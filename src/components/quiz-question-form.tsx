'use client';

import { useState, useTransition } from 'react';
import { saveResponse } from '@/app/actions/quiz';
import type { QuizAnswer, QuizQuestion } from '@/types/database';

export type QuestionWithAnswers = QuizQuestion & {
  answers: QuizAnswer[];
};

export function QuizQuestionForm({
  attemptId,
  question,
  initialSelectedAnswerId,
  questionNumberLabel,
}: {
  attemptId: string;
  question: QuestionWithAnswers;
  initialSelectedAnswerId: string | null;
  questionNumberLabel: string;
}) {
  const [selected, setSelected] = useState<string | null>(
    initialSelectedAnswerId,
  );
  const [pending, startTransition] = useTransition();
  const [error, setError] = useState<string | null>(null);

  function onSelect(answerId: string) {
    setSelected(answerId);
    setError(null);
    startTransition(async () => {
      const res = await saveResponse(attemptId, question.id, answerId);
      if (res.error) setError(res.error);
    });
  }

  return (
    <fieldset className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm">
      <legend className="px-2 text-xs font-medium uppercase tracking-wide text-slate-500">
        {questionNumberLabel}
        {question.difficulty ? (
          <span className="ml-2 text-slate-400">
            &middot; {question.difficulty}
          </span>
        ) : null}
      </legend>
      <p className="text-base text-slate-900">{question.question_text}</p>
      <div className="mt-4 space-y-2">
        {question.answers.map((a) => {
          const isSelected = selected === a.id;
          return (
            <label
              key={a.id}
              className={`flex cursor-pointer items-start gap-3 rounded-md border px-4 py-3 text-sm ${
                isSelected
                  ? 'border-blue-500 bg-blue-50'
                  : 'border-slate-200 hover:bg-slate-50'
              }`}
            >
              <input
                type="radio"
                name={`q-${question.id}`}
                value={a.id}
                checked={isSelected}
                onChange={() => onSelect(a.id)}
                disabled={pending}
                className="mt-0.5"
              />
              <span className="text-slate-800">
                <span className="mr-2 font-semibold text-slate-600">
                  {a.answer_letter}.
                </span>
                {a.answer_text}
              </span>
            </label>
          );
        })}
      </div>
      {error ? (
        <p className="mt-2 text-xs text-red-600">{error}</p>
      ) : null}
    </fieldset>
  );
}
