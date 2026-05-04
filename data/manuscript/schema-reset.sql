-- Schema reset for sections + chapters titles to match manuscript
-- Generated from manuscript transcripts (April 27 + April 29, 2026)
-- Total rows to insert: 540

BEGIN;

-- Step 1: Delete all existing section content and revisions for Parts 1-3
-- This is destructive — it drops the Cody-generated section template.
-- Manuscript sections will be inserted in Step 3.

DELETE FROM content_revisions
WHERE section_id IN (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number IN (1, 2, 3)
);

DELETE FROM bookmarks
WHERE section_id IN (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number IN (1, 2, 3)
);

DELETE FROM reading_progress
WHERE section_id IN (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number IN (1, 2, 3)
);

DELETE FROM sections
WHERE chapter_id IN (
  SELECT c.id FROM chapters c
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number IN (1, 2, 3)
);

-- Step 2: Update chapter titles to match manuscript exactly
UPDATE chapters SET title = 'Composition Shingle Roofing' WHERE chapter_number = 1 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'TPO Roofing' WHERE chapter_number = 2 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Silicone Roof Coatings' WHERE chapter_number = 3 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Roof Rejuvenation' WHERE chapter_number = 4 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'PVC Roofing' WHERE chapter_number = 5 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Modified Bitumen Roofing (Self-Adhered)' WHERE chapter_number = 6 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Acrylic Roof Coatings' WHERE chapter_number = 7 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Concrete Tile Roofing' WHERE chapter_number = 8 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Built-Up Roofing (BUR)' WHERE chapter_number = 9 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Spray Polyurethane Foam (SPF) Roofing' WHERE chapter_number = 10 AND part_id = (SELECT id FROM book_parts WHERE part_number = 1);
UPDATE chapters SET title = 'Roof Maintenance and Repairs' WHERE chapter_number = 11 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Roof Inspections and Documentation' WHERE chapter_number = 12 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Repair vs Restoration vs Replacement: Decision Framework' WHERE chapter_number = 13 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Roof Ventilation and Condensation Basics' WHERE chapter_number = 14 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Flashings, Penetrations, and Edge Details' WHERE chapter_number = 15 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Gutters, Drainage, and Ponding Water' WHERE chapter_number = 16 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Commercial Flat Roof Systems Overview' WHERE chapter_number = 17 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);
UPDATE chapters SET title = 'Residential Steep-Slope Roof Systems Overview' WHERE chapter_number = 18 AND part_id = (SELECT id FROM book_parts WHERE part_number = 2);

-- Module title updates (Part 3)
UPDATE chapters SET title = 'How to Talk About Roof Age' WHERE chapter_number = 1 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Leaks' WHERE chapter_number = 2 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Ponding Water on Flat Roofs' WHERE chapter_number = 3 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Coatings vs Repair vs Restoration vs Replacement' WHERE chapter_number = 4 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Roof Rejuvenation' WHERE chapter_number = 5 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Storm Damage' WHERE chapter_number = 6 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Take Roof Photos Like a Professional' WHERE chapter_number = 7 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Build Trust: Consultative vs Pressure Selling' WHERE chapter_number = 8 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Recommend Repair vs Replacement' WHERE chapter_number = 9 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Present Good / Better / Best Options' WHERE chapter_number = 10 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'How to Talk About Pricing' WHERE chapter_number = 11 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'Warranty Reality: Cross-System Deep Dive' WHERE chapter_number = 12 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);
UPDATE chapters SET title = 'Why Honesty Is the Long-Term Sale' WHERE chapter_number = 13 AND part_id = (SELECT id FROM book_parts WHERE part_number = 3);

-- Step 3: Insert sections from manuscript
-- Note: content_markdown is left empty here; the import script will
-- populate it. We just need the rows in place with correct titles,
-- numbers, is_instructor_only flags, and display_order.
-- Schema columns: chapter_id, section_number (TEXT, will implicit-cast from int),
-- title, content_markdown, is_instructor_only, display_order (NOT NULL, set to section_number).

