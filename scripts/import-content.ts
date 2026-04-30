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
//   quizzes             — upsert by chapter_id (one quiz per chapter,
//                         including the final-exam quiz under the
//                         synthesized Part 7 / chapter 1 row)
//   quiz_sections       — upsert by (quiz_id, section_number)
//                         (used only for the final exam's 7 sections)
//   quiz_questions      — upsert by (quiz_id, question_number)
//   quiz_answers        — delete-and-reinsert per question_id (small
//                         fanout; safer than diffing answer letters)
//   comparison_tables   — upsert by table_number (UNIQUE). Any keys
//                         not in the known set are bundled into
//                         guidance_json.
//   glossary_terms      — bulk upsert with onConflict=term, in
//                         batches of 50. Existing-term names are
//                         pre-queried so insert/update counts stay
//                         accurate.
//   checklists          — upsert by checklist_number (UNIQUE)
//   checklist_sections  — upsert by (checklist_id, display_order)

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

// ----- Final exam (full keys) -----
type Difficulty = 'beginner' | 'intermediate' | 'advanced';
type AnswerLetter = 'A' | 'B' | 'C' | 'D';

interface FinalExamAnswerJson {
  letter: AnswerLetter;
  text: string;
  is_correct: boolean;
  explanation?: string;
}

interface FinalExamQuestionJson {
  question_number: number;
  question_text: string;
  difficulty: Difficulty;
  answers: FinalExamAnswerJson[];
}

interface FinalExamSectionJson {
  section_number: number;
  title: string;
  question_count: number;
  questions: FinalExamQuestionJson[];
}

interface FinalExamJson {
  metadata: {
    passing_score_percent: number;
    total_questions: number;
    section_count: number;
    retake_cooldown_hours: number;
    [k: string]: unknown;
  };
  sections: FinalExamSectionJson[];
}

// ----- Chapter quizzes (abbreviated keys: q/text/l/t/c/e) -----
interface ChapterQuizAnswerJson {
  l: AnswerLetter;
  t: string;
  c: boolean;
  e?: string;
}

interface ChapterQuizQuestionJson {
  q: number;
  text: string;
  difficulty: Difficulty;
  answers: ChapterQuizAnswerJson[];
}

interface ChapterQuizJson {
  chapter_number: number;
  chapter_title: string;
  questions: ChapterQuizQuestionJson[];
}

interface ChapterQuizzesJson {
  metadata: Record<string, unknown>;
  quizzes: ChapterQuizJson[];
}

// ----- Comparison tables -----
interface ComparisonTableColumnJson {
  key: string;
  label: string;
}

// `[extra: string]: unknown` is intentional — any field beyond the
// known set is bundled into guidance_json by importComparisonTables.
interface ComparisonTableJson {
  table_number: number;
  title: string;
  description?: string;
  columns: ComparisonTableColumnJson[];
  rows: Array<Record<string, string>>;
  footnote?: string;
  [extra: string]: unknown;
}

interface ComparisonTablesJson {
  metadata: Record<string, unknown>;
  tables: ComparisonTableJson[];
}

// ----- Glossary -----
interface GlossaryTermJson {
  term: string;
  definition: string;
  references: string[];
}

interface GlossaryJson {
  metadata: Record<string, unknown>;
  terms: GlossaryTermJson[];
}

// ----- Inspection checklists -----
interface ChecklistSectionJson {
  section_title: string;
  items: unknown[];
}

interface ChecklistJson {
  checklist_number: number;
  title: string;
  use_when?: string;
  sections: ChecklistSectionJson[];
}

interface ChecklistsJson {
  metadata: Record<string, unknown>;
  checklists: ChecklistJson[];
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
  final_exam_chapter: TableStats;
  final_exam_quiz: TableStats;
  quiz_sections: TableStats;
  chapter_quizzes: TableStats;
  quiz_questions: TableStats;
  quiz_answers: TableStats;
  comparison_tables: TableStats;
  glossary_terms: TableStats;
  checklists: TableStats;
  checklist_sections: TableStats;
}

