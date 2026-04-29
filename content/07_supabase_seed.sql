-- ============================================================================
-- USA Flat Roof — Roof Systems Field Guide Study App
-- Supabase / PostgreSQL Seed File
-- Edition: April 2026
-- ============================================================================
--
-- This file contains:
--   PART 1: Complete database schema (tables, indexes, constraints)
--   PART 2: Row Level Security (RLS) policies
--   PART 3: Helper functions and triggers
--   PART 4: Sample seed data (one part, one chapter, three sections, one quiz)
--          — for testing the import pipeline before running the full import
--
-- Usage:
--   1. Run this file in a fresh Supabase project to set up the schema
--   2. Verify the sample data loads correctly
--   3. Use the JSON files (01_book_structure, 02_final_exam, 03_chapter_quizzes,
--      04_comparison_tables, 05_glossary, 06_inspection_checklists) with the
--      import script in PART 5 of this file to populate the full database
--
-- ============================================================================


-- ============================================================================
-- PART 1: DATABASE SCHEMA
-- ============================================================================

-- Enable required extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ----------------------------------------------------------------------------
-- USERS AND ROLES
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS profiles (
  id UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  email TEXT UNIQUE NOT NULL,
  full_name TEXT,
  role TEXT NOT NULL CHECK (role IN ('admin', 'instructor', 'sales_rep')),
  manager_id UUID REFERENCES profiles(id),
  hire_date DATE,
  certified BOOLEAN DEFAULT FALSE,
  certification_date TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- BOOK STRUCTURE
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS book_parts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  part_number INTEGER UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  display_order INTEGER NOT NULL,
  is_exam BOOLEAN DEFAULT FALSE,
  reference_only BOOLEAN DEFAULT FALSE,
  points_to TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS chapters (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  part_id UUID REFERENCES book_parts(id) ON DELETE CASCADE,
  chapter_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  type TEXT CHECK (type IN ('chapter', 'module', 'reference', 'exam', 'glossary', 'training_path', 'pocket_card')),
  depth TEXT CHECK (depth IN ('core', 'secondary', 'reference')),
  display_order INTEGER NOT NULL,
  estimated_read_time_minutes INTEGER,
  estimated_word_count INTEGER,
  last_reviewed_date DATE DEFAULT '2026-04-01',
  has_quiz BOOLEAN DEFAULT FALSE,
  extended_section BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (part_id, chapter_number)
);

CREATE TABLE IF NOT EXISTS sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  section_number TEXT,
  title TEXT NOT NULL,
  content_markdown TEXT NOT NULL DEFAULT '',
  is_instructor_only BOOLEAN DEFAULT FALSE,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- QUIZZES (chapter-level and final exam)
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS quizzes (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  title TEXT NOT NULL,
  passing_score_percent INTEGER DEFAULT 70,
  question_count INTEGER NOT NULL DEFAULT 10,
  is_final_exam BOOLEAN DEFAULT FALSE,
  retake_cooldown_hours INTEGER DEFAULT 24,
  allow_section_review BOOLEAN DEFAULT TRUE,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quiz_sections (
  -- Used for the final exam's 7 thematic sections
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  section_number INTEGER NOT NULL,
  title TEXT NOT NULL,
  question_count INTEGER NOT NULL,
  display_order INTEGER NOT NULL
);

CREATE TABLE IF NOT EXISTS quiz_questions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  quiz_section_id UUID REFERENCES quiz_sections(id) ON DELETE SET NULL,
  question_number INTEGER NOT NULL,
  question_text TEXT NOT NULL,
  difficulty TEXT CHECK (difficulty IN ('beginner', 'intermediate', 'advanced')),
  display_order INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quiz_answers (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  question_id UUID REFERENCES quiz_questions(id) ON DELETE CASCADE,
  answer_letter TEXT CHECK (answer_letter IN ('A', 'B', 'C', 'D')),
  answer_text TEXT NOT NULL,
  is_correct BOOLEAN NOT NULL DEFAULT FALSE,
  explanation TEXT,
  display_order INTEGER NOT NULL
);

-- ----------------------------------------------------------------------------
-- COMPARISON TABLES
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS comparison_tables (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  table_number INTEGER UNIQUE NOT NULL,
  title TEXT NOT NULL,
  description TEXT,
  columns_json JSONB NOT NULL,
  rows_json JSONB NOT NULL,
  footnote TEXT,
  guidance_json JSONB,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- GLOSSARY
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS glossary_terms (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  term TEXT UNIQUE NOT NULL,
  definition TEXT NOT NULL,
  references_json JSONB DEFAULT '[]'::jsonb,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX IF NOT EXISTS idx_glossary_term_lower ON glossary_terms(LOWER(term));

-- ----------------------------------------------------------------------------
-- INSPECTION CHECKLISTS
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS checklists (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  checklist_number INTEGER UNIQUE NOT NULL,
  title TEXT NOT NULL,
  use_when TEXT,
  display_order INTEGER NOT NULL,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS checklist_sections (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  checklist_id UUID REFERENCES checklists(id) ON DELETE CASCADE,
  section_title TEXT NOT NULL,
  display_order INTEGER NOT NULL,
  items_json JSONB NOT NULL DEFAULT '[]'::jsonb
);

-- ----------------------------------------------------------------------------
-- USER PROGRESS AND ATTEMPTS
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS reading_progress (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  chapter_id UUID REFERENCES chapters(id) ON DELETE CASCADE,
  section_id UUID REFERENCES sections(id) ON DELETE CASCADE,
  completed BOOLEAN DEFAULT FALSE,
  last_position INTEGER DEFAULT 0,
  read_at TIMESTAMP,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_id, section_id)
);

CREATE TABLE IF NOT EXISTS quiz_attempts (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  quiz_id UUID REFERENCES quizzes(id) ON DELETE CASCADE,
  attempt_number INTEGER NOT NULL,
  started_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  score_percent NUMERIC(5,2),
  passed BOOLEAN,
  time_spent_seconds INTEGER,
  section_scores_json JSONB,
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE IF NOT EXISTS quiz_responses (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  attempt_id UUID REFERENCES quiz_attempts(id) ON DELETE CASCADE,
  question_id UUID REFERENCES quiz_questions(id),
  selected_answer_id UUID REFERENCES quiz_answers(id),
  is_correct BOOLEAN,
  answered_at TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- BOOKMARKS AND NOTES
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS bookmarks (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES profiles(id) ON DELETE CASCADE,
  section_id UUID REFERENCES sections(id) ON DELETE CASCADE,
  note TEXT,
  created_at TIMESTAMP DEFAULT NOW(),
  UNIQUE (user_id, section_id)
);

-- ----------------------------------------------------------------------------
-- ADMIN: CONTENT EDIT HISTORY
-- ----------------------------------------------------------------------------

CREATE TABLE IF NOT EXISTS content_revisions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  section_id UUID REFERENCES sections(id) ON DELETE CASCADE,
  edited_by UUID REFERENCES profiles(id),
  previous_content TEXT,
  new_content TEXT,
  edit_note TEXT,
  edited_at TIMESTAMP DEFAULT NOW()
);

-- ----------------------------------------------------------------------------
-- INDEXES
-- ----------------------------------------------------------------------------

CREATE INDEX IF NOT EXISTS idx_sections_chapter ON sections(chapter_id);
CREATE INDEX IF NOT EXISTS idx_chapters_part ON chapters(part_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_quiz ON quiz_questions(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_questions_section ON quiz_questions(quiz_section_id);
CREATE INDEX IF NOT EXISTS idx_quiz_answers_question ON quiz_answers(question_id);
CREATE INDEX IF NOT EXISTS idx_reading_progress_user ON reading_progress(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_user ON quiz_attempts(user_id);
CREATE INDEX IF NOT EXISTS idx_quiz_attempts_quiz ON quiz_attempts(quiz_id);
CREATE INDEX IF NOT EXISTS idx_quiz_responses_attempt ON quiz_responses(attempt_id);
CREATE INDEX IF NOT EXISTS idx_bookmarks_user ON bookmarks(user_id);
CREATE INDEX IF NOT EXISTS idx_checklist_sections_checklist ON checklist_sections(checklist_id);


-- ============================================================================
-- PART 2: ROW LEVEL SECURITY (RLS) POLICIES
-- ============================================================================

-- Enable RLS on all tables
ALTER TABLE profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE book_parts ENABLE ROW LEVEL SECURITY;
ALTER TABLE chapters ENABLE ROW LEVEL SECURITY;
ALTER TABLE sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE quizzes ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_questions ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_answers ENABLE ROW LEVEL SECURITY;
ALTER TABLE comparison_tables ENABLE ROW LEVEL SECURITY;
ALTER TABLE glossary_terms ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklists ENABLE ROW LEVEL SECURITY;
ALTER TABLE checklist_sections ENABLE ROW LEVEL SECURITY;
ALTER TABLE reading_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_attempts ENABLE ROW LEVEL SECURITY;
ALTER TABLE quiz_responses ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;
ALTER TABLE content_revisions ENABLE ROW LEVEL SECURITY;

-- ----------------------------------------------------------------------------
-- PROFILES POLICIES
-- ----------------------------------------------------------------------------

CREATE POLICY "Users can view own profile" ON profiles
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON profiles
  FOR UPDATE USING (auth.uid() = id);

CREATE POLICY "Admins can view all profiles" ON profiles
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins can manage all profiles" ON profiles
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Instructors can view their assigned reps" ON profiles
  FOR SELECT USING (manager_id = auth.uid());

-- ----------------------------------------------------------------------------
-- BOOK CONTENT POLICIES
-- ----------------------------------------------------------------------------

CREATE POLICY "Authenticated users read book parts" ON book_parts
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users read chapters" ON chapters
  FOR SELECT USING (auth.role() = 'authenticated');

-- Sales reps see only non-instructor content; admins/instructors see all
CREATE POLICY "Authenticated users read appropriate sections" ON sections
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      is_instructor_only = FALSE
      OR EXISTS (
        SELECT 1 FROM profiles
        WHERE id = auth.uid() AND role IN ('admin', 'instructor')
      )
    )
  );

-- Admins can edit content
CREATE POLICY "Admins manage book parts" ON book_parts
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage chapters" ON chapters
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage sections" ON sections
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ----------------------------------------------------------------------------
-- QUIZZES POLICIES
-- ----------------------------------------------------------------------------

CREATE POLICY "Authenticated users read quizzes" ON quizzes
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users read quiz sections" ON quiz_sections
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users read quiz questions" ON quiz_questions
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users read quiz answers" ON quiz_answers
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins manage quizzes" ON quizzes
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage quiz sections" ON quiz_sections
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage quiz questions" ON quiz_questions
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage quiz answers" ON quiz_answers
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ----------------------------------------------------------------------------
-- COMPARISON TABLES, GLOSSARY, CHECKLISTS POLICIES
-- ----------------------------------------------------------------------------

CREATE POLICY "Authenticated users read comparison tables" ON comparison_tables
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins manage comparison tables" ON comparison_tables
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Authenticated users read glossary" ON glossary_terms
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins manage glossary" ON glossary_terms
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Authenticated users read checklists" ON checklists
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Authenticated users read checklist sections" ON checklist_sections
  FOR SELECT USING (auth.role() = 'authenticated');

CREATE POLICY "Admins manage checklists" ON checklists
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins manage checklist sections" ON checklist_sections
  FOR ALL USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

-- ----------------------------------------------------------------------------
-- USER PROGRESS POLICIES
-- ----------------------------------------------------------------------------

CREATE POLICY "Users manage own reading progress" ON reading_progress
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Admins view all reading progress" ON reading_progress
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Instructors view assigned reps progress" ON reading_progress
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = reading_progress.user_id AND manager_id = auth.uid()
    )
  );

CREATE POLICY "Users view own attempts" ON quiz_attempts
  FOR SELECT USING (user_id = auth.uid());

CREATE POLICY "Users create own attempts" ON quiz_attempts
  FOR INSERT WITH CHECK (user_id = auth.uid());

CREATE POLICY "Users update own attempts" ON quiz_attempts
  FOR UPDATE USING (user_id = auth.uid());

CREATE POLICY "Admins view all attempts" ON quiz_attempts
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Instructors view assigned reps attempts" ON quiz_attempts
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM profiles
      WHERE id = quiz_attempts.user_id AND manager_id = auth.uid()
    )
  );

CREATE POLICY "Users manage own quiz responses" ON quiz_responses
  FOR ALL USING (
    EXISTS (SELECT 1 FROM quiz_attempts WHERE id = quiz_responses.attempt_id AND user_id = auth.uid())
  );

CREATE POLICY "Admins view all quiz responses" ON quiz_responses
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Users manage own bookmarks" ON bookmarks
  FOR ALL USING (user_id = auth.uid());

CREATE POLICY "Admins view content revisions" ON content_revisions
  FOR SELECT USING (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );

CREATE POLICY "Admins create content revisions" ON content_revisions
  FOR INSERT WITH CHECK (
    EXISTS (SELECT 1 FROM profiles WHERE id = auth.uid() AND role = 'admin')
  );


-- ============================================================================
-- PART 3: HELPER FUNCTIONS AND TRIGGERS
-- ============================================================================

-- Auto-update timestamp trigger function
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to all tables with updated_at
CREATE TRIGGER trg_profiles_updated BEFORE UPDATE ON profiles
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_book_parts_updated BEFORE UPDATE ON book_parts
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_chapters_updated BEFORE UPDATE ON chapters
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_sections_updated BEFORE UPDATE ON sections
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_quizzes_updated BEFORE UPDATE ON quizzes
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();
CREATE TRIGGER trg_glossary_terms_updated BEFORE UPDATE ON glossary_terms
  FOR EACH ROW EXECUTE FUNCTION update_updated_at();

-- Auto-create profile when user signs up
CREATE OR REPLACE FUNCTION handle_new_user()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO profiles (id, email, full_name, role)
  VALUES (
    NEW.id,
    NEW.email,
    COALESCE(NEW.raw_user_meta_data->>'full_name', ''),
    'sales_rep'  -- Default role; admin can change
  );
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION handle_new_user();

-- Function: get user's most recent attempt for a quiz
CREATE OR REPLACE FUNCTION get_latest_attempt(p_user_id UUID, p_quiz_id UUID)
RETURNS quiz_attempts AS $$
DECLARE
  result quiz_attempts;
BEGIN
  SELECT * INTO result FROM quiz_attempts
  WHERE user_id = p_user_id AND quiz_id = p_quiz_id
  ORDER BY attempt_number DESC LIMIT 1;
  RETURN result;
END;
$$ LANGUAGE plpgsql;

-- Function: check if user can retake quiz (24-hour cooldown)
CREATE OR REPLACE FUNCTION can_retake_quiz(p_user_id UUID, p_quiz_id UUID)
RETURNS BOOLEAN AS $$
DECLARE
  last_attempt quiz_attempts;
  cooldown_hours INTEGER;
BEGIN
  SELECT retake_cooldown_hours INTO cooldown_hours FROM quizzes WHERE id = p_quiz_id;
  SELECT * INTO last_attempt FROM quiz_attempts
    WHERE user_id = p_user_id AND quiz_id = p_quiz_id
    ORDER BY attempt_number DESC LIMIT 1;

  IF last_attempt IS NULL THEN RETURN TRUE; END IF;
  IF last_attempt.completed_at IS NULL THEN RETURN FALSE; END IF;
  IF last_attempt.passed = TRUE THEN RETURN TRUE; END IF;

  RETURN (NOW() - last_attempt.completed_at) > (cooldown_hours || ' hours')::interval;
END;
$$ LANGUAGE plpgsql;


-- ============================================================================
-- PART 4: SAMPLE SEED DATA
-- (One part, one chapter, three sections, one quiz with two questions)
-- (Use this to verify the import pipeline before running the full import)
-- ============================================================================

-- Sample book part
INSERT INTO book_parts (part_number, title, description, display_order)
VALUES (
  1,
  'Roof Systems',
  'Detailed coverage of every roof system USA Flat Roof works on.',
  1
);

-- Sample chapter (Composition Shingle - Chapter 1)
INSERT INTO chapters (part_id, chapter_number, title, type, depth, display_order, estimated_read_time_minutes, estimated_word_count, has_quiz)
SELECT id, 1, 'Composition Shingle', 'chapter', 'core', 1, 25, 5200, TRUE
FROM book_parts WHERE part_number = 1;

-- Sample sections
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order)
SELECT
  c.id, '1', 'Learning Objectives',
  E'By the end of this chapter, the salesperson should be able to:\n\n1. Recognize composition shingle on sight and distinguish three-tab, architectural, and designer profiles.\n2. Inspect composition shingle for aging signs, granule loss, lifted tabs, and detail failures.\n3. Apply the four-point Inspection Severity Scale to composition shingle conditions.\n4. Recommend repair, rejuvenation, or replacement based on observed condition and age.',
  FALSE, 1
FROM chapters c
WHERE c.chapter_number = 1;

INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order)
SELECT
  c.id, '2', 'What This System Is',
  E'Composition shingle is the most common residential roof system in the United States. It consists of asphalt-based shingles with a mineral granule surface that protects the asphalt from UV degradation.\n\n**Three profile types:**\n\n- **Three-tab shingle** — flat, uniform appearance with cutouts creating three tab segments per shingle.\n- **Architectural (dimensional, laminated) shingle** — two layers bonded together creating a thicker, shadowed, textured appearance.\n- **Designer / luxury shingle** — heavier, multi-layer shingles designed to mimic slate, shake, or other premium materials.',
  FALSE, 2
