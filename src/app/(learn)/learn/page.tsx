import { requireRole } from '@/lib/auth/role';
import { LogoutButton } from '@/components/logout-button';

export default async function LearnDashboardPage() {
  const { user, profile } = await requireRole([
    'admin',
    'instructor',
    'sales_rep',
  ]);

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-3xl space-y-6">
        <header className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
              Roof Systems Field Guide
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

        <section className="grid gap-4 sm:grid-cols-3">
          <div className="rounded-lg bg-white p-5 shadow-sm ring-1 ring-slate-200">
            <h2 className="text-sm font-semibold text-slate-900">
              Continue reading
            </h2>
            <p className="mt-2 text-sm text-slate-600">
              Pick up where you left off.
            </p>
          </div>
          <div className="rounded-lg bg-white p-5 shadow-sm ring-1 ring-slate-200">
            <h2 className="text-sm font-semibold text-slate-900">
              Take a quiz
            </h2>
            <p className="mt-2 text-sm text-slate-600">
              Sharpen what you&rsquo;ve learned.
            </p>
          </div>
          <div className="rounded-lg bg-white p-5 shadow-sm ring-1 ring-slate-200">
            <h2 className="text-sm font-semibold text-slate-900">
              Final exam
            </h2>
            <p className="mt-2 text-sm text-slate-600">
              When you&rsquo;re ready to certify.
            </p>
          </div>
        </section>
      </div>
    </div>
  );
}
