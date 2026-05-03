import { requireRole } from '@/lib/auth/role';
import { AdminNav } from '@/components/admin-nav';

export default async function AdminGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  await requireRole(['admin']);
  return (
    <div className="min-h-screen bg-slate-50">
      <AdminNav />
      <main className="mx-auto max-w-5xl px-6 py-8">{children}</main>
    </div>
  );
}
