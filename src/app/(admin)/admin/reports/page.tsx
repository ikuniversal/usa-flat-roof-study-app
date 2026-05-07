import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';
import type {
  Quiz,
  QuizAttempt,
  Chapter,
  Profile,
} from '@/types/database';

type QuizStats = {
  quiz: Quiz;
  chapterTitle: string | null;
  chapterNumber: number | null;
  attempts: number;
  uniqueUsers: number;
  passes: number;
  averageScore: number | null;
};

export default async function AdminReportsPage() {
  await requireRole(['admin']);
  const supabase = createClient();

  const { data: quizzes } = await supabase
    .from('quizzes')
    .select('*')
    .returns<Quiz[]>();
  const { data: chapters } = await supabase
    .from('chapters')
    .select('id, title, chapter_number')
    .returns<Pick<Chapter, 'id' | 'title' | 'chapter_number'>[]>();
  const { data: attempts } = await supabase
    .from('quiz_attempts')
    .select('*')
    .returns<QuizAttempt[]>();
  const { data: salesReps } = await supabase
    .from('profiles')
    .select('id, certified')
    .eq('role', 'sales_rep')
    .returns<Pick<Profile, 'id' | 'certified'>[]>();

  const chapterById = new Map((chapters ?? []).map((c) => [c.id, c] as const));

  const attemptsByQuiz = new Map<string, QuizAttempt[]>();
  for (const a of attempts ?? []) {
    if (!a.quiz_id) continue;
    const arr = attemptsByQuiz.get(a.quiz_id) ?? [];
    arr.push(a);
    attemptsByQuiz.set(a.quiz_id, arr);
  }

  const stats: QuizStats[] = (quizzes ?? []).map((q) => {
    const qAttempts = attemptsByQuiz.get(q.id) ?? [];
    const completed = qAttempts.filter((a) => a.completed_at);
    const passes = completed.filter((a) => a.passed).length;
    const scoreSum = completed.reduce(
      (acc, a) => acc + (a.score_percent ?? 0),
      0,
    );
    const avg = completed.length > 0 ? scoreSum / completed.length : null;
    const ch = q.chapter_id ? chapterById.get(q.chapter_id) : null;
    return {
      quiz: q,
      chapterTitle: ch?.title ?? null,
      chapterNumber: ch?.chapter_number ?? null,
      attempts: completed.length,
      uniqueUsers: new Set(qAttempts.map((a) => a.user_id).filter(Boolean))
        .size,
      passes,
      averageScore: avg,
    };
  });

  // Sort: final exam first, then chapter quizzes by chapter number.
  stats.sort((a, b) => {
    if (a.quiz.is_final_exam !== b.quiz.is_final_exam) {
      return a.quiz.is_final_exam ? -1 : 1;
    }
    return (a.chapterNumber ?? 0) - (b.chapterNumber ?? 0);
  });

  const totalReps = (salesReps ?? []).length;
  const certifiedReps = (salesReps ?? []).filter((r) => r.certified).length;
  const totalAttempts = (attempts ?? []).filter((a) => a.completed_at).length;
  const totalPasses = (attempts ?? []).filter(
    (a) => a.completed_at && a.passed,
  ).length;
  const overallPassRate =
    totalAttempts > 0 ? Math.round((totalPasses / totalAttempts) * 100) : 0;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Reports
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Quiz pass rates and certification status across all sales reps.
        </p>
      </div>

      <section className="grid gap-3 sm:grid-cols-3">
        <Stat label="Sales reps" value={totalReps.toString()} />
        <Stat
          label="Certified"
          value={`${certifiedReps} / ${totalReps}`}
        />
        <Stat
          label="Overall pass rate"
          value={`${overallPassRate}%`}
          sublabel={`${totalPasses} of ${totalAttempts} completed attempts`}
        />
      </section>

      <section>
        <h2 className="mb-2 text-sm font-semibold text-slate-900">
          Per-quiz stats
        </h2>
        <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Quiz</th>
                <th className="px-4 py-2 text-left">Attempts</th>
                <th className="px-4 py-2 text-left">Unique reps</th>
                <th className="px-4 py-2 text-left">Pass rate</th>
                <th className="px-4 py-2 text-left">Avg score</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100 text-slate-800">
              {stats.map((s) => {
                const passRate =
                  s.attempts > 0
                    ? Math.round((s.passes / s.attempts) * 100)
                    : null;
                return (
                  <tr key={s.quiz.id}>
                    <td className="px-4 py-2">
                      <div className="font-medium">
                        {s.quiz.is_final_exam ? (
                          <span className="mr-2 inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
                            Final
                          </span>
                        ) : null}
                        {s.chapterTitle
                          ? `Ch ${s.chapterNumber}: ${s.chapterTitle}`
                          : s.quiz.title}
                      </div>
                    </td>
                    <td className="px-4 py-2 text-slate-600">{s.attempts}</td>
                    <td className="px-4 py-2 text-slate-600">
                      {s.uniqueUsers}
                    </td>
                    <td className="px-4 py-2">
                      {passRate == null ? (
                        <span className="text-xs text-slate-400">—</span>
                      ) : passRate >= 80 ? (
                        <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
                          {passRate}%
                        </span>
                      ) : passRate >= 50 ? (
                        <span className="inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
                          {passRate}%
                        </span>
                      ) : (
                        <span className="inline-flex items-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700">
                          {passRate}%
                        </span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-slate-600">
                      {s.averageScore != null
                        ? `${Math.round(s.averageScore * 10) / 10}%`
                        : '—'}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>
    </div>
  );
}

function Stat({
  label,
  value,
  sublabel,
}: {
  label: string;
  value: string;
  sublabel?: string;
}) {
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
      <p className="text-xs uppercase tracking-wide text-slate-500">{label}</p>
      <p className="mt-1 text-2xl font-semibold text-slate-900">{value}</p>
      {sublabel ? (
        <p className="mt-0.5 text-xs text-slate-500">{sublabel}</p>
      ) : null}
    </div>
  );
}
