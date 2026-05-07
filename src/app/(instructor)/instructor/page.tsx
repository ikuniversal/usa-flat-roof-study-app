import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type { Profile, ReadingProgress, QuizAttempt } from '@/types/database';

type RepSummary = {
  profile: Profile;
  sectionsRead: number;
  attemptsTaken: number;
  attemptsPassed: number;
  latestAttempt: QuizAttempt | null;
};

export default async function InstructorDashboardPage() {
  const { user, profile } = await requireUserWithProfile();
  const supabase = createClient();

  // Admins see all sales reps; instructors see only their assigned reps.
  // RLS already enforces this on the profile read for non-admins.
  let repsQuery = supabase
    .from('profiles')
    .select('*')
    .eq('role', 'sales_rep')
    .order('email', { ascending: true });
  if (profile.role === 'instructor') {
    repsQuery = repsQuery.eq('manager_id', user.id);
  }
  const { data: reps } = await repsQuery.returns<Profile[]>();

  const repIds = (reps ?? []).map((r) => r.id);

  // Pull progress + attempts in two queries (RLS scoped).
  const { data: progress } = await supabase
    .from('reading_progress')
    .select('user_id, completed')
    .in('user_id', repIds.length ? repIds : ['__none__'])
    .eq('completed', true)
    .returns<Pick<ReadingProgress, 'user_id' | 'completed'>[]>();

  const { data: attempts } = await supabase
    .from('quiz_attempts')
    .select('*')
    .in('user_id', repIds.length ? repIds : ['__none__'])
    .order('started_at', { ascending: false })
    .returns<QuizAttempt[]>();

  const sectionCountByRep = new Map<string, number>();
  for (const r of progress ?? []) {
    if (!r.user_id) continue;
    sectionCountByRep.set(
      r.user_id,
      (sectionCountByRep.get(r.user_id) ?? 0) + 1,
    );
  }

  const attemptStatsByRep = new Map<
    string,
    { taken: number; passed: number; latest: QuizAttempt | null }
  >();
  for (const a of attempts ?? []) {
    if (!a.user_id) continue;
    const cur = attemptStatsByRep.get(a.user_id) ?? {
      taken: 0,
      passed: 0,
      latest: null,
    };
    cur.taken += 1;
    if (a.passed) cur.passed += 1;
    if (!cur.latest) cur.latest = a;
    attemptStatsByRep.set(a.user_id, cur);
  }

  const summaries: RepSummary[] = (reps ?? []).map((p) => {
    const stats = attemptStatsByRep.get(p.id);
    return {
      profile: p,
      sectionsRead: sectionCountByRep.get(p.id) ?? 0,
      attemptsTaken: stats?.taken ?? 0,
      attemptsPassed: stats?.passed ?? 0,
      latestAttempt: stats?.latest ?? null,
    };
  });

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          {profile.role === 'admin' ? 'All sales reps' : 'My sales reps'}
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {summaries.length} rep{summaries.length === 1 ? '' : 's'}.
        </p>
      </div>

      {summaries.length === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          {profile.role === 'instructor'
            ? 'You have no sales reps assigned yet. An admin can assign reps to you from the user management page.'
            : 'No sales rep accounts exist yet.'}
        </p>
      ) : (
        <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Rep</th>
                <th className="px-4 py-2 text-left">Sections read</th>
                <th className="px-4 py-2 text-left">Attempts</th>
                <th className="px-4 py-2 text-left">Latest</th>
                <th className="px-4 py-2 text-left">Certified</th>
                <th className="px-4 py-2 text-left"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-800">
              {summaries.map((s) => (
                <tr key={s.profile.id}>
                  <td className="px-4 py-2">
                    <div className="font-medium">{s.profile.email}</div>
                    {s.profile.full_name ? (
                      <div className="text-xs text-slate-500">
                        {s.profile.full_name}
                      </div>
                    ) : null}
                  </td>
                  <td className="px-4 py-2 text-slate-600">{s.sectionsRead}</td>
                  <td className="px-4 py-2 text-slate-600">
                    {s.attemptsPassed}/{s.attemptsTaken} passed
                  </td>
                  <td className="px-4 py-2 text-xs text-slate-500">
                    {s.latestAttempt
                      ? `${
                          s.latestAttempt.completed_at
                            ? `${s.latestAttempt.score_percent ?? '—'}%`
                            : 'in progress'
                        } · ${new Date(
                          s.latestAttempt.started_at,
                        ).toLocaleDateString()}`
                      : '—'}
                  </td>
                  <td className="px-4 py-2">
                    {s.profile.certified ? (
                      <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
                        Yes
                      </span>
                    ) : (
                      <span className="text-xs text-slate-400">No</span>
                    )}
                  </td>
                  <td className="px-4 py-2 text-xs">
                    <Link
                      href={`/instructor/reps/${s.profile.id}`}
                      className="text-blue-700 hover:underline"
                    >
                      View
                    </Link>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
