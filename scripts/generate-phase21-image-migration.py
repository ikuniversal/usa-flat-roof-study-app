"""Generate the Phase 21 batch image-import migration SQL.

Replaces 14 [IMAGE #N] metadata placeholder blocks in Part 1 with
markdown image references pointing to the content-images Supabase
Storage bucket. Pairs each UPDATE with a content_revisions audit row.

Reads the verbatim OLD blocks from data/manuscript/extracted-content.json
(the same source that fed Phase 20) so the generated SQL is fully
deterministic and can be re-derived from committed inputs.

Single transaction. Halts and rolls back if:
  - any [IMAGE block remains in Part 1 after all UPDATEs (UPDATE no-op
    means OLD block didn't match — drift between source and live data); or
  - the audit-row count for the batch is not exactly 14.

Run from the repo root:
  python3 scripts/generate-phase21-image-migration.py
"""

import json
import re
import sys
from pathlib import Path

REPO_ROOT = Path(__file__).resolve().parent.parent
SRC = REPO_ROOT / 'data/manuscript/extracted-content.json'
OUT_PATH = REPO_ROOT / 'supabase/migrations/0005_phase21_image_import.sql'

BUCKET_URL_PREFIX = (
    'https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/'
)
EDITOR_EMAIL = 'ikuniversal@gmail.com'

# Director-supplied UUID -> section mapping. image_number is the [IMAGE #N]
# index that should be replaced (some sections have #1, others #2 — both
# variants exist in Part 1; the test image at P1/Ch1/Sec4 uses a separate
# UUID and is intentionally excluded from this batch).
MAPPING = [
    # (uuid, part, chap, sec, image_number)
    ('0B3BAAC5-5F31-4EF9-90FA-3AD0526CED27', 1, 1, '6', 2),
    ('4A487804-DA54-495C-AEB5-BA8C1306FC8C', 1, 2, '4', 1),
    ('B1A01A5A-8444-4CD4-9074-13A0D5ED191E', 1, 2, '6', 2),
    ('F76C055C-0F7A-4BB3-971E-0608C2088116', 1, 3, '4', 1),
    ('2202847B-AD25-4028-8A45-3F42A98078DA', 1, 3, '6', 2),
    ('B27B1465-11E3-48E8-B279-CC924E7D41A3', 1, 4, '4', 1),
    ('B09AABBD-86AA-407A-B0E1-E7071E91FED7', 1, 5, '4', 1),
    ('429E4CB5-84AF-4237-9ED7-6E3617D1D671', 1, 6, '4', 1),
    ('BAC9C660-FF32-43F4-BF4D-97370E909F2A', 1, 6, '6', 2),
    ('3C56D259-49D5-4049-8072-1554C3A8EFB4', 1, 8, '4', 1),
    ('18AF2508-280C-493D-86A6-CF159D237754', 1, 8, '6', 2),
    ('7A1FEF90-03A2-4E57-8252-33A3CFFEC8DF', 1, 9, '4', 1),
    ('8420B21B-A1E8-4B8D-B5E6-53B2EA921469', 1, 10, '4', 1),
    ('30C9E644-A611-46CC-8001-086ECF90AFBE', 1, 10, '6', 2),
]
EXPECTED_COUNT = len(MAPPING)  # 14


def find_row(rows: list[dict], part: int, chap: int, sec: str) -> dict:
    """Locate a manuscript row. JSON stores section_number as int but the
    live DB stores it as text — match against the int form."""
    sec_int = int(sec)
    for r in rows:
        if (
            r['part_number'] == part
            and r['chapter_number'] == chap
            and r['section_number'] == sec_int
        ):
            return r
    raise RuntimeError(f'No manuscript row for P{part}/Ch{chap}/Sec{sec}')


def extract_image_block(body: str, image_number: int) -> str:
    """Return the [IMAGE #N] block from the body, from the marker through
    the end of the trailing 'Review status: ...' line (inclusive)."""
    marker = f'[IMAGE #{image_number}]'
    start = body.find(marker)
    if start == -1:
        raise RuntimeError(f'Marker {marker!r} not found in body')
    after = body[start:]
    m = re.search(r'^Review status: [^\n]*$', after, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f'No "Review status:" line after {marker!r}')
    return after[:m.end()]


def parse_field(block: str, name: str) -> str:
    m = re.search(rf'^{re.escape(name)}: (.*)$', block, flags=re.MULTILINE)
    if not m:
        raise RuntimeError(f'No "{name}:" field in block:\n{block}')
    return m.group(1).strip()


