import Link from 'next/link';
import { LogoutButton } from '@/components/logout-button';
import { requireUserWithProfile } from '@/lib/auth/role';

const NAV_LINKS = [
  { href: '/admin', label: 'Dashboard' },
  { href: '/admin/users', label: 'Users' },
];

export async function AdminNav() {
  const { user, profile } = await requireUserWithProfile();
  return (
    <header className="sticky top-0 z-10 border-b border-slate-200 bg-white">
      <div className="mx-auto flex max-w-5xl flex-wrap items-center gap-4 px-6 py-3">
        <Link href="/admin" className="text-base font-semibold text-slate-900">
          USA Flat Roof &mdash; Admin
        </Link>
        <nav className="flex flex-wrap items-center gap-1 text-sm">
          {NAV_LINKS.map((link) => (
            <Link
              key={link.href}
              href={link.href}
              className="rounded-md px-2.5 py-1.5 text-slate-700 hover:bg-slate-100 hover:text-slate-900"
            >
              {link.label}
            </Link>
          ))}
        </nav>
        <div className="ml-auto flex items-center gap-3 text-xs text-slate-500">
          <span className="hidden sm:inline">
            {user.email}{' '}
            <span className="text-slate-400">&middot; {profile.role}</span>
          </span>
          <LogoutButton className="rounded-md border border-slate-300 bg-white px-2.5 py-1.5 text-xs font-medium text-slate-700 hover:bg-slate-50" />
        </div>
      </div>
    </header>
  );
}
