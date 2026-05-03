import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';

export default async function AdminDashboardPage() {
  const { profile } = await requireUserWithProfile();
  const supabase = createClient();

  const { count: userCount } = await supabase
    .from('profiles')
    .select('id', { head: true, count: 'exact' });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Admin dashboard
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Welcome back, {profile.full_name ?? profile.email}.
        </p>
      </div>

      <section className="grid gap-4 sm:grid-cols-2">
        <Link
          href="/admin/users"
          className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm hover:shadow-md"
        >
          <h2 className="text-base font-semibold text-slate-900">Users</h2>
          <p className="mt-1 text-sm text-slate-600">
            {userCount ?? '—'} account{userCount === 1 ? '' : 's'} &middot; invite, assign roles,
            link sales reps to instructors
          </p>
        </Link>
        <div className="rounded-lg border border-dashed border-slate-300 bg-white p-5 text-sm text-slate-500">
          <h2 className="text-base font-semibold text-slate-700">Content editor</h2>
          <p className="mt-1">Coming soon.</p>
        </div>
      </section>
    </div>
  );
}
