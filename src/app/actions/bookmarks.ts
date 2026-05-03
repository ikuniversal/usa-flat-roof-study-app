'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';

export type ToggleBookmarkResult = { error: string | null };

export async function toggleBookmark(
  sectionId: string,
  note: string | null,
): Promise<ToggleBookmarkResult> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: 'You must be signed in.' };

  const { data: existing } = await supabase
    .from('bookmarks')
    .select('id')
    .eq('user_id', user.id)
    .eq('section_id', sectionId)
    .maybeSingle<{ id: string }>();

  if (existing) {
    const { error } = await supabase
      .from('bookmarks')
      .delete()
      .eq('id', existing.id);
    if (error) return { error: error.message };
  } else {
    const { error } = await supabase.from('bookmarks').insert({
      user_id: user.id,
      section_id: sectionId,
      note,
    });
    if (error) return { error: error.message };
  }

  revalidatePath(`/learn/sections/${sectionId}`);
  revalidatePath('/learn/bookmarks');
  return { error: null };
}

export async function removeBookmark(
  sectionId: string,
): Promise<ToggleBookmarkResult> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) return { error: 'You must be signed in.' };

  const { error } = await supabase
    .from('bookmarks')
    .delete()
    .eq('user_id', user.id)
    .eq('section_id', sectionId);
  if (error) return { error: error.message };

  revalidatePath('/learn/bookmarks');
  revalidatePath(`/learn/sections/${sectionId}`);
  return { error: null };
}