-- Part 1, Chapter/Module 1
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 4, 'What It Looks Like + Ground-Level Recognition Clues', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 15, 'Ideal Customer Profile + Pain Points', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 16, 'Lead Qualification Questions', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 17, 'Sales Conversation Guide', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 18, 'Proposal Language Examples', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 19, 'Role-Play Scenario', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 20, 'Field Photo & Documentation Checklist', '', FALSE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 21, 'When to Escalate', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 22, 'Company Method Box', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 23, 'Instructor Notes', '', TRUE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 24, 'Key Terms to Remember', '', FALSE, 24),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 25, 'Chapter Summary', '', FALSE, 25),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 26, 'End-of-Chapter Quiz', '', FALSE, 26),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 1), 27, 'Manager Review Checklist + Verification Notes', '', TRUE, 27);

-- Part 1, Chapter/Module 2
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 4, 'What It Looks Like + Ground-Level Recognition Clues', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 15, 'Ideal Customer Profile + Pain Points', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 16, 'Lead Qualification Questions', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 17, 'Sales Conversation Guide', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 18, 'Proposal Language Examples', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 19, 'Role-Play Scenario', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 20, 'Field Photo & Documentation Checklist', '', FALSE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 21, 'When to Escalate', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 22, 'Company Method Box', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 23, 'Instructor Notes', '', TRUE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 24, 'Key Terms to Remember', '', FALSE, 24),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 25, 'Chapter Summary', '', FALSE, 25),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 26, 'End-of-Chapter Quiz', '', FALSE, 26),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 2), 27, 'Manager Review Checklist + Verification Notes', '', TRUE, 27);

-- Part 1, Chapter/Module 3
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 4, 'What It Looks Like + Ground-Level Recognition Clues', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 15, 'Ideal Customer Profile + Pain Points', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 16, 'Lead Qualification Questions', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 17, 'Sales Conversation Guide', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 18, 'Proposal Language Examples', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 19, 'Role-Play Scenario', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 20, 'Field Photo & Documentation Checklist', '', FALSE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 21, 'When to Escalate', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 22, 'Company Method Box', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 23, 'Instructor Notes', '', TRUE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 24, 'Key Terms to Remember', '', FALSE, 24),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 25, 'Chapter Summary', '', FALSE, 25),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 26, 'End-of-Chapter Quiz', '', FALSE, 26),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 3), 27, 'Manager Review Checklist + Verification Notes', '', TRUE, 27);

-- Part 1, Chapter/Module 4
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 7, 'How It''s Applied', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 8, 'Expected Lifespan Extension', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 15, 'Ideal Customer Profile + Pain Points', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 16, 'Lead Qualification Questions', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 17, 'Sales Conversation Guide', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 18, 'Proposal Language Examples', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 19, 'Role-Play Scenario', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 20, 'Field Photo & Documentation Checklist', '', FALSE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 21, 'When to Escalate', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 22, 'Company Method Box', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 23, 'Instructor Notes', '', TRUE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 24, 'Key Terms to Remember', '', FALSE, 24),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 25, 'Chapter Summary', '', FALSE, 25),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 26, 'End-of-Chapter Quiz', '', FALSE, 26),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 4), 27, 'Manager Review Checklist + Verification Notes', '', TRUE, 27);

-- Part 1, Chapter/Module 5
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 15, 'Sales Conversation Guide', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 16, 'Proposal Language Examples', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 17, 'Field Photo & Documentation Checklist', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 18, 'When to Escalate', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 19, 'Company Method Box', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 20, 'Instructor Notes', '', TRUE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 21, 'Key Terms to Remember', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 22, 'Chapter Summary', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 23, 'End-of-Chapter Quiz', '', FALSE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 5), 24, 'Manager Review Checklist + Verification Notes', '', TRUE, 24);

