import { requireRole } from '@/lib/auth/role';

export default async function AdminGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Admins only.
  await requireRole(['admin']);
  return <>{children}</>;
}
