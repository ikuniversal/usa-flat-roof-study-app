// Imports the USA Flat Roof Field Guide content from /content JSON
// files into Supabase. Idempotent — re-runnable without duplication.
//
// Usage:
//   npm run import:content              (LIVE, writes to DB)
//   npm run import:content -- --dry-run (queries DB, prints what
//                                        would change, writes nothing)
//
// Idempotency strategy:
//   book_parts          — upsert by part_number
//   chapters            — upsert by (part_id, chapter_number)
//   sections            — insert if (chapter_id, section_number)
//                         not present; never update or delete (so
//                         admin-edited content_markdown is preserved
//                         across re-imports)
//
// (Importers for final exam, chapter quizzes, comparison tables,
//  glossary, and checklists land in subsequent commits.)

import { createClient, type SupabaseClient } from '@supabase/supabase-js';
import { readFileSync } from 'node:fs';
import path from 'node:path';

// ---------------------------------------------------------------------------
// CLI args
// ---------------------------------------------------------------------------
const dryRun = process.argv.includes('--dry-run');

// ---------------------------------------------------------------------------
// Logging
// ---------------------------------------------------------------------------
function log(msg: string): void {
  const prefix = dryRun ? '[DRY-RUN]' : '[LIVE]';
  console.log(`${prefix} ${msg}`);
}

// ---------------------------------------------------------------------------
// Inline admin client (this script runs from Node, not Next.js)
// ---------------------------------------------------------------------------
function createAdminClient(): SupabaseClient {
  const url = process.env.NEXT_PUBLIC_SUPABASE_URL;
  const serviceKey = process.env.SUPABASE_SERVICE_ROLE_KEY;
  if (!url) {
    throw new Error(
      'NEXT_PUBLIC_SUPABASE_URL is not set. Add it to .env.local.',
    );
  }
  if (!serviceKey) {
    throw new Error(
      'SUPABASE_SERVICE_ROLE_KEY is not set. Add it to .env.local.',
    );
  }
  return createClient(url, serviceKey, {
    auth: { persistSession: false, autoRefreshToken: false },
  });
}

// ---------------------------------------------------------------------------
// Content file paths
// ---------------------------------------------------------------------------
const CONTENT_DIR = path.resolve(process.cwd(), 'content');
const PATHS = {
  bookStructure: path.join(CONTENT_DIR, '01_book_structure.json'),
  finalExam: path.join(CONTENT_DIR, '02_final_exam.json'),
  chapterQuizzes: path.join(CONTENT_DIR, '03_chapter_quizzes.json'),
  comparisonTables: path.join(CONTENT_DIR, '04_comparison_tables.json'),
  glossary: path.join(CONTENT_DIR, '05_glossary.json'),
  checklists: path.join(CONTENT_DIR, '06_inspection_checklists.json'),
};

// ---------------------------------------------------------------------------
// JSON shape types — only what these three importers need.
// ---------------------------------------------------------------------------
interface ChapterJson {
  chapter_number: number;
  title: string;
  type: string;
  depth?: 'core' | 'secondary' | 'reference';
  display_order: number;
  estimated_read_time_minutes?: number;
  estimated_word_count?: number;
  has_quiz?: boolean;
  extended_section?: boolean;
}

interface ModuleJson {
  module_number: number;
  title: string;
  type: 'module';
  display_order: number;
  estimated_read_time_minutes?: number;
  estimated_word_count?: number;
  has_quiz?: boolean;
}

interface PartJson {
  part_number: number;
  title: string;
  description?: string;
  display_order: number;
  is_exam?: boolean;
  reference_only?: boolean;
  points_to?: string;
  chapters?: ChapterJson[];
  modules?: ModuleJson[];
}

interface SectionTemplateJson {
  section_number: string;
  title: string;
  is_instructor_only: boolean;
}

interface BookStructureJson {
  metadata: Record<string, unknown>;
  parts: PartJson[];
  chapter_section_templates: {
    core_chapter_sections: SectionTemplateJson[];
  };
}

// ---------------------------------------------------------------------------
// Summary accumulator
// ---------------------------------------------------------------------------
interface TableStats {
  inserted: number;
  updated: number;
  skipped: number;
}

