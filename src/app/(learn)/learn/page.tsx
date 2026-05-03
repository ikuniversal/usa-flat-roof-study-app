import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type { BookPart, Chapter } from '@/types/database';

type ChapterWithCounts = Chapter & {
  total_sections: number;
  read_sections: number;
};

export default async function LearnDashboardPage() {
  const { user } = await requireUserWithProfile();
  const supabase = createClient();

  // Skip exam parts (Phase 7).
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

  // RLS-filtered section ids (e.g. is_instructor_only hidden from sales_rep).
  const { data: sections } = await supabase
    .from('sections')
    .select('id, chapter_id')
    .returns<{ id: string; chapter_id: string | null }[]>();

  const { data: progressRows } = await supabase
    .from('reading_progress')
    .select('section_id')
    .eq('user_id', user.id)
    .eq('completed', true)
    .returns<{ section_id: string | null }[]>();

  const readSet = new Set(
    (progressRows ?? []).map((r) => r.section_id).filter(Boolean) as string[],
  );

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
      </div>

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
