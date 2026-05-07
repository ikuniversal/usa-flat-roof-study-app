import { SkeletonLine, SkeletonTable } from '@/components/skeleton';

export default function InstructorLoading() {
  return (
    <div className="min-h-screen bg-slate-50">
      <div className="mx-auto max-w-5xl px-6 py-8 space-y-6">
        <div className="space-y-2">
          <SkeletonLine width="w-1/4" height="h-7" />
          <SkeletonLine width="w-1/3" height="h-3" />
        </div>
        <SkeletonTable rows={6} />
      </div>
    </div>
  );
}
