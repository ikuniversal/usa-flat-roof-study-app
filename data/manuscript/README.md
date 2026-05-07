# USA Flat Roof — Manuscript Content Extraction & Import

## What's in this handoff

Three artifacts:

1. **`extracted-content.json`** (~965 KB, 540 section rows) — full manuscript content extracted from the April 27 + April 29, 2026 transcripts, structured for import into the `sections` table. Produced by running `reassemble.py` against the three chunk files.

2. **`schema-reset.sql`** (~100 KB, 717 lines) — destructive SQL that deletes the existing Cody-generated section template for Parts 1–3 and inserts the manuscript's actual section structure (correct titles, variable per-chapter section counts, instructor-only flags, display_order). Run this BEFORE the import script.

3. **`reassemble.py`** — concatenates `chunk_1_of_3.json` + `chunk_2_of_3.json` + `chunk_3_of_3.json` into `extracted-content.json`, validating the row count matches the metadata.

## Why this is needed

The database was scaffolded with a uniform 27-section template per chapter (Parts 1–2) and 5-section template per module (Part 3). The manuscript actually has variable section counts per chapter — between 5 and 27 — based on chapter depth (Core / Secondary / Reference). Director's call: manuscript is the source of truth. Schema gets reshaped to match.

## Extraction summary

| Part | Chapters/Modules | Sections |
|------|-----------------|----------|
| 1 — Roof Systems | 10 | 227 |
| 2 — Supporting Topics | 8 | 137 |
| 3 — Sales Modules | 13 | 176 |
| **Total** | **31** | **540** |

Per-chapter counts:
- Part 1: Ch1=27, Ch2=27, Ch3=27, Ch4=27, Ch5=24, Ch6=24, Ch7=5, Ch8=20, Ch9=22, Ch10=24
- Part 2: Ch11=18, Ch12=18, Ch13=18, Ch14=16, Ch15=16, Ch16=16, Ch17=18, Ch18=17
- Part 3: M1=11, M2=12, M3=13, M4=12, M5=13, M6=16, M7=17, M8=13, M9=14, M10=14, M11=13, M12=14, M13=14

Health check on extracted bodies:
- 540/540 sections have non-empty bodies
- 0 sections under 100 chars
- 34 sections flagged instructor-only
- All bodies preserve em-dashes, formatting, and instructor-only marker blocks

## Two-phase task

### Phase A — Schema reset

1. Apply `schema-reset.sql` inside an explicit transaction.
2. Pre-flight checks:
   - Confirm `book_parts` has rows for `part_number IN (1, 2, 3)`
   - Confirm `chapters` has 31 rows tied to those parts (10 + 8 + 13)
   - Confirm `bookmarks` and `reading_progress` have zero rows for Parts 1–3 sections (if non-zero, STOP and notify director — those rows will be deleted)
3. Apply, then verify:
   - 540 section rows exist across Parts 1–3
   - Chapter titles match manuscript
4. Wait for director approval before Phase B.

### Phase B — Content import

Write `scripts/extract-and-import-content.ts`. Read `data/manuscript/extracted-content.json`. For each row, look up DB section by `(part_number, chapter_number, section_number)` joining through `book_parts → chapters → sections`. Populate `content_markdown`. Write `content_revisions` audit row.

Reconciliations from prior spec all stand:
- Use `is_instructor_only` (already correctly populated by Phase A — do NOT touch)
- `content_revisions` columns: `edited_by`, `previous_content`, `new_content`, `edit_note`, `edited_at`
- Admin (service-role) client, resolve editor profile id from `ikuniversal@gmail.com` at startup
- `--dry-run` default, `--commit` required
- Single transaction, idempotent skip on body equality
- `edit_note = 'Imported from April 2026 source manuscript'`
- Halt if matched < 540, halt if any unmatched rows

After Phase B: all 540 sections have populated `content_markdown`, 540 rows in `content_revisions`, Content Editor admin UI shows correct counts and live content.
