"""Generate the Phase B content-import migration SQL.

Produces FOUR files under supabase/migrations/:

  0004_manuscript_content_import.sql           (all 540 sections, single tx)
  0004a_manuscript_content_part1.sql           (Part 1 only, 227 sections)
  0004b_manuscript_content_part2.sql           (Part 2 only, 137 sections)
  0004c_manuscript_content_part3.sql           (Part 3 only, 176 sections)

The single-file form is the primary deliverable. The three per-part files
are a fallback if the Supabase web SQL editor truncates the ~1 MB single
file. Each per-part file is its own atomic transaction with its own
scoped temp table and its own scoped defensive safety check.

Each output file uses the same structure:
  BEGIN;
  CREATE TEMP TABLE _import_previous (...) ON COMMIT DROP;
  INSERT INTO _import_previous SELECT (current values for in-scope sections);
  -- N UPDATEs (one per in-scope section)
  INSERT INTO content_revisions SELECT (joining temp + sections);
  DO $$ ... safety check, RAISE EXCEPTION on miscount ... $$;
  COMMIT;

Run from the repo root:
  python3 scripts/generate-manuscript-migration.py
"""

import json
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC = REPO_ROOT / 'data/manuscript/extracted-content.json'
OUT_DIR = REPO_ROOT / 'supabase/migrations'

EDIT_NOTE = 'Imported from April 2026 source manuscript'
EDITOR_EMAIL = 'ikuniversal@gmail.com'

# Per-part expected row counts (must match per-chapter sums in the README).
EXPECTED_BY_PART = {1: 227, 2: 137, 3: 176}
TOTAL_EXPECTED = sum(EXPECTED_BY_PART.values())  # 540


def pick_tag(bodies: list[str]) -> str:
    """Pick a dollar-quote tag that does not collide with any body content."""
    for tag in ['$mfst$', '$mfst2026$', '$msbody_v1$', '$_manuscript_2026_$']:
        if not any(tag in b for b in bodies):
            return tag
    print('ERROR: every candidate dollar-quote tag collides with body content.', file=sys.stderr)
    sys.exit(1)


def render_header(out: list[str], scope_label: str, scope_count: int, parts_in_scope: list[int], tag: str) -> None:
    parts_str = ', '.join(str(p) for p in parts_in_scope)
    out.append(f'-- Phase B content import: manuscript bodies -> sections.content_markdown ({scope_label})')
    out.append('-- Source: data/manuscript/extracted-content.json')
    out.append(f'-- Scope: Part(s) {parts_str}, {scope_count} sections')
    out.append('-- Companion to scripts/extract-and-import-content.ts (the live equivalent).')
    out.append('-- Atomicity: single transaction. Either all in-scope sections update + their')
    out.append('-- content_revisions rows insert, or nothing changes (defensive count check')
    out.append('-- before COMMIT raises and rolls back if the post-import populated count is')
    out.append(f'-- not exactly {scope_count}).')
    out.append('-- Idempotency: NOT idempotent on its own. Re-running this file would attempt')
    out.append('-- a second UPDATE (no-op since content matches) plus a second INSERT into')
    out.append('-- content_revisions, producing duplicate audit rows. To recover from a')
    out.append('-- partial / interrupted run, prefer the TS script which IS idempotent via')
    out.append('-- body equality. Or run manual cleanup of duplicates.')
    out.append(f'-- Dollar-quote tag for body strings: {tag}')
    out.append('')


def render_temp_table_capture(out: list[str], parts_in_scope: list[int]) -> None:
    out.append('-- Capture pre-update content_markdown for in-scope sections.')
    out.append('-- This temp table feeds the content_revisions previous_content column.')
    out.append('CREATE TEMP TABLE _import_previous (')
    out.append('  section_id UUID PRIMARY KEY,')
    out.append('  previous_content TEXT NOT NULL')
    out.append(') ON COMMIT DROP;')
    out.append('')
    out.append('INSERT INTO _import_previous (section_id, previous_content)')
    out.append('SELECT s.id, s.content_markdown')
    out.append('FROM sections s')
    out.append('JOIN chapters c ON s.chapter_id = c.id')
    out.append('JOIN book_parts p ON c.part_id = p.id')
    if len(parts_in_scope) == 1:
        out.append(f'WHERE p.part_number = {parts_in_scope[0]};')
    else:
        parts_list = ', '.join(str(p) for p in parts_in_scope)
        out.append(f'WHERE p.part_number IN ({parts_list});')
    out.append('')


def render_updates(out: list[str], rows: list[dict], tag: str) -> None:
    out.append(f'-- {len(rows)} UPDATE statements: one per manuscript section.')
    out.append('-- Subquery resolves section.id by (part_number, chapter_number, section_number).')
    out.append('-- Each UPDATE writes the manuscript body and bumps updated_at.')
    out.append('')
    for r in rows:
        part = r['part_number']
        chap = r['chapter_number']
        sec = r['section_number']
        body = r['body_markdown']
        out.append(f'-- Part {part} / Ch {chap} / Sec {sec}: {r["section_title"]}')
        out.append('UPDATE sections SET')
        out.append(f'  content_markdown = {tag}{body}{tag},')
        out.append('  updated_at = NOW()')
        out.append('WHERE id = (')
        out.append('  SELECT s.id FROM sections s')
        out.append('  JOIN chapters c ON s.chapter_id = c.id')
        out.append('  JOIN book_parts p ON c.part_id = p.id')
        out.append(
            f"  WHERE p.part_number = {part} AND c.chapter_number = {chap} "
            f"AND s.section_number = '{sec}'"
        )
        out.append(');')
        out.append('')


