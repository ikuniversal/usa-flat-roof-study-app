'use client';

import { useState, useTransition } from 'react';
import { updateBookmarkNote } from '@/app/actions/bookmarks';

export function BookmarkNoteEditor({
  bookmarkId,
  initialNote,
}: {
  bookmarkId: string;
  initialNote: string | null;
}) {
  const [note, setNote] = useState<string>(initialNote ?? '');
  const [pending, startTransition] = useTransition();
  const [editing, setEditing] = useState(false);
  const [error, setError] = useState<string | null>(null);

  function save() {
    setError(null);
    startTransition(async () => {
      const res = await updateBookmarkNote(bookmarkId, note);
      if (res.error) setError(res.error);
      else setEditing(false);
    });
  }

  if (!editing) {
    return (
      <button
        type="button"
        onClick={(e) => {
          e.preventDefault();
          e.stopPropagation();
          setEditing(true);
        }}
        className="mt-2 text-xs text-blue-700 hover:underline"
      >
        {note ? 'Edit note' : '+ Add note'}
      </button>
    );
  }

  return (
    <div
      className="mt-2"
      onClick={(e) => e.stopPropagation()}
      onMouseDown={(e) => e.stopPropagation()}
    >
      <textarea
        value={note}
        onChange={(e) => setNote(e.target.value)}
        rows={3}
        placeholder="Why did you bookmark this?"
        className="block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
      />
      {error ? <p className="mt-1 text-xs text-red-600">{error}</p> : null}
      <div className="mt-2 flex items-center gap-2">
        <button
          type="button"
          onClick={(e) => {
            e.preventDefault();
            save();
          }}
          disabled={pending}
          className="rounded-md bg-blue-600 px-3 py-1 text-xs font-medium text-white hover:bg-blue-700 disabled:opacity-50"
        >
          {pending ? 'Saving…' : 'Save'}
        </button>
        <button
          type="button"
          onClick={(e) => {
            e.preventDefault();
            setNote(initialNote ?? '');
            setEditing(false);
            setError(null);
          }}
          disabled={pending}
          className="rounded-md border border-slate-300 bg-white px-3 py-1 text-xs font-medium text-slate-700 hover:bg-slate-50"
        >
          Cancel
        </button>
      </div>
    </div>
  );
}
