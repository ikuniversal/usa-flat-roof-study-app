import Link from 'next/link';
import { requireRole } from '@/lib/auth/role';
import { UserInviteForm } from '@/components/user-invite-form';

export default async function NewUserPage() {
  await requireRole(['admin']);

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
          Invite user
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          A magic-link email is sent. The user sets their password on first
          sign-in.
        </p>
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
        <UserInviteForm />
      </div>
    </div>
  );
}
