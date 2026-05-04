// Imports the USA Flat Roof Field Guide manuscript content into the
// `sections.content_markdown` column from data/manuscript/extracted-content.json.
// Phase B of the manuscript handoff. Phase A (schema-reset.sql) must
// already have been applied before this script can be run.
//
// Usage:
//   npx tsx --env-file=.env.local scripts/extract-and-import-content.ts
//                                                       (DRY-RUN, no writes)
//   npx tsx --env-file=.env.local scripts/extract-and-import-content.ts --commit
//                                                       (LIVE, writes to DB)
//
// Transaction model
// -----------------
// PostgREST (what @supabase/supabase-js talks to) doesn't expose a
// multi-statement transaction API. Each REST call is its own transaction.
// We therefore use PER-ROW atomicity rather than whole-batch atomicity:
//
//   for each row to update:
//     1. UPDATE sections SET content_markdown=..., updated_at=NOW() WHERE id=...
//     2. INSERT INTO content_revisions (...) VALUES (...)
//     3. If either fails, halt the batch immediately. Do not advance.
//
// Recovery story
// --------------
// The script is idempotent on re-run via body equality. If the batch halts
// partway through, re-running with --commit will:
//   - Skip any section whose content_markdown already equals the new body
//     (these were committed in the prior run, no second revision row written)
//   - Resume work on the remaining sections
// To re-import a section even if the body matches (e.g. to refresh the
// audit trail), clear the row's content_markdown first via the admin UI.
//
// Edge case
// ---------
// Per-row atomicity means within a single row, the UPDATE could succeed
// and the content_revisions INSERT could fail (network blip, RLS edge,
// etc.). The blast radius is exactly one row: the section is updated
// without a corresponding revisions audit entry. This is acceptable
// because:
//   - The blast radius is tiny (1 row, not the whole batch)
//   - The next halt-and-report makes it visible (we know exactly where)
//   - Manual repair is straightforward (insert the missing revisions row
//     by hand from the script's per-row log)
// We do NOT attempt to roll back the UPDATE if the INSERT fails — that
// would require a second UPDATE-back-to-empty which itself could fail,
// digging the hole deeper. Halt-and-report is the safer behavior.
//
// What this script does NOT touch
// -------------------------------
// - sections.title, sections.is_instructor_only, sections.display_order,
//   sections.section_number — Phase A populated these, leave alone.
// - chapters or book_parts — Phase A renamed them.
// - quizzes or any other table.
// - .env.local or any config file.

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { readFileSync } from 'node:fs';
import path from 'node:path';

// ---------------------------------------------------------------------------
// CLI args
// ---------------------------------------------------------------------------
const commit = process.argv.includes('--commit');
const dryRun = !commit;

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------
function log(msg: string): void {
  const prefix = dryRun ? '[DRY-RUN]' : '[LIVE]';
  console.log(`${prefix} ${msg}`);
}

function err(msg: string): never {
  console.error(`[ERROR] ${msg}`);
  process.exit(1);
}

// ---------------------------------------------------------------------------
// Inline admin client (mirrors scripts/import-content.ts conventions)
// ---------------------------------------------------------------------------
function createAdminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url) {
    err('NEXT_PUBLIC_SUPABASE_URL is not set. Add it to .env.local.');
  }
  if (!serviceKey) {
    err('SUPABASE_SERVICE_ROLE_KEY is not set. Add it to .env.local.');
  }
  return createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

// ---------------------------------------------------------------------------
// Constants
// ---------------------------------------------------------------------------
const MANUSCRIPT_PATH = path.resolve(
  process.cwd(),
  'data/manuscript/extracted-content.json',
);
const EDITOR_EMAIL = 'ikuniversal@gmail.com';
const EDIT_NOTE = 'Imported from April 2026 source manuscript';
const EXPECTED_ROWS = 540;
const EXPECTED_INSTRUCTOR_ONLY = 34;

// ---------------------------------------------------------------------------
// JSON shape
// ---------------------------------------------------------------------------
interface ManuscriptRow {
  part_number: number;
  chapter_number: number;
  section_number: number;
  section_title: string;
  body_markdown: string;
  source: string;
  is_instructor_only_in_source: boolean;
}

