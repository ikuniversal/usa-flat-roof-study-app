// Reusable skeleton building blocks. Used by route-group loading.tsx
// files to mimic the shape of the page that's about to render so the
// transition is less jarring.

export function SkeletonLine({
  width = 'w-full',
  height = 'h-4',
  className = '',
}: {
  width?: string;
  height?: string;
  className?: string;
}) {
  return (
    <div
      className={`animate-pulse rounded bg-slate-200 ${width} ${height} ${className}`}
    />
  );
}

export function SkeletonCard({
  lines = 2,
  className = '',
}: {
  lines?: number;
  className?: string;
}) {
  return (
    <div
      className={`space-y-2 rounded-lg border border-slate-200 bg-white p-5 shadow-sm ${className}`}
    >
      <SkeletonLine width="w-1/3" height="h-3" />
      {Array.from({ length: lines }).map((_, i) => (
        <SkeletonLine key={i} width={i === lines - 1 ? 'w-2/3' : 'w-full'} />
      ))}
    </div>
  );
}

export function SkeletonTable({ rows = 5 }: { rows?: number }) {
  return (
    <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
      <div className="space-y-2 p-4">
        {Array.from({ length: rows }).map((_, i) => (
          <div key={i} className="flex gap-3">
            <SkeletonLine width="w-1/3" />
            <SkeletonLine width="w-1/4" />
            <SkeletonLine width="w-1/6" />
          </div>
        ))}
      </div>
    </div>
  );
}
