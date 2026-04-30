import Link from 'next/link';
import { ForgotPasswordForm } from './forgot-password-form';

export default function ForgotPasswordPage() {
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-slate-900">Reset password</h2>
      <p className="text-sm text-slate-600">
        Enter your email and we&rsquo;ll send you a link to set a new password.
      </p>

      <ForgotPasswordForm />

      <p className="text-sm text-slate-600">
        <Link
          href="/login"
          className="text-slate-900 underline-offset-2 hover:underline"
        >
          Back to sign in
        </Link>
      </p>
    </div>
  );
}