-- Part 1, Chapter/Module 6
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 13, 'Recommendation Options — Good / Better / Best', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 15, 'Sales Conversation Guide', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 16, 'Proposal Language Examples', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 17, 'Field Photo & Documentation Checklist', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 18, 'When to Escalate', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 19, 'Company Method Box', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 20, 'Instructor Notes', '', TRUE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 21, 'Key Terms to Remember', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 22, 'Chapter Summary', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 23, 'End-of-Chapter Quiz', '', FALSE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 6), 24, 'Manager Review Checklist + Verification Notes', '', TRUE, 24);

-- Part 1, Chapter/Module 7
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 7), 1, 'Recognition + Ground-Level Clues', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 7), 2, 'Commonly Confused With', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 7), 3, 'Common Failure Modes', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 7), 4, 'Sales Cautions / What Not to Promise', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 7), 5, 'When to Escalate', '', FALSE, 5);

-- Part 1, Chapter/Module 8
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 7, 'Expected Lifespan', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 8, 'Strengths', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 9, 'Limitations & Trade-offs', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 10, 'Common Problems & Failure Modes', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 11, 'Field Inspection Guide', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 12, 'Recommendation Options — Repair / Maintenance / Refer', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 13, 'Sales Conversation Guide', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 14, 'Proposal Language Examples', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 15, 'Field Photo & Documentation Checklist', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 16, 'When to Escalate or Refer Out', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 17, 'Instructor Notes', '', TRUE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 18, 'Chapter Summary', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 19, 'End-of-Chapter Quiz', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 8), 20, 'Manager Review Checklist + Verification Notes', '', TRUE, 20);

-- Part 1, Chapter/Module 9
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 7, 'Expected Lifespan', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 8, 'Strengths', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 9, 'Limitations & Trade-offs', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 10, 'Common Problems & Failure Modes', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 11, 'Field Inspection Guide', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 12, 'Recommendation Options — Good / Better / Best', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 13, 'Sales Conversation Guide', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 14, 'Proposal Language Examples', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 15, 'Field Photo & Documentation Checklist', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 16, 'When to Escalate', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 17, 'Company Method Box', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 18, 'Instructor Notes', '', TRUE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 19, 'Key Terms to Remember', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 20, 'Chapter Summary', '', FALSE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 21, 'End-of-Chapter Quiz', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 9), 22, 'Manager Review Checklist + Verification Notes', '', TRUE, 22);

-- Part 1, Chapter/Module 10
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 2, 'Simple Overview', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 3, 'Where It''s Commonly Used', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 4, 'What It Looks Like + Recognition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 5, 'Commonly Confused With', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 6, 'Main Components', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 7, 'How It''s Installed', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 8, 'Expected Lifespan', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 9, 'Strengths', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 10, 'Limitations & Trade-offs', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 11, 'Common Problems & Failure Modes', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 12, 'Field Inspection Guide', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 13, 'Recommendation Options', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 14, 'Warranty Reality', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 15, 'Sales Conversation Guide', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 16, 'Proposal Language Examples', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 17, 'Field Photo & Documentation Checklist', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 18, 'When to Escalate', '', FALSE, 18),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 19, 'Company Method Box', '', FALSE, 19),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 20, 'Instructor Notes', '', TRUE, 20),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 21, 'Key Terms to Remember', '', FALSE, 21),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 22, 'Chapter Summary', '', FALSE, 22),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 23, 'End-of-Chapter Quiz', '', FALSE, 23),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 1 AND c.chapter_number = 10), 24, 'Manager Review Checklist + Verification Notes', '', TRUE, 24);

-- Part 2, Chapter/Module 11
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 3, 'Maintenance vs Repair — Plain Language', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 4, 'Categories of Maintenance Work', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 5, 'Categories of Repair Work', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 6, 'Field Inspection Approach for Maintenance and Repair Calls', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 7, 'The Repair-Plus-Plan Conversation', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 8, 'Maintenance Programs as a Sales Strategy', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 9, 'Pricing and Proposal Considerations', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 10, 'Common Maintenance and Repair Mistakes', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 11, 'Sales Conversation Guide', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 12, 'When to Escalate', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 13, 'Company Method Box', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 14, 'Instructor Notes', '', TRUE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 15, 'Key Terms to Remember', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 16, 'Chapter Summary', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 17, 'End-of-Chapter Quiz', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 11), 18, 'Manager Review Checklist + Verification Notes', '', TRUE, 18);

