import { requireRole } from '@/lib/auth/role';
import { InstructorNav } from '@/components/instructor-nav';

export default async function InstructorGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  await requireRole(['instructor', 'admin']);
  return (
    <div className="min-h-screen bg-slate-50">
      <InstructorNav />
      <main className="mx-auto max-w-5xl px-6 py-8">{children}</main>
    </div>
  );
}
