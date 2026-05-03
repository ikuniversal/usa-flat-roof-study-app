'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';

export type UpdateProfileSelfState = { error: string | null; saved: boolean };

// Lets the signed-in user update their own profile fields. Limited
// to full_name -- role and manager assignment stay admin-controlled,
// and email changes go through the Supabase auth surface, not here.
export async function updateOwnProfile(
  _prev: UpdateProfileSelfState,
  formData: FormData,
): Promise<UpdateProfileSelfState> {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const fullName = String(formData.get('full_name') ?? '').trim() || null;

  const { error } = await supabase
    .from('profiles')
    .update({ full_name: fullName })
    .eq('id', user.id);
  if (error) return { error: error.message, saved: false };

  revalidatePath('/learn');
  revalidatePath('/learn/profile');
  return { error: null, saved: true };
}
