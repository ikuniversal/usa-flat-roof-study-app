// Reads /content/*.json and emits per-chunk idempotent SQL files. The
// chunks are designed to fit inside one Supabase MCP `apply_migration`
// call each, so the import can be applied entirely through MCP without
// direct egress to *.supabase.co.
//
// Output: supabase/migrations/0003_chunk_*.sql
// Usage:  npx tsx scripts/generate-import-sql.ts
//
// All INSERTs are batched into multi-row VALUES for size efficiency.

import { readFileSync, writeFileSync, mkdirSync } from 'node:fs';
import path from 'node:path';

const CONTENT_DIR = path.resolve(process.cwd(), 'content');
const OUT_DIR = path.resolve(process.cwd(), 'supabase/migrations');

// ---------------------------------------------------------------------------
// Helpers
// ---------------------------------------------------------------------------
function read<T>(name: string): T {
  return JSON.parse(readFileSync(path.join(CONTENT_DIR, name), 'utf8')) as T;
}

function q(s: string | null | undefined): string {
  if (s === null || s === undefined) return 'NULL';
  return `'${String(s).replace(/'/g, "''")}'`;
}

function n(x: number | null | undefined): string {
  if (x === null || x === undefined) return 'NULL';
  return String(x);
}

function b(x: boolean | null | undefined): string {
  if (x === null || x === undefined) return 'NULL';
  return x ? 'TRUE' : 'FALSE';
}

function jsonb(x: unknown): string {
  return `'${JSON.stringify(x).replace(/'/g, "''")}'::jsonb`;
}

const PART_ID = (partNumber: number) =>
  `(SELECT id FROM book_parts WHERE part_number = ${partNumber})`;
const CHAPTER_ID = (partNumber: number, chapterNumber: number) =>
  `(SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id ` +
  `WHERE p.part_number = ${partNumber} AND c.chapter_number = ${chapterNumber})`;
const QUIZ_ID_FOR_CHAPTER = (partNumber: number, chapterNumber: number) =>
  `(SELECT q.id FROM quizzes q JOIN chapters c ON q.chapter_id = c.id ` +
  `JOIN book_parts p ON c.part_id = p.id ` +
  `WHERE p.part_number = ${partNumber} AND c.chapter_number = ${chapterNumber})`;
const QSEC_ID = (partNumber: number, chapterNumber: number, secNum: number) =>
  `(SELECT qs.id FROM quiz_sections qs ` +
  `WHERE qs.quiz_id = ${QUIZ_ID_FOR_CHAPTER(partNumber, chapterNumber)} ` +
  `AND qs.section_number = ${secNum})`;
const QUESTION_ID = (
  partNumber: number,
  chapterNumber: number,
  questionNumber: number,
) =>
  `(SELECT qq.id FROM quiz_questions qq ` +
  `WHERE qq.quiz_id = ${QUIZ_ID_FOR_CHAPTER(partNumber, chapterNumber)} ` +
  `AND qq.question_number = ${questionNumber})`;

// Emits a single multi-row INSERT in batches of `batchSize` rows.
function bulkInsert(
  table: string,
  columns: string[],
  rows: string[],
  conflictClause: string,
  batchSize = 25,
): string[] {
  if (rows.length === 0) return [];
  const out: string[] = [];
  for (let i = 0; i < rows.length; i += batchSize) {
    const slice = rows.slice(i, i + batchSize);
    out.push(
      `INSERT INTO ${table} (${columns.join(', ')}) VALUES\n  ${slice.join(',\n  ')}\n${conflictClause};`,
    );
  }
  return out;
}

