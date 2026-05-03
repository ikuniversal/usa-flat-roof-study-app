'use client';

import { useTransition } from 'react';
import { toggleBookmark } from '@/app/actions/bookmarks';

export function BookmarkButton({
  sectionId,
  isBookmarked,
}: {
  sectionId: string;
  isBookmarked: boolean;
}) {
  const [pending, startTransition] = useTransition();

  function onClick() {
    startTransition(async () => {
      await toggleBookmark(sectionId, null);
    });
  }

  return (
    <button
      type="button"
      onClick={onClick}
      disabled={pending}
      aria-pressed={isBookmarked}
      className={`rounded-md border px-3 py-1.5 text-sm font-medium disabled:opacity-50 ${
        isBookmarked
          ? 'border-amber-300 bg-amber-50 text-amber-900 hover:bg-amber-100'
          : 'border-slate-300 bg-white text-slate-700 hover:bg-slate-50'
      }`}
    >
      {pending
        ? 'Saving…'
        : isBookmarked
          ? '★ Bookmarked'
          : '☆ Bookmark'}
    </button>
  );
}
