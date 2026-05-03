import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { ProfileSelfForm } from '@/components/profile-self-form';
import type { Profile } from '@/types/database';

export default async function ProfileSelfPage() {
  const { user, profile } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: manager } = profile.manager_id
    ? await supabase
        .from('profiles')
        .select('id, email, full_name')
        .eq('id', profile.manager_id)
        .maybeSingle<Pick<Profile, 'id' | 'email' | 'full_name'>>()
    : { data: null };

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          My profile
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Update your display name. Role and manager assignment are managed by
          an admin.
        </p>
      </div>

      <div className="grid gap-6 sm:grid-cols-[2fr_1fr]">
        <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <ProfileSelfForm initialFullName={profile.full_name} />
        </div>

        <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
          <dl className="space-y-3 text-sm">
            <div>
              <dt className="text-xs uppercase tracking-wide text-slate-500">
                Email
              </dt>
              <dd className="mt-0.5 text-slate-900">{user.email}</dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-wide text-slate-500">
                Role
              </dt>
              <dd className="mt-0.5 text-slate-900">{profile.role}</dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-wide text-slate-500">
                Manager
              </dt>
              <dd className="mt-0.5 text-slate-900">
                {manager
                  ? `${manager.full_name ?? manager.email}`
                  : profile.role === 'sales_rep'
                    ? 'Not assigned'
                    : '—'}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-wide text-slate-500">
                Certified
              </dt>
              <dd className="mt-0.5">
                {profile.certified ? (
                  <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
                    Yes
                    {profile.certification_date
                      ? ` · ${new Date(profile.certification_date).toLocaleDateString()}`
                      : ''}
                  </span>
                ) : (
                  <span className="text-xs text-slate-400">No</span>
                )}
              </dd>
            </div>
            <div>
              <dt className="text-xs uppercase tracking-wide text-slate-500">
                Joined
              </dt>
              <dd className="mt-0.5 text-slate-900">
                {new Date(profile.created_at).toLocaleDateString()}
              </dd>
            </div>
          </dl>
        </div>
      </div>

      <p className="text-xs text-slate-500">
        Need to change your password?{' '}
        <Link href="/forgot-password" className="text-blue-700 hover:underline">
          Request a reset link
        </Link>
        .
      </p>
    </div>
  );
}