-- Part 2, Chapter/Module 12
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 2, 'Why Documentation Matters', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 3, 'The Inspection Sequence', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 4, 'Inspection Methods', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 5, 'Photo Standards', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 6, 'Customer-Facing Documentation', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 7, 'Warranty-Required Documentation', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 8, 'Documentation Boundaries — What Reps Cannot Document', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 9, 'Common Documentation Mistakes', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 10, 'The Inspection-as-Sales-Asset Mindset', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 11, 'Sales Conversation Guide for Inspection-Stage Conversations', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 12, 'When to Escalate', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 13, 'Company Method Box', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 14, 'Instructor Notes', '', TRUE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 15, 'Key Terms to Remember', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 16, 'Chapter Summary', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 17, 'End-of-Chapter Quiz', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 12), 18, 'Manager Review Checklist + Verification Notes', '', TRUE, 18);

-- Part 2, Chapter/Module 13
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 3, 'The Three Scopes — Plain Language Definitions', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 4, 'Lens One — Condition', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 5, 'Lens Two — Customer Fit', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 6, 'Lens Three — Budget', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 7, 'Lens Four — Honest-Versus-Easy', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 8, 'The Decision Tree', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 9, 'Common Decision Errors', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 10, 'Cross-System Quick-Reference', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 11, 'Sales Conversation Guide for Decision Conversations', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 12, 'Red Flags and Escalation', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 13, 'Company Method Box', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 14, 'Instructor Notes', '', TRUE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 15, 'Key Terms to Remember', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 16, 'Chapter Summary', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 17, 'End-of-Chapter Quiz', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 13), 18, 'Manager Review Checklist + Verification Notes', '', TRUE, 18);

-- Part 2, Chapter/Module 14
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 3, 'The Basic Physics — Plain Language', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 4, 'Steep-Slope Residential Ventilation', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 5, 'Flat-Roof Commercial Vapor and Condensation', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 6, 'The Re-Roof Conversation', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 7, 'Common Customer Questions and Honest Answers', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 8, 'Common Ventilation and Condensation Mistakes', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 9, 'Sales Conversation Guide', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 10, 'When to Escalate', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 11, 'Company Method Box', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 12, 'Instructor Notes', '', TRUE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 13, 'Key Terms to Remember', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 14, 'Chapter Summary', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 15, 'End-of-Chapter Quiz', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 14), 16, 'Manager Review Checklist + Verification Notes', '', TRUE, 16);

-- Part 2, Chapter/Module 15
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 3, 'The Vocabulary — What Each Detail Is', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 4, 'Why Details Fail', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 5, 'Common Failures by Detail Type', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 6, 'Field Inspection Approach for Details', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 7, 'Detail Inspection in the Severity Scale', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 8, 'The "Leaks Live at Details" Conversation', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 9, 'Sales Conversation Guide', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 10, 'When to Escalate', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 11, 'Company Method Box', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 12, 'Instructor Notes', '', TRUE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 13, 'Key Terms to Remember', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 14, 'Chapter Summary', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 15, 'End-of-Chapter Quiz', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 15), 16, 'Manager Review Checklist + Verification Notes', '', TRUE, 16);

-- Part 2, Chapter/Module 16
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 2, 'Why Drainage Matters', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 3, 'Residential Gutters and Drainage — Brief Coverage', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 4, 'Commercial Flat-Roof Drainage — How It''s Designed', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 5, 'Ponding Water — The Central Topic', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 6, 'The Ponding Conversation with Customers', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 7, 'Drainage Inspection Across Flat-Roof Systems', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 8, 'Common Drainage and Ponding Mistakes', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 9, 'Sales Conversation Guide', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 10, 'When to Escalate', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 11, 'Company Method Box', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 12, 'Instructor Notes', '', TRUE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 13, 'Key Terms to Remember', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 14, 'Chapter Summary', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 15, 'End-of-Chapter Quiz', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 16), 16, 'Manager Review Checklist + Verification Notes', '', TRUE, 16);

