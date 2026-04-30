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

// Fetches the current user and their profile. Redirects to /login if
// the session is missing or no profile row exists.
//
// Used inside protected route-group layouts as the auth gate.
export async function requireUserWithProfile(): Promise<{
  user: { id: string; email?: string };
  profile: Profile;
}> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile, error } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', user.id)
    .single<Profile>();

  if (error || !profile) {
    // No profile row means the user exists in auth.users but the
    // handle_new_user trigger didn't run or failed. Treat as
    // unauthenticated to keep the user out of the app.
    redirect('/login');
  }

  return { user: { id: user.id, email: user.email ?? undefined }, profile };
}

// Enforces that the current user has one of the allowed roles. If
// authenticated but with the wrong role, sends the user to *their*
// dashboard rather than /login (avoids confusing logout behaviour).
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
