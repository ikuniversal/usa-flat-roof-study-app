'use client';

import { useEffect } from 'react';
import Link from 'next/link';

// Shared error UI used by every route-group's error.tsx. In
// development the full error (message, digest, stack) is shown so you
// can debug; in production only a friendly message + the digest is
// shown so a user can quote the digest in a bug report without seeing
// implementation details.
export function ErrorPanel({
  error,
  reset,
  scope,
  homeHref,
  homeLabel,
}: {
  error: Error & { digest?: string };
  reset: () => void;
  scope: string;
  homeHref: string;
  homeLabel: string;
}) {
  useEffect(() => {
    console.error(`[${scope}Error]`, error);
  }, [error, scope]);

  const isDev = process.env.NODE_ENV !== 'production';

  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-2xl space-y-4">
        <div>
          <h1 className="text-xl font-semibold text-slate-900">
            Something went wrong
          </h1>
          <p className="mt-1 text-sm text-slate-600">
            {scope === 'Root'
              ? 'The page failed to load.'
              : `The ${scope.toLowerCase()} surface failed to render.`}{' '}
            Try again, or head back to a known-good page.
          </p>
        </div>

        {isDev ? (
          <div className="rounded-lg border border-red-200 bg-white p-4">
            <div className="text-xs font-semibold uppercase tracking-wide text-slate-500">
              Message
            </div>
            <pre className="mt-1 whitespace-pre-wrap break-words text-sm text-red-900">
              {error.message || '(no message)'}
            </pre>
            {error.digest ? (
              <>
                <div className="mt-3 text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Digest
                </div>
                <pre className="mt-1 text-sm text-slate-900">{error.digest}</pre>
              </>
            ) : null}
            {error.stack ? (
              <>
                <div className="mt-3 text-xs font-semibold uppercase tracking-wide text-slate-500">
                  Stack
                </div>
                <pre className="mt-1 max-h-64 overflow-auto whitespace-pre-wrap break-words text-xs text-slate-700">
                  {error.stack}
                </pre>
              </>
            ) : null}
          </div>
        ) : error.digest ? (
          <p className="rounded-lg border border-slate-200 bg-white px-4 py-3 text-xs text-slate-500">
            Reference id: <code className="text-slate-700">{error.digest}</code>
          </p>
        ) : null}

        <div className="flex gap-2">
          <button
            type="button"
            onClick={reset}
            className="rounded-md bg-slate-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-800"
          >
            Try again
          </button>
          <Link
            href={homeHref}
            className="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            {homeLabel}
          </Link>
        </div>
      </div>
    </div>
  );
}
