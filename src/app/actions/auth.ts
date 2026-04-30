'use server';

import { redirect } from 'next/navigation';
import { headers } from 'next/headers';
import { createClient } from '@/lib/supabase/server';
import { homePathForRole } from '@/lib/auth/role';
import type { Profile } from '@/types/database';

export type LoginState = { error: string | null };
export type ForgotPasswordState = { error: string | null; sent: boolean };
export type ResetPasswordState = { error: string | null };

const GENERIC_AUTH_ERROR = 'Invalid email or password.';

// Login. On success, redirects to the role-appropriate dashboard. On
// failure, returns a generic error so we don't expose whether the
// account exists.
export async function login(
  _prev: LoginState,
  formData: FormData,
): Promise<LoginState> {
  const email = String(formData.get('email') ?? '').trim();
  const password = String(formData.get('password') ?? '');

  if (!email || !password) {
    return { error: GENERIC_AUTH_ERROR };
  }

  const supabase = createClient();
  const { error: signInError } = await supabase.auth.signInWithPassword({
    email,
    password,
  });

  if (signInError) {
    return { error: GENERIC_AUTH_ERROR };
  }

  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return { error: GENERIC_AUTH_ERROR };
  }

  const { data: profile } = await supabase
    .from('profiles')
    .select('role')
    .eq('id', user.id)
    .single<Pick<Profile, 'role'>>();

  // Default destination is /learn if we somehow can't read the role
  // (the layout role guard will catch and re-route if needed).
  const target = profile ? homePathForRole(profile.role) : '/learn';

  // redirect() throws — must run outside any try/catch.
  redirect(target);
}

// Sends a password-reset email. We don't reveal whether the email
// exists; the success view shows the same message either way.
export async function requestPasswordReset(
  _prev: ForgotPasswordState,
  formData: FormData,
): Promise<ForgotPasswordState> {
  const email = String(formData.get('email') ?? '').trim();
  if (!email) {
    return { error: 'Please enter your email address.', sent: false };
  }

  const supabase = createClient();
  const origin = getRequestOrigin();

  await supabase.auth.resetPasswordForEmail(email, {
    redirectTo: `${origin}/auth/callback?next=/reset-password`,
  });

  // Intentionally do not surface Supabase errors — same response
  // whether the email exists or not.
  return { error: null, sent: true };
}

// Updates the password for the currently-authenticated user (the
// /reset-password page is reached via the auth callback, which has
// already exchanged the recovery code for a session).
export async function resetPassword(
  _prev: ResetPasswordState,
  formData: FormData,
): Promise<ResetPasswordState> {
  const password = String(formData.get('password') ?? '');
  const confirm = String(formData.get('confirm') ?? '');

  if (password.length < 8) {
    return { error: 'Password must be at least 8 characters.' };
  }
  if (password !== confirm) {
    return { error: 'Passwords do not match.' };
  }

  const supabase = createClient();
  const { error } = await supabase.auth.updateUser({ password });
  if (error) {
    return { error: 'Could not update password. The reset link may have expired.' };
  }

  redirect('/login?reset=success');
}

export async function logout(): Promise<void> {
  const supabase = createClient();
  await supabase.auth.signOut();
  redirect('/login');
}

// Best-effort origin reconstruction from forwarded headers — used to
// build the password-reset redirect URL. Falls back to localhost.
function getRequestOrigin(): string {
  const h = headers();
  const proto = h.get('x-forwarded-proto') ?? 'http';
  const host = h.get('x-forwarded-host') ?? h.get('host') ?? 'localhost:3000';
  return `${proto}://${host}`;
}
