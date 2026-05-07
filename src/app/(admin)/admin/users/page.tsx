import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';
import type { Profile } from '@/types/database';

const ROLE_BADGE: Record<Profile['role'], string> = {
  admin: 'bg-violet-50 text-violet-800',
  instructor: 'bg-blue-50 text-blue-800',
  sales_rep: 'bg-emerald-50 text-emerald-800',
};

export default async function UsersListPage() {
  await requireRole(['admin']);
  const supabase = createClient();

  const { data: profiles } = await supabase
    .from('profiles')
    .select('*')
    .order('role', { ascending: true })
    .order('email', { ascending: true })
    .returns<Profile[]>();

  // Build manager email map for the "Manager" column.
  const idToEmail = new Map<string, string>();
  for (const p of profiles ?? []) idToEmail.set(p.id, p.email);

  return (
    <div className="space-y-6">
      <div className="flex flex-wrap items-end justify-between gap-3">
        <div>
          <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
            Users
          </h1>
          <p className="mt-1 text-sm text-slate-600">
            {profiles?.length ?? 0} account{profiles?.length === 1 ? '' : 's'}.
          </p>
        </div>
        <Link
          href="/admin/users/new"
          className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
        >
          Invite user
        </Link>
      </div>

      <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-sm">
          <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-2 text-left">Email</th>
              <th className="px-4 py-2 text-left">Name</th>
              <th className="px-4 py-2 text-left">Role</th>
              <th className="px-4 py-2 text-left">Manager</th>
              <th className="px-4 py-2 text-left"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-slate-800">
            {(profiles ?? []).map((p) => (
              <tr key={p.id}>
                <td className="px-4 py-2 font-medium">{p.email}</td>
                <td className="px-4 py-2 text-slate-600">
                  {p.full_name ?? '—'}
                </td>
                <td className="px-4 py-2">
                  <span
                    className={`inline-flex items-center rounded-full px-2 py-0.5 text-xs font-medium ${ROLE_BADGE[p.role]}`}
                  >
                    {p.role}
                  </span>
                </td>
                <td className="px-4 py-2 text-xs text-slate-500">
                  {p.manager_id ? (idToEmail.get(p.manager_id) ?? '—') : '—'}
                </td>
                <td className="px-4 py-2 text-xs">
                  <Link
                    href={`/admin/users/${p.id}`}
                    className="text-blue-700 hover:underline"
                  >
                    Edit
                  </Link>
                </td>
              </tr>
            ))}
          </tbody>
        </table>
      </div>
    </div>
  );
}
