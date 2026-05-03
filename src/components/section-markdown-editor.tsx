'use client';

import { useFormState, useFormStatus } from 'react-dom';
import dynamic from 'next/dynamic';
import { useState } from 'react';
import {
  updateSectionMarkdown,
  type UpdateSectionState,
} from '@/app/actions/content';
import '@uiw/react-md-editor/markdown-editor.css';
import '@uiw/react-markdown-preview/markdown.css';

// react-md-editor is a heavy client-only component; load it lazily.
const MDEditor = dynamic(
  () => import('@uiw/react-md-editor').then((m) => m.default),
  { ssr: false },
);

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

export function SectionMarkdownEditor({
  sectionId,
  initialContent,
}: {
  sectionId: string;
  initialContent: string;
}) {
  const [content, setContent] = useState<string>(initialContent);
  const action = (
    prev: UpdateSectionState,
    formData: FormData,
  ): Promise<UpdateSectionState> => {
    formData.set('content_markdown', content);
    return updateSectionMarkdown(sectionId, prev, formData);
  };
  const [state, formAction] = useFormState<UpdateSectionState, FormData>(
    action,
    { error: null, saved: false },
  );

  return (
    <form action={formAction} className="space-y-4" data-color-mode="light">
      <MDEditor
        value={content}
        onChange={(v) => setContent(v ?? '')}
        height={520}
        preview="live"
      />

      <div>
        <label
          htmlFor="edit_note"
          className="block text-sm font-medium text-slate-900"
        >
          Edit note (optional)
        </label>
        <input
          id="edit_note"
          name="edit_note"
          type="text"
          placeholder="Why this change?"
          className="mt-1 block w-full rounded-md border border-slate-300 bg-white px-3 py-2 text-sm text-slate-900"
        />
      </div>

      {state.error ? (
        <p className="text-sm text-red-700">{state.error}</p>
      ) : null}

      <div className="flex items-center gap-3">
        <SubmitButton saved={state.saved} />
        <p className="text-xs text-slate-500">
          {content.length.toLocaleString()} characters
        </p>
      </div>
    </form>
  );
}