-- Part 2, Chapter/Module 17
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 3, 'The Commercial Flat-Roof Landscape', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 4, 'The Quick Recognition Decision Tree', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 5, 'System-by-System Recognition Detail', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 6, 'The Hard Calls — TPO vs PVC and Coating-Chemistry Identification', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 7, 'Substrate Detective Work on Coated and Recovered Roofs', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 8, 'The Building-Use Lens', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 9, 'The Inspection-Stage Recognition Process', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 10, 'Common Recognition Mistakes', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 11, 'Sales Conversation Guide', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 12, 'When to Escalate', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 13, 'Cross-System Quick-Reference Table', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 14, 'Instructor Notes', '', TRUE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 15, 'Key Terms to Remember', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 16, 'Chapter Summary', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 17, 'End-of-Chapter Quiz', '', FALSE, 17),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 17), 18, 'Manager Review Checklist + Verification Notes', '', TRUE, 18);

-- Part 2, Chapter/Module 18
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 1, 'Learning Objectives', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 2, 'Why This Chapter Exists', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 3, 'The Residential Steep-Slope Landscape', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 4, 'The Quick Recognition Decision Tree', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 5, 'System-by-System Recognition Detail', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 6, 'The Hard Calls — Profile Distinctions and Look-Alikes', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 7, 'The Architectural and Era Lens', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 8, 'The Inspection-Stage Recognition Process', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 9, 'Common Recognition Mistakes', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 10, 'Sales Conversation Guide', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 11, 'When to Escalate or Refer Out', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 12, 'Cross-System Quick-Reference Table', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 13, 'Instructor Notes', '', TRUE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 14, 'Key Terms to Remember', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 15, 'Chapter Summary', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 16, 'End-of-Chapter Quiz', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 2 AND c.chapter_number = 18), 17, 'Manager Review Checklist + Verification Notes', '', TRUE, 17);

-- Part 3, Chapter/Module 1
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 2, 'What Roof Age Actually Tells You', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 3, 'What Reps Must NOT Do', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 4, 'The Honest Customer Language', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 5, 'The Age + Condition Framework', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 6, 'Common Customer Questions and Honest Answers', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 7, 'The Older-Owner / Inherited-Roof Conversation', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 8, 'When Age Does Drive the Recommendation', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 9, 'Common Sales Mistakes on Age', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 10, 'Quick Reference', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 1), 11, 'Module Summary', '', FALSE, 11);

-- Part 3, Chapter/Module 2
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 2, 'The Core Rule: Entry Point ≠ Interior Drip', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 3, 'Why This Mistake Happens', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 4, 'The Honest Investigation Process', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 5, 'When the Source Can''t Be Found', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 6, 'Sample Customer Language', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 7, 'When the Customer Reports the Leak Is "Solved" After Prior Work', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 8, 'When Insurance Is Involved', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 9, 'The Repair-Plus-Plan Conversation', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 10, 'Common Sales Mistakes on Leak Calls', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 11, 'Quick Reference', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 2), 12, 'Module Summary', '', FALSE, 12);

-- Part 3, Chapter/Module 3
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 3, 'The 48-Hour Standard', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 4, 'Why Ponding Matters (In Customer Language)', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 5, 'The Most Important Customer Conversation: Coating Won''t Fix Ponding', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 6, 'The Real Solutions to Ponding', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 7, 'Acceptable Ponding vs. Problematic Ponding — How to Tell', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 8, 'Common Customer Beliefs and Honest Responses', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 9, 'When the Customer Pushes Back Hard', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 10, 'When SPF Is the Right Recommendation', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 11, 'Common Sales Mistakes on Ponding', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 12, 'Quick Reference', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 3), 13, 'Module Summary', '', FALSE, 13);