interface Summary {
  book_parts: TableStats;
  chapters: TableStats;
  sections: TableStats;
}

const summary: Summary = {
  book_parts: { inserted: 0, updated: 0, skipped: 0 },
  chapters: { inserted: 0, updated: 0, skipped: 0 },
  sections: { inserted: 0, updated: 0, skipped: 0 },
};

// ---------------------------------------------------------------------------
// 5-section template applied to Part 3 modules
// (per Phase 4 brief Step 6 — overrides Step 5 for Part 3)
// ---------------------------------------------------------------------------
const MODULE_SECTION_TEMPLATE: SectionTemplateJson[] = [
  { section_number: '1', title: 'Learning Objectives', is_instructor_only: false },
  { section_number: '2', title: 'Core Content', is_instructor_only: false },
  { section_number: '3', title: 'Examples', is_instructor_only: false },
  { section_number: '4', title: 'Common Mistakes', is_instructor_only: false },
  { section_number: '5', title: 'Quick Reference Summary', is_instructor_only: false },
];

// ---------------------------------------------------------------------------
// JSON loaders
// ---------------------------------------------------------------------------
function loadBookStructure(): BookStructureJson {
  return JSON.parse(readFileSync(PATHS.bookStructure, 'utf8')) as BookStructureJson;
}

// ---------------------------------------------------------------------------
// Cross-importer maps
// ---------------------------------------------------------------------------
type PartIdMap = Map<number, string>;

interface ChapterRecord {
  id: string;
  part_number: number;
  chapter_number: number;
  type: string;
  depth: string | null;
}

// Keyed by `${part_number}-${chapter_number}` to avoid collisions
// (chapter_number repeats across parts in the source data).
type ChapterIdMap = Map<string, ChapterRecord>;

// Marker prefixes for synthetic ids used during a dry-run when no
// real DB row exists yet. Lets downstream importers skip queries
// they know would return nothing.
const DRY_PART_PREFIX = 'dry-part-';
const DRY_CHAPTER_PREFIX = 'dry-chap-';

// ---------------------------------------------------------------------------
// Importer 1: book_parts
// ---------------------------------------------------------------------------
async function importBookParts(supabase: SupabaseClient): Promise<PartIdMap> {
  log('Importing book_parts...');
  const data = loadBookStructure();
  const map: PartIdMap = new Map();

  for (const p of data.parts) {
    const { data: existing, error: fetchErr } = await supabase
      .from('book_parts')
      .select('id')
      .eq('part_number', p.part_number)
      .maybeSingle();
    if (fetchErr) {
      throw new Error(
        `book_parts query (part ${p.part_number}): ${fetchErr.message}`,
      );
    }

    const payload = {
      part_number: p.part_number,
      title: p.title,
      description: p.description ?? null,
      display_order: p.display_order,
      is_exam: p.is_exam ?? false,
      reference_only: p.reference_only ?? false,
      points_to: p.points_to ?? null,
    };

    if (existing) {
      if (!dryRun) {
        const { error } = await supabase
          .from('book_parts')
          .update(payload)
          .eq('id', existing.id);
        if (error) {
          throw new Error(
            `book_parts update (part ${p.part_number}): ${error.message}`,
          );
        }
      }
      summary.book_parts.updated++;
      map.set(p.part_number, existing.id as string);
    } else {
      let newId: string;
      if (!dryRun) {
        const { data: inserted, error } = await supabase
          .from('book_parts')
          .insert(payload)
          .select('id')
          .single();
        if (error || !inserted) {
          throw new Error(
            `book_parts insert (part ${p.part_number}): ${
              error?.message ?? 'no row returned'
            }`,
          );
        }
        newId = inserted.id as string;
      } else {
        newId = `${DRY_PART_PREFIX}${p.part_number}`;
      }
      summary.book_parts.inserted++;
      map.set(p.part_number, newId);
    }
  }

  log(
    `book_parts done — inserted=${summary.book_parts.inserted} ` +
      `updated=${summary.book_parts.updated}`,
  );
  return map;
}