FROM chapters c
WHERE c.chapter_number = 1;

INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order)
SELECT
  c.id, '23', 'Instructor Notes',
  E'**What new reps usually misunderstand:**\n- They confuse warranty length with service life.\n- They mistake granule loss as a cosmetic issue rather than aging marker.\n- They quote specific remaining-life numbers when ranges are appropriate.\n\n**Discussion questions:**\n- A homeowner says their shingles are "5-year shingles." How do you respond?\n- A roof shows widespread granule loss. What other indicators would you check?',
  TRUE, 23
FROM chapters c
WHERE c.chapter_number = 1;

-- Sample quiz
INSERT INTO quizzes (chapter_id, title, passing_score_percent, question_count, is_final_exam)
SELECT id, 'Chapter 1 Quiz', 70, 2, FALSE
FROM chapters WHERE chapter_number = 1;

-- Sample quiz question 1
WITH q AS (
  INSERT INTO quiz_questions (quiz_id, question_number, question_text, difficulty, display_order)
  SELECT
    qz.id, 1,
    'The granular surface on a composition shingle is composed of:',
    'beginner', 1
  FROM quizzes qz
  JOIN chapters c ON qz.chapter_id = c.id
  WHERE c.chapter_number = 1
  RETURNING id
)
INSERT INTO quiz_answers (question_id, answer_letter, answer_text, is_correct, explanation, display_order)
SELECT id, 'A', 'Sand', FALSE, 'Not sand; specifically mineral granules.', 1 FROM q
UNION ALL
SELECT id, 'B', 'Mineral granules embedded in the asphalt', TRUE, 'Standard composition shingle definition.', 2 FROM q
UNION ALL
SELECT id, 'C', 'Aluminum flakes', FALSE, 'Not the surface material.', 3 FROM q
UNION ALL
SELECT id, 'D', 'Plastic chips', FALSE, 'Not the surface material.', 4 FROM q;

