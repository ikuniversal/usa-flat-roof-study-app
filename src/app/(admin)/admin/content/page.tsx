import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';
import type { BookPart, Chapter } from '@/types/database';

export default async function ContentEditorPage() {
  await requireRole(['admin']);
  const supabase = createClient();

  const { data: parts } = await supabase
    .from('book_parts')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<BookPart[]>();
  const { data: chapters } = await supabase
    .from('chapters')
    .select('*')
    .order('display_order', { ascending: true })
    .returns<Chapter[]>();
  const { data: sections } = await supabase
    .from('sections')
    .select('id, chapter_id, content_markdown')
    .returns<{ id: string; chapter_id: string | null; content_markdown: string }[]>();

  const sectionStatsByChapter = new Map<
    string,
    { total: number; written: number }
  >();
  for (const s of sections ?? []) {
    if (!s.chapter_id) continue;
    const cur = sectionStatsByChapter.get(s.chapter_id) ?? {
      total: 0,
      written: 0,
    };
    cur.total += 1;
    if (s.content_markdown.trim().length > 0) cur.written += 1;
    sectionStatsByChapter.set(s.chapter_id, cur);
  }

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Content editor
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Edit chapter sections. Saves write a `content_revisions`
          audit row.
        </p>
      </div>

      {(parts ?? []).map((p) => {
        const partChapters = (chapters ?? []).filter(
          (c) => c.part_id === p.id,
        );
        if (partChapters.length === 0) return null;
        return (
          <section
            key={p.id}
            className="rounded-lg border border-slate-200 bg-white p-5 shadow-sm"
          >
            <h2 className="text-base font-semibold text-slate-900">
              Part {p.part_number}: {p.title}
            </h2>
            <ul className="mt-3 divide-y divide-slate-100">
              {partChapters.map((c) => {
                const stats = sectionStatsByChapter.get(c.id) ?? {
                  total: 0,
                  written: 0,
                };
                if (stats.total === 0) return null;
                return (
                  <li key={c.id}>
                    <Link
                      href={`/admin/content/chapters/${c.id}`}
                      className="flex items-center justify-between gap-4 py-3 text-sm hover:bg-slate-50"
                    >
                      <span className="text-slate-900">
                        <span className="text-slate-400">
                          Ch {c.chapter_number}.
                        </span>{' '}
                        {c.title}
                      </span>
                      <span className="text-xs text-slate-500">
                        {stats.written} of {stats.total} sections written
                      </span>
                    </Link>
                  </li>
                );
              })}
            </ul>
          </section>
        );
      })}
    </div>
  );
}
