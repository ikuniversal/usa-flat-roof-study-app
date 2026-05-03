import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';
import { SectionMarkdownEditor } from '@/components/section-markdown-editor';
import type { Chapter, Section, ContentRevision, Profile } from '@/types/database';

export default async function ContentSectionEditPage({
  params,
}: {
  params: { sectionId: string };
}) {
  await requireRole(['admin']);
  const supabase = createClient();

  const { data: section } = await supabase
    .from('sections')
    .select('*')
    .eq('id', params.sectionId)
    .single<Section>();
  if (!section) notFound();

  const { data: chapter } = section.chapter_id
    ? await supabase
        .from('chapters')
        .select('id, title, chapter_number')
        .eq('id', section.chapter_id)
        .single<Pick<Chapter, 'id' | 'title' | 'chapter_number'>>()
    : { data: null };

  const { data: revisions } = await supabase
    .from('content_revisions')
    .select('*')
    .eq('section_id', section.id)
    .order('edited_at', { ascending: false })
    .limit(5)
    .returns<ContentRevision[]>();

  const editorIds = Array.from(
    new Set((revisions ?? []).map((r) => r.edited_by).filter(Boolean) as string[]),
  );
  const { data: editors } = await supabase
    .from('profiles')
    .select('id, email')
    .in('id', editorIds.length ? editorIds : ['__none__'])
    .returns<Pick<Profile, 'id' | 'email'>[]>();
  const editorEmail = new Map(
    (editors ?? []).map((e) => [e.id, e.email] as const),
  );

  return (
    <div className="space-y-6">
      <div>
        {chapter ? (
          <Link
            href={`/admin/content/chapters/${chapter.id}`}
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Chapter {chapter.chapter_number}: {chapter.title}
          </Link>
        ) : (
          <Link
            href="/admin/content"
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Content editor
          </Link>
        )}
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {section.section_number ? (
            <span className="text-slate-400">{section.section_number}. </span>
          ) : null}
          {section.title}
        </h1>
        <div className="mt-1 flex flex-wrap items-center gap-3 text-xs text-slate-500">
          {section.is_instructor_only ? (
            <span className="inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
              Instructor only
            </span>
          ) : null}
          <Link
            href={`/learn/sections/${section.id}`}
            className="text-blue-700 hover:underline"
          >
            View public page →
          </Link>
        </div>
      </div>

      <SectionMarkdownEditor
        sectionId={section.id}
        initialContent={section.content_markdown}
      />

      {revisions && revisions.length > 0 ? (
        <section>
          <h2 className="mb-2 text-sm font-semibold text-slate-900">
            Recent revisions
          </h2>
          <ul className="space-y-2 text-xs text-slate-600">
            {revisions.map((r) => (
              <li
                key={r.id}
                className="rounded-md border border-slate-200 bg-white px-3 py-2"
              >
                <span className="font-medium text-slate-800">
                  {r.edited_by ? (editorEmail.get(r.edited_by) ?? '—') : '—'}
                </span>{' '}
                <span className="text-slate-500">
                  &middot; {new Date(r.edited_at).toLocaleString()}
                </span>
                {r.edit_note ? (
                  <p className="mt-1 text-slate-700">{r.edit_note}</p>
                ) : null}
              </li>
            ))}
          </ul>
        </section>
      ) : null}
    </div>
  );
}