interface ManuscriptFile {
  metadata: {
    total_rows: number;
    instructor_only_count: number;
    sources: Record<string, unknown>;
    [k: string]: unknown;
  };
  rows: ManuscriptRow[];
}

// ---------------------------------------------------------------------------
// DB row shapes (subset used here)
// ---------------------------------------------------------------------------
interface DbBookPart {
  id: string;
  part_number: number;
}

interface DbChapter {
  id: string;
  chapter_number: number;
  part_id: string;
}

interface DbSection {
  id: string;
  chapter_id: string;
  section_number: string; // TEXT in the DB
  title: string;
  content_markdown: string;
}

// ---------------------------------------------------------------------------
// Lookup-map key
// ---------------------------------------------------------------------------
function lookupKey(part: number | string, chap: number | string, sec: number | string): string {
  return `${String(part)}|${String(chap)}|${String(sec)}`;
}

// ---------------------------------------------------------------------------
// JSON load + validate
// ---------------------------------------------------------------------------
function loadAndValidateManuscript(): ManuscriptFile {
  let raw: string;
  try {
    raw = readFileSync(MANUSCRIPT_PATH, 'utf8');
  } catch (e) {
    err(`Could not read ${MANUSCRIPT_PATH}: ${(e as Error).message}`);
  }
  let parsed: ManuscriptFile;
  try {
    parsed = JSON.parse(raw) as ManuscriptFile;
  } catch (e) {
    err(`extracted-content.json is not valid JSON: ${(e as Error).message}`);
  }
  if (!parsed || !Array.isArray(parsed.rows) || !parsed.metadata) {
    err('extracted-content.json missing top-level `metadata` or `rows`.');
  }
  if (parsed.rows.length !== EXPECTED_ROWS) {
    err(
      `Row count mismatch: file has ${parsed.rows.length}, expected ${EXPECTED_ROWS}.`,
    );
  }
  if (parsed.metadata.total_rows !== EXPECTED_ROWS) {
    err(
      `metadata.total_rows = ${parsed.metadata.total_rows}, expected ${EXPECTED_ROWS}.`,
    );
  }
  if (parsed.metadata.instructor_only_count !== EXPECTED_INSTRUCTOR_ONLY) {
    err(
      `metadata.instructor_only_count = ${parsed.metadata.instructor_only_count}, expected ${EXPECTED_INSTRUCTOR_ONLY}.`,
    );
  }
  log(
    `Loaded ${parsed.rows.length} manuscript rows from ${path.relative(process.cwd(), MANUSCRIPT_PATH)}.`,
  );
  return parsed;
}

// ---------------------------------------------------------------------------
// Resolve editor profile
// ---------------------------------------------------------------------------
async function resolveEditorId(supabase: SupabaseClient): Promise<string> {
  const { data, error } = await supabase
    .from('profiles')
    .select('id, email')
    .eq('email', EDITOR_EMAIL)
    .maybeSingle<{ id: string; email: string }>();
  if (error) {
    err(`Profiles query failed: ${error.message}`);
  }
  if (!data) {
    err(
      `No profiles row found for editor email '${EDITOR_EMAIL}'. ` +
        'Create the account or update EDITOR_EMAIL constant before running.',
    );
  }
  log(`Editor resolved: ${data.email} (profile id ${data.id}).`);
  return data.id;
}

