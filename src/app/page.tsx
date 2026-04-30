import { redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { homePathForRole } from '@/lib/auth/role';
import type { Profile } from '@/types/database';

// Root: send the user to wherever they belong.
//   not signed in        → /login
//   signed in, has role  → /admin | /instructor | /learn
//   signed in, no profile → /login (defensive — middleware will catch
//                                    most of this)
export default async function RootPage() {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();

  if (!user) {
    redirect('/login');
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single<Pick<Profile, 'role'>>();

  if (!profile) {
    redirect('/login');
  }

  redirect(homePathForRole(profile.role));
}
