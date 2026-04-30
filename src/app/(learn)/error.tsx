'use client';

import { useEffect } from 'react';

export default function LearnError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  useEffect(() => {
    console.error('[LearnError]', error);
  }, [error]);

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-3xl space-y-4">
        <h1 className="text-xl font-semibold text-red-700">
          Learn route error
        </h1>
        <p className="text-sm text-slate-700">
          The learn dashboard failed to render. Details below were
          captured by an instrumentation error boundary.
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
        <div className="flex gap-2">
          <button
            type="button"
            onClick={reset}
            className="rounded-md bg-slate-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-800"
          >
            Try again
          </button>
          <a
            href="/login"
            className="rounded-md bg-white px-3 py-1.5 text-sm font-medium text-slate-900 ring-1 ring-slate-200 hover:bg-slate-50"
          >
            Back to sign in
          </a>
        </div>
      </div>
    </div>
  );
}
