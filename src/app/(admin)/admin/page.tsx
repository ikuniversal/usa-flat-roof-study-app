import { requireRole } from '@/lib/auth/role';
import { LogoutButton } from '@/components/logout-button';

export default async function AdminDashboardPage() {
  const { user, profile } = await requireRole(['admin']);

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-3xl space-y-6">
        <header className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
              Admin Dashboard
            </h1>
            <p className="mt-1 text-sm text-slate-600">
              Signed in as{' '}
              <span className="font-medium text-slate-900">{user.email}</span>{' '}
              <span className="text-slate-500">&middot; role:</span>{' '}
              <span className="font-medium text-slate-900">
                {profile.role}
              </span>
            </p>
          </div>
          <LogoutButton />
        </header>

        <section className="rounded-lg bg-white p-6 shadow-sm ring-1 ring-slate-200">
          <h2 className="text-base font-semibold text-slate-900">
            Coming soon
          </h2>
          <ul className="mt-3 space-y-2 text-sm text-slate-700">
            <li>Content Editor &mdash; coming soon</li>
            <li>User Management &mdash; coming soon</li>
            <li>Reports &mdash; coming soon</li>
          </ul>
        </section>
      </div>
    </div>
  );
}
