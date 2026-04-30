'use client';

import { useFormState, useFormStatus } from 'react-dom';
import {
  requestPasswordReset,
  type ForgotPasswordState,
} from '@/app/actions/auth';

const initialState: ForgotPasswordState = { error: null, sent: false };

export function ForgotPasswordForm() {
  const [state, formAction] = useFormState(requestPasswordReset, initialState);

  if (state.sent) {
    return (
      <div className="rounded-md bg-green-50 px-3 py-2 text-sm text-green-700 ring-1 ring-green-200">
        If an account exists for that email, a reset link has been sent.
        Check your inbox.
      </div>
    );
  }

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
          htmlFor="email"
          className="block text-sm font-medium text-slate-700"
        >
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          autoComplete="email"
          required
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
      {pending ? 'Sending…' : 'Send reset link'}
    </button>
  );
}