-- Sample quiz question 2
WITH q AS (
  INSERT INTO quiz_questions (quiz_id, question_number, question_text, difficulty, display_order)
  SELECT
    qz.id, 2,
    'The most common composition shingle profile installed today is:',
    'beginner', 2
  FROM quizzes qz
  JOIN chapters c ON qz.chapter_id = c.id
  WHERE c.chapter_number = 1
  RETURNING id
)
INSERT INTO quiz_answers (question_id, answer_letter, answer_text, is_correct, explanation, display_order)
SELECT id, 'A', 'Three-tab', FALSE, 'Three-tab is older style; less common on new installs.', 1 FROM q
UNION ALL
SELECT id, 'B', 'Architectural (dimensional, laminated)', TRUE, 'Industry standard since the 2000s.', 2 FROM q
UNION ALL
SELECT id, 'C', 'Designer / luxury', FALSE, 'Designer is premium tier; less common than architectural.', 3 FROM q
UNION ALL
SELECT id, 'D', 'Built-up', FALSE, 'Built-up isn''t a shingle profile.', 4 FROM q;

-- Sample glossary term
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Composition shingle', 'Asphalt-based shingle with mineral granule surface. Most common residential roof system in the United States.', '["Chapter 1"]'::jsonb);

-- Sample comparison table
INSERT INTO comparison_tables (table_number, title, description, columns_json, rows_json, display_order) VALUES
  (
    1,
    'Sample Lifespan Comparison',
    'Sample row for testing.',
    '[{"key": "system", "label": "System"}, {"key": "lifespan", "label": "Lifespan"}]'::jsonb,
    '[{"system": "Composition Shingle (Architectural)", "lifespan": "18-25 years"}]'::jsonb,
    1
  );