// ---------------------------------------------------------------------------
// Build section lookup map keyed by (part_number, chapter_number, section_number)
// ---------------------------------------------------------------------------
async function buildSectionLookup(
  supabase: SupabaseClient,
): Promise<Map<string, DbSection & { part_number: number; chapter_number: number }>> {
  const { data: parts, error: partsErr } = await supabase
    .from('book_parts')
    .select('id, part_number')
    .in('part_number', [1, 2, 3])
    .returns<DbBookPart[]>();
  if (partsErr) err(`book_parts query failed: ${partsErr.message}`);
  if (!parts || parts.length === 0) err('No book_parts rows found for parts 1-3.');

  const partIds = parts.map((p) => p.id);
  const partNumberByPartId = new Map(parts.map((p) => [p.id, p.part_number]));

  const { data: chapters, error: chErr } = await supabase
    .from('chapters')
    .select('id, chapter_number, part_id')
    .in('part_id', partIds)
    .returns<DbChapter[]>();
  if (chErr) err(`chapters query failed: ${chErr.message}`);
  if (!chapters || chapters.length === 0) err('No chapters rows found for parts 1-3.');

  const chapterIds = chapters.map((c) => c.id);
  const chapterMetaById = new Map(
    chapters.map((c) => [
      c.id,
      {
        chapter_number: c.chapter_number,
        part_number: partNumberByPartId.get(c.part_id) ?? -1,
      },
    ]),
  );

  // Sections fetched in chunks of <=200 to avoid query-string limits when
  // chapterIds list grows. 31 chapters today, but defensive.
  const allSections: DbSection[] = [];
  const CHUNK = 200;
  for (let i = 0; i < chapterIds.length; i += CHUNK) {
    const slice = chapterIds.slice(i, i + CHUNK);
    const { data, error } = await supabase
      .from('sections')
      .select('id, chapter_id, section_number, title, content_markdown')
      .in('chapter_id', slice)
      .returns<DbSection[]>();
    if (error) err(`sections query failed: ${error.message}`);
    if (data) allSections.push(...data);
  }

  const map = new Map<string, DbSection & { part_number: number; chapter_number: number }>();
  for (const s of allSections) {
    const meta = chapterMetaById.get(s.chapter_id);
    if (!meta) continue; // shouldn't happen — section has FK to chapter we already fetched
    const key = lookupKey(meta.part_number, meta.chapter_number, s.section_number);
    map.set(key, { ...s, ...meta });
  }
  log(
    `Built section lookup: ${parts.length} parts, ${chapters.length} chapters, ${allSections.length} sections.`,
  );
  return map;
}

// ---------------------------------------------------------------------------
// Plan classification
// ---------------------------------------------------------------------------
interface PlannedUpdate {
  row: ManuscriptRow;
  section_id: string;
  previous_content: string;
  new_content: string;
}

interface TitleMismatch {
  part_number: number;
  chapter_number: number;
  section_number: number;
  json_title: string;
  db_title: string;
}

interface UnmatchedRow {
  part_number: number;
  chapter_number: number;
  section_number: number;
  section_title: string;
}

interface Plan {
  total: number;
  matched: number;
  unmatched: UnmatchedRow[];
  toUpdate: PlannedUpdate[];
  toSkip: number;
  titleMismatches: TitleMismatch[];
}

function buildPlan(
  manuscript: ManuscriptFile,
  sectionLookup: Map<string, DbSection & { part_number: number; chapter_number: number }>,
): Plan {
  const plan: Plan = {
    total: manuscript.rows.length,
    matched: 0,
    unmatched: [],
    toUpdate: [],
    toSkip: 0,
    titleMismatches: [],
  };

  for (const row of manuscript.rows) {
    const key = lookupKey(row.part_number, row.chapter_number, row.section_number);
    const dbRow = sectionLookup.get(key);
    if (!dbRow) {
      plan.unmatched.push({
        part_number: row.part_number,
        chapter_number: row.chapter_number,
        section_number: row.section_number,
        section_title: row.section_title,
      });
      continue;
    }
    plan.matched += 1;

    if (dbRow.title.trim() !== row.section_title.trim()) {
      plan.titleMismatches.push({
        part_number: row.part_number,
        chapter_number: row.chapter_number,
        section_number: row.section_number,
        json_title: row.section_title,
        db_title: dbRow.title,
      });
    }

    if (dbRow.content_markdown === row.body_markdown) {
      plan.toSkip += 1;
    } else {
      plan.toUpdate.push({
        row,
        section_id: dbRow.id,
        previous_content: dbRow.content_markdown,
        new_content: row.body_markdown,
      });
    }
  }
  return plan;
}

// ---------------------------------------------------------------------------
// Halt checks
// ---------------------------------------------------------------------------
function enforceHaltConditions(plan: Plan): void {
  if (plan.matched < EXPECTED_ROWS) {
    err(
      `Matched ${plan.matched} of ${plan.total} expected (${EXPECTED_ROWS}). ` +
        `Halt before any writes. ${plan.unmatched.length} rows did not match a DB section.`,
    );
  }
  if (plan.unmatched.length > 0) {
    err(
      `${plan.unmatched.length} unmatched row(s) in extracted-content.json. ` +
        'Halt before any writes. See unmatched list above.',
    );
  }
}