// ---------------------------------------------------------------------------
// JSON shape types
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
  parts: PartJson[];
  chapter_section_templates: { core_chapter_sections: SectionTemplateJson[] };
}
interface FinalExamAnswerJson {
  letter: 'A' | 'B' | 'C' | 'D';
  text: string;
  is_correct: boolean;
  explanation?: string;
}
interface FinalExamQuestionJson {
  question_number: number;
  question_text: string;
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
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
    passing_score_percent?: number;
    question_count?: number;
    retake_cooldown_hours?: number;
    total_questions?: number;
  };
  sections: FinalExamSectionJson[];
}
interface ChapterQuizCompactAnswer {
  l: 'A' | 'B' | 'C' | 'D';
  t: string;
  c: boolean;
  e?: string;
}
interface ChapterQuizCompactQuestion {
  q: number;
  text: string;
  difficulty?: 'beginner' | 'intermediate' | 'advanced';
  answers: ChapterQuizCompactAnswer[];
}
interface ChapterQuizJson {
  chapter_number: number;
  chapter_title?: string;
  questions: ChapterQuizCompactQuestion[];
}
interface ChapterQuizzesFile {
  quizzes: ChapterQuizJson[];
}
interface ComparisonTableJson {
  table_number: number;
  title: string;
  description?: string;
  columns: { key: string; label: string }[];
  rows: Record<string, string>[];
  footnote?: string;
  [extra: string]: unknown;
}
interface ComparisonTablesFile {
  tables: ComparisonTableJson[];
}
interface GlossaryTermJson {
  term: string;
  definition: string;
  references?: string[];
}
interface GlossaryFile {
  terms: GlossaryTermJson[];
}
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
interface ChecklistsFile {
  checklists: ChecklistJson[];
}

const MODULE_SECTION_TEMPLATE: SectionTemplateJson[] = [
  { section_number: '1', title: 'Learning Objectives', is_instructor_only: false },
  { section_number: '2', title: 'Core Content', is_instructor_only: false },
  { section_number: '3', title: 'Examples', is_instructor_only: false },
  { section_number: '4', title: 'Common Mistakes', is_instructor_only: false },
  { section_number: '5', title: 'Quick Reference Summary', is_instructor_only: false },
];

// ---------------------------------------------------------------------------
// Build per-chunk SQL
// ---------------------------------------------------------------------------
const book = read<BookStructureJson>('01_book_structure.json');
const finalExam = read<FinalExamJson>('02_final_exam.json');
const chapterQuizzes = read<ChapterQuizzesFile>('03_chapter_quizzes.json');
const compTables = read<ComparisonTablesFile>('04_comparison_tables.json');
const glossary = read<GlossaryFile>('05_glossary.json');
const checklists = read<ChecklistsFile>('06_inspection_checklists.json');

// -- Chunk B: sections (compact SELECT-FROM-VALUES form)
// Each row in VALUES is (part_num, chap_num, section_number, title, instr, ord).
const sectionValueRows: string[] = [];
const template27 = book.chapter_section_templates.core_chapter_sections;
for (const p of book.parts) {
  if (p.part_number === 1 || p.part_number === 2) {
    for (const c of p.chapters ?? []) {
      if (c.depth !== 'core' && c.depth !== 'secondary') continue;
      for (const t of template27) {
        sectionValueRows.push(
          `(${p.part_number}, ${c.chapter_number}, ${q(t.section_number)}, ${q(t.title)}, ${b(t.is_instructor_only)}, ${parseInt(t.section_number, 10)})`,
        );
      }
    }
  }
  if (p.part_number === 3) {
    for (const m of p.modules ?? []) {
      for (const t of MODULE_SECTION_TEMPLATE) {
        sectionValueRows.push(
          `(3, ${m.module_number}, ${q(t.section_number)}, ${q(t.title)}, ${b(t.is_instructor_only)}, ${parseInt(t.section_number, 10)})`,
        );
      }
    }
  }
}
function sectionsFromValuesInsert(rows: string[]): string {
  return `INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order)
SELECT c.id, v.section_number, v.title, '', v.is_instructor_only, v.display_order
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(part_num, chap_num, section_number, title, is_instructor_only, display_order)
JOIN book_parts p ON p.part_number = v.part_num
JOIN chapters c ON c.part_id = p.id AND c.chapter_number = v.chap_num
ON CONFLICT (chapter_id, section_number) DO NOTHING;`;
}
const chunkB = ['-- Chunk B: sections (compact SELECT-FROM-VALUES form)', 'BEGIN;'];
const SECTIONS_BATCH = 100;
for (let i = 0; i < sectionValueRows.length; i += SECTIONS_BATCH) {
  chunkB.push(sectionsFromValuesInsert(sectionValueRows.slice(i, i + SECTIONS_BATCH)));
}
chunkB.push('COMMIT;');

