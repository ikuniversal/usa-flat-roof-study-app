import Link from 'next/link';
import { createClient } from '@/lib/supabase/server';
import { requireUserWithProfile } from '@/lib/auth/role';
import { SearchInput } from '@/components/search-input';
import type {
  ComparisonTable,
  GlossaryTerm,
  Section,
  Chapter,
  Checklist,
} from '@/types/database';

function escapeIlikePattern(s: string): string {
  // % and _ are LIKE metacharacters; escape so the user's literal
  // text matches as text.
  return s.replace(/([\\%_])/g, '\\$1');
}

export default async function SearchPage({
  searchParams,
}: {
  searchParams: { q?: string };
}) {
  await requireUserWithProfile();
  const supabase = createClient();

  const raw = (searchParams.q ?? '').trim();
  const q = raw.length >= 2 ? raw : '';

  let glossary: GlossaryTerm[] = [];
  let sections: (Section & { chapter_title?: string; chapter_number?: number })[] = [];
  let comparisons: ComparisonTable[] = [];
  let checklists: Checklist[] = [];

  if (q) {
    const pattern = `%${escapeIlikePattern(q)}%`;

    const [glos, sec, comp, chk] = await Promise.all([
      supabase
        .from('glossary_terms')
        .select('*')
        .or(`term.ilike.${pattern},definition.ilike.${pattern}`)
        .order('term', { ascending: true })
        .limit(50)
        .returns<GlossaryTerm[]>(),
      supabase
        .from('sections')
        .select('*')
        .or(`title.ilike.${pattern},content_markdown.ilike.${pattern}`)
        .order('title', { ascending: true })
        .limit(50)
        .returns<Section[]>(),
      supabase
        .from('comparison_tables')
        .select('*')
        .or(`title.ilike.${pattern},description.ilike.${pattern}`)
        .order('table_number', { ascending: true })
        .limit(50)
        .returns<ComparisonTable[]>(),
      supabase
        .from('checklists')
        .select('*')
        .or(`title.ilike.${pattern},use_when.ilike.${pattern}`)
        .order('checklist_number', { ascending: true })
        .limit(50)
        .returns<Checklist[]>(),
    ]);
    glossary = glos.data ?? [];
    comparisons = comp.data ?? [];
    checklists = chk.data ?? [];

    // Augment section results with chapter labels.
    const rawSections = sec.data ?? [];
    const chapterIds = Array.from(
      new Set(rawSections.map((s) => s.chapter_id).filter(Boolean) as string[]),
    );
    const { data: chapterRows } = await supabase
      .from('chapters')
      .select('id, title, chapter_number')
      .in('id', chapterIds.length ? chapterIds : ['__none__'])
      .returns<Pick<Chapter, 'id' | 'title' | 'chapter_number'>[]>();
    const chapterById = new Map(
      (chapterRows ?? []).map((c) => [c.id, c] as const),
    );
    sections = rawSections.map((s) => {
      const ch = s.chapter_id ? chapterById.get(s.chapter_id) : null;
      return {
        ...s,
        chapter_title: ch?.title,
        chapter_number: ch?.chapter_number,
      };
    });
  }

  const totalCount =
    glossary.length + sections.length + comparisons.length + checklists.length;

  return (
    <div className="space-y-6">
      <div>
        <h1 className="text-2xl font-semibold tracking-tight text-slate-900">
          Search
        </h1>
        <p className="mt-1 text-sm text-slate-600">
          Across glossary, section titles and bodies, comparison tables, and
          checklists.
        </p>
      </div>

      <SearchInput initialQuery={raw} />

      {!q ? (
        <p className="text-sm italic text-slate-500">
          Enter at least two characters.
        </p>
      ) : totalCount === 0 ? (
        <p className="rounded-lg border border-slate-200 bg-white px-5 py-4 text-sm italic text-slate-500">
          No results for &ldquo;{q}&rdquo;.
        </p>
      ) : (
        <div className="space-y-6">
          {glossary.length > 0 ? (
            <ResultGroup
              label={`Glossary (${glossary.length})`}
              href="/learn/glossary"
            >
              {glossary.map((t) => (
                <li
                  key={t.id}
                  className="rounded-md border border-slate-200 bg-white p-3"
                >
                  <p className="text-sm font-semibold text-slate-900">
                    {t.term}
                  </p>
                  <p className="mt-1 text-xs text-slate-700 line-clamp-2">
                    {t.definition}
                  </p>
                </li>
              ))}
            </ResultGroup>
          ) : null}

          {sections.length > 0 ? (
            <ResultGroup label={`Sections (${sections.length})`}>
              {sections.map((s) => (
                <li
                  key={s.id}
                  className="rounded-md border border-slate-200 bg-white"
                >
                  <Link
                    href={`/learn/sections/${s.id}`}
                    className="block p-3 hover:bg-slate-50"
                  >
                    <p className="text-sm font-semibold text-slate-900">
                      {s.section_number ? (
                        <span className="text-slate-400">
                          {s.section_number}.{' '}
                        </span>
                      ) : null}
                      {s.title}
                    </p>
                    {s.chapter_title ? (
                      <p className="mt-0.5 text-xs text-slate-500">
                        Chapter {s.chapter_number}: {s.chapter_title}
                      </p>
                    ) : null}
                  </Link>
                </li>
              ))}
            </ResultGroup>
          ) : null}

          {comparisons.length > 0 ? (
            <ResultGroup
              label={`Comparison tables (${comparisons.length})`}
              href="/learn/comparisons"
            >
              {comparisons.map((t) => (
                <li
                  key={t.id}
                  className="rounded-md border border-slate-200 bg-white p-3"
                >
                  <p className="text-sm font-semibold text-slate-900">
                    Table {t.table_number}: {t.title}
                  </p>
                  {t.description ? (
                    <p className="mt-1 text-xs text-slate-700 line-clamp-2">
                      {t.description}
                    </p>
                  ) : null}
                </li>
              ))}
            </ResultGroup>
          ) : null}

          {checklists.length > 0 ? (
            <ResultGroup
              label={`Checklists (${checklists.length})`}
              href="/learn/checklists"
            >
              {checklists.map((c) => (
                <li
                  key={c.id}
                  className="rounded-md border border-slate-200 bg-white p-3"
                >
                  <p className="text-sm font-semibold text-slate-900">
                    {c.checklist_number}. {c.title}
                  </p>
                  {c.use_when ? (
                    <p className="mt-0.5 text-xs text-slate-500">
                      Use when: {c.use_when}
                    </p>
                  ) : null}
                </li>
              ))}
            </ResultGroup>
          ) : null}
        </div>
      )}
    </div>
  );
}

function ResultGroup({
  label,
  href,
  children,
}: {
  label: string;
  href?: string;
  children: React.ReactNode;
}) {
  return (
    <section>
      <header className="mb-2 flex items-baseline justify-between">
        <h2 className="text-sm font-semibold text-slate-900">{label}</h2>
        {href ? (
          <Link
            href={href}
            className="text-xs text-blue-700 hover:underline"
          >
            View all →
          </Link>
        ) : null}
      </header>
      <ul className="space-y-2">{children}</ul>
    </section>
  );
}
