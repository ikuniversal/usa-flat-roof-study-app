'use client';

import { ErrorPanel } from '@/components/error-panel';

export default function AdminError({
  error,
  reset,
}: {
  error: Error & { digest?: string };
  reset: () => void;
}) {
  return (
    <ErrorPanel
      error={error}
      reset={reset}
      scope="Admin"
      homeHref="/admin"
      homeLabel="Back to admin dashboard"
    />
  );
}
