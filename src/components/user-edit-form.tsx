'use client';

import { useFormState, useFormStatus } from 'react-dom';
import { updateProfile, type UpdateProfileState } from '@/app/actions/users';
import type { Profile, UserRole } from '@/types/database';

const ROLES: UserRole[] = ['admin', 'instructor', 'sales_rep'];

function SubmitButton() {
  const { pending } = useFormStatus();
  return (
    <button
      type="submit"
      disabled={pending}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {pending ? 'Saving…' : 'Save changes'}
    </button>
  );
}

export function UserEditForm({
  profile,
  instructors,
}: {
  profile: Profile;
  instructors: Profile[];
}) {
  const action = (
    _prev: UpdateProfileState,
    formData: FormData,
  ): Promise<UpdateProfileState> => updateProfile(profile.id, formData);

  const [state, formAction] = useFormState<UpdateProfileState, FormData>(
    action,
    { error: null },
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
          defaultValue={profile.full_name ?? ''}
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        />
      </div>

      <div>
        <label htmlFor="role" className="block text-sm font-medium text-slate-900">
          Role
        </label>
        <select
          id="role"
          name="role"
          defaultValue={profile.role}
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        >
          {ROLES.map((r) => (
            <option key={r} value={r}>
              {r}
            </option>
          ))}
        </select>
      </div>

      <div>
        <label
          htmlFor="manager_id"
          className="block text-sm font-medium text-slate-900"
        >
          Manager (instructor)
        </label>
        <select
          id="manager_id"
          name="manager_id"
          defaultValue={profile.manager_id ?? ''}
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        >
          <option value="">(none)</option>
          {instructors.map((i) => (
            <option key={i.id} value={i.id}>
              {i.email}
            </option>
          ))}
        </select>
        <p className="mt-1 text-xs text-slate-500">
          Used by sales reps to surface their assigned instructor in dashboards.
        </p>
      </div>

      {state.error ? (
        <p className="text-sm text-red-700">{state.error}</p>
      ) : null}

      <SubmitButton />
    </form>
  );
}