// ---------------------------------------------------------------------------
// Importer 2: chapters (handles both `chapters[]` and `modules[]`
// arrays from book_structure.json)
// ---------------------------------------------------------------------------
async function importChapters(
  supabase: SupabaseClient,
  partMap: PartIdMap,
): Promise<ChapterIdMap> {
  log('Importing chapters...');
  const data = loadBookStructure();
  const chapterMap: ChapterIdMap = new Map();

  for (const p of data.parts) {
    const partId = partMap.get(p.part_number);
    if (!partId) {
      throw new Error(`Missing part_id for part ${p.part_number}`);
    }

    interface Item {
      chapter_number: number;
      type: string;
      depth: string | null;
      payload: Record<string, unknown>;
    }
    const items: Item[] = [];

    for (const c of p.chapters ?? []) {
      items.push({
        chapter_number: c.chapter_number,
        type: c.type,
        depth: c.depth ?? null,
        payload: {
          part_id: partId,
          chapter_number: c.chapter_number,
          title: c.title,
          type: c.type,
          depth: c.depth ?? null,
          display_order: c.display_order,
          estimated_read_time_minutes: c.estimated_read_time_minutes ?? null,
          estimated_word_count: c.estimated_word_count ?? null,
          has_quiz: c.has_quiz ?? false,
          extended_section: c.extended_section ?? false,
        },
      });
    }

    for (const m of p.modules ?? []) {
      items.push({
        chapter_number: m.module_number,
        type: 'module',
        depth: null,
        payload: {
          part_id: partId,
          chapter_number: m.module_number,
          title: m.title,
          type: 'module',
          depth: null,
          display_order: m.display_order,
          estimated_read_time_minutes: m.estimated_read_time_minutes ?? null,
          estimated_word_count: m.estimated_word_count ?? null,
          has_quiz: m.has_quiz ?? false,
          extended_section: false,
        },
      });
    }

    for (const item of items) {
      let existingId: string | null = null;

      // Skip the existence query when the parent part is synthetic
      // (dry-run + no parent row in DB). Children can't exist either.
      if (!partId.startsWith(DRY_PART_PREFIX)) {
        const { data: existing, error: fetchErr } = await supabase
          .from('chapters')
          .select('id')
          .eq('part_id', partId)
          .eq('chapter_number', item.chapter_number)
          .maybeSingle();
        if (fetchErr) {
          throw new Error(
            `chapters query (part ${p.part_number}, ch ${item.chapter_number}): ` +
              fetchErr.message,
          );
        }
        existingId = (existing?.id as string | undefined) ?? null;
      }

      const mapKey = `${p.part_number}-${item.chapter_number}`;

      if (existingId) {
        if (!dryRun) {
          const { error } = await supabase
            .from('chapters')
            .update(item.payload)
            .eq('id', existingId);
          if (error) {
            throw new Error(
              `chapters update (part ${p.part_number}, ch ${item.chapter_number}): ` +
                error.message,
            );
          }
        }
        summary.chapters.updated++;
        chapterMap.set(mapKey, {
          id: existingId,
          part_number: p.part_number,
          chapter_number: item.chapter_number,
          type: item.type,
          depth: item.depth,
        });
      } else {
        let newId: string;
        if (!dryRun) {
          const { data: inserted, error } = await supabase
            .from('chapters')
            .insert(item.payload)
            .select('id')
            .single();
          if (error || !inserted) {
            throw new Error(
              `chapters insert (part ${p.part_number}, ch ${item.chapter_number}): ` +
                (error?.message ?? 'no row returned'),
            );
          }
          newId = inserted.id as string;
        } else {
          newId = `${DRY_CHAPTER_PREFIX}${p.part_number}-${item.chapter_number}`;
        }
        summary.chapters.inserted++;
        chapterMap.set(mapKey, {
          id: newId,
          part_number: p.part_number,
          chapter_number: item.chapter_number,
          type: item.type,
          depth: item.depth,
        });
      }
    }
  }

  log(
    `chapters done — inserted=${summary.chapters.inserted} ` +
      `updated=${summary.chapters.updated}`,
  );
  return chapterMap;
}

