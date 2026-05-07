'use client';

import { ErrorPanel } from '@/components/error-panel';

export default function LearnError({
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
      scope="Learn"
      homeHref="/learn"
      homeLabel="Back to table of contents"
    />
  );
}
