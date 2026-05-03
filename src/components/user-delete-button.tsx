'use client';

import { useTransition } from 'react';
import { useRouter } from 'next/navigation';
import { deleteUser } from '@/app/actions/users';

export function UserDeleteButton({
  profileId,
  email,
  disabled,
}: {
  profileId: string;
  email: string;
  disabled?: boolean;
}) {
  const [pending, startTransition] = useTransition();
  const router = useRouter();

  function onClick() {
    if (pending || disabled) return;
    const ok = window.confirm(
      `Delete ${email}? This removes their auth account and profile. Cannot be undone.`,
    );
    if (!ok) return;
    startTransition(async () => {
      await deleteUser(profileId);
      router.push('/admin/users');
    });
  }

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={pending || disabled}
      className="rounded-md border border-red-300 bg-white px-4 py-2 text-sm font-medium text-red-700 hover:bg-red-50 disabled:opacity-50"
    >
      {pending ? 'Deleting…' : 'Delete user'}
    </button>
  );
}
