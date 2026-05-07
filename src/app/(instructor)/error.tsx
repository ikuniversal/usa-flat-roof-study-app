'use client';

import { ErrorPanel } from '@/components/error-panel';

export default function InstructorError({
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
      scope="Instructor"
      homeHref="/instructor"
      homeLabel="Back to instructor dashboard"
    />
  );
}
