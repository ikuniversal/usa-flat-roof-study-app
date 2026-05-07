'use client';

import { useFormState, useFormStatus } from 'react-dom';
import {
  updateOwnProfile,
  type UpdateProfileSelfState,
} from '@/app/actions/profile';

function SubmitButton({ saved }: { saved: boolean }) {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {pending ? 'Saving…' : saved ? 'Saved ✓' : 'Save'}
    </button>
  );
}

export function ProfileSelfForm({
  initialFullName,
}: {
  initialFullName: string | null;
}) {
  const [state, formAction] = useFormState<UpdateProfileSelfState, FormData>(
    updateOwnProfile,
    { error: null, saved: false },
  );

  return (
    <form action={formAction} className="space-y-4">
      <div>
        <label
          htmlFor="full_name"
          className="block text-sm font-medium text-slate-900"
        >
          Full name
        </label>
        <input
          id="full_name"
          name="full_name"
          type="text"
          defaultValue={initialFullName ?? ''}
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        />
      </div>

      {state.error ? (
        <p className="text-sm text-red-700">{state.error}</p>
      ) : null}

      <SubmitButton saved={state.saved} />
    </form>
  );
}