// -- Chunk C: final exam (quiz + sections + questions + answers).
// Uses SELECT-FROM-VALUES-JOIN for compact SQL.
const fePass = finalExam.metadata.passing_score_percent ?? 80;
const feCount =
  finalExam.metadata.question_count ?? finalExam.metadata.total_questions ?? 100;
const feCooldown = finalExam.metadata.retake_cooldown_hours ?? 24;

const chunkC: string[] = [
  '-- Chunk C: final exam quiz + sections + questions + answers',
  'BEGIN;',
  // Final exam quiz row
  `INSERT INTO quizzes (chapter_id, title, passing_score_percent, question_count, is_final_exam, retake_cooldown_hours, allow_section_review)
VALUES (${CHAPTER_ID(7, 1)}, 'Final Comprehensive Exam', ${fePass}, ${feCount}, TRUE, ${feCooldown}, TRUE)
ON CONFLICT (chapter_id) DO UPDATE SET
  title = EXCLUDED.title,
  passing_score_percent = EXCLUDED.passing_score_percent,
  question_count = EXCLUDED.question_count,
  is_final_exam = EXCLUDED.is_final_exam,
  retake_cooldown_hours = EXCLUDED.retake_cooldown_hours,
  allow_section_review = EXCLUDED.allow_section_review;`,
];

// quiz_sections (compact form: join via the final-exam quiz)
const feQsRows = finalExam.sections.map(
  (s) =>
    `(${s.section_number}, ${q(s.title)}, ${s.question_count})`,
);
function feQsInsert(rows: string[]): string {
  return `INSERT INTO quiz_sections (quiz_id, section_number, title, question_count, display_order)
SELECT q.id, v.section_number, v.title, v.question_count, v.section_number
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(section_number, title, question_count)
JOIN quizzes q ON q.is_final_exam = TRUE
ON CONFLICT ON CONSTRAINT quiz_sections_quiz_id_section_number_key DO UPDATE SET
  title = EXCLUDED.title,
  question_count = EXCLUDED.question_count,
  display_order = EXCLUDED.display_order;`;
}
chunkC.push(feQsInsert(feQsRows));

// quiz_questions (compact: join via final-exam quiz + quiz_section)
const feQRows: string[] = [];
for (const s of finalExam.sections) {
  for (const ques of s.questions) {
    feQRows.push(
      `(${s.section_number}, ${ques.question_number}, ${q(ques.question_text)}, ${q(ques.difficulty ?? null)})`,
    );
  }
}
function feQuestionsInsert(rows: string[]): string {
  return `INSERT INTO quiz_questions (quiz_id, quiz_section_id, question_number, question_text, difficulty, display_order)
SELECT q.id, qs.id, v.question_number, v.question_text, v.difficulty, v.question_number
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(section_number, question_number, question_text, difficulty)
JOIN quizzes q ON q.is_final_exam = TRUE
JOIN quiz_sections qs ON qs.quiz_id = q.id AND qs.section_number = v.section_number
ON CONFLICT ON CONSTRAINT quiz_questions_quiz_id_question_number_key DO UPDATE SET
  quiz_section_id = EXCLUDED.quiz_section_id,
  question_text = EXCLUDED.question_text,
  difficulty = EXCLUDED.difficulty,
  display_order = EXCLUDED.display_order;`;
}
const FE_Q_BATCH = 50;
for (let i = 0; i < feQRows.length; i += FE_Q_BATCH) {
  chunkC.push(feQuestionsInsert(feQRows.slice(i, i + FE_Q_BATCH)));
}

