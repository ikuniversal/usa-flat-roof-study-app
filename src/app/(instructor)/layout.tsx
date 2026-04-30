import { requireRole } from '@/lib/auth/role';

export default async function InstructorGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Instructors and admins.
  await requireRole(['instructor', 'admin']);
  return <>{children}</>;
}
