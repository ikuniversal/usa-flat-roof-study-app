import { requireRole } from '@/lib/auth/role';
import { LogoutButton } from '@/components/logout-button';

export default async function InstructorDashboardPage() {
  const { user, profile } = await requireRole(['instructor', 'admin']);

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-3xl space-y-6">
        <header className="flex items-start justify-between gap-4">
          <div>
            <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
              Instructor Dashboard
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
            Your trainees
          </h2>
          <p className="mt-3 text-sm text-slate-600">
            Trainee list and progress will appear here.
          </p>
        </section>
      </div>
    </div>
  );
}
