-- Phase 4.5 fix #3: break the infinite recursion in profiles RLS.
--
-- The admin policies in 07_supabase_seed.sql query `profiles` from
-- inside a policy on `profiles`, which re-enters RLS and raises
-- error 42P17. The fix is a SECURITY DEFINER helper that does the
-- role lookup with elevated privileges (bypassing RLS), and policies
-- that call it. Idempotent -- safe to re-run.

-- ---------------------------------------------------------------
-- 1. is_admin() helper. SECURITY DEFINER + locked search_path so it
--    cannot be hijacked by a malicious schema on the search path.
-- ---------------------------------------------------------------
CREATE OR REPLACE FUNCTION public.is_admin(uid uuid)
RETURNS boolean
LANGUAGE sql
STABLE
SECURITY DEFINER
SET search_path = public
AS $$
  SELECT EXISTS (
    SELECT 1 FROM public.profiles
    WHERE id = uid AND role = 'admin'
  );
$$;

REVOKE ALL ON FUNCTION public.is_admin(uuid) FROM PUBLIC;
GRANT EXECUTE ON FUNCTION public.is_admin(uuid) TO authenticated, anon, service_role;

-- ---------------------------------------------------------------
-- 2. Replace recursive admin policies on profiles.
-- ---------------------------------------------------------------
DROP POLICY IF EXISTS "Admins can view all profiles"   ON public.profiles;
DROP POLICY IF EXISTS "Admins can manage all profiles" ON public.profiles;

CREATE POLICY "Admins can view all profiles" ON public.profiles
  FOR SELECT USING (public.is_admin(auth.uid()));

CREATE POLICY "Admins can manage all profiles" ON public.profiles
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

-- ---------------------------------------------------------------
-- 3. Replace every other admin policy that subqueries profiles.
--    Required because each of those subqueries triggers profiles
--    RLS, which would still hit the recursive policy if left.
-- ---------------------------------------------------------------

-- Book content
DROP POLICY IF EXISTS "Admins manage book parts" ON public.book_parts;
CREATE POLICY "Admins manage book parts" ON public.book_parts
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage chapters" ON public.chapters;
CREATE POLICY "Admins manage chapters" ON public.chapters
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage sections" ON public.sections;
CREATE POLICY "Admins manage sections" ON public.sections
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

-- Sections also has an authenticated read policy with an inline
-- subquery on profiles -- replace it too.
DROP POLICY IF EXISTS "Authenticated users read appropriate sections"
  ON public.sections;
CREATE POLICY "Authenticated users read appropriate sections" ON public.sections
  FOR SELECT USING (
    auth.role() = 'authenticated' AND (
      is_instructor_only = FALSE
      OR public.is_admin(auth.uid())
      OR EXISTS (
        SELECT 1 FROM public.profiles
        WHERE id = auth.uid() AND role = 'instructor'
      )
    )
  );

-- Quizzes
DROP POLICY IF EXISTS "Admins manage quizzes" ON public.quizzes;
CREATE POLICY "Admins manage quizzes" ON public.quizzes
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage quiz sections" ON public.quiz_sections;
CREATE POLICY "Admins manage quiz sections" ON public.quiz_sections
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage quiz questions" ON public.quiz_questions;
CREATE POLICY "Admins manage quiz questions" ON public.quiz_questions
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage quiz answers" ON public.quiz_answers;
CREATE POLICY "Admins manage quiz answers" ON public.quiz_answers
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

-- Comparison tables, glossary, checklists
DROP POLICY IF EXISTS "Admins manage comparison tables" ON public.comparison_tables;
CREATE POLICY "Admins manage comparison tables" ON public.comparison_tables
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage glossary" ON public.glossary_terms;
CREATE POLICY "Admins manage glossary" ON public.glossary_terms
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage checklists" ON public.checklists;
CREATE POLICY "Admins manage checklists" ON public.checklists
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins manage checklist sections" ON public.checklist_sections;
CREATE POLICY "Admins manage checklist sections" ON public.checklist_sections
  FOR ALL USING (public.is_admin(auth.uid()))
  WITH CHECK (public.is_admin(auth.uid()));

-- User progress
DROP POLICY IF EXISTS "Admins view all reading progress" ON public.reading_progress;
CREATE POLICY "Admins view all reading progress" ON public.reading_progress
  FOR SELECT USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins view all attempts" ON public.quiz_attempts;
CREATE POLICY "Admins view all attempts" ON public.quiz_attempts
  FOR SELECT USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins view all quiz responses" ON public.quiz_responses;
CREATE POLICY "Admins view all quiz responses" ON public.quiz_responses
  FOR SELECT USING (public.is_admin(auth.uid()));

-- Content revisions
DROP POLICY IF EXISTS "Admins view content revisions" ON public.content_revisions;
CREATE POLICY "Admins view content revisions" ON public.content_revisions
  FOR SELECT USING (public.is_admin(auth.uid()));

DROP POLICY IF EXISTS "Admins create content revisions" ON public.content_revisions;
CREATE POLICY "Admins create content revisions" ON public.content_revisions
  FOR INSERT WITH CHECK (public.is_admin(auth.uid()));
