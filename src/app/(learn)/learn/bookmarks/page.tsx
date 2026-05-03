import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type { Bookmark, Section, Chapter } from '@/types/database';

export default async function BookmarksPage() {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: bookmarks } = await supabase
    .from('bookmarks')
    .select('*')
    .eq('user_id', user.id)
    .order('created_at', { ascending: false })
    .returns<Bookmark[]>();

  const sectionIds = (bookmarks ?? [])
    .map((b) => b.section_id)
    .filter(Boolean) as string[];

  const { data: sections } = await supabase
    .from('sections')
    .select('id, title, section_number, chapter_id')
    .in('id', sectionIds.length ? sectionIds : ['__none__'])
    .returns<Pick<Section, 'id' | 'title' | 'section_number' | 'chapter_id'>[]>();

  const chapterIds = Array.from(
    new Set((sections ?? []).map((s) => s.chapter_id).filter(Boolean) as string[]),
  );
  const { data: chapters } = await supabase
    .from('chapters')
    .select('id, title, chapter_number')
    .in('id', chapterIds.length ? chapterIds : ['__none__'])
    .returns<Pick<Chapter, 'id' | 'title' | 'chapter_number'>[]>();

  const sectionById = new Map((sections ?? []).map((s) => [s.id, s] as const));
  const chapterById = new Map((chapters ?? []).map((c) => [c.id, c] as const));

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Bookmarks
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          {bookmarks?.length ?? 0} bookmark
          {bookmarks?.length === 1 ? '' : 's'}.
        </p>
      </div>

      {!bookmarks || bookmarks.length === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          You haven&rsquo;t bookmarked any sections yet. Use the &ldquo;☆
          Bookmark&rdquo; button on any section reader page.
        </p>
      ) : (
        <ul className="space-y-3">
          {bookmarks.map((b) => {
            const sec = b.section_id ? sectionById.get(b.section_id) : null;
            const ch = sec?.chapter_id ? chapterById.get(sec.chapter_id) : null;
            return (
              <li
                key={b.id}
                className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm hover:shadow-md"
              >
                <Link
                  href={
                    b.section_id ? `/learn/sections/${b.section_id}` : '/learn'
                  }
                  className="block"
                >
                  <p className="text-base font-medium text-slate-900">
                    {sec ? (
                      <>
                        {sec.section_number ? (
                          <span className="text-slate-400">
                            {sec.section_number}.{' '}
                          </span>
                        ) : null}
                        {sec.title}
                      </>
                    ) : (
                      <span className="text-slate-500 italic">
                        (deleted section)
                      </span>
                    )}
                  </p>
                  {ch ? (
                    <p className="mt-0.5 text-xs text-slate-500">
                      Chapter {ch.chapter_number}: {ch.title}
                    </p>
                  ) : null}
                  {b.note ? (
                    <p className="mt-2 text-sm text-slate-700">{b.note}</p>
                  ) : null}
                  <p className="mt-1 text-xs text-slate-400">
                    Saved {new Date(b.created_at).toLocaleDateString()}
                  </p>
                </Link>
              </li>
            );
          })}
        </ul>
      )}
    </div>
  );
}
