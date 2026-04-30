// Truncates the content tables so the import script can run on a
// clean slate. Deletes in dependency order so foreign keys don't
// block. User-progress tables (quiz_responses, quiz_attempts,
// reading_progress, bookmarks, content_revisions) are deleted first
// — running this in production would wipe rep progress, hence the
// required --confirm flag.
//
// Usage:
//   npm run import:clear -- --confirm
//
// Without --confirm the script prints what it WOULD delete and exits.

import { createAdminClient } from '../src/lib/supabase/admin';

const CONFIRM = process.argv.includes('--confirm');

// Order respects foreign keys: leaf tables first, root tables last.
const TABLES_IN_DELETE_ORDER = [
  'quiz_responses',
  'quiz_attempts',
  'reading_progress',
  'bookmarks',
  'content_revisions',
  'quiz_answers',
  'quiz_questions',
  'quiz_sections',
  'quizzes',
  'sections',
  'chapters',
  'book_parts',
  'comparison_tables',
  'glossary_terms',
  'checklist_sections',
  'checklists',
] as const;

// Sentinel UUID used to satisfy Supabase's "delete must include a
// WHERE clause" rule. No real row will ever have this id.
const DELETE_ALL_SENTINEL = '00000000-0000-0000-0000-000000000000';

async function main() {
  if (!CONFIRM) {
    console.log('DRY RUN — no rows will be deleted.');
    console.log('To actually clear, re-run with --confirm:');
    console.log('  npm run import:clear -- --confirm\n');
    console.log('Tables that will be cleared (in order):');
    for (const t of TABLES_IN_DELETE_ORDER) {
      console.log(`  - ${t}`);
    }
    return;
  }

  console.log(
    'WARNING: about to DELETE ALL rows from content tables.\n' +
      'This wipes user progress (attempts, bookmarks, reading_progress).\n',
  );

  let supabase;
  try {
    supabase = createAdminClient();
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`Configuration error: ${msg}`);
    process.exit(1);
  }

  let totalDeleted = 0;
  for (const table of TABLES_IN_DELETE_ORDER) {
    process.stdout.write(`  ${table}... `);
    const { error, count } = await supabase
      .from(table)
      .delete({ count: 'exact' })
      .neq('id', DELETE_ALL_SENTINEL);

    if (error) {
      console.error(`FAILED: ${error.message}`);
      process.exit(1);
    }
    const n = count ?? 0;
    totalDeleted += n;
    console.log(`deleted ${n} rows`);
  }

  console.log(`\nDone. Cleared ${totalDeleted} rows across ${TABLES_IN_DELETE_ORDER.length} tables.`);
}

main().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});