def render_revisions_insert(out: list[str]) -> None:
    out.append('-- Single INSERT capturing all in-scope audit rows.')
    out.append('-- previous_content comes from the temp table populated above (pre-UPDATE values).')
    out.append('-- new_content reads from sections live, which now reflects the post-UPDATE bodies.')
    out.append('INSERT INTO content_revisions (')
    out.append('  section_id, edited_by, previous_content, new_content, edit_note, edited_at')
    out.append(')')
    out.append('SELECT')
    out.append('  ip.section_id,')
    out.append(f"  (SELECT id FROM profiles WHERE email = '{EDITOR_EMAIL}'),")
    out.append('  ip.previous_content,')
    out.append('  s.content_markdown,')
    out.append(f"  '{EDIT_NOTE}',")
    out.append('  NOW()')
    out.append('FROM _import_previous ip')
    out.append('JOIN sections s ON s.id = ip.section_id;')
    out.append('')


def render_safety_check(out: list[str], parts_in_scope: list[int], scope_count: int, scope_label: str) -> None:
    out.append('-- Defensive safety check: verify exactly N sections in scope are now populated.')
    out.append('-- If any UPDATE silently no-op\'d (e.g. lookup subquery returned no rows),')
    out.append('-- the count below will be wrong and the RAISE EXCEPTION rolls back the')
    out.append('-- entire transaction. This catches generator bugs, schema drift, and any')
    out.append('-- partial-state hazard before COMMIT.')
    out.append('DO $$')
    out.append('DECLARE')
    out.append('  populated_count integer;')
    out.append('BEGIN')
    out.append('  SELECT COUNT(*) INTO populated_count')
    out.append('  FROM sections s')
    out.append('  JOIN chapters c ON s.chapter_id = c.id')
    out.append('  JOIN book_parts p ON c.part_id = p.id')
    if len(parts_in_scope) == 1:
        out.append(f'  WHERE p.part_number = {parts_in_scope[0]}')
    else:
        parts_list = ', '.join(str(p) for p in parts_in_scope)
        out.append(f'  WHERE p.part_number IN ({parts_list})')
    out.append("    AND s.content_markdown != ''")
    out.append('    AND s.content_markdown IS NOT NULL;')
    out.append(f'  IF populated_count != {scope_count} THEN')
    out.append(
        f"    RAISE EXCEPTION 'Phase B import safety check failed ({scope_label}): "
        f"expected {scope_count} populated sections, found %. Transaction rolled back.', "
        f'populated_count;'
    )
    out.append('  END IF;')
    out.append('END $$;')
    out.append('')


def render_full_migration(rows: list[dict], parts_in_scope: list[int], scope_label: str, tag: str) -> str:
    expected = sum(EXPECTED_BY_PART[p] for p in parts_in_scope)
    if len(rows) != expected:
        raise RuntimeError(
            f"row count mismatch for {scope_label}: got {len(rows)}, expected {expected}"
        )
    out: list[str] = []
    render_header(out, scope_label, expected, parts_in_scope, tag)
    out.append('BEGIN;')
    out.append('')
    render_temp_table_capture(out, parts_in_scope)
    render_updates(out, rows, tag)
    render_revisions_insert(out)
    render_safety_check(out, parts_in_scope, expected, scope_label)
    out.append('COMMIT;')
    out.append('')
    return '\n'.join(out)


def write_and_report(path: Path, content: str) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(content, encoding='utf-8')
    size = len(content)
    lines = content.count('\n') + 1
    print(f'  Wrote {path.relative_to(REPO_ROOT)}')
    print(f'    Size: {size:,} bytes ({size/1024:,.1f} KB)')
    print(f'    Lines: {lines:,}')


def main() -> None:
    with SRC.open(encoding='utf-8') as f:
        data = json.load(f)
    rows = data['rows']
    if len(rows) != TOTAL_EXPECTED:
        print(f'ERROR: expected {TOTAL_EXPECTED} rows, got {len(rows)}', file=sys.stderr)
        sys.exit(1)

    bodies = [r['body_markdown'] for r in rows]
    tag = pick_tag(bodies)
    print(f'Dollar-quote tag: {tag}')
    print()

    # Single-file (all 540).
    print('Single-file (all 540 sections):')
    single_sql = render_full_migration(rows, [1, 2, 3], 'all parts', tag)
    write_and_report(OUT_DIR / '0004_manuscript_content_import.sql', single_sql)
    print()

    # Per-part splits.
    for part_n, suffix in [(1, 'a'), (2, 'b'), (3, 'c')]:
        part_rows = [r for r in rows if r['part_number'] == part_n]
        print(f'Per-part split for Part {part_n} ({len(part_rows)} sections):')
        sql = render_full_migration(part_rows, [part_n], f'Part {part_n} only', tag)
        out_path = OUT_DIR / f'0004{suffix}_manuscript_content_part{part_n}.sql'
        write_and_report(out_path, sql)
        print()


if __name__ == '__main__':
    main()
