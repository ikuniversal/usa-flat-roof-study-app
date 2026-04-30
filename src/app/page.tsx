import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { homePathForRole } from '@/lib/auth/role';
import type { Profile } from '@/types/database';

// Root page. Middleware is the SINGLE source of truth for the
// authenticated/unauthenticated decision; this page does NOT
// redirect to /login on its own. Middleware adds `/` to its
// protected prefixes, so any user reaching this point has already
// been confirmed authenticated by middleware.
//
// Sole job: route the user to their role-specific home. The profile
// lookup needs DB access, which is why this can't live in middleware.
// If the profile lookup fails for any reason, default to /learn —
// never redirect back to /login here, that's the loop trigger.
export default async function RootPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  // Profile lookup is best-effort. If user is somehow null (cookie
  // read race between middleware and server component), fall through
  // to /learn rather than fighting middleware on /login.
  const userId = user?.id;
  let role: Profile['role'] | null = null;
  if (userId) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('role')
      .eq('id', userId)
      .single<Pick<Profile, 'role'>>();
    role = profile?.role ?? null;
  }

  redirect(role ? homePathForRole(role) : '/learn');
}