const summary: Summary = {
  book_parts: { inserted: 0, updated: 0, skipped: 0 },
  chapters: { inserted: 0, updated: 0, skipped: 0 },
  sections: { inserted: 0, updated: 0, skipped: 0 },
  final_exam_chapter: { inserted: 0, updated: 0, skipped: 0 },
  final_exam_quiz: { inserted: 0, updated: 0, skipped: 0 },
  quiz_sections: { inserted: 0, updated: 0, skipped: 0 },
  chapter_quizzes: { inserted: 0, updated: 0, skipped: 0 },
  quiz_questions: { inserted: 0, updated: 0, skipped: 0 },
  quiz_answers: { inserted: 0, updated: 0, skipped: 0 },
  comparison_tables: { inserted: 0, updated: 0, skipped: 0 },
  glossary_terms: { inserted: 0, updated: 0, skipped: 0 },
  checklists: { inserted: 0, updated: 0, skipped: 0 },
  checklist_sections: { inserted: 0, updated: 0, skipped: 0 },
};

// Expected counts when importing into an empty database. Used by the
// EXPECTED vs ACTUAL block in printSummary. Source-of-truth is the
// JSON files; figures below are the static totals, NOT what dry-run
// will print on a partially-loaded DB (where most rows are updates,
// not inserts).
const EXPECTED: Record<keyof Summary, number> = {
  book_parts: 8,
  chapters: 55, // 10 + 8 (Parts 1,2) + 13 modules (Part 3) + 12 + 9 + 3 (Parts 5,6,8)
  sections: 524, // 9*27 (Part 1 core/secondary) + 8*27 (Part 2) + 13*5 (Part 3 modules)
  final_exam_chapter: 1,
  final_exam_quiz: 1,
  quiz_sections: 7,
  chapter_quizzes: 18,
  quiz_questions: 280, // 100 final + 180 chapter
  quiz_answers: 1120, // 280 * 4
  comparison_tables: 8,
  glossary_terms: 154,
  checklists: 11,
  checklist_sections: 93,
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
const DRY_QUIZ_PREFIX = 'dry-quiz-';
const DRY_QSEC_PREFIX = 'dry-qsec-';
const DRY_QUESTION_PREFIX = 'dry-q-';

// Returns the first ChapterRecord whose chapter_number matches AND
// whose part_number is in `allowedParts`. Returns null if no match.
// Used by importChapterQuizzes to look up a Part 1/2 chapter from
// the chapter quiz JSON's bare chapter_number field.
function findChapterByNumberInParts(
  chapterMap: ChapterIdMap,
  chapterNumber: number,
  allowedParts: number[],
): ChapterRecord | null {
  for (const ch of Array.from(chapterMap.values())) {
    if (
      ch.chapter_number === chapterNumber &&
      allowedParts.includes(ch.part_number)
    ) {
      return ch;
    }
  }
  return null;
}

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
// Importer 4: final exam
//
// Three layers of upsert:
//   1. Synthesize a chapter row under Part 7 with chapter_number=1
//      and type='exam'.
//   2. Upsert a quiz row keyed on that chapter_id with
//      is_final_exam=true.
//   3. For each of the 7 sections in the JSON, upsert a quiz_sections
//      row, then upsert each question, then delete-and-reinsert that
//      question's quiz_answers.
// ---------------------------------------------------------------------------
async function importFinalExam(
  supabase: SupabaseClient,
  partMap: PartIdMap,
): Promise<void> {
  log('Importing final exam...');
  const data = JSON.parse(
    readFileSync(PATHS.finalExam, 'utf8'),
  ) as FinalExamJson;

  // ----- step 1: synthesized exam chapter under Part 7 -----
  const part7Id = partMap.get(7);
  if (!part7Id) {
    throw new Error('importFinalExam: Part 7 not present in partMap');
  }

  const examChapterPayload = {
    part_id: part7Id,
    chapter_number: 1,
    title: 'Final Comprehensive Exam',
    type: 'exam',
    depth: null,
    display_order: 1,
    has_quiz: true,
    extended_section: false,
  };

  let examChapterId: string;
  if (part7Id.startsWith(DRY_PART_PREFIX)) {
    examChapterId = `${DRY_CHAPTER_PREFIX}7-1`;
    summary.final_exam_chapter.inserted++;
  } else {
    const { data: existing, error: fetchErr } = await supabase
      .from('chapters')
      .select('id')
      .eq('part_id', part7Id)
      .eq('chapter_number', 1)
      .maybeSingle();
    if (fetchErr) {
      throw new Error(`final exam chapter query: ${fetchErr.message}`);
    }
    if (existing) {
      if (!dryRun) {
        const { error } = await supabase
          .from('chapters')
          .update(examChapterPayload)
          .eq('id', existing.id);
        if (error) {
          throw new Error(`final exam chapter update: ${error.message}`);
        }
      }
      summary.final_exam_chapter.updated++;
      examChapterId = existing.id as string;
    } else {
      if (!dryRun) {
        const { data: inserted, error } = await supabase
          .from('chapters')
          .insert(examChapterPayload)
          .select('id')
          .single();
        if (error || !inserted) {
          throw new Error(
            `final exam chapter insert: ${error?.message ?? 'no row returned'}`,
          );
        }
        examChapterId = inserted.id as string;
      } else {
        examChapterId = `${DRY_CHAPTER_PREFIX}7-1`;
      }
      summary.final_exam_chapter.inserted++;
    }
  }

  // ----- step 2: final-exam quiz row -----
  const examQuizPayload = {
    chapter_id: examChapterId,
    title: 'Final Comprehensive Exam',
    passing_score_percent: data.metadata.passing_score_percent ?? 80,
    question_count: data.metadata.total_questions ?? 100,
    is_final_exam: true,
    retake_cooldown_hours: data.metadata.retake_cooldown_hours ?? 24,
    allow_section_review: true,
  };

  let examQuizId: string;
  if (examChapterId.startsWith(DRY_CHAPTER_PREFIX)) {
    examQuizId = `${DRY_QUIZ_PREFIX}final`;
    summary.final_exam_quiz.inserted++;
  } else {
    const { data: existing, error: fetchErr } = await supabase
      .from('quizzes')
      .select('id')
      .eq('chapter_id', examChapterId)
      .maybeSingle();
    if (fetchErr) {
      throw new Error(`final exam quiz query: ${fetchErr.message}`);
    }
    if (existing) {
      if (!dryRun) {
        const { error } = await supabase
          .from('quizzes')
          .update(examQuizPayload)
          .eq('id', existing.id);
        if (error) {
          throw new Error(`final exam quiz update: ${error.message}`);
        }
      }
      summary.final_exam_quiz.updated++;
      examQuizId = existing.id as string;
    } else {
      if (!dryRun) {
        const { data: inserted, error } = await supabase
          .from('quizzes')
          .insert(examQuizPayload)
          .select('id')
          .single();
        if (error || !inserted) {
          throw new Error(
            `final exam quiz insert: ${error?.message ?? 'no row returned'}`,
          );
        }
        examQuizId = inserted.id as string;
      } else {
        examQuizId = `${DRY_QUIZ_PREFIX}final`;
      }
      summary.final_exam_quiz.inserted++;
    }
  }

  // ----- step 3: 7 quiz_sections + 100 questions + 400 answers -----
  for (const sec of data.sections) {
    const secPayload = {
      quiz_id: examQuizId,
      section_number: sec.section_number,
      title: sec.title,
      question_count: sec.question_count,
      display_order: sec.section_number,
    };

    let sectionId: string;
    if (examQuizId.startsWith(DRY_QUIZ_PREFIX)) {
      sectionId = `${DRY_QSEC_PREFIX}${sec.section_number}`;
      summary.quiz_sections.inserted++;
    } else {
      const { data: existing, error: fetchErr } = await supabase
        .from('quiz_sections')
        .select('id')
        .eq('quiz_id', examQuizId)
        .eq('section_number', sec.section_number)
        .maybeSingle();
      if (fetchErr) {
        throw new Error(
          `quiz_sections query (sec ${sec.section_number}): ${fetchErr.message}`,
        );
      }
      if (existing) {
        if (!dryRun) {
          const { error } = await supabase
            .from('quiz_sections')
            .update(secPayload)
            .eq('id', existing.id);
          if (error) {
            throw new Error(`quiz_sections update: ${error.message}`);
          }
        }
        summary.quiz_sections.updated++;
        sectionId = existing.id as string;
      } else {
        if (!dryRun) {
          const { data: inserted, error } = await supabase
            .from('quiz_sections')
            .insert(secPayload)
            .select('id')
            .single();
          if (error || !inserted) {
            throw new Error(
              `quiz_sections insert: ${error?.message ?? 'no row returned'}`,
            );
          }
          sectionId = inserted.id as string;
        } else {
          sectionId = `${DRY_QSEC_PREFIX}${sec.section_number}`;
        }
        summary.quiz_sections.inserted++;
      }
    }

    for (const q of sec.questions) {
      const qPayload = {
        quiz_id: examQuizId,
        quiz_section_id: sectionId.startsWith(DRY_QSEC_PREFIX) ? null : sectionId,
        question_number: q.question_number,
        question_text: q.question_text,
        difficulty: q.difficulty,
        display_order: q.question_number,
      };

      let questionId: string;
      if (examQuizId.startsWith(DRY_QUIZ_PREFIX)) {
        questionId = `${DRY_QUESTION_PREFIX}final-${q.question_number}`;
        summary.quiz_questions.inserted++;
      } else {
        const { data: existing, error: fetchErr } = await supabase
          .from('quiz_questions')
          .select('id')
          .eq('quiz_id', examQuizId)
          .eq('question_number', q.question_number)
          .maybeSingle();
        if (fetchErr) {
          throw new Error(
            `quiz_questions query (q ${q.question_number}): ${fetchErr.message}`,
          );
        }
        if (existing) {
          if (!dryRun) {
            const { error } = await supabase
              .from('quiz_questions')
              .update(qPayload)
              .eq('id', existing.id);
            if (error) {
              throw new Error(`quiz_questions update: ${error.message}`);
            }
          }
          summary.quiz_questions.updated++;
          questionId = existing.id as string;
        } else {
          if (!dryRun) {
            const { data: inserted, error } = await supabase
              .from('quiz_questions')
              .insert(qPayload)
              .select('id')
              .single();
            if (error || !inserted) {
              throw new Error(
                `quiz_questions insert: ${error?.message ?? 'no row returned'}`,
              );
            }
            questionId = inserted.id as string;
          } else {
            questionId = `${DRY_QUESTION_PREFIX}final-${q.question_number}`;
          }
          summary.quiz_questions.inserted++;
        }
      }

      // Delete-and-reinsert answers (skipped entirely for synthetic ids).
      if (!questionId.startsWith(DRY_QUESTION_PREFIX) && !dryRun) {
        const { error: delErr } = await supabase
          .from('quiz_answers')
          .delete()
          .eq('question_id', questionId);
        if (delErr) {
          throw new Error(
            `quiz_answers delete (q ${q.question_number}): ${delErr.message}`,
          );
        }
      }

      for (let i = 0; i < q.answers.length; i++) {
        const a = q.answers[i];
        const aPayload = {
          question_id: questionId,
          answer_letter: a.letter,
          answer_text: a.text,
          is_correct: a.is_correct,
          explanation: a.explanation ?? null,
          display_order: i + 1,
        };
        if (!questionId.startsWith(DRY_QUESTION_PREFIX) && !dryRun) {
          const { error } = await supabase
            .from('quiz_answers')
            .insert(aPayload);
          if (error) {
            throw new Error(
              `quiz_answers insert (q ${q.question_number}, ${a.letter}): ${error.message}`,
            );
          }
        }
        summary.quiz_answers.inserted++;
      }
    }
  }

  log(
    `final exam done — chapter=${summary.final_exam_chapter.inserted + summary.final_exam_chapter.updated} ` +
      `quiz=${summary.final_exam_quiz.inserted + summary.final_exam_quiz.updated} ` +
      `quiz_sections=${summary.quiz_sections.inserted + summary.quiz_sections.updated} ` +
      `questions=${summary.quiz_questions.inserted + summary.quiz_questions.updated} ` +
      `answers=${summary.quiz_answers.inserted}`,
  );
}

// ---------------------------------------------------------------------------
// Importer 5: chapter quizzes (one per chapter in Parts 1–2)
//
// JSON uses abbreviated keys: q/text/difficulty + answers[].l/t/c/e.
// Maps to the same database rows as the final-exam importer.
// quiz_section_id is null for chapter quizzes (no sections).
// ---------------------------------------------------------------------------
async function importChapterQuizzes(
  supabase: SupabaseClient,
  chapterMap: ChapterIdMap,
): Promise<void> {
  log('Importing chapter quizzes...');
  const data = JSON.parse(
    readFileSync(PATHS.chapterQuizzes, 'utf8'),
  ) as ChapterQuizzesJson;

  for (const quiz of data.quizzes) {
    const chapter = findChapterByNumberInParts(
      chapterMap,
      quiz.chapter_number,
      [1, 2],
    );
    if (!chapter) {
      console.warn(
        `[WARN] Chapter quiz references chapter_number=${quiz.chapter_number} ` +
          `which is not present in Parts 1–2 of book_structure.json. Skipping.`,
      );
      continue;
    }

    const quizPayload = {
      chapter_id: chapter.id,
      title:
        quiz.chapter_title?.trim()
          ? `Chapter ${quiz.chapter_number} Quiz — ${quiz.chapter_title}`
          : `Chapter ${quiz.chapter_number} Quiz`,
      passing_score_percent: 70,
      question_count: 10,
      is_final_exam: false,
      retake_cooldown_hours: 24,
      allow_section_review: true,
    };

    let quizId: string;
    if (chapter.id.startsWith(DRY_CHAPTER_PREFIX)) {
      quizId = `${DRY_QUIZ_PREFIX}ch-${quiz.chapter_number}`;
      summary.chapter_quizzes.inserted++;
    } else {
      const { data: existing, error: fetchErr } = await supabase
        .from('quizzes')
        .select('id')
        .eq('chapter_id', chapter.id)
        .maybeSingle();
      if (fetchErr) {
        throw new Error(
          `chapter quiz query (ch ${quiz.chapter_number}): ${fetchErr.message}`,
        );
      }
      if (existing) {
        if (!dryRun) {
          const { error } = await supabase
            .from('quizzes')
            .update(quizPayload)
            .eq('id', existing.id);
          if (error) {
            throw new Error(
              `chapter quiz update (ch ${quiz.chapter_number}): ${error.message}`,
            );
          }
        }
        summary.chapter_quizzes.updated++;
        quizId = existing.id as string;
      } else {
        if (!dryRun) {
          const { data: inserted, error } = await supabase
            .from('quizzes')
            .insert(quizPayload)
            .select('id')
            .single();
          if (error || !inserted) {
            throw new Error(
              `chapter quiz insert (ch ${quiz.chapter_number}): ` +
                (error?.message ?? 'no row returned'),
            );
          }
          quizId = inserted.id as string;
        } else {
          quizId = `${DRY_QUIZ_PREFIX}ch-${quiz.chapter_number}`;
        }
        summary.chapter_quizzes.inserted++;
      }
    }

    for (const q of quiz.questions) {
      const qPayload = {
        quiz_id: quizId,
        quiz_section_id: null,
        question_number: q.q,
        question_text: q.text,
        difficulty: q.difficulty,
        display_order: q.q,
      };

      let questionId: string;
      if (quizId.startsWith(DRY_QUIZ_PREFIX)) {
        questionId = `${DRY_QUESTION_PREFIX}ch-${quiz.chapter_number}-${q.q}`;
        summary.quiz_questions.inserted++;
      } else {
        const { data: existing, error: fetchErr } = await supabase
          .from('quiz_questions')
          .select('id')
          .eq('quiz_id', quizId)
          .eq('question_number', q.q)
          .maybeSingle();
        if (fetchErr) {
          throw new Error(
            `chapter quiz_questions query (ch ${quiz.chapter_number}, q ${q.q}): ` +
              fetchErr.message,
          );
        }
        if (existing) {
          if (!dryRun) {
            const { error } = await supabase
              .from('quiz_questions')
              .update(qPayload)
              .eq('id', existing.id);
            if (error) {
              throw new Error(
                `chapter quiz_questions update (ch ${quiz.chapter_number}, q ${q.q}): ` +
                  error.message,
              );
            }
          }
          summary.quiz_questions.updated++;
          questionId = existing.id as string;
        } else {
          if (!dryRun) {
            const { data: inserted, error } = await supabase
              .from('quiz_questions')
              .insert(qPayload)
              .select('id')
              .single();
            if (error || !inserted) {
              throw new Error(
                `chapter quiz_questions insert (ch ${quiz.chapter_number}, q ${q.q}): ` +
                  (error?.message ?? 'no row returned'),
              );
            }
            questionId = inserted.id as string;
          } else {
            questionId = `${DRY_QUESTION_PREFIX}ch-${quiz.chapter_number}-${q.q}`;
          }
          summary.quiz_questions.inserted++;
        }
      }

      if (!questionId.startsWith(DRY_QUESTION_PREFIX) && !dryRun) {
        const { error: delErr } = await supabase
          .from('quiz_answers')
          .delete()
          .eq('question_id', questionId);
        if (delErr) {
          throw new Error(
            `chapter quiz_answers delete (ch ${quiz.chapter_number}, q ${q.q}): ` +
              delErr.message,
          );
        }
      }

      for (let i = 0; i < q.answers.length; i++) {
        const a = q.answers[i];
        const aPayload = {
          question_id: questionId,
          answer_letter: a.l,
          answer_text: a.t,
          is_correct: a.c,
          explanation: a.e ?? null,
          display_order: i + 1,
        };
        if (!questionId.startsWith(DRY_QUESTION_PREFIX) && !dryRun) {
          const { error } = await supabase
            .from('quiz_answers')
            .insert(aPayload);
          if (error) {
            throw new Error(
              `chapter quiz_answers insert (ch ${quiz.chapter_number}, q ${q.q}, ${a.l}): ` +
                error.message,
            );
          }
        }
        summary.quiz_answers.inserted++;
      }
    }
  }

  log(
    `chapter quizzes done — quizzes=${summary.chapter_quizzes.inserted + summary.chapter_quizzes.updated}`,
  );
}

// ---------------------------------------------------------------------------
// Importer 6: comparison tables
//
// Any keys on a table beyond the known set
// {table_number, title, description, columns, rows, footnote} are
// bundled into guidance_json verbatim. This is how the JSON's
// table-specific extras (guidance, patterns_worth_noting,
// disqualifying_conditions_pattern, universal_pattern, pipeline_math)
// reach the database without each one needing its own column.
// ---------------------------------------------------------------------------
const COMPARISON_TABLE_KNOWN_KEYS = new Set([
  'table_number',
  'title',
  'description',
  'columns',
  'rows',
  'footnote',
]);

async function importComparisonTables(supabase: SupabaseClient): Promise<void> {
  log('Importing comparison_tables...');
  const data = JSON.parse(
    readFileSync(PATHS.comparisonTables, 'utf8'),
  ) as ComparisonTablesJson;

  for (const t of data.tables) {
    const extras: Record<string, unknown> = {};
    for (const [k, v] of Object.entries(t)) {
      if (!COMPARISON_TABLE_KNOWN_KEYS.has(k)) {
        extras[k] = v;
      }
    }
    const guidance_json = Object.keys(extras).length > 0 ? extras : null;

    const payload = {
      table_number: t.table_number,
      title: t.title,
      description: t.description ?? null,
      columns_json: t.columns,
      rows_json: t.rows,
      footnote: t.footnote ?? null,
      guidance_json,
      display_order: t.table_number,
    };

    const { data: existing, error: fetchErr } = await supabase
      .from('comparison_tables')
      .select('id')
      .eq('table_number', t.table_number)
      .maybeSingle();
    if (fetchErr) {
      throw new Error(
        `comparison_tables query (table ${t.table_number}): ${fetchErr.message}`,
      );
    }

    if (existing) {
      if (!dryRun) {
        const { error } = await supabase
          .from('comparison_tables')
          .update(payload)
          .eq('id', existing.id);
        if (error) {
          throw new Error(
            `comparison_tables update (table ${t.table_number}): ${error.message}`,
          );
        }
      }
      summary.comparison_tables.updated++;
    } else {
      if (!dryRun) {
        const { error } = await supabase
          .from('comparison_tables')
          .insert(payload);
        if (error) {
          throw new Error(
            `comparison_tables insert (table ${t.table_number}): ${error.message}`,
          );
        }
      }
      summary.comparison_tables.inserted++;
    }
  }

  log(
    `comparison_tables done — inserted=${summary.comparison_tables.inserted} ` +
      `updated=${summary.comparison_tables.updated}`,
  );
}

// ---------------------------------------------------------------------------
// Importer 7: glossary
//
// 154 terms — uses a single SELECT to know which terms already exist,
// then bulk-upserts in batches of 50 (Supabase's PostgREST handles
// upsert with onConflict natively). Counts are derived from the
// pre-query, not the upsert response, so insert/update tracking is
// accurate.
// ---------------------------------------------------------------------------
const GLOSSARY_BATCH_SIZE = 50;

async function importGlossary(supabase: SupabaseClient): Promise<void> {
  log('Importing glossary_terms...');
  const data = JSON.parse(
    readFileSync(PATHS.glossary, 'utf8'),
  ) as GlossaryJson;

  // Pre-query existing term names to classify each row insert/update.
  const existingTerms = new Set<string>();
  {
    const { data: existing, error: fetchErr } = await supabase
      .from('glossary_terms')
      .select('term');
    if (fetchErr) {
      throw new Error(`glossary pre-query: ${fetchErr.message}`);
    }
    for (const row of existing ?? []) {
      const t = (row as { term: string | null }).term;
      if (t) existingTerms.add(t);
    }
  }

  const rows = data.terms.map((g) => ({
    term: g.term,
    definition: g.definition,
    references_json: g.references,
  }));

  for (const r of rows) {
    if (existingTerms.has(r.term)) {
      summary.glossary_terms.updated++;
    } else {
      summary.glossary_terms.inserted++;
    }
  }

  if (!dryRun) {
    for (let i = 0; i < rows.length; i += GLOSSARY_BATCH_SIZE) {
      const batch = rows.slice(i, i + GLOSSARY_BATCH_SIZE);
      const { error } = await supabase
        .from('glossary_terms')
        .upsert(batch, { onConflict: 'term' });
      if (error) {
        throw new Error(
          `glossary upsert (batch starting at ${i}): ${error.message}`,
        );
      }
    }
  }

  log(
    `glossary_terms done — inserted=${summary.glossary_terms.inserted} ` +
      `updated=${summary.glossary_terms.updated}`,
  );
}

// ---------------------------------------------------------------------------
// Importer 8: inspection checklists
//
// Two tables: `checklists` (one row per checklist, keyed by
// checklist_number) and `checklist_sections` (one row per section
// within a checklist, keyed by (checklist_id, display_order)).
// items_json carries each section's rich item structure verbatim.
// ---------------------------------------------------------------------------
async function importChecklists(supabase: SupabaseClient): Promise<void> {
  log('Importing checklists...');
  const data = JSON.parse(
    readFileSync(PATHS.checklists, 'utf8'),
  ) as ChecklistsJson;

  for (const cl of data.checklists) {
    const checklistPayload = {
      checklist_number: cl.checklist_number,
      title: cl.title,
      use_when: cl.use_when ?? null,
      display_order: cl.checklist_number,
    };

    let checklistId: string;
    const { data: existing, error: fetchErr } = await supabase
      .from('checklists')
      .select('id')
      .eq('checklist_number', cl.checklist_number)
      .maybeSingle();
    if (fetchErr) {
      throw new Error(
        `checklists query (checklist ${cl.checklist_number}): ${fetchErr.message}`,
      );
    }

    if (existing) {
      if (!dryRun) {
        const { error } = await supabase
          .from('checklists')
          .update(checklistPayload)
          .eq('id', existing.id);
        if (error) {
          throw new Error(
            `checklists update (checklist ${cl.checklist_number}): ${error.message}`,
          );
        }
      }
      summary.checklists.updated++;
      checklistId = existing.id as string;
    } else {
      if (!dryRun) {
        const { data: inserted, error } = await supabase
          .from('checklists')
          .insert(checklistPayload)
          .select('id')
          .single();
        if (error || !inserted) {
          throw new Error(
            `checklists insert (checklist ${cl.checklist_number}): ` +
              (error?.message ?? 'no row returned'),
          );
        }
        checklistId = inserted.id as string;
      } else {
        checklistId = `dry-checklist-${cl.checklist_number}`;
      }
      summary.checklists.inserted++;
    }

    for (let i = 0; i < cl.sections.length; i++) {
      const sec = cl.sections[i];
      const display_order = i + 1;
      const secPayload = {
        checklist_id: checklistId,
        section_title: sec.section_title,
        display_order,
        items_json: sec.items,
      };

      if (checklistId.startsWith('dry-checklist-')) {
        summary.checklist_sections.inserted++;
        continue;
      }

      const { data: existingSec, error: secFetchErr } = await supabase
        .from('checklist_sections')
        .select('id')
        .eq('checklist_id', checklistId)
        .eq('display_order', display_order)
        .maybeSingle();
      if (secFetchErr) {
        throw new Error(
          `checklist_sections query (checklist ${cl.checklist_number}, ` +
            `display_order ${display_order}): ${secFetchErr.message}`,
        );
      }

      if (existingSec) {
        if (!dryRun) {
          const { error } = await supabase
            .from('checklist_sections')
            .update(secPayload)
            .eq('id', existingSec.id);
          if (error) {
            throw new Error(
              `checklist_sections update (checklist ${cl.checklist_number}, ` +
                `display_order ${display_order}): ${error.message}`,
            );
          }
        }
        summary.checklist_sections.updated++;
      } else {
        if (!dryRun) {
          const { error } = await supabase
            .from('checklist_sections')
            .insert(secPayload);
          if (error) {
            throw new Error(
              `checklist_sections insert (checklist ${cl.checklist_number}, ` +
                `display_order ${display_order}): ${error.message}`,
            );
          }
        }
        summary.checklist_sections.inserted++;
      }
    }
  }

  log(
    `checklists done — checklists=${
      summary.checklists.inserted + summary.checklists.updated
    } sections=${
      summary.checklist_sections.inserted + summary.checklist_sections.updated
    }`,
  );
}

// ---------------------------------------------------------------------------
// Summary printing
// ---------------------------------------------------------------------------
function printSummary(): void {
  console.log('');
  console.log('=== IMPORT SUMMARY ===');
  console.log(`Mode: ${dryRun ? 'DRY-RUN (no writes)' : 'LIVE'}`);
  const rows: Array<[keyof Summary, TableStats]> = [
    ['book_parts', summary.book_parts],
    ['chapters', summary.chapters],
    ['sections', summary.sections],
    ['final_exam_chapter', summary.final_exam_chapter],
    ['final_exam_quiz', summary.final_exam_quiz],
    ['quiz_sections', summary.quiz_sections],
    ['chapter_quizzes', summary.chapter_quizzes],
    ['quiz_questions', summary.quiz_questions],
    ['quiz_answers', summary.quiz_answers],
    ['comparison_tables', summary.comparison_tables],
    ['glossary_terms', summary.glossary_terms],
    ['checklists', summary.checklists],
    ['checklist_sections', summary.checklist_sections],
  ];
  for (const [name, s] of rows) {
    console.log(
      `  ${name.padEnd(20)} inserted=${s.inserted}  ` +
        `updated=${s.updated}  skipped=${s.skipped}`,
    );
  }

  // EXPECTED vs ACTUAL — actual = inserted+updated+skipped, which
  // should equal the number of rows in each JSON source when the
  // importer is run against a target DB (empty or already-loaded).
  console.log('');
  console.log('=== EXPECTED vs ACTUAL (inserted + updated + skipped) ===');
  let allMatch = true;
  for (const [name] of rows) {
    const stats = summary[name];
    const actual = stats.inserted + stats.updated + stats.skipped;
    const expected = EXPECTED[name];
    const match = actual === expected;
    if (!match) allMatch = false;
    const flag = match ? 'OK ' : 'MISMATCH';
    console.log(
      `  ${flag}  ${name.padEnd(20)} expected=${String(expected).padEnd(5)} actual=${actual}`,
    );
  }
  console.log('');
  console.log(allMatch ? 'All counts match expected.' : 'WARNING: counts do not match expected. Investigate before live import.');
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
  await importFinalExam(supabase, partMap);
  await importChapterQuizzes(supabase, chapterMap);
  await importComparisonTables(supabase);
  await importGlossary(supabase);
  await importChecklists(supabase);

  printSummary();
}

main().catch((err) => {
  console.error('Import failed:', err instanceof Error ? err.message : err);
  process.exit(1);
});
