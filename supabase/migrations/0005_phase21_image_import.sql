-- Phase 21 batch image import: replace [IMAGE #N] placeholders -> markdown images
-- Source: data/manuscript/extracted-content.json (for verbatim OLD-block matching)
-- Target: 14 sections in Part 1 (chapter/section list below)
-- Companion to scripts/generate-phase21-image-migration.py.
-- Atomicity: single transaction. Either all 14 UPDATEs apply + their
-- content_revisions rows insert, or nothing changes (defensive checks
-- before COMMIT roll back if any [IMAGE block remains in Part 1, or if
-- the audit-row count for the batch is not exactly 14).
-- Idempotency: NOT idempotent. Re-running this file would no-op the
-- UPDATEs (REPLACE finds nothing) but insert 14 more audit rows. Do not re-run.
-- Dollar-quote tag for body strings: $mfst$
--
-- In-scope sections (P1/Ch/Sec -> bucket UUID):
--   P1/Ch1/Sec6 -> 0B3BAAC5-5F31-4EF9-90FA-3AD0526CED27.png  (replaces [IMAGE #2])
--   P1/Ch2/Sec4 -> 4A487804-DA54-495C-AEB5-BA8C1306FC8C.png  (replaces [IMAGE #1])
--   P1/Ch2/Sec6 -> B1A01A5A-8444-4CD4-9074-13A0D5ED191E.png  (replaces [IMAGE #2])
--   P1/Ch3/Sec4 -> F76C055C-0F7A-4BB3-971E-0608C2088116.png  (replaces [IMAGE #1])
--   P1/Ch3/Sec6 -> 2202847B-AD25-4028-8A45-3F42A98078DA.png  (replaces [IMAGE #2])
--   P1/Ch4/Sec4 -> B27B1465-11E3-48E8-B279-CC924E7D41A3.png  (replaces [IMAGE #1])
--   P1/Ch5/Sec4 -> B09AABBD-86AA-407A-B0E1-E7071E91FED7.png  (replaces [IMAGE #1])
--   P1/Ch6/Sec4 -> 429E4CB5-84AF-4237-9ED7-6E3617D1D671.png  (replaces [IMAGE #1])
--   P1/Ch6/Sec6 -> BAC9C660-FF32-43F4-BF4D-97370E909F2A.png  (replaces [IMAGE #2])
--   P1/Ch8/Sec4 -> 3C56D259-49D5-4049-8072-1554C3A8EFB4.png  (replaces [IMAGE #1])
--   P1/Ch8/Sec6 -> 18AF2508-280C-493D-86A6-CF159D237754.png  (replaces [IMAGE #2])
--   P1/Ch9/Sec4 -> 7A1FEF90-03A2-4E57-8252-33A3CFFEC8DF.png  (replaces [IMAGE #1])
--   P1/Ch10/Sec4 -> 8420B21B-A1E8-4B8D-B5E6-53B2EA921469.png  (replaces [IMAGE #1])
--   P1/Ch10/Sec6 -> 30C9E644-A611-46CC-8001-086ECF90AFBE.png  (replaces [IMAGE #2])

BEGIN;

-- Capture pre-update content_markdown for the 14 in-scope sections.
-- This temp table feeds the content_revisions previous_content column.
CREATE TEMP TABLE _img_import_previous (
  section_id UUID PRIMARY KEY,
  previous_content TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO _img_import_previous (section_id, previous_content)
SELECT s.id, s.content_markdown
FROM sections s
JOIN chapters c ON s.chapter_id = c.id
JOIN book_parts p ON c.part_id = p.id
WHERE p.part_number = 1
  AND (c.chapter_number, s.section_number) IN (
    (1, '6'),
    (2, '4'),
    (2, '6'),
    (3, '4'),
    (3, '6'),
    (4, '4'),
    (5, '4'),
    (6, '4'),
    (6, '6'),
    (8, '4'),
    (8, '6'),
    (9, '4'),
    (10, '4'),
    (10, '6')
  );

-- 14 UPDATE statements: one per in-scope section.
-- Each UPDATE uses REPLACE() so a stale OLD block (drift since this file
-- was generated) becomes a silent no-op, which the post-update [IMAGE
-- residue check at the bottom of the transaction catches.

-- P1 / Ch 1 / Sec 6: [IMAGE #2] -> 0B3BAAC5-5F31-4EF9-90FA-3AD0526CED27.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a composition shingle roof showing rafter, deck, underlayment, drip edge, starter strip, field shingle, flashing at a penetration, and ridge cap.
Purpose: Help reps visualize layered system.
Caption: Cross-section of a typical composition shingle roof system. Components shown are conceptual; actual installations vary.
Alt text: Diagram showing layers of an asphalt shingle roof from rafter to ridge cap.
Annotation needed: Yes — label all components listed above.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram showing layers of an asphalt shingle roof from rafter to ridge cap.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/0B3BAAC5-5F31-4EF9-90FA-3AD0526CED27.png)
*Cross-section of a typical composition shingle roof system. Components shown are conceptual; actual installations vary.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '6'
);

-- P1 / Ch 2 / Sec 4: [IMAGE #1] -> 4A487804-DA54-495C-AEB5-BA8C1306FC8C.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Wide overhead view of a recently installed white 60-mil mechanically attached TPO roof on a commercial building. Show seams, fastener rows, parapet flashing, and at least one drain or HVAC curb.
Purpose: Establish baseline visual recognition.
Caption: A typical 60-mil mechanically attached TPO roof in good condition.
Alt text: Drone view of a white TPO roof on a commercial building with visible seams, parapet flashing, and rooftop HVAC equipment.
Annotation needed: No
Field note: Capture in even daylight. Avoid identifiable tenant signage or addresses unless approved.
Review status: Conceptual only$mfst$,
    $mfst$![Drone view of a white TPO roof on a commercial building with visible seams, parapet flashing, and rooftop HVAC equipment.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/4A487804-DA54-495C-AEB5-BA8C1306FC8C.png)
*A typical 60-mil mechanically attached TPO roof in good condition.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '4'
);

-- P1 / Ch 2 / Sec 6: [IMAGE #2] -> B1A01A5A-8444-4CD4-9074-13A0D5ED191E.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a 60-mil mechanically attached TPO assembly showing metal deck, insulation, cover board, membrane, fastener and plate at seam, and a typical parapet termination.
Purpose: Help reps visualize the layered system.
Caption: Cross-section of a typical mechanically attached TPO assembly. Components shown are conceptual; actual installations vary.
Alt text: Diagram of a TPO roof assembly showing deck, insulation, cover board, membrane, fasteners, and parapet flashing.
Annotation needed: Yes — label all components listed above.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram of a TPO roof assembly showing deck, insulation, cover board, membrane, fasteners, and parapet flashing.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/B1A01A5A-8444-4CD4-9074-13A0D5ED191E.png)
*Cross-section of a typical mechanically attached TPO assembly. Components shown are conceptual; actual installations vary.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '6'
);

-- P1 / Ch 3 / Sec 4: [IMAGE #1] -> F76C055C-0F7A-4BB3-971E-0608C2088116.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Close-up of a properly applied silicone coating showing surface texture, continuous wrap over a curb or pipe penetration, and clean edge work.
Purpose: Establish visual recognition.
Caption: A silicone-coated commercial roof in good condition. Note the continuous wrap over details and the brush/spray texture.
Alt text: White silicone-coated roof showing painted texture and continuous coverage over a pipe penetration.
Annotation needed: No
Field note: Capture in even daylight. Show one detail (drain, curb, or pipe boot) clearly.
Review status: Conceptual only$mfst$,
    $mfst$![White silicone-coated roof showing painted texture and continuous coverage over a pipe penetration.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/F76C055C-0F7A-4BB3-971E-0608C2088116.png)
*A silicone-coated commercial roof in good condition. Note the continuous wrap over details and the brush/spray texture.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '4'
);

-- P1 / Ch 3 / Sec 6: [IMAGE #2] -> 2202847B-AD25-4028-8A45-3F42A98078DA.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Diagram
Priority: Required
Source preference: Custom diagram
Description: Cross-section showing existing membrane substrate, primer (where used), reinforcement fabric at a seam or transition, detail coat, and field coat.
Purpose: Help reps visualize the coating system as a layered restoration, not just paint.
Caption: Cross-section of a typical single-coat silicone restoration system. Components shown are conceptual; actual systems vary by manufacturer.
Alt text: Diagram showing layers of a silicone roof coating system over an existing substrate.
Annotation needed: Yes — label substrate, primer (if used), fabric, detail coat, and field coat.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram showing layers of a silicone roof coating system over an existing substrate.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/2202847B-AD25-4028-8A45-3F42A98078DA.png)
*Cross-section of a typical single-coat silicone restoration system. Components shown are conceptual; actual systems vary by manufacturer.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '6'
);

-- P1 / Ch 4 / Sec 4: [IMAGE #1] -> B27B1465-11E3-48E8-B279-CC924E7D41A3.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Recommended
Source preference: Company photo
Description: Side-by-side comparison of a composition shingle roof before and after rejuvenation application, ideally captured in similar lighting conditions.
Purpose: Establish realistic expectation of visual change.
Caption: A composition shingle roof before and after Fresh Roof rejuvenation. Note that visible difference is subtle — rejuvenation works at the asphalt level, not on the surface appearance.
Alt text: Two photos of the same roof showing minimal visible difference before and after rejuvenation treatment.
Annotation needed: No
Field note: Document with consistent lighting and angle. Avoid overstating the visual change in marketing.
Review status: Conceptual only$mfst$,
    $mfst$![Two photos of the same roof showing minimal visible difference before and after rejuvenation treatment.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/B27B1465-11E3-48E8-B279-CC924E7D41A3.png)
*A composition shingle roof before and after Fresh Roof rejuvenation. Note that visible difference is subtle — rejuvenation works at the asphalt level, not on the surface appearance.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '4'
);

-- P1 / Ch 5 / Sec 4: [IMAGE #1] -> B09AABBD-86AA-407A-B0E1-E7071E91FED7.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Side-by-side close-up comparison of PVC and TPO membranes, showing surface texture and weld bead. Same lighting and angle.
Purpose: Train reps on the (limited) visual differences.
Caption: PVC (left) and TPO (right) at close range. Differences are subtle — documentation remains the most reliable identification method.
Alt text: Two close-up photos of white single-ply roof membranes showing surface and seam texture.
Annotation needed: Yes — call out surface and weld bead.
Review status: Conceptual only$mfst$,
    $mfst$![Two close-up photos of white single-ply roof membranes showing surface and seam texture.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/B09AABBD-86AA-407A-B0E1-E7071E91FED7.png)
*PVC (left) and TPO (right) at close range. Differences are subtle — documentation remains the most reliable identification method.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '4'
);

-- P1 / Ch 6 / Sec 4: [IMAGE #1] -> 429E4CB5-84AF-4237-9ED7-6E3617D1D671.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Self-adhered modified bitumen roof in good condition, showing granule surface, seam pattern, and parapet flashing.
Purpose: Establish baseline visual recognition.
Caption: A self-adhered modified bitumen roof in good condition. Note the granule surface and clean seam appearance.
Alt text: Flat commercial roof with granule-surfaced modified bitumen membrane and visible parapet flashing.
Annotation needed: No
Field note: Capture in even daylight. Show one detail (drain or curb) clearly.
Review status: Conceptual only$mfst$,
    $mfst$![Flat commercial roof with granule-surfaced modified bitumen membrane and visible parapet flashing.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/429E4CB5-84AF-4237-9ED7-6E3617D1D671.png)
*A self-adhered modified bitumen roof in good condition. Note the granule surface and clean seam appearance.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '4'
);

-- P1 / Ch 6 / Sec 6: [IMAGE #2] -> BAC9C660-FF32-43F4-BF4D-97370E909F2A.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a two-ply self-adhered modified bitumen assembly showing deck, insulation, cover board, base sheet, cap sheet, and parapet termination.
Purpose: Help reps visualize the layered system.
Caption: Cross-section of a typical two-ply self-adhered modified bitumen assembly. Components shown are conceptual; actual installations vary.
Alt text: Diagram of a modified bitumen roof assembly showing deck, insulation, cover board, base sheet, cap sheet, and flashing.
Annotation needed: Yes — label all components.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram of a modified bitumen roof assembly showing deck, insulation, cover board, base sheet, cap sheet, and flashing.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/BAC9C660-FF32-43F4-BF4D-97370E909F2A.png)
*Cross-section of a typical two-ply self-adhered modified bitumen assembly. Components shown are conceptual; actual installations vary.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '6'
);

-- P1 / Ch 8 / Sec 4: [IMAGE #1] -> 3C56D259-49D5-4049-8072-1554C3A8EFB4.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Wide view of a concrete tile roof on a typical Northern California residential home, showing tile courses, ridge tiles, and at least one penetration.
Purpose: Establish visual recognition.
Caption: A typical concrete tile roof on a Northern California residence.
Alt text: Two-story home with concrete tile roof showing clear tile courses, ridge tiles, and a chimney.
Annotation needed: No
Field note: Capture in even daylight. Avoid identifiable house numbers.
Review status: Conceptual only$mfst$,
    $mfst$![Two-story home with concrete tile roof showing clear tile courses, ridge tiles, and a chimney.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/3C56D259-49D5-4049-8072-1554C3A8EFB4.png)
*A typical concrete tile roof on a Northern California residence.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '4'
);

-- P1 / Ch 8 / Sec 6: [IMAGE #2] -> 18AF2508-280C-493D-86A6-CF159D237754.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a concrete tile roof showing deck, underlayment (highlighted as the actual waterproofing layer), batten (if applicable), tile, and a valley or penetration detail.
Purpose: Reinforce the central learning point — underlayment is the waterproofing.
Caption: Cross-section of a typical concrete tile assembly. The underlayment is the waterproofing layer; the tiles shed bulk water but are not waterproof on their own.
Alt text: Diagram of a concrete tile roof showing deck, underlayment, batten, and tile with a valley flashing detail.
Annotation needed: Yes — clearly highlight the underlayment as the waterproofing layer.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram of a concrete tile roof showing deck, underlayment, batten, and tile with a valley flashing detail.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/18AF2508-280C-493D-86A6-CF159D237754.png)
*Cross-section of a typical concrete tile assembly. The underlayment is the waterproofing layer; the tiles shed bulk water but are not waterproof on their own.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '6'
);

-- P1 / Ch 9 / Sec 4: [IMAGE #1] -> 7A1FEF90-03A2-4E57-8252-33A3CFFEC8DF.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Wide view of a gravel-surfaced BUR roof on an older commercial building, showing the gravel field, parapet wrap, and at least one penetration.
Purpose: Establish visual recognition.
Caption: A typical gravel-surfaced built-up roof on an older commercial building.
Alt text: Flat commercial roof with gravel surface, parapet walls, and rooftop HVAC equipment.
Annotation needed: No
Field note: Capture in even daylight. Try to include an edge or termination where layered construction is visible.
Review status: Conceptual only$mfst$,
    $mfst$![Flat commercial roof with gravel surface, parapet walls, and rooftop HVAC equipment.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/7A1FEF90-03A2-4E57-8252-33A3CFFEC8DF.png)
*A typical gravel-surfaced built-up roof on an older commercial building.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '4'
);

-- P1 / Ch 10 / Sec 4: [IMAGE #1] -> 8420B21B-A1E8-4B8D-B5E6-53B2EA921469.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Wide view of an SPF roof showing the characteristic orange-peel texture, continuous monolithic surface, and tapered drainage at a drain.
Purpose: Establish visual recognition.
Caption: A typical SPF roof with silicone topcoat. Note the orange-peel texture characteristic of foam application.
Alt text: Flat commercial roof with white-coated foam surface showing orange-peel texture and a tapered drain.
Annotation needed: No
Field note: Capture in even daylight. Show the orange-peel texture clearly and include a drain or edge detail.
Review status: Conceptual only$mfst$,
    $mfst$![Flat commercial roof with white-coated foam surface showing orange-peel texture and a tapered drain.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/8420B21B-A1E8-4B8D-B5E6-53B2EA921469.png)
*A typical SPF roof with silicone topcoat. Note the orange-peel texture characteristic of foam application.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '4'
);

-- P1 / Ch 10 / Sec 6: [IMAGE #2] -> 30C9E644-A611-46CC-8001-086ECF90AFBE.png
UPDATE sections SET
  content_markdown = REPLACE(content_markdown,
    $mfst$[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of an SPF system showing existing substrate (e.g., BUR with gravel removed), primer, foam at varying thickness for taper, topcoat, and a tapered drainage detail at a drain.
Purpose: Help reps visualize how SPF creates slope and provides insulation simultaneously.
Caption: Cross-section of an SPF system over an existing BUR substrate. Foam thickness is varied to create slope toward drains. Components shown are conceptual.
Alt text: Diagram showing layered SPF assembly with tapered foam thickness, topcoat, and drain detail.
Annotation needed: Yes — label substrate, primer, foam (with thickness variation noted), and topcoat.
Review status: Requires technical review before publication$mfst$,
    $mfst$![Diagram showing layered SPF assembly with tapered foam thickness, topcoat, and drain detail.](https://incnssapeuouhsglkfno.supabase.co/storage/v1/object/public/content-images/30C9E644-A611-46CC-8001-086ECF90AFBE.png)
*Cross-section of an SPF system over an existing BUR substrate. Foam thickness is varied to create slope toward drains. Components shown are conceptual.*$mfst$),
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '6'
);

-- Single INSERT capturing all 14 audit rows.
-- previous_content comes from the temp table populated above (pre-UPDATE values).
-- new_content reads from sections live, which now reflects the post-UPDATE bodies.
-- edit_note is computed per-row to record which P/Ch/Sec each row covers.
INSERT INTO content_revisions (
  section_id, edited_by, previous_content, new_content, edit_note, edited_at
)
SELECT
  ip.section_id,
  (SELECT id FROM profiles WHERE email = 'ikuniversal@gmail.com'),
  ip.previous_content,
  s.content_markdown,
  'Phase 21 batch image import: replaced [IMAGE] placeholder in P'
    || p.part_number || '/Ch' || c.chapter_number || '/Sec'
    || s.section_number || ' with AI-generated image',
  NOW()
FROM _img_import_previous ip
JOIN sections s ON s.id = ip.section_id
JOIN chapters c ON s.chapter_id = c.id
JOIN book_parts p ON c.part_id = p.id;

-- Defensive safety checks. If either fails the entire transaction
-- rolls back and no rows are written.
DO $$
DECLARE
  still_present integer;
  rev_count integer;
BEGIN
  -- Check #1: no [IMAGE blocks remain anywhere in Part 1.
  --   If any UPDATE silently no-op'd (OLD-block drift vs. live data),
  --   the [IMAGE marker would still be present in that section.
  SELECT COUNT(*) INTO still_present
  FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND s.content_markdown LIKE '%[IMAGE%';
  IF still_present <> 0 THEN
    RAISE EXCEPTION 'Phase 21 image import safety check #1 failed: % [IMAGE blocks still present in Part 1 after UPDATEs. Transaction rolled back.', still_present;
  END IF;

  -- Check #2: exactly 14 audit rows for the batch.
  SELECT COUNT(*) INTO rev_count
  FROM content_revisions cr
  WHERE cr.edit_note LIKE 'Phase 21 batch image import:%'
    AND cr.section_id IN (SELECT section_id FROM _img_import_previous);
  IF rev_count <> 14 THEN
    RAISE EXCEPTION 'Phase 21 image import safety check #2 failed: expected 14 audit rows for the batch, found %. Transaction rolled back.', rev_count;
  END IF;
END $$;

COMMIT;
