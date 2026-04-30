// Verifies the Supabase admin client can connect and that the schema
// is reachable. Run with: `npm run verify:supabase`.
//
// Exit codes:
//   0 — connected, query succeeded
//   1 — env vars missing, network failure, or query failed
import { createAdminClient } from '../src/lib/supabase/admin';

async function main() {
  let supabase;
  try {
    supabase = createAdminClient();
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`Configuration error: ${msg}`);
    console.error(
      'Check that .env.local exists at the project root and that ' +
        'NEXT_PUBLIC_SUPABASE_URL and SUPABASE_SERVICE_ROLE_KEY are set.',
    );
    process.exit(1);
  }

  const { count, error } = await supabase
    .from('chapters')
    .select('*', { count: 'exact', head: true });

  if (error) {
    console.error(`Query failed: ${error.message}`);
    if (error.hint) console.error(`Hint: ${error.hint}`);
    if (error.details) console.error(`Details: ${error.details}`);
    process.exit(1);
  }

  if (count === null) {
    console.error('Query returned no count value.');
    process.exit(1);
  }

  console.log(`Connected to Supabase. Found ${count} chapters.`);
  process.exit(0);
}

main().catch((err) => {
  console.error('Unexpected error:', err);
  process.exit(1);
});
