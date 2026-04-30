// TypeScript interfaces for the USA Flat Roof study app database schema.
// Source of truth: content/07_supabase_seed.sql.
//
// Column → TS mapping:
//   UUID, TEXT       → string
//   INTEGER, NUMERIC → number
//   BOOLEAN          → boolean
//   TIMESTAMP, DATE  → string (ISO 8601, returned as ISO from PostgREST)
//   JSONB            → typed where shape is known, otherwise `unknown`
//
// Nullability follows the SQL:
//   NOT NULL           → required, non-nullable
//   nullable / no NN   → `T | null`
//   has DEFAULT        → required, non-nullable (DB always returns a value)

export type UserRole = 'admin' | 'instructor' | 'sales_rep';

export type ChapterType =
  | 'chapter'
  | 'module'
  | 'reference'
  | 'exam'
  | 'glossary'
  | 'training_path'
  | 'pocket_card';

export type ChapterDepth = 'core' | 'secondary' | 'reference';

export type Difficulty = 'beginner' | 'intermediate' | 'advanced';

export type AnswerLetter = 'A' | 'B' | 'C' | 'D';

export interface Profile {
  id: string;
  email: string;
  full_name: string | null;
  role: UserRole;
  manager_id: string | null;
  hire_date: string | null;
  certified: boolean;
  certification_date: string | null;
  created_at: string;
  updated_at: string;
}

export interface BookPart {
  id: string;
  part_number: number;
  title: string;
  description: string | null;
  display_order: number;
  is_exam: boolean;
  reference_only: boolean;
  points_to: string | null;
  created_at: string;
  updated_at: string;
}

export interface Chapter {
  id: string;
  part_id: string | null;
  chapter_number: number;
  title: string;
  type: ChapterType | null;
  depth: ChapterDepth | null;
  display_order: number;
  estimated_read_time_minutes: number | null;
  estimated_word_count: number | null;
  last_reviewed_date: string | null;
  has_quiz: boolean;
  extended_section: boolean;
  created_at: string;
  updated_at: string;
}

export interface Section {
  id: string;
  chapter_id: string | null;
  section_number: string | null;
  title: string;
  content_markdown: string;
  is_instructor_only: boolean;
  display_order: number;
  created_at: string;
  updated_at: string;
}

export interface Quiz {
  id: string;
  chapter_id: string | null;
  title: string;
  passing_score_percent: number;
  question_count: number;
  is_final_exam: boolean;
  retake_cooldown_hours: number;
  allow_section_review: boolean;
  created_at: string;
  updated_at: string;
}

export interface QuizSection {
  id: string;
  quiz_id: string | null;
  section_number: number;
  title: string;
  question_count: number;
  display_order: number;
}

export interface QuizQuestion {
  id: string;
  quiz_id: string | null;
  quiz_section_id: string | null;
  question_number: number;
  question_text: string;
  difficulty: Difficulty | null;
  display_order: number;
  created_at: string;
  updated_at: string;
}

export interface QuizAnswer {
  id: string;
  question_id: string | null;
  answer_letter: AnswerLetter | null;
  answer_text: string;
  is_correct: boolean;
  explanation: string | null;
  display_order: number;
}

// JSONB shape for comparison_tables.columns_json — see seed sample at
// content/07_supabase_seed.sql line ~688:
//   [{"key": "system", "label": "System"}, ...]
export interface ComparisonTableColumn {
  key: string;
  label: string;
}

// rows_json is an array of objects keyed by the column keys above.
export type ComparisonTableRow = Record<string, string>;

export interface ComparisonTable {
  id: string;
  table_number: number;
  title: string;
  description: string | null;
  columns_json: ComparisonTableColumn[];
  rows_json: ComparisonTableRow[];
  footnote: string | null;
  guidance_json: unknown | null;
  display_order: number;
  created_at: string;
  updated_at: string;
}

export interface GlossaryTerm {
  id: string;
  term: string;
  definition: string;
  // references_json is an array of free-form reference strings, e.g.
  // ["Chapter 1", "Comparison Table 3"].
  references_json: string[];
  created_at: string;
  updated_at: string;
}

export interface Checklist {
  id: string;
  checklist_number: number;
  title: string;
  use_when: string | null;
  display_order: number;
  created_at: string;
  updated_at: string;
}

// items_json shape is determined by the import — typed as unknown[]
// until the JSON files dictate a stricter contract.
export interface ChecklistSection {
  id: string;
  checklist_id: string | null;
  section_title: string;
  display_order: number;
  items_json: unknown[];
}

export interface ReadingProgress {
  id: string;
  user_id: string | null;
  chapter_id: string | null;
  section_id: string | null;
  completed: boolean;
  last_position: number;
  read_at: string | null;
  created_at: string;
  updated_at: string;
}

export interface QuizAttempt {
  id: string;
  user_id: string | null;
  quiz_id: string | null;
  attempt_number: number;
  started_at: string;
  completed_at: string | null;
  score_percent: number | null;
  passed: boolean | null;
  time_spent_seconds: number | null;
  section_scores_json: unknown | null;
  created_at: string;
}

export interface QuizResponse {
  id: string;
  attempt_id: string | null;
  question_id: string | null;
  selected_answer_id: string | null;
  is_correct: boolean | null;
  answered_at: string;
}

export interface Bookmark {
  id: string;
  user_id: string | null;
  section_id: string | null;
  note: string | null;
  created_at: string;
}

// Not in Phase 2's required list but present in the schema —
// added for completeness so admin tooling has a type to lean on.
export interface ContentRevision {
  id: string;
  section_id: string | null;
  edited_by: string | null;
  previous_content: string | null;
  new_content: string | null;
  edit_note: string | null;
  edited_at: string;
}