// quiz_answers: clear, then insert with compact join
chunkC.push(
  `DELETE FROM quiz_answers WHERE question_id IN (
  SELECT qq.id FROM quiz_questions qq JOIN quizzes q ON qq.quiz_id = q.id WHERE q.is_final_exam = TRUE
);`,
);
const feARows: string[] = [];
for (const s of finalExam.sections) {
  for (const ques of s.questions) {
    ques.answers.forEach((a, idx) => {
      feARows.push(
        `(${ques.question_number}, ${q(a.letter)}, ${q(a.text)}, ${b(a.is_correct)}, ${q(a.explanation ?? null)}, ${idx + 1})`,
      );
    });
  }
}
function feAnswersInsert(rows: string[]): string {
  return `INSERT INTO quiz_answers (question_id, answer_letter, answer_text, is_correct, explanation, display_order)
SELECT qq.id, v.answer_letter, v.answer_text, v.is_correct, v.explanation, v.display_order
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(question_number, answer_letter, answer_text, is_correct, explanation, display_order)
JOIN quizzes q ON q.is_final_exam = TRUE
JOIN quiz_questions qq ON qq.quiz_id = q.id AND qq.question_number = v.question_number;`;
}
const FE_A_BATCH = 80;
for (let i = 0; i < feARows.length; i += FE_A_BATCH) {
  chunkC.push(feAnswersInsert(feARows.slice(i, i + FE_A_BATCH)));
}
chunkC.push('COMMIT;');

// -- Chunk D: chapter quizzes (Parts 1-2 only)
const chapterPartMap = new Map<number, number>();
for (const p of book.parts) {
  if (p.part_number !== 1 && p.part_number !== 2) continue;
  for (const c of p.chapters ?? []) {
    chapterPartMap.set(c.chapter_number, p.part_number);
  }
}

const chunkD: string[] = [
  '-- Chunk D: chapter quizzes (compact SELECT-FROM-VALUES form)',
  'BEGIN;',
];

// 5a. quizzes: one row per chapter quiz, joined to chapter via (part, chap) VALUES
const cqQuizRows: string[] = [];
const cqQRows: string[] = [];
const cqARows: string[] = [];
for (const cq of chapterQuizzes.quizzes) {
  const partNumber = chapterPartMap.get(cq.chapter_number);
  if (!partNumber) continue;
  const titleSafe = cq.chapter_title ?? `Chapter ${cq.chapter_number}`;
  cqQuizRows.push(
    `(${partNumber}, ${cq.chapter_number}, ${q(`Chapter ${cq.chapter_number} Quiz - ${titleSafe}`)})`,
  );
  for (const ques of cq.questions) {
    cqQRows.push(
      `(${partNumber}, ${cq.chapter_number}, ${ques.q}, ${q(ques.text)}, ${q(ques.difficulty ?? null)})`,
    );
    ques.answers.forEach((a, idx) => {
      cqARows.push(
        `(${partNumber}, ${cq.chapter_number}, ${ques.q}, ${q(a.l)}, ${q(a.t)}, ${b(a.c)}, ${q(a.e ?? null)}, ${idx + 1})`,
      );
    });
  }
}

function cqQuizzesInsert(rows: string[]): string {
  return `INSERT INTO quizzes (chapter_id, title, passing_score_percent, question_count, is_final_exam, retake_cooldown_hours, allow_section_review)
SELECT c.id, v.title, 70, 10, FALSE, 24, TRUE
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(part_num, chap_num, title)
JOIN book_parts p ON p.part_number = v.part_num
JOIN chapters c ON c.part_id = p.id AND c.chapter_number = v.chap_num
ON CONFLICT (chapter_id) DO UPDATE SET
  title = EXCLUDED.title,
  passing_score_percent = EXCLUDED.passing_score_percent,
  question_count = EXCLUDED.question_count,
  is_final_exam = EXCLUDED.is_final_exam,
  retake_cooldown_hours = EXCLUDED.retake_cooldown_hours,
  allow_section_review = EXCLUDED.allow_section_review;`;
}
chunkD.push(cqQuizzesInsert(cqQuizRows));