-- Part 3, Chapter/Module 4
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 2, 'The Four Scopes — In Plain Customer Language', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 3, 'The Most Common Customer Confusions', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 4, 'When Each Scope Is Right — In One Sentence Each', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 5, 'The Comparison Conversation: When Customers Have Multiple Quotes', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 6, 'When the Customer Wants the Cheapest Scope That Doesn''t Fit', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 7, 'When the Customer Wants More Scope Than the Roof Needs', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 8, 'The Honest Phrases Reps Should Have Ready', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 9, 'Pricing Comparison Pitfalls', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 10, 'What Reps Must NOT Do', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 11, 'Quick Reference', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 4), 12, 'Module Summary', '', FALSE, 12);

-- Part 3, Chapter/Module 5
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 3, 'The Proactive Maintenance Positioning', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 4, 'The Chemistry — In 30 Seconds', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 5, 'The Three Moments Where the Conversation Goes Sideways', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 6, 'The Window — Why Timing Matters', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 7, 'The Honest-Versus-Easy Moment', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 8, 'What Rejuvenation Is Not', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 9, 'The Maintenance Program Conversation', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 10, 'When NOT to Propose Rejuvenation', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 11, 'Common Sales Mistakes on Rejuvenation', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 12, 'Quick Reference', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 5), 13, 'Module Summary', '', FALSE, 13);

-- Part 3, Chapter/Module 6
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 3, 'What Reps Can Do on Storm-Damage Calls', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 4, 'What Reps Cannot Do', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 5, 'The Honest Customer Language', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 6, 'The Storm Damage vs. Trade Damage vs. Aging Damage Distinction', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 7, 'Hail Damage — A Specific Caution', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 8, 'The Insurance Adjuster Conversation', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 9, 'When the Customer Says "Insurance Will Cover It"', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 10, 'When Insurance Doesn''t Cover (or Partially Covers)', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 11, 'When Other Contractors Overpromise', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 12, 'When the Customer Wants Scope Inflated to "Maximize the Claim"', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 13, 'Documentation Standards on Storm-Damage Calls', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 14, 'Common Sales Mistakes on Storm-Damage Calls', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 15, 'Quick Reference', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 6), 16, 'Module Summary', '', FALSE, 16);

-- Part 3, Chapter/Module 7
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 2, 'The Three Audiences for Roof Photos', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 3, 'The Equipment Reps Use', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 4, 'The Eight Universal Photo Rules', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 5, 'The Five Photo Types Every Inspection Needs', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 6, 'Before and After Documentation', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 7, 'Reference Scale and Measurement Photos', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 8, 'Documenting Ponding Water', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 9, 'Substrate and Coating-Layer Documentation', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 10, 'Drone Photography', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 11, 'Customer-Facing Photo Presentation', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 12, 'Good vs Bad Photo Examples', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 13, 'Safety Reference in Photos', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 14, 'Photo Organization After the Inspection', '', FALSE, 14),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 15, 'Common Photo Mistakes Reps Make', '', FALSE, 15),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 16, 'Quick Reference', '', FALSE, 16),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 7), 17, 'Module Summary', '', FALSE, 17);

-- Part 3, Chapter/Module 8
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 2, 'What Pressure Selling Actually Looks Like', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 3, 'What Consultative Selling Actually Looks Like', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 4, 'The Mindset Shift', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 5, 'The Long-Term Relationship Math', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 6, 'Recognizing Pressure Tactics in Others', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 7, 'The Patterns Reps Should Practice', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 8, 'When the Customer Mistakes Honesty for Weakness', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 9, 'The Quiet Confidence Pattern', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 10, 'When the Customer Tries to Pressure the Rep', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 11, 'Common Sales Mistakes That Erode Trust', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 12, 'Quick Reference', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 8), 13, 'Module Summary', '', FALSE, 13);

