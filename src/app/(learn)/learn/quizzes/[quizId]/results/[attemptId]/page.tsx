import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type {
  Quiz,
  QuizAttempt,
  QuizQuestion,
  QuizAnswer,
  QuizResponse,
  Profile,
  Chapter,
} from '@/types/database';

function formatDuration(seconds: number | null): string {
  if (seconds == null) return '—';
  if (seconds < 60) return `${seconds}s`;
  const m = Math.floor(seconds / 60);
  const s = seconds % 60;
  return s === 0 ? `${m}m` : `${m}m ${s}s`;
}

export default async function QuizResultsPage({
  params,
}: {
  params: { quizId: string; attemptId: string };
}) {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: attempt } = await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('id', params.attemptId)
    .single<QuizAttempt>();
  if (!attempt || attempt.user_id !== user.id || attempt.quiz_id !== params.quizId) {
    notFound();
  }

  const { data: quiz } = await supabase
    .from('quizzes')
    .select('*')
    .eq('id', params.quizId)
    .single<Quiz>();
  if (!quiz) notFound();

  const { data: questions } = await supabase
    .from('quiz_questions')
    .select('*')
    .eq('quiz_id', quiz.id)
    .order('display_order', { ascending: true })
    .returns<QuizQuestion[]>();
  const questionIds = (questions ?? []).map((q) => q.id);

  const { data: answers } = await supabase
    .from('quiz_answers')
    .select('*')
    .in('question_id', questionIds.length ? questionIds : ['__none__'])
    .order('display_order', { ascending: true })
    .returns<QuizAnswer[]>();

  const { data: responses } = await supabase
    .from('quiz_responses')
    .select('*')
    .eq('attempt_id', attempt.id)
    .returns<QuizResponse[]>();

  // Source chapter for the "Review chapter" deep link on wrong answers.
  // Final exam questions live under the synthesized exam chapter, so
  // this link is hidden for the exam (no real source chapter to send
  // the user to).
  const { data: chapter } = quiz.chapter_id
    ? await supabase
        .from('chapters')
        .select('id, title, chapter_number')
        .eq('id', quiz.chapter_id)
        .maybeSingle<Pick<Chapter, 'id' | 'title' | 'chapter_number'>>()
    : { data: null };
  const showReviewLink = chapter && !quiz.is_final_exam;

  const answersByQ = new Map<string, QuizAnswer[]>();
  for (const a of answers ?? []) {
    if (!a.question_id) continue;
    const arr = answersByQ.get(a.question_id) ?? [];
    arr.push(a);
    answersByQ.set(a.question_id, arr);
  }
  const responseByQ = new Map<string, QuizResponse>();
  for (const r of responses ?? []) {
    if (r.question_id) responseByQ.set(r.question_id, r);
  }

  const passed = attempt.passed === true;
  const showReview = quiz.allow_section_review && attempt.completed_at != null;

  // Show the celebratory cert banner only when this attempt was the
  // one that flipped the user to certified (cert date matches the
  // attempt's completed_at within a couple of seconds).
  let justCertified = false;
  if (passed && quiz.is_final_exam) {
    const { data: profile } = await supabase
      .from('profiles')
      .select('certified, certification_date')
      .eq('id', user.id)
      .single<Pick<Profile, 'certified' | 'certification_date'>>();
    if (
      profile?.certified &&
      profile.certification_date &&
      attempt.completed_at
    ) {
      const certTs = new Date(profile.certification_date).getTime();
      const submitTs = new Date(attempt.completed_at).getTime();
      justCertified = Math.abs(certTs - submitTs) < 5000;
    }
  }

  return (
    <div className="space-y-6">
      <div>
        <Link
          href={`/learn/quizzes/${quiz.id}`}
          className="text-xs text-slate-500 hover:text-slate-900"
        >
          &larr; Quiz overview
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {quiz.title} &mdash; results
        </h1>
        <p className="mt-1 text-xs text-slate-500">
          Attempt {attempt.attempt_number} &middot; submitted{' '}
          {attempt.completed_at
            ? new Date(attempt.completed_at).toLocaleString()
            : '(not submitted)'}
        </p>
      </div>

      {justCertified ? (
        <div className="rounded-lg border border-emerald-300 bg-gradient-to-br from-emerald-50 to-amber-50 p-5 shadow-sm">
          <p className="text-xs font-semibold uppercase tracking-wide text-emerald-700">
            🎉 Certified
          </p>
          <p className="mt-1 text-base font-semibold text-emerald-900">
            You passed the final exam &mdash; you&rsquo;re now a certified USA
            Flat Roof sales rep.
          </p>
          <p className="mt-1 text-xs text-emerald-800">
            Your manager and admins can see this on the instructor dashboard.
          </p>
        </div>
      ) : null}

      <div
        className={`rounded-lg border p-5 shadow-sm ${
          passed
            ? 'border-emerald-200 bg-emerald-50'
            : 'border-red-200 bg-red-50'
        }`}
      >
        <div className="flex flex-wrap items-baseline gap-x-6 gap-y-2">
          <p
            className={`text-3xl font-semibold ${
              passed ? 'text-emerald-700' : 'text-red-700'
            }`}
          >
            {attempt.score_percent != null ? `${attempt.score_percent}%` : '—'}
          </p>
          <p
            className={`text-sm font-medium ${
              passed ? 'text-emerald-800' : 'text-red-800'
            }`}
          >
            {passed ? 'Passed' : 'Did not pass'}{' '}
            <span className="text-slate-500">
              (need {quiz.passing_score_percent}%)
            </span>
          </p>
          <p className="text-xs text-slate-500">
            Time: {formatDuration(attempt.time_spent_seconds)}
          </p>
        </div>
      </div>

      {showReview ? (
        <section className="space-y-3">
          <h2 className="text-sm font-semibold text-slate-900">Review</h2>
          {(questions ?? []).map((q, idx) => {
            const qAnswers = answersByQ.get(q.id) ?? [];
            const userResp = responseByQ.get(q.id);
            const correctAnswer = qAnswers.find((a) => a.is_correct);
            const isCorrect = userResp?.is_correct === true;
            return (
              <div
                key={q.id}
                className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm"
              >
                <p className="text-xs font-medium uppercase tracking-wide text-slate-500">
                  Question {q.question_number ?? idx + 1}{' '}
                  {isCorrect ? (
                    <span className="ml-2 text-emerald-600">✓ Correct</span>
                  ) : (
                    <span className="ml-2 text-red-600">✗ Incorrect</span>
                  )}
                </p>
                <p className="mt-2 text-base text-slate-900">
                  {q.question_text}
                </p>
                <div className="mt-3 space-y-1.5 text-sm">
                  {qAnswers.map((a) => {
                    const isUser = a.id === userResp?.selected_answer_id;
                    const isCorr = a.is_correct;
                    let cls =
                      'rounded-md border px-3 py-2 border-slate-200 text-slate-700';
                    if (isCorr) {
                      cls =
                        'rounded-md border px-3 py-2 border-emerald-300 bg-emerald-50 text-emerald-900';
                    } else if (isUser) {
                      cls =
                        'rounded-md border px-3 py-2 border-red-300 bg-red-50 text-red-900';
                    }
                    return (
                      <div key={a.id} className={cls}>
                        <span className="mr-2 font-semibold">
                          {a.answer_letter}.
                        </span>
                        {a.answer_text}
                        {isUser ? (
                          <span className="ml-2 text-xs italic text-slate-500">
                            (your answer)
                          </span>
                        ) : null}
                      </div>
                    );
                  })}
                </div>
                {!isCorrect && correctAnswer?.explanation ? (
                  <p className="mt-3 rounded-md bg-slate-50 px-3 py-2 text-xs text-slate-700">
                    <span className="font-semibold">Why:</span>{' '}
                    {correctAnswer.explanation}
                  </p>
                ) : null}
                {!isCorrect && showReviewLink && chapter ? (
                  <p className="mt-2 text-xs">
                    <Link
                      href={`/learn/chapters/${chapter.id}`}
                      className="text-blue-700 hover:underline"
                    >
                      Review Chapter {chapter.chapter_number}: {chapter.title} →
                    </Link>
                  </p>
                ) : null}
              </div>
            );
          })}
        </section>
      ) : (
        <p className="text-sm italic text-slate-500">
          Per-question review is not available for this quiz.
        </p>
      )}

      <div className="flex gap-3">
        <Link
          href={`/learn/quizzes/${quiz.id}`}
          className="rounded-md border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50"
        >
          Back to quiz
        </Link>
      </div>
    </div>
  );
}