def pick_tag(strings: list[str]) -> str:
    for tag in ['$ph21$', '$ph21img$', '$_phase21_$', '$ph21body$']:
        if not any(tag in s for s in strings):
            return tag
    print('ERROR: every candidate dollar-quote tag collides with content.', file=sys.stderr)
    sys.exit(1)


def render(entries: list[dict], tag: str) -> str:
    out: list[str] = []
    out.append('-- Phase 21 batch image import: replace [IMAGE #N] placeholders -> markdown images')
    out.append('-- Source: data/manuscript/extracted-content.json (for verbatim OLD-block matching)')
    out.append('-- Target: 14 sections in Part 1 (chapter/section list below)')
    out.append('-- Companion to scripts/generate-phase21-image-migration.py.')
    out.append('-- Atomicity: single transaction. Either all 14 UPDATEs apply + their')
    out.append('-- content_revisions rows insert, or nothing changes (defensive checks')
    out.append('-- before COMMIT roll back if any [IMAGE block remains in Part 1, or if')
    out.append('-- the audit-row count for the batch is not exactly 14).')
    out.append('-- Idempotency: NOT idempotent. Re-running this file would no-op the')
    out.append('-- UPDATEs (REPLACE finds nothing) but insert 14 more audit rows. Do not re-run.')
    out.append(f'-- Dollar-quote tag for body strings: {tag}')
    out.append('--')
    out.append('-- In-scope sections (P1/Ch/Sec -> bucket UUID):')
    for e in entries:
        out.append(f'--   P1/Ch{e["chap"]}/Sec{e["sec"]} -> {e["uuid"]}.png  (replaces [IMAGE #{e["image_number"]}])')
    out.append('')

    out.append('BEGIN;')
    out.append('')

    out.append('-- Capture pre-update content_markdown for the 14 in-scope sections.')
    out.append('-- This temp table feeds the content_revisions previous_content column.')
    out.append('CREATE TEMP TABLE _img_import_previous (')
    out.append('  section_id UUID PRIMARY KEY,')
    out.append('  previous_content TEXT NOT NULL')
    out.append(') ON COMMIT DROP;')
    out.append('')
    out.append('INSERT INTO _img_import_previous (section_id, previous_content)')
    out.append('SELECT s.id, s.content_markdown')
    out.append('FROM sections s')
    out.append('JOIN chapters c ON s.chapter_id = c.id')
    out.append('JOIN book_parts p ON c.part_id = p.id')
    out.append('WHERE p.part_number = 1')
    out.append('  AND (c.chapter_number, s.section_number) IN (')
    for i, e in enumerate(entries):
        sep = ',' if i < len(entries) - 1 else ''
        out.append(f"    ({e['chap']}, '{e['sec']}'){sep}")
    out.append('  );')
    out.append('')

    out.append(f'-- {EXPECTED_COUNT} UPDATE statements: one per in-scope section.')
    out.append('-- Each UPDATE uses REPLACE() so a stale OLD block (drift since this file')
    out.append('-- was generated) becomes a silent no-op, which the post-update [IMAGE')
    out.append('-- residue check at the bottom of the transaction catches.')
    out.append('')
    for e in entries:
        out.append(
            f'-- P1 / Ch {e["chap"]} / Sec {e["sec"]}: '
            f'[IMAGE #{e["image_number"]}] -> {e["uuid"]}.png'
        )
        out.append('UPDATE sections SET')
        out.append('  content_markdown = REPLACE(content_markdown,')
        out.append(f'    {tag}{e["old_block"]}{tag},')
        out.append(f'    {tag}{e["new_md"]}{tag}),')
        out.append('  updated_at = NOW()')
        out.append('WHERE id = (')
        out.append('  SELECT s.id FROM sections s')
        out.append('  JOIN chapters c ON s.chapter_id = c.id')
        out.append('  JOIN book_parts p ON c.part_id = p.id')
        out.append(
            f"  WHERE p.part_number = 1 AND c.chapter_number = {e['chap']} "
            f"AND s.section_number = '{e['sec']}'"
        )
        out.append(');')
        out.append('')

    out.append('-- Single INSERT capturing all 14 audit rows.')
    out.append('-- previous_content comes from the temp table populated above (pre-UPDATE values).')
    out.append('-- new_content reads from sections live, which now reflects the post-UPDATE bodies.')
    out.append('-- edit_note is computed per-row to record which P/Ch/Sec each row covers.')
    out.append('INSERT INTO content_revisions (')
    out.append('  section_id, edited_by, previous_content, new_content, edit_note, edited_at')
    out.append(')')
    out.append('SELECT')
    out.append('  ip.section_id,')
    out.append(f"  (SELECT id FROM profiles WHERE email = '{EDITOR_EMAIL}'),")
    out.append('  ip.previous_content,')
    out.append('  s.content_markdown,')
    out.append("  'Phase 21 batch image import: replaced [IMAGE] placeholder in P'")
    out.append("    || p.part_number || '/Ch' || c.chapter_number || '/Sec'")
    out.append("    || s.section_number || ' with AI-generated image',")
    out.append('  NOW()')
    out.append('FROM _img_import_previous ip')
    out.append('JOIN sections s ON s.id = ip.section_id')
    out.append('JOIN chapters c ON s.chapter_id = c.id')
    out.append('JOIN book_parts p ON c.part_id = p.id;')
    out.append('')

    out.append('-- Defensive safety checks. If either fails the entire transaction')
    out.append('-- rolls back and no rows are written.')
    out.append('DO $$')
    out.append('DECLARE')
    out.append('  still_present integer;')
    out.append('  rev_count integer;')
    out.append('BEGIN')
    out.append('  -- Check #1: no [IMAGE blocks remain anywhere in Part 1.')
    out.append('  --   If any UPDATE silently no-op\'d (OLD-block drift vs. live data),')
    out.append('  --   the [IMAGE marker would still be present in that section.')
    out.append('  SELECT COUNT(*) INTO still_present')
    out.append('  FROM sections s')
    out.append('  JOIN chapters c ON s.chapter_id = c.id')
    out.append('  JOIN book_parts p ON c.part_id = p.id')
    out.append("  WHERE p.part_number = 1 AND s.content_markdown LIKE '%[IMAGE%';")
    out.append('  IF still_present <> 0 THEN')
    out.append("    RAISE EXCEPTION 'Phase 21 image import safety check #1 failed: % [IMAGE blocks still present in Part 1 after UPDATEs. Transaction rolled back.', still_present;")
    out.append('  END IF;')
    out.append('')
    out.append(f'  -- Check #2: exactly {EXPECTED_COUNT} audit rows for the batch.')
    out.append('  SELECT COUNT(*) INTO rev_count')
    out.append('  FROM content_revisions cr')
    out.append("  WHERE cr.edit_note LIKE 'Phase 21 batch image import:%'")
    out.append('    AND cr.section_id IN (SELECT section_id FROM _img_import_previous);')
    out.append(f'  IF rev_count <> {EXPECTED_COUNT} THEN')
    out.append(f"    RAISE EXCEPTION 'Phase 21 image import safety check #2 failed: expected {EXPECTED_COUNT} audit rows for the batch, found %. Transaction rolled back.', rev_count;")
    out.append('  END IF;')
    out.append('END $$;')
    out.append('')
    out.append('COMMIT;')
    out.append('')
    return '\n'.join(out)


