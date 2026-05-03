import Link from 'next/link';
import { notFound, redirect } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { QuizQuestionForm } from '@/components/quiz-question-form';
import type { QuestionWithAnswers } from '@/components/quiz-question-form';
import { QuizSubmitButton } from '@/components/quiz-submit-button';
import type {
  Quiz,
  QuizAttempt,
  QuizQuestion,
  QuizAnswer,
  QuizSection,
} from '@/types/database';

export default async function QuizTakePage({
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
  if (attempt.completed_at) {
    redirect(`/learn/quizzes/${params.quizId}/results/${params.attemptId}`);
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

  const { data: quizSections } = quiz.is_final_exam
    ? await supabase
        .from('quiz_sections')
        .select('*')
        .eq('quiz_id', quiz.id)
        .order('display_order', { ascending: true })
        .returns<QuizSection[]>()
    : { data: [] };

  const { data: priorResponses } = await supabase
    .from('quiz_responses')
    .select('question_id, selected_answer_id')
    .eq('attempt_id', attempt.id)
    .returns<{ question_id: string | null; selected_answer_id: string | null }[]>();
  const responseByQuestion = new Map<string, string>();
  for (const r of priorResponses ?? []) {
    if (r.question_id && r.selected_answer_id) {
      responseByQuestion.set(r.question_id, r.selected_answer_id);
    }
  }

  const answersByQuestion = new Map<string, QuizAnswer[]>();
  for (const a of answers ?? []) {
    if (!a.question_id) continue;
    const arr = answersByQuestion.get(a.question_id) ?? [];
    arr.push(a);
    answersByQuestion.set(a.question_id, arr);
  }

  const enriched: QuestionWithAnswers[] = (questions ?? []).map((q) => ({
    ...q,
    answers: answersByQuestion.get(q.id) ?? [],
  }));

  const total = enriched.length;
  const answered = enriched.filter((q) =>
    responseByQuestion.has(q.id),
  ).length;

  // Group questions by quiz_section_id for the final exam.
  const grouped: { sectionTitle: string | null; items: QuestionWithAnswers[] }[] = [];
  if (quiz.is_final_exam && quizSections && quizSections.length > 0) {
    for (const s of quizSections) {
      grouped.push({
        sectionTitle: `Section ${s.section_number}: ${s.title}`,
        items: enriched.filter((q) => q.quiz_section_id === s.id),
      });
    }
    const orphaned = enriched.filter((q) => !q.quiz_section_id);
    if (orphaned.length > 0) {
      grouped.push({ sectionTitle: 'Other', items: orphaned });
    }
  } else {
    grouped.push({ sectionTitle: null, items: enriched });
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
          {quiz.title}
        </h1>
        <p className="mt-1 text-xs text-slate-500">
          Attempt {attempt.attempt_number} &middot; {answered} of {total} answered
        </p>
      </div>

      {total === 0 ? (
        <div className="rounded-lg border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-900">
          This quiz has no questions yet. Apply the remaining content-import
          chunks to populate it.
        </div>
      ) : (
        <>
          {grouped.map((group, gi) => (
            <section key={gi} className="space-y-4">
              {group.sectionTitle ? (
                <h2 className="text-sm font-semibold text-slate-900">
                  {group.sectionTitle}
                </h2>
              ) : null}
              {group.items.map((q, idx) => (
                <QuizQuestionForm
                  key={q.id}
                  attemptId={attempt.id}
                  question={q}
                  initialSelectedAnswerId={
                    responseByQuestion.get(q.id) ?? null
                  }
                  questionNumberLabel={`Question ${q.question_number ?? idx + 1}`}
                />
              ))}
            </section>
          ))}

          <div className="sticky bottom-4 mt-6 flex items-center justify-between rounded-lg border border-slate-200 bg-white px-4 py-3 shadow-sm">
            <p className="text-sm text-slate-600">
              {answered} of {total} answered
            </p>
            <QuizSubmitButton
              attemptId={attempt.id}
              total={total}
              answered={answered}
            />
          </div>
        </>
      )}
    </div>
  );
}