// ---------------------------------------------------------------------------
// Report printer
// ---------------------------------------------------------------------------
function printPlan(plan: Plan): void {
  log('---------- PLAN ----------');
  log(`Total rows in JSON:          ${plan.total}`);
  log(`Total matched to DB section: ${plan.matched}`);
  log(`Total unmatched:             ${plan.unmatched.length}`);
  if (plan.unmatched.length > 0) {
    for (const u of plan.unmatched) {
      log(
        `  UNMATCHED  Part ${u.part_number} / Ch ${u.chapter_number} / Sec ${u.section_number}: "${u.section_title}"`,
      );
    }
  }
  log(`Total to update:             ${plan.toUpdate.length}`);
  log(`Total to skip (idempotent):  ${plan.toSkip}`);
  log(`Title mismatches (warning):  ${plan.titleMismatches.length}`);
  if (plan.titleMismatches.length > 0) {
    for (const m of plan.titleMismatches) {
      log(
        `  TITLE-DIFF Part ${m.part_number} / Ch ${m.chapter_number} / Sec ${m.section_number}: ` +
          `JSON="${m.json_title}"  DB="${m.db_title}"`,
      );
    }
  }
  log('--------------------------');
}

// ---------------------------------------------------------------------------
// Per-row commit (atomic at the row level: UPDATE then INSERT immediately,
// halt batch on first failure)
// ---------------------------------------------------------------------------
async function commitPlan(
  supabase: SupabaseClient,
  plan: Plan,
  editorId: string,
): Promise<{ updated: number; revisionsWritten: number }> {
  let updated = 0;
  let revisionsWritten = 0;
  for (const u of plan.toUpdate) {
    const { row, section_id, previous_content, new_content } = u;
    const where = `Part ${row.part_number} / Ch ${row.chapter_number} / Sec ${row.section_number}`;

    const { error: updErr } = await supabase
      .from('sections')
      .update({
        content_markdown: new_content,
        updated_at: new Date().toISOString(),
      })
      .eq('id', section_id);
    if (updErr) {
      err(
        `UPDATE failed at ${where} (section_id ${section_id}): ${updErr.message}. ` +
          `Batch halted. ${updated} sections written before halt. ` +
          'Re-run with --commit to resume from this row.',
      );
    }
    updated += 1;

    const { error: insErr } = await supabase.from('content_revisions').insert({
      section_id,
      edited_by: editorId,
      previous_content,
      new_content,
      edit_note: EDIT_NOTE,
      edited_at: new Date().toISOString(),
    });
    if (insErr) {
      err(
        `content_revisions INSERT failed at ${where} (section_id ${section_id}): ${insErr.message}. ` +
          `Batch halted. The section was UPDATED but no audit row was written for this section. ` +
          `${updated} sections updated, ${revisionsWritten} revisions written before halt. ` +
          'Manual repair: insert the revisions row for this section_id, then re-run --commit to resume.',
      );
    }
    revisionsWritten += 1;
  }
  return { updated, revisionsWritten };
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main(): Promise<void> {
  log(`Mode: ${dryRun ? 'DRY-RUN (no writes)' : 'LIVE COMMIT'}`);
  const manuscript = loadAndValidateManuscript();
  const supabase = createAdminClient();
  const editorId = await resolveEditorId(supabase);
  const sectionLookup = await buildSectionLookup(supabase);
  const plan = buildPlan(manuscript, sectionLookup);

  printPlan(plan);
  enforceHaltConditions(plan);

  if (dryRun) {
    log('Dry-run complete. No writes performed. Re-run with --commit to apply.');
    return;
  }

  log(`Committing ${plan.toUpdate.length} updates (per-row UPDATE + revisions INSERT)...`);
  const { updated, revisionsWritten } = await commitPlan(supabase, plan, editorId);
  log('---------- COMMIT REPORT ----------');
  log(`Sections updated:        ${updated}`);
  log(`content_revisions rows:  ${revisionsWritten}`);
  log(`Idempotent skips:        ${plan.toSkip}`);
  log(`Title-only warnings:     ${plan.titleMismatches.length}`);
  log('-----------------------------------');
  log('Live commit complete.');
}

main().catch((e) => {
  console.error('[FATAL]', e);
  process.exit(1);
});
