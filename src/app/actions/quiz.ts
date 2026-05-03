'use server';

import { redirect } from 'next/navigation';
import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';

export type SaveResponseResult = { error: string | null };

// Creates a new quiz_attempts row and redirects to the take page.
// attempt_number is computed as max(existing) + 1 for this user/quiz.
export async function startQuizAttempt(quizId: string): Promise<void> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: prior } = await supabase
    .from('quiz_attempts')
    .select('attempt_number')
    .eq('user_id', user.id)
    .eq('quiz_id', quizId)
    .order('attempt_number', { ascending: false })
    .limit(1)
    .maybeSingle<{ attempt_number: number }>();

  const nextAttemptNumber = (prior?.attempt_number ?? 0) + 1;

  const { data: attempt, error } = await supabase
    .from('quiz_attempts')
    .insert({
      user_id: user.id,
      quiz_id: quizId,
      attempt_number: nextAttemptNumber,
    })
    .select('id')
    .single<{ id: string }>();

  if (error || !attempt) {
    throw new Error(`Could not start attempt: ${error?.message ?? 'unknown error'}`);
  }

  revalidatePath(`/learn/quizzes/${quizId}`);
  redirect(`/learn/quizzes/${quizId}/take/${attempt.id}`);
}

// Upserts the user's selected answer for a single question within an
// attempt. Called as the user clicks each answer.
export async function saveResponse(
  attemptId: string,
  questionId: string,
  selectedAnswerId: string,
): Promise<SaveResponseResult> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: 'Not signed in.' };

  // Confirm the attempt belongs to the user (RLS will already gate, but
  // we want a clean error message instead of a silent failure).
  const { data: attempt } = await supabase
    .from('quiz_attempts')
    .select('id, user_id, completed_at')
    .eq('id', attemptId)
    .single<{ id: string; user_id: string; completed_at: string | null }>();
  if (!attempt || attempt.user_id !== user.id) {
    return { error: 'Attempt not found.' };
  }
  if (attempt.completed_at) {
    return { error: 'This attempt has already been submitted.' };
  }

  const { data: answer } = await supabase
    .from('quiz_answers')
    .select('id, is_correct, question_id')
    .eq('id', selectedAnswerId)
    .single<{ id: string; is_correct: boolean; question_id: string }>();
  if (!answer || answer.question_id !== questionId) {
    return { error: 'Invalid answer.' };
  }

  // Delete any prior response for this (attempt, question) pair, then insert.
  await supabase
    .from('quiz_responses')
    .delete()
    .eq('attempt_id', attemptId)
    .eq('question_id', questionId);

  const { error } = await supabase.from('quiz_responses').insert({
    attempt_id: attemptId,
    question_id: questionId,
    selected_answer_id: selectedAnswerId,
    is_correct: answer.is_correct,
  });
  if (error) return { error: error.message };

  return { error: null };
}

// Marks an attempt complete. Computes score_percent from quiz_responses,
// sets passed against quiz.passing_score_percent, then redirects to
// results.
export async function submitAttempt(
  attemptId: string,
): Promise<void> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) redirect('/login');

  const { data: attempt } = await supabase
    .from('quiz_attempts')
    .select('id, quiz_id, user_id, started_at, completed_at')
    .eq('id', attemptId)
    .single<{
      id: string;
      quiz_id: string;
      user_id: string;
      started_at: string;
      completed_at: string | null;
    }>();
  if (!attempt || attempt.user_id !== user.id) {
    throw new Error('Attempt not found.');
  }
  if (attempt.completed_at) {
    redirect(`/learn/quizzes/${attempt.quiz_id}/results/${attemptId}`);
  }

  const { data: quiz } = await supabase
    .from('quizzes')
    .select('id, passing_score_percent, question_count')
    .eq('id', attempt.quiz_id)
    .single<{
      id: string;
      passing_score_percent: number;
      question_count: number;
    }>();
  if (!quiz) throw new Error('Quiz not found.');

  // Total questions actually in the quiz (may differ from
  // quiz.question_count if data is incomplete -- use the live count
  // for the score denominator).
  const { count: totalQ } = await supabase
    .from('quiz_questions')
    .select('id', { head: true, count: 'exact' })
    .eq('quiz_id', quiz.id);

  const { data: responses } = await supabase
    .from('quiz_responses')
    .select('is_correct')
    .eq('attempt_id', attemptId)
    .returns<{ is_correct: boolean | null }[]>();

  const correct = (responses ?? []).filter((r) => r.is_correct === true).length;
  const denom = totalQ ?? quiz.question_count ?? (responses?.length ?? 0);
  const scorePercent =
    denom > 0 ? Math.round((correct / denom) * 1000) / 10 : 0;
  const passed = scorePercent >= quiz.passing_score_percent;

  const startedAt = new Date(attempt.started_at).getTime();
  const completedAt = Date.now();
  const timeSpentSeconds = Math.max(
    0,
    Math.round((completedAt - startedAt) / 1000),
  );

  const { error } = await supabase
    .from('quiz_attempts')
    .update({
      completed_at: new Date(completedAt).toISOString(),
      score_percent: scorePercent,
      passed,
      time_spent_seconds: timeSpentSeconds,
    })
    .eq('id', attemptId);
  if (error) throw new Error(`Could not submit attempt: ${error.message}`);

  revalidatePath(`/learn/quizzes/${quiz.id}`);
  redirect(`/learn/quizzes/${quiz.id}/results/${attemptId}`);
}
