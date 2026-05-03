import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireRole, requireUserWithProfile } from '@/lib/auth/role';
import { UserEditForm } from '@/components/user-edit-form';
import { UserDeleteButton } from '@/components/user-delete-button';
import type { Profile } from '@/types/database';

export default async function UserEditPage({
  params,
}: {
  params: { id: string };
}) {
  await requireRole(['admin']);
  const { user: currentUser } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: profile } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', params.id)
    .single<Profile>();

  if (!profile) notFound();

  const { data: instructors } = await supabase
    .from('profiles')
    .select('*')
    .in('role', ['admin', 'instructor'])
    .neq('id', profile.id)
    .order('email', { ascending: true })
    .returns<Profile[]>();

  const isSelf = profile.id === currentUser.id;

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/admin/users"
          className="text-xs text-slate-500 hover:text-slate-900"
        >
          &larr; All users
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {profile.email}
        </h1>
        <p className="mt-1 text-xs text-slate-500">
          Joined {new Date(profile.created_at).toLocaleDateString()}
          {profile.certified ? (
            <span className="ml-3 inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
              Certified
            </span>
          ) : null}
        </p>
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
        <UserEditForm profile={profile} instructors={instructors ?? []} />
      </div>

      <div className="rounded-lg border border-red-200 bg-red-50 p-5">
        <h2 className="text-sm font-semibold text-red-900">Danger zone</h2>
        <p className="mt-1 text-xs text-red-800">
          {isSelf
            ? 'You cannot delete your own account from here.'
            : 'Removes the auth account and (via cascade) all reading progress, attempts, and bookmarks.'}
        </p>
        <div className="mt-3">
          <UserDeleteButton
            profileId={profile.id}
            email={profile.email}
            disabled={isSelf}
          />
        </div>
      </div>
    </div>
  );
}