def main() -> None:
    with SRC.open(encoding='utf-8') as f:
        data = json.load(f)
    rows = data['rows']

    entries: list[dict] = []
    for uuid, part, chap, sec, image_number in MAPPING:
        row = find_row(rows, part, chap, sec)
        block = extract_image_block(row['body_markdown'], image_number)
        alt = parse_field(block, 'Alt text')
        caption = parse_field(block, 'Caption')
        url = f'{BUCKET_URL_PREFIX}{uuid}.png'
        new_md = f'![{alt}]({url})\n*{caption}*'
        entries.append({
            'uuid': uuid,
            'part': part,
            'chap': chap,
            'sec': sec,
            'image_number': image_number,
            'alt': alt,
            'caption': caption,
            'url': url,
            'old_block': block,
            'new_md': new_md,
        })

    candidates: list[str] = []
    for e in entries:
        candidates.append(e['old_block'])
        candidates.append(e['new_md'])
    tag = pick_tag(candidates)

    sql = render(entries, tag)
    OUT_PATH.parent.mkdir(parents=True, exist_ok=True)
    OUT_PATH.write_text(sql, encoding='utf-8')

    size = len(sql)
    lines = sql.count('\n') + 1
    print(f'Wrote {OUT_PATH.relative_to(REPO_ROOT)}')
    print(f'  Tag: {tag}')
    print(f'  Sections: {len(entries)}')
    print(f'  Size: {size:,} bytes ({size/1024:,.1f} KB)')
    print(f'  Lines: {lines:,}')
    print()
    print('DIGEST (alt + caption parsed from manuscript source):')
    print()
    for e in entries:
        print(f'  P1 / Ch {e["chap"]:>2} / Sec {e["sec"]}  ({e["uuid"]}.png)  [IMAGE #{e["image_number"]}]')
        print(f'    Alt:     {e["alt"]}')
        print(f'    Caption: {e["caption"]}')
        print()


if __name__ == '__main__':
    main()
