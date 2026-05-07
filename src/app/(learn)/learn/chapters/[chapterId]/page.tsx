import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type { Chapter, Quiz, Section } from '@/types/database';

export default async function ChapterPage({
  params,
}: {
  params: { chapterId: string };
}) {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: chapter } = await supabase
    .from('chapters')
    .select('*')
    .eq('id', params.chapterId)
    .single<Chapter>();

  if (!chapter) {
    notFound();
  }

  const { data: sections } = await supabase
    .from('sections')
    .select('*')
    .eq('chapter_id', chapter.id)
    .order('display_order', { ascending: true })
    .returns<Section[]>();

  const { data: progressRows } = await supabase
    .from('reading_progress')
    .select('section_id')
    .eq('user_id', user.id)
    .eq('completed', true)
    .returns<{ section_id: string | null }[]>();

  const { data: quiz } = chapter.has_quiz
    ? await supabase
        .from('quizzes')
        .select('id, is_final_exam')
        .eq('chapter_id', chapter.id)
        .maybeSingle<Pick<Quiz, 'id' | 'is_final_exam'>>()
    : { data: null };

  const readSet = new Set(
    (progressRows ?? []).map((r) => r.section_id).filter(Boolean) as string[],
  );

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/learn"
          className="text-xs text-slate-500 hover:text-slate-900"
        >
          &larr; Back to table of contents
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          Chapter {chapter.chapter_number}: {chapter.title}
        </h1>
        <p className="mt-1 flex flex-wrap items-center gap-x-3 gap-y-1 text-xs text-slate-500">
          {chapter.estimated_read_time_minutes ? (
            <span>
              ~{chapter.estimated_read_time_minutes} min read
            </span>
          ) : null}
          {chapter.estimated_word_count ? (
            <span>{chapter.estimated_word_count.toLocaleString()} words</span>
          ) : null}
          {chapter.has_quiz ? (
            <span className="inline-flex items-center rounded-full bg-blue-50 px-2 py-0.5 text-xs font-medium text-blue-700">
              Quiz available
            </span>
          ) : null}
        </p>
      </div>

      <section className="rounded-lg border border-slate-200 bg-white shadow-sm">
        <header className="border-b border-slate-200 px-5 py-3">
          <h2 className="text-sm font-semibold text-slate-900">Sections</h2>
        </header>
        {!sections || sections.length === 0 ? (
          <p className="px-5 py-4 text-sm italic text-slate-500">
            No sections in this chapter yet.
          </p>
        ) : (
          <ol className="divide-y divide-slate-100">
            {sections.map((section) => {
              const isRead = readSet.has(section.id);
              return (
                <li key={section.id}>
                  <Link
                    href={`/learn/sections/${section.id}`}
                    className="flex items-center justify-between gap-4 px-5 py-3 text-sm hover:bg-slate-50"
                  >
                    <span className="flex items-center gap-3">
                      <span
                        aria-hidden
                        className={
                          isRead
                            ? 'inline-flex h-5 w-5 items-center justify-center rounded-full bg-emerald-500 text-xs font-bold text-white'
                            : 'inline-flex h-5 w-5 items-center justify-center rounded-full border border-slate-300 text-xs text-slate-400'
                        }
                      >
                        {isRead ? '✓' : ''}
                      </span>
                      <span className="text-slate-900">
                        {section.section_number ? (
                          <span className="text-slate-400">
                            {section.section_number}.{' '}
                          </span>
                        ) : null}
                        {section.title}
                      </span>
                    </span>
                    <span className="text-xs text-slate-400">
                      {isRead ? 'Read' : 'Unread'}
                    </span>
                  </Link>
                </li>
              );
            })}
          </ol>
        )}
      </section>

      {chapter.has_quiz && quiz ? (
        <Link
          href={`/learn/quizzes/${quiz.id}`}
          className="block rounded-lg border border-blue-200 bg-blue-50 px-5 py-4 text-sm text-blue-900 hover:bg-blue-100"
        >
          A chapter quiz is available &mdash;{' '}
          <span className="font-semibold">take it now &rarr;</span>
        </Link>
      ) : chapter.has_quiz ? (
        <div className="rounded-lg border border-amber-200 bg-amber-50 px-5 py-4 text-sm text-amber-900">
          A chapter quiz is expected here, but its questions have not been
          imported yet.
        </div>
      ) : null}
    </div>
  );
}
