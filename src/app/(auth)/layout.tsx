export default function AuthLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  return (
    <div className="min-h-screen bg-slate-50 flex flex-col items-center justify-center px-4 py-12">
      <header className="mb-8 text-center">
        <h1 className="text-xl font-semibold tracking-tight text-slate-900">
          USA Flat Roof &mdash; Field Guide
        </h1>
      </header>
      <main className="w-full max-w-[400px]">
        <div className="rounded-lg bg-white p-6 shadow-sm ring-1 ring-slate-200">
          {children}
        </div>
      </main>
    </div>
  );
}
