import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { startQuizAttempt } from '@/app/actions/quiz';
import type { Chapter, Quiz, QuizAttempt } from '@/types/database';

function formatDate(iso: string): string {
  return new Date(iso).toLocaleString();
}

function hoursUntil(targetIso: string): number {
  const ms = new Date(targetIso).getTime() - Date.now();
  return Math.max(0, Math.ceil(ms / (1000 * 60 * 60)));
}

export default async function QuizOverviewPage({
  params,
}: {
  params: { quizId: string };
}) {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: quiz } = await supabase
    .from('quizzes')
    .select('*')
    .eq('id', params.quizId)
    .single<Quiz>();
  if (!quiz) notFound();

  const { data: chapter } = quiz.chapter_id
    ? await supabase
        .from('chapters')
        .select('id, title, chapter_number')
        .eq('id', quiz.chapter_id)
        .single<Pick<Chapter, 'id' | 'title' | 'chapter_number'>>()
    : { data: null };

  const { count: liveQuestionCount } = await supabase
    .from('quiz_questions')
    .select('id', { head: true, count: 'exact' })
    .eq('quiz_id', quiz.id);

  const { data: attempts } = await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('user_id', user.id)
    .eq('quiz_id', quiz.id)
    .order('attempt_number', { ascending: false })
    .returns<QuizAttempt[]>();

  const lastAttempt = attempts?.[0] ?? null;
  const lastCompleted = (attempts ?? []).find((a) => a.completed_at) ?? null;
  const inProgress = lastAttempt && !lastAttempt.completed_at ? lastAttempt : null;

  // Cooldown check: blocks new attempts for retake_cooldown_hours after
  // last completed attempt. We only enforce on retake (not first try).
  let cooldownEndsAt: string | null = null;
  if (lastCompleted && quiz.retake_cooldown_hours > 0) {
    const ts = new Date(lastCompleted.completed_at!).getTime();
    const ends = new Date(
      ts + quiz.retake_cooldown_hours * 60 * 60 * 1000,
    ).toISOString();
    if (new Date(ends).getTime() > Date.now()) cooldownEndsAt = ends;
  }

  const canStart = !inProgress && !cooldownEndsAt;

  return (
    <div className="space-y-6">
      <div>
        {chapter ? (
          <Link
            href={`/learn/chapters/${chapter.id}`}
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Chapter {chapter.chapter_number}: {chapter.title}
          </Link>
        ) : (
          <Link
            href="/learn"
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Back to table of contents
          </Link>
        )}
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {quiz.title}
        </h1>
        <p className="mt-1 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-slate-500">
          <span>{liveQuestionCount ?? quiz.question_count} questions</span>
          <span>passing score {quiz.passing_score_percent}%</span>
          {quiz.is_final_exam ? (
            <span className="inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
              Final exam
            </span>
          ) : null}
          {quiz.retake_cooldown_hours > 0 ? (
            <span>{quiz.retake_cooldown_hours}h cooldown between attempts</span>
          ) : null}
        </p>
      </div>

      {(liveQuestionCount ?? 0) === 0 ? (
        <div className="rounded-lg border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-900">
          No questions have been imported into this quiz yet. Run the
          remaining content-import migrations to populate it.
        </div>
      ) : null}

      <div className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
        {inProgress ? (
          <div className="space-y-3">
            <p className="text-sm text-slate-700">
              You have an attempt in progress (started{' '}
              {formatDate(inProgress.started_at)}).
            </p>
            <Link
              href={`/learn/quizzes/${quiz.id}/take/${inProgress.id}`}
              className="inline-block rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700"
            >
              Resume attempt
            </Link>
          </div>
        ) : cooldownEndsAt ? (
          <div className="space-y-3">
            <p className="text-sm text-slate-700">
              You can retake in about{' '}
              <span className="font-medium">
                {hoursUntil(cooldownEndsAt)} hour
                {hoursUntil(cooldownEndsAt) === 1 ? '' : 's'}
              </span>
              .
            </p>
          </div>
        ) : (
          <form action={startQuizAttempt.bind(null, quiz.id)}>
            <button
              type="submit"
              disabled={!canStart || (liveQuestionCount ?? 0) === 0}
              className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
            >
              {lastCompleted ? 'Take again' : 'Start quiz'}
            </button>
          </form>
        )}
      </div>

      {attempts && attempts.length > 0 ? (
        <section>
          <h2 className="mb-2 text-sm font-semibold text-slate-900">
            Your attempts
          </h2>
          <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
            <table className="min-w-full divide-y divide-slate-200 text-sm">
              <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-4 py-2 text-left">#</th>
                  <th className="px-4 py-2 text-left">Started</th>
                  <th className="px-4 py-2 text-left">Score</th>
                  <th className="px-4 py-2 text-left">Result</th>
                  <th className="px-4 py-2 text-left"></th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-800">
                {attempts.map((a) => (
                  <tr key={a.id}>
                    <td className="px-4 py-2">{a.attempt_number}</td>
                    <td className="px-4 py-2 text-slate-500">
                      {formatDate(a.started_at)}
                    </td>
                    <td className="px-4 py-2">
                      {a.completed_at && a.score_percent != null
                        ? `${a.score_percent}%`
                        : '—'}
                    </td>
                    <td className="px-4 py-2">
                      {a.completed_at ? (
                        a.passed ? (
                          <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
                            Pass
                          </span>
                        ) : (
                          <span className="inline-flex items-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700">
                            Fail
                          </span>
                        )
                      ) : (
                        <span className="text-xs text-slate-400">In progress</span>
                      )}
                    </td>
                    <td className="px-4 py-2 text-xs">
                      {a.completed_at ? (
                        <Link
                          href={`/learn/quizzes/${quiz.id}/results/${a.id}`}
                          className="text-blue-700 hover:underline"
                        >
                          View
                        </Link>
                      ) : null}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        </section>
      ) : null}
    </div>
  );
}
