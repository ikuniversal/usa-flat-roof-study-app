import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireRole } from '@/lib/auth/role';
import type { Chapter, Section } from '@/types/database';

export default async function ContentChapterPage({
  params,
}: {
  params: { chapterId: string };
}) {
  await requireRole(['admin']);
  const supabase = createClient();

  const { data: chapter } = await supabase
    .from('chapters')
    .select('*')
    .eq('id', params.chapterId)
    .single<Chapter>();
  if (!chapter) notFound();

  const { data: sections } = await supabase
    .from('sections')
    .select('*')
    .eq('chapter_id', chapter.id)
    .order('display_order', { ascending: true })
    .returns<Section[]>();

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/admin/content"
          className="text-xs text-slate-500 hover:text-slate-900"
        >
          &larr; All content
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          Chapter {chapter.chapter_number}: {chapter.title}
        </h1>
      </div>

      <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
        <table className="min-w-full divide-y divide-slate-200 text-sm">
          <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
            <tr>
              <th className="px-4 py-2 text-left">#</th>
              <th className="px-4 py-2 text-left">Title</th>
              <th className="px-4 py-2 text-left">Body</th>
              <th className="px-4 py-2 text-left">Visibility</th>
              <th className="px-4 py-2 text-left"></th>
            </tr>
          </thead>
          <tbody className="divide-y divide-slate-100 text-slate-800">
            {(sections ?? []).map((s) => {
              const len = s.content_markdown.trim().length;
              return (
                <tr key={s.id}>
                  <td className="px-4 py-2 text-slate-500">
                    {s.section_number ?? '—'}
                  </td>
                  <td className="px-4 py-2 font-medium">{s.title}</td>
                  <td className="px-4 py-2 text-xs text-slate-500">
                    {len === 0
                      ? 'empty'
                      : `${len.toLocaleString()} chars`}
                  </td>
                  <td className="px-4 py-2 text-xs">
                    {s.is_instructor_only ? (
                      <span className="inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
                        Instructor
                      </span>
                    ) : (
                      <span className="text-slate-400">Public</span>
                    )}
                  </td>
                  <td className="px-4 py-2 text-xs">
                    <Link
                      href={`/admin/content/sections/${s.id}`}
                      className="text-blue-700 hover:underline"
                    >
                      Edit
                    </Link>
                  </td>
                </tr>
              );
            })}
          </tbody>
        </table>
      </div>
    </div>
  );
}
