import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type { BookPart, Chapter, Section } from '@/types/database';

type ChapterWithCounts = Chapter & {
  total_sections: number;
  read_sections: number;
};

type ContinueTarget = {
  sectionId: string;
  sectionTitle: string;
  sectionNumber: string | null;
  chapterId: string;
  chapterTitle: string;
  chapterNumber: number;
};

export default async function LearnDashboardPage() {
  const { user, profile } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: parts } = await supabase
    .from('book_parts')
    .select('*')
    .eq('is_exam', false)
    .order('display_order', { ascending: true })
    .returns<BookPart[]>();

  const { data: chapters } = await supabase
    .from('chapters')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<Chapter[]>();

  const { data: sections } = await supabase
    .from('sections')
    .select('id, chapter_id, title, section_number, display_order')
    .order('display_order', { ascending: true })
    .returns<Pick<Section, 'id' | 'chapter_id' | 'title' | 'section_number' | 'display_order'>[]>();

  const { data: progressRows } = await supabase
    .from('reading_progress')
    .select('section_id')
    .eq('user_id', user.id)
    .eq('completed', true)
    .returns<{ section_id: string | null }[]>();

  const readSet = new Set(
    (progressRows ?? []).map((r) => r.section_id).filter(Boolean) as string[],
  );

  const chapterById = new Map((chapters ?? []).map((c) => [c.id, c] as const));
  const partOrderById = new Map((parts ?? []).map((p) => [p.id, p.display_order] as const));

  // Compute the next unread section in reading order:
  // (part display_order, chapter display_order, section display_order).
  const orderedSections = (sections ?? [])
    .filter((s) => s.chapter_id && chapterById.has(s.chapter_id))
    .map((s) => {
      const ch = chapterById.get(s.chapter_id!)!;
      return {
        section: s,
        chapter: ch,
        partOrder: ch.part_id ? (partOrderById.get(ch.part_id) ?? 999) : 999,
      };
    })
    .sort((a, b) => {
      if (a.partOrder !== b.partOrder) return a.partOrder - b.partOrder;
      if (a.chapter.display_order !== b.chapter.display_order) {
        return a.chapter.display_order - b.chapter.display_order;
      }
      return a.section.display_order - b.section.display_order;
    });

  let continueTarget: ContinueTarget | null = null;
  for (const item of orderedSections) {
    if (!readSet.has(item.section.id)) {
      continueTarget = {
        sectionId: item.section.id,
        sectionTitle: item.section.title,
        sectionNumber: item.section.section_number,
        chapterId: item.chapter.id,
        chapterTitle: item.chapter.title,
        chapterNumber: item.chapter.chapter_number,
      };
      break;
    }
  }
  const allRead = continueTarget == null && orderedSections.length > 0;

  const chaptersByPart = new Map<string, ChapterWithCounts[]>();
  for (const ch of chapters ?? []) {
    const partKey = ch.part_id ?? '__orphan__';
    const sectionsInChapter = (sections ?? []).filter(
      (s) => s.chapter_id === ch.id,
    );
    const total = sectionsInChapter.length;
    const read = sectionsInChapter.filter((s) => readSet.has(s.id)).length;
    const enriched: ChapterWithCounts = {
      ...ch,
      total_sections: total,
      read_sections: read,
    };
    const arr = chaptersByPart.get(partKey) ?? [];
    arr.push(enriched);
    chaptersByPart.set(partKey, arr);
  }

  if (!parts || parts.length === 0) {
    return (
      <div className="rounded-lg border border-slate-200 bg-white p-6 text-sm text-slate-600">
        No book content has been loaded yet.
      </div>
    );
  }

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Table of contents
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Work through the book at your own pace. Progress is saved as you mark
          sections read.
        </p>
        {profile.certified ? (
          <p className="mt-2 inline-flex items-center rounded-full bg-emerald-50 px-2.5 py-0.5 text-xs font-medium text-emerald-700">
            ✓ Certified{profile.certification_date
              ? ` ${new Date(profile.certification_date).toLocaleDateString()}`
              : ''}
          </p>
        ) : null}
      </div>

      {continueTarget ? (
        <Link
          href={`/learn/sections/${continueTarget.sectionId}`}
          className="block rounded-lg border border-blue-200 bg-blue-50 p-5 shadow-sm hover:bg-blue-100"
        >
          <p className="text-xs font-medium uppercase tracking-wide text-blue-700">
            Continue reading
          </p>
          <p className="mt-1 text-base font-semibold text-blue-900">
            {continueTarget.sectionNumber ? (
              <span className="text-blue-500">
                {continueTarget.sectionNumber}.{' '}
              </span>
            ) : null}
            {continueTarget.sectionTitle}
          </p>
          <p className="mt-0.5 text-xs text-blue-700">
            Chapter {continueTarget.chapterNumber}: {continueTarget.chapterTitle}
          </p>
        </Link>
      ) : allRead ? (
        <div className="rounded-lg border border-emerald-200 bg-emerald-50 p-5 shadow-sm">
          <p className="text-xs font-medium uppercase tracking-wide text-emerald-700">
            All caught up
          </p>
          <p className="mt-1 text-sm text-emerald-900">
            You&rsquo;ve read every section. Time for the{' '}
            <Link href="/learn/exam" className="font-semibold underline">
              final exam
            </Link>
            .
          </p>
        </div>
      ) : null}

      <div className="space-y-6">
        {parts.map((part) => {
          const partChapters = chaptersByPart.get(part.id) ?? [];
          return (
            <section
              key={part.id}
              className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm"
            >
              <header className="mb-3">
                <h2 className="text-lg font-semibold text-slate-900">
                  Part {part.part_number}: {part.title}
                </h2>
                {part.description ? (
                  <p className="mt-1 text-sm text-slate-600">
                    {part.description}
                  </p>
                ) : null}
              </header>
              {partChapters.length === 0 ? (
                <p className="text-sm italic text-slate-500">
                  No chapters in this part yet.
                </p>
              ) : (
                <ul className="divide-y divide-slate-100">
                  {partChapters.map((ch) => (
                    <li key={ch.id}>
                      <Link
                        href={`/learn/chapters/${ch.id}`}
                        className="flex items-center justify-between gap-4 py-3 text-sm hover:bg-slate-50"
                      >
                        <span className="text-slate-900">
                          <span className="text-slate-400">
                            Ch {ch.chapter_number}.
                          </span>{' '}
                          {ch.title}
                        </span>
                        <span className="text-xs text-slate-500">
                          {ch.read_sections} of {ch.total_sections} sections
                          {ch.has_quiz ? ' · quiz' : ''}
                        </span>
                      </Link>
                    </li>
                  ))}
                </ul>
              )}
            </section>
          );
        })}
      </div>
    </div>
  );
}
