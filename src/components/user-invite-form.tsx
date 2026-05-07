'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { useRouter } from 'next/navigation';
import { useEffect } from 'react';
import { inviteUser, type InviteUserState } from '@/app/actions/users';

const ROLES = ['sales_rep', 'instructor', 'admin'] as const;

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {pending ? 'Sending…' : 'Send invite'}
    </button>
  );
}

export function UserInviteForm() {
  const [state, formAction] = useFormState<InviteUserState, FormData>(
    inviteUser,
    { error: null, email: null },
  );
  const router = useRouter();

  // Success: action returns email=null, error=null. Redirect back to list.
  useEffect(() => {
    if (state.email === null && state.error === null) {
      router.push('/admin/users');
    }
  }, [state, router]);

  return (
    <form action={formAction} className="space-y-4">
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

      {state.error ? (
        <p className="text-sm text-red-700">{state.error}</p>
      ) : null}

      <SubmitButton />
    </form>
  );
}
