import { logout } from '@/app/actions/auth';

export function LogoutButton({ className }: { className?: string }) {
  return (
    <form action={logout}>
      <button
        type="submit"
        className={
          className ??
          'rounded-md bg-slate-900 px-3 py-1.5 text-sm font-medium text-white hover:bg-slate-800'
        }
      >
        Log out
      </button>
    </form>
  );
}
