'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { useRouter } from 'next/navigation';
import { useEffect, useState } from 'react';
import {
  inviteUser,
  createUserDirectly,
  type InviteUserState,
} from '@/app/actions/users';

const ROLES = ['sales_rep', 'instructor', 'admin'] as const;
const INITIAL_STATE: InviteUserState = {
  error: null,
  email: null,
  submitted: false,
};

type Method = 'invite' | 'direct';

function SubmitButton({ method }: { method: Method }) {
  const { pending } = useFormStatus();
  const idleLabel = method === 'invite' ? 'Send invite' : 'Create account';
  const busyLabel = method === 'invite' ? 'Sending…' : 'Creating…';
  return (
    <button
      type="submit"
      disabled={pending}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {pending ? busyLabel : idleLabel}
    </button>
  );
}

export function UserInviteForm() {
  const [method, setMethod] = useState<Method>('invite');
  const [showPassword, setShowPassword] = useState(false);
  const [inviteState, inviteAction] = useFormState<InviteUserState, FormData>(
    inviteUser,
    INITIAL_STATE,
  );
  const [directState, directAction] = useFormState<InviteUserState, FormData>(
    createUserDirectly,
    INITIAL_STATE,
  );
  const state = method === 'invite' ? inviteState : directState;
  const action = method === 'invite' ? inviteAction : directAction;
  const router = useRouter();

  // Redirect back to the list only after a successful submit. The
  // discriminator flag distinguishes "not yet submitted" from
  // "submitted and succeeded" — both used to look identical
  // (error=null, email=null) and the redirect fired on mount.
  useEffect(() => {
    if (state.submitted) {
      router.push('/admin/users');
    }
  }, [state, router]);

  return (
    <form action={action} className="space-y-4">
      <fieldset>
        <legend className="block text-sm font-medium text-slate-900">
          Method
        </legend>
        <div className="mt-1 flex gap-1 rounded-md border border-slate-300 bg-white p-1 text-sm">
          <label
            className={`flex-1 cursor-pointer rounded px-3 py-1.5 text-center ${
              method === 'invite'
                ? 'bg-blue-50 font-medium text-blue-700'
                : 'text-slate-700 hover:bg-slate-50'
            }`}
          >
            <input
              type="radio"
              name="method"
              value="invite"
              checked={method === 'invite'}
              onChange={() => setMethod('invite')}
              className="sr-only"
            />
            Send invite email
          </label>
          <label
            className={`flex-1 cursor-pointer rounded px-3 py-1.5 text-center ${
              method === 'direct'
                ? 'bg-blue-50 font-medium text-blue-700'
                : 'text-slate-700 hover:bg-slate-50'
            }`}
          >
            <input
              type="radio"
              name="method"
              value="direct"
              checked={method === 'direct'}
              onChange={() => setMethod('direct')}
              className="sr-only"
            />
            Set password directly
          </label>
        </div>
      </fieldset>

      <div>
        <label
          htmlFor="email"
          className="block text-sm font-medium text-slate-900"
        >
          Email
        </label>
        <input
          id="email"
          name="email"
          type="email"
          required
          autoComplete="off"
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        />
      </div>

      <div>
        <label
          htmlFor="full_name"
          className="block text-sm font-medium text-slate-900"
        >
          Full name (optional)
        </label>
        <input
          id="full_name"
          name="full_name"
          type="text"
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        />
      </div>

      <div>
        <label
          htmlFor="role"
          className="block text-sm font-medium text-slate-900"
        >
          Role
        </label>
        <select
          id="role"
          name="role"
          defaultValue="sales_rep"
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        >
          {ROLES.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
      </div>

      {method === 'direct' ? (
        <div>
          <label
            htmlFor="password"
            className="block text-sm font-medium text-slate-900"
          >
            Temporary password
          </label>
          <div className="relative mt-1">
            <input
              id="password"
              name="password"
              type={showPassword ? 'text' : 'password'}
              required
              minLength={6}
              autoComplete="new-password"
              className="block w-full rounded-md border border-slate-300 bg-white px-3 py-2 pr-16 text-sm text-slate-900"
            />
            <button
              type="button"
              onClick={() => setShowPassword((s) => !s)}
              tabIndex={-1}
              aria-label={showPassword ? 'Hide password' : 'Show password'}
              className="absolute inset-y-0 right-0 flex items-center px-3 text-xs font-medium text-blue-700 hover:underline"
            >
              {showPassword ? 'Hide' : 'Show'}
            </button>
          </div>
          <p className="mt-1 text-xs text-slate-500">
            Share this password securely with the user. They can change it
            later via Forgot Password.
          </p>
        </div>
      ) : null}

      {state.error ? (
        <p className="text-sm text-red-700">{state.error}</p>
      ) : null}

      <SubmitButton method={method} />
    </form>
  );
}