function cqQuestionsInsert(rows: string[]): string {
  return `INSERT INTO quiz_questions (quiz_id, quiz_section_id, question_number, question_text, difficulty, display_order)
SELECT q.id, NULL, v.question_number, v.question_text, v.difficulty, v.question_number
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(part_num, chap_num, question_number, question_text, difficulty)
JOIN book_parts p ON p.part_number = v.part_num
JOIN chapters c ON c.part_id = p.id AND c.chapter_number = v.chap_num
JOIN quizzes q ON q.chapter_id = c.id AND q.is_final_exam = FALSE
ON CONFLICT ON CONSTRAINT quiz_questions_quiz_id_question_number_key DO UPDATE SET
  question_text = EXCLUDED.question_text,
  difficulty = EXCLUDED.difficulty,
  display_order = EXCLUDED.display_order;`;
}
const CQ_Q_BATCH = 60;
for (let i = 0; i < cqQRows.length; i += CQ_Q_BATCH) {
  chunkD.push(cqQuestionsInsert(cqQRows.slice(i, i + CQ_Q_BATCH)));
}

// Delete answers for chapter quizzes
chunkD.push(
  `DELETE FROM quiz_answers WHERE question_id IN (
  SELECT qq.id FROM quiz_questions qq JOIN quizzes q ON qq.quiz_id = q.id WHERE q.is_final_exam = FALSE
);`,
);

function cqAnswersInsert(rows: string[]): string {
  return `INSERT INTO quiz_answers (question_id, answer_letter, answer_text, is_correct, explanation, display_order)
SELECT qq.id, v.answer_letter, v.answer_text, v.is_correct, v.explanation, v.display_order
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(part_num, chap_num, question_number, answer_letter, answer_text, is_correct, explanation, display_order)
JOIN book_parts p ON p.part_number = v.part_num
JOIN chapters c ON c.part_id = p.id AND c.chapter_number = v.chap_num
JOIN quizzes q ON q.chapter_id = c.id AND q.is_final_exam = FALSE
JOIN quiz_questions qq ON qq.quiz_id = q.id AND qq.question_number = v.question_number;`;
}
const CQ_A_BATCH = 100;
for (let i = 0; i < cqARows.length; i += CQ_A_BATCH) {
  chunkD.push(cqAnswersInsert(cqARows.slice(i, i + CQ_A_BATCH)));
}
chunkD.push('COMMIT;');

// -- Chunk E: comparison_tables, glossary_terms, checklists, checklist_sections
const chunkE: string[] = [
  '-- Chunk E: comparison tables + glossary + checklists',
  'BEGIN;',
];
const KNOWN_COMP_KEYS = new Set([
  'table_number',
  'title',
  'description',
  'columns',
  'rows',
  'footnote',
]);
const compRows = compTables.tables.map((t) => {
  const guidance: Record<string, unknown> = {};
  let hasGuidance = false;
  for (const k of Object.keys(t)) {
    if (!KNOWN_COMP_KEYS.has(k)) {
      guidance[k] = t[k];
      hasGuidance = true;
    }
  }
  return `(${t.table_number}, ${q(t.title)}, ${q(t.description ?? null)}, ${jsonb(t.columns)}, ${jsonb(t.rows)}, ${q(t.footnote ?? null)}, ${hasGuidance ? jsonb(guidance) : 'NULL'}, ${t.table_number})`;
});
chunkE.push(
  ...bulkInsert(
    'comparison_tables',
    [
      'table_number',
      'title',
      'description',
      'columns_json',
      'rows_json',
      'footnote',
      'guidance_json',
      'display_order',
    ],
    compRows,
    `ON CONFLICT (table_number) DO UPDATE SET
  title = EXCLUDED.title,
  description = EXCLUDED.description,
  columns_json = EXCLUDED.columns_json,
  rows_json = EXCLUDED.rows_json,
  footnote = EXCLUDED.footnote,
  guidance_json = EXCLUDED.guidance_json,
  display_order = EXCLUDED.display_order`,
    15,
  ),
);

const glossaryRows = glossary.terms.map(
  (t) => `(${q(t.term)}, ${q(t.definition)}, ${jsonb(t.references ?? [])})`,
);
chunkE.push(
  ...bulkInsert(
    'glossary_terms',
    ['term', 'definition', 'references_json'],
    glossaryRows,
    `ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json`,
    15,
  ),
);

