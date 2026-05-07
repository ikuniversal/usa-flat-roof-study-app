'use client';

import { useTransition } from 'react';
import { submitAttempt } from '@/app/actions/quiz';

export function QuizSubmitButton({
  attemptId,
  total,
  answered,
}: {
  attemptId: string;
  total: number;
  answered: number;
}) {
  const [pending, startTransition] = useTransition();
  const allAnswered = answered === total;
  const label = pending
    ? 'Submitting…'
    : allAnswered
      ? `Submit ${total} answers`
      : `Submit (${answered} of ${total} answered)`;

  function onClick() {
    if (pending) return;
    if (!allAnswered) {
      const ok = window.confirm(
        `You've answered ${answered} of ${total}. Unanswered questions count as incorrect. Submit anyway?`,
      );
      if (!ok) return;
    }
    startTransition(async () => {
      await submitAttempt(attemptId);
    });
  }

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={pending}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {label}
    </button>
  );
}
