'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';

export type MarkSectionState = { error: string | null };

// Upserts the user's reading_progress row for a section. Uses the SSR
// client so the write happens under the user's auth context — RLS
// (`Users manage own reading progress`) gates `user_id = auth.uid()`.
// Returns an error string for the caller to surface; never throws.
export async function markSectionRead(
  sectionId: string,
): Promise<MarkSectionState> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return { error: 'You must be signed in to track progress.' };
  }

  const { data: section, error: sectionErr } = await supabase
    .from('sections')
    .select('id, chapter_id')
    .eq('id', sectionId)
    .single<{ id: string; chapter_id: string | null }>();
  if (sectionErr || !section) {
    return { error: 'Section not found.' };
  }

  const { error } = await supabase.from('reading_progress').upsert(
    {
      user_id: user.id,
      section_id: section.id,
      chapter_id: section.chapter_id,
      completed: true,
      read_at: new Date().toISOString(),
    },
    { onConflict: 'user_id,section_id' },
  );
  if (error) {
    return { error: error.message };
  }

  revalidatePath('/learn');
  revalidatePath(`/learn/sections/${sectionId}`);
  if (section.chapter_id) {
    revalidatePath(`/learn/chapters/${section.chapter_id}`);
  }
  return { error: null };
}

export async function markSectionUnread(
  sectionId: string,
): Promise<MarkSectionState> {
  const supabase = createClient();
  const {
    data: { user },
  } = await supabase.auth.getUser();
  if (!user) {
    return { error: 'You must be signed in to track progress.' };
  }

  const { data: section } = await supabase
    .from('sections')
    .select('chapter_id')
    .eq('id', sectionId)
    .single<{ chapter_id: string | null }>();

  const { error } = await supabase
    .from('reading_progress')
    .delete()
    .eq('user_id', user.id)
    .eq('section_id', sectionId);
  if (error) {
    return { error: error.message };
  }

  revalidatePath('/learn');
  revalidatePath(`/learn/sections/${sectionId}`);
  if (section?.chapter_id) {
    revalidatePath(`/learn/chapters/${section.chapter_id}`);
  }
  return { error: null };
}
