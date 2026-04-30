import Link from 'next/link';
import { LoginForm } from './login-form';

export default function LoginPage({
  searchParams,
}: {
  searchParams: { reset?: string };
}) {
  const passwordWasReset = searchParams.reset === 'success';

  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-slate-900">Sign in</h2>

      {passwordWasReset && (
        <div className="rounded-md bg-green-50 px-3 py-2 text-sm text-green-700 ring-1 ring-green-200">
          Password updated. Sign in with your new password.
        </div>
      )}

      <LoginForm />

      <p className="text-sm text-slate-600">
        <Link
          href="/forgot-password"
          className="text-slate-900 underline-offset-2 hover:underline"
        >
          Forgot password?
        </Link>
      </p>
    </div>
  );
}