-- Part 3, Chapter/Module 9
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 3, 'When Repair Is Clearly the Right Answer', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 4, 'When Replacement Is Clearly the Right Answer', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 5, 'When the Answer Is in the Middle: The Repair-Plus-Plan Conversation', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 6, 'Patterns That Point Toward Repair', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 7, 'Patterns That Point Toward Replacement', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 8, 'The Honest Patterns That Aren''t Always Obvious', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 9, 'When Customers Push Back on the Recommendation', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 10, 'When Honesty Costs the Sale', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 11, 'The Phased Work Option', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 12, 'Common Sales Mistakes on Repair vs Replacement', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 13, 'Quick Reference', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 9), 14, 'Module Summary', '', FALSE, 14);

-- Part 3, Chapter/Module 10
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 3, 'What Honest Good / Better / Best Looks Like', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 4, 'When Good / Better / Best Doesn''t Apply', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 5, 'The Anchoring Trap', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 6, 'How to Present the Three Options', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 7, 'When Customers Want to Skip the Analysis', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 8, 'When Customers Want Only the Cheapest', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 9, 'When Customers Want Only the Most Expensive', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 10, 'The Comparison-Quote Conversation', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 11, 'Common Mistakes in Good / Better / Best Presentation', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 12, 'The "Reasonable Customer" Test', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 13, 'Quick Reference', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 10), 14, 'Module Summary', '', FALSE, 14);

-- Part 3, Chapter/Module 11
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 3, 'Why Price Conversations Go Wrong', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 4, 'The Framework: Why Prices Vary', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 5, 'The Variables That Drive Price', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 6, 'When Customers Ask for Verbal Pricing', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 7, 'The Comparison-Quote Conversation', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 8, 'When Customers Negotiate', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 9, 'When Pricing Genuinely Is the Constraint', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 10, 'Common Mistakes in Pricing Conversations', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 11, 'The Honest Closing on Pricing', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 12, 'Quick Reference', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 11), 13, 'Module Summary', '', FALSE, 13);

-- Part 3, Chapter/Module 12
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 3, 'The Three Warranty Layers', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 4, 'The Critical Distinction Customers Miss', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 5, 'The "Lifetime Warranty" Trap', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 6, 'What Voids or Limits Coverage — The Common Patterns', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 7, 'What Reps Cannot Promise', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 8, 'The Honest Customer Language', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 9, 'Sample Warranty Conversations by System', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 10, 'The Comparison-Quote Conversation on Warranty', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 11, 'When Customers File Claims', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 12, 'Common Sales Mistakes on Warranty', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 13, 'Quick Reference', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 12), 14, 'Module Summary', '', FALSE, 14);

-- Part 3, Chapter/Module 13
INSERT INTO sections (chapter_id, section_number, title, content_markdown, is_instructor_only, display_order) VALUES
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 1, 'Why This Module Exists', '', FALSE, 1),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 2, 'The One-Sentence Version', '', FALSE, 2),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 3, 'The Three Categories of "Honest Loss" That Aren''t Actually Losses', '', FALSE, 3),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 4, 'The Maintenance Pipeline as the Honesty Engine', '', FALSE, 4),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 5, 'The Compound Math', '', FALSE, 5),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 6, 'The Moments That Test the Discipline', '', FALSE, 6),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 7, 'What "Holding the Line" Actually Looks Like', '', FALSE, 7),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 8, 'The Internal Discipline', '', FALSE, 8),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 9, 'Common Phrases the Rep Uses', '', FALSE, 9),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 10, 'When the Customer Does Walk Away', '', FALSE, 10),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 11, 'When the Customer Stays', '', FALSE, 11),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 12, 'Common Mistakes That Undermine the Framing', '', FALSE, 12),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 13, 'Quick Reference', '', FALSE, 13),
  ((SELECT c.id FROM chapters c JOIN book_parts p ON c.part_id = p.id WHERE p.part_number = 3 AND c.chapter_number = 13), 14, 'Module Summary', '', FALSE, 14);

COMMIT;

-- After running this script, run scripts/extract-and-import-content.ts
-- with the extracted-content.json file to populate content_markdown.
