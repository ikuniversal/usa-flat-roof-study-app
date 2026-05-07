import Link from 'next/link';
import { notFound } from 'next/navigation';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import type {
  Profile,
  ReadingProgress,
  QuizAttempt,
  Quiz,
  Chapter,
  Section,
} from '@/types/database';

export default async function RepDetailPage({
  params,
}: {
  params: { repId: string };
}) {
  const { user, profile: viewer } = await requireUserWithProfile();
  const supabase = createClient();

  const { data: rep } = await supabase
    .from('profiles')
    .select('*')
    .eq('id', params.repId)
    .single<Profile>();

  // Reps that aren't the viewer's assignee will be filtered out by RLS
  // (instructor policy joins on manager_id). Admins see everyone.
  if (!rep) notFound();
  if (
    viewer.role === 'instructor' &&
    rep.manager_id !== user.id
  ) {
    notFound();
  }
  if (rep.role !== 'sales_rep') notFound();

  const { data: progress } = await supabase
    .from('reading_progress')
    .select('*')
    .eq('user_id', rep.id)
    .returns<ReadingProgress[]>();

  const { data: attempts } = await supabase
    .from('quiz_attempts')
    .select('*')
    .eq('user_id', rep.id)
    .order('started_at', { ascending: false })
    .returns<QuizAttempt[]>();

  // Fetch chapter + quiz titles for the attempts list.
  const quizIds = Array.from(
    new Set((attempts ?? []).map((a) => a.quiz_id).filter(Boolean) as string[]),
  );
  const { data: quizzes } = await supabase
    .from('quizzes')
    .select('id, title, chapter_id, is_final_exam')
    .in('id', quizIds.length ? quizIds : ['__none__'])
    .returns<Pick<Quiz, 'id' | 'title' | 'chapter_id' | 'is_final_exam'>[]>();
  const quizById = new Map((quizzes ?? []).map((q) => [q.id, q] as const));

  // Per-chapter progress: reads / total visible sections per chapter.
  const { data: sections } = await supabase
    .from('sections')
    .select('id, chapter_id')
    .returns<Pick<Section, 'id' | 'chapter_id'>[]>();
  const { data: chapters } = await supabase
    .from('chapters')
    .select('id, title, chapter_number, part_id')
    .order('display_order', { ascending: true })
    .returns<Pick<Chapter, 'id' | 'title' | 'chapter_number' | 'part_id'>[]>();

  const sectionCountByChapter = new Map<string, number>();
  for (const s of sections ?? []) {
    if (!s.chapter_id) continue;
    sectionCountByChapter.set(
      s.chapter_id,
      (sectionCountByChapter.get(s.chapter_id) ?? 0) + 1,
    );
  }
  const sectionIdToChapter = new Map(
    (sections ?? []).map((s) => [s.id, s.chapter_id] as const),
  );
  const readByChapter = new Map<string, number>();
  for (const r of progress ?? []) {
    if (!r.completed || !r.section_id) continue;
    const chapId = sectionIdToChapter.get(r.section_id);
    if (!chapId) continue;
    readByChapter.set(chapId, (readByChapter.get(chapId) ?? 0) + 1);
  }

  return (
    <div className="space-y-6">
      <div>
        <Link
          href="/instructor"
          className="text-xs text-slate-500 hover:text-slate-900"
        >
          &larr; My reps
        </Link>
        <h1 className="mt-2 text-2xl font-semibold tracking-tight text-slate-900">
          {rep.full_name ?? rep.email}
        </h1>
        <p className="mt-1 text-xs text-slate-500">
          {rep.email}
          {rep.certified ? (
            <span className="ml-3 inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
              Certified
            </span>
          ) : null}
          {rep.hire_date ? (
            <span className="ml-3">
              Hired {new Date(rep.hire_date).toLocaleDateString()}
            </span>
          ) : null}
        </p>
      </div>

      <section>
        <h2 className="mb-2 text-sm font-semibold text-slate-900">
          Reading progress
        </h2>
        <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
              <tr>
                <th className="px-4 py-2 text-left">Chapter</th>
                <th className="px-4 py-2 text-left">Sections read</th>
                <th className="px-4 py-2 text-left"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {(chapters ?? []).map((c) => {
                const total = sectionCountByChapter.get(c.id) ?? 0;
                const read = readByChapter.get(c.id) ?? 0;
                if (total === 0) return null;
                return (
                  <tr key={c.id}>
                    <td className="px-4 py-2 text-slate-900">
                      <span className="text-slate-400">
                        Ch {c.chapter_number}.
                      </span>{' '}
                      {c.title}
                    </td>
                    <td className="px-4 py-2 text-slate-600">
                      {read} / {total}
                    </td>
                    <td className="px-4 py-2 text-xs text-slate-400">
                      {read === total && total > 0 ? '✓ Complete' : ''}
                    </td>
                  </tr>
                );
              })}
            </tbody>
          </table>
        </div>
      </section>

      <section>
        <h2 className="mb-2 text-sm font-semibold text-slate-900">
          Quiz attempts
        </h2>
        {!attempts || attempts.length === 0 ? (
          <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
            No attempts yet.
          </p>
        ) : (
          <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
            <table className="min-w-full divide-y divide-slate-200 text-sm">
              <thead className="bg-slate-50 text-xs uppercase tracking-wide text-slate-500">
                <tr>
                  <th className="px-4 py-2 text-left">Quiz</th>
                  <th className="px-4 py-2 text-left">Attempt</th>
                  <th className="px-4 py-2 text-left">Date</th>
                  <th className="px-4 py-2 text-left">Score</th>
                  <th className="px-4 py-2 text-left">Result</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100 text-slate-800">
                {attempts.map((a) => {
                  const q = a.quiz_id ? quizById.get(a.quiz_id) : null;
                  return (
                    <tr key={a.id}>
                      <td className="px-4 py-2">
                        {q?.title ?? '(unknown quiz)'}
                        {q?.is_final_exam ? (
                          <span className="ml-2 inline-flex items-center rounded-full bg-amber-50 px-2 py-0.5 text-xs font-medium text-amber-800">
                            Final
                          </span>
                        ) : null}
                      </td>
                      <td className="px-4 py-2 text-slate-600">
                        #{a.attempt_number}
                      </td>
                      <td className="px-4 py-2 text-xs text-slate-500">
                        {new Date(a.started_at).toLocaleString()}
                      </td>
                      <td className="px-4 py-2">
                        {a.completed_at && a.score_percent != null
                          ? `${a.score_percent}%`
                          : '—'}
                      </td>
                      <td className="px-4 py-2">
                        {a.completed_at ? (
                          a.passed ? (
                            <span className="inline-flex items-center rounded-full bg-emerald-50 px-2 py-0.5 text-xs font-medium text-emerald-700">
                              Pass
                            </span>
                          ) : (
                            <span className="inline-flex items-center rounded-full bg-red-50 px-2 py-0.5 text-xs font-medium text-red-700">
                              Fail
                            </span>
                          )
                        ) : (
                          <span className="text-xs text-slate-400">
                            In progress
                          </span>
                        )}
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
