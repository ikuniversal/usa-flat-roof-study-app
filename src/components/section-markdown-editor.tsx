'use client';

import { useFormState, useFormStatus } from 'react-dom';
import dynamic from 'next/dynamic';
import { useEffect, useRef, useState } from 'react';
import {
  updateSectionMarkdown,
  type UpdateSectionState,
} from '@/app/actions/content';
import '@uiw/react-md-editor/markdown-editor.css';
import '@uiw/react-markdown-preview/markdown.css';

const MDEditor = dynamic(
  () => import('@uiw/react-md-editor').then((m) => m.default),
  { ssr: false },
);

// Rough reading-time estimate (200 wpm).
function readMinutes(s: string): number {
  const words = s.trim().split(/\s+/).filter(Boolean).length;
  return Math.max(1, Math.round(words / 200));
}

function SubmitButton({
  saved,
  dirty,
}: {
  saved: boolean;
  dirty: boolean;
}) {
  const { pending } = useFormStatus();
  const label = pending
    ? 'Saving…'
    : dirty
      ? 'Save (⌘+S)'
      : saved
        ? 'Saved ✓'
        : 'Save';
  return (
    <button
      type="submit"
      disabled={pending || !dirty}
      className="rounded-md bg-blue-600 px-4 py-2 text-sm font-medium text-white hover:bg-blue-700 disabled:opacity-50"
    >
      {label}
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
  // Tracks "what was last saved", separate from initialContent so the
  // dirty flag flips back to clean after a successful save without a
  // page reload.
  const [savedContent, setSavedContent] = useState<string>(initialContent);
  const dirty = content !== savedContent;
  const formRef = useRef<HTMLFormElement>(null);

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

  // Snapshot last-saved content whenever the action reports success.
  useEffect(() => {
    if (state.saved && state.error == null) {
      setSavedContent(content);
    }
    // eslint-disable-next-line react-hooks/exhaustive-deps
  }, [state.saved, state.error]);

  // ⌘/Ctrl+S submits the form.
  useEffect(() => {
    function onKey(e: KeyboardEvent) {
      const cmd = e.metaKey || e.ctrlKey;
      if (cmd && e.key.toLowerCase() === 's') {
        e.preventDefault();
        formRef.current?.requestSubmit();
      }
    }
    window.addEventListener('keydown', onKey);
    return () => window.removeEventListener('keydown', onKey);
  }, []);

  // Browser unsaved-changes guard. Custom messages aren't shown by
  // modern browsers — they all use a generic "leave site?" prompt —
  // but the prompt itself is the win.
  useEffect(() => {
    if (!dirty) return;
    function onBeforeUnload(e: BeforeUnloadEvent) {
      e.preventDefault();
      e.returnValue = '';
    }
    window.addEventListener('beforeunload', onBeforeUnload);
    return () => window.removeEventListener('beforeunload', onBeforeUnload);
  }, [dirty]);

  return (
    <form
      ref={formRef}
      action={formAction}
      className="space-y-4"
      data-color-mode="light"
    >
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

      <div className="flex flex-wrap items-center gap-3">
        <SubmitButton saved={state.saved && !dirty} dirty={dirty} />
        <p className="text-xs text-slate-500">
          {content.length.toLocaleString()} chars &middot; ~{readMinutes(content)} min read
          {dirty ? (
            <span className="ml-2 inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
              Unsaved changes
            </span>
          ) : null}
        </p>
      </div>
    </form>
  );
}
