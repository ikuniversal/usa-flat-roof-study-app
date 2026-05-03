import { requireRole } from '@/lib/auth/role';
import { LearnNav } from '@/components/learn-nav';

export default async function LearnGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  await requireRole(['admin', 'instructor', 'sales_rep']);
  return (
    <div className="min-h-screen bg-slate-50">
      <LearnNav />
      <main className="mx-auto max-w-5xl px-6 py-8">{children}</main>
    </div>
  );
}
