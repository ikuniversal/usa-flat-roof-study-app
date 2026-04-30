'use client';

import { useFormState, useFormStatus } from 'react-dom';
import {
  resetPassword,
  type ResetPasswordState,
} from '@/app/actions/auth';

const initialState: ResetPasswordState = { error: null };

export function ResetPasswordForm() {
  const [state, formAction] = useFormState(resetPassword, initialState);

  return (
    <form action={formAction} className="space-y-3">
      {state.error && (
        <div
          role="alert"
          className="rounded-md bg-red-50 px-3 py-2 text-sm text-red-700 ring-1 ring-red-200"
        >
          {state.error}
        </div>
      )}

      <div className="space-y-1">
        <label
          htmlFor="password"
          className="block text-sm font-medium text-slate-700"
        >
          New password
        </label>
        <input
          id="password"
          name="password"
          type="password"
          autoComplete="new-password"
          required
          minLength={8}
          className="block w-full rounded-md bg-white px-3 py-2 text-sm text-slate-900 ring-1 ring-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-900"
        />
      </div>

      <div className="space-y-1">
        <label
          htmlFor="confirm"
          className="block text-sm font-medium text-slate-700"
        >
          Confirm new password
        </label>
        <input
          id="confirm"
          name="confirm"
          type="password"
          autoComplete="new-password"
          required
          minLength={8}
          className="block w-full rounded-md bg-white px-3 py-2 text-sm text-slate-900 ring-1 ring-slate-200 focus:outline-none focus:ring-2 focus:ring-slate-900"
        />
      </div>

      <SubmitButton />
    </form>
  );
}

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="w-full rounded-md bg-slate-900 px-3 py-2 text-sm font-medium text-white hover:bg-slate-800 disabled:opacity-60"
    >
      {pending ? 'Updating…' : 'Update password'}
    </button>
  );
}