-- ============================================================================
-- PART 5: IMPORT SCRIPT TEMPLATE (Node.js / TypeScript)
-- ============================================================================
-- The build window will create an import script that reads the JSON files
-- and populates the database. Below is the recommended structure for the
-- script — implementation lives in the Next.js project, not in SQL.
--
-- Recommended file: /scripts/import-content.ts
--
-- The script should:
--   1. Read 01_book_structure.json → populate book_parts, chapters
--   2. Read 02_final_exam.json → populate quizzes, quiz_sections, quiz_questions, quiz_answers
--      (Create one quiz with is_final_exam = TRUE; link to a synthetic
--       "Final Exam" chapter under Part 7)
--   3. Read 03_chapter_quizzes.json → populate quizzes (one per chapter),
--      quiz_questions, quiz_answers
--   4. Read 04_comparison_tables.json → populate comparison_tables
--   5. Read 05_glossary.json → populate glossary_terms
--   6. Read 06_inspection_checklists.json → populate checklists, checklist_sections
--   7. Section content (the actual markdown body of each section) is added
--      separately by admins through the admin portal — the import only creates
--      empty section records with metadata. This is intentional: it lets
--      the team review and adjust content during entry rather than locking
--      in a rushed export.
--
-- Field mapping notes for the build window:
--   - chapter quiz JSON uses abbreviated keys (q, text, l, t, c, e)
--     → map to question_number, question_text, answer_letter, answer_text,
--       is_correct, explanation
--   - final exam JSON uses full keys
--   - Both should normalize to the same database schema
--
-- Use the Supabase JS client with the service role key for the import
-- (RLS is bypassed for service role).
-- ============================================================================


