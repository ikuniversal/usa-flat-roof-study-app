'use server';

import { revalidatePath } from 'next/cache';
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';

export type UpdateSectionState = { error: string | null; saved: boolean };

// Updates a section's markdown body and writes a content_revisions
// audit row. Both the section update and the revision insert go
// through the SSR client and are gated by the existing admin RLS
// policies (is_admin(auth.uid())).
export async function updateSectionMarkdown(
  sectionId: string,
  _prev: UpdateSectionState,
  formData: FormData,
): Promise<UpdateSectionState> {
  const { user } = await requireRole(['admin']);
  const supabase = createClient();

  const newContent = String(formData.get('content_markdown') ?? '');
  const editNote = String(formData.get('edit_note') ?? '').trim() || null;

  const { data: prior, error: readErr } = await supabase
    .from('sections')
    .select('content_markdown')
    .eq('id', sectionId)
    .single<{ content_markdown: string }>();
  if (readErr || !prior) {
    return { error: readErr?.message ?? 'Section not found.', saved: false };
  }

  if (prior.content_markdown === newContent) {
    return { error: null, saved: true };
  }

  const { error: updateErr } = await supabase
    .from('sections')
    .update({ content_markdown: newContent })
    .eq('id', sectionId);
  if (updateErr) return { error: updateErr.message, saved: false };

  // Best-effort revision write -- do not fail the save if it errors,
  // since the user-visible save already succeeded.
  await supabase.from('content_revisions').insert({
    section_id: sectionId,
    edited_by: user.id,
    previous_content: prior.content_markdown,
    new_content: newContent,
    edit_note: editNote,
  });

  revalidatePath(`/admin/content/sections/${sectionId}`);
  revalidatePath(`/learn/sections/${sectionId}`);
  return { error: null, saved: true };
}
