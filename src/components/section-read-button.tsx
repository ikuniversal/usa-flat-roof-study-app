'use client';

import { useTransition } from 'react';
import { markSectionRead, markSectionUnread } from '@/app/actions/reading';

export function SectionReadButton({
  sectionId,
  isRead,
}: {
  sectionId: string;
  isRead: boolean;
}) {
  const [pending, startTransition] = useTransition();

  function onClick() {
    startTransition(async () => {
      if (isRead) {
        await markSectionUnread(sectionId);
      } else {
        await markSectionRead(sectionId);
      }
    });
  }

  const label = pending
    ? 'Saving…'
    : isRead
      ? 'Mark as unread'
      : 'Mark as read';
  const className = isRead
    ? 'rounded-md border border-slate-300 bg-white px-4 py-2 text-sm font-medium text-slate-700 hover:bg-slate-50 disabled:opacity-50'
    : 'rounded-md bg-emerald-600 px-4 py-2 text-sm font-medium text-white hover:bg-emerald-700 disabled:opacity-50';

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={pending}
      className={className}
    >
      {label}
    </button>
  );
}
