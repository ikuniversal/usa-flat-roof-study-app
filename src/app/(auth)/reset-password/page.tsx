import { ResetPasswordForm } from './reset-password-form';

export default function ResetPasswordPage() {
  return (
    <div className="space-y-4">
      <h2 className="text-lg font-semibold text-slate-900">
        Set a new password
      </h2>
      <p className="text-sm text-slate-600">
        Enter and confirm the new password for your account.
      </p>
      <ResetPasswordForm />
    </div>
  );
}