// ---------------------------------------------------------------------------
// Importer 3: sections
//
// Template-selection rules:
//   Parts 1–2 chapters with depth in {core, secondary} → 27-section
//                                                        template
//   Parts 1–2 chapters with depth='reference'          → no sections
//                                                        (per the
//                                                        section
//                                                        template's
//                                                        own _comment)
//   Part 3 modules                                     → 5-section
//                                                        template
//                                                        (Step 6)
//   Everything else (Parts 4–8 reference rows, the
//   synthesized exam chapter, etc.)                    → no sections
//
// Section idempotency: only INSERT rows for (chapter_id,
// section_number) pairs that don't exist yet. Existing rows are left
// untouched so admin-edited content_markdown is never overwritten.
// ---------------------------------------------------------------------------
async function importSections(
  supabase: SupabaseClient,
  chapterMap: ChapterIdMap,
): Promise<void> {
  log('Importing sections...');
  const data = loadBookStructure();
  const template27 = data.chapter_section_templates.core_chapter_sections;

  for (const ch of Array.from(chapterMap.values())) {
    let template: SectionTemplateJson[] | null = null;

    if (
      (ch.part_number === 1 || ch.part_number === 2) &&
      (ch.depth === 'core' || ch.depth === 'secondary')
    ) {
      template = template27;
    } else if (ch.part_number === 3 && ch.type === 'module') {
      template = MODULE_SECTION_TEMPLATE;
    } else {
      continue;
    }

    const existingNumbers = new Set<string>();
    if (!ch.id.startsWith(DRY_CHAPTER_PREFIX)) {
      const { data: existing, error: fetchErr } = await supabase
        .from('sections')
        .select('section_number')
        .eq('chapter_id', ch.id);
      if (fetchErr) {
        throw new Error(
          `sections query (chapter ${ch.id}): ${fetchErr.message}`,
        );
      }
      for (const row of existing ?? []) {
        const sn = (row as { section_number: string | null }).section_number;
        if (sn != null) existingNumbers.add(sn);
      }
    }

    for (const tmpl of template) {
      if (existingNumbers.has(tmpl.section_number)) {
        summary.sections.skipped++;
        continue;
      }

      const payload = {
        chapter_id: ch.id,
        section_number: tmpl.section_number,
        title: tmpl.title,
        content_markdown: '',
        is_instructor_only: tmpl.is_instructor_only,
        display_order: parseInt(tmpl.section_number, 10),
      };

      if (!dryRun) {
        const { error } = await supabase.from('sections').insert(payload);
        if (error) {
          throw new Error(
            `sections insert (chapter ${ch.id}, section ${tmpl.section_number}): ` +
              error.message,
          );
        }
      }
      summary.sections.inserted++;
    }
  }

  log(
    `sections done — inserted=${summary.sections.inserted} ` +
      `skipped=${summary.sections.skipped}`,
  );
}

// ---------------------------------------------------------------------------
// Summary printing
// ---------------------------------------------------------------------------
function printSummary(): void {
  console.log('');
  console.log('=== IMPORT SUMMARY ===');
  console.log(`Mode: ${dryRun ? 'DRY-RUN (no writes)' : 'LIVE'}`);
  const rows: Array<[string, TableStats]> = [
    ['book_parts', summary.book_parts],
    ['chapters', summary.chapters],
    ['sections', summary.sections],
  ];
  for (const [name, s] of rows) {
    console.log(
      `  ${name.padEnd(20)} inserted=${s.inserted}  ` +
        `updated=${s.updated}  skipped=${s.skipped}`,
    );
  }
  console.log('');
  console.log(
    'Importers still pending in this script: final exam, chapter ' +
      'quizzes, comparison tables, glossary, checklists.',
  );
}

// ---------------------------------------------------------------------------
// Main
// ---------------------------------------------------------------------------
async function main(): Promise<void> {
  console.log(
    `USA Flat Roof Content Import — ${dryRun ? '[DRY-RUN]' : '[LIVE]'}`,
  );

  let supabase: SupabaseClient;
  try {
    supabase = createAdminClient();
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    console.error(`Configuration error: ${msg}`);
    process.exit(1);
  }

  const partMap = await importBookParts(supabase);
  const chapterMap = await importChapters(supabase, partMap);
  await importSections(supabase, chapterMap);

  printSummary();
}

main().catch((err) => {
  console.error('Import failed:', err instanceof Error ? err.message : err);
  process.exit(1);
});
