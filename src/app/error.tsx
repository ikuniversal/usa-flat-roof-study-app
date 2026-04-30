'use client';

import { useEffect } from 'react';

// Top-level error boundary. Catches any client-side error that the
// route-group boundaries don't catch (e.g. errors during render of
// the root layout or unmatched routes).
export default function RootError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('[RootError]', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-3xl space-y-4">
        <h1 className="text-xl font-semibold text-red-700">
          Application error
        </h1>
        <p className="text-sm text-slate-700">
          An error escaped all route-group boundaries. Details below
          were captured by the top-level error boundary.
        </p>
        <div className="rounded bg-white p-4 ring-1 ring-red-200">
          <div className="text-xs font-semibold uppercase text-slate-500">
            Message
          </div>
          <pre className="mt-1 whitespace-pre-wrap break-words text-sm text-red-900">
            {error.message || '(no message)'}
          </pre>
          {error.digest ? (
            <>
              <div className="mt-3 text-xs font-semibold uppercase text-slate-500">
                Digest
              </div>
              <pre className="mt-1 text-sm text-slate-900">{error.digest}</pre>
            </>
          ) : null}
          {error.stack ? (
            <>
              <div className="mt-3 text-xs font-semibold uppercase text-slate-500">
                Stack
              </div>
              <pre className="mt-1 whitespace-pre-wrap break-words text-xs text-slate-700">
                {error.stack}
              </pre>
            </>
          ) : null}
        </div>
        <button
          type="button"
          onClick={reset}
          className="rounded-md bg-slate-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-800"
        >
          Try again
        </button>
      </div>
    </div>
  );
}
