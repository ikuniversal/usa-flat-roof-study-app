import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { computeStreak } from '@/lib/streak';
import type {
  ReadingProgress,
  QuizAttempt,
  Section,
  Chapter,
  Quiz,
} from '@/types/database';

type ActivityEvent = {
  kind: 'read' | 'attempt';
  at: Date;
  label: string;
  href: string;
  detail?: string;
};

function formatRelative(d: Date): string {
  const ms = Date.now() - d.getTime();
  const sec = Math.floor(ms / 1000);
  if (sec < 60) return 'just now';
  const min = Math.floor(sec / 60);
  if (min < 60) return `${min}m ago`;
  const hr = Math.floor(min / 60);
  if (hr < 24) return `${hr}h ago`;
  const days = Math.floor(hr / 24);
  if (days < 7) return `${days}d ago`;
  return d.toLocaleDateString();
}

export default async function MyProgressPage() {
  const { user, profile } = await requireUserWithProfile();
  const supabase = createClient();

  const [progressRes, attemptsRes, sectionsRes, chaptersRes] = await Promise.all([
    supabase
      .from('reading_progress')
      .select('*')
      .eq('user_id', user.id)
      .returns<ReadingProgress[]>(),
    supabase
      .from('quiz_attempts')
      .select('*')
      .eq('user_id', user.id)
      .order('started_at', { ascending: false })
      .returns<QuizAttempt[]>(),
    supabase
      .from('sections')
      .select('id, title, section_number, chapter_id')
      .returns<Pick<Section, 'id' | 'title' | 'section_number' | 'chapter_id'>[]>(),
    supabase
      .from('chapters')
      .select('id, title, chapter_number, part_id, display_order')
      .order('display_order', { ascending: true })
      .returns<Pick<Chapter, 'id' | 'title' | 'chapter_number' | 'part_id' | 'display_order'>[]>(),
  ]);

  const progress = (progressRes.data ?? []).filter((r) => r.completed);
  const attempts = attemptsRes.data ?? [];
  const sections = sectionsRes.data ?? [];
  const chapters = chaptersRes.data ?? [];

  const quizIds = Array.from(
    new Set(attempts.map((a) => a.quiz_id).filter(Boolean) as string[]),
  );
  const { data: quizzes } = await supabase
    .from('quizzes')
    .select('id, title, chapter_id, is_final_exam')
    .in('id', quizIds.length ? quizIds : ['__none__'])
    .returns<Pick<Quiz, 'id' | 'title' | 'chapter_id' | 'is_final_exam'>[]>();
  const quizById = new Map((quizzes ?? []).map((q) => [q.id, q] as const));

  const sectionById = new Map(sections.map((s) => [s.id, s] as const));
  const chapterById = new Map(chapters.map((c) => [c.id, c] as const));

  // Reading streak.
  const streak = computeStreak(progress.map((r) => r.read_at));

  // Stats.
  const totalSections = sections.length;
  const sectionsRead = progress.length;
  const completedAttempts = attempts.filter((a) => a.completed_at);
  const passedAttempts = completedAttempts.filter((a) => a.passed);
  const totalQuizSeconds = completedAttempts.reduce(
    (acc, a) => acc + (a.time_spent_seconds ?? 0),
    0,
  );
  const totalQuizMinutes = Math.round(totalQuizSeconds / 60);

  // Per-chapter completion bars (chapters that have any sections).
  const sectionsByChapter = new Map<string, number>();
  for (const s of sections) {
    if (!s.chapter_id) continue;
    sectionsByChapter.set(
      s.chapter_id,
      (sectionsByChapter.get(s.chapter_id) ?? 0) + 1,
    );
  }
  const readByChapter = new Map<string, number>();
  for (const r of progress) {
    if (!r.section_id) continue;
    const sec = sectionById.get(r.section_id);
    if (!sec?.chapter_id) continue;
    readByChapter.set(sec.chapter_id, (readByChapter.get(sec.chapter_id) ?? 0) + 1);
  }

  // Activity feed: latest 12 events (reads + attempts), sorted desc.
  const events: ActivityEvent[] = [];
  for (const r of progress) {
    if (!r.read_at || !r.section_id) continue;
    const sec = sectionById.get(r.section_id);
    if (!sec) continue;
    const ch = sec.chapter_id ? chapterById.get(sec.chapter_id) : null;
    events.push({
      kind: 'read',
      at: new Date(r.read_at),
      label: `Read ${sec.section_number ? sec.section_number + '. ' : ''}${sec.title}`,
      href: `/learn/sections/${sec.id}`,
      detail: ch ? `Ch ${ch.chapter_number}: ${ch.title}` : undefined,
    });
  }
  for (const a of attempts) {
    const q = a.quiz_id ? quizById.get(a.quiz_id) : null;
    if (!a.completed_at) continue;
    events.push({
      kind: 'attempt',
      at: new Date(a.completed_at),
      label: `${a.passed ? 'Passed' : 'Failed'} ${
        q?.title ?? 'a quiz'
      }${a.score_percent != null ? ` (${a.score_percent}%)` : ''}`,
      href: q ? `/learn/quizzes/${q.id}/results/${a.id}` : '/learn',
    });
  }
  events.sort((a, b) => b.at.getTime() - a.at.getTime());
  const recentEvents = events.slice(0, 12);

  const readingProgressPct =
    totalSections > 0 ? Math.round((sectionsRead / totalSections) * 100) : 0;

  return (
    <div className="space-y-8">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          My progress
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Hi {profile.full_name ?? user.email} &mdash; here&rsquo;s where you stand.
        </p>
      </div>

      <section className="grid gap-3 sm:grid-cols-2 lg:grid-cols-4">
        <Stat
          label="Reading streak"
          value={`${streak.currentStreak} day${streak.currentStreak === 1 ? '' : 's'}`}
          sublabel={
            streak.longestStreak > streak.currentStreak
              ? `Longest: ${streak.longestStreak} days`
              : streak.currentStreak === 0 && streak.lastReadAt
                ? `Last read ${formatRelative(streak.lastReadAt)}`
                : undefined
          }
          accent={streak.currentStreak > 0 ? 'amber' : undefined}
        />
        <Stat
          label="Sections read"
          value={`${sectionsRead}`}
          sublabel={`${readingProgressPct}% of ${totalSections}`}
        />
        <Stat
          label="Quizzes passed"
          value={`${passedAttempts.length} / ${completedAttempts.length}`}
          sublabel={
            completedAttempts.length > 0
              ? `${Math.round((passedAttempts.length / completedAttempts.length) * 100)}% pass rate`
              : 'No attempts yet'
          }
        />
        <Stat
          label="Time on quizzes"
          value={
            totalQuizMinutes >= 60
              ? `${Math.floor(totalQuizMinutes / 60)}h ${totalQuizMinutes % 60}m`
              : `${totalQuizMinutes}m`
          }
          sublabel={
            profile.certified
              ? '✓ Certified'
              : `${
                  completedAttempts.filter((a) => quizById.get(a.quiz_id ?? '')?.is_final_exam)
                    .length
                } final-exam attempts`
          }
          accent={profile.certified ? 'emerald' : undefined}
        />
      </section>

      <section>
        <h2 className="mb-2 text-sm font-semibold text-slate-900">
          Chapter completion
        </h2>
        <div className="overflow-hidden rounded-lg border border-slate-200 bg-white shadow-sm">
          <ul className="divide-y divide-slate-100">
            {chapters
              .filter((c) => (sectionsByChapter.get(c.id) ?? 0) > 0)
              .map((c) => {
                const total = sectionsByChapter.get(c.id) ?? 0;
                const read = readByChapter.get(c.id) ?? 0;
                const pct = total > 0 ? Math.round((read / total) * 100) : 0;
                return (
                  <li key={c.id}>
                    <Link
                      href={`/learn/chapters/${c.id}`}
                      className="block px-4 py-2.5 text-sm hover:bg-slate-50"
                    >
                      <div className="flex items-baseline justify-between gap-3">
                        <span className="text-slate-900">
                          <span className="text-slate-400">
                            Ch {c.chapter_number}.
                          </span>{' '}
                          {c.title}
                        </span>
                        <span className="text-xs text-slate-500">
                          {read} / {total}
                        </span>
                      </div>
                      <div className="mt-1 h-1.5 overflow-hidden rounded-full bg-slate-100">
                        <div
                          className={`h-full ${
                            pct === 100
                              ? 'bg-emerald-500'
                              : pct > 0
                                ? 'bg-blue-500'
                                : 'bg-slate-200'
                          }`}
                          style={{ width: `${pct}%` }}
                        />
                      </div>
                    </Link>
                  </li>
                );
              })}
          </ul>
        </div>
      </section>

      <section>
        <h2 className="mb-2 text-sm font-semibold text-slate-900">
          Recent activity
        </h2>
        {recentEvents.length === 0 ? (
          <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
            No activity yet. Mark a section read to start your streak.
          </p>
        ) : (
          <ul className="space-y-2">
            {recentEvents.map((e, idx) => (
              <li
                key={idx}
                className="rounded-md border border-slate-200 bg-white px-3 py-2 text-sm shadow-sm"
              >
                <Link href={e.href} className="block hover:bg-slate-50">
                  <div className="flex items-baseline justify-between gap-3">
                    <span className="text-slate-900">
                      <span
                        aria-hidden
                        className={`mr-2 ${
                          e.kind === 'read' ? 'text-blue-500' : 'text-amber-500'
                        }`}
                      >
                        {e.kind === 'read' ? '📖' : '✓'}
                      </span>
                      {e.label}
                    </span>
                    <span className="text-xs text-slate-400">
                      {formatRelative(e.at)}
                    </span>
                  </div>
                  {e.detail ? (
                    <p className="mt-0.5 pl-7 text-xs text-slate-500">
                      {e.detail}
                    </p>
                  ) : null}
                </Link>
              </li>
            ))}
          </ul>
        )}
      </section>
    </div>
  );
}

function Stat({
  label,
  value,
  sublabel,
  accent,
}: {
  label: string;
  value: string;
  sublabel?: string;
  accent?: 'amber' | 'emerald';
}) {
  const accentClass =
    accent === 'amber'
      ? 'text-amber-700'
      : accent === 'emerald'
        ? 'text-emerald-700'
        : 'text-slate-900';
  return (
    <div className="rounded-lg border border-slate-200 bg-white p-4 shadow-sm">
      <p className="text-xs uppercase tracking-wide text-slate-500">{label}</p>
      <p className={`mt-1 text-2xl font-semibold ${accentClass}`}>{value}</p>
      {sublabel ? (
        <p className="mt-0.5 text-xs text-slate-500">{sublabel}</p>
      ) : null}
    </div>
  );
}
