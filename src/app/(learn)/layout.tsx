import { requireRole } from '@/lib/auth/role';

export default async function LearnGroupLayout({
  children,
}: {
  children: React.ReactNode;
}) {
  // Any authenticated user.
  await requireRole(['admin', 'instructor', 'sales_rep']);
  return <>{children}</>;
}