-- ============================================================================
-- PART 6: VERIFICATION QUERIES
-- (Run these after import to confirm data loaded correctly)
-- ============================================================================

-- Expected counts after full import:
-- SELECT COUNT(*) FROM book_parts;           -- 8
-- SELECT COUNT(*) FROM chapters;             -- 18 chapters + 13 modules + checklists/tables/glossary entries = ~50+
-- SELECT COUNT(*) FROM quizzes;              -- 18 chapter quizzes + 1 final exam = 19
-- SELECT COUNT(*) FROM quiz_questions;       -- 180 (chapter) + 100 (final) = 280
-- SELECT COUNT(*) FROM quiz_answers;         -- 280 questions × 4 answers = 1120
-- SELECT COUNT(*) FROM comparison_tables;    -- 8
-- SELECT COUNT(*) FROM glossary_terms;       -- 154
-- SELECT COUNT(*) FROM checklists;           -- 11

-- Verify each chapter quiz has exactly one correct answer per question:
-- SELECT q.question_number, COUNT(*) FILTER (WHERE a.is_correct = TRUE) AS correct_count
-- FROM quiz_questions q
-- JOIN quiz_answers a ON a.question_id = q.id
-- GROUP BY q.id, q.question_number
-- HAVING COUNT(*) FILTER (WHERE a.is_correct = TRUE) <> 1;
-- (Should return zero rows.)


-- ============================================================================
-- INITIAL ADMIN USER SETUP
-- (Run this AFTER signing up the first admin user via Supabase Auth)
-- ============================================================================
--
-- After the admin signs up via the auth interface (which auto-creates a
-- profile row with role = 'sales_rep'), update their role to 'admin':
--
-- UPDATE profiles SET role = 'admin' WHERE email = 'admin@usaflatroof.com';
--
-- ============================================================================
-- END OF SEED FILE
-- ============================================================================
