import Link from 'next/link';

// App-wide 404 page. Used when notFound() is called inside any
// route group, or when no route matches at all.
export default function NotFound() {
  return (
    <div className="min-h-screen bg-slate-50 px-6 py-10">
      <div className="mx-auto max-w-2xl space-y-4">
        <p className="text-xs uppercase tracking-wide text-slate-500">404</p>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Page not found
        </h1>
        <p className="text-sm text-slate-600">
          The page you&rsquo;re looking for doesn&rsquo;t exist, or you may
          not have access to it.
        </p>
        <div className="flex flex-wrap gap-2 pt-2">
          <Link
            href="/learn"
            className="rounded-md bg-slate-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-800"
          >
            Back to reading
          </Link>
          <Link
            href="/login"
            className="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-sm font-medium text-slate-700 hover:bg-slate-50"
          >
            Sign in
          </Link>
        </div>
      </div>
    </div>
  );
}
