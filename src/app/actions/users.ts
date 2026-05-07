'use server';

import { revalidatePath } from 'next/cache';
import { headers } from 'next/headers';
import { createClient } from '@/lib/supabase/server';
import { createAdminClient } from '@/lib/supabase/admin';
import { requireRole } from '@/lib/auth/role';
import type { UserRole } from '@/types/database';

export type InviteUserState = {
  error: string | null;
  email: string | null;
};

export type UpdateProfileState = { error: string | null };

const VALID_ROLES: UserRole[] = ['admin', 'instructor', 'sales_rep'];

function isValidRole(r: unknown): r is UserRole {
  return typeof r === 'string' && (VALID_ROLES as string[]).includes(r);
}

// Sends a magic-link invite to a new user. Uses the admin client
// because auth.admin.inviteUserByEmail requires the service role key.
// The handle_new_user trigger creates a profiles row with role
// 'sales_rep' on first sign-in; we then immediately update the role
// to whatever was selected at invite time.
export async function inviteUser(
  _prev: InviteUserState,
  formData: FormData,
): Promise<InviteUserState> {
  await requireRole(['admin']);

  const email = String(formData.get('email') ?? '').trim();
  const role = String(formData.get('role') ?? '');
  const fullName = String(formData.get('full_name') ?? '').trim() || null;

  if (!email) {
    return { error: 'Email is required.', email };
  }
  if (!isValidRole(role)) {
    return { error: 'Invalid role.', email };
  }

  const admin = createAdminClient();
  const origin = getRequestOrigin();

  const { data, error } = await admin.auth.admin.inviteUserByEmail(email, {
    redirectTo: `${origin}/auth/callback?next=/reset-password`,
    data: { full_name: fullName },
  });

  if (error || !data?.user) {
    return {
      error:
        error?.message ??
        'Could not send invite. The email may already be registered.',
      email,
    };
  }

  // The handle_new_user trigger inserts the profile with role
  // 'sales_rep' by default. Update it now that we have the new user id.
  const { error: updateErr } = await admin
    .from('profiles')
    .update({ role, full_name: fullName })
    .eq('id', data.user.id);
  if (updateErr) {
    return {
      error: `Invite sent, but role assignment failed: ${updateErr.message}`,
      email,
    };
  }

  revalidatePath('/admin/users');
  return { error: null, email: null };
}

export async function updateProfile(
  profileId: string,
  formData: FormData,
): Promise<UpdateProfileState> {
  await requireRole(['admin']);

  const role = String(formData.get('role') ?? '');
  const managerIdRaw = String(formData.get('manager_id') ?? '');
  const fullName = String(formData.get('full_name') ?? '').trim() || null;

  if (!isValidRole(role)) {
    return { error: 'Invalid role.' };
  }

  const managerId = managerIdRaw && managerIdRaw !== '' ? managerIdRaw : null;
  if (managerId === profileId) {
    return { error: 'A user cannot be their own manager.' };
  }

  const supabase = createClient();
  const { error } = await supabase
    .from('profiles')
    .update({ role, manager_id: managerId, full_name: fullName })
    .eq('id', profileId);
  if (error) return { error: error.message };

  revalidatePath('/admin/users');
  revalidatePath(`/admin/users/${profileId}`);
  return { error: null };
}

export async function deleteUser(profileId: string): Promise<void> {
  await requireRole(['admin']);

  const admin = createAdminClient();
  // Deleting the auth user cascades to the profile via the FK with
  // ON DELETE CASCADE.
  const { error } = await admin.auth.admin.deleteUser(profileId);
  if (error) throw new Error(`Could not delete user: ${error.message}`);

  revalidatePath('/admin/users');
}

function getRequestOrigin(): string {
  const h = headers();
  const proto = h.get('x-forwarded-proto') ?? 'http';
  const host = h.get('x-forwarded-host') ?? h.get('host') ?? 'localhost:3000';
  return `${proto}://${host}`;
}
