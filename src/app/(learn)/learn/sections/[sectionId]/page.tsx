import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { MarkdownRenderer } from '@/components/markdown-renderer';
import { SectionReadButton } from '@/components/section-read-button';
import { BookmarkButton } from '@/components/bookmark-button';
import type { Chapter, Section } from '@/types/database';

export default async function SectionReaderPage({
  params,
}: {
  params: { sectionId: string };
}) {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: section } = await supabase
    .from('sections')
    .select('*')
    .eq('id', params.sectionId)
    .single<Section>();

  if (!section) {
    notFound();
  }

  const { data: chapter } = section.chapter_id
    ? await supabase
        .from('chapters')
        .select('id, title, chapter_number')
        .eq('id', section.chapter_id)
        .single<Pick<Chapter, 'id' | 'title' | 'chapter_number'>>()
    : { data: null };

  const { data: siblings } = section.chapter_id
    ? await supabase
        .from('sections')
        .select('id, title, display_order')
        .eq('chapter_id', section.chapter_id)
        .order('display_order', { ascending: true })
        .returns<Pick<Section, 'id' | 'title' | 'display_order'>[]>()
    : { data: [] };

  const ordered = siblings ?? [];
  const idx = ordered.findIndex((s) => s.id === section.id);
  const prev = idx > 0 ? ordered[idx - 1] : null;
  const next = idx >= 0 && idx < ordered.length - 1 ? ordered[idx + 1] : null;

  const { data: progress } = await supabase
    .from('reading_progress')
    .select('completed')
    .eq('user_id', user.id)
    .eq('section_id', section.id)
    .maybeSingle<{ completed: boolean }>();

  const isRead = progress?.completed === true;

  const { data: bookmark } = await supabase
    .from('bookmarks')
    .select('id')
    .eq('user_id', user.id)
    .eq('section_id', section.id)
    .maybeSingle<{ id: string }>();
  const isBookmarked = bookmark != null;

  return (
    <article className="space-y-6">
      <div>
        {chapter ? (
          <Link
            href={`/learn/chapters/${chapter.id}`}
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Chapter {chapter.chapter_number}: {chapter.title}
          </Link>
        ) : (
          <Link
            href="/learn"
            className="text-xs text-slate-500 hover:text-slate-900"
          >
            &larr; Back to table of contents
          </Link>
        )}
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {section.section_number ? (
            <span className="text-slate-400">{section.section_number}. </span>
          ) : null}
          {section.title}
        </h1>
        {section.is_instructor_only ? (
          <p className="mt-2 inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
            Instructor-only content
          </p>
        ) : null}
      </div>

      <div className="rounded-lg border border-slate-200 bg-white p-6 shadow-sm">
        <MarkdownRenderer source={section.content_markdown} />
      </div>

      <div className="flex flex-wrap items-center justify-between gap-3 border-t border-slate-200 pt-4">
        <div className="flex items-center gap-2">
          <SectionReadButton sectionId={section.id} isRead={isRead} />
          <BookmarkButton
            sectionId={section.id}
            isBookmarked={isBookmarked}
          />
        </div>
        <div className="flex items-center gap-2 text-sm">
          {prev ? (
            <Link
              href={`/learn/sections/${prev.id}`}
              className="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-slate-700 hover:bg-slate-50"
            >
              &larr; {prev.title}
            </Link>
          ) : (
            <span className="rounded-md border border-slate-200 px-3 py-1.5 text-slate-300">
              &larr; Previous
            </span>
          )}
          {next ? (
            <Link
              href={`/learn/sections/${next.id}`}
              className="rounded-md border border-slate-300 bg-white px-3 py-1.5 text-slate-700 hover:bg-slate-50"
            >
              {next.title} &rarr;
            </Link>
          ) : (
            <span className="rounded-md border border-slate-200 px-3 py-1.5 text-slate-300">
              Next &rarr;
            </span>
          )}
        </div>
      </div>
    </article>
  );
}