const checklistRows = checklists.checklists.map(
  (c) =>
    `(${c.checklist_number}, ${q(c.title)}, ${q(c.use_when ?? null)}, ${c.checklist_number})`,
);
chunkE.push(
  ...bulkInsert(
    'checklists',
    ['checklist_number', 'title', 'use_when', 'display_order'],
    checklistRows,
    `ON CONFLICT (checklist_number) DO UPDATE SET
  title = EXCLUDED.title,
  use_when = EXCLUDED.use_when,
  display_order = EXCLUDED.display_order`,
  ),
);

// Checklist sections: clear and re-insert via VALUES JOIN (compact)
chunkE.push(
  `DELETE FROM checklist_sections WHERE checklist_id IN (
  SELECT id FROM checklists WHERE checklist_number IN (${checklists.checklists.map((c) => c.checklist_number).join(', ')})
);`,
);
const csRows: string[] = [];
for (const c of checklists.checklists) {
  c.sections.forEach((s, idx) => {
    csRows.push(
      `(${c.checklist_number}, ${q(s.section_title)}, ${jsonb(s.items)}, ${idx + 1})`,
    );
  });
}
function csInsert(rows: string[]): string {
  return `INSERT INTO checklist_sections (checklist_id, section_title, items_json, display_order)
SELECT cl.id, v.section_title, v.items_json, v.display_order
FROM (VALUES
  ${rows.join(',\n  ')}
) AS v(checklist_number, section_title, items_json, display_order)
JOIN checklists cl ON cl.checklist_number = v.checklist_number;`;
}
const CS_BATCH = 30;
for (let i = 0; i < csRows.length; i += CS_BATCH) {
  chunkE.push(csInsert(csRows.slice(i, i + CS_BATCH)));
}
chunkE.push('COMMIT;');

// ---------------------------------------------------------------------------
// Sub-split the larger chunks (C and D) so each file fits comfortably in
// one apply_migration call.
// ---------------------------------------------------------------------------
function splitChunk(name: string, allLines: string[]): Record<string, string[]> {
  // Group statements (SQL between BEGIN; and COMMIT;) into pieces that
  // each fit under MAX_BYTES. Wrap each piece in its own BEGIN/COMMIT.
  const MAX_BYTES = 25 * 1024;
  // Strip BEGIN; and COMMIT; from input
  const inner = allLines.filter((l) => l !== 'BEGIN;' && l !== 'COMMIT;');
  const header = inner[0]?.startsWith('--') ? inner[0] : '';
  const body = header ? inner.slice(1) : inner;

  const subChunks: string[][] = [];
  let current: string[] = [];
  let currentBytes = 0;
  for (const stmt of body) {
    const sz = Buffer.byteLength(stmt, 'utf8');
    if (current.length > 0 && currentBytes + sz > MAX_BYTES) {
      subChunks.push(current);
      current = [];
      currentBytes = 0;
    }
    current.push(stmt);
    currentBytes += sz;
  }
  if (current.length > 0) subChunks.push(current);

  const out: Record<string, string[]> = {};
  if (subChunks.length === 1) {
    out[name] = ['BEGIN;', ...(header ? [header] : []), ...subChunks[0], 'COMMIT;'];
  } else {
    subChunks.forEach((piece, i) => {
      const subName = `${name}_${String(i + 1).padStart(2, '0')}`;
      out[subName] = [
        'BEGIN;',
        ...(header ? [`${header} (part ${i + 1}/${subChunks.length})`] : []),
        ...piece,
        'COMMIT;',
      ];
    });
  }
  return out;
}

// ---------------------------------------------------------------------------
// Write per-chunk files
// ---------------------------------------------------------------------------
mkdirSync(OUT_DIR, { recursive: true });

const allChunks = {
  ...splitChunk('b_sections', chunkB),
  ...splitChunk('c_final_exam', chunkC),
  ...splitChunk('d_chapter_quizzes', chunkD),
  ...splitChunk('e_reference', chunkE),
};

for (const [name, lines] of Object.entries(allChunks)) {
  const filePath = path.join(OUT_DIR, `0003_chunk_${name}.sql`);
  const body = lines.join('\n') + '\n';
  writeFileSync(filePath, body, 'utf8');
  const sizeKB = Math.round(body.length / 1024);
  console.log(`Wrote ${filePath} (${lines.length} stmts, ${sizeKB} KB)`);
}
