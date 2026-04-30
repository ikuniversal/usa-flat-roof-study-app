import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import type { Profile, UserRole } from '@/types/database';

// Where each role lands after authenticating.
export function homePathForRole(role: UserRole): string {
  switch (role) {
    case 'admin':
      return '/admin';
    case 'instructor':
      return '/instructor';
    case 'sales_rep':
      return '/learn';
  }
}

// Fetches the current user and their profile.
//
// IMPORTANT: middleware is the single source of truth for whether a
// request is authenticated. By the time this helper runs in a
// protected route-group layout, middleware has already verified
// `getUser()` returned a user and forwarded the request. If our
// server-component `getUser()` here returns null anyway, that is a
// cookie-propagation inconsistency, NOT a logged-out user. In that
// case we THROW (caught by the route-group error.tsx) rather than
// redirecting to /login — a redirect here would race with middleware
// on the next request and produce ERR_TOO_MANY_REDIRECTS.
export async function requireUserWithProfile(): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
}> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    throw new Error(
      'requireUserWithProfile: middleware approved this request but ' +
        'server-component getUser() returned null. Cookie propagation ' +
        'between middleware and the RSC has failed. (Check the network ' +
        'tab for missing sb-* cookies or rotated tokens that did not ' +
        'reach the browser.)',
    );
  }

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single<Profile>();

  if (error || !profile) {
    throw new Error(
      `requireUserWithProfile: no profile row for auth user ${user.id} ` +
        `(${user.email ?? 'no email'}). Either the handle_new_user trigger ` +
        `did not run on signup, or RLS is blocking the read. Underlying ` +
        `error: ${error?.message ?? 'no error returned'}`,
    );
  }

  return { user: { id: user.id, email: user.email ?? undefined }, profile };
}

// Enforces that the current user has one of the allowed roles. If
// authenticated but with the wrong role, sends the user to *their*
// dashboard. (Mismatch redirect is fine — it goes to a different
// protected route, which middleware will allow without bouncing.)
export async function requireRole(allowed: UserRole[]): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
}> {
  const session = await requireUserWithProfile();
  if (!allowed.includes(session.profile.role)) {
    redirect(homePathForRole(session.profile.role));
  }
  return session;
}
