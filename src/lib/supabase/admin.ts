import { createClient } from '@supabase/supabase-js';

// Server-only admin client. Uses the service role key which BYPASSES
// row-level security, so this must never be imported into any code
// that ships to the browser. Intended for the content import script
// and other privileged server-side jobs.
export function createAdminClient() {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;

  if (!url) {
    throw new Error(
      'NEXT_PUBLIC_SUPABASE_URL is not set. Add it to .env.local.',
    );
  }
  if (!serviceKey) {
    throw new Error(
      'SUPABASE_SERVICE_ROLE_KEY is not set. Add it to .env.local.',
    );
  }

  return createClient(url, serviceKey, {
    auth: {
      persistSession: false,
      autoRefreshToken: false,
    },
  });
}
