import { SkeletonCard, SkeletonLine } from '@/components/skeleton';

// Loading fallback for any /learn route. Mimics the typical shape:
// a header line, optional hero card, a few content rows.
export default function LearnLoading() {
  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto max-w-5xl px-6 py-8">
        <div className="space-y-6">
          <div className="space-y-2">
            <SkeletonLine width="w-1/3" height="h-7" />
            <SkeletonLine width="w-1/2" height="h-3" />
          </div>
          <SkeletonCard lines={2} />
          <SkeletonCard lines={4} />
          <SkeletonCard lines={3} />
        </div>
      </div>
    </div>
  );
}
