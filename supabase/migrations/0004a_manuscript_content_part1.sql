-- Phase B content import: manuscript bodies -> sections.content_markdown (Part 1 only)
-- Source: data/manuscript/extracted-content.json
-- Scope: Part(s) 1, 227 sections
-- Companion to scripts/extract-and-import-content.ts (the live equivalent).
-- Atomicity: single transaction. Either all in-scope sections update + their
-- content_revisions rows insert, or nothing changes (defensive count check
-- before COMMIT raises and rolls back if the post-import populated count is
-- not exactly 227).
-- Idempotency: NOT idempotent on its own. Re-running this file would attempt
-- a second UPDATE (no-op since content matches) plus a second INSERT into
-- content_revisions, producing duplicate audit rows. To recover from a
-- partial / interrupted run, prefer the TS script which IS idempotent via
-- body equality. Or run manual cleanup of duplicates.
-- Dollar-quote tag for body strings: $mfst$

BEGIN;

-- Capture pre-update content_markdown for in-scope sections.
-- This temp table feeds the content_revisions previous_content column.
CREATE TEMP TABLE _import_previous (
  section_id UUID PRIMARY KEY,
  previous_content TEXT NOT NULL
) ON COMMIT DROP;

INSERT INTO _import_previous (section_id, previous_content)
SELECT s.id, s.content_markdown
FROM sections s
JOIN chapters c ON s.chapter_id = c.id
JOIN book_parts p ON c.part_id = p.id
WHERE p.part_number = 1;

-- 227 UPDATE statements: one per manuscript section.
-- Subquery resolves section.id by (part_number, chapter_number, section_number).
-- Each UPDATE writes the manuscript body and bumps updated_at.

-- Part 1 / Ch 1 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify composition shingle roofs on sight and distinguish them from look-alike systems (synthetic slate, designer shingles, dimensional vs. three-tab profiles).
2. Name the main components of a shingle roof system and explain their function in plain language.
3. Inspect a shingle roof from the ground, ladder edge, or attic and classify common conditions on the Inspection Severity Scale.
4. Recommend repair, rejuvenation, or replacement honestly based on roof condition — including when the most profitable recommendation is not the right one.
5. Explain shingle lifespan, warranty structure, and Northern California–specific failure patterns to a customer in language that builds trust without overpromising.
6. Recognize when a roof condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '1'
);

-- Part 1 / Ch 1 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$A **composition shingle** roof is a steep-slope roofing system made of overlapping rectangular shingles that shed water by gravity. Each shingle is built around a fiberglass mat coated with **asphalt** (a petroleum-based waterproofing layer) and surfaced with **mineral granules** (small ceramic-coated rock particles that protect the asphalt from sunlight and add color).

Composition shingles are the most common residential roof covering in the United States. They are sometimes called "asphalt shingles," "comp shingles," or simply "shingles." All three terms refer to the same product family.

Composition shingles come in three main profile types:

- **Three-tab shingles** — flat, uniform appearance with cutouts that create the look of three separate tabs per shingle. Lower cost, shorter service life. Increasingly rare on new installations.
- **Architectural shingles** (also called **dimensional** or **laminated** shingles) — two layers bonded together to create a thicker, shadowed, more textured appearance. The current industry standard for new residential roofs.
- **Designer / luxury shingles** — heavier, multi-layer shingles designed to mimic slate, shake, or other premium materials.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '2'
);

-- Part 1 / Ch 1 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Primary use:** single-family residential homes with sloped roofs
- **Common in:** townhomes, condominiums (where individually owned), small multi-family buildings, mixed-use buildings with steep-slope sections
- **Less common on:** commercial buildings (which typically use flat-roof systems), historic homes with original tile or wood shake, custom or high-end homes specifying tile, slate, or metal

In Northern California, composition shingle is the dominant residential roof system across the Bay Area, Sacramento Valley, North Bay, and East Bay. It is used on tract homes, custom homes, and most home renovations where the original roof is being replaced.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '3'
);

-- Part 1 / Ch 1 / Sec 4: What It Looks Like + Ground-Level Recognition Clues
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

- Rectangular, overlapping pieces running in horizontal courses from eave to ridge
- Surface texture appears slightly grainy or sandy due to mineral granules
- Color is uniform across the field, with optional contrasting ridge caps along the peak
- Steep slope — typically 4:12 or steeper (meaning the roof rises 4 inches or more for every 12 inches of horizontal run)

### Recognition by viewpoint

- **Street view:** uniform rectangular pattern, granular surface, sloped form, ridge cap line along the peak. Color is most often gray, brown, black, or weathered wood tones.
- **Drone view:** clear courses of overlapping shingles, visible ridges and hips, valleys (where two slopes meet to form a V), and penetrations (vents, pipes, chimneys).
- **Ladder edge:** visible **drip edge** (metal flashing along the eave), **starter strip** (a special first course of shingles), and the bottom edge of the **field shingles**.
- **Attic view:** underside of the roof deck (usually plywood or OSB), nail tips protruding through the deck, and any signs of moisture staining, daylight, or insulation damage.
- **Interior leak evidence:** ceiling stains, peeling paint near a wall-roof intersection, water marks around a chimney chase or skylight.
- **Customer-provided photos:** look for granule loss patterns, missing tabs, lifted shingles, or staining.

[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Wide-angle photo of a typical Northern California single-family home with a recently installed architectural composition shingle roof. Show clear courses, ridge cap, and at least one penetration (plumbing vent or attic vent).
Purpose: Establish baseline visual recognition.
Caption: A typical architectural composition shingle roof in good condition.
Alt text: Single-family home with gray architectural composition shingle roof, sloped, visible ridge and plumbing vent.
Annotation needed: No
Field note: Capture in even daylight, no harsh shadows. Avoid identifiable house numbers or client information.
Review status: Conceptual only$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '4'
);

-- Part 1 / Ch 1 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Synthetic slate or shake** | Synthetic products have a deeper, irregular profile and individual piece shapes. Comp shingles are uniformly rectangular. |
| **Real slate** | Slate has visible stone texture, irregular thickness, and a distinct ringing sound when tapped. Slate is also significantly heavier and almost always installed on older or higher-end homes. |
| **Designer comp shingles** | Still composition shingles — heavier multi-layer products designed to look like slate or shake. If the surface is granular and the courses are uniform rectangles, it is comp. |
| **Concrete or clay tile** | Tile has a curved or flat-piece profile, no granules, and a distinct stone or terracotta appearance. Common on older NorCal homes. |
| **Metal shingle** | Metal shingles have visible seams or interlocks, a metallic surface, and no granules. Tap test confirms quickly. |

> **[SALES REP BOUNDARY]** Sales reps may document visible conditions and identify the system type. They may not certify the exact shingle product, manufacturer, or installation date without documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '5'
);

-- Part 1 / Ch 1 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A composition shingle roof is a layered system. From the structure up:

1. **Roof deck** — the structural sheathing, typically plywood or **oriented strand board (OSB)**, nailed to the roof rafters or trusses.
2. **Underlayment** — a water-resistant layer between the deck and the shingles. Two main types: traditional asphalt-saturated felt ("tar paper") or modern synthetic underlayment (a woven plastic sheet).
3. **Ice and water shield** *(in cold-climate or vulnerable areas)* — a self-adhering membrane installed at eaves, valleys, and around penetrations. Less common in most NorCal residential, but used in mountain or foothill installations.
4. **Drip edge** — metal flashing along the eaves and rakes (the sloped edges of the roof) that directs water off the deck and into the gutter.
5. **Starter strip** — a first course of specialty shingles installed along the eave to seal the bottom edge of the first row of field shingles.
6. **Field shingles** — the main shingles covering the roof surface.
7. **Flashings** — metal pieces installed at penetrations, valleys, sidewalls, and chimneys to direct water around obstacles. Common types include step flashing, headwall flashing, valley flashing, and pipe boots.
8. **Ridge cap shingles** — specialty shingles installed at the peak (ridge) and at hips.
9. **Ventilation components** — ridge vents, box vents, turbine vents, soffit vents, or gable vents. Ventilation is part of the roof system, not an accessory.

[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a composition shingle roof showing rafter, deck, underlayment, drip edge, starter strip, field shingle, flashing at a penetration, and ridge cap.
Purpose: Help reps visualize layered system.
Caption: Cross-section of a typical composition shingle roof system. Components shown are conceptual; actual installations vary.
Alt text: Diagram showing layers of an asphalt shingle roof from rafter to ridge cap.
Annotation needed: Yes — label all components listed above.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '6'
);

-- Part 1 / Ch 1 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$A typical re-roof installation follows this general sequence. This overview is for awareness only — it is not an installation specification.

1. **Tear-off** — existing shingles, flashings, and underlayment are removed down to the deck.
2. **Deck inspection and repair** — production crew checks the deck for soft, rotten, or delaminated areas and replaces affected sheathing.
3. **Drip edge** — installed along the eaves first, then rakes (sequence varies by manufacturer specification and local code).
4. **Underlayment** — rolled out from eave to ridge, overlapping each course.
5. **Ice and water shield** *(where required)* — applied at eaves, valleys, and around penetrations.
6. **Flashings** — installed at sidewalls, headwalls, valleys, and around penetrations.
7. **Starter strip** — installed along the eave.
8. **Field shingles** — installed in courses from eave to ridge.
9. **Ridge cap** — installed last, over the ridge and any hips.
10. **Cleanup and final inspection.**

> **[CHECK MANUFACTURER]** Fastening pattern, nail placement, exposure, and starter requirements vary by product. Reps should not specify these details — they are determined by the manufacturer and the installation crew.

> **[VERIFY LOCALLY]** California building code, local jurisdiction requirements, and Title 24 energy provisions may affect underlayment, ventilation, and cool-roof requirements. Confirm with code official or production manager.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '7'
);

-- Part 1 / Ch 1 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$Composition shingle lifespan is one of the most misunderstood topics in residential roofing.

- **Industry rating range:** Manufacturer ratings commonly fall between 25 and 50 years. These are laboratory estimates, not service-life guarantees.
- **Real-world field range (architectural shingles, NorCal):** roughly **18–25 years**, with significant variation based on conditions below. Premium designer shingles can exceed this; three-tab shingles typically fall below.
- **Factors that shorten lifespan:** poor attic ventilation, sun-exposed slopes (especially south and west), proximity to coast (salt air, fog cycles), tree overhang and debris accumulation, repeated foot traffic, deferred maintenance, and improper installation.
- **Factors that extend lifespan:** good attic ventilation, balanced solar exposure, regular cleaning of debris and gutters, prompt repair of small issues, and quality installation.

> **[VERIFY LOCALLY]** NorCal climate ranges from coastal fog (Bay Area, North Coast) to hot inland summers (Sacramento Valley, foothills). South- and west-facing slopes in inland zones generally show wear earlier than coastal-shaded slopes. Confirm specific patterns with field experience.

### What reps must NOT promise

- Specific service-life numbers ("this roof will last 25 years")
- Outcomes contingent on weather, maintenance, or future installations
- Lifespan based on manufacturer rating alone

### Suggested customer language

> "Architectural shingles in this area commonly perform in the range of about 18 to 25 years, but real-world results depend on ventilation, exposure, and maintenance. Based on what we're seeing on your roof today, here's what we'd expect…"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '8'
);

-- Part 1 / Ch 1 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Affordable** relative to tile, slate, and metal — strong cost-per-year-of-service when properly maintained.
- **Wide product selection** — colors, profiles, and price points to match most homes.
- **Familiar to crews** — most residential roofing crews are highly experienced with composition shingle, which generally improves installation consistency.
- **Easier to repair** than tile, slate, or metal — individual shingles or sections can typically be replaced.
- **Compatible with most residential structures** without engineering modifications.
- **Faster installation** than tile or slate, which usually means a shorter project window for the homeowner.
- **Improving fire resistance** — most modern composition shingles are rated **Class A** (the highest fire-resistance rating for roof coverings under standard testing).$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '9'
);

-- Part 1 / Ch 1 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Shorter lifespan** than tile, metal, or slate.
- **More vulnerable to wind** than mechanically attached tile or properly fastened metal — wind uplift can lift or tear tabs.
- **Granule loss is progressive and irreversible** — once granules are gone, the asphalt is exposed to UV and degrades faster.
- **Heat-sensitive** — high attic temperatures and direct sun exposure accelerate aging on inland NorCal homes.
- **Algae and moss susceptibility** — especially on north slopes and shaded areas common in coastal and foothill NorCal.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '10'
);

-- Part 1 / Ch 1 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Light surface granule loss | Monitor | Slight thinning of granule cover, asphalt not yet exposed |
| Algae streaking (black streaks) | Monitor → Maintenance | Dark vertical streaks, typically on north slopes |
| Moss growth | Maintenance | Green or brown moss along course edges or in shaded areas |
| Lifted or curling tab edges | Maintenance → Repair | Edges curling upward, no longer lying flat |
| Cracked or split shingles | Repair | Visible splits across one or more shingles |
| Missing shingles or tabs | Repair → Urgent | Bare deck or underlayment visible |
| Exposed nails (failed seal) | Repair | Nail heads visible through shingle surface |
| Damaged or deteriorated flashing | Repair → Urgent | Lifted, rusted, or separated metal at penetrations or sidewalls |
| Sagging deck | Urgent | Visible dip in roof plane indicating structural concern |
| Active interior leak | Urgent | Water staining, drip, or peeling paint inside the home |
| Granules in gutters (heavy accumulation) | Maintenance → Repair | Indicates advanced surface wear |
| Hail bruising | Repair → Urgent | Soft spots or impact craters; requires trained inspection |
| Wind damage (lifted strips) | Repair → Urgent | Long horizontal lifts of shingles after a wind event |
| Improper or missing flashing at skylight or chimney | Repair → Urgent | Visible gaps, sealant-only repairs, leak history |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not diagnose hail damage for insurance purposes, certify storm damage, or determine root cause of a leak.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '11'
);

-- Part 1 / Ch 1 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$Work through the inspection in this order. Skip steps you cannot safely perform — escalate instead.

**Ground-level walk-around**
- Photograph all four elevations
- Look for missing, lifted, or discolored shingles
- Note tree overhang, debris, and gutter condition
- Note penetrations: chimney, vents, skylights, satellite mounts

**Gutter check**
- Look for granules in gutters (handful or more = significant)
- Note gutter slope, sagging, or detachment

**Ladder edge (where safe)**
- Check drip edge condition
- Note starter strip exposure
- Photograph eave detail

**Roof surface (if safe and trained)**
- Inspect each slope separately
- Photograph all penetrations and flashings
- Photograph all valleys
- Note any soft spots underfoot — **escalate immediately**

**Attic check (if accessible)**
- Look for daylight at penetrations or eaves
- Note water staining on deck, rafters, or insulation
- Note ventilation provisions
- Note insulation depth and condition

**Red flags requiring immediate escalation**
- Active leak inside the home
- Visibly sagging roof plane
- Soft or spongy deck underfoot
- Significant hail or wind damage suspected
- Mold or biological growth in attic
- Asbestos suspected in older underlayment$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '12'
);

-- Part 1 / Ch 1 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$The recommendation depends on roof age, condition, and customer goals — not on margin.

### Scenario A: 8-year-old roof, light granule loss, one lifted shingle

- **Good (right call):** spot repair the lifted shingle, document condition, recommend annual maintenance.
- **Better:** consider Fresh Roof rejuvenation if shingle profile and condition qualify (see Chapter 4).
- **Best:** *Not appropriate.* Replacement on a roof with this much remaining life would be a hard sell that damages trust.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof guidance on when reps should *not* propose replacement.

### Scenario B: 18-year-old roof, moderate granule loss, two leak points, intact deck

- **Good:** repair the two leak points, monitor closely. Buys time but does not address the underlying age of the system.
- **Better:** evaluate for rejuvenation if the roof qualifies. Honest about what rejuvenation does and does not do (see Chapter 4).
- **Best:** plan for replacement within 1–3 years. Present this as the long-term answer while offering interim options.

### Scenario C: 25-year-old three-tab roof, widespread granule loss, multiple leaks, soft deck areas

- **Good:** *Not appropriate.* Targeted repair on a roof at end of life is short-term spending without long-term benefit.
- **Better:** *Not appropriate.* Rejuvenation does not restore a roof at end of life.
- **Best (right call):** full replacement, including deck repair and updated flashings.

> **[VERIFY LOCALLY]** Title 24 cool-roof and ventilation requirements may apply to full replacement. Confirm with code official.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '13'
);

-- Part 1 / Ch 1 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$Two warranties cover most shingle roofs, and they are not the same thing.

- **Manufacturer (material) warranty** — covers the shingle product itself against manufacturing defects. Typically advertised as a long-term or "lifetime" warranty, but the practical coverage drops significantly after the first several years (the **non-prorated period**) and becomes prorated after that. *Prorated* means the manufacturer's payout decreases each year.
- **Workmanship (contractor) warranty** — covers the installation. Issued by the roofing contractor, not the manufacturer. Length and terms vary widely between contractors.

### What commonly voids or limits warranties

- Improper installation (often voids manufacturer warranty)
- Inadequate ventilation
- Roof-mounted equipment installed by other trades without protection
- Pressure washing
- Unapproved repairs by other contractors
- Lack of documented maintenance

### What reps must not promise

- That the manufacturer will pay full replacement cost on an aging roof
- That a workmanship warranty transfers automatically on home sale
- That a "lifetime" warranty means the roof lasts a lifetime
- Specific warranty outcomes without reading the actual document

> **[COMPANY POLICY]** Placeholder — USA Flat Roof workmanship warranty terms, transferability, and registration requirements.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '14'
);

-- Part 1 / Ch 1 / Sec 15: Ideal Customer Profile + Pain Points
UPDATE sections SET
  content_markdown = $mfst$| Customer type | Why they call | Common pain points |
|---|---|---|
| Homeowner (current roof leaking) | Active or recent leak | Anxiety about damage, urgency, fear of being upsold |
| Homeowner (planning ahead) | Old roof, no leak yet | Wants to budget, compare options, understand timeline |
| Homeowner (storm or wind event) | Visible damage | Insurance questions, urgency, confusion about claim process |
| Property manager | Tenant complaint or scheduled inspection | Wants documented condition, options, and clear pricing |
| Real estate agent or seller | Pre-sale inspection | Needs disclosure-quality documentation and fast turnaround |
| Buyer (post-inspection) | Inspection report flagged the roof | Needs second opinion and honest scope |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '15'
);

-- Part 1 / Ch 1 / Sec 16: Lead Qualification Questions
UPDATE sections SET
  content_markdown = $mfst$Ask these before or during the inspection:

1. How old is the current roof, to your best knowledge?
2. Has the roof had any repairs in the past five years?
3. Is there an active leak, or have you seen one recently?
4. Have you noticed any interior staining, peeling paint, or musty smells?
5. Are there any rooms or areas where you've placed buckets or moved furniture during a storm?
6. Has there been any recent storm, wind, or hail event?
7. Do you know what type of shingle is up there — three-tab, architectural, or designer?
8. Do you have any documentation from the original installation or past repairs?
9. Are you the original owner, or did you inherit the roof at purchase?
10. What's your timeline — immediate concern, planning ahead, or evaluating for sale?
11. Are you working with insurance on this?
12. What outcome would make this call a success for you today?$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '16'
);

-- Part 1 / Ch 1 / Sec 17: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "A composition shingle roof is built in layers. The shingles you see are the outer protection — they shed water and protect the layers underneath. Underneath the shingles is an underlayment, then the wood deck, then your attic. When a roof fails, it's almost always at a transition point — where two slopes meet, where a vent comes through, or along the edges. That's why our inspection focuses on those areas first, not just the surface."

### Talking points (honest selling angles)

1. Composition shingle is the most common residential roof for a reason — strong cost-per-year-of-service when installed well and maintained.
2. The system is only as good as its weakest detail. Flashings and ventilation matter more than the shingle brand.
3. Regular maintenance materially extends roof life. Most roofs we replace early were neglected, not defective.
4. Repair, rejuvenation, and replacement are all valid answers in the right circumstances. Our job is to tell you which one fits your roof — even when the answer is the smaller job.
5. Documentation today protects you tomorrow — for warranty claims, insurance, and resale.

### FAQ

- **Q: How long will my new roof last?** A: Architectural shingles in this area commonly perform in the range of about 18 to 25 years, depending on ventilation, exposure, and maintenance. We won't quote a specific number — but we will quote you on the work and the workmanship warranty.
- **Q: Should I just patch it?** A: Sometimes yes. If the roof has good remaining life and the issue is localized, a targeted repair is the right call. We'll be straight with you about that.
- **Q: What's the difference between a 30-year and 50-year shingle?** A: Mostly weight, layers, and the manufacturer's warranty length. The real-world lifespan difference is smaller than the labels suggest. Ventilation and installation quality matter more.
- **Q: Do I need to replace the whole roof if only one slope is bad?** A: Not always, but partial replacement has trade-offs — color match, warranty implications, and how the new section ties into the old. We'll lay those out.
- **Q: Can I just put new shingles over the old ones?** A: A roof-over (also called overlay) is allowed in some cases but not always recommended. It saves on tear-off cost but adds weight, hides deck issues, and shortens the new roof's life. We'll tell you when it makes sense and when it doesn't.
- **Q: My neighbor's roof looks fine and it's the same age as mine — why is mine worse?** A: Slope direction, tree cover, ventilation, and original installation can all create big differences between two homes built the same year.
- **Q: Will the manufacturer warranty cover this?** A: Possibly — but manufacturer warranties on aging roofs are often prorated and have specific exclusions. We'll review your documentation and walk through what's actually covered.

### Objections & Responses

- **"You're more expensive than the other guys."** A: Possibly. The number on a proposal is one part of the picture — the other parts are scope, deck repair allowance, flashing replacement, ventilation, and workmanship warranty. We're glad to walk you through where the numbers are different and let you decide.
- **"I just need a quick patch."** A: We can do that, and sometimes it's the right answer. Before we patch, let us confirm the leak source — patching the wrong spot is more expensive than patching the right one.
- **"I'm waiting until I have an actual leak."** A: That's a fair instinct — but most leaks first appear inside the home after damage has been happening above for months. A leak inside is the late stage, not the early one.
- **"Insurance should pay for this."** A: Maybe. We can document conditions for your claim, but we won't promise a claim outcome — that's between you and your carrier. We'll do our part honestly.
- **"Can you just throw new shingles over the old ones?"** A: Sometimes that's allowed, but it's rarely the better long-term move. Let us show you the trade-offs before you decide.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number ("this will last 30 years")
- Promising insurance approval or a specific claim payout
- Recommending replacement on a roof with significant remaining life
- Talking down a competitor's work without seeing it
- Using fear language about the deck or structure without documentation
- Promising warranty outcomes without reading the actual warranty
- Diagnosing mold, asbestos, or structural failure outside your training$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '17'
);

-- Part 1 / Ch 1 / Sec 18: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Repair recommendation:**
> Based on our inspection, the roof has remaining service life. We recommend targeted repair of [specific areas], replacement of damaged flashings at [location], and resealing of exposed fasteners. We do not recommend full replacement at this time. Recommend annual maintenance inspection to monitor condition.

**Rejuvenation recommendation:**
> The shingles show moderate weathering but remain structurally intact. The roof qualifies for Fresh Roof rejuvenation treatment, which is intended to restore flexibility and extend useful service life. Rejuvenation is not a leak repair and does not address damaged flashings, deck issues, or end-of-life shingles. Recommended scope: [specific areas, prep, application]. **[CHECK MANUFACTURER]** Confirm qualifying conditions and warranty terms with current Fresh Roof documentation.

**Replacement recommendation:**
> Based on inspection findings, the existing roof has reached the end of its useful service life. Conditions observed include [list]. We recommend full tear-off and replacement, including [scope]. Deck repair allowance included for unforeseen sheathing damage discovered during tear-off. Workmanship warranty per USA Flat Roof terms.

**Maintenance recommendation:**
> The roof is in good general condition. We recommend a maintenance service consisting of [scope]: debris clearing, fastener resealing, flashing inspection, and minor sealant work as needed. Documentation provided for warranty and resale records.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '18'
);

-- Part 1 / Ch 1 / Sec 19: Role-Play Scenario
UPDATE sections SET
  content_markdown = $mfst$**Setting:** Single-story 1995 home in Walnut Creek. Owner called because of a water stain on the dining room ceiling after the last storm. Roof is original three-tab composition shingle.

**Customer:** "I just need someone to patch where it's leaking. The roof's been fine for 30 years."

**Rep should:**

1. Acknowledge the customer's framing without dismissing it.
2. Inspect to confirm the leak source — interior stain location is rarely directly under the actual roof breach.
3. Document conditions honestly: roof age, granule loss, flashing condition, deck access if available.
4. Present options based on what was found, not what is most profitable.
5. Handle the objection if the recommendation is replacement.

**Sample handling of the objection:**

> "I hear you, and I want to give you the answer that's right for your roof — not the one that sounds best. The leak we found isn't where the ceiling stain is; it's at the chimney flashing about 6 feet uphill. That's a real repair. But while we were up there, we also documented [conditions]. The roof itself is at 30 years on a three-tab — past most service ranges. If you want, we can patch the chimney today, and I can put a replacement option on paper for you to look at on your timeline. No pressure, just honest information."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '19'
);

-- Part 1 / Ch 1 / Sec 20: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every inspection:**

- All four elevations from ground level
- Each roof slope from elevated view (drone or ladder edge)
- Every penetration (vents, pipes, chimneys, skylights)
- Every valley
- Every flashing detail (sidewall, headwall, drip edge, valley)
- Any damage close-up with reference scale (tape measure or business card)
- Gutters at downspouts (granule check)
- Attic interior if accessible
- Interior leak evidence if reported

**Measurements to record:**

- Roof footprint (linear measurements)
- Slope (pitch) — measure or estimate to nearest 1:12
- Number of slopes, valleys, hips, and ridges
- Penetration count and types

**Conditions to note:**

- Roof age (best estimate, source of estimate)
- Shingle profile (three-tab, architectural, designer)
- Number of layers (if visible at edge)
- Ventilation provisions
- Tree overhang and debris exposure

**Severity rating to apply** to each documented condition using the four-point scale.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '20'
);

-- Part 1 / Ch 1 / Sec 21: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active interior leak with unknown source
- Soft, spongy, or visibly sagging deck
- Suspected hail or storm damage involving an insurance claim
- Suspected mold, asbestos, or other hazard
- Multiple roof layers (overlay history)
- Code-related questions (Title 24, ventilation, cool-roof requirements)
- Solar array on the roof — interaction with re-roof scope and warranty
- Customer requesting specific warranty interpretation
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '21'
);

-- Part 1 / Ch 1 / Sec 22: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred inspection process: [placeholder]
> - Our photo standards: [placeholder]
> - Our standard repair options: [placeholder]
> - Our criteria for proposing rejuvenation: [placeholder]
> - Our criteria for proposing replacement: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language: [placeholder]
> - Our sales-to-production handoff process: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '22'
);

-- Part 1 / Ch 1 / Sec 23: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They quote shingle lifespan based on the package rating instead of field conditions.
- They confuse manufacturer warranty length with actual service life.
- They miss flashing failures because they focus on the field shingles.
- They recommend replacement on roofs with significant remaining life because the proposal is easier to write than a repair scope.
- They underestimate how much ventilation drives lifespan.

**Discussion questions for group training**
- Why is "lifetime warranty" not the same as "lifetime roof"?
- Walk through the Scenario B example (18-year-old roof). What would push the recommendation toward repair? Toward rejuvenation? Toward replacement?
- A customer says "just patch it" but you found an end-of-life condition. What's your script?
- What's the honest answer to "your competitor said they could overlay this — why can't you?"

**Field exercises**
- Pair up. One rep walks the other through a roof inspection from photos only. Identify three conditions and apply severity ratings.
- Review three real proposals. Identify any language that overpromises lifespan, warranty, or insurance outcome.
- Practice the role-play scenario in Section 19. Rotate customer and rep roles.

**What the manager should test verbally**
- Distinguish three-tab from architectural from designer.
- Name five components of the system.
- Recite the four severity-scale levels and give an example of each.
- Walk through a Good/Better/Best presentation for a 12-year-old roof with two leak points.
- State five things a rep must not promise.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '23'
);

-- Part 1 / Ch 1 / Sec 24: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Architectural (dimensional, laminated) shingle** — multi-layer composition shingle with shadowed, textured appearance.
- **Asphalt** — petroleum-based waterproofing layer that bonds the fiberglass mat and granules.
- **Class A fire rating** — highest fire-resistance rating for roof coverings under standard testing.
- **Composition (asphalt) shingle** — fiberglass-mat shingle with asphalt and mineral-granule surfacing.
- **Deck** — structural sheathing under the roof system, typically plywood or OSB.
- **Drip edge** — metal flashing at eaves and rakes.
- **Field shingle** — main shingle covering the roof surface.
- **Flashing** — metal at penetrations, sidewalls, valleys, and chimneys.
- **Granule** — ceramic-coated rock particle on the shingle surface.
- **Manufacturer (material) warranty** — covers shingle product defects.
- **Non-prorated period** — initial warranty years with full coverage.
- **Prorated** — reduced payout based on age.
- **Pitch (slope)** — vertical rise per 12 inches of horizontal run.
- **Ridge cap** — specialty shingle along the peak.
- **Starter strip** — first course at the eave.
- **Three-tab shingle** — flat single-layer shingle with cutouts.
- **Underlayment** — water-resistant layer between deck and shingle.
- **Workmanship (contractor) warranty** — covers installation quality.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '24'
);

-- Part 1 / Ch 1 / Sec 25: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Composition shingle is the dominant residential roof system in Northern California and across the U.S. It is a layered system in which the shingle surface is only the most visible part — the deck, underlayment, flashings, and ventilation determine real performance. Architectural shingles in NorCal commonly perform in the range of about 18 to 25 years, with significant variation based on ventilation, exposure, and maintenance. Reps must avoid quoting specific lifespans, promising warranty outcomes, or recommending replacement on roofs with remaining service life. Honest classification on the four-point Inspection Severity Scale, combined with a Good/Better/Best framework that includes Fresh Roof rejuvenation when appropriate, is the foundation of consultative selling. Documentation, photos, and severity ratings protect both the customer and the company. Reps should escalate any condition exceeding their training, including suspected structural, hazard, or insurance-claim issues.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '25'
);

-- Part 1 / Ch 1 / Sec 26: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** Which component sits directly between the roof deck and the shingles?
A. Drip edge
B. Underlayment
C. Ridge cap
D. Starter strip

**2. (Beginner)** What is the primary purpose of granules on a composition shingle?
A. Improve appearance
B. Add weight for wind resistance
C. Protect the asphalt from sunlight
D. Bond the shingles to the deck

**3. (Beginner)** Which type of shingle is the current industry standard for new residential roofs?
A. Three-tab
B. Architectural
C. Designer slate-look
D. Roll roofing

**4. (Beginner)** A "Class A" fire rating means the shingle is:
A. Fireproof under all conditions
B. Rated at the highest level of fire resistance under standard testing
C. Approved for commercial buildings only
D. Treated with fire-retardant coating after manufacture

**5. (Intermediate)** A rep finds light granule loss, intact flashings, and no leaks on an 8-year-old architectural shingle roof. The most appropriate severity rating for the granule loss is:
A. Monitor
B. Repair Recommended
C. Urgent / Escalate
D. End of life

**6. (Intermediate)** Which of the following most often shortens shingle lifespan in inland Northern California?
A. Coastal salt air
B. Poor attic ventilation combined with sun exposure
C. Snow load
D. Heavy rainfall

**7. (Intermediate)** A homeowner asks the rep to confirm their new roof will last 30 years. The best response is to:
A. Confirm 30 years based on the manufacturer's rating
B. Provide a range based on field conditions and avoid a specific guarantee
C. Quote the warranty length as the lifespan
D. Tell the customer no roof lasts 30 years

**8. (Intermediate)** Which condition most clearly warrants escalation rather than a sales recommendation?
A. Algae streaks on the north slope
B. A handful of granules in the gutter
C. A visibly sagging roof plane
D. One lifted shingle tab

**9. (Advanced)** A customer says, "Just patch the leak — the roof's only 30 years old and it's been fine." On inspection, the roof is original three-tab with widespread granule loss, two active leak points, and soft deck areas. The most honest recommendation is:
A. Patch the leak as requested and document the call
B. Recommend Fresh Roof rejuvenation
C. Recommend full replacement and explain why repair and rejuvenation are not appropriate at this stage
D. Decline the job

**10. (Advanced)** A homeowner asks why their south-facing slope shows more wear than the north slope on the same roof. The most accurate explanation is:
A. The shingles on the south slope were defective
B. South-facing slopes in inland NorCal typically receive more direct sun exposure, which accelerates aging
C. The original installer skipped underlayment on the south slope
D. The north slope is protected by the manufacturer warranty

---

### Answer Key

1. **B — Underlayment.** It sits between the deck and shingles. Drip edge (A) is at the edges, ridge cap (C) is at the peak, starter strip (D) is at the eave only.
2. **C — Protect the asphalt from sunlight.** Once granules are gone, the asphalt degrades from UV exposure. Appearance (A) is a side benefit, not the primary purpose.
3. **B — Architectural.** Three-tab (A) is now uncommon on new installs. Designer (C) is a premium tier, not the standard.
4. **B — Highest level of fire resistance under standard testing.** "Fireproof" (A) overstates what any rating guarantees.
5. **A — Monitor.** Light granule loss with no other failure is consistent with normal early-life wear. Repair (B) and Urgent (C) overstate the condition.
6. **B — Poor attic ventilation combined with sun exposure.** Inland NorCal sees hot summers and high attic temperatures. Coastal salt air (A) matters in coastal zones, not inland.
7. **B — Provide a range based on field conditions and avoid a specific guarantee.** Confirming 30 years (A) and quoting warranty length as lifespan (C) both violate the no-fake-precision rule.
8. **C — A visibly sagging roof plane.** Structural concern always escalates. Algae (A) and a few granules (B) are normal monitor or maintenance items.
9. **C — Recommend full replacement and explain why repair and rejuvenation are not appropriate.** Patching (A) is short-term spending without long-term benefit on an end-of-life roof. Rejuvenation (B) does not restore end-of-life shingles. Declining (D) abandons the customer.
10. **B — South-facing slopes typically receive more direct sun exposure, which accelerates aging.** Defective shingles (A) and skipped underlayment (C) are unsupported assumptions. Warranty (D) does not protect against sun exposure.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '26'
);

-- Part 1 / Ch 1 / Sec 27: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California climate?
- [ ] Accurate for the shingle products USA Flat Roof installs?
- [ ] Matches USA Flat Roof workmanship warranty language?
- [ ] Matches USA Flat Roof inspection process and photo standards?
- [ ] Matches USA Flat Roof production capabilities (deck repair, flashing replacement, ventilation upgrades)?
- [ ] Are escalation triggers correct for our team structure?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the Fresh Roof reference match our current partnership terms?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: any specific shingle product references (kept generic in this draft — verify if USA Flat Roof prefers naming a primary brand).
- Code-dependent items: Title 24 cool-roof and ventilation language. Confirm with current California Energy Commission requirements and local jurisdictions.
- Regional climate assumptions: 18–25 year NorCal field range. Verify with USA Flat Roof field experience across coastal, Bay, Valley, and foothill markets.
- Warranty-related statements: prorated/non-prorated language, transferability, USA Flat Roof workmanship terms — needs review against actual warranty document.
- Company policy items: every [COMPANY POLICY] placeholder in Section 22.
- Fresh Roof claims: all rejuvenation language flagged — verify against current Fresh Roof contractor documentation, qualifying conditions, and warranty terms.
- Sales scripts and proposal language: review against USA Flat Roof current standard proposals and approved customer-facing language.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 1 AND s.section_number = '27'
);

-- Part 1 / Ch 2 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify TPO roofs on sight and distinguish them from PVC and other single-ply systems.
2. Name the main components of a mechanically attached TPO system and explain their function in plain language.
3. Inspect a TPO roof from the ground, ladder edge, or roof surface and classify common conditions on the Inspection Severity Scale.
4. Recommend repair, restoration (silicone coating), or replacement honestly based on roof condition.
5. Explain TPO lifespan, seam behavior, ponding water, and warranty structure to a customer in language that builds trust without overpromising.
6. Recognize when a roof condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '1'
);

-- Part 1 / Ch 2 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**TPO** stands for **thermoplastic polyolefin** — a single-ply roof membrane used primarily on flat and low-slope commercial buildings. The word "thermoplastic" means the material can be melted and re-melted by heat. This matters in installation: TPO seams are joined by **hot-air welding**, where a robotic or hand welder heats the overlapping edges of two sheets until the polymer melts and the sheets fuse into one continuous membrane.

A **single-ply** roof means the waterproofing layer is one engineered sheet, as opposed to a multi-layer **built-up** assembly. TPO has become the dominant flat-roof system on new commercial construction in much of the United States.

USA Flat Roof installs TPO primarily as **60-mil mechanically attached** systems. *60-mil* refers to membrane thickness — 60 thousandths of an inch. *Mechanically attached* means the membrane is fastened to the deck with screws and plates at regular intervals along the seams.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard TPO product lines, color options, and any thicker-mil offerings (80-mil) for specific applications.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '2'
);

-- Part 1 / Ch 2 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Primary use:** flat and low-slope commercial roofs — warehouses, retail centers, office buildings, restaurants, light industrial
- **Common in:** multi-tenant commercial buildings, mixed-use buildings with flat roof sections, schools, religious buildings, distribution centers
- **Less common on:** single-family residential (most residential is steep-slope shingle or tile in NorCal), historic buildings, structures with extensive curved or sloped geometry

In Northern California, TPO is widely used across Bay Area commercial corridors, Sacramento Valley industrial parks, and retail/restaurant buildings throughout the region. It is particularly common on re-roofs replacing aging built-up roofs (BUR) or modified bitumen.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '3'
);

-- Part 1 / Ch 2 / Sec 4: What It Looks Like + Ground-Level Recognition Clues
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

- Smooth, matte-finish membrane covering the roof in large sheets
- Most commonly **white** (cool-roof reflective), though gray and tan are also available
- Visible **seams** running across the roof at regular intervals where sheet edges overlap
- Visible **fastener rows** along seams in mechanically attached systems — small bumps under the membrane where screws and plates sit
- Welded flashings at parapet walls, curbs, drains, and penetrations
- Smooth, clean appearance compared to gravel-surfaced BUR or granule-surfaced modified bitumen

### Recognition by viewpoint

- **Street view (low-rise buildings):** white reflective surface visible from upper floors of adjacent buildings; long horizontal sightlines often impossible from street level alone.
- **Drone or satellite view:** large white rectangular sheets, visible seams, drains, HVAC penetrations. The most reliable way to ID a flat roof remotely.
- **Ladder edge:** visible parapet flashing where the membrane wraps up the wall, terminating under metal coping or a termination bar.
- **Roof surface:** seams (typically running long-direction across the roof), fastener bumps along seams, T-joints where three sheets meet, drains and penetration boots.
- **Interior leak evidence:** ceiling tile staining (most common in commercial), efflorescence (white salt deposits) on parapet wall interiors, water tracking along electrical conduits.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '4'
);

-- Part 1 / Ch 2 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **PVC** | PVC is also a white single-ply welded membrane and looks nearly identical from a distance. Up close, PVC is slightly more flexible and slick to the touch; TPO is firmer. The most reliable distinction is documentation, not appearance. **Reps should not certify PVC vs TPO without product documentation.** |
| **EPDM** | EPDM is rubber and almost always **black** (occasionally white). EPDM seams are glued or taped, not welded. Surface texture is matte-rubbery, not plastic. |
| **Modified bitumen (mod-bit)** | Mod-bit has a granular surface (looks like rolled shingle) or a smooth black/gray asphalt surface with torch-down or self-adhered seams. No hot-air welds. |
| **Built-Up Roofing (BUR)** | BUR usually has a gravel surface or a smooth asphalt cap. Multi-layer construction visible at edges. No single welded membrane. |
| **Acrylic or silicone coating over an old roof** | A coated roof has a painted appearance with brush or spray texture, not the smooth uniform finish of a factory-made membrane. Coatings often show overspray on flashings, equipment, or parapet caps. |

> **[SALES REP BOUNDARY]** Reps may identify the system as "appears to be TPO" based on visual indicators. They should not certify product type, manufacturer, or installation date without documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '5'
);

-- Part 1 / Ch 2 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A mechanically attached TPO system is layered. From the structure up:

1. **Roof deck** — structural sheathing. Most commonly metal (steel) on commercial buildings; sometimes wood, concrete, or gypsum.
2. **Vapor retarder** *(in some assemblies)* — a layer that limits water-vapor migration into the insulation from inside the building. Used in specific climate and occupancy conditions.
3. **Insulation** — typically **polyiso (polyisocyanurate)** rigid foam boards. Insulation provides thermal performance and a base layer for the membrane. Thickness varies by code and design.
4. **Cover board** — a hard board (commonly gypsum-based or high-density polyiso) installed over the insulation to provide a stable substrate, improve fire performance, and protect the insulation from foot traffic and hail.
5. **TPO membrane (60-mil)** — the waterproofing sheet itself. Installed in rolls, with overlapping seams welded together.
6. **Fasteners and plates** — screws driven through the membrane, cover board, and insulation into the deck along seam lines, with metal or plastic plates that distribute load.
7. **Welded seams** — where sheet edges overlap; hot-air welded into a single continuous membrane.
8. **Flashings** — TPO-coated metal or membrane flashings at parapet walls, curbs (raised platforms around HVAC units), drains, penetrations, and edge terminations.
9. **Termination details** — termination bars, counter-flashing, sealant, and metal coping at parapet tops.
10. **Drains and scuppers** — primary drains, overflow drains, and scuppers (wall openings that drain water through the parapet) handle water removal. **Drainage is part of the roof system, not an accessory.**

[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a 60-mil mechanically attached TPO assembly showing metal deck, insulation, cover board, membrane, fastener and plate at seam, and a typical parapet termination.
Purpose: Help reps visualize the layered system.
Caption: Cross-section of a typical mechanically attached TPO assembly. Components shown are conceptual; actual installations vary.
Alt text: Diagram of a TPO roof assembly showing deck, insulation, cover board, membrane, fasteners, and parapet flashing.
Annotation needed: Yes — label all components listed above.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '6'
);

-- Part 1 / Ch 2 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$A typical mechanically attached TPO installation follows this general sequence. This overview is for awareness only — not an installation specification.

1. **Preparation** — existing roof removed (if a tear-off) or prepared (if a recover). Deck inspected and repaired.
2. **Vapor retarder** *(if specified)* — installed over the deck.
3. **Insulation** — polyiso boards laid in courses, mechanically fastened or adhered per design.
4. **Cover board** — installed over insulation, fastened or adhered per design.
5. **TPO membrane** — rolls laid out, positioned with the specified overlap.
6. **Mechanical attachment** — fasteners and plates driven along the seam edge, attaching the membrane through cover board and insulation into the deck.
7. **Hot-air welding** — overlapping sheet edges welded with automated robot welder for long runs and hand welder for details.
8. **Flashings** — wall flashings, curb flashings, drain flashings, and pipe boots installed and welded in.
9. **Terminations** — termination bars, sealant, counter-flashing, and metal coping installed.
10. **Final inspection** — including a probe test of every welded seam to confirm fusion.

> **[CHECK MANUFACTURER]** Fastener spacing, welding parameters (temperature and speed), and detail requirements vary by manufacturer and wind-uplift design. Reps should not specify these details — they are determined by the manufacturer and project documents.

> **[VERIFY LOCALLY]** California Title 24 cool-roof requirements affect membrane color and reflectivity for many commercial occupancies. Local jurisdiction may add wind-uplift, fire, or insulation requirements. Confirm with code official or production manager.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '7'
);

-- Part 1 / Ch 2 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$- **Industry rating range:** Manufacturer warranties commonly run 15, 20, or 25 years depending on system, thickness, and contractor program participation. Warranty length is not the same as service life.
- **Real-world field range (60-mil mechanically attached, NorCal):** roughly **18–25 years** with reasonable maintenance. Premium systems and ideal conditions may exceed this; harsh conditions, ponding, or installation issues can shorten it.
- **Factors that shorten lifespan:** chronic ponding water, high foot traffic without protection, heavy rooftop equipment work, UV exposure on weak seams, mechanical damage, biological staining left untreated, deferred maintenance.
- **Factors that extend lifespan:** good drainage, walk pads at high-traffic areas, regular inspections, prompt repair of seam issues and punctures, cleaning, and correct flashing details at penetrations.

> **[VERIFY LOCALLY]** NorCal sun and UV exposure varies significantly between coastal fog belt and inland Valley. Inland buildings see higher membrane temperatures and slightly accelerated aging. Confirm specific patterns with field experience.

### What reps must NOT promise

- Specific service-life numbers
- Warranty payouts on aging systems
- Coating or restoration outcomes that exceed actual product capability
- Outcomes contingent on customer maintenance behavior

### Suggested customer language

> "60-mil TPO commonly performs in the range of about 18 to 25 years in this area, depending on drainage, maintenance, and how heavily the roof is used by other trades. Based on what we're seeing on your roof today, here's what we'd expect…"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '8'
);

-- Part 1 / Ch 2 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Cost-competitive** with other commercial single-ply systems for typical applications.
- **Reflective white surface** reduces cooling loads — particularly valuable for inland NorCal commercial buildings and important for Title 24 compliance on many occupancies.
- **Welded seams** create a continuous monolithic membrane stronger than the sheet material itself when properly installed.
- **Lighter than BUR or modified bitumen** — usable on a wider range of structures without engineering modifications.
- **Faster installation** than multi-layer systems, which generally means a shorter project window for the building owner.
- **Repairable** — punctures, seam issues, and flashing problems can typically be repaired with patches and additional welding.
- **Restorable in many cases** — properly conditioned TPO roofs can be restored with silicone coating to extend service life (see Chapter 3 and Chapter 18).$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '9'
);

-- Part 1 / Ch 2 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Seams are the weakest point** of any single-ply system. Quality of the original weld determines long-term performance.
- **Ponding water** is common on low-slope roofs and degrades any membrane over time. TPO is no exception.
- **Mechanical damage from foot traffic and rooftop trades** is one of the most common failure causes — HVAC technicians, electricians, and other contractors regularly damage roofs without reporting it.
- **Membrane shrinkage** can occur over time with some products, pulling at flashings and seams.
- **UV exposure** gradually degrades the membrane surface, particularly at seams and edges.
- **Compatibility with adjacent materials** matters — petroleum-based products (asphalt, some sealants, some greases) can damage TPO and require careful detailing.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '10'
);

-- Part 1 / Ch 2 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Surface dirt and biological staining | Monitor → Maintenance | Dark patches, particularly on north sides or under tree cover |
| Light ponding (drains within 48 hours of rain) | Monitor | Faint outline rings where water sits temporarily |
| Chronic ponding (water sits longer than 48 hours) | Maintenance → Repair | Persistent water, dirt rings, accelerated wear at the pond |
| Seam separation (visible gap) | Repair → Urgent | Edges no longer fused; gap visible along seam |
| Seam fishmouth | Repair | Small puckered opening along a seam, often from incomplete weld |
| Punctures | Repair | Holes from dropped tools, debris, or foot traffic |
| Membrane tears | Repair → Urgent | Cuts or tears, often from rooftop trade work |
| Failed pipe boot | Repair | Cracked, separated, or shrinking boot at a penetration |
| Failed parapet flashing | Repair → Urgent | Wall flashing pulled, separated, or unsealed |
| Failed termination bar / coping | Repair → Urgent | Loose or missing fasteners; sealant failure |
| Drain failure (clogged or damaged) | Repair → Urgent | Standing water, vegetation, deteriorated drain ring |
| Membrane shrinkage at perimeter | Repair → Urgent | Flashings pulling tight, exposed termination |
| UV degradation / chalking | Maintenance → Repair | Powdery surface, particularly at seams and edges |
| Damage from other trades (HVAC, solar, electrical) | Repair → Urgent | Tool drops, scuffs, sealant smears, unauthorized penetrations |
| Active interior leak | Urgent | Water staining, drip, or ceiling damage inside the building |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify storm or insurance damage, identify root cause of a leak without proper testing, or determine whether a roof qualifies for restoration without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '11'
);

-- Part 1 / Ch 2 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$Work through the inspection in this order. Skip steps you cannot safely perform — escalate instead.

**Building exterior walk-around**
- Photograph all four elevations
- Note parapet condition, coping, scuppers, downspout outlets
- Note any signs of efflorescence or staining on exterior walls

**Roof access**
- Inspect ladder, hatch, or stair access for safety
- Note any code violations or missing safety equipment

**Roof surface — general**
- Photograph each quadrant of the roof
- Note overall membrane color, dirt level, biological staining
- Note presence and condition of walk pads at high-traffic areas

**Seam-by-seam inspection**
- Walk every seam if safely accessible
- Photograph any seam separation, fishmouth, or visible weld inconsistency
- Note T-joints (where three sheets meet) — high-failure locations

**Penetrations and details**
- Photograph every pipe, vent, drain, HVAC curb, conduit, and skylight
- Note pipe boot condition, sealant condition, flashing integrity
- Note any unsealed or improperly detailed penetrations

**Drainage**
- Photograph every drain and scupper
- Note debris, vegetation, ponding extent (mark with chalk if available)
- Note overflow drain presence and condition

**Parapet and edge details**
- Inspect parapet flashing along its full length
- Note coping condition, fastener integrity, sealant joints
- Inspect termination bars

**Mechanical attachment indicators**
- Note any visible fastener back-out (raised bumps)
- Note any membrane separation along seams suggesting attachment failure

**Interior check (if accessible)**
- Note ceiling tile staining, water marks, efflorescence
- Note drip patterns relative to known roof penetrations or seams

**Red flags requiring immediate escalation**
- Active interior leak
- Visible structural deflection (sagging deck, ponded water creating depression)
- Suspected wet insulation (soft, spongy underfoot when walked)
- Widespread seam failure
- Unauthorized work by other trades
- Solar array on the roof — interaction with re-roof or restoration scope$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '12'
);

-- Part 1 / Ch 2 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$The recommendation depends on roof age, condition, drainage, and customer goals — not on margin.

### Scenario A: 5-year-old TPO roof, one punctured area, otherwise excellent

- **Good (right call):** repair the puncture with welded patch, document condition, recommend annual maintenance.
- **Better:** *Not appropriate.* The system is in its early life — restoration coating would be premature.
- **Best:** *Not appropriate.* Replacement on a 5-year-old roof in good condition would damage trust and is rarely the right answer.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof guidance on minimum age and condition thresholds before recommending restoration or replacement.

### Scenario B: 16-year-old TPO roof, light surface wear, sound seams, two failed pipe boots, no chronic ponding

- **Good:** repair the two pipe boots, monitor seams, recommend annual maintenance.
- **Better:** evaluate for **silicone coating restoration** if the roof qualifies — sound substrate, minimal ponding, intact seams, addressable details (see Chapter 3 and Chapter 18). Honest about what the coating does and does not do.
- **Best:** plan for replacement within 3–7 years. Present this as the long-term answer while offering interim restoration as a viable bridge.

### Scenario C: 20+-year-old TPO roof, widespread seam failure, chronic ponding, suspected wet insulation, multiple active leaks

- **Good:** *Not appropriate.* Repairs on a system this far gone are short-term spending without long-term benefit.
- **Better:** *Not appropriate.* Coating over wet insulation, failing seams, and ponding is the textbook case of restoration done wrong (see Chapter 3 and Rule 5).
- **Best (right call):** full replacement with insulation evaluation. Wet insulation must be removed; intact insulation may be reusable depending on assessment. Honest scope and pricing.

> **[VERIFY LOCALLY]** Title 24 requirements may apply to full replacement and to certain re-cover scenarios. Confirm with code official.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '13'
);

-- Part 1 / Ch 2 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$Three warranty layers commonly apply to commercial TPO:

- **Manufacturer (material) warranty** — covers the membrane against manufacturing defects. Length varies (commonly 15, 20, or 25 years).
- **Manufacturer system (NDL) warranty** — a stronger warranty that covers the full system (membrane, flashings, accessories) including labor, available only when a manufacturer-certified contractor installs an approved assembly. NDL stands for **No Dollar Limit**, meaning the manufacturer covers qualifying repairs without a cost cap up to the warranty terms.
- **Workmanship (contractor) warranty** — covers installation. Issued by the contractor.

### What commonly voids or limits warranties

- Damage caused by other trades not properly repaired and re-approved
- Modifications, additions, or penetrations made without manufacturer-approved details
- Lack of documented annual inspections (some manufacturers require these)
- Ponding water beyond manufacturer-allowed durations
- Roof traffic and storage not anticipated in the warranty
- Chemical exposure (grease vents, exhaust contamination) outside approved details

### What reps must not promise

- That an aging roof "still has warranty coverage" without reading the actual document
- That an NDL warranty covers all repairs forever — terms always apply
- Specific warranty outcomes for storm or trade-caused damage
- That a transferred warranty automatically applies to a new building owner

> **[COMPANY POLICY]** Placeholder — USA Flat Roof workmanship warranty terms, manufacturer certifications held, NDL warranty availability, and inspection/maintenance requirements for warranty validity.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '14'
);

-- Part 1 / Ch 2 / Sec 15: Ideal Customer Profile + Pain Points
UPDATE sections SET
  content_markdown = $mfst$| Customer type | Why they call | Common pain points |
|---|---|---|
| Building owner (active leak) | Tenant complaint or visible interior damage | Urgency, tenant relations, cost of business interruption |
| Property manager | Scheduled inspection or recurring issues | Wants documented condition, defensible recommendation, clear pricing for owner approval |
| Facility manager (owner-occupant) | Budget planning or known aging roof | Capital planning, downtime concerns, comparison of options |
| Real estate / acquisition | Pre-purchase due diligence | Needs honest condition assessment to inform negotiation |
| HOA or commercial condo board | Multi-unit decision-making | Group decision dynamics, fairness across owners, transparency |
| General contractor (re-roof tied to renovation) | Coordinated project | Schedule integration, scope clarity, single point of contact |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '15'
);

-- Part 1 / Ch 2 / Sec 16: Lead Qualification Questions
UPDATE sections SET
  content_markdown = $mfst$Ask these before or during the inspection:

1. How old is the current roof, to your best knowledge?
2. Do you have any documentation — original warranty, prior inspection reports, repair records?
3. Is there an active leak, or have there been recent leak events?
4. How many leak calls have you had in the past 12 months? 24 months?
5. What does the roof look like during and after rain — any ponding you've noticed?
6. Has any recent work been done by other trades — HVAC, solar, electrical, telecom?
7. Are there any walk pads or designated traffic paths up there?
8. Who has access to the roof, and how often?
9. Is there a current maintenance program in place?
10. Are you working with insurance on any current claim?
11. What's your timeline — emergency, planned project, or budget evaluation?
12. What outcome would make this engagement a success for you?$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '16'
);

-- Part 1 / Ch 2 / Sec 17: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "TPO is a single-ply roof membrane — one continuous waterproof sheet welded together at the seams. The system underneath the membrane is just as important as the membrane itself: insulation, cover board, fasteners, and the deck. When TPO fails, it's almost always at one of three places — a seam, a flashing detail, or a drain. That's where our inspection focuses."

### Talking points (honest selling angles)

1. TPO is the most-installed flat-roof system on new commercial construction for good reason — strong cost-per-year-of-service when installed and maintained well.
2. The seams determine the long-term performance, which means installer skill matters as much as product brand.
3. Drainage and detailing matter more than membrane thickness in most failure cases.
4. A well-maintained TPO roof is a strong candidate for silicone restoration before replacement — when the substrate qualifies.
5. Documentation of inspections and repairs protects warranty coverage and resale value.

### FAQ

- **Q: Is TPO better than PVC?** A: They're both proven single-ply systems with different strengths. PVC has a longer track record and tends to perform better around grease and chemical exposure. TPO is more cost-competitive on standard buildings. The right answer depends on the building.
- **Q: Why white?** A: Reflectivity. White reduces cooling loads in summer, which matters in inland NorCal. California's Title 24 cool-roof requirements also drive white membrane on many commercial occupancies.
- **Q: How long will it last?** A: 60-mil TPO commonly performs in the range of about 18 to 25 years with reasonable maintenance. We won't quote a specific number — we'll quote you on the work and the workmanship warranty.
- **Q: Why is ponding water a problem?** A: Standing water accelerates wear on any membrane. Even when the membrane handles short-term ponding, persistent ponding is a sign that drainage isn't working, and it pushes the system harder than intended.
- **Q: Can we just coat it instead of replacing it?** A: Sometimes. Restoration coatings are a real option when the substrate qualifies — sound seams, addressable details, no wet insulation, no chronic structural ponding. We'll inspect and tell you honestly if your roof qualifies.
- **Q: Why does the seam matter so much?** A: A welded seam, when done correctly, is stronger than the membrane itself. When done incorrectly, it's the weakest point. That's why we probe-test every seam during installation and inspect them carefully on re-roof evaluations.
- **Q: Will the warranty cover this?** A: Possibly — but warranty coverage on commercial roofs is detailed. We'll review the actual document and tell you what's covered, what's excluded, and what's required to keep coverage active.

### Objections & Responses

- **"You're more expensive than the other guys."** A: Possibly. The number on a proposal is one part of the picture — scope, insulation, cover board, attachment method, flashing details, and workmanship warranty are the others. We're glad to walk you through where the numbers differ.
- **"We just want a cheap patch."** A: We can patch when patching is the right call. Before we patch, let us confirm the leak source — patching the wrong location is more expensive than patching the right one.
- **"My contractor said we should just coat it."** A: Coating works when the substrate qualifies. If your roof has chronic ponding, failing seams, or wet insulation, a coating will fail and your money is gone. We'll inspect and tell you what's actually possible.
- **"We're going to wait until it really leaks."** A: That's a reasonable instinct, but commercial leaks rarely "really leak" — they show up as ceiling tile staining, mystery callbacks, mold concerns, and tenant complaints. The cost of waiting is usually higher than the cost of acting.
- **"Insurance will cover this."** A: We can document conditions for your claim, but we won't promise an outcome — that's between you and your carrier. We'll do our part honestly.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Promising insurance approval or claim payout
- Recommending replacement on a young roof in good condition
- Recommending coating restoration without verifying the substrate qualifies
- Talking down a competitor's installation without seeing the documentation
- Promising warranty outcomes without reading the actual warranty
- Identifying wet insulation or structural failure outside your training$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '17'
);

-- Part 1 / Ch 2 / Sec 18: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Repair recommendation:**
> Based on inspection, the roof has remaining service life. Recommended scope: welded patches at [locations], pipe boot replacement at [location], drain ring resealing, and seam re-welding at [seam]. Annual maintenance recommended. Replacement not recommended at this time.

**Restoration recommendation (silicone coating):**
> The TPO membrane has aged but the substrate qualifies for silicone restoration: sound seams, no chronic ponding, addressable detail conditions, and no evidence of wet insulation. Recommended scope: full clean and prep, detail repair at [locations], seam reinforcement, and silicone coating application per manufacturer specification. Restoration is intended to extend service life — it does not replace failed details, restore deteriorated substrate, or address structural issues. **[CHECK MANUFACTURER]** Confirm coating system, mil thickness, and warranty terms.

**Replacement recommendation:**
> Based on inspection findings, the existing TPO roof has reached the end of its useful service life. Conditions observed include [list]. Recommended scope: full tear-off including suspected wet insulation, deck inspection, new insulation and cover board, 60-mil mechanically attached TPO, all flashings, drains, and terminations per current manufacturer details. Workmanship warranty per USA Flat Roof terms. **[VERIFY LOCALLY]** Title 24 cool-roof and code-required scope items confirmed with jurisdiction.

**Maintenance recommendation:**
> The roof is in serviceable condition. Recommended scope: clean and inspect, debris removal, drain clearing, fastener and termination check, sealant touch-up at [locations]. Documentation provided for warranty and ownership records. Recommend re-inspection in 12 months.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '18'
);

-- Part 1 / Ch 2 / Sec 19: Role-Play Scenario
UPDATE sections SET
  content_markdown = $mfst$**Setting:** 22,000 sq ft single-story warehouse in Hayward. Property manager calls because a tenant in unit 4 has water staining on ceiling tiles after a recent storm. Existing roof is 16-year-old 60-mil mechanically attached TPO.

**Customer:** "We just need someone to find the leak and patch it. The roof's not that old."

**Rep should:**

1. Acknowledge the request without dismissing it.
2. Inspect the full roof, not just the area above the staining — leak entry rarely sits directly above the visible interior damage.
3. Document conditions including drainage, seam condition, flashings, and any signs of chronic ponding or wet insulation.
4. Present options based on what was found, not what is most profitable.
5. Handle the objection if the recommendation is restoration or replacement.

**Sample handling of the objection:**

> "I hear you — and we can definitely patch the leak today. The leak we found isn't directly above the stained tile; it's a failed pipe boot about 30 feet to the east, where water is tracking along a roof joist before showing inside. That's a real, fixable repair. But while we were up there, we documented [conditions]. The roof is at 16 years on a 60-mil TPO, which puts it in the back half of its expected service range. Here's what I'd suggest: we patch the boot today so your tenant is dry, and I'll put two options on paper for your owner — one for restoration coating, one for replacement, with clear notes on what each would and wouldn't solve. You decide on your timeline."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '19'
);

-- Part 1 / Ch 2 / Sec 20: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every inspection:**

- All four building elevations from ground level
- Each quadrant of the roof from elevated view
- Every seam where condition is concerning, with reference scale
- Every penetration (pipes, vents, curbs, drains, skylights, conduits)
- Every flashing detail (parapet, curb, drain, termination)
- Every drain and scupper
- Any ponding evidence (chalk outline preferred)
- Any damage close-up with reference scale
- Walk pad condition and coverage
- Interior leak evidence if reported

**Measurements to record:**

- Roof footprint (square footage)
- Number of drains and scuppers
- Penetration count and types
- Parapet height
- Slope direction(s) and approximate pitch
- Number of HVAC units and other rooftop equipment

**Conditions to note:**

- Roof age (best estimate, source)
- Membrane type and color
- Thickness if documented
- Attachment method (mechanically attached, fully adhered, ballasted)
- Insulation condition if assessable
- Ventilation/HVAC penetration density
- Solar or telecom equipment presence

**Severity rating** applied to each condition using the four-point scale.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '20'
);

-- Part 1 / Ch 2 / Sec 21: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active interior leak with unknown source
- Suspected wet insulation (soft underfoot)
- Visible structural deflection or sagging deck
- Widespread seam failure
- Suspected hail or storm damage with insurance involvement
- Solar array on the roof — re-roof and restoration scope interact with PV warranty and removal cost
- Multi-tenant or HOA buildings with complex stakeholder approval
- Code-related questions (Title 24, wind uplift, structural)
- Customer requesting specific warranty interpretation
- Suspected mold, asbestos, or other hazard
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '21'
);

-- Part 1 / Ch 2 / Sec 22: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred TPO product line(s) and manufacturer certifications: [placeholder]
> - Our standard membrane thickness offerings (60-mil baseline; 80-mil applications): [placeholder]
> - Our standard insulation and cover board specifications: [placeholder]
> - Our inspection and probe-test procedures during installation: [placeholder]
> - Our restoration qualification criteria for existing TPO: [placeholder]
> - Our replacement criteria: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language and NDL warranty offerings: [placeholder]
> - Our sales-to-production handoff process for commercial projects: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '22'
);

-- Part 1 / Ch 2 / Sec 23: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They confuse TPO and PVC visually and certify product type without documentation.
- They assume "60-mil" is a quality marker on its own — without recognizing that attachment method, cover board, insulation, and details drive performance more than membrane mil.
- They overstate what silicone restoration coatings can do — particularly on roofs with ponding or wet insulation.
- They miss damage caused by other trades because the damage doesn't look like a roof problem (sealant smears, scuffs, unauthorized penetrations).
- They underestimate how much a single failed pipe boot can cost in tenant disruption.

**Discussion questions for group training**
- Walk through Scenario B (16-year-old roof). What distinguishes a good restoration candidate from a roof that should be replaced instead?
- A property manager asks "why does the seam matter so much?" — give the 30-second answer.
- A building owner says "we just had a coating put on three years ago." What inspection priorities does that change?
- How do you respond to "TPO and PVC are basically the same"?

**Field exercises**
- Pair up. Review three sets of TPO inspection photos. Identify seam issues, flashing issues, and drainage issues separately.
- Walk a real roof together. Have the trainee find every penetration and apply severity ratings before the trainer reviews.
- Practice the role-play scenario in Section 19. Rotate property manager and rep roles.

**What the manager should test verbally**
- Distinguish TPO from PVC and from EPDM.
- Name five components of a mechanically attached TPO assembly.
- Explain why white membrane is dominant in California commercial.
- Walk through a Good/Better/Best presentation for a 16-year-old TPO roof with two failed pipe boots.
- State five things a rep must not promise.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '23'
);

-- Part 1 / Ch 2 / Sec 24: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Cover board** — hard board (gypsum-based or HD polyiso) over insulation, providing a stable membrane substrate.
- **Fully adhered** — membrane bonded to substrate with adhesive (alternative to mechanically attached).
- **Hot-air welding** — heat-fusion method for joining single-ply seams.
- **Mechanically attached** — membrane fastened with screws and plates along seams.
- **Mil** — one thousandth of an inch (60-mil = 0.060 inches thick).
- **NDL warranty (No Dollar Limit)** — full-system manufacturer warranty without per-claim cap, available with certified contractors and approved assemblies.
- **Polyiso (polyisocyanurate)** — common rigid foam insulation under single-ply membranes.
- **Ponding water** — water remaining on a roof beyond manufacturer-allowed duration after rain stops.
- **Probe test** — hand-tool test of welded seam integrity.
- **Scupper** — wall opening that drains water through the parapet.
- **Single-ply** — roof system using one engineered waterproofing sheet.
- **T-joint** — point where three membrane sheets meet; high-failure location.
- **Termination bar** — metal bar securing the membrane edge at a wall or curb.
- **Thermoplastic** — plastic that melts under heat and can be welded.
- **TPO (thermoplastic polyolefin)** — the membrane chemistry itself.
- **Walk pad** — protective surface installed at high-traffic roof areas.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '24'
);

-- Part 1 / Ch 2 / Sec 25: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$TPO is the dominant single-ply commercial flat-roof system in Northern California and across the U.S. USA Flat Roof installs primarily 60-mil mechanically attached TPO. Real-world service life commonly falls in the range of 18–25 years with reasonable maintenance, but installation quality, drainage, and damage from other trades drive outcomes more than product brand. Reps must avoid quoting specific lifespans, certifying TPO vs PVC without documentation, or recommending coating restoration without verifying that the substrate qualifies. Most TPO failures occur at three locations: seams, flashing details, and drains — and inspection should focus accordingly. The Good/Better/Best framework offers repair, silicone restoration, or replacement depending on age, drainage, and seam condition. Documentation, photos, and severity ratings protect both the customer and the company. Reps should escalate any condition exceeding their training, including suspected wet insulation, structural concerns, and insurance-claim scenarios.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '25'
);

-- Part 1 / Ch 2 / Sec 26: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** What does "TPO" stand for?
A. Thermoplastic polyolefin
B. Total polymer overlay
C. Treated polyester oxide
D. Thermo-protected oxide

**2. (Beginner)** How are TPO seams joined during installation?
A. Glued with adhesive
B. Sealed with self-adhesive tape
C. Hot-air welded
D. Mechanically clamped

**3. (Beginner)** "60-mil" refers to:
A. The width of a TPO roll
B. The thickness of the membrane
C. The fastener spacing
D. The warranty length

**4. (Beginner)** The most common color for TPO membrane in California commercial roofing is:
A. Black
B. Tan
C. White
D. Gray

**5. (Intermediate)** A rep finds a small, visible gap along a welded seam on a 12-year-old TPO roof. The most appropriate severity rating is:
A. Monitor
B. Maintenance Needed
C. Repair Recommended → Urgent
D. End of life

**6. (Intermediate)** Which of the following is most likely to disqualify a TPO roof from silicone restoration?
A. Surface dirt and biological staining
B. Light surface chalking
C. Chronic ponding water and suspected wet insulation
D. Two failed pipe boots

**7. (Intermediate)** A customer asks why white membrane is used so often on California commercial roofs. The best answer is:
A. White is the cheapest color to manufacture
B. White reflects sunlight and reduces cooling loads, supported by Title 24 requirements
C. White is the only color manufacturers offer
D. White hides dirt better than other colors

**8. (Intermediate)** Which of these locations is statistically most likely to be the source of a TPO leak?
A. The middle of a continuous sheet
B. A seam, flashing detail, or drain
C. The fastener heads under the membrane
D. The cover board joints

**9. (Advanced)** A property manager says, "Our previous contractor told us we should just coat the roof — it's cheaper." On inspection, the roof has chronic ponding, two areas of soft underfoot insulation, and seam separation in three locations. The most honest response is:
A. Recommend coating because it's what the customer wants
B. Recommend coating but with a higher-end product
C. Explain that coating in these conditions will fail and recommend replacement instead
D. Decline to respond and refer to the senior estimator

**10. (Advanced)** A rep is asked to confirm whether a roof is TPO or PVC. There is no documentation available. The most appropriate response is:
A. Tell the customer it's TPO based on the white color
B. Tell the customer it's PVC because it feels slick
C. Document the membrane appearance and note that product type cannot be certified without documentation
D. Tell the customer the two are interchangeable

---

### Answer Key

1. **A — Thermoplastic polyolefin.** This is the membrane chemistry name. The other options are made up.
2. **C — Hot-air welded.** TPO is thermoplastic, meaning it melts and re-fuses under heat. Adhesive (A) and tape (B) describe other systems (EPDM, some modified bitumen).
3. **B — The thickness of the membrane.** A mil is one thousandth of an inch. Width (A), spacing (C), and warranty length (D) are unrelated.
4. **C — White.** Reflectivity drives the choice, particularly under Title 24.
5. **C — Repair Recommended → Urgent.** A visible seam gap is an active failure point. Monitor (A) and Maintenance (B) understate it.
6. **C — Chronic ponding water and suspected wet insulation.** These conditions disqualify a roof from coating restoration per Rule 5. Surface dirt (A), light chalking (B), and individual failed details (D) are addressable.
7. **B — White reflects sunlight and reduces cooling loads, supported by Title 24.** "Cheapest" (A) and "only color" (C) are factually wrong. "Hides dirt" (D) is the opposite of true — white shows dirt.
8. **B — A seam, flashing detail, or drain.** These are the three classic failure points on single-ply roofs. The middle of a sheet (A) rarely fails on its own.
9. **C — Explain that coating in these conditions will fail and recommend replacement instead.** Proceeding with coating (A, B) would be the textbook restoration ethics failure. Declining to respond (D) abandons the customer.
10. **C — Document the appearance and note that product type cannot be certified without documentation.** TPO and PVC look nearly identical from a distance and similar up close. Reps should not certify product type by visual inspection alone.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '26'
);

-- Part 1 / Ch 2 / Sec 27: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for the TPO products and assemblies USA Flat Roof installs?
- [ ] Matches USA Flat Roof manufacturer certifications and NDL warranty availability?
- [ ] Matches USA Flat Roof workmanship warranty language?
- [ ] Matches USA Flat Roof inspection process and probe-test procedures?
- [ ] Are escalation triggers correct for our team structure?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the silicone restoration framing match Chapter 3 once that chapter is produced?
- [ ] Are 60-mil-only references aligned with our actual offerings (or do we offer 80-mil for specific applications)?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's primary TPO manufacturer(s) and certification programs; insert specific NDL warranty terms.
- Code-dependent items: Title 24 cool-roof requirements, wind uplift requirements, fire ratings — confirm with current California Energy Commission and local jurisdiction guidance.
- Regional climate assumptions: 18–25 year NorCal field range. Verify with USA Flat Roof field data across coastal, Bay, Valley, and inland markets.
- Warranty-related statements: prorated/non-prorated language, transferability, NDL terms, USA Flat Roof workmanship terms.
- Company policy items: every [COMPANY POLICY] placeholder in Section 22.
- Restoration claims: all silicone restoration language in Sections 13, 17, and 18 should be cross-checked against Chapter 3 (Silicone Coatings) when that chapter is produced.
- Sales scripts and proposal language: review against USA Flat Roof current standard proposals and approved customer-facing language.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 2 AND s.section_number = '27'
);

-- Part 1 / Ch 3 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain what a silicone roof coating is, what it does, and what it does not do — in plain language.
2. Identify roofs that are good candidates for silicone restoration and roofs that are not.
3. Inspect a roof for the specific conditions that determine whether silicone restoration will succeed or fail.
4. Recommend silicone restoration honestly — including when the right answer is repair or replacement instead.
5. Explain coating warranty structure, application requirements, and prep work to a customer in language that builds trust without overpromising.
6. Recognize when a coating recommendation exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '1'
);

-- Part 1 / Ch 3 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$A **silicone roof coating** is a liquid-applied, fluid-cured waterproofing layer rolled or sprayed onto an existing roof. Once cured, it forms a single continuous **monolithic** (seamless) membrane bonded to the roof underneath.

Silicone coatings are part of a category called **roof restoration** — work intended to extend the service life of a roof that still has a sound substrate. They are not roof replacements, repairs, or magic. The most important thing a sales rep can understand about silicone is what it can and cannot do:

**Silicone coatings can:**
- Add a continuous waterproof layer to an aged but sound substrate
- Reflect sunlight and reduce membrane temperature
- Bridge minor surface imperfections and fine cracks
- Extend the useful service life of a qualifying roof
- Often qualify the roof for a manufacturer-issued coating warranty

**Silicone coatings cannot:**
- Restore a roof at end of life
- Fix wet insulation
- Solve chronic ponding water
- Repair structural deficiencies
- Replace failed flashings, deteriorated decks, or actively leaking seams (these must be repaired *before* coating)
- Add structural strength

USA Flat Roof typically applies silicone as a **single high-build coat** — a single application at a thicker mil rate, rather than two separate thinner applications. This is one of two common approaches in the industry; the other is a two-coat system.

> **[CHECK MANUFACTURER]** Mil thickness, dry film thickness, prep requirements, and warranty terms vary significantly by product and warranty tier. Confirm current product data sheets before quoting any specific scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '2'
);

-- Part 1 / Ch 3 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Primary use:** existing flat or low-slope commercial roofs being restored to extend service life
- **Common over:** aged TPO, PVC, EPDM, modified bitumen, built-up roofing, spray polyurethane foam (SPF), and metal roofs (with appropriate prep)
- **Common in:** retail centers, warehouses, office buildings, light industrial, restaurants, multi-tenant commercial — any flat-roof building where the substrate qualifies and the owner wants to extend life rather than replace
- **Less common on:** steep-slope residential (silicone is rarely used on shingle roofs), historic buildings with specialty roof systems, structures with severe ponding or structural issues

In Northern California, silicone restoration is widely applied across Bay Area, Sacramento Valley, and inland commercial buildings — particularly where the existing single-ply or modified bitumen roof has aged but the deck and insulation are intact.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '3'
);

-- Part 1 / Ch 3 / Sec 4: What It Looks Like + Ground-Level Recognition Clues
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

- Smooth, painted-looking white surface (silicone is most commonly white for reflectivity, though gray and tan are available)
- Visible **brush, roller, or spray texture** — different from the factory-uniform finish of a single-ply membrane
- Coating wraps continuously over the roof field, flashings, parapet bases, drains, and most penetrations — no visible seams
- Often shows **overspray or coating bleed** onto adjacent surfaces (wall caps, equipment bases, gravel stops) on less careful applications
- Newly applied coatings have a clean, almost-wet appearance; older coatings show dirt accumulation, biological staining, and chalking

### Recognition by viewpoint

- **Drone or roof view:** continuous painted-looking surface, no welded seams, smooth wrapping over details, brush/spray texture visible up close.
- **Ladder edge:** coating typically continues up parapet walls and over the top in many applications; abrupt termination at a clean edge is unusual.
- **Roof surface:** look for substrate type underneath the coating — sometimes the original membrane is visible at edges, drains, or worn areas. Identifying the substrate matters for any future re-coat or replacement decision.
- **Interior leak evidence:** identical to the underlying substrate's leak patterns. The coating itself does not change how leaks present inside.

### How to tell a coating from a single-ply membrane

| Clue | Coating | Single-ply membrane |
|---|---|---|
| Surface texture | Brush/spray/roller texture | Smooth factory finish |
| Seams | None visible (monolithic) | Visible seam lines at sheet overlaps |
| Detail wrap | Coating wraps continuously over details | Membrane terminates at flashings, edges, terminations |
| Edge appearance | Often shows overspray or bleed onto adjacent surfaces | Clean, defined termination |
| Aging signs | Chalking, dirt accumulation, biological staining | Seam deterioration, shrinkage, UV degradation |

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '4'
);

-- Part 1 / Ch 3 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Acrylic roof coating** | Acrylics are also liquid-applied and white, but they are water-based and breathe differently. Silicone is moisture-cure and performs differently in ponding water. The two often look similar — confirm with documentation. (See Chapter 7.) |
| **TPO or PVC membrane** | Single-ply membranes show seam lines; coatings do not. Membranes are factory-uniform; coatings show application texture. |
| **Spray polyurethane foam (SPF) with topcoat** | SPF has a textured, slightly orange-peel surface even under coating, with visible foam build-up at edges. Pure coatings on a hard substrate are flatter. |
| **Painted parapet or wall coating extending onto roof** | Sometimes a building's wall paint is over-applied onto the roof edge. Confirm the entire field is coated, not just the edges. |
| **Aluminum-pigmented asphalt coating ("aluminum roof paint")** | Common older approach on modified bitumen and BUR. Has a metallic silver appearance, not white. Different chemistry and far shorter service life. |

> **[SALES REP BOUNDARY]** Reps may identify a roof as "appears coated" based on visual indicators. They should not certify coating chemistry, manufacturer, or application date without documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '5'
);

-- Part 1 / Ch 3 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A silicone restoration system is the coating itself plus several supporting components and prep elements:

1. **Existing substrate** — the roof being coated. Substrate type and condition determine whether restoration is appropriate at all.
2. **Cleaning** — typically power-washing or chemical cleaning to remove dirt, biological growth, chalking, and residue. **Coatings will not bond to a dirty substrate.**
3. **Repairs and prep** — failed seams, flashing details, pipe boots, and minor punctures must be repaired before coating. Coating is *not* a leak repair.
4. **Reinforcement fabric (where required)** — woven polyester fabric embedded in coating at seams, transitions, and high-stress areas. Common at parapet bases, curbs, and drain rings.
5. **Detail coating ("stripe coat")** — a separate detail-coat application around penetrations, drains, seams, and terminations before the field coat.
6. **Field coating** — the main silicone application across the roof surface. In USA Flat Roof's standard system, applied as a **single high-build coat** at a specified mil thickness.
7. **Drain inserts and accessories** *(where used)* — drain ring repair products, expansion joint covers, walk pads.

> **[CHECK MANUFACTURER]** Mil thickness, fabric placement, primer requirements, and detail-coat specifications are product- and warranty-specific. Confirm with current manufacturer documentation.

[IMAGE #2]
Type: Diagram
Priority: Required
Source preference: Custom diagram
Description: Cross-section showing existing membrane substrate, primer (where used), reinforcement fabric at a seam or transition, detail coat, and field coat.
Purpose: Help reps visualize the coating system as a layered restoration, not just paint.
Caption: Cross-section of a typical single-coat silicone restoration system. Components shown are conceptual; actual systems vary by manufacturer.
Alt text: Diagram showing layers of a silicone roof coating system over an existing substrate.
Annotation needed: Yes — label substrate, primer (if used), fabric, detail coat, and field coat.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '6'
);

-- Part 1 / Ch 3 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$A typical single-coat silicone restoration follows this general sequence. This overview is for awareness only — not an installation specification.

1. **Inspection and qualification** — confirm the roof qualifies for restoration. This is the most important step. (See Section 13.)
2. **Repair and prep** — replace failed pipe boots, repair seam separations, address flashing failures, replace deteriorated drains. **The roof must be watertight before coating.**
3. **Cleaning** — power-wash or chemical-clean the entire roof to remove dirt, biological growth, and chalking. Allow to dry fully.
4. **Primer** *(where required)* — some substrates and conditions require a primer before silicone application.
5. **Reinforcement fabric** — embed fabric at seams, transitions, parapet bases, curbs, drain rings, and other high-stress areas per manufacturer specification.
6. **Detail coat** — apply silicone at penetrations, drains, terminations, and detail areas.
7. **Field coat (single high-build application)** — apply silicone across the full roof field at the specified mil thickness, typically by spray with back-rolling.
8. **Cure time** — silicone cures by reacting with atmospheric moisture. Cure time depends on humidity and temperature.
9. **Final inspection and documentation** — confirm coverage, mil thickness, and details. Document with photos for warranty registration.

> **[CHECK MANUFACTURER]** Application rate (gallons per square), mil thickness (wet and dry), cure conditions (temperature and humidity windows), recoat windows, and warranty inspection requirements vary by product and warranty tier. Reps should not specify these details — they are determined by the manufacturer and project documents.

> **[VERIFY LOCALLY]** Cool-roof reflectivity and Title 24 compliance may apply to silicone restorations on certain commercial occupancies. Confirm with code official.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '7'
);

-- Part 1 / Ch 3 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$- **Industry rating range:** Manufacturer warranties on silicone restoration commonly run 10, 15, or 20 years depending on system, mil thickness, and contractor program tier. Warranty length is not the same as service life.
- **Real-world field range (single-coat silicone, NorCal):** roughly **10–15 years** before a maintenance recoat or further restoration is appropriate. Heavier-mil systems with strong prep can reach 15–20 years. Conditions and maintenance drive the variation.
- **Factors that shorten coating lifespan:** poor surface prep, application over a substrate that didn't qualify, ponding water, mechanical damage, dirt and biological growth left untreated, foot traffic without walk pads, missed maintenance.
- **Factors that extend coating lifespan:** good substrate qualification, thorough cleaning before application, correct mil thickness, regular inspection, prompt cleaning of biological growth and debris, walk pads at high-traffic areas.

> **[VERIFY LOCALLY]** Coating performance varies between coastal NorCal (more biological growth, chronic moisture) and inland NorCal (higher UV, faster chalking). Confirm specific patterns with field experience.

### What reps must NOT promise

- Specific service-life numbers
- Warranty payouts on coatings applied over questionable substrates
- That the warranty covers leaks from the underlying roof
- Coating performance on roofs that did not qualify at the start
- Outcomes contingent on customer maintenance behavior

### Suggested customer language

> "A silicone restoration on a qualifying roof commonly performs in the range of about 10 to 15 years before a maintenance recoat is appropriate, depending on application thickness, prep, and the condition of the roof underneath. Based on what we're seeing on your roof today, here's what we'd expect…"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '8'
);

-- Part 1 / Ch 3 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Extends service life** of a qualifying aged roof at lower cost than full replacement.
- **Monolithic coverage** — no seams, no fasteners. The continuous layer eliminates the most common single-ply failure points.
- **Highly UV-resistant** — silicone holds up to sun exposure better than most other coating chemistries over time.
- **Performs well in ponding water** *(relative to other coatings)* — silicone tolerates standing water better than acrylic, though ponding still degrades any roof system.
- **Reflective white surface** — reduces cooling loads and contributes to Title 24 compliance.
- **Faster than full replacement** — typically a smaller project window with less business disruption for the building owner.
- **Available with manufacturer-issued warranties** when applied by certified contractors over qualifying substrates.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '9'
);

-- Part 1 / Ch 3 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Not a leak repair** — coatings cannot fix active leaks until the leak source is repaired underneath.
- **Substrate-dependent** — coating performance is only as good as what's underneath. A failing substrate cannot be restored by coating it.
- **Requires correct prep** — applying silicone over a dirty, oily, or damp substrate is the most common failure cause.
- **Difficult to recoat with non-silicone products** — once silicone is applied, future coatings (other than silicone) often will not bond. This affects long-term maintenance and replacement options.
- **Single-coat thickness must be achieved correctly** — under-applied coating fails years earlier than expected, and the customer rarely knows until the warranty period is over.
- **Sensitive to weather during application** — humidity, rain, and temperature all affect cure quality.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '10'
);

-- Part 1 / Ch 3 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Light dirt and biological staining | Monitor → Maintenance | Surface darkening, particularly on north sides or under tree cover |
| Chalking | Maintenance | Powdery white residue when surface is rubbed |
| Surface dirt accumulation | Maintenance | Loss of reflectivity, often noticeable from comparison areas |
| Ponded water on a coating | Repair → Urgent | Coating may show staining, blistering, or accelerated wear at the pond |
| Coating delamination (peeling, lifting) | Repair → Urgent | Coating no longer bonded to substrate; lifts when tugged |
| Coating cracking | Repair | Visible cracks in the cured coating |
| Substrate failure visible through coating | Urgent | Coating intact but underlying membrane or detail has failed |
| Fabric exposure or lift | Repair | Reinforcement fabric visible, lifted, or no longer encapsulated |
| Coating applied over wet substrate (early-life failure) | Repair → Urgent | Coating bubbling, releasing in sheets, often within first 1–2 years |
| Coating applied over chronic ponding | Repair → Urgent | Coating visibly degrading at pond areas faster than the rest of the roof |
| Detail-coat or stripe-coat failure | Repair | Cracking or pulling at penetrations, drains, parapet bases |
| Dirty / oily substrate (failed prep) | Urgent | Widespread early delamination |
| Active leak through coated roof | Urgent | Indicates substrate failure regardless of coating condition |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify coating chemistry, application thickness, or warranty status without documentation; they do not diagnose root cause of a coating failure without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '11'
);

-- Part 1 / Ch 3 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$For an inspection of a coated roof, inspect the coating *and* the substrate underneath. Both matter.

**Coating-specific inspection**
- Photograph each quadrant of the roof
- Note coating color, age (if known), and overall condition
- Look for chalking (rub a finger on the surface; powdery residue indicates chalking)
- Look for biological staining, dirt accumulation, and reflectivity loss
- Inspect every seam transition, fabric area, and detail for cracking or lifting
- Look for any area where the coating has separated, peeled, or blistered
- Photograph any area of suspected substrate failure visible through the coating

**Substrate inspection (where assessable)**
- Check exposed substrate at edges, drains, or worn areas — what is underneath the coating?
- Note substrate type (TPO, modified bitumen, BUR, etc.) — this affects future options
- Look for substrate symptoms unrelated to the coating: deck deflection, ponding patterns, parapet wall deterioration

**Detail and penetration inspection**
- Photograph every penetration, drain, curb, and termination
- Note coating wrap quality, fabric integration, and any detail-area failure

**Drainage**
- Photograph every drain and scupper
- Note ponding extent and any debris or vegetation
- Note overflow drains

**Interior check (if accessible)**
- Note ceiling staining, water marks, efflorescence
- Patterns relative to known penetrations, drains, or substrate transitions

**Red flags requiring immediate escalation**
- Active interior leak through a coated roof
- Soft / spongy underfoot — wet insulation under the coating
- Visible substrate failure (deck deflection, severe ponding)
- Widespread coating delamination or peeling
- Coating applied over a substrate that did not qualify (asphalt bleed-through, biological staining bleeding through, or adhesion failure)
- Solar array on the roof — coating projects involving PV require specific coordination$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '12'
);

-- Part 1 / Ch 3 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$This is the chapter where Rule 5 (Restoration Honesty) matters most. The Good/Better/Best framework here is not Repair / Restore / Replace — it is *which restoration approach, if any, is honest*.

### Scenario A: 12-year-old TPO roof, sound seams, light surface wear, no ponding, intact insulation

- **Good:** address minor maintenance items, monitor.
- **Better (right call):** silicone restoration. Roof qualifies — sound substrate, addressable details, no ponding, no wet insulation. Coating extends service life cost-effectively.
- **Best:** *Not appropriate yet.* Replacement on a roof in this condition would be premature.

### Scenario B: 18-year-old modified bitumen roof, surface aged but sound, small ponding areas, two failed pipe boots

- **Good:** repair the pipe boots, monitor ponding, recommend annual maintenance — but this defers the larger conversation.
- **Better (right call):** silicone restoration *after* full prep — repair the pipe boots, address the ponding cause where possible, clean thoroughly, then coat. The roof qualifies but the prep matters as much as the coating.
- **Best:** plan for replacement in 5–8 years if ponding cannot be corrected and substrate continues to age.

### Scenario C: 20+-year-old single-ply roof, widespread seam failure, chronic ponding, soft underfoot in two areas

- **Good:** *Not appropriate.* Spot repair on a system this far gone is short-term spending.
- **Better:** *Not appropriate — and this is the critical sales moment.* A coating recommendation here would be the ethics failure described in Rule 5. Soft underfoot indicates wet insulation. Coating over wet insulation traps moisture and accelerates substrate failure. The customer's money would be wasted, and when the roof fails the warranty would not cover the substrate.
- **Best (right call):** full replacement with insulation evaluation. **Recommend this honestly even if a coating would be easier to sell.**

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific qualification criteria for proposing silicone restoration: minimum substrate condition, ponding limits, moisture survey requirements, and required prep scope.

### The honest-versus-easy moment

A coating proposal is easier to sell than a replacement proposal:
- Lower price
- Faster project
- Less customer disruption
- Customer often *prefers* this answer

When the roof qualifies, this is a genuine win — the rep recommends what's right *and* what the customer wants.

When the roof does not qualify, the rep faces the moment described in Rule 3. The most honest recommendation (replacement) is the harder sell. The temptation is to propose a coating, accept the close, and let the warranty process deal with the consequences in 18 months.

This is the moment USA Flat Roof reps are trained to handle correctly: **if the roof does not qualify, the rep must not propose silicone restoration, no matter how much the customer wants it.** Long-term trust and reputation depend on this.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '13'
);

-- Part 1 / Ch 3 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$Three warranty layers commonly apply to silicone restoration:

- **Manufacturer (material) warranty** — covers the coating product against defects.
- **Manufacturer system warranty** — covers the coating system as installed by a certified contractor over a qualifying substrate. Length and terms vary by warranty tier.
- **Workmanship (contractor) warranty** — covers application quality. Issued by the contractor.

### What commonly voids or limits coating warranties

- Application over a substrate that did not qualify
- Insufficient mil thickness (under-application)
- Inadequate surface prep
- Substrate failure under the coating (most warranties exclude pre-existing substrate issues)
- Damage from ponding water beyond manufacturer-allowed limits
- Damage from other trades or rooftop equipment
- Lack of documented annual inspections (some warranties require these)
- Modifications, additions, or penetrations made without manufacturer-approved details

### Critical warranty point reps must understand

A manufacturer's coating warranty typically covers the **coating**, not the **substrate underneath**. If the substrate fails, the coating warranty does not cover the resulting leak repair or replacement. This is why qualification matters so much — a coating warranty has no value if the underlying roof was failing at the start.

### What reps must not promise

- That the coating warranty covers all leaks
- That the coating warranty covers the substrate
- That an aging coated roof "still has full warranty coverage" without reading the document
- That ponded water is "not a problem because the coating is rated for ponding"
- Specific outcomes for damage caused by other trades or weather events

> **[COMPANY POLICY]** Placeholder — USA Flat Roof workmanship warranty terms for coatings, manufacturer certifications held, available warranty tiers, inspection requirements for warranty validity, and substrate qualification documentation requirements.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '14'
);

-- Part 1 / Ch 3 / Sec 15: Ideal Customer Profile + Pain Points
UPDATE sections SET
  content_markdown = $mfst$| Customer type | Why they call | Common pain points |
|---|---|---|
| Building owner with aging roof | Wants to extend life, defer replacement | Capital budget concerns, comparison-shopping coatings vs replacement, suspicion of "too good to be true" pricing |
| Property manager | Owner pressure to control capital costs | Needs defensible recommendation, clear scope, owner-approval-friendly pricing |
| Facility manager (owner-occupant) | Capital planning, sustainability goals | Wants longest-life option within budget, understands trade-offs |
| Real estate / acquisition | Pre-purchase or post-purchase planning | Needs honest condition assessment to avoid buying a roof problem |
| Multi-tenant commercial owner | Limited disruption tolerance | Tenant relations, scheduling around business hours |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '15'
);

-- Part 1 / Ch 3 / Sec 16: Lead Qualification Questions
UPDATE sections SET
  content_markdown = $mfst$Ask these before or during the inspection:

1. How old is the current roof, to your best knowledge?
2. What kind of roof is it — TPO, PVC, modified bitumen, BUR, EPDM, or something else? Do you have documentation?
3. Has the roof been coated or restored in the past? When? With what product?
4. Are there any active leaks, or have there been recent leak events?
5. How many leak calls have you had in the past 12 months? 24 months?
6. What does the roof look like during and after rain — any ponding you've noticed?
7. Have any rooftop changes been made recently — new HVAC, new penetrations, equipment moves?
8. Is the building occupied during business hours, or could we work daytime without disruption?
9. What's your budget framing — looking for the most life-extending option, or the most cost-effective one?
10. What's your timeline?
11. Are you working with insurance on any current claim?
12. What outcome would make this engagement a success for you?$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '16'
);

-- Part 1 / Ch 3 / Sec 17: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "A silicone roof coating is a liquid-applied waterproof layer that we put over your existing roof. Once it cures, it forms one continuous seamless membrane bonded to what's already there. The goal is to add waterproofing and reflectivity to a roof that still has good bones, so we can extend its life rather than replace it. Two things matter most: the condition of the roof underneath, and the quality of the prep before we coat. If either is wrong, the coating won't perform — no matter how good the product is."

### Talking points (honest selling angles)

1. Restoration is a real option when the roof qualifies — and a serious mistake when it doesn't. Our inspection tells you which one applies to your roof.
2. The coating product matters less than the prep. Most coating failures we see were caused by the surface not being ready, not by the coating itself.
3. A silicone restoration can extend roof life cost-effectively when conditions are right. It is not a replacement, and we will not present it as one.
4. If your roof doesn't qualify, we will not propose coating it. That conversation might be harder, but you would rather hear it now than two years into a failing coating.
5. Silicone performs well in our climate when applied correctly, and holds up to sun exposure better than most other coating chemistries.

### FAQ

- **Q: Will this fix my leak?** A: Coating is not a leak repair. We have to find and repair the leak first, then the coating goes on a roof that's already watertight. If a contractor tells you a coating fixes leaks on its own, that's a warning sign.
- **Q: How long will it last?** A: A silicone restoration on a qualifying roof commonly performs in the range of about 10 to 15 years before a maintenance recoat is appropriate, depending on application thickness, prep, and the substrate condition. We won't quote a specific number — we'll quote you on the work.
- **Q: Why does the substrate matter so much?** A: A coating is only as good as what's underneath. If the membrane below is failing, the coating will follow it down. We inspect the substrate carefully because that's the variable that makes or breaks the project.
- **Q: Why is this so much cheaper than replacement?** A: Restoration is a smaller scope — we're not removing the existing roof, we're adding a new waterproof layer on top. That's why qualification matters so much: the savings only exist if the roof underneath supports it.
- **Q: Can I coat over my old coating?** A: Sometimes — it depends on the existing coating, its condition, and chemistry compatibility. Silicone over silicone usually works. Silicone over acrylic or other chemistries is more nuanced. We'll inspect and tell you.
- **Q: Will I be able to recoat this in 10 years?** A: Yes, with silicone — silicone over silicone is a standard maintenance approach. One trade-off worth knowing: once silicone is applied, future coatings in *other* chemistries often won't bond. That's a long-term consideration.
- **Q: Is this a real warranty?** A: Manufacturer warranties on silicone restoration are real, but they cover the coating, not the substrate. We'll walk through what's covered, what's excluded, and what's required to keep coverage active.

### Objections & Responses

- **"The other contractor said they could coat my roof for half the price."** A: Possibly. A few things to compare on the proposals: mil thickness specified, prep scope, fabric reinforcement, detail coat, manufacturer warranty tier, and substrate qualification documentation. The number on the proposal is one part of the picture.
- **"I just want the cheapest option that gets me through five years."** A: A short-term coating on a qualifying roof might be reasonable. A short-term coating on a non-qualifying roof is not — it'll fail before five years and you'll be replacing the roof anyway. Let us inspect first, then we can talk about what's realistic.
- **"My buddy in another state had this done and it failed in two years."** A: That happens, and it almost always traces to one of two issues: the roof shouldn't have been coated, or the prep wasn't done right. We can walk you through what we'd be doing differently and why.
- **"Can't you just paint over it?"** A: Coatings are not paint, even though they look similar. Paint will not bond, will not waterproof, and will not perform. The product chemistry, mil thickness, and prep are what make a coating do its job.
- **"Will this make my insurance go up?"** A: Generally no — restoration coatings tend to be neutral or favorable from an insurance perspective. We're not insurance experts and we won't promise a specific outcome with your carrier, but we can document the work for your records.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Recommending coating without verifying substrate qualification
- Recommending coating over chronic ponding, soft insulation, or failing seams
- Calling coating a "leak repair" or "fix"
- Promising the coating will solve issues that are actually substrate or structural
- Promising warranty outcomes without reading the actual warranty
- Talking down a competitor's coating without seeing what was specified
- Promising insurance approval or claim outcomes$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '17'
);

-- Part 1 / Ch 3 / Sec 18: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Restoration recommendation (qualifying roof):**
> Based on inspection, the existing roof qualifies for silicone restoration: sound substrate, addressable details, no chronic ponding, no evidence of wet insulation. Recommended scope: detail repairs at [locations], full power-wash cleaning, primer where required, reinforcement fabric at seams and transitions, detail coat at penetrations and parapets, and single high-build silicone field coat at specified mil thickness. Restoration is intended to extend service life — it does not replace failed details, restore deteriorated substrate, or address structural issues. Workmanship warranty per USA Flat Roof terms. Manufacturer warranty per [tier] subject to manufacturer inspection and approval. **[CHECK MANUFACTURER]** Confirm current product, mil thickness, and warranty terms.

**Restoration not recommended (substrate disqualified):**
> Based on inspection, the existing roof does not qualify for silicone restoration at this time. Conditions observed include [specific findings — e.g., chronic ponding, soft underfoot in [areas], widespread seam failure]. Coating over these conditions would not perform reliably and would not be supported by manufacturer warranty. We recommend [replacement / further moisture survey / other appropriate next step] instead.

**Restoration combined with deferred replacement plan:**
> The existing roof qualifies for silicone restoration as an interim solution. Recommended scope: [as above]. This restoration is intended to extend service life by approximately [range] depending on conditions and maintenance. Replacement is recommended within [timeframe] based on substrate age, ponding presence, and projected substrate condition.

**Maintenance recoat (existing silicone):**
> The existing silicone coating remains in serviceable condition with [observed wear pattern]. Recommended scope: full clean, detail repair at [locations], fabric reinforcement at [areas if needed], and single-coat silicone maintenance recoat at [mil thickness] to extend service life. **[CHECK MANUFACTURER]** Confirm warranty extension or renewal availability.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '18'
);

-- Part 1 / Ch 3 / Sec 19: Role-Play Scenario
UPDATE sections SET
  content_markdown = $mfst$**Setting:** 18,000 sq ft retail center in Concord. Owner calls because three tenants have reported water staining after recent storms. Existing roof is 19-year-old modified bitumen with two minor ponding areas, three failed pipe boots, and intact substrate elsewhere.

**Customer:** "I want to coat the roof. My buddy did his warehouse and saved a fortune. How fast can you get me a number?"

**Rep should:**

1. Acknowledge the customer's preference without committing to it.
2. Inspect the full roof, not just the leak areas.
3. Document substrate condition, ponding, detail failures, and any signs of wet insulation.
4. Determine honestly whether the roof qualifies.
5. Present options based on what was found.
6. Handle the conversation if the recommendation is not what the customer wanted.

**Sample handling — roof qualifies:**

> "Good news — based on what we found, your roof qualifies for restoration. Substrate is sound, no soft underfoot, the ponding is minor and addressable. Three pipe boots need to come out and be redone before we coat. Once those are repaired and the surface is prepped, the silicone goes on as a single high-build coat. Here's what the scope looks like, here's the warranty tier we'd target, and here's a number. We're not promising you a specific number of years — we'll talk you through what to expect realistically and what would shorten that range."

**Sample handling — roof does not qualify:**

> "I want to give you the answer that's actually right for your roof, not the one that's easiest to sell. We did find significant issues — soft areas underfoot in two locations, which usually means wet insulation, plus seam failure across the south half of the roof. If we coated this, the warranty wouldn't cover the substrate, and the coating would likely fail within a couple of years. That's not the call we'd recommend, even though I know it's not what you were hoping to hear. The honest path forward is replacement. I can put two options on paper — replacement now, or a moisture survey first if you want to confirm the wet-insulation finding before committing. Your call."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '19'
);

-- Part 1 / Ch 3 / Sec 20: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every restoration inspection:**

- All four building elevations from ground level
- Each quadrant of the roof from elevated view
- Every penetration, curb, drain, scupper, and skylight
- Every parapet and termination detail
- Every area of suspected ponding (chalk outline preferred)
- Substrate exposed at edges, drains, or worn areas
- Any area of suspected coating delamination, peeling, or substrate failure
- Walk pad coverage and condition
- Interior leak evidence if reported

**Substrate qualification documentation:**

- Roof age and substrate type
- Membrane / substrate condition assessment
- Moisture indicators (visual signs; **moisture survey to be performed by qualified inspector if needed**)
- Ponding extent and frequency reported by owner
- Detail condition assessment (drains, pipe boots, parapets, curbs)

**Measurements to record:**

- Roof footprint
- Penetration count and types
- Drain and scupper count
- Parapet height and length

**Severity rating** applied to each condition using the four-point scale.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '20'
);

-- Part 1 / Ch 3 / Sec 21: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Soft / spongy underfoot — suspected wet insulation
- Visible structural deflection or sagging deck
- Chronic ponding extending across more than a small fraction of the roof
- Widespread substrate failure visible
- Existing coating with questionable bond or visible delamination
- Solar array on the roof — coating projects involving PV require coordination
- Code-related questions (Title 24, fire ratings, reflectivity)
- Customer specifically requesting coating over a substrate the rep believes does not qualify
- Customer requesting specific warranty interpretation
- Suspected mold, asbestos, or other hazard
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '21'
);

-- Part 1 / Ch 3 / Sec 22: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred silicone product line(s) and manufacturer certifications: [placeholder]
> - Our standard mil thickness for single-coat application: [placeholder]
> - Our standard prep scope: cleaning method, primer use, fabric placement: [placeholder]
> - Our substrate qualification criteria — minimum age threshold, maximum ponding, moisture survey requirements: [placeholder]
> - When we will and will not propose silicone restoration: [placeholder]
> - Our standard inspection and documentation procedures during application: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options and warranty tiers: [placeholder]
> - Our workmanship warranty language for coatings: [placeholder]
> - Our sales-to-production handoff process for restoration projects: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '22'
);

-- Part 1 / Ch 3 / Sec 23: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat silicone like a leak repair or a roof replacement substitute, when it is neither.
- They underestimate how much prep matters and overstate the role of product brand.
- They miss the disqualifying conditions — particularly soft underfoot (wet insulation) and chronic ponding.
- They follow the customer's preference instead of the inspection findings — the most common ethics failure in coating sales.
- They assume coating warranties cover substrate failures.
- They quote specific lifespan numbers based on warranty length.

**Discussion questions for group training**
- Walk through Scenario C. Why is recommending coating here a worse outcome for the company than walking away?
- A customer says "my buddy did his roof for half this price." How do you handle the comparison without trashing the other contractor?
- A property manager wants to coat a roof you believe doesn't qualify. They're a repeat client. What do you do?
- What's the 30-second answer to "will the warranty cover everything?"
- How do you explain to a customer that "coating is not a leak repair" without sounding evasive?

**Field exercises**
- Pair up. Review three sets of restoration inspection photos. Identify substrate qualification status (qualifies / does not qualify / needs further survey) for each.
- Walk a real roof together. Have the trainee identify the substrate type, ponding extent, and any disqualifying conditions before the trainer reviews.
- Practice the role-play scenario in Section 19 in both versions (qualifies / does not qualify). Rotate roles.
- Review three coating proposals (real or constructed). Identify any language that overpromises or that proposes coating over a non-qualifying substrate.

**What the manager should test verbally**
- Distinguish silicone from acrylic and from a single-ply membrane visually.
- Name the disqualifying conditions for restoration.
- Explain what "coating is not a leak repair" means in plain customer language.
- Walk through Scenario B and C and explain the recommendation in each.
- State five things a rep must not promise.
- Recite the honesty-versus-easy moment in their own words.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '23'
);

-- Part 1 / Ch 3 / Sec 24: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Acrylic coating** — water-based reflective roof coating; alternative chemistry to silicone with different performance characteristics (covered in Chapter 7).
- **Chalking** — powdery surface residue on aged coatings caused by UV degradation.
- **Detail coat (stripe coat)** — separate coating application at penetrations, drains, and details before the field coat.
- **Field coat** — main coating application across the roof surface.
- **High-build coat** — single coating application at thicker mil rate than a standard coat.
- **Mil** — one thousandth of an inch.
- **Monolithic** — single continuous seamless layer.
- **Moisture-cure** — coating chemistry that cures by reacting with atmospheric moisture (silicone uses this).
- **Reinforcement fabric** — woven polyester embedded in coating at seams and high-stress areas.
- **Restoration** — work intended to extend service life of an existing roof with sound substrate.
- **Silicone roof coating** — silicone-chemistry liquid-applied waterproofing.
- **Substrate** — the existing roof underneath a coating.
- **Substrate qualification** — the assessment of whether an existing roof is appropriate for coating.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '24'
);

-- Part 1 / Ch 3 / Sec 25: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$A silicone roof coating is a liquid-applied, fluid-cured waterproofing layer that bonds to an existing roof and forms a seamless continuous membrane. USA Flat Roof typically applies silicone as a single high-build coat. Silicone restoration is a real and valuable option — but only when the substrate qualifies. The coating cannot fix wet insulation, chronic ponding, structural failure, or end-of-life roofs. Real-world performance commonly falls in the range of 10–15 years on qualifying substrates with proper prep and application. The most important sales judgment in this chapter is honest qualification: when the roof qualifies, restoration is often the right answer; when it does not, the rep must not propose coating it, no matter how much the customer wants that answer. Coating warranties cover the coating, not the substrate. Documentation, photos, and severity ratings protect both the customer and the company. Reps should escalate suspected wet insulation, structural concerns, and any condition exceeding their training.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '25'
);

-- Part 1 / Ch 3 / Sec 26: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** A silicone roof coating is best described as:
A. A type of single-ply membrane
B. A liquid-applied waterproofing layer that cures into a seamless membrane
C. A specialty paint for roofs
D. A repair sealant for individual leaks

**2. (Beginner)** "Mil" in coating specifications refers to:
A. The chemical composition of the product
B. One thousandth of an inch (a measure of thickness)
C. The number of coats applied
D. The square footage covered per gallon

**3. (Beginner)** Silicone coatings cure by:
A. Drying through evaporation only
B. Heat from the sun activating a curing agent
C. Reacting with atmospheric moisture
D. Chemical reaction with the substrate underneath

**4. (Beginner)** Why is white the most common color for silicone coatings on commercial roofs?
A. White is the cheapest pigment
B. White reflects sunlight, reduces cooling loads, and supports Title 24 compliance
C. White is the only color available
D. White hides dirt better than other colors

**5. (Intermediate)** Which of the following conditions most clearly disqualifies a roof from silicone restoration?
A. Surface dirt and biological staining
B. Light surface chalking on the existing coating
C. Soft / spongy underfoot in two areas (suspected wet insulation)
D. Two failed pipe boots

**6. (Intermediate)** The single most important factor determining whether a silicone restoration will succeed is:
A. The brand of silicone product
B. The condition of the substrate underneath and the quality of prep
C. The color of the coating
D. The number of coats applied

**7. (Intermediate)** A standard silicone coating warranty typically covers:
A. The coating product, but not the substrate underneath
B. The full roof system including substrate failures
C. Only manufacturing defects, not application
D. All leaks regardless of cause

**8. (Intermediate)** A customer asks "Will this fix my leak?" The most accurate response is:
A. Yes, that's the main purpose of the coating
B. Yes, once the coating cures the leak will be sealed
C. No — coating is not a leak repair; the leak must be fixed first, then the coating goes on a watertight roof
D. Sometimes, depending on where the leak is

**9. (Advanced)** A repeat client asks for a coating proposal on a roof that, based on the inspection, has chronic ponding and suspected wet insulation. The most appropriate response is:
A. Provide the proposal because the client requested it
B. Provide the proposal but use a higher-tier product
C. Decline to propose coating, explain the disqualifying conditions, and recommend an honest alternative
D. Refer the client to another contractor

**10. (Advanced)** A homeowner claims their previous coating "failed in two years." The most likely root cause, based on patterns described in this chapter, is:
A. Defective product from the manufacturer
B. Climate change accelerating coating degradation
C. The roof did not qualify, or the prep was inadequate
D. Customer applied the coating themselves

---

### Answer Key

1. **B — A liquid-applied waterproofing layer that cures into a seamless membrane.** Single-ply (A) is a different category. "Specialty paint" (C) trivializes the product. Repair sealant (D) confuses category — coating is restoration, not repair.
2. **B — One thousandth of an inch.** A simple unit-of-measurement question. The other options describe other product attributes.
3. **C — Reacting with atmospheric moisture.** Silicone is a moisture-cure chemistry. Drying by evaporation (A) describes solvent-based products; heat-cure (B) describes other chemistries.
4. **B — White reflects sunlight, reduces cooling loads, and supports Title 24 compliance.** "Cheapest pigment" (A) and "only color" (C) are factually wrong. "Hides dirt" (D) is the opposite of true.
5. **C — Soft / spongy underfoot in two areas (suspected wet insulation).** Wet insulation under a coating is a textbook disqualifying condition. Surface dirt (A) is addressable through cleaning. Light chalking (B) is normal aging. Failed pipe boots (D) are repaired before coating.
6. **B — The condition of the substrate underneath and the quality of prep.** This is the central message of the chapter. Brand (A), color (C), and coat count (D) matter less than the substrate and prep.
7. **A — The coating product, but not the substrate underneath.** This is the critical warranty point in Section 14. Customers and reps frequently misunderstand this.
8. **C — No — coating is not a leak repair; the leak must be fixed first.** This is the central honesty point in coating sales. Saying yes (A, B) is the ethics failure.
9. **C — Decline to propose coating, explain the disqualifying conditions, and recommend an honest alternative.** This is the honesty-versus-easy moment from Section 13. Providing the proposal anyway (A, B) is the textbook restoration ethics failure. Referring elsewhere (D) abandons the client.
10. **C — The roof did not qualify, or the prep was inadequate.** Most coating failures trace to qualification or prep issues, not product defects (A) or climate (B).$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '26'
);

-- Part 1 / Ch 3 / Sec 27: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for the silicone products and assemblies USA Flat Roof installs?
- [ ] Matches USA Flat Roof manufacturer certifications and warranty tier offerings?
- [ ] Matches USA Flat Roof workmanship warranty language for coatings?
- [ ] Matches USA Flat Roof inspection process and substrate qualification procedures?
- [ ] Are the disqualifying conditions in Section 13 aligned with our actual proposal practice?
- [ ] Is the single-coat positioning accurate for our standard offering, with appropriate flagging if we offer two-coat alternatives?
- [ ] Are escalation triggers correct for our team structure?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 2 (TPO), 7 (Acrylic), and 18 (Repair vs Restoration vs Replacement)?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's primary silicone manufacturer(s) and warranty tier programs; insert specific terms.
- Code-dependent items: Title 24 cool-roof requirements for restoration projects; confirm with current California Energy Commission and local jurisdiction guidance.
- Regional climate assumptions: 10–15 year NorCal field range. Verify with USA Flat Roof field data across coastal, Bay, Valley, and inland markets.
- Warranty-related statements: substrate vs coating coverage, transferability, USA Flat Roof workmanship terms.
- Company policy items: every [COMPANY POLICY] placeholder, particularly substrate qualification criteria in Section 22.
- Application-specific claims: mil thickness, fabric placement, primer requirements — all flagged for [CHECK MANUFACTURER] verification.
- Sales scripts and proposal language: review against USA Flat Roof current standard proposals and approved customer-facing language, particularly the "roof does not qualify" handling in Section 19.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 3 AND s.section_number = '27'
);

-- Part 1 / Ch 4 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain what asphalt shingle rejuvenation is, what it does at the chemical level, and what it does not do.
2. Identify shingle roofs that are good candidates for rejuvenation and roofs that are not.
3. Inspect a shingle roof for the specific conditions that determine whether rejuvenation will succeed or fail.
4. Position rejuvenation honestly as a proactive maintenance offering — not a leak repair, not a substitute for replacement.
5. Explain rejuvenation lifespan extension claims, warranty structure, and prep requirements to a customer in language that builds trust without overpromising.
6. Recognize when rejuvenation is the wrong recommendation and what to offer instead.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '1'
);

-- Part 1 / Ch 4 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**Roof rejuvenation** is a proactive maintenance treatment applied to existing asphalt shingle roofs. The treatment is a sprayed-on liquid (commonly a bio-based oil or specially formulated polymer) intended to restore flexibility and water-shedding properties to aging shingles.

The chemistry behind the claim: as asphalt shingles age, they lose **plasticizers** — the oil compounds that keep the asphalt flexible. Plasticizer loss causes shingles to become brittle, crack, curl, and shed granules faster. Rejuvenation products are designed to replace some of these lost oils, restoring a measure of flexibility and slowing further deterioration.

USA Flat Roof offers Fresh Roof rejuvenation as a service.

**Rejuvenation can:**
- Replace some of the lost flexibility in aging asphalt shingles
- Slow the rate of further degradation on a qualifying roof
- Extend useful service life by a documented period (varies by product and roof condition)
- Often qualify the roof for a manufacturer-issued service-life extension warranty

**Rejuvenation cannot:**
- Restore a roof at end of life
- Replace damaged or missing shingles
- Repair flashings, vents, or other system components
- Fix leaks
- Restore granule coverage that has been lost
- Add structural strength
- Be applied to other roof types — it is specifically for asphalt shingle

> **[CHECK MANUFACTURER]** Active ingredients, application rates, qualifying age and condition criteria, lifespan extension claims, and warranty terms vary by product. Confirm current Fresh Roof product documentation before quoting any specific scope or extension period.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '2'
);

-- Part 1 / Ch 4 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Primary use:** existing asphalt shingle roofs in mid-life that are showing early aging but are not yet failing
- **Common on:** single-family residential, townhomes, and condominiums with composition shingle roofs
- **Less common on:** new roofs (rejuvenation has no benefit on a roof in its first few years), end-of-life roofs (rejuvenation cannot restore them), tile, metal, or flat roofs (different systems entirely)

In Northern California, rejuvenation is positioned as a maintenance offering for homeowners with composition shingle roofs aged roughly 6–15 years — past the early-life period where it offers no benefit, but well before end of life when it would be too late to help.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '3'
);

-- Part 1 / Ch 4 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### What a freshly rejuvenated roof looks like
- Slightly darker shingle appearance immediately after application as the oil is absorbed
- No surface coating, paint, or visible film once the product has cured into the shingles
- After full cure, the roof looks largely the same as before — slightly refreshed, but not dramatically different
- No granule coverage change (rejuvenation does not add granules; it works at the asphalt level beneath them)

### Recognition during inspection
Unlike a coating, a rejuvenation treatment is essentially invisible after cure. Reps cannot reliably identify whether a roof has been rejuvenated by looking at it. The most reliable indicators are:
- Customer documentation (treatment receipts, warranty documents)
- Service records from a previous contractor
- Manufacturer warranty registration

> **[SALES REP BOUNDARY]** Reps may not certify whether a roof has been previously rejuvenated based on visual inspection alone. Always ask the customer for documentation.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '4'
);

-- Part 1 / Ch 4 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Roof coating (silicone, acrylic, elastomeric)** | Coatings sit on top of the substrate as a visible film. Rejuvenation absorbs into the shingle and is invisible after cure. Coatings change color and texture; rejuvenation does not. |
| **Roof cleaning / soft wash** | Cleaning removes dirt, algae, and biological growth from the surface. Rejuvenation modifies the chemistry of the asphalt itself. The two are different services and address different conditions. |
| **Sealant or "roof sealer"** | Generic "roof sealer" products from hardware stores are typically asphalt emulsion or similar — not the same as engineered rejuvenation products. Sealants form a film; rejuvenation absorbs. |
| **Repairing or replacing shingles** | Rejuvenation is a chemical treatment of intact shingles. It does not replace damaged or missing pieces. |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '5'
);

-- Part 1 / Ch 4 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A rejuvenation service includes more than just the spray:

1. **Pre-application inspection** — confirms the roof qualifies for treatment.
2. **Roof cleaning** *(where required)* — removal of debris, leaves, and surface contaminants. Some products also require treatment of moss or algae before application.
3. **Repairs** — any active issues (lifted shingles, exposed nails, damaged flashings) must be addressed before treatment. **Rejuvenation is not a leak repair.**
4. **Rejuvenation product application** — spray application of the rejuvenation liquid at the manufacturer-specified rate.
5. **Cure period** — product absorbs into the shingles over a defined time window. Cure conditions (temperature, humidity, no rain) matter.
6. **Documentation and warranty registration** — photos, application data, and submission to the manufacturer for warranty registration.

> **[CHECK MANUFACTURER]** Application rate, prep requirements, cleaning standards, weather windows, and warranty registration procedures are product-specific. Confirm with current Fresh Roof contractor documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '6'
);

-- Part 1 / Ch 4 / Sec 7: How It's Applied
UPDATE sections SET
  content_markdown = $mfst$A typical rejuvenation application follows this general sequence. This overview is for awareness only — not an installation specification.

1. **Inspection and qualification** — confirm roof qualifies (age, condition, shingle type).
2. **Document existing condition** — photos and notes for warranty registration.
3. **Repairs and prep** — address any failed shingles, exposed nails, damaged flashings before treatment.
4. **Cleaning** — debris removal; biological growth treatment if required.
5. **Spray application** — the rejuvenation product is sprayed on at the specified rate, typically one application across the full roof field.
6. **Cure period** — typically 24–72 hours under appropriate weather. **[CHECK MANUFACTURER]**
7. **Final documentation** — photos, application data, warranty submission.

> **[CHECK MANUFACTURER]** Specific application rates, equipment, weather windows, and warranty registration steps must be confirmed against current product documentation.

> **[VERIFY LOCALLY]** Some California jurisdictions or HOAs may have requirements relevant to roof spray applications. Confirm before scheduling.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '7'
);

-- Part 1 / Ch 4 / Sec 8: Expected Lifespan Extension
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation does not give a roof a new lifespan — it extends the existing roof's useful service life by a defined period.

- **Industry claim range:** Manufacturer claims for service life extension commonly fall in the range of 5–15 years per treatment, with re-application possible after a defined interval. Actual extension depends on roof condition at time of treatment and ongoing maintenance.
- **Real-world field range (NorCal asphalt shingle):** roughly **5–10 years** of useful extension on roofs in good qualifying condition is a reasonable expectation. Less on roofs treated late in life. More is sometimes claimed by manufacturers — flagged for verification.
- **Factors that affect extension performance:** roof age at time of treatment, shingle condition, ventilation, ongoing maintenance, exposure (sun, trees, debris), and whether the roof was rejuvenated proactively versus reactively.

> **[CHECK MANUFACTURER]** Specific lifespan extension claims and the warranty terms supporting them must be confirmed against current Fresh Roof documentation. Reps should not quote a specific number of years of extension without manufacturer-backed documentation in hand.

### What reps must NOT promise
- A specific number of additional years
- That rejuvenation makes a 20-year-old roof "like new"
- Warranty payouts on poorly qualifying roofs
- Outcomes that the manufacturer does not support in writing

### Suggested customer language
> "Rejuvenation is intended to extend the useful service life of your shingle roof when applied at the right point in its life. The manufacturer publishes extension ranges, and we'll walk you through what's realistic for your roof based on its condition today. We won't promise a specific number of years — but we will tell you whether rejuvenation makes sense for your roof."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '8'
);

-- Part 1 / Ch 4 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Cost-effective maintenance** for shingle roofs in mid-life — a fraction of the cost of replacement.
- **Extends usable life** when applied to a qualifying roof, deferring full replacement.
- **Non-disruptive** — typically a one-day application with no tear-off, no debris, and minimal homeowner impact.
- **Sustainable framing** — rejuvenation extends the life of an existing roof rather than producing tear-off waste.
- **Manufacturer warranty available** when applied by certified contractors on qualifying roofs.
- **Aligns with proactive maintenance philosophy** — addresses roof aging before it becomes failure.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '9'
);

-- Part 1 / Ch 4 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Window of effectiveness** — too early in roof life, no benefit; too late, no benefit. The middle window is where rejuvenation makes sense.
- **Not a leak repair** — actively leaking roofs need repair, not rejuvenation.
- **Not a substitute for replacement** — end-of-life roofs are not candidates.
- **Performance depends on roof condition** — a roof that has been neglected for years may not respond well even within the right age range.
- **Customer expectations management** — homeowners often expect dramatic visible change; rejuvenation works at the chemical level and shows little surface change.
- **Manufacturer warranty terms vary** — coverage scope, transferability, and exclusions need to be reviewed for each product.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '10'
);

-- Part 1 / Ch 4 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like / means |
|---|---|---|
| Rejuvenation applied to a roof that did not qualify | Repair → Urgent | Treatment fails to produce expected results; warranty may not be honored |
| Rejuvenation applied as a leak fix | Urgent | Customer believes leak is resolved; underlying issue continues; secondary damage accumulates |
| Application during inappropriate weather | Repair | Product does not cure properly; uneven absorption; performance compromised |
| Insufficient prep | Repair | Existing damage worsens because it was not addressed before treatment |
| Customer expectation mismatch | Monitor → Maintenance | Customer expected dramatic visible improvement; education was insufficient at sale |
| Rejuvenation applied to wrong roof type | Repair → Urgent | Product applied to non-asphalt-shingle roof; no benefit; potential damage to substrate |
| Rejuvenation applied late in roof life | Repair | Insufficient remaining shingle structure to benefit from treatment |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify whether a previous rejuvenation treatment "worked" or "failed" without proper investigation, and do not diagnose causes of poor rejuvenation performance without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '11'
);

-- Part 1 / Ch 4 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$A rejuvenation inspection is also a shingle roof inspection — but with a specific qualification lens.

**Roof age and history**
- How old is the roof?
- Original installation, prior repairs, prior rejuvenation
- Documentation: warranty papers, prior contractor invoices

**Shingle type and condition**
- Three-tab vs architectural vs designer
- Granule coverage (significant loss disqualifies)
- Flexibility (extreme brittleness suggests roof is past the rejuvenation window)
- Curling, cracking, splitting (limited amounts may still qualify; widespread does not)

**System integrity**
- Flashings, valleys, drip edge condition
- Penetrations, vents, pipe boots
- Ridge cap condition
- Active leaks (disqualifies until repaired)
- Soft or sagging deck (disqualifies)

**Environmental factors**
- Tree overhang and debris exposure
- Slope orientation (south/west exposure may have aged faster)
- Ventilation provisions

**Documentation for warranty registration**
- Photos meeting manufacturer's standards
- Roof age verification
- Shingle type identification

**Red flags that disqualify the roof**
- Active leaks
- Widespread granule loss with exposed asphalt
- Significant curling, cracking, or splitting across the field
- Damaged or missing shingles in multiple locations
- Soft or sagging deck
- Suspected wet decking or insulation
- Roof age outside the manufacturer's qualifying window

**Red flags requiring escalation**
- Suspected hail or storm damage involving an insurance claim
- Multiple roof layers
- Solar array on the roof
- Customer requesting rejuvenation on a roof that does not qualify$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '12'
);

-- Part 1 / Ch 4 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$For rejuvenation, the Good/Better/Best framework is best understood as: *which form of care is honest for this roof's stage of life?*

### Scenario A: 7-year-old architectural shingle roof, good condition, no problems

- **Good:** routine maintenance — gutter cleaning, debris removal, annual inspection.
- **Better (right call):** proactive rejuvenation. Roof is in the early-mid window where treatment provides full benefit and warranty registration is most valuable.
- **Best:** *Not appropriate.* Replacement on a 7-year-old roof in good condition would be wrong on multiple counts.

### Scenario B: 14-year-old architectural shingle roof, light granule loss, two lifted tabs, no leaks

- **Good:** repair the lifted tabs, recommend annual maintenance.
- **Better (right call):** repair first, then rejuvenation. Roof qualifies — mid-life, sound substrate, addressable details. Treatment extends useful service life and defers replacement.
- **Best:** plan for replacement in 5–10 years if exposure conditions are aggressive or budget allows.

### Scenario C: 23-year-old three-tab shingle roof, widespread granule loss, multiple cracked shingles, two leaks

- **Good:** *Not appropriate.* Spot repair is short-term spending on an end-of-life roof.
- **Better:** *Not appropriate — and this is the critical sales moment.* A rejuvenation recommendation here would fail Rule 5. The shingles do not have enough remaining structure to benefit from treatment. The customer's money would be wasted, and the manufacturer warranty would not be honored on a roof that did not qualify.
- **Best (right call):** full replacement. Honest scope and pricing. Recommend this even though rejuvenation is an easier sell on price.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific qualification criteria for proposing rejuvenation: minimum and maximum roof age, shingle condition standards, required pre-treatment repairs.

### The honest-versus-easy moment

Rejuvenation is one of the easiest products in roofing to oversell:
- Lower price than replacement
- Faster project than replacement
- Customer often *prefers* the cheaper answer
- Visible inspection results are subtle, so reps can fudge "qualifying" without immediate consequence
- Failure shows up years later, after the rep has moved on

This is the moment the rep faces in Rule 3: the most honest recommendation (replacement on a non-qualifying roof) is the harder, larger sell. Proposing rejuvenation anyway is the textbook ethics failure.

USA Flat Roof reps offer rejuvenation when the roof qualifies — and only then. The trust earned by walking away from a non-qualifying treatment is worth more in repeat business and referrals than the close.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '13'
);

-- Part 1 / Ch 4 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation warranties typically have two layers:

- **Manufacturer warranty** — covers the rejuvenation product's effectiveness for a defined period when applied to a qualifying roof by a certified contractor. Specific coverage and exclusions vary.
- **Workmanship (contractor) warranty** — covers the application itself.

### Critical points reps must understand

- The manufacturer warranty typically covers **the rejuvenation treatment**, not the underlying roof. If the roof leaks because of failed flashings or substrate issues unrelated to the shingle aging, the rejuvenation warranty does not pay for those repairs.
- Warranty registration usually requires specific documentation submitted within a defined window. Missed documentation can void the warranty.
- Warranty terms vary on whether they transfer at sale of the home.

### What commonly voids or limits warranties
- Application to a roof that did not qualify
- Insufficient prep
- Application during inappropriate weather
- Subsequent modifications, additions, or unauthorized work
- Lack of documented maintenance
- Missed warranty registration

### What reps must not promise
- A specific service-life extension number unsupported by manufacturer documentation
- That the warranty covers all leaks
- That the warranty covers the substrate or system components
- That the warranty transfers automatically at sale

> **[COMPANY POLICY]** Placeholder — USA Flat Roof warranty terms for Fresh Roof applications, our role in warranty registration, and our workmanship warranty.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '14'
);

-- Part 1 / Ch 4 / Sec 15: Ideal Customer Profile + Pain Points
UPDATE sections SET
  content_markdown = $mfst$Because USA Flat Roof positions rejuvenation primarily as proactive maintenance, the customer profile is different from the typical "roof emergency" call.

| Customer type | Why they call (or are called) | Common pain points |
|---|---|---|
| Homeowner with a 7–14 year old roof | Wants to extend life, defer replacement | Budget consciousness, sustainability values, reluctance to spend on replacement before necessary |
| Homeowner planning to stay long-term | Capital planning, home maintenance mindset | Wants to maximize life of existing system |
| Property manager (residential portfolio) | Asset preservation across multiple homes | Predictable maintenance budgets, defensible recommendation, scalable service |
| Real estate agent / seller | Pre-listing preparation | Wants documentation showing roof has been maintained |
| HOA boards (governed communities) | Community-wide maintenance programs | Group decision dynamics, transparency, defensible scope |

### Pain points across customer types
- "My roof isn't broken — I don't want to spend money on it."
- "I can't afford a full replacement right now."
- "I want to make my roof last as long as possible."
- "How do I know this isn't just a gimmick?"
- "What's the difference between this and a coating?"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '15'
);

-- Part 1 / Ch 4 / Sec 16: Lead Qualification Questions
UPDATE sections SET
  content_markdown = $mfst$Ask these before or during the inspection:

1. How old is the roof, to your best knowledge?
2. What kind of shingle is it — three-tab or architectural? Do you know the manufacturer?
3. Has the roof been rejuvenated, coated, or treated previously? When? With what product?
4. Has the roof been repaired in the last few years? What was repaired?
5. Are there any active leaks, or have you seen any signs of leaking inside?
6. Are there any rooms where you've placed buckets or moved furniture during a storm?
7. How long do you plan to be in this home?
8. What's your goal — extend the life of this roof, or plan for replacement?
9. Are you the original owner, or did you inherit the roof at purchase?
10. What outcome would make this engagement a success for you today?$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '16'
);

-- Part 1 / Ch 4 / Sec 17: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "Asphalt shingles age in part because the oils that keep them flexible dry out over time. Once the shingles get brittle, they crack and shed granules faster, and the roof ages quicker. Rejuvenation is a treatment we spray on that's designed to replace some of those lost oils — restoring flexibility and slowing further aging. It works best when applied to a roof in mid-life, before significant damage has set in. It's not a coating, it's not a leak repair, and it's not a replacement. When the timing is right, it's a cost-effective way to extend the useful life of your roof."

### Talking points (honest selling angles)

1. Rejuvenation is a maintenance treatment, not a repair or a replacement. The right time to apply it is in the middle of a roof's life — too early, no benefit; too late, no benefit.
2. The treatment is invisible after cure — it works at the chemical level, not the surface level. Customers should expect their roof to look largely the same afterward.
3. Manufacturer warranty matters. We register every treatment so you have documentation for resale and for any warranty claim.
4. We will only recommend rejuvenation if your roof qualifies. If it doesn't, we'll be straight with you about that.
5. Rejuvenation is part of a broader maintenance approach — clean gutters, address small repairs early, ventilation matters, and rejuvenation extends what good maintenance has already preserved.

### FAQ

- **Q: Will I see a visible difference?** A: Honestly, not much. Right after we apply it, the roof looks slightly darker because the oil is being absorbed. Once it cures fully, your roof looks largely the same. Rejuvenation works at the asphalt level, beneath the granules. Surface-level products like coatings change appearance; rejuvenation does not.
- **Q: How many years will this add to my roof?** A: The manufacturer publishes extension claims, and we'll walk you through what's realistic for your roof based on its current condition. We won't quote you a specific number of years — that depends on the roof, the maintenance, and the conditions.
- **Q: Is this just paint or sealer?** A: No. Paint and surface sealers form a film on top of the shingles. Rejuvenation absorbs into the asphalt itself and is gone from the surface after cure. Different chemistry, different purpose.
- **Q: Will this fix my leak?** A: No. Rejuvenation is not a leak repair. If you have a leak, we have to find and repair it first. Then if your roof qualifies, rejuvenation can extend its life from there.
- **Q: Can I just do this every few years instead of replacing the roof?** A: There are limits. Rejuvenation extends life within a window — eventually the roof reaches the end of what treatment can support, and replacement becomes the right answer. The right way to think about it is: rejuvenation extends life, it doesn't reset it.
- **Q: Is this safe for my landscaping and pets?** A: We'll review the specific product safety data with you and address any precautions before application. **[CHECK MANUFACTURER]**
- **Q: What if it doesn't work?** A: The manufacturer warranty addresses that. We register every treatment, so you have documentation. Realistically, when we recommend rejuvenation, it's because we've inspected the roof and confirmed it qualifies — that's the most important factor in performance.

### Objections & Responses

- **"My neighbor said this stuff is a scam."** A: I understand the concern. There are real engineered rejuvenation products with manufacturer warranties, and there are products that don't perform. The chemistry is real — asphalt shingles do lose plasticizers, and the right product can replace them. We'll show you the manufacturer documentation, and we'll only recommend it if your roof qualifies.
- **"I'd rather just save up for a new roof."** A: That's a completely fair plan. If your roof has 10–15 years of remaining life and rejuvenation can extend that meaningfully, it could change the timing of when you need to save for replacement. We'll lay out the math honestly so you can decide.
- **"My roof is 25 years old — let's do this."** A: Honest answer: at 25 years, your roof is past the window where rejuvenation provides real benefit. We can inspect to confirm, but it's likely the right answer is replacement, not treatment. I'd rather tell you that now than take your money for a treatment that won't perform.
- **"Why is this so much cheaper than a coating?"** A: Different products doing different jobs. A coating is a continuous waterproof layer added over a roof — that's a lot of material, prep, and labor. Rejuvenation is a chemical treatment of existing shingles — different scope. They're not comparable.
- **"My insurance won't cover this."** A: Most insurance policies cover damage events, not maintenance. Rejuvenation is preventive maintenance, similar to gutter cleaning or fence painting. We're not insurance experts, and we won't promise an outcome with your carrier — but maintenance services are typically a homeowner expense.

### Common sales mistakes (do not do)

- Quoting a specific number of additional years
- Recommending rejuvenation on a roof that does not qualify
- Calling rejuvenation a "leak fix" or "repair"
- Promising the roof will look dramatically different
- Comparing rejuvenation to coatings as if they're equivalent
- Promising warranty outcomes without reading the actual warranty
- Promising insurance approval or claim outcomes
- Selling the treatment without confirming the manufacturer's qualifying conditions are met$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '17'
);

-- Part 1 / Ch 4 / Sec 18: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Rejuvenation recommendation (qualifying roof):**
> Based on inspection, the existing roof qualifies for Fresh Roof rejuvenation: roof age within the qualifying window, shingles in serviceable condition with sound flexibility and intact granule coverage, no active leaks, and addressable detail repairs. Recommended scope: detail repairs at [locations], debris removal and cleaning, single rejuvenation application per manufacturer specification, photo documentation, and warranty registration. Rejuvenation is intended to extend useful service life — it is not a leak repair, replacement, or substitute for ongoing maintenance. Workmanship warranty per USA Flat Roof terms. Manufacturer warranty per Fresh Roof program subject to qualifying conditions and registration. **[CHECK MANUFACTURER]** Confirm current product, application rate, and warranty terms.

**Rejuvenation not recommended (does not qualify):**
> Based on inspection, the existing roof does not qualify for rejuvenation at this time. Conditions observed include [specific findings — e.g., roof age outside qualifying window, widespread granule loss, multiple damaged shingles, active leak]. Rejuvenation would not perform reliably and would not be supported by manufacturer warranty. We recommend [repair / replacement / further evaluation] instead.

**Rejuvenation as part of a maintenance program:**
> The existing roof is in good condition for its age. Recommended scope: annual inspection, gutter and debris service, minor sealant work as needed, and Fresh Roof rejuvenation to extend useful service life. Rejuvenation is positioned as a proactive maintenance step — applied while the roof is still in good condition rather than after problems develop.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '18'
);

-- Part 1 / Ch 4 / Sec 19: Role-Play Scenario
UPDATE sections SET
  content_markdown = $mfst$**Setting:** Two-story 2009 home in San Jose. Homeowner saw an ad for roof rejuvenation and called USA Flat Roof for a quote. Roof is 17-year-old architectural composition shingle with widespread moderate granule loss, several curled tabs, exposed nails in two areas, and one prior repair patch.

**Customer:** "I want the rejuvenation treatment. My neighbor got hers done and her roof looks great. How fast can you get me a number?"

**Rep should:**

1. Acknowledge the customer's preference without committing to it.
2. Inspect the full roof carefully — both for rejuvenation qualification and overall condition.
3. Document granule coverage, shingle flexibility, detail condition, and any signs of advancing aging.
4. Determine honestly whether the roof still qualifies given its age and condition.
5. Present the honest answer.
6. Handle the conversation if the recommendation is not what the customer wanted.

**Sample handling — roof qualifies (lighter version of the scenario):**

> "Good news — based on what we found, your roof still qualifies for rejuvenation. We did note the curled tabs and exposed nails — those need to be addressed before we apply the treatment, because rejuvenation isn't a repair. Once we take care of those, we can do the application, and we'll register it with the manufacturer for warranty. We're not going to promise you a specific number of years — the manufacturer's published extension claims are the basis, and your roof is at the older end of the qualifying window. Realistically, this extends life on a roof that's still got runway, but eventually replacement becomes the right call. Want me to put options on paper?"

**Sample handling — roof does not qualify (the harder version):**

> "I want to give you the honest answer here. We did the inspection, and your roof is past the window where rejuvenation provides real benefit. The granule loss is significant — that's not something rejuvenation can rebuild. The shingles are losing structure, not just oils. If we applied rejuvenation today, the manufacturer wouldn't honor the warranty because the roof doesn't qualify, and you wouldn't get the extension you're paying for. I'd rather tell you that now than take your money for something that won't perform. The honest answer is replacement — and I can put a proposal together for that whenever you're ready. No pressure, no hard sell. I just don't want to sell you the wrong thing."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '19'
);

-- Part 1 / Ch 4 / Sec 20: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every rejuvenation inspection:**

- All four elevations from ground level
- Each roof slope from elevated view
- Close-up granule coverage shots (multiple slopes)
- Close-up flexibility/condition shots (multiple slopes)
- Every penetration, vent, and detail
- Every flashing
- Any damaged or curled shingles
- Gutter check (granule accumulation)
- Interior leak evidence if reported
- Any condition flagged for repair before treatment

**Documentation for warranty registration:**

- Roof age (best estimate, source)
- Shingle type (three-tab, architectural, designer)
- Manufacturer if known
- Pre-application photos meeting manufacturer's standards
- Application date, weather conditions, and product batch information **[CHECK MANUFACTURER]**

**Severity rating** applied to each documented condition using the four-point scale.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '20'
);

-- Part 1 / Ch 4 / Sec 21: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Roof age or condition is borderline for rejuvenation qualification
- Customer requests rejuvenation on a roof the rep believes does not qualify
- Suspected hail or storm damage with insurance involvement
- Multiple roof layers
- Solar array on the roof
- Suspected mold, asbestos, or other hazard
- Customer requesting specific warranty interpretation
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '21'
);

-- Part 1 / Ch 4 / Sec 22: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred rejuvenation product (Fresh Roof) and certifications: [placeholder]
> - Our standard application rate and procedures: [placeholder]
> - Our minimum and maximum roof age criteria for proposing rejuvenation: [placeholder]
> - Our shingle condition criteria for qualifying: [placeholder]
> - Required pre-treatment repairs included in our standard scope: [placeholder]
> - Our warranty registration procedures and timing: [placeholder]
> - When we will and will not propose rejuvenation: [placeholder]
> - Our standard proposal options for rejuvenation: [placeholder]
> - Our workmanship warranty language for rejuvenation: [placeholder]
> - Our maintenance program offerings that include rejuvenation: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '22'
);

-- Part 1 / Ch 4 / Sec 23: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat rejuvenation as comparable to coatings — they're not the same chemistry, the same purpose, or the same scope.
- They overstate how visible the result will be.
- They quote specific lifespan extension numbers without manufacturer documentation.
- They miss the disqualifying conditions — particularly age past the window and significant granule loss.
- They follow the customer's preference instead of the inspection findings.
- They forget that rejuvenation is not a leak repair — and let customers believe it is.
- They underestimate the importance of warranty registration documentation.

**Discussion questions for group training**
- Walk through Scenario C (23-year-old three-tab). Why is recommending rejuvenation here a worse outcome for the company than walking away?
- A homeowner says "my neighbor's roof was rejuvenated and it looks brand new." How do you handle the visual expectation without sounding evasive?
- A repeat customer with a non-qualifying roof asks for rejuvenation specifically. What do you do?
- What's the 30-second answer to "is this the same thing as a coating?"
- A homeowner asks "how many years will this add?" What's a strong honest answer?

**Field exercises**
- Pair up. Review three sets of inspection photos. Identify whether each roof qualifies, doesn't qualify, or needs further inspection.
- Walk a real composition shingle roof together. Have the trainee identify roof age indicators, shingle condition indicators, and qualifying status before the trainer reviews.
- Practice the role-play scenario in Section 19 in both versions (qualifies / does not qualify). Rotate roles.
- Review three rejuvenation proposals (real or constructed). Identify any language that overpromises lifespan extension.

**What the manager should test verbally**
- Distinguish rejuvenation from coatings, sealers, and repairs.
- Name the disqualifying conditions for rejuvenation.
- Explain the chemistry of asphalt aging in plain customer language.
- Walk through Scenario B and C and explain the recommendation in each.
- State five things a rep must not promise.
- Recite the honesty-versus-easy moment in their own words.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '23'
);

-- Part 1 / Ch 4 / Sec 24: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Asphalt shingle aging** — gradual loss of plasticizers, granules, and flexibility over time.
- **Asphalt shingle rejuvenation** — chemical treatment intended to restore flexibility to aging shingles by replacing lost oils.
- **Granule loss** — wearing-off of the protective ceramic-coated rock particles from shingle surfaces.
- **Mid-life window** — the period in a roof's service life during which rejuvenation provides meaningful benefit; varies by product and manufacturer.
- **Plasticizer** — oil compound in asphalt that maintains flexibility.
- **Proactive maintenance** — service performed before failure, to extend system life.
- **Service life extension** — the additional years of useful roof life expected after rejuvenation.
- **Warranty registration** — manufacturer process required to activate coverage; missing registration may void warranty.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '24'
);

-- Part 1 / Ch 4 / Sec 25: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Asphalt shingle rejuvenation is a maintenance treatment that replaces some of the oils lost as shingles age. USA Flat Roof offers Fresh Roof rejuvenation as a proactive maintenance service, positioned for shingle roofs in the mid-life window — past the early-life period when there's no benefit, but well before end of life when it would be too late. Rejuvenation is not a coating, not a leak repair, and not a substitute for replacement. The most important sales judgment in this chapter is honest qualification: when the roof qualifies, rejuvenation is a real and valuable maintenance offering; when it does not, the rep must not propose it, no matter how much the customer wants the cheaper answer. Manufacturer warranties cover the rejuvenation treatment, not the underlying roof — and only when applied to qualifying roofs by certified contractors with proper documentation. Reps should expect minimal visible change after application, set customer expectations accordingly, and escalate any roof in borderline qualifying condition.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '25'
);

-- Part 1 / Ch 4 / Sec 26: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** Roof rejuvenation is best described as:
A. A coating that creates a new waterproof layer
B. A chemical treatment intended to replace oils lost in aging asphalt shingles
C. A repair service for shingle leaks
D. A replacement product for damaged shingles

**2. (Beginner)** Rejuvenation works best on roofs that are:
A. Brand new
B. In their mid-life period, before significant damage has occurred
C. At end of life with widespread granule loss
D. Any age — rejuvenation works equally on all roofs

**3. (Beginner)** Rejuvenation is appropriate for:
A. Asphalt shingle roofs only
B. All roof types including tile, metal, and flat roofs
C. Flat commercial roofs primarily
D. Wood shake and slate roofs

**4. (Beginner)** After rejuvenation cures, what visible change should the customer expect?
A. The roof will look brand new with restored color
B. The roof will be noticeably reflective
C. Minimal visible change — rejuvenation works at the asphalt level, not the surface
D. The roof will be visibly coated with a glossy finish

**5. (Intermediate)** A homeowner with a 23-year-old three-tab roof, widespread granule loss, and active leaks wants rejuvenation. The most appropriate response is:
A. Apply the rejuvenation as requested
B. Apply rejuvenation but with a higher application rate
C. Decline to propose rejuvenation, explain why the roof does not qualify, and recommend an honest alternative
D. Offer rejuvenation only if the customer signs a waiver

**6. (Intermediate)** A customer asks "How many years will this add to my roof?" The best response is:
A. Quote the maximum number from the manufacturer's marketing materials
B. Refer to the manufacturer's published extension range and note that actual results depend on roof condition and maintenance
C. Promise a specific number of years based on the warranty
D. Tell the customer that rejuvenation has no defined lifespan extension

**7. (Intermediate)** A rejuvenation manufacturer warranty typically covers:
A. The rejuvenation treatment itself, when applied to a qualifying roof per program requirements
B. All future leaks regardless of cause
C. The full roof system including substrate
D. Replacement of the roof at end of treatment life

**8. (Intermediate)** Which of the following most clearly disqualifies a shingle roof from rejuvenation?
A. Light surface dirt and minor algae streaks
B. Roof age outside the manufacturer's qualifying window with widespread granule loss
C. Moderate granule loss with intact shingle structure
D. A single curled shingle tab

**9. (Advanced)** A homeowner says "my neighbor's roof looks brand new after rejuvenation." The most honest response is:
A. Confirm that rejuvenation produces dramatic visible improvement
B. Explain that rejuvenation works at the asphalt level beneath the granules and produces only subtle visible change; whatever the neighbor saw may be from cleaning or other work
C. Promise the same dramatic result for the customer's roof
D. Suggest the neighbor used a different, better product

**10. (Advanced)** USA Flat Roof's positioning of rejuvenation is best described as:
A. An emergency leak repair service
B. A proactive maintenance offering for shingle roofs in their mid-life window
C. A substitute for full roof replacement at any age
D. A surface coating similar to silicone or acrylic

---

### Answer Key

1. **B — A chemical treatment intended to replace oils lost in aging asphalt shingles.** Coating (A) is a different product category. Repair (C) is a different service. Replacement (D) misrepresents the product entirely.
2. **B — In their mid-life period, before significant damage has occurred.** This is the central window concept of the chapter. Brand new (A) gets no benefit; end of life (C) is past the window; "any age" (D) is the marketing-overstatement trap.
3. **A — Asphalt shingle roofs only.** Other roof types use entirely different systems and chemistries.
4. **C — Minimal visible change.** This is the central customer-expectation point. Promising visible improvement (A, B, D) is the sales mistake to avoid.
5. **C — Decline to propose rejuvenation, explain why the roof does not qualify, and recommend an honest alternative.** This is the honesty-versus-easy moment from Section 13. Applying rejuvenation anyway (A, B) is the textbook ethics failure. A waiver (D) does not solve the underlying problem of selling a non-performing service.
6. **B — Refer to the manufacturer's published extension range and note that actual results depend on roof condition and maintenance.** Quoting marketing maximums (A) and promising specific numbers (C) violate the no-fake-precision rule. "No defined extension" (D) is wrong — the manufacturer publishes ranges.
7. **A — The rejuvenation treatment itself, when applied to a qualifying roof per program requirements.** This is the critical warranty point in Section 14. The other options overstate what the warranty covers.
8. **B — Roof age outside the manufacturer's qualifying window with widespread granule loss.** The other conditions are addressable or fall within normal qualifying ranges.
9. **B — Explain that rejuvenation works at the asphalt level and produces subtle visible change.** Confirming the neighbor's claim (A, C) sets up false expectations. Bashing the neighbor's product (D) is unprofessional and unsupported.
10. **B — A proactive maintenance offering for shingle roofs in their mid-life window.** This matches USA Flat Roof's specific positioning. Emergency repair (A), replacement substitute (C), and surface coating (D) all misrepresent the product.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '26'
);

-- Part 1 / Ch 4 / Sec 27: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California residential market?
- [ ] Accurate for the Fresh Roof program USA Flat Roof participates in?
- [ ] Matches USA Flat Roof contractor certification and warranty registration procedures?
- [ ] Matches USA Flat Roof workmanship warranty language for rejuvenation?
- [ ] Matches USA Flat Roof inspection process and qualification criteria?
- [ ] Are the disqualifying conditions in Section 13 aligned with our actual proposal practice?
- [ ] Is the proactive maintenance positioning aligned with our actual sales approach (versus reactive offering for declined replacement)?
- [ ] Are escalation triggers correct for our team structure?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 1 (Composition Shingle) and Chapter 18 (Repair vs Restoration vs Replacement)?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm Fresh Roof program details, current product specifications, application rates, qualifying age window, qualifying condition criteria, warranty terms, registration requirements. Every product-specific claim in this chapter is flagged [CHECK MANUFACTURER] and must be verified against current Fresh Roof contractor documentation.
- Service life extension claims: the 5–10 year and 5–15 year ranges in Section 8 are placeholder. Confirm with current Fresh Roof documentation.
- Cure conditions: temperature, humidity, weather windows. Confirm with current product data sheet.
- Safety data: customer-facing safety information for landscaping and pets. Confirm with current SDS.
- Code-dependent items: California jurisdictional or HOA requirements relevant to roof spray applications.
- Warranty-related statements: coverage scope, transferability, registration timing, USA Flat Roof workmanship terms.
- Company policy items: every [COMPANY POLICY] placeholder, particularly qualification criteria in Section 22.
- Sales scripts and proposal language: review against USA Flat Roof current standard proposals and approved customer-facing language, particularly the "roof does not qualify" handling in Section 19.

*No external citations included. All product-specific items marked for verification. The single most important verification step before publishing this chapter is confirming the qualifying age and condition criteria against current Fresh Roof contractor documentation, since incorrect criteria would produce both warranty failures and ethical problems.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 4 AND s.section_number = '27'
);

-- Part 1 / Ch 5 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify PVC roofs on sight and distinguish them from TPO and other single-ply systems.
2. Explain the practical differences between PVC and TPO and when PVC is the better answer.
3. Inspect a PVC roof and classify common conditions on the Inspection Severity Scale.
4. Position PVC honestly — both as a premium choice for specific applications and as a TPO alternative when a customer asks.
5. Recognize when a PVC roof condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '1'
);

-- Part 1 / Ch 5 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**PVC** stands for **polyvinyl chloride** — a single-ply roof membrane used on flat and low-slope commercial buildings. Like TPO, PVC is a **thermoplastic** material, meaning it can be melted and re-fused by heat. PVC seams are joined by **hot-air welding**, the same method used on TPO.

PVC has been used on commercial roofs in the United States since the 1960s, giving it the longest field track record of any single-ply membrane. It is generally positioned as a **premium** flat-roof option — higher cost than TPO, with specific performance advantages in chemical-exposure environments, grease-vent zones, and applications demanding longer expected service life.

USA Flat Roof installs PVC for two reasons: as the right answer for buildings with chemical or grease exposure, and as a customer-requested alternative to TPO when the property owner specifies it.

> **[CHECK MANUFACTURER]** PVC product lines, mil thickness options, attachment methods, and warranty tiers vary by manufacturer. Confirm current product data sheets before quoting any specific scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '2'
);

-- Part 1 / Ch 5 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Common applications:** restaurants and food service, commercial kitchens with grease vents, manufacturing buildings with chemical exhaust, hospitals, schools, hotels, multi-tenant commercial where longer expected service life is valued
- **Niche applications:** roofs with significant chemical or oil exposure that would damage TPO; buildings where the owner specifically values PVC's longer field track record
- **Less common on:** single-family residential, structures with extensive curved or sloped geometry, low-budget commercial where cost drives the decision toward TPO

In Northern California, PVC is widely seen on restaurant rows, retail food service, hospitals, and older commercial buildings where the original PVC roof has performed for decades and the owner wants to stay with the same product family.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '3'
);

-- Part 1 / Ch 5 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### Visual identification
- Smooth, matte-finish white membrane (most common color), occasionally gray or tan
- Visible welded seams running across the roof at regular intervals
- Slightly more flexible and slick to the touch than TPO when felt up close
- Often slightly thinner-feeling than TPO at the same nominal mil thickness

### How to distinguish PVC from TPO

This is the single most important recognition skill in this chapter. PVC and TPO look nearly identical from a distance. Up close, the differences are subtle and not always reliable.

| Indicator | PVC | TPO |
|---|---|---|
| Surface feel | Slightly more flexible, slick | Firmer, less slick |
| Weld appearance at seams | Smooth, slightly glossy weld bead | Matte weld bead |
| Edge cut appearance | Cuts cleanly with a slight resistance | Cuts cleanly, slightly stiffer |
| Solvent test (production team only) | PVC reacts to MEK or PVC cleaner | TPO does not react to PVC cleaner |
| Documentation | Project records, warranty paperwork | Same |

**The reliable answer is documentation, not visual inspection.** Reps should not certify PVC vs TPO by appearance alone.

> **[SALES REP BOUNDARY]** Reps may identify a roof as "appears to be PVC or TPO" based on visual indicators. Product type cannot be certified without documentation. Solvent testing is a production-team task, not a sales-rep task.

[IMAGE #1]
Type: Photo
Priority: Required
Source preference: Company photo
Description: Side-by-side close-up comparison of PVC and TPO membranes, showing surface texture and weld bead. Same lighting and angle.
Purpose: Train reps on the (limited) visual differences.
Caption: PVC (left) and TPO (right) at close range. Differences are subtle — documentation remains the most reliable identification method.
Alt text: Two close-up photos of white single-ply roof membranes showing surface and seam texture.
Annotation needed: Yes — call out surface and weld bead.
Review status: Conceptual only$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '4'
);

-- Part 1 / Ch 5 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **TPO** | Nearly identical from a distance. Differences are subtle (see Section 4). Documentation is the reliable answer. |
| **EPDM** | EPDM is rubber, almost always black, with glued or taped seams (not welded). |
| **Modified bitumen** | Mod-bit has a granular or smooth asphalt surface with torch-down or self-adhered seams. No hot-air welds. |
| **Silicone or acrylic coating over an old PVC roof** | A coating shows brush/spray texture and continuous wrap over details. PVC shows factory-uniform finish with welded seams. |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '5'
);

-- Part 1 / Ch 5 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A PVC system is layered the same way as TPO. From the structure up:

1. **Roof deck** — typically metal (steel) on commercial buildings; sometimes wood, concrete, or gypsum.
2. **Vapor retarder** *(in some assemblies)* — limits water-vapor migration into insulation.
3. **Insulation** — typically polyiso rigid foam.
4. **Cover board** — gypsum-based or HD polyiso, providing a stable membrane substrate.
5. **PVC membrane** — the waterproofing sheet itself, in rolls with overlapping welded seams.
6. **Fasteners and plates** *(mechanically attached systems)* or **adhesive** *(fully adhered systems)*.
7. **Welded seams** — hot-air welded into a continuous membrane.
8. **Flashings** — PVC-coated metal or membrane flashings at parapet walls, curbs, drains, and penetrations.
9. **Termination details** — termination bars, counter-flashing, sealant, metal coping.
10. **Drains and scuppers** — drainage components.

> **[CHECK MANUFACTURER]** Membrane thickness, attachment method, fastener spacing, welding parameters, and detail requirements are product- and project-specific.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '6'
);

-- Part 1 / Ch 5 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$PVC installation follows the same general sequence as TPO: tear-off or prep, vapor retarder where specified, insulation, cover board, membrane laid in rolls, mechanical attachment or adhesive bonding, hot-air welding of seams, flashings and details, terminations, and final inspection including seam probe-testing.

The two systems use identical installation methods at the assembly level. Differences are at the product level — chemistry, thickness options, accessory compatibility, and manufacturer details.

> **[CHECK MANUFACTURER]** Welding parameters and detail specifications differ between PVC manufacturers and between PVC and TPO. Production teams trained on TPO cannot transfer assumptions directly.

> **[VERIFY LOCALLY]** Title 24 cool-roof requirements affect PVC color and reflectivity for many California commercial occupancies. Local jurisdiction may add wind-uplift or fire requirements.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '7'
);

-- Part 1 / Ch 5 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$- **Industry rating range:** Manufacturer warranties commonly run 20, 25, or 30 years on PVC — generally one tier longer than equivalent TPO offerings.
- **Real-world field range (60-mil PVC, NorCal):** roughly **20–30 years** with reasonable maintenance. Premium thicker systems and ideal conditions may exceed this; harsh conditions, ponding, or installation issues shorten it.
- **Track record advantage:** PVC has the longest documented field service history of any single-ply membrane, with installations from the 1970s and 1980s still in service. This history is a real advantage when customers value proven longevity.
- **Factors that shorten lifespan:** chronic ponding, mechanical damage, plasticizer migration over decades, UV exposure on weak seams, deferred maintenance.
- **Factors that extend lifespan:** good drainage, walk pads, regular inspections, prompt repair of seam issues and details.

> **[VERIFY LOCALLY]** NorCal climate variation affects PVC similarly to TPO. Confirm specific patterns with field experience.

### What reps must NOT promise
- Specific service-life numbers
- That PVC "always lasts longer than TPO" — performance depends on installation, maintenance, and conditions
- Warranty payouts on aging systems
- Outcomes contingent on customer maintenance behavior

### Suggested customer language
> "PVC commonly performs in the range of about 20 to 30 years in this area, depending on drainage, maintenance, and how heavily the roof is used by other trades. PVC has the longest field track record of any single-ply membrane, which matters to some owners. We won't quote a specific number of years — but we'll quote you on the work and the warranty."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '8'
);

-- Part 1 / Ch 5 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Longest field track record** of any single-ply membrane.
- **Excellent chemical and grease resistance** — the primary technical advantage over TPO. PVC tolerates restaurant grease, kitchen exhaust, and many industrial chemical exposures that damage TPO.
- **Welded seams** create a continuous monolithic membrane.
- **Reflective white surface** reduces cooling loads and supports Title 24 compliance.
- **Available in factory-fabricated detail accessories** — corners, pipe boots, walkway pads — that streamline installations.
- **Fire performance** — PVC is inherently flame-retardant by chemistry, an advantage in some occupancies.
- **Repairable** with patches and additional welding, like TPO.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '9'
);

-- Part 1 / Ch 5 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Higher cost** than TPO for equivalent specifications.
- **Plasticizer migration over decades** can cause older PVC to become more rigid; this is the primary long-term aging mechanism.
- **Compatibility with some adjacent materials matters** — asphalt-based products and some sealants can interact poorly with PVC.
- **Welding parameters differ from TPO** — production teams need correct training; cross-application of techniques causes seam failures.
- **Recyclability** is a sometimes-cited environmental concern; this is a complex topic and varies by jurisdiction and recycler.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '10'
);

-- Part 1 / Ch 5 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Surface dirt and biological staining | Monitor → Maintenance | Dark patches, particularly under tree cover |
| Chronic ponding water | Maintenance → Repair | Persistent water, dirt rings, accelerated wear |
| Seam separation | Repair → Urgent | Edges no longer fused; gap visible |
| Punctures and tears | Repair → Urgent | Holes from tools, debris, or foot traffic |
| Failed pipe boot or detail | Repair | Cracked, separated, or shrinking flashing |
| Failed parapet flashing | Repair → Urgent | Wall flashing pulled, separated, or unsealed |
| Drain failure | Repair → Urgent | Clogged or damaged drain; standing water |
| Membrane shrinkage at perimeter | Repair → Urgent | Flashings pulling tight, exposed terminations |
| UV degradation / chalking | Maintenance → Repair | Powdery surface, particularly at seams and edges |
| Plasticizer migration (older systems) | Repair → Urgent | Membrane stiffening, loss of flexibility, cracking |
| Damage from other trades | Repair → Urgent | Tool drops, scuffs, sealant smears, unauthorized penetrations |
| Active interior leak | Urgent | Water staining or drip inside the building |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify storm or insurance damage, identify root cause of a leak without proper testing, or determine whether an aged PVC roof qualifies for restoration without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '11'
);

-- Part 1 / Ch 5 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$PVC inspection follows the same general process as TPO inspection (see Chapter 2, Section 12). The differences are:

- **Note any chemical or grease exposure environments** — restaurant exhaust, kitchen vents, industrial discharge points. These zones often show accelerated wear and confirm why PVC was specified in the first place.
- **Older PVC roofs (15+ years)** — check for membrane stiffness and any visible cracking, particularly at corners, transitions, and high-stress areas. Plasticizer migration becomes a relevant aging factor on older systems.
- **Confirm product type if possible** — review project documentation, warranty paperwork, or manufacturer markings on the membrane edges. Do not certify PVC vs TPO by appearance alone.

**Red flags requiring immediate escalation**
- Active interior leak with unknown source
- Suspected wet insulation
- Visible structural deflection or sagging deck
- Widespread seam failure
- Older PVC showing widespread stiffening and cracking — this is an end-of-life indicator
- Unauthorized work by other trades
- Solar array on the roof
- Suspected hail or storm damage with insurance involvement$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '12'
);

-- Part 1 / Ch 5 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$The recommendation logic for PVC parallels TPO with one important difference: PVC's longer track record affects the calculus on restoration vs replacement for older systems.

### Scenario A: 8-year-old PVC roof, one punctured area, otherwise excellent

- **Good (right call):** repair the puncture with welded patch, recommend annual maintenance.
- **Better:** *Not appropriate.* The system is in early-mid life — restoration would be premature.
- **Best:** *Not appropriate.* Replacement on a roof in this condition would damage trust.

### Scenario B: 22-year-old PVC roof on a restaurant building, light surface wear, sound seams, moderate grease exposure visible at exhaust vents, no chronic ponding

- **Good:** repair specific failures, monitor seams, annual maintenance.
- **Better (right call):** evaluate for **silicone coating restoration** — possible if the substrate qualifies. Note: PVC's plasticizer chemistry can affect coating bond; consult manufacturer on compatibility before specifying.
- **Best:** plan for replacement within 5–10 years given roof age. Present this as the long-term plan with restoration as a viable bridge.

> **[CHECK MANUFACTURER]** Coating compatibility with aged PVC is a product-specific question. Some coating systems are formulated for PVC; others are not. Confirm before proposing.

### Scenario C: 28-year-old PVC roof, widespread membrane stiffening and cracking, multiple seam failures, chronic ponding

- **Good:** *Not appropriate.* The roof is at end of life; spot repair is short-term spending.
- **Better:** *Not appropriate.* Coating over a brittle, cracking PVC substrate is a classic restoration ethics failure (Rule 5).
- **Best (right call):** full replacement. PVC track record means many of these systems are reaching end of life now in NorCal — this conversation will come up regularly.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific qualification criteria for proposing restoration on aged PVC versus full replacement.

### When to recommend PVC over TPO on a new project

This is the recurring sales question for new commercial projects. The honest framework:

**Recommend PVC when:**
- Building has chemical or grease exposure (restaurant, kitchen, industrial)
- Owner specifically values longer expected service life and is willing to pay the premium
- Project requires factory-fabricated details PVC offers more readily
- Owner has existing PVC roofs and prefers to standardize

**Recommend TPO when:**
- Cost is a primary driver
- Building has standard commercial use without chemical exposure
- Owner is satisfied with TPO's expected service range

**Both are real options for most commercial buildings.** The right answer depends on use, budget, and owner preference — not on what's most profitable for the contractor. Reps should present both honestly when both are viable.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '13'
);

-- Part 1 / Ch 5 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$PVC warranty structure parallels TPO:

- **Manufacturer (material) warranty** — covers membrane against defects.
- **Manufacturer system (NDL) warranty** — covers full system including labor, available with certified contractors and approved assemblies. NDL = No Dollar Limit (see Chapter 2 for full explanation).
- **Workmanship (contractor) warranty** — covers installation.

PVC warranties commonly run one tier longer than equivalent TPO offerings (e.g., 25-year PVC vs 20-year TPO). This length advantage is part of the premium positioning.

### What commonly voids or limits warranties
- Damage caused by other trades
- Modifications without manufacturer-approved details
- Lack of documented annual inspections
- Ponding water beyond manufacturer-allowed durations
- Chemical or grease exposure outside the warranty's stated tolerances (yes, even PVC has limits)
- Roof traffic and storage not anticipated in the warranty

### What reps must not promise
- That a longer warranty length means a longer guaranteed service life
- That PVC's grease resistance is unlimited
- That an aging PVC roof "still has full warranty coverage" without reading the document
- Specific warranty outcomes for storm or trade-caused damage

> **[COMPANY POLICY]** Placeholder — USA Flat Roof PVC manufacturer certifications, NDL warranty availability, and standard workmanship warranty terms.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '14'
);

-- Part 1 / Ch 5 / Sec 15: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "PVC is a single-ply roof membrane that's been around longer than TPO. It welds the same way TPO does and looks similar from a distance, but it's a different chemistry with different strengths. The main reason buildings specify PVC is chemical resistance — restaurants, kitchens, and industrial buildings benefit from PVC's tolerance for grease and exhaust. It also has the longest field track record of any single-ply system, which matters to owners who want a proven product."

### Talking points

1. PVC and TPO are both proven single-ply systems. The right choice depends on the building.
2. PVC's grease and chemical resistance is the technical reason it's specified for food service, kitchens, and certain industrial applications — TPO is not a good fit in those exposures.
3. PVC carries a higher price than TPO for equivalent assemblies. The premium has to make sense for the building.
4. The longest-running single-ply roofs in service today are PVC. That track record is the second reason owners choose PVC.
5. Like any flat roof, PVC's performance depends on installation quality, drainage, and how the roof is treated by other trades — not on the product alone.

### FAQ

- **Q: Is PVC better than TPO?** A: Different, not universally better. PVC has the longer track record and better chemical resistance. TPO is more cost-competitive for standard applications. The right answer depends on the building.
- **Q: Why does grease damage TPO but not PVC?** A: It's a chemistry issue. The polymers in TPO are vulnerable to certain oils and greases that PVC tolerates. For restaurants and commercial kitchens, this can be the deciding factor.
- **Q: How long will it last?** A: PVC commonly performs in the range of about 20 to 30 years in this area, with some systems exceeding that. We won't quote a specific number — we'll quote you on the work and the warranty.
- **Q: Why does PVC cost more?** A: Higher material cost, more demanding manufacturing process, and a premium positioning. For buildings where the additional service life and chemical resistance matter, the cost premium often makes sense over the building's lifecycle. For buildings without those needs, TPO is the more economical answer.
- **Q: Can I replace my old PVC with TPO?** A: Sometimes, with appropriate prep — TPO and PVC are not chemically compatible at direct contact, so an approved separation is required. We'll detail that scope honestly if you're considering it.
- **Q: Why do you offer both PVC and TPO?** A: Because the right answer for every building isn't the same. We install both, we'll inspect honestly, and we'll tell you which fits your application and budget.

### Objections & Responses

- **"PVC is too expensive."** A: Possibly, depending on the building. For a standard commercial office or retail building without chemical exposure, TPO is often the more economical answer. For a restaurant, kitchen, or grease-exposed building, PVC's chemical resistance often justifies the premium over the building's life. Let us walk through what fits your application.
- **"My contractor said PVC is outdated."** A: That's a strong claim. PVC has been continuously improved over decades and remains specified on premium new commercial construction worldwide. The longest-running single-ply roofs in service today are PVC. We're glad to walk through the comparison honestly.
- **"My contractor said TPO is just as good for half the price."** A: TPO is a strong product for the right application. For a building without chemical exposure, that comparison is reasonable. For a building with grease or chemical exposure, TPO will not perform like PVC. The right comparison depends on the building's use.
- **"I want the longest warranty I can get."** A: Warranty length and service life are related but not the same. We can discuss what the warranty actually covers, what's excluded, and what's required to keep coverage active. A long warranty on a poorly installed roof or one that doesn't qualify is worth less than a shorter warranty on a well-installed qualifying roof.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Claiming PVC "always lasts longer than TPO" regardless of application
- Recommending PVC on every commercial project to capture margin
- Claiming TPO is "just as good" on grease-exposed buildings (it isn't)
- Talking down a competitor's installation without seeing documentation
- Promising warranty outcomes without reading the actual warranty
- Certifying PVC vs TPO by appearance alone$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '15'
);

-- Part 1 / Ch 5 / Sec 16: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Repair recommendation:**
> Based on inspection, the existing PVC roof has remaining service life. Recommended scope: welded patches at [locations], pipe boot replacement at [location], drain ring resealing, and seam re-welding at [seam]. Annual maintenance recommended.

**Replacement recommendation (PVC):**
> Recommended scope: full tear-off including suspected wet insulation, deck inspection, new insulation and cover board, [thickness]-mil mechanically attached PVC, all flashings, drains, and terminations per current manufacturer details. PVC is recommended due to [grease exposure / chemical exposure / owner preference / continuity with existing system]. Workmanship warranty per USA Flat Roof terms. **[VERIFY LOCALLY]** Title 24 cool-roof and code-required scope items confirmed with jurisdiction. **[CHECK MANUFACTURER]** Confirm current PVC product, warranty tier, and detail requirements.

**PVC vs TPO comparison (for new project):**
> Two viable system options for this building: 60-mil mechanically attached TPO and [thickness]-mil mechanically attached PVC. TPO is the more economical option and appropriate for standard commercial use without chemical or grease exposure. PVC carries a premium of approximately [percentage / dollar range] but provides chemical and grease resistance and a longer field track record — appropriate for [restaurant / kitchen / industrial / specific application]. Both options carry comparable workmanship warranty terms; manufacturer warranty tiers differ. Recommendation based on building use: [TPO / PVC].$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '16'
);

-- Part 1 / Ch 5 / Sec 17: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$Same general checklist as TPO (Chapter 2, Section 20), with these additions:

- Document any chemical or grease exposure points (kitchen vents, exhaust ducts, industrial discharge)
- Note any visible product markings or stamps on the membrane
- Photograph any aged PVC stiffness, cracking, or plasticizer migration evidence
- Photograph any project documentation, original warranty papers, or manufacturer literature provided by the customer$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '17'
);

-- Part 1 / Ch 5 / Sec 18: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active interior leak with unknown source
- Suspected wet insulation
- Visible structural deflection or sagging deck
- Widespread seam failure or membrane cracking on aged PVC
- PVC vs TPO identification cannot be confirmed by documentation
- Coating compatibility question on aged PVC
- Suspected hail or storm damage with insurance involvement
- Solar array on the roof
- Code-related questions
- Customer requesting specific warranty interpretation
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '18'
);

-- Part 1 / Ch 5 / Sec 19: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred PVC product line(s) and manufacturer certifications: [placeholder]
> - Our standard membrane thickness offerings: [placeholder]
> - Our standard insulation, cover board, and attachment specifications: [placeholder]
> - Our PVC vs TPO recommendation framework: [placeholder]
> - Our restoration qualification criteria for aged PVC: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language: [placeholder]
> - Our sales-to-production handoff process for PVC projects: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '19'
);

-- Part 1 / Ch 5 / Sec 20: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They certify PVC vs TPO by appearance alone — the most common identification error in this chapter.
- They recommend PVC on every commercial project because the price is higher (margin-driven, not customer-driven).
- They claim TPO is "just as good" on grease-exposed buildings, which is incorrect.
- They confuse warranty length with service life.
- They miss plasticizer migration as a relevant aging factor on older PVC roofs.
- They underestimate coating compatibility issues on aged PVC restoration projects.

**Discussion questions for group training**
- A restaurant owner asks for a quote on a TPO replacement. The roof is 18 years old and currently PVC, with significant grease exposure at exhaust vents. How do you handle the conversation?
- A property owner wants to "just go with whatever's cheapest." The building is a commercial kitchen. What do you say?
- A customer says "PVC is outdated technology." How do you respond?
- Walk through Scenario C (28-year-old PVC at end of life). Why is honest replacement the right answer even though restoration is an easier sell?

**Field exercises**
- Pair up. Review three sets of photos from claimed-PVC and claimed-TPO roofs. Identify which features are reliable indicators and which are not.
- Walk a real PVC roof together. Have the trainee identify chemical exposure zones, age indicators, and any signs of plasticizer migration.
- Practice the PVC-vs-TPO recommendation conversation in two scenarios: a standard office building and a restaurant.

**What the manager should test verbally**
- Distinguish PVC from TPO in terms of chemistry, applications, and key differences.
- Name the three reasons a building owner might specifically choose PVC.
- Name the disqualifying conditions for restoration on aged PVC.
- State five things a rep must not promise about PVC.
- Walk through a PVC vs TPO recommendation framework for a hypothetical building.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '20'
);

-- Part 1 / Ch 5 / Sec 21: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **NDL warranty (No Dollar Limit)** — full-system manufacturer warranty without per-claim cap.
- **Plasticizer** — additive that maintains polymer flexibility; migration over decades is the primary PVC aging mechanism.
- **Plasticizer migration** — gradual loss of plasticizers from PVC over time, causing stiffening and brittleness.
- **PVC (polyvinyl chloride)** — single-ply membrane chemistry with longest field track record in commercial roofing.
- **Single-ply** — roof system using one engineered waterproofing sheet.
- **Solvent test** — production-team identification method using PVC cleaner or MEK to distinguish PVC from TPO.
- **Thermoplastic** — plastic that melts under heat and can be welded.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '21'
);

-- Part 1 / Ch 5 / Sec 22: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$PVC is the longest-running single-ply roof membrane in commercial use, positioned as a premium alternative to TPO. PVC and TPO look nearly identical and weld using the same method, but PVC's chemistry provides better resistance to grease and chemicals — which makes it the right answer for restaurants, kitchens, and certain industrial buildings. PVC also has the longest documented field track record of any single-ply system, which matters to owners who value proven longevity. PVC commonly performs in the range of about 20–30 years in NorCal. The premium price requires a reason — when a building's use justifies it, PVC is the right call; when not, TPO is more economical. Reps should not certify PVC vs TPO by appearance alone, should not claim PVC is universally superior, and should not propose restoration coatings on aged PVC without verifying compatibility. Plasticizer migration on older PVC roofs is the primary long-term aging factor, and many original-installation PVC roofs in NorCal are reaching end of life — making honest replacement conversations a regular part of the work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '22'
);

-- Part 1 / Ch 5 / Sec 23: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** What does "PVC" stand for?
A. Plasticized vinyl coating
B. Polyvinyl chloride
C. Polymer vapor compound
D. Polyethylene vinyl coating

**2. (Beginner)** PVC seams are joined by:
A. Adhesive bonding
B. Self-adhesive tape
C. Hot-air welding
D. Mechanical clamping

**3. (Beginner)** Compared to TPO, PVC is generally:
A. Lower cost
B. Higher cost with premium positioning
C. Available only in black
D. Used only on residential roofs

**4. (Intermediate)** The primary technical reason a restaurant or commercial kitchen might specify PVC over TPO is:
A. PVC is required by California building code for restaurants
B. PVC's grease and chemical resistance is significantly better than TPO's
C. PVC is more reflective than TPO
D. PVC weighs less than TPO

**5. (Intermediate)** A rep is asked to confirm whether a roof is PVC or TPO. There is no documentation available. The most appropriate response is:
A. Confirm PVC because the surface feels more flexible
B. Confirm TPO because that's more common
C. Document the visual indicators and note that product type cannot be certified without documentation
D. Defer to whatever the customer says

**6. (Intermediate)** The primary long-term aging mechanism in PVC is:
A. Granule loss
B. Plasticizer migration leading to stiffening and brittleness
C. UV-driven color change
D. Seam adhesive degradation

**7. (Intermediate)** A 28-year-old PVC roof shows widespread membrane stiffening, multiple cracked areas, and chronic ponding. The most honest recommendation is:
A. Silicone coating restoration
B. Spot repair the cracked areas
C. Full replacement
D. Acrylic coating to restore flexibility

**8. (Advanced)** A property owner with a standard commercial office building (no chemical exposure) asks whether to install PVC or TPO. The most honest framework is:
A. Always recommend PVC for the longer warranty
B. Always recommend TPO because it's more affordable
C. Recommend TPO as the more economical answer for this application; mention PVC as available if the owner specifically values the premium
D. Leave the decision entirely to the customer with no guidance

**9. (Advanced)** A restaurant owner wants the cheapest option for a roof replacement and asks for a TPO quote. The kitchen has visible grease exposure at exhaust vents. The most appropriate response is:
A. Quote TPO as requested without comment
B. Quote PVC instead without explanation
C. Explain that TPO is generally cost-effective but does not perform well in grease exposure environments, and recommend PVC despite the higher cost — with the customer making the final call
D. Decline to quote either system

**10. (Advanced)** A customer says "I want the longest warranty available — that's how I'll know it's the best roof." The most honest response includes which of the following points?
A. Warranty length is the most important factor in roof selection
B. Warranty length and actual service life are related but not the same; warranty terms, exclusions, and proper installation matter at least as much
C. Always choose the system with the longest warranty regardless of application
D. Warranty length is meaningless

---

### Answer Key

1. **B — Polyvinyl chloride.** Standard chemistry name.
2. **C — Hot-air welding.** PVC is thermoplastic, like TPO.
3. **B — Higher cost with premium positioning.** Cost is one of the defining trade-offs vs TPO.
4. **B — PVC's grease and chemical resistance is significantly better than TPO's.** This is the technical reason for restaurant and kitchen specification. Code (A) doesn't generally mandate PVC; reflectivity (C) and weight (D) are not where the difference lies.
5. **C — Document the visual indicators and note that product type cannot be certified without documentation.** Visual confirmation (A, B) is unreliable. Customer report (D) without documentation isn't certification.
6. **B — Plasticizer migration leading to stiffening and brittleness.** This is the primary long-term aging mechanism on older PVC. Granule loss (A) is a shingle issue. UV color change (C) and seam adhesive (D) are not the primary aging factor.
7. **C — Full replacement.** A roof at end of life with widespread cracking, stiffening, and ponding does not qualify for restoration coating. Spot repair (B) is short-term spending. Coating (A, D) is the textbook restoration ethics failure.
8. **C — Recommend TPO as the more economical answer for this application; mention PVC as available if the owner specifically values the premium.** This is the honest framework from Section 13. Always-PVC (A) is margin-driven; always-TPO (B) misses cases where PVC fits; no guidance (D) abandons the customer.
9. **C — Explain that TPO does not perform well in grease exposure, and recommend PVC despite the higher cost.** Quoting TPO without comment (A) sets up a failed roof. Quoting PVC without explanation (B) leaves the customer confused about the premium. Declining (D) abandons the customer.
10. **B — Warranty length and actual service life are related but not the same.** Always longest (A, C) confuses warranty length with quality. "Meaningless" (D) overstates in the opposite direction.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '23'
);

-- Part 1 / Ch 5 / Sec 24: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for the PVC products and assemblies USA Flat Roof installs?
- [ ] Matches USA Flat Roof manufacturer certifications and NDL warranty availability?
- [ ] Matches USA Flat Roof workmanship warranty language for PVC?
- [ ] Matches USA Flat Roof PVC vs TPO recommendation framework?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 2 (TPO) and Chapter 18 (Repair vs Restoration vs Replacement)?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's primary PVC manufacturer(s) and certification programs; insert specific NDL warranty terms.
- Code-dependent items: Title 24 cool-roof requirements, fire ratings.
- Regional climate assumptions: 20–30 year NorCal field range. Verify with USA Flat Roof field experience.
- Warranty-related statements.
- Company policy items: every [COMPANY POLICY] placeholder.
- Coating compatibility on aged PVC: cross-check with Chapter 3 (Silicone) when reviewing both chapters together.
- PVC vs TPO recommendation framework in Section 13: verify against USA Flat Roof's actual sales practice and pricing.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 5 AND s.section_number = '24'
);

-- Part 1 / Ch 6 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify modified bitumen roofs on sight and distinguish self-adhered from torch-down and hot-mopped variations.
2. Explain what self-adhered modified bitumen is, how it's installed, and why USA Flat Roof installs only this version.
3. Inspect a modified bitumen roof and classify common conditions on the Inspection Severity Scale.
4. Recommend repair, restoration (silicone coating), or replacement honestly based on roof condition.
5. Recognize when a modified bitumen roof condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '1'
);

-- Part 1 / Ch 6 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**Modified bitumen** (often shortened to **mod-bit**) is a multi-layer flat-roof system built around asphalt — but with engineered polymer modifiers added to improve flexibility, weather resistance, and service life compared to traditional built-up roofing.

The "bitumen" is asphalt. The "modified" part refers to two main polymer chemistries:

- **APP (atactic polypropylene)** — modifier that produces a stiffer, plastic-like membrane. Traditionally torch-applied.
- **SBS (styrene-butadiene-styrene)** — modifier that produces a more flexible, rubber-like membrane. Used in self-adhered, torch-down, and hot-mopped systems.

Modified bitumen comes in three main installation methods:

1. **Self-adhered (peel-and-stick)** — factory-applied adhesive backing, activated by removing release film and rolling the membrane into place. **This is the only method USA Flat Roof installs.**
2. **Torch-down (heat-welded)** — propane torch melts the asphalt backing as the membrane is rolled out, fusing it to the substrate.
3. **Hot-mopped** — molten asphalt applied from a kettle, with the membrane embedded into it.

USA Flat Roof installs self-adhered modified bitumen because it eliminates the open-flame fire risk of torch-down installation and avoids the kettle and fume issues of hot-mopped application. Reps will encounter all three methods in the field on existing buildings.

> **[CHECK MANUFACTURER]** Self-adhered modified bitumen is offered by multiple manufacturers with different polymer formulations, surface options, and warranty programs. Confirm current product data sheets before quoting.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '2'
);

-- Part 1 / Ch 6 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Common applications:** flat and low-slope commercial roofs, multifamily residential with flat sections, additions to existing buildings, structures where fire risk or fume restrictions disqualify torch-down or hot-mopped methods
- **Common in:** retail, light commercial, multifamily residential, occupied buildings during installation, fire-restricted environments
- **Less common on:** standard new commercial construction (where TPO has largely displaced it), high-end commercial (where single-ply systems are typically specified)

In Northern California, self-adhered modified bitumen is widely used on multifamily residential, retail buildings, and additions to existing structures — particularly where fire codes or occupancy considerations make open-flame installation impractical.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '3'
);

-- Part 1 / Ch 6 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

Modified bitumen has two surface options that affect what reps see in the field:

- **Granule-surfaced (cap sheet)** — most common. The top membrane has factory-embedded mineral granules in white, gray, tan, or black. Looks similar to a rolled shingle.
- **Smooth-surfaced** — black or gray asphalt finish. Often coated later with reflective aluminum or elastomeric coating.

**Recognition by viewpoint:**

- **Drone or roof view:** rolled appearance with visible seams every 36 inches or so (standard roll width). Granule surface, factory-uniform appearance.
- **Roof surface:** seams typically show a slight bead of asphalt squeezed out at the edge in torch-down and hot-mopped installations. Self-adhered seams are cleaner with no asphalt extrusion.
- **Edge appearance:** parapet flashings, terminations, drains.

### Distinguishing self-adhered from torch-down and hot-mopped

| Indicator | Self-adhered | Torch-down | Hot-mopped |
|---|---|---|---|
| Seam appearance | Clean, no asphalt squeeze-out | Visible asphalt bead at seams | Visible asphalt at seams; sometimes embedded into BUR-style assembly |
| Edge details | Typically cleaner | May show torch-darkening at edges | May show kettle-asphalt residue |
| Substrate evidence | Adhesive film, no scorch marks | Possible scorch marks on adjacent materials | Asphalt drips, kettle staining |

> **[SALES REP BOUNDARY]** Reps may identify the system as "appears to be self-adhered modified bitumen" or "appears to be torch-down" based on visual indicators. Definitive product and installation method should be confirmed through documentation when possible.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '4'
);

-- Part 1 / Ch 6 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Built-Up Roofing (BUR)** | BUR is multi-layer asphalt with gravel surface or smooth asphalt cap. Mod-bit is fewer layers with engineered cap sheet. (See Chapter 9.) |
| **Torch-down or hot-mopped mod-bit** | Same membrane chemistry, different installation method. Visual seam differences (above) are the most reliable indicator. |
| **TPO or PVC** | Single-ply membranes are smooth and welded. Mod-bit is granular or smooth-asphalt and uses different seam methods. |
| **Rolled asphalt roofing (residential)** | A consumer-grade product used on sheds, garages, and budget applications. Thinner, less durable, no polymer modification. |
| **Coated roof over old mod-bit** | A coating applied over aged mod-bit shows brush/spray texture and continuous wrap over details. The mod-bit substrate may still be visible at edges. |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '5'
);

-- Part 1 / Ch 6 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A self-adhered modified bitumen system is layered. From the structure up:

1. **Roof deck** — wood, concrete, or metal. Self-adhered systems typically require a solid substrate without significant gaps.
2. **Vapor retarder** *(in some assemblies)* — limits moisture migration into the assembly.
3. **Insulation** — typically polyiso rigid foam, mechanically attached or adhered.
4. **Cover board** — provides a smooth, sound substrate for the self-adhered membrane.
5. **Base sheet** — the first layer of self-adhered membrane installed over the cover board.
6. **Cap sheet** — the second (top) layer of self-adhered membrane. The cap sheet has the granule surface or smooth finish that becomes the visible roof surface.
7. **Seams** — overlaps between rolls, factory-adhesive bonded, often supplemented with primer and roller pressure during installation.
8. **Flashings** — modified bitumen flashings at parapet walls, curbs, drains, and penetrations. Sometimes combined with metal flashings.
9. **Termination details** — termination bars, counter-flashing, sealant, metal coping.
10. **Drains and scuppers** — drainage components.

> **[CHECK MANUFACTURER]** Number of plies (one-ply vs two-ply systems), base sheet vs cap sheet specifications, primer requirements, and accessory compatibility vary by manufacturer.

[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a two-ply self-adhered modified bitumen assembly showing deck, insulation, cover board, base sheet, cap sheet, and parapet termination.
Purpose: Help reps visualize the layered system.
Caption: Cross-section of a typical two-ply self-adhered modified bitumen assembly. Components shown are conceptual; actual installations vary.
Alt text: Diagram of a modified bitumen roof assembly showing deck, insulation, cover board, base sheet, cap sheet, and flashing.
Annotation needed: Yes — label all components.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '6'
);

-- Part 1 / Ch 6 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$A typical self-adhered installation follows this general sequence. This overview is for awareness only — not an installation specification.

1. **Preparation** — existing roof removed (if a tear-off) or prepared (if a recover). Deck inspected and repaired.
2. **Vapor retarder** *(if specified)* — installed over the deck.
3. **Insulation** — polyiso boards laid in courses, mechanically fastened or adhered per design.
4. **Cover board** — installed over insulation. **Critical** for self-adhered systems — adhesion depends on a smooth, sound substrate.
5. **Primer application** *(where required)* — manufacturer-specified primer applied to the cover board to promote adhesion.
6. **Base sheet** — first ply rolled out, release film removed, membrane pressed to the substrate with a roller.
7. **Cap sheet** — second ply rolled out with offset seams from the base sheet, release film removed, pressure-rolled to bond.
8. **Seams** — manufacturer-specified roller pressure applied to seams to ensure bond.
9. **Flashings** — wall flashings, curb flashings, drain flashings, and pipe boots installed with appropriate primer and bonding.
10. **Terminations** — termination bars, sealant, counter-flashing, and metal coping installed.
11. **Final inspection** — adhesion check, seam pressure verification, detail review.

> **[CHECK MANUFACTURER]** Application temperature minimums, primer requirements, roller pressure standards, and seam treatment vary by product. Self-adhered systems are sensitive to substrate temperature — installation in cold weather requires specific procedures.

> **[VERIFY LOCALLY]** California Title 24 cool-roof requirements affect granule surface color and reflectivity for many commercial occupancies.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '7'
);

-- Part 1 / Ch 6 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$- **Industry rating range:** Manufacturer warranties commonly run 10, 15, or 20 years depending on system, plies, and contractor program participation.
- **Real-world field range (two-ply self-adhered, NorCal):** roughly **15–25 years** with reasonable maintenance. One-ply systems typically fall toward the lower end; two-ply systems and premium products toward the upper end.
- **Factors that shorten lifespan:** chronic ponding, foot traffic without protection, mechanical damage, seam delamination from poor original installation, extreme heat exposure, deferred maintenance.
- **Factors that extend lifespan:** good drainage, walk pads at high-traffic areas, regular inspections, prompt repair of seam issues and details, periodic coating with reflective or restoration products.

> **[VERIFY LOCALLY]** NorCal climate variation matters: inland heat exposure shortens life; coastal moderation may extend it. Confirm with field experience.

### What reps must NOT promise
- Specific service-life numbers
- Outcomes contingent on customer maintenance behavior
- Warranty payouts on aging systems
- That coating restoration will reset the roof's clock

### Suggested customer language
> "Two-ply self-adhered modified bitumen commonly performs in the range of about 15 to 25 years in this area, depending on drainage, maintenance, and roof traffic. Based on what we're seeing on your roof today, here's what we'd expect…"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '8'
);

-- Part 1 / Ch 6 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **No open flame during installation** — the primary practical advantage of self-adhered systems. Eliminates the fire risk of torch-down installation, which matters for occupied buildings, fire-restricted environments, and insurance considerations.
- **No kettle, no fumes** — avoids the disruption and air-quality issues of hot-mopped application.
- **Proven asphalt-based chemistry** — modified bitumen has decades of field track record.
- **Multi-ply redundancy** — two-ply systems provide a backup waterproofing layer if the cap sheet is damaged.
- **Repairable** — patches can be applied with primer and roller pressure, or with compatible flashing cement.
- **Coatable** — qualifies for silicone restoration coating when the substrate is sound (see Chapter 3).$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '9'
);

-- Part 1 / Ch 6 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Heavier than single-ply** — affects structural calculations on certain buildings.
- **Substrate-sensitive during installation** — requires a smooth, clean, dry, primed surface. Adhesion failures from poor prep are the most common installation defect.
- **Temperature-sensitive during installation** — cold weather application requires specific procedures and may not be possible at all temperatures.
- **Asphalt-based** — vulnerable to certain chemicals, solvents, and oils that don't affect single-ply membranes the same way.
- **Granule loss over time** — exposes the asphalt to UV, accelerating aging in late life (similar to composition shingle).
- **Heavier installation labor** than rolling out single-ply membrane; project duration can be longer for equivalent square footage.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '10'
);

-- Part 1 / Ch 6 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Light surface granule loss | Monitor → Maintenance | Slight thinning of granule cover |
| Significant granule loss with exposed asphalt | Repair | Black asphalt visible across large areas |
| Seam separation / lifting | Repair → Urgent | Edges no longer bonded; gap visible |
| Blistering | Repair | Raised bubbles on the membrane surface |
| Punctures and tears | Repair → Urgent | Holes from tools, debris, or foot traffic |
| Failed pipe boot or detail flashing | Repair | Cracked or separated flashing |
| Failed parapet flashing | Repair → Urgent | Wall flashing pulled, separated, or unsealed |
| Drain failure | Repair → Urgent | Clogged or damaged drain; standing water |
| Chronic ponding | Maintenance → Repair | Persistent water, dirt rings, accelerated wear |
| Membrane shrinkage at perimeter | Repair → Urgent | Flashings pulling tight, exposed terminations |
| Adhesion failure (early-life) | Repair → Urgent | Membrane releasing in sheets; usually traces to prep failure |
| UV degradation on smooth-surfaced systems | Repair | Cracking, alligatoring (network of cracks), surface deterioration |
| Active interior leak | Urgent | Water staining inside the building |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not diagnose root cause of seam failures or adhesion problems without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '11'
);

-- Part 1 / Ch 6 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$Modified bitumen inspection follows the same general process as TPO inspection (see Chapter 2, Section 12). Key differences:

**Modified bitumen specifics:**
- Note the membrane finish: granule-surfaced or smooth/coated
- If smooth-surfaced, note any prior coating (aluminum, acrylic, silicone) and its condition
- Check granule coverage on cap sheet — significant loss with exposed asphalt is an aging indicator
- Inspect every seam — both lateral overlaps and end laps. Seams are the most common failure point
- Look for blistering — often indicates moisture entrapment under the membrane

**Substrate and assembly indicators:**
- Walk-test for soft underfoot — wet insulation under modified bitumen is a common late-life issue
- Check parapet wall conditions — water tracking down parapets often originates at failed wall flashings
- Note any sign of prior repairs (asphalt cement patches, flashing tape additions)

**Red flags requiring immediate escalation**
- Active interior leak with unknown source
- Soft / spongy underfoot — suspected wet insulation
- Visible structural deflection or sagging deck
- Widespread seam failure or blistering
- Suspected hail or storm damage with insurance involvement
- Solar array on the roof
- Aged mod-bit with widespread granule loss and exposed asphalt — likely end of life$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '12'
);

-- Part 1 / Ch 6 / Sec 13: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$### Scenario A: 6-year-old self-adhered mod-bit roof, two failed pipe boots, otherwise excellent

- **Good (right call):** repair the two pipe boots, recommend annual maintenance.
- **Better:** *Not appropriate.* The system is in early life — restoration premature.
- **Best:** *Not appropriate.* Replacement on a young roof in good condition would damage trust.

### Scenario B: 17-year-old two-ply mod-bit roof, light surface wear, intact seams, two areas of light ponding, granule coverage still adequate

- **Good:** repair detail failures, recommend maintenance.
- **Better (right call):** silicone coating restoration if the roof qualifies — sound substrate, intact seams, addressable ponding, no wet insulation. Coating is well-suited to mod-bit substrates when prep is correct.
- **Best:** plan for replacement in 5–10 years if conditions worsen or budget allows.

### Scenario C: 25-year-old smooth-surfaced mod-bit roof, widespread alligatoring, multiple seam failures, soft underfoot in two areas, chronic ponding

- **Good:** *Not appropriate.* End-of-life roof; spot repair is short-term spending.
- **Better:** *Not appropriate.* Coating over wet insulation, failing seams, and structural ponding is the textbook restoration ethics failure (Rule 5).
- **Best (right call):** full replacement with insulation evaluation. Many original-installation mod-bit roofs in NorCal commercial are reaching end of life now — this conversation will come up regularly.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's qualification criteria for proposing restoration on aged modified bitumen versus full replacement.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '13'
);

-- Part 1 / Ch 6 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$Modified bitumen warranty structure:

- **Manufacturer (material) warranty** — covers the membrane against defects. Length varies by product and number of plies.
- **Manufacturer system warranty** — covers the assembly when installed by certified contractors with approved details.
- **Workmanship (contractor) warranty** — covers installation quality. Issued by the contractor.

### What commonly voids or limits warranties
- Improper installation (often voids manufacturer warranty)
- Inadequate substrate prep
- Application during inappropriate weather conditions
- Damage caused by other trades not properly addressed
- Modifications or additions without manufacturer-approved details
- Lack of documented annual inspections (for some warranty tiers)
- Ponding water beyond manufacturer-allowed durations

### What reps must not promise
- That an aging roof "still has full warranty coverage" without reading the document
- That manufacturer warranty covers the substrate or system components beyond the membrane
- Specific outcomes for damage caused by other trades or weather events
- That a workmanship warranty transfers automatically at sale

> **[COMPANY POLICY]** Placeholder — USA Flat Roof manufacturer certifications, warranty tier offerings, and standard workmanship terms for modified bitumen.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '14'
);

-- Part 1 / Ch 6 / Sec 15: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "Modified bitumen is essentially an engineered, polymer-modified asphalt roof — proven chemistry with a long field track record. The version we install is self-adhered, which means no torches and no kettles during installation. That matters for occupied buildings, fire-sensitive environments, and any project where you don't want open flame on your roof. The system is installed in two plies — a base sheet and a cap sheet — bonded together for redundancy."

### Talking points

1. We install only self-adhered modified bitumen — no torch-down, no hot-mopped. The reason is fire safety and occupant impact.
2. Modified bitumen has decades of field track record. It's not new technology; it's proven technology.
3. Two-ply systems provide redundancy — if the cap sheet is damaged, the base sheet still provides waterproofing.
4. Modified bitumen is a strong candidate for silicone restoration coating later in life — a real cost-saving option when the substrate qualifies.
5. The system is heavier than single-ply, which sometimes affects building structural calculations. We'll flag that if it applies.

### FAQ

- **Q: Why don't you do torch-down?** A: Open-flame installation creates real fire risk. We made the call to specialize in self-adhered to eliminate that risk for our customers and our crews. Self-adhered also doesn't disrupt occupied buildings the way torch-down does.
- **Q: Is self-adhered as good as torch-down?** A: Performance is comparable when both are installed correctly on appropriate substrates. The main differences are installation method and cold-weather application limits — not long-term performance.
- **Q: How long will it last?** A: Two-ply self-adhered modified bitumen commonly performs in the range of about 15 to 25 years in this area. We won't quote a specific number — we'll quote you on the work.
- **Q: Is mod-bit better than TPO?** A: Different, not better or worse universally. Mod-bit has multi-ply redundancy and decades of asphalt-based track record. TPO is lighter, faster to install, and often more cost-competitive. The right answer depends on the building.
- **Q: Can I coat my old mod-bit roof?** A: Possibly, if the substrate qualifies. Modified bitumen is generally a good coating substrate when the membrane is sound and there's no chronic ponding or wet insulation. We'll inspect and tell you honestly if your roof qualifies.
- **Q: What's the warranty?** A: Depends on the product and the warranty tier. We'll review options with you and pick the tier that matches the project.

### Objections & Responses

- **"Another contractor said torch-down lasts longer."** A: Both methods produce comparable long-term performance when installed correctly. Torch-down installation adds open-flame fire risk during construction — that's why we don't do it. The roof itself, once installed, performs based on the membrane and the details, not the heat method used to apply it.
- **"You're more expensive than the TPO quote."** A: Different systems with different attributes. Modified bitumen is heavier, has multi-ply redundancy, and is asphalt-based. TPO is single-ply, lighter, and often cost-competitive. Both are real options. Let us walk through what fits your building.
- **"My building has a flat roof — why can't you just torch this on?"** A: We don't do torch-down installation. The fire risk doesn't fit how we operate. We'll either install self-adhered mod-bit, or — if torch-down is the right answer for your project — we'll be straight with you and let you know we're not the right fit.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Claiming self-adhered is "always better" than torch-down (it's not — they're different methods with similar long-term performance)
- Recommending coating over a mod-bit roof without verifying substrate qualification
- Promising warranty outcomes without reading the actual warranty
- Talking down a competitor's torch-down installation without knowing the application
- Identifying mod-bit installation method (self-adhered vs torch-down) by appearance alone without documentation$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '15'
);

-- Part 1 / Ch 6 / Sec 16: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Repair recommendation:**
> Based on inspection, the existing modified bitumen roof has remaining service life. Recommended scope: pipe boot replacement at [location], seam repair at [location], drain ring resealing, and flashing repair at [location]. Annual maintenance recommended.

**Restoration recommendation (silicone coating):**
> The modified bitumen membrane has aged but the substrate qualifies for silicone restoration: sound seams, no chronic ponding, addressable detail conditions, and no evidence of wet insulation. Recommended scope: full clean and prep, detail repair at [locations], reinforcement at seams, and silicone coating application per manufacturer specification. Restoration is intended to extend service life. **[CHECK MANUFACTURER]** Confirm coating compatibility, mil thickness, and warranty terms.

**Replacement recommendation:**
> Based on inspection findings, the existing roof has reached the end of its useful service life. Recommended scope: full tear-off including suspected wet insulation, deck inspection, new insulation and cover board, two-ply self-adhered modified bitumen, all flashings, drains, and terminations per current manufacturer details. Workmanship warranty per USA Flat Roof terms. **[VERIFY LOCALLY]** Title 24 cool-roof and code-required scope items confirmed with jurisdiction. **[CHECK MANUFACTURER]** Confirm current product, warranty tier, and installation requirements.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '16'
);

-- Part 1 / Ch 6 / Sec 17: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$Same general checklist as TPO (Chapter 2, Section 20), with these additions:

- Document membrane surface type (granule-surfaced or smooth)
- Photograph any prior coating and its condition
- Photograph any blistering, alligatoring, or granule-loss patterns
- Photograph any sign of prior torch-down or hot-mopped installation if encountered (for context — even though USA Flat Roof doesn't install these methods, identifying them on existing roofs matters)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '17'
);

-- Part 1 / Ch 6 / Sec 18: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active interior leak with unknown source
- Suspected wet insulation
- Visible structural deflection or sagging deck
- Widespread seam failure, blistering, or alligatoring
- Existing roof installed with torch-down or hot-mopped methods and customer requests like-for-like replacement
- Coating compatibility question on aged mod-bit
- Suspected hail or storm damage with insurance involvement
- Solar array on the roof
- Code-related questions
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '18'
);

-- Part 1 / Ch 6 / Sec 19: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred self-adhered modified bitumen product line(s) and certifications: [placeholder]
> - Our standard ply configuration (one-ply vs two-ply standards): [placeholder]
> - Our standard insulation, cover board, and primer specifications: [placeholder]
> - Our position on torch-down and hot-mopped customer requests: [placeholder]
> - Our restoration qualification criteria for aged mod-bit: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language: [placeholder]
> - Our cold-weather installation limits and procedures: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '19'
);

-- Part 1 / Ch 6 / Sec 20: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They confuse modified bitumen with built-up roofing (BUR) — they're related but not the same.
- They certify installation method (self-adhered vs torch-down vs hot-mopped) by appearance alone.
- They claim self-adhered is universally superior to torch-down, when the difference is primarily installation safety and occupant impact.
- They miss blistering as a moisture-entrapment indicator.
- They underestimate substrate prep importance for self-adhered systems.
- They confuse warranty length with service life.

**Discussion questions for group training**
- A property owner asks for a torch-down replacement of their existing torch-down roof. How do you handle the conversation honestly?
- A 25-year-old mod-bit roof is showing widespread alligatoring and the customer wants to coat it. What do you say?
- Why does USA Flat Roof install only self-adhered mod-bit? Explain in plain customer language.

**Field exercises**
- Pair up. Review three sets of photos of mod-bit roofs in different conditions. Identify granule-surfaced vs smooth, identify likely installation method, and apply severity ratings.
- Walk a real mod-bit roof together. Have the trainee identify membrane surface type, ply count if visible at edges, and any signs of prior coating.

**What the manager should test verbally**
- Distinguish modified bitumen from BUR and from single-ply membranes.
- Name the three installation methods and explain why USA Flat Roof installs only self-adhered.
- Walk through a Good/Better/Best presentation for a 17-year-old two-ply mod-bit roof.
- State five things a rep must not promise about modified bitumen.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '20'
);

-- Part 1 / Ch 6 / Sec 21: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Alligatoring** — network of cracks resembling alligator skin, common in aged smooth-surfaced asphalt-based systems.
- **APP (atactic polypropylene)** — polymer modifier producing stiffer, plastic-like membrane behavior.
- **Base sheet** — first ply of a multi-ply modified bitumen system.
- **Bitumen** — asphalt-based waterproofing material.
- **Cap sheet** — top ply of a modified bitumen system, providing the visible surface.
- **Granule-surfaced** — membrane with factory-embedded mineral granules on the visible surface.
- **Hot-mopped** — installation method using molten asphalt from a kettle.
- **Modified bitumen (mod-bit)** — asphalt-based roofing membrane with engineered polymer modifiers.
- **Ply** — one layer of a multi-layer roof assembly.
- **SBS (styrene-butadiene-styrene)** — polymer modifier producing more flexible, rubber-like membrane behavior.
- **Self-adhered** — installation method using factory-applied adhesive backing.
- **Smooth-surfaced** — membrane finish without granules; typically intended for later coating application.
- **Torch-down** — installation method using propane torch to heat-fuse membrane to substrate.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '21'
);

-- Part 1 / Ch 6 / Sec 22: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Modified bitumen is an engineered, polymer-modified asphalt roof system used widely on flat and low-slope commercial buildings. USA Flat Roof installs only self-adhered (peel-and-stick) modified bitumen — no torch-down or hot-mopped — because self-adhered eliminates the open-flame fire risk and the kettle-fume disruption of the other methods. Two-ply systems are common and provide redundancy. Real-world service life commonly falls in the range of 15–25 years in NorCal. Modified bitumen is a strong candidate for silicone restoration coating later in life when the substrate qualifies. Reps should not certify installation method by appearance alone, should not claim self-adhered is universally superior to torch-down (the long-term performance is comparable when both are installed correctly), and should not propose coating restoration without verifying substrate qualification. Many original-installation mod-bit roofs in NorCal commercial are reaching end of life now, making honest replacement conversations a regular part of the work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '22'
);

-- Part 1 / Ch 6 / Sec 23: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** "Bitumen" refers to:
A. A specific polymer modifier
B. Asphalt-based waterproofing material
C. A type of insulation
D. A surface coating chemistry

**2. (Beginner)** USA Flat Roof installs which type of modified bitumen?
A. Torch-down only
B. Hot-mopped only
C. Self-adhered (peel-and-stick) only
D. All three methods

**3. (Beginner)** The primary practical advantage of self-adhered installation over torch-down is:
A. Significantly longer service life
B. Lower material cost
C. No open flame during installation, eliminating fire risk
D. Faster cure time

**4. (Beginner)** A "cap sheet" in a modified bitumen system is:
A. The base layer installed first
B. The top membrane that becomes the visible roof surface
C. A metal flashing component
D. A drainage accessory

**5. (Intermediate)** Two-ply self-adhered modified bitumen commonly performs in the field for:
A. About 5 to 10 years
B. About 15 to 25 years, depending on conditions
C. Exactly 30 years per warranty
D. Over 50 years guaranteed

**6. (Intermediate)** "Blistering" on a modified bitumen roof typically indicates:
A. Normal aging that requires no action
B. A manufacturer defect requiring full warranty replacement
C. Moisture entrapment under the membrane
D. UV damage to the granules

**7. (Intermediate)** A 17-year-old two-ply mod-bit roof has light surface wear, intact seams, light ponding in two spots, and adequate granule coverage. The most appropriate recommendation is:
A. Full replacement immediately
B. Spot repair only and continue monitoring
C. Silicone coating restoration if the substrate qualifies, with a longer-term replacement plan
D. Decline to inspect further

**8. (Intermediate)** A customer says torch-down lasts longer than self-adhered. The most accurate response is:
A. Confirm that torch-down lasts significantly longer
B. Explain that performance is comparable when both are installed correctly; the main differences are installation method, fire risk, and occupant impact
C. Tell the customer self-adhered is universally superior
D. Decline to comment on torch-down

**9. (Advanced)** A 25-year-old smooth-surfaced mod-bit roof shows widespread alligatoring, soft underfoot in two areas, and chronic ponding. The customer wants to coat the roof to save money. The most appropriate response is:
A. Apply the coating as requested
B. Apply a higher-tier coating product
C. Decline to propose coating, explain the disqualifying conditions, and recommend replacement
D. Refer the customer elsewhere

**10. (Advanced)** A property owner asks USA Flat Roof to torch-down a replacement modified bitumen roof. The most appropriate response is:
A. Quote the project as torch-down to capture the work
B. Explain that USA Flat Roof installs only self-adhered modified bitumen, the reasoning behind that choice, and offer to quote self-adhered as an alternative
C. Decline the project without explanation
D. Propose silicone coating instead

---

### Answer Key

1. **B — Asphalt-based waterproofing material.** Polymer modifiers (A) modify the bitumen but aren't the bitumen itself.
2. **C — Self-adhered (peel-and-stick) only.** Specific to USA Flat Roof's offerings.
3. **C — No open flame during installation, eliminating fire risk.** This is the central reason for the self-adhered choice. Service life (A) is comparable across methods. Cost (B) and cure time (D) are not the main drivers.
4. **B — The top membrane that becomes the visible roof surface.** Base sheet (A) is the first layer; cap sheet is the top.
5. **B — About 15 to 25 years, depending on conditions.** Specific guarantees (C, D) violate the no-fake-precision rule.
6. **C — Moisture entrapment under the membrane.** Blistering is a moisture indicator. Normal aging (A) understates it; manufacturer defect (B) overstates the cause; UV (D) affects granules but doesn't cause blistering.
7. **C — Silicone coating restoration if the substrate qualifies, with a longer-term replacement plan.** This matches Scenario B in Section 13. Immediate replacement (A) is premature; spot repair only (B) ignores the broader aging picture; declining (D) abandons the customer.
8. **B — Performance is comparable when both are installed correctly.** This is the honest framework. Confirming torch-down's superiority (A) overstates; calling self-adhered universally superior (C) overstates in the opposite direction.
9. **C — Decline to propose coating, explain the disqualifying conditions, and recommend replacement.** This is the honesty-versus-easy moment from Scenario C. Coating over wet insulation and chronic ponding is the textbook ethics failure.
10. **B — Explain that USA Flat Roof installs only self-adhered, the reasoning, and offer self-adhered as an alternative.** This is honest positioning. Quoting torch-down anyway (A) violates the company's installation policy. Declining without explanation (C) loses the relationship without educating. Coating (D) is unrelated to the request.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '23'
);

-- Part 1 / Ch 6 / Sec 24: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for the self-adhered products and assemblies USA Flat Roof installs?
- [ ] Matches USA Flat Roof manufacturer certifications and warranty tier offerings?
- [ ] Matches USA Flat Roof workmanship warranty language?
- [ ] Matches USA Flat Roof position on torch-down customer requests?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 3 (Silicone) and Chapter 18 (Repair vs Restoration vs Replacement)?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's primary self-adhered modified bitumen manufacturer(s) and certification programs.
- Code-dependent items: Title 24 cool-roof requirements, fire ratings, structural load.
- Regional climate assumptions: 15–25 year NorCal field range. Verify with USA Flat Roof field experience.
- Warranty-related statements.
- Company policy items: every [COMPANY POLICY] placeholder.
- Coating compatibility on aged mod-bit: cross-check with Chapter 3 (Silicone).
- Cold-weather installation procedures: verify USA Flat Roof's standard practices match manufacturer requirements.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 6 AND s.section_number = '24'
);

-- Part 1 / Ch 7 / Sec 1: Recognition + Ground-Level Clues
UPDATE sections SET
  content_markdown = $mfst$**Acrylic roof coatings** are water-based, liquid-applied reflective coatings used on flat and low-slope commercial roofs. Like silicone, acrylics are part of the **roof restoration** category — work intended to extend the service life of an existing roof with a sound substrate. They are applied by spray, roller, or brush and cure by water evaporation rather than by reaction with atmospheric moisture (the silicone curing mechanism).

USA Flat Roof leads with silicone for restoration work and does not typically propose acrylic coatings. This chapter exists so reps can:

- Recognize acrylic coatings on existing roofs during inspection
- Answer customer questions about acrylic versus silicone honestly
- Identify when an existing acrylic coating affects future restoration options

### Visual identification

Acrylic coatings look very similar to silicone coatings at first glance:

- Smooth, painted-looking white surface (most common color; gray and tan available)
- Brush, roller, or spray texture visible up close
- Continuous wrap over flashings, parapets, and most penetrations
- Often shows overspray on adjacent surfaces

### How to distinguish acrylic from silicone

Honestly — visual distinction is unreliable. Both products produce similar appearance after cure. Reliable identification methods:

- **Customer documentation** — receipts, warranty papers, original spec
- **Performance pattern** — acrylic tends to show wear sooner in ponded areas than silicone
- **Recoat history** — if the roof has been recoated multiple times in shorter cycles, it's more likely acrylic
- **Touch test (limited reliability)** — silicone has a slightly slick, rubbery feel when cured; acrylic feels more like cured paint. Not definitive.

> **[SALES REP BOUNDARY]** Reps may identify a roof as "appears coated" and note features that suggest one chemistry or another. Definitive identification of coating chemistry requires documentation or laboratory testing — not visual inspection.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 7 AND s.section_number = '1'
);

-- Part 1 / Ch 7 / Sec 2: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$This is the non-negotiable section for a Reference chapter. Reps must not misidentify these systems.

| Confused with | Key difference |
|---|---|
| **Silicone coating** | Visually similar after cure. Performance differs in ponding water (silicone tolerates better) and recoatability (acrylic recoats more flexibly). Documentation is the reliable answer. |
| **Elastomeric paint or "roof paint"** | Generic hardware-store roof paints are typically thinner, less engineered, and not part of a manufacturer-warranted restoration system. Often confused with engineered acrylic coatings. |
| **TPO or PVC membrane** | Single-ply membranes show factory-uniform finish and welded seams. Coatings show application texture and continuous wrap over details. |
| **Aluminum-pigmented asphalt coating** | Metallic silver appearance, not white. Different chemistry; far shorter service life. Common older approach on modified bitumen and BUR. |
| **Spray polyurethane foam (SPF) with acrylic topcoat** | SPF has textured, slightly orange-peel surface visible through any topcoat. The substrate is what matters here — see Chapter 10 (SPF). |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 7 AND s.section_number = '2'
);

-- Part 1 / Ch 7 / Sec 3: Common Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Light surface dirt and biological staining | Monitor → Maintenance | Surface darkening; common on coatings with longer dirt-pickup tendency |
| Chalking | Maintenance | Powdery white residue from UV degradation |
| Coating wear in ponded areas | Repair → Urgent | Visible degradation, blistering, or release where water sits |
| Coating delamination | Repair → Urgent | Peeling or lifting from substrate |
| Coating cracking | Repair | Visible cracks in the cured coating |
| Substrate failure visible through coating | Urgent | Coating intact but underlying membrane has failed |
| Coating applied over wet substrate (early-life failure) | Urgent | Bubbling, releasing in sheets, often within first 1–2 years |
| Coating applied over a non-qualifying substrate | Repair → Urgent | Widespread early failure regardless of product quality |

The two failure modes most commonly seen on acrylic specifically are **ponded-area degradation** and **dirt pickup over time**. Acrylics tolerate ponding less well than silicone — this is one of the practical reasons silicone is often preferred for NorCal commercial roofs with imperfect drainage.

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify which coating chemistry was applied, do not diagnose root cause of coating failures, and do not propose recoating without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 7 AND s.section_number = '3'
);

-- Part 1 / Ch 7 / Sec 4: Sales Cautions / What Not to Promise
UPDATE sections SET
  content_markdown = $mfst$When a customer brings up acrylic coatings — typically because they got a competing quote or read about them online — reps need to handle the conversation honestly rather than dismissively.

### Honest framing for the silicone-vs-acrylic conversation

Both silicone and acrylic are real, engineered restoration products. Both have manufacturer warranties available. Both work when applied to qualifying substrates with proper prep. They have different strengths:

- **Silicone:** better ponding-water tolerance, longer field service life on most substrates, holds up to UV very well over time. Difficult to recoat with non-silicone products in the future.
- **Acrylic:** lower cost typically, easier to recoat with other chemistries in the future, generally good UV resistance. Less tolerant of ponding water; more dirt pickup over time.

USA Flat Roof's preference for silicone is a practical choice for the kind of NorCal commercial roofs we typically restore — flat or low-slope buildings where some ponding is realistic and where long-term performance matters more than recoat flexibility. Other contractors may legitimately prefer acrylic for different reasons.

### What reps must NOT do

- **Bash acrylic as inferior.** It isn't, when used in the right application. Bashing it makes the rep look biased.
- **Claim silicone is universally superior.** It isn't — there are real applications where acrylic is the more appropriate choice.
- **Identify a coating's chemistry by appearance and use that identification to argue for replacement.** Reps cannot reliably tell silicone from acrylic visually.
- **Promise that an existing acrylic-coated roof can be recoated with silicone without compatibility verification.** Silicone bond to aged acrylic varies by product and prep.
- **Propose silicone over an existing acrylic coating without escalating** for substrate compatibility review.

### What reps CAN do

- Identify that the roof appears coated
- Document the coating's condition using the severity scale
- Ask the customer for documentation of the coating chemistry, application date, and warranty status
- Explain the practical differences between silicone and acrylic when the customer asks
- Present USA Flat Roof's restoration approach honestly and let the customer make the choice
- Escalate any recoat or restoration question on a previously coated roof

> **[CHECK MANUFACTURER]** Compatibility between silicone restoration coatings and existing acrylic substrates is a product-specific question. Some silicone systems are formulated for application over acrylic; others are not. Confirm before proposing.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 7 AND s.section_number = '4'
);

-- Part 1 / Ch 7 / Sec 5: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Customer requests a recoat on an existing acrylic-coated roof
- Customer specifically asks for an acrylic coating proposal
- Existing coating chemistry cannot be confirmed by documentation
- Existing coating shows widespread delamination, blistering, or substrate failure
- Customer compares acrylic and silicone proposals and asks USA Flat Roof to evaluate the other contractor's scope
- Coating applied over a substrate that did not qualify (visible substrate failure under intact coating)
- Any condition exceeding the rep's training or authorization

---

## Brief Chapter Summary

Acrylic roof coatings are water-based liquid-applied reflective coatings used in roof restoration — same general category as silicone, different chemistry. USA Flat Roof leads with silicone for restoration and does not typically propose acrylic coatings, primarily because silicone tolerates ponding water better and tends to perform longer on the kinds of NorCal commercial roofs we work on. Acrylic is not inferior — it has real strengths, particularly recoat flexibility and lower cost — but it's not how USA Flat Roof leads. Reps should recognize acrylic on existing roofs, handle silicone-vs-acrylic conversations honestly without bashing acrylic, and escalate any restoration or recoat question on previously coated roofs.

---

## [INSTRUCTOR ONLY] Notes

**What new reps usually misunderstand**
- They claim acrylic is "cheap" or "inferior" — this is dismissive and inaccurate.
- They try to identify coating chemistry visually, which is not reliable.
- They propose silicone over existing acrylic without verifying compatibility.

**What the manager should test verbally**
- Why USA Flat Roof leads with silicone for restoration.
- The honest version of the silicone-vs-acrylic conversation.
- Why coating chemistry identification requires documentation, not appearance.
- What to escalate.

**Discussion question:** A customer says "another contractor quoted us acrylic for half your silicone price." How does the rep handle this without bashing the competitor and without overpromising silicone?

[/INSTRUCTOR ONLY]

---

## Manager Review Checklist + Verification Notes

- [ ] Accurate for USA Flat Roof's actual position on acrylic coatings?
- [ ] Does the silicone-vs-acrylic framing match how we want reps to handle competing quotes?
- [ ] Is the escalation guidance correct?

**Verification items:** Compatibility statements between silicone and existing acrylic substrates flagged [CHECK MANUFACTURER]. USA Flat Roof's position on whether to ever propose acrylic should be confirmed and reflected here.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 7 AND s.section_number = '5'
);

-- Part 1 / Ch 8 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify concrete tile roofs on sight and distinguish them from clay tile and composite look-alikes.
2. Explain the components of a concrete tile system in plain language, with emphasis on the underlayment as the actual waterproofing layer.
3. Inspect a concrete tile roof and classify common conditions on the Inspection Severity Scale.
4. Propose repair and maintenance work honestly within USA Flat Roof's scope.
5. Recognize when a concrete tile roof condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '1'
);

-- Part 1 / Ch 8 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$A **concrete tile roof** is a steep-slope roof covered with individual tiles cast from concrete (Portland cement, sand, water, and pigments). The tiles are laid in overlapping courses similar to shingles, but with a critical difference reps must understand:

**On a tile roof, the tiles are not the waterproofing layer.** The tiles shed bulk water, but the actual waterproof barrier is the **underlayment** beneath them. When a tile roof leaks, the underlayment has almost always failed — not the tiles themselves.

This single fact drives most of how reps inspect and discuss tile roofs. A roof can have tiles in apparently fine condition while the underlayment underneath has reached end of life. A roof can have several broken tiles and still be perfectly watertight if the underlayment is sound.

Concrete tile is widely used on Northern California residential — particularly on tract homes built from the 1980s onward, where it became a common alternative to clay tile and composition shingle. Reps will encounter concrete tile constantly on inspection calls.

USA Flat Roof's scope on concrete tile is **repair and maintenance**, not replacement. Full tile roof replacement is specialty work that USA Flat Roof refers out. Within the repair-and-maintenance scope, reps need to inspect competently, identify what's actually wrong, and propose appropriate work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '2'
);

-- Part 1 / Ch 8 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Common on:** single-family residential (especially tract homes built 1980s–2010s), townhomes, Mediterranean and Spanish-influenced architecture, custom homes specifying tile aesthetic
- **Less common on:** commercial buildings, structures with low slope (tile requires steep slope to shed water), older historic homes (which usually have original clay tile)

In Northern California, concrete tile is widespread across the Bay Area, Sacramento Valley, San Jose, and the East Bay. Many homes from the late 1980s through the 2000s have original concrete tile roofs that are now reaching the age where the underlayment underneath needs attention.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '3'
);

-- Part 1 / Ch 8 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

- Individual rectangular or curved tile pieces in overlapping courses
- Heavy, substantial appearance with deep shadow lines between courses
- Surface texture: smooth, sand-textured, or wood-grain patterned (concrete tile manufacturers offer many surface treatments)
- Color: factory-pigmented through the tile body, or surface-coated. Common colors include terracotta, brown, gray, and slate-look
- Steep slope, typically 4:12 or steeper

### Common concrete tile profiles

- **Flat / shake-look** — flat tiles with textured surface designed to mimic wood shake or slate
- **Low-profile / S-tile** — gentle curve, common on tract homes
- **High-profile / Spanish or barrel** — pronounced curve, Mediterranean appearance

### Recognition by viewpoint

- **Street view:** distinctive tile pattern, deep shadow lines, often a heavier visual presence than shingle. Color may vary across the field showing weathering patterns
- **Drone view:** clear tile courses, ridge tiles along the peak, hip tiles along hips, valley flashing visible
- **Ladder edge:** drip edge or eave tile, gutter relationship, sometimes a metal eave-closure
- **Attic view (if accessible):** underside of the tile battens or counter-battens (depending on installation), the underlayment visible from below in some assemblies, deck condition

### Distinguishing concrete tile from look-alikes

| Indicator | Concrete tile | Clay tile | Composite/synthetic tile |
|---|---|---|---|
| Weight | Heavy | Heavy (often slightly lighter than concrete) | Significantly lighter |
| Sound when tapped | Dull thud | Higher-pitched ring | Plastic-sounding |
| Color uniformity | Pigmented through-body or surface-coated; surface coatings can wear off | Color is the natural fired clay | Manufactured uniform color |
| Edge appearance | Smooth or factory-textured concrete edge | Sometimes shows the natural clay edge | Manufactured edge |
| Age clues | Common on homes built 1980s–2010s | Common on older or higher-end homes | Common on recent custom homes |

> **[SALES REP BOUNDARY]** Reps may identify the tile type by visual indicators. Definitive product identification requires manufacturer documentation when available.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '4'
);

-- Part 1 / Ch 8 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Clay tile** | Clay is fired terracotta — distinct color, slight ring when tapped, usually on older or higher-end homes. Concrete is cast cement, dull thud when tapped, common on tract homes from the 1980s onward. |
| **Composite / synthetic tile** | Significantly lighter weight, plastic-sounding when tapped, common on recent custom homes. |
| **Concrete shake-look tile vs real wood shake** | Real wood shake is split wood with grain visible; concrete shake-look tile is cast concrete textured to mimic wood. Tap test confirms quickly. |
| **Stone-coated metal shake** | Metal shingle with stone-coated surface designed to look like shake or tile. Lighter weight, metallic underside visible at edges. |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '5'
);

-- Part 1 / Ch 8 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A concrete tile roof is a layered system. The key insight: the **underlayment is the actual waterproofing**, not the tiles.

1. **Roof deck** — plywood or OSB sheathing.
2. **Underlayment** — the actual waterproofing layer. Originally installed as one or two plies of asphalt-saturated felt ("30-pound felt" or "double 30-pound") or modern synthetic underlayment. **This is where leaks come from when a tile roof fails.**
3. **Battens (in some assemblies)** — wood strips fastened over the underlayment that the tiles attach to. Some installations are direct-deck mounted without battens.
4. **Tiles** — the visible roof covering. Mechanically fastened and/or held by gravity and interlock depending on profile and installation method.
5. **Flashings** — metal at valleys, sidewalls, headwalls, chimneys, and skylights. Tile-specific flashing details exist for the various penetration types.
6. **Ridge and hip tiles** — specialty tiles installed at the peak and along hips, typically mortared or mechanically fastened with weather-blocking underneath.
7. **Eave closures** — fascia boards, anti-bird strips, or metal closures at the bottom edge of the tile field.
8. **Pipe boots and penetration flashings** — purpose-made flashings for plumbing vents, exhaust vents, and other penetrations.

> **[CHECK MANUFACTURER]** Concrete tile manufacturers offer many profiles, fastening patterns, and installation specifications. Detail requirements vary by product.

[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of a concrete tile roof showing deck, underlayment (highlighted as the actual waterproofing layer), batten (if applicable), tile, and a valley or penetration detail.
Purpose: Reinforce the central learning point — underlayment is the waterproofing.
Caption: Cross-section of a typical concrete tile assembly. The underlayment is the waterproofing layer; the tiles shed bulk water but are not waterproof on their own.
Alt text: Diagram of a concrete tile roof showing deck, underlayment, batten, and tile with a valley flashing detail.
Annotation needed: Yes — clearly highlight the underlayment as the waterproofing layer.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '6'
);

-- Part 1 / Ch 8 / Sec 7: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$Concrete tile lifespan is genuinely confusing because **the tile and the underlayment have very different lifespans** — and most customers and many new reps assume the visible tile life equals the roof system life.

- **Tile lifespan:** the tiles themselves commonly last 50+ years. Concrete tiles are extremely durable as a material. They can chip, crack from impact, or weather aesthetically, but they don't fail from age the way shingles do.
- **Underlayment lifespan:** traditional asphalt-felt underlayment typically performs in the range of about **20–30 years** in NorCal before degrading to the point where leaks develop. Synthetic underlayments may perform longer.
- **Practical roof system lifespan:** roughly **20–30 years** before underlayment replacement becomes the appropriate work — even though the tiles may still look fine.

This mismatch creates the central tile-roof conversation: an aging tile roof needs underlayment replacement, but the customer sees their tiles and thinks the roof is fine.

> **[VERIFY LOCALLY]** NorCal underlayment performance varies between coastal and inland zones. Confirm specific patterns with field experience.

### What reps must NOT promise
- That the tiles' lifespan equals the roof's lifespan
- That a re-felt (underlayment replacement) job is a USA Flat Roof scope (it isn't — referred out)
- A specific number of remaining years on an aging underlayment

### Suggested customer language
> "Concrete tiles themselves can last 50 years or more. The underlayment underneath is what actually waterproofs the roof, and that typically performs in the range of about 20 to 30 years. So when we look at a tile roof, the question isn't really 'how are the tiles?' — it's 'how is the underlayment?' Based on what we're seeing, here's what we'd expect…"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '7'
);

-- Part 1 / Ch 8 / Sec 8: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Very long tile life** — the tiles outlast most other roof coverings.
- **Fire-resistant** — concrete is non-combustible; concrete tile typically achieves Class A fire rating.
- **Distinctive aesthetic** — tile is a defining feature of many California neighborhoods.
- **Energy performance** — air gap between tiles and deck contributes to thermal performance.
- **Hail and impact resistance** is generally good (though tiles can crack from focused impacts).
- **Not prone to granule loss** the way composition shingles are.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '8'
);

-- Part 1 / Ch 8 / Sec 9: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Heavy** — typically 800–1,200 pounds per square (100 sq ft), versus 250–450 pounds for composition shingle. Structural capacity must be considered.
- **Underlayment is the failure point**, not the tile — customers often delay action because the visible tiles look fine.
- **Walking damage** — tile roofs are walked carefully; foot traffic in the wrong place breaks tiles. This affects inspection technique.
- **Tile replacement matching** — discontinued tile profiles or colors can be difficult to source, complicating repair.
- **Specialty work** — concrete tile is a different trade from composition shingle; many general roofing crews are not tile-trained.
- **Mortar deterioration** at ridges and hips on older installations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '9'
);

-- Part 1 / Ch 8 / Sec 10: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Single broken or cracked tile | Maintenance → Repair | One or two tiles cracked; underlayment still intact in most cases |
| Multiple broken tiles | Repair → Urgent | Several tiles damaged; potential underlayment exposure |
| Slipped or displaced tile | Repair | Tile out of position; risk of further displacement and underlayment exposure |
| Mortar deterioration at ridge/hip | Repair → Urgent | Cracked, missing, or crumbling mortar on ridge or hip |
| Failed pipe boot or penetration flashing | Repair → Urgent | Cracked boot, separated flashing, sealant-only repairs |
| Failed valley flashing | Urgent | Rust, debris dam, water tracking under tiles |
| Underlayment failure (visible) | Urgent | Black underlayment showing brittleness, cracking, or tearing under lifted tiles |
| Leak inside the home | Urgent | Active leak — almost always traces to underlayment or flashing failure |
| Tile color fade / surface coating wear | Monitor | Aesthetic only; not a waterproofing concern |
| Biological growth (moss, algae) | Maintenance | Vegetation in tile crevices or on the tile surface |
| Debris accumulation in valleys | Maintenance | Leaves, needles, and debris damming valleys |
| Bird nesting under tiles | Maintenance → Repair | Especially at eaves and penetrations; can damage underlayment |
| Cracked tiles around penetrations | Repair | Often from improper foot traffic during prior trade work |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify underlayment condition without proper inspection access; they do not diagnose root cause of a leak without senior review; they do not estimate underlayment remaining life.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '10'
);

-- Part 1 / Ch 8 / Sec 11: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$Tile roof inspection requires care — for the rep's safety, for the tiles, and for accuracy.

### Safety first
- Tile roofs require careful walking technique. Step on the lower third of each tile, where the tile is supported by the one below.
- **Reps should not walk a tile roof without specific training and PPE.** Drone inspection, ladder-edge inspection, and ground-level inspection are often the appropriate scope.
- Never walk a wet, mossy, or debris-covered tile roof.

### Inspection sequence

**Ground-level walk-around**
- Photograph all four elevations
- Look for visibly broken, missing, or displaced tiles
- Note tile color, profile, and any obvious aesthetic concerns
- Photograph gutters, downspouts, and visible valleys
- Note tree overhang and debris exposure

**Ladder edge (where safe)**
- Check eave detail, drip edge, and gutter relationship
- Photograph the bottom edge of the tile field
- Look for any debris accumulation in gutters or valleys

**Drone inspection (preferred for tile roofs)**
- Photograph each slope individually
- Inspect every penetration (vents, pipes, chimneys, skylights)
- Inspect every valley
- Inspect ridge and hip lines for mortar or fastening condition
- Look for displaced tiles, debris, biological growth

**Roof surface inspection (only if trained and safe)**
- Walk only on supported tile portions
- Inspect every penetration up close
- Check valley flashings for rust, debris, or water tracking
- Lift edges of suspect tiles carefully (without causing damage) to check underlayment condition where possible
- Look for any sign of underlayment failure visible at lifted edges

**Attic inspection (if accessible)**
- Look for daylight at penetrations or eaves
- Look for water staining on the deck underside
- Note any evidence of past leaks (water marks, repaired drywall above, insulation damage)
- Look for any sign of deck deterioration

**Interior leak evidence (if reported)**
- Photograph staining
- Identify approximate location relative to roof penetrations or transitions

### Red flags requiring immediate escalation

- Active interior leak with unknown source
- Visible underlayment failure (black, brittle, cracking material visible under lifted tiles)
- Structural deflection or sagging
- Soft deck underfoot
- Widespread ridge or hip mortar failure
- Underlayment age confirmed at 20+ years with leak history
- Customer requesting full tile roof replacement (refer out — not USA Flat Roof scope)
- Solar array on the tile roof
- Suspected mold, asbestos in older underlayment, or other hazard$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '11'
);

-- Part 1 / Ch 8 / Sec 12: Recommendation Options — Repair / Maintenance / Refer
UPDATE sections SET
  content_markdown = $mfst$The Good/Better/Best framework here is different from membrane roofs. USA Flat Roof's scope on concrete tile is repair and maintenance only. Replacement (re-felt or full tile-system replacement) is referred out. The honest framework:

### Scenario A: 12-year-old tile roof, two broken tiles from a recent storm, no leaks, sound flashings

- **Right call:** repair the broken tiles (replace with matching tiles or close color match), document condition, recommend annual maintenance.
- **Not appropriate:** suggesting the customer needs major work. The roof is in its early-mid life and the failure is localized.

### Scenario B: 22-year-old tile roof, several cracked tiles, deteriorated mortar at ridge, one failed pipe boot, no active leaks but underlayment age is approaching the typical service range

- **Right call:** propose a maintenance scope — replace cracked tiles, re-mortar the ridge, replace the failed pipe boot. **Be honest with the customer that the underlayment is approaching the age where replacement becomes the right answer**, and that the maintenance work extends current service rather than resetting it.
- **Refer out:** if the customer wants to discuss underlayment replacement (a full re-felt where tiles are removed, underlayment replaced, and tiles reinstalled) — that's specialty tile work and outside USA Flat Roof's scope.

### Scenario C: 28-year-old tile roof, multiple active leaks, visible underlayment failure at lifted-tile inspection points, water staining in attic

- **Not appropriate:** patching with maintenance work. Spot repairs on a roof with end-of-life underlayment are short-term spending without addressing the root cause.
- **Right call:** explain the underlayment situation honestly to the customer, offer any temporary repair work that's clearly within scope (failed pipe boot, broken tiles around the leak path), and **refer the customer to a tile specialty contractor for re-felt evaluation and pricing**. Document the inspection thoroughly so the customer has a defensible record.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific scope limits on concrete tile work and the referral process for re-felt and tile replacement projects.

### The honest-versus-easy moment for tile

The temptation on tile roofs is to do small repairs on roofs that genuinely need underlayment replacement, because the small repair is within scope and feels helpful. The customer is happy in the short term. But two years later they have another leak in a different location, another small repair, and so on — without ever addressing the underlying issue.

**The right call is to do the repair *and* tell the customer honestly what's happening with the underlayment.** Document the conversation. Provide the referral. Customer trust is built on the honest information, not just the immediate fix.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '12'
);

-- Part 1 / Ch 8 / Sec 13: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "Here's the thing about a tile roof: the tiles themselves can last 50 years or more. The waterproofing on a tile roof isn't the tiles — it's the underlayment underneath them. The underlayment is what actually keeps water out, and that typically lasts about 20 to 30 years. So when we inspect a tile roof, we're looking at two things separately: the condition of the tiles, and the condition of the underlayment. They age differently. The tiles you see might look fine while the underlayment underneath has reached the end of its life — that's how a 'good-looking' tile roof can leak."

### Talking points

1. The tiles are not the waterproofing — the underlayment is. This single fact changes how tile roofs are inspected and discussed.
2. USA Flat Roof handles repair and maintenance on tile roofs. Major underlayment replacement is specialty work and we refer it out — we'll connect you with the right contractor when that's what's needed.
3. Tile roofs need careful walking technique. Damage from prior trades (HVAC, solar, antenna, painters) is common and accelerates problems.
4. Maintenance on tile roofs matters: clearing debris from valleys, addressing biological growth, replacing broken tiles promptly, and keeping flashings in good condition.
5. Most tile-roof leaks trace to one of three places: a flashing detail, a penetration boot, or aged underlayment. Inspection focuses on those.

### FAQ

- **Q: My tiles look fine — why does my roof leak?** A: The tiles aren't the waterproof layer. The underlayment underneath the tiles is what actually keeps water out, and underlayment ages on a different timeline than the tiles. A roof can have apparently fine-looking tiles and a failed underlayment.
- **Q: How long will a tile roof last?** A: The tiles themselves typically last 50 years or more. The underlayment that actually waterproofs the roof typically lasts about 20 to 30 years. So when people ask about "tile roof lifespan," the honest answer is that the underlayment determines when major work is needed.
- **Q: Can I just patch where it's leaking?** A: Sometimes. If the leak is from a failed flashing detail or a damaged tile, we can repair that. If the leak traces to aged underlayment, patching one location won't address the underlying issue — you'll see another leak somewhere else within a year or two.
- **Q: Why don't you do full tile replacement?** A: Concrete tile work at the underlayment-replacement scale is specialty work. We've made the call to focus on what we do well — flat roofing, composition shingles, restoration coatings, and tile-roof repairs and maintenance — and refer out the specialty tile re-felt work to contractors who specialize in it.
- **Q: One of my tiles broke — is the whole roof at risk?** A: Usually not. A single broken tile is typically a localized issue. The underlayment is still there, doing its job. We'll replace the broken tile, check the condition of the surrounding area and the underlayment where we can see it, and document what we find.
- **Q: Should I get the tiles cleaned?** A: If there's significant biological growth or debris accumulation, cleaning has value. Tile cleaning needs to be done carefully — pressure washing can damage tiles and underlayment. We can recommend appropriate methods and timing.

### Objections & Responses

- **"You're more expensive than the handyman quote."** A: Tile work is specialty work. A handyman can replace a broken tile, but they may not be checking the underlayment condition, the flashing details, or whether the broken tile points to a larger pattern. Different scope, different price. Let us walk you through what we'd actually be doing.
- **"My roof is 25 years old and the tiles look great. I don't need any work."** A: The tiles probably do look great — they typically last 50+ years. But the underlayment underneath, which is what keeps water out, typically performs in the range of about 20 to 30 years. We're not saying you need work today, but a thorough inspection now gives you a baseline to plan from. That's worth doing whether or not you decide on any immediate repair.
- **"I had a roofer tell me I need a new roof. You're saying I just need a repair. Who's right?"** A: Without seeing what the other roofer saw, I can't say for sure. What I can tell you is what we found on our inspection, what we'd recommend doing, and what we'd recommend escalating. If you want, we can walk you through how a tile re-felt project differs from spot repairs, and you can compare the scopes side by side.
- **"Can't you just seal the broken spots?"** A: We can address specific failures, but "sealing" tile roofs is rarely the right approach. Most "roof sealers" sold for tile are short-term fixes that mask issues without solving them. Targeted repair work is more durable and more honest.

### Common sales mistakes (do not do)

- Quoting a remaining-life number for the underlayment based on visual inspection alone
- Calling a tile roof "shot" or "done" because tiles look weathered (the tiles aren't the waterproofing)
- Doing small repairs on a roof that genuinely needs underlayment replacement without telling the customer about the underlayment situation
- Promising that one repair will solve all leak issues
- Walking onto a tile roof without proper training
- Identifying tile material (concrete vs clay vs composite) without confirming when uncertainty matters
- Recommending pressure washing without manufacturer-appropriate methods
- Quoting full tile roof replacement (outside USA Flat Roof scope)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '13'
);

-- Part 1 / Ch 8 / Sec 14: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Maintenance / repair recommendation:**
> Based on inspection, the existing tile roof is in serviceable condition. Recommended scope: replace cracked tiles at [locations], re-mortar ridge at [locations], replace failed pipe boot at [location], clear debris from valleys, and address biological growth on north slopes. The underlayment, which is the actual waterproofing layer beneath the tiles, was inspected at accessible points and appears to be at approximately [estimated age range]. **This maintenance scope addresses current issues and extends current service. It does not replace the underlayment, which will eventually require a full tile-system re-felt by a tile specialty contractor.**

**Repair only (with referral note):**
> Recommended scope: replace broken tiles at [locations] and reseal flashing at [location]. Inspection identified additional concerns including [conditions] that suggest the underlayment is approaching end of life. **For full tile re-felt evaluation and pricing, we will provide a referral to a tile specialty contractor.**

**Inspection-only deliverable:**
> Inspection complete. Findings documented with photographs and severity ratings. No immediate repair work proposed at this time. Recommended next steps: [annual inspection cadence / referral for tile specialty evaluation / specific maintenance items].$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '14'
);

-- Part 1 / Ch 8 / Sec 15: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every tile inspection:**

- All four elevations from ground level
- Each roof slope from elevated view (drone preferred)
- All tiles visible in overview shots
- Every broken, cracked, or displaced tile (close-up with reference scale)
- Every penetration (vents, pipes, chimneys, skylights)
- Every valley
- Every ridge and hip line
- Any visible underlayment (where exposed at edges, lifted tiles, or damaged areas)
- Gutters and any debris accumulation
- Attic interior if accessible (deck condition, water staining, daylight)
- Interior leak evidence if reported

**Conditions to note:**
- Tile profile and approximate age of installation
- Underlayment type and approximate age (if known or inferable from build year)
- Tile color/profile match availability concerns
- Mortar condition at ridges and hips
- Walking damage from prior trades
- Solar or telecom equipment

**Severity rating** applied to each documented condition using the four-point scale.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '15'
);

-- Part 1 / Ch 8 / Sec 16: When to Escalate or Refer Out
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator or production manager when:

- Customer requests work outside USA Flat Roof scope (full tile replacement, re-felt projects)
- Visible underlayment failure with active leak history
- Suspected structural deflection
- Solar array on tile roof (re-roof and repair coordination needed)
- Suspected hail or storm damage with insurance involvement
- Suspected asbestos in older underlayment (some 1970s and earlier underlayments)
- Customer wants written assessment of remaining underlayment life
- Tile profile / color matching concerns for repair sourcing
- Multi-tenant or HOA buildings with stakeholder approval requirements

**Refer out to a tile specialty contractor when:**

- Full tile-system re-felt is the appropriate scope
- Customer wants new tile installation
- Specialty tile work beyond repair-and-maintenance scope$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '16'
);

-- Part 1 / Ch 8 / Sec 17: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat tiles as the waterproofing layer and miss the underlayment-vs-tile distinction.
- They walk tile roofs without proper training and break tiles in the process.
- They do small repairs on aged-underlayment roofs without telling the customer about the underlying situation.
- They quote remaining-life numbers based on tile appearance.
- They confuse concrete tile with clay tile or composite, sometimes affecting repair material sourcing.
- They miss biological growth and debris as maintenance items that genuinely matter on tile.

**Discussion questions for group training**
- Walk through Scenario C. How do you tell a customer their roof needs major work when the tiles look fine?
- A 25-year-old tile roof has one broken tile. How do you handle the inspection and proposal?
- A handyman quoted half your price for a tile repair. How do you handle the comparison without bashing the handyman?
- Why does USA Flat Roof refer out tile re-felt work? Frame the answer for a customer who asks.
- What's the 30-second answer to "the tiles look fine, why is my roof leaking?"

**Field exercises**
- Pair up. Review three sets of tile roof photos. Distinguish concrete from clay from composite. Identify visible failure modes. Apply severity ratings.
- Walk a real tile roof together (only if trained). Have the trainee identify access points where underlayment can be inspected without damage.
- Practice the underlayment conversation in role-play — "the tiles look fine, but the roof needs major work" framing.

**What the manager should test verbally**
- The underlayment-as-waterproofing concept in plain customer language.
- Distinguish concrete from clay from composite tile.
- Walk through a Good/Better/Refer presentation for a 22-year-old tile roof.
- State five things a rep must not promise about tile roofs.
- Explain when to refer out and how to frame the referral honestly.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '17'
);

-- Part 1 / Ch 8 / Sec 18: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Concrete tile is widespread on Northern California residential roofs. The single most important fact about a tile roof: **the tiles are not the waterproofing — the underlayment underneath is**. Tiles commonly last 50+ years; underlayment commonly lasts 20–30. This mismatch creates the central tile-roof conversation, where a "good-looking" tile roof can have a failed underlayment. USA Flat Roof's scope is repair and maintenance on tile roofs — replacing broken tiles, re-mortaring ridges, replacing failed pipe boots and flashings, and clearing debris and biological growth. Full tile-system re-felt is referred out to specialty contractors. Reps should not walk tile roofs without training, should not quote underlayment remaining-life from visual inspection, should not do small repairs on end-of-life roofs without honestly disclosing the underlayment situation, and should escalate any condition exceeding their training. The honest-versus-easy moment on tile roofs is telling a customer their underlayment is failing even when the tiles look fine — and providing the referral when full re-felt is the right answer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '18'
);

-- Part 1 / Ch 8 / Sec 19: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** On a concrete tile roof, the actual waterproofing layer is:
A. The tiles themselves
B. The underlayment beneath the tiles
C. The mortar at the ridge
D. The flashings only

**2. (Beginner)** Concrete tiles themselves typically last:
A. 5–10 years
B. 15–20 years
C. 50+ years
D. Forever — concrete doesn't degrade

**3. (Beginner)** The underlayment beneath a concrete tile roof typically performs in the range of:
A. 5–10 years
B. About 20–30 years
C. 50+ years, matching the tiles
D. Indefinitely

**4. (Intermediate)** A homeowner says "my tiles look fine, why is my roof leaking?" The most accurate response is:
A. The tiles must be defective
B. Tile roofs don't usually leak; check the gutters
C. The underlayment beneath the tiles is the actual waterproofing layer, and it ages on a different timeline than the tiles
D. The customer is mistaken about the leak

**5. (Intermediate)** USA Flat Roof's scope on concrete tile roofs is:
A. Full tile replacement and new installations
B. Repair and maintenance, with full re-felt work referred out
C. Inspection only — no repair work
D. We do not work on tile roofs

**6. (Intermediate)** A 25-year-old concrete tile roof has multiple active leaks and visible underlayment failure at inspection points. The most honest recommendation is:
A. Patch each leak individually
B. Recommend pressure washing the roof
C. Address what's clearly within scope, explain the underlayment situation, and refer the customer to a tile specialty contractor for re-felt evaluation
D. Recommend silicone coating

**7. (Intermediate)** Walking a tile roof requires:
A. No special technique
B. Walking on the lower third of each tile, on supported areas, and only with proper training
C. Walking only on the ridge tiles
D. Pressure-washing the tiles first

**8. (Advanced)** A homeowner has a 22-year-old tile roof with two broken tiles and otherwise sound conditions. Another contractor quoted full roof replacement. The most appropriate USA Flat Roof response is:
A. Match the replacement quote
B. Decline to comment on the other quote
C. Document inspection findings honestly, propose appropriate repair within scope, and explain that the underlayment is approaching the typical service range — letting the customer compare scopes
D. Tell the customer the other contractor is wrong

**9. (Advanced)** A property manager asks for tile cleaning service on multiple homes. The most appropriate response includes:
A. Quote pressure washing without further inspection
B. Decline because USA Flat Roof doesn't clean roofs
C. Discuss appropriate cleaning methods (which depend on tile type and condition), inspect each roof, and propose work tailored to what each property needs
D. Quote a flat per-home rate without inspection

**10. (Advanced)** A homeowner has a tile roof with one broken tile and asks to "just have a handyman seal everything." The most honest response is:
A. Agree that sealing is the simplest answer
B. Explain that "sealing" tile roofs is rarely appropriate, that targeted repair is more durable, and offer a proper repair scope
C. Refer the customer to a handyman
D. Do the sealing work

---

### Answer Key

1. **B — The underlayment beneath the tiles.** This is the central learning point of the chapter. The tiles (A) shed bulk water but are not the waterproofing.
2. **C — 50+ years.** The tiles themselves are extremely durable.
3. **B — About 20–30 years.** This is the typical underlayment range. The mismatch with tile lifespan drives the central conversation.
4. **C — The underlayment beneath the tiles is the actual waterproofing layer.** Defective tiles (A) and customer error (D) are wrong. "Tile roofs don't usually leak" (B) is false.
5. **B — Repair and maintenance, with full re-felt work referred out.** Specific to USA Flat Roof's scope.
6. **C — Address what's clearly within scope, explain the underlayment situation, and refer.** Patching leaks individually (A) on an end-of-life underlayment is short-term spending. Pressure washing (B) doesn't address the issue. Coating (D) isn't appropriate for tile.
7. **B — Walking on the lower third of each tile, on supported areas, and only with proper training.** This is the safety standard. (A) and (C) are unsafe; (D) is unrelated.
8. **C — Document inspection findings honestly, propose appropriate repair within scope, and explain the underlayment situation.** Matching the replacement quote (A) without justification is dishonest. Declining to comment (B) abandons the customer. Telling the customer the other contractor is wrong (D) is unprofessional and unsupported.
9. **C — Discuss appropriate cleaning methods, inspect each roof, propose tailored work.** Pressure washing without inspection (A, D) can damage tiles and underlayment. Declining (B) is overly restrictive — appropriate tile cleaning is within scope.
10. **B — Explain that sealing is rarely appropriate; offer proper repair.** This is the honest answer. Agreeing with the seal-everything approach (A, D) is the easy-but-wrong path.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '19'
);

-- Part 1 / Ch 8 / Sec 20: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California residential market?
- [ ] Accurate for USA Flat Roof's scope and limits on tile work?
- [ ] Matches USA Flat Roof's referral process and partner contractors?
- [ ] Does the underlayment-as-waterproofing framing match how we want reps to lead the conversation?
- [ ] Are escalation and referral triggers correct for our team structure?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the maintenance scope match what our crews actually perform?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm common concrete tile brands and profile sourcing for repair material in NorCal.
- Underlayment age ranges: 20–30 year NorCal range for traditional asphalt felt — verify with field experience.
- Walking technique and crew training: confirm USA Flat Roof's standards for tile-roof access.
- Cleaning methods: verify USA Flat Roof's approved cleaning approaches for concrete tile.
- Asbestos awareness: older underlayments may contain asbestos — confirm current handling and testing protocol.
- Company policy items: USA Flat Roof's specific scope limits, referral partners, and repair pricing structure.
- Sales scripts: review against current standard proposals and approved customer-facing language.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 8 AND s.section_number = '20'
);

-- Part 1 / Ch 9 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify built-up roofs on sight and distinguish them from modified bitumen and other flat-roof systems.
2. Determine whether a BUR roof has one layer or multiple layers — the central question driving USA Flat Roof's recommendation options.
3. Inspect a BUR roof and classify common conditions on the Inspection Severity Scale.
4. Present the Good/Better/Best framework — silicone restoration, TPO overlay, or full replacement — honestly based on roof condition.
5. Recognize when a BUR roof exceeds the rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '1'
);

-- Part 1 / Ch 9 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**Built-up roofing**, almost always shortened to **BUR**, is a flat-roof system built from multiple layers of bitumen-saturated felt or fiberglass plies bonded together with hot asphalt or coal tar pitch, typically topped with a layer of gravel or a smooth asphalt cap. It is one of the oldest commercial roofing systems in widespread use, with installations going back over a century.

BUR is sometimes called **"tar and gravel"** by customers and older field hands. The term refers to the hot asphalt and protective gravel surface that defines most traditional installations.

USA Flat Roof does not install new BUR — the system has largely been replaced on new commercial construction by single-ply membranes (TPO, PVC), modified bitumen, and SPF. But reps will encounter BUR constantly on inspections of older commercial buildings, particularly anything built between roughly the 1950s and the 1990s.

The central scope decision on a BUR roof comes down to a single question: **how many layers are on the roof?**

- **One layer of BUR (no recover):** USA Flat Roof can offer four recommendation paths — silicone restoration, TPO overlay, SPF, or full replacement.
- **Multiple layers (BUR with prior recover):** different conversation, typically full tear-off and replacement.

> **[VERIFY LOCALLY]** California building code and local jurisdiction limit how many roof layers a building may carry. A second recover is generally not permitted; a third never is. Confirm with code official before proposing recover work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '2'
);

-- Part 1 / Ch 9 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Common on:** older commercial buildings (1950s–1990s), schools, hospitals, government buildings, industrial buildings, multifamily flat-roof structures from that era
- **Less common on:** new commercial construction (largely displaced by single-ply systems and modified bitumen)
- **Almost never on:** residential

In Northern California, BUR is encountered on older Bay Area commercial buildings, Sacramento Valley industrial properties, and any commercial building older than roughly 30 years that hasn't already been recovered or replaced.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '3'
);

-- Part 1 / Ch 9 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

BUR comes in two main surface types:

- **Gravel-surfaced BUR (most common older installations)** — top layer of loose or embedded gravel covers the asphalt cap. Gives the roof a rocky, textured appearance from above. Gravel is functional, not decorative — it protects the asphalt from UV and weather.
- **Smooth-surfaced BUR** — exposed asphalt cap without gravel. Often coated later with reflective aluminum or elastomeric coating to extend life.

### Recognition by viewpoint

- **Drone or satellite view:** distinctive gravel surface (most common) or smooth dark asphalt cap. Visible at the parapets where the roofing wraps up the wall.
- **Roof surface:** gravel underfoot, layered asphalt edges visible at terminations and penetrations, multiple plies sometimes visible at damaged or cut edges.
- **Edges and terminations:** look for the layered edge — BUR shows distinct multi-ply construction at any cut or torn edge. This is the most reliable way to confirm BUR versus other flat-roof systems.
- **Interior leak evidence:** ceiling stains, efflorescence on parapet wall interiors, water tracking along structural members.

### How to count BUR layers

Counting layers is the central question for proposal purposes. Methods:

1. **Edge inspection at flashings, terminations, or cut areas** — look for the visible cross-section. A single-layer BUR shows one set of plies and gravel/cap. A recovered roof shows the original system plus additional roofing material on top.
2. **Probe at flashings or transitions (production team task)** — careful coring or probing to confirm layer count.
3. **Building documentation** — original roof age, prior recover history, permit records.
4. **Customer or property manager records** — service history.

> **[SALES REP BOUNDARY]** Reps may estimate layer count from visible edge inspection. Definitive layer counting (especially via probing or coring) is a production team or qualified inspector task — not a sales rep task. When uncertain, escalate.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '4'
);

-- Part 1 / Ch 9 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Modified bitumen (mod-bit)** | Mod-bit is fewer plies (often two), engineered with polymer modifiers, with a granule-surfaced or smooth cap sheet — not a gravel field. The most common confusion in this chapter. |
| **TPO or PVC** | Single-ply systems are smooth, white, and welded. BUR is gravel- or asphalt-surfaced and multi-ply. |
| **EPDM** | EPDM is a black rubber single-ply with glued/taped seams. BUR is multi-layer asphalt with gravel or smooth cap. |
| **Coated BUR** | An old BUR roof may have been coated with aluminum, acrylic, or silicone. The gravel or asphalt substrate is still BUR underneath. Identifying the substrate matters for any future scope. |
| **SPF (spray polyurethane foam) over old BUR** | SPF has a textured, slightly orange-peel surface. The BUR substrate is still beneath the foam. (See Chapter 10.) |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '5'
);

-- Part 1 / Ch 9 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$A traditional BUR system is layered from the structure up:

1. **Roof deck** — concrete, gypsum, wood, or metal, depending on the era and building type.
2. **Vapor retarder** *(in some assemblies)* — limits moisture migration into the assembly.
3. **Insulation** — typically perlite, fiberboard, or older polyiso. Insulation type and condition vary widely on older BUR roofs.
4. **Base sheet** — the first ply, often nailed or hot-mopped to the substrate.
5. **Multiple plies** — typically 3 to 5 plies of bitumen-saturated felt or fiberglass, bonded with hot asphalt or coal tar pitch.
6. **Bitumen flood coat** — final layer of hot asphalt across the field.
7. **Surface (gravel or cap)** — gravel embedded in the flood coat, or a smooth asphalt cap, or a granule-surfaced cap sheet.
8. **Flashings** — typically asphalt-based or metal at parapet walls, curbs, drains, and penetrations.
9. **Terminations** — termination bars, counter-flashing, sealant, and metal coping.
10. **Drains and scuppers** — drainage components.

> **[CHECK MANUFACTURER]** BUR systems were historically built from many manufacturer specifications. New work is rarely BUR; references to manufacturer specs typically apply to recover or coating systems applied over existing BUR.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '6'
);

-- Part 1 / Ch 9 / Sec 7: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$- **Industry rating range:** original BUR installations were often warranted for 10, 15, or 20 years depending on plies and specification. Many BUR roofs significantly exceeded their warranty length.
- **Real-world field range:** roughly **20–40+ years** for BUR roofs in NorCal, with significant variation. The longest-running flat-roof systems still in service today are often original-installation BUR from the 1950s and 1960s.
- **Track record advantage:** BUR has the longest documented field service history of any commercial flat-roof system. The aging of a 50-year-old BUR roof is well understood; the aging of a 50-year-old single-ply roof is largely theoretical because few exist yet.
- **Factors that shorten lifespan:** poor original installation, chronic ponding, mechanical damage, biological growth, deferred maintenance, gravel displacement exposing the asphalt to UV.
- **Factors that extend lifespan:** good drainage, intact gravel coverage, regular inspections, prompt repair of seam and flashing issues, and periodic coating with reflective products.

> **[VERIFY LOCALLY]** Many original-installation BUR roofs in NorCal commercial are now 30–50+ years old. Conditions vary widely. Confirm specific patterns with field experience.

### What reps must NOT promise
- Specific service-life numbers
- That a coating or overlay "resets" the roof's age
- Outcomes contingent on customer maintenance behavior
- Warranty payouts on aging systems

### Suggested customer language
> "BUR roofs are built to last. The original installation might be 30 or 40 years old and still serviceable, depending on conditions. The question isn't usually 'how old is the roof' — it's 'what's the substrate condition today, and is there one layer up there or multiple?' That determines what makes sense going forward."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '7'
);

-- Part 1 / Ch 9 / Sec 8: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Proven track record** — the longest-running flat-roof system in commercial use.
- **Multi-ply redundancy** — multiple bonded layers provide significant waterproofing redundancy.
- **Gravel surface protection** — embedded gravel protects the asphalt from UV exposure when properly maintained.
- **Repairable** — patches with compatible asphalt-based materials are well-understood work.
- **Coatable and recoverable** — BUR is a strong substrate for silicone restoration, TPO overlay, or SPF when conditions qualify.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '8'
);

-- Part 1 / Ch 9 / Sec 9: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Heavy** — BUR adds significant weight to the structure. Affects load calculations on any recover scope.
- **Asbestos concern in older systems** — BUR roofs installed before roughly the 1980s may contain asbestos in felt, mastic, or flashings. Asbestos must be tested before any tear-off or major disturbance.
- **Gravel displacement** exposes asphalt to UV, accelerating aging in localized areas.
- **Difficult to walk and inspect** — gravel surface obscures membrane condition; reps cannot see most problems without disturbing gravel.
- **Limited recover options on multi-layer roofs** — code typically prohibits adding layers indefinitely.
- **Hot-applied installation methods** — when BUR is replaced like-for-like, kettle-asphalt application creates fume and fire-risk issues. (USA Flat Roof does not install new BUR for this reason.)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '9'
);

-- Part 1 / Ch 9 / Sec 10: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Gravel displacement / bald spots | Maintenance → Repair | Bare asphalt visible where gravel has migrated or been swept away |
| Surface alligatoring | Repair | Network of cracks resembling alligator skin in exposed asphalt or smooth-surfaced BUR |
| Blistering | Repair → Urgent | Raised bubbles in the membrane indicating moisture entrapment or installation defects |
| Ply separation | Repair → Urgent | Layers no longer bonded; visible separation at edges or seams |
| Failed flashings | Repair → Urgent | Asphalt-based flashings cracked, separated, or compromised |
| Failed pipe boot or detail | Repair | Cracked, separated, or shrinking flashing at penetration |
| Drain failure | Repair → Urgent | Clogged or damaged drain; standing water |
| Chronic ponding | Maintenance → Repair | Persistent water; accelerated wear at the pond |
| Wet insulation underneath | Urgent | Soft / spongy underfoot; common on aged BUR |
| Multiple roof layers | Repair → Urgent | Limits recover options; affects code compliance |
| Suspected asbestos in older BUR | Urgent | Pre-1980s installation; testing required before any disturbance |
| Active interior leak | Urgent | Water staining or drip inside the building |
| Gravel covering all conditions | N/A — escalation needed | Gravel obscures the membrane; full assessment may require gravel removal in test areas (production team task) |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not test for asbestos, do not core or probe the assembly, do not certify wet insulation extent without proper survey, and do not certify layer count without escalation when uncertain.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '10'
);

-- Part 1 / Ch 9 / Sec 11: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$BUR inspection is more difficult than single-ply or modified bitumen inspection because gravel obscures the membrane. Approach methodically.

### Building exterior walk-around
- Photograph all four elevations
- Note parapet condition, coping, scuppers, downspout outlets
- Note signs of efflorescence or staining on exterior walls

### Roof surface — general
- Photograph each quadrant
- Note overall gravel coverage; identify bald spots and gravel displacement
- Note any visible asphalt on smooth-surfaced or thinly-covered areas
- Note any ponding evidence (gravel migration patterns, water staining)

### Edge and termination inspection
- Inspect every parapet and edge for visible layer count
- Photograph any cross-section visible at flashings, scuppers, or cut areas
- Note visible ply count where assessable
- Note any prior coating or recover evidence

### Penetrations and details
- Photograph every pipe, vent, drain, HVAC curb, conduit, and skylight
- Note flashing condition (asphalt flashings on older installations, sometimes metal)
- Note any sealant repairs or unauthorized work

### Drainage
- Photograph every drain and scupper
- Note debris, vegetation, ponding extent
- Note overflow drain presence

### Underfoot assessment
- Walk-test for soft / spongy areas indicating wet insulation
- **This is one of the most important assessments on a BUR roof** — wet insulation is common on aged systems and disqualifies recover scope

### Documentation gathering
- Ask the property manager for original construction date, prior recover history, and any permit records
- Request any prior inspection reports

### Interior check (if accessible)
- Note ceiling tile staining, water marks, efflorescence
- Note drip patterns relative to known roof penetrations

### Red flags requiring immediate escalation

- Active interior leak with unknown source
- Soft / spongy underfoot — suspected wet insulation
- Visible structural deflection or sagging deck
- **Multiple roof layers visible** — affects every recommendation
- **Building age that suggests asbestos** (typically pre-1980s) — testing required before tear-off or major disturbance
- Widespread blistering or ply separation
- Gravel coverage so complete that membrane condition cannot be assessed without gravel removal
- Solar array on the roof
- Suspected hail or storm damage with insurance involvement$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '11'
);

-- Part 1 / Ch 9 / Sec 12: Recommendation Options — Good / Better / Best
UPDATE sections SET
  content_markdown = $mfst$This is the heart of the chapter. **The framework applies only to single-layer BUR roofs.** Multi-layer BUR roofs require a different conversation (typically full tear-off and replacement, often with code-driven scope, sometimes referred out for asbestos abatement).

### Disqualifying conditions

Before applying the Good/Better/Best framework, confirm none of the following apply. Any of these typically push the conversation to full replacement (or escalation/referral):

- Multiple roof layers
- Wet insulation across significant area
- Severe structural ponding
- Visible structural deflection
- Suspected asbestos requiring abatement
- Code restrictions on recover (jurisdictional or Title 24)
- Substrate failure too widespread to address in recover prep

### Good — Silicone Restoration Coating

**When it fits:**
- Single-layer BUR
- Substrate is sound: gravel coverage adequate, no widespread alligatoring or ply separation
- No chronic ponding
- No wet insulation
- Customer wants the lowest-cost life-extension option
- Roof has 5–15 years of remaining substrate life that coating can extend

**Scope:**
- Detail repairs at all penetrations, flashings, drains, and seam transitions
- Loose gravel removal where required for coating contact
- Cleaning to remove dirt, biological growth, and debris
- Reinforcement fabric at seams, transitions, and high-stress areas
- Detail coat at penetrations and parapets
- Full silicone field coat at specified mil thickness
- Photo documentation and warranty registration

**What reps must explain honestly:**
- The coating extends life; it does not replace the BUR or add structural strength
- The BUR substrate is still aging underneath; the coating slows that aging at the surface
- Eventually full replacement becomes the right answer regardless of coating condition

> **[CHECK MANUFACTURER]** Coating compatibility with gravel-surfaced BUR varies by product. Some coating systems require gravel removal; others tolerate embedded gravel. Confirm with current manufacturer documentation.

### Better — TPO Overlay (Recover) with Fanfold or ISO Board

**When it fits:**
- Single-layer BUR
- Substrate is sound enough to support recover
- Customer wants longer life than coating provides
- Customer wants improved insulation (with ISO board option) or modest cost (with fanfold)
- Code permits the recover (single-layer status; jurisdiction allows)
- Building structure can support the added load

**Scope:**
- Substrate prep — repairs, debris removal, gravel sweep where needed
- **Fanfold (thin recovery board)** — economical option providing a smooth substrate over irregular BUR surface; minimal added insulation value
- **ISO board (rigid foam)** — adds insulation value and provides a substrate; thicker option, more cost, more thermal benefit
- Mechanical attachment of cover board through to the deck per design
- 60-mil mechanically attached TPO membrane installation
- Full flashing replacement (overlay does not preserve original BUR flashings)
- Workmanship and manufacturer warranty per program

**What reps must explain honestly:**
- TPO overlay installs a new roof system over the existing BUR; the BUR remains in place underneath
- The overlay provides a fresh waterproofing system with new flashings
- The combined assembly weight matters — verify structural capacity
- Code permits this as a single recover; future overlay would not be permitted

> **[VERIFY LOCALLY]** Title 24 and jurisdictional code requirements for recover work. Confirm structural load adequacy before proposing.

### Best — Complete Replacement

**When it fits:**
- BUR is at end of life
- Wet insulation is widespread
- Multiple layers exist
- Asbestos is present (with proper abatement)
- Customer wants the longest-life option and is investing for the long term
- Code does not permit recover

**Scope:**
- Full tear-off including BUR system and any wet insulation
- Asbestos abatement if applicable (specialty contractor required)
- Deck inspection and repair
- New insulation, cover board, and 60-mil mechanically attached TPO (or other system per customer preference)
- All new flashings, drains, and terminations
- Full workmanship and manufacturer warranty

**What reps must explain honestly:**
- Highest cost among the three options
- Longest expected service life
- Required when recover is not permitted or not appropriate
- Asbestos abatement adds cost and timeline if applicable

### A note on SPF

**Spray polyurethane foam (SPF)** is a fourth option that can fit BUR substrates in specific scenarios — particularly buildings with irregular substrates, complex penetration density, or significant insulation upgrade needs. SPF is covered in Chapter 10 (Reference). Reps should be aware SPF exists as an option, but the standard USA Flat Roof Good/Better/Best framework on BUR is silicone / TPO overlay / replacement. SPF is escalated for senior estimator review when conditions suggest it.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific scope, approach, and pricing for SPF on BUR substrates.

### The honest-versus-easy moment on BUR

Aging BUR roofs are common, and the recover options (silicone, TPO overlay) are easier to sell than full replacement — lower cost, faster project, less customer disruption. The temptation is to propose a coating or overlay even when the substrate or conditions don't truly qualify.

The right call: **escalate when uncertain, confirm layer count and substrate condition before proposing recover, and recommend full replacement when the conditions actually require it — even though it's the harder sell.**$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '12'
);

-- Part 1 / Ch 9 / Sec 13: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "Your roof is a built-up system — multiple layers of asphalt and felt with a gravel surface, originally installed [decades ago]. These systems were built to last and many of them are still serviceable well past their warranty. The big question we need to answer is whether there's one layer of roofing up there or multiple. If it's one layer, we have several options ranging from a silicone restoration coating up through full replacement. If it's multiple layers, the conversation gets simpler — code generally requires full removal at that point."

### Talking points

1. BUR is a proven system with a long track record. We're not here to tell you the roof is "obsolete" — we're here to tell you what makes sense going forward.
2. The number of layers matters more than almost anything else. We'll confirm that during inspection.
3. We have three main paths on a single-layer BUR: silicone restoration (lowest cost, life extension), TPO overlay with insulation board (longer life, fresh waterproofing), or full replacement (longest life, fresh substrate).
4. Wet insulation, severe ponding, structural concerns, or suspected asbestos all change the conversation. We escalate any of those rather than pushing recover work that won't perform.
5. We'll be honest about what each option does and doesn't do. Coating doesn't replace the roof; overlay doesn't reset it; only replacement does.

### FAQ

- **Q: Is my BUR roof obsolete?** A: No. BUR is a proven system, and many original installations are still serviceable decades after they were built. The question isn't whether the system is obsolete — it's what condition your roof is in today and what makes sense going forward.
- **Q: How long will my BUR roof last?** A: BUR roofs commonly perform in the range of 20 to 40 years or longer in NorCal, with significant variation. We won't quote a specific number — we'll inspect and tell you what we're seeing.
- **Q: Why don't you install new BUR?** A: We made the call to focus on systems that match modern construction methods — single-ply, modified bitumen, restoration coatings, and SPF. New BUR installation involves hot kettles and significant fume issues that don't fit how we operate. We're well-equipped to work on existing BUR roofs through restoration, recover, or replacement.
- **Q: What's the difference between coating, overlay, and replacement?** A: Coating extends the life of the existing roof by adding a waterproof layer on top. Overlay installs a new roof system over the existing BUR. Replacement removes the existing roof and installs a new one. Increasing scope, increasing cost, increasing expected service life.
- **Q: Is there asbestos in my old roof?** A: Possibly — BUR roofs installed before about the 1980s may contain asbestos in felt, mastic, or flashings. We don't test for asbestos ourselves; that's a specialty service. If your building's age suggests it, we'd recommend testing before any tear-off work.
- **Q: Can you just patch the leak?** A: Sometimes. We can address specific failures on a BUR roof. If the inspection reveals broader issues — wet insulation, multi-layer, end-of-life — we'll tell you that, and patching alone won't be the right answer.

### Objections & Responses

- **"You're more expensive than the patching contractor."** A: Patching is the right answer sometimes — and we can patch when that's appropriate. What we're providing is an inspection that tells you whether patching alone gets you where you want to go, or whether the roof needs broader work. Different scope, different price.
- **"Why can't you just tell me how many years I have left?"** A: Honestly, no one can tell you that with precision. We can tell you what we're seeing today, what conditions suggest, and what options make sense for the next 5, 10, or 20 years. Specific year-counts on a roof are guesses, not analysis.
- **"My building is old — I'd rather just replace it all."** A: That might be the right call, and we can put together a replacement scope. Before you commit, let us walk you through what restoration or overlay would cost and look like — sometimes there's a meaningful gap, and sometimes the replacement makes the most sense. You'll have all three numbers and can choose.
- **"Another contractor said I just need a coat of aluminum paint."** A: Aluminum coatings have a place, but they're typically a 2–5 year touch-up rather than a real life-extension product. If you want a real restoration that comes with manufacturer warranty and meaningful life extension, silicone is the more substantive option. We're glad to walk you through the comparison.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Recommending coating or overlay without confirming layer count and substrate condition
- Proposing recover on a multi-layer roof
- Disturbing gravel or coring without proper authorization (production team work)
- Promising the absence of asbestos on a pre-1980s building
- Calling BUR "obsolete" or "outdated" — it isn't
- Promising warranty outcomes without reading the actual warranty
- Promising structural capacity for overlay without engineering confirmation
- Talking down a BUR roof to upsell a replacement when restoration would qualify$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '13'
);

-- Part 1 / Ch 9 / Sec 14: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**Silicone restoration recommendation (qualifying single-layer BUR):**
> Based on inspection, the existing BUR roof is single-layer with a sound gravel-surfaced substrate, no chronic ponding, and no evidence of wet insulation. Roof qualifies for silicone restoration. Recommended scope: detail repairs at [locations], gravel sweep and cleaning, reinforcement fabric at seams and transitions, detail coat at penetrations, and silicone field coat at specified mil thickness. Restoration is intended to extend service life — it does not replace the BUR or restore deteriorated substrate. **[CHECK MANUFACTURER]** Confirm coating system, mil thickness, gravel handling, and warranty terms.

**TPO overlay recommendation (single-layer BUR):**
> Based on inspection, the existing BUR roof is single-layer with sound substrate. Recommended scope: substrate prep including [scope], installation of [fanfold / ISO board] cover board mechanically attached through to deck, 60-mil mechanically attached TPO membrane, all new flashings, drains, and terminations per current manufacturer details. Workmanship and manufacturer warranty per program tier. **[VERIFY LOCALLY]** Code permission for recover and structural load capacity confirmed. **[CHECK MANUFACTURER]** Confirm assembly per current manufacturer specifications.

**Full replacement recommendation:**
> Based on inspection findings — [specific conditions: multi-layer, wet insulation, end-of-life substrate, etc.] — recover is not appropriate for this roof. Recommended scope: full tear-off including all roof layers and any wet insulation, asbestos testing prior to tear-off [if applicable], deck inspection and repair, new insulation and cover board, 60-mil mechanically attached TPO, all flashings, drains, and terminations. Workmanship and manufacturer warranty per program tier.

**Inspection deliverable (uncertainty / escalation needed):**
> Inspection complete. Findings include [conditions]. Layer count [confirmed / requires further investigation]. Recommended next steps: [moisture survey / asbestos testing / code consultation / structural review] before any restoration or replacement scope can be finalized.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '14'
);

-- Part 1 / Ch 9 / Sec 15: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every BUR inspection:**

- All four building elevations from ground level
- Each quadrant of the roof from elevated view
- Every visible cross-section at edges, terminations, and cut areas (for layer count assessment)
- Every penetration, drain, scupper, and skylight
- Every flashing detail
- Any ponding evidence (chalk outline preferred)
- Any blistering, alligatoring, or substrate failure close-ups
- Gravel coverage condition (overview and bald spots)
- Walk-test soft areas marked
- Interior leak evidence if reported

**Documentation to gather:**

- Building age and original construction date
- Prior roofing history (recover, repairs, coatings)
- Permit records if available
- Asbestos test history if available
- Structural drawings or load capacity if available

**Severity rating** applied to each documented condition.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '15'
);

-- Part 1 / Ch 9 / Sec 16: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Layer count cannot be confirmed visually
- Multiple roof layers appear present
- Pre-1980s building with potential asbestos
- Suspected wet insulation
- Visible structural deflection or sagging deck
- Customer requesting like-for-like BUR replacement (not USA Flat Roof scope; refer)
- Code or jurisdiction questions
- Solar array on the roof
- Building of significant size or complexity beyond the rep's training
- Suspected hail or storm damage with insurance involvement
- Customer wants SPF specifically — escalate for senior estimator review
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '16'
);

-- Part 1 / Ch 9 / Sec 17: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our position on BUR work — repair, restoration, overlay, replacement; we do not install new BUR: [placeholder]
> - Our standard silicone restoration scope on BUR substrates: [placeholder]
> - Our standard TPO overlay specifications — fanfold vs ISO board criteria: [placeholder]
> - Our SPF criteria and when to escalate for SPF consideration: [placeholder]
> - Our position on like-for-like BUR replacement requests (refer out): [placeholder]
> - Our asbestos testing protocol and partner abatement contractors: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language: [placeholder]
> - Our process for confirming layer count and structural capacity before overlay proposals: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '17'
);

-- Part 1 / Ch 9 / Sec 18: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They miss the layer-count question entirely and propose overlay on multi-layer roofs.
- They confuse BUR with modified bitumen — different system, different scope.
- They don't ask about building age and miss the asbestos consideration.
- They quote lifespan numbers based on age alone.
- They propose silicone restoration on roofs with wet insulation under the gravel, not realizing the disqualifying condition.
- They call BUR "obsolete" — it isn't.
- They underestimate how much the gravel surface obscures during inspection.

**Discussion questions for group training**
- Walk through the disqualifying conditions list. For each one, why does it push the conversation to full replacement?
- A property manager asks for a "BUR replacement quote" on a 1965 building. What's your first response?
- How do you confirm layer count without coring the roof?
- A customer says "another contractor told me I just need aluminum coating." How do you handle that comparison?
- What's the 30-second answer to "is BUR obsolete?"

**Field exercises**
- Pair up. Review three sets of BUR inspection photos. Identify visible layer count, gravel condition, ponding, and apply severity ratings.
- Walk a real BUR roof together. Have the trainee identify edge inspection points, walk-test for soft areas, and document gravel coverage before reviewing with the trainer.
- Practice the layer-count conversation with a customer.
- Practice presenting Good/Better/Best for a single-layer BUR scenario.

**What the manager should test verbally**
- Distinguish BUR from modified bitumen and from single-ply membranes.
- Explain why layer count is the central scope question.
- Walk through Good/Better/Best on a single-layer BUR.
- Name the disqualifying conditions for recover work.
- State five things a rep must not promise about BUR.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '18'
);

-- Part 1 / Ch 9 / Sec 19: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Asbestos** — fibrous mineral historically used in roofing felts and mastics; potential in pre-1980s BUR systems.
- **Bitumen** — asphalt-based waterproofing material.
- **BUR (built-up roofing)** — multi-ply asphalt-and-felt roof system, often gravel-surfaced.
- **Cover board** — board installed over insulation or substrate to provide a smooth, sound base for membrane application.
- **Fanfold** — thin folded recovery board used to provide a smooth substrate over irregular surfaces; minimal insulation value.
- **Flood coat** — final layer of hot asphalt across the BUR field, into which gravel is embedded.
- **ISO board (polyisocyanurate)** — rigid foam insulation board; provides insulation value and substrate.
- **Layer count** — number of distinct roofing systems on a building; central scope question for BUR.
- **Overlay (recover)** — installation of a new roof system over an existing roof without tear-off.
- **Ply** — one layer of a multi-layer assembly.
- **Tar and gravel** — common customer term for traditional gravel-surfaced BUR.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '19'
);

-- Part 1 / Ch 9 / Sec 20: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Built-up roofing is the longest-running flat-roof system in commercial use, encountered constantly on inspections of older Northern California commercial buildings. USA Flat Roof does not install new BUR but works on existing BUR through repair, restoration, overlay, and replacement. The central scope question on every BUR inspection is layer count: a single-layer BUR opens four recommendation paths (silicone restoration, TPO overlay, SPF for specific cases, or full replacement); a multi-layer BUR typically requires full tear-off. The Good/Better/Best framework — silicone restoration as Good, TPO overlay as Better, full replacement as Best — applies only when disqualifying conditions are absent: wet insulation, severe ponding, suspected asbestos, structural deflection, code restrictions, or multiple layers. Reps should not certify layer count when uncertain, should not propose recover on multi-layer roofs, should not disturb gravel or core the assembly without authorization, and should escalate any pre-1980s building for asbestos consideration. BUR is a proven system, not an obsolete one — the right conversation is about current condition and appropriate next steps, not about replacing an entire system category.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '20'
);

-- Part 1 / Ch 9 / Sec 21: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** "BUR" stands for:
A. Bituminous urethane roofing
B. Built-up roofing
C. Bonded underlayment roof
D. Bitumen-urethane reinforced

**2. (Beginner)** A traditional BUR roof typically has which surface?
A. White single-ply membrane
B. Gravel embedded in asphalt, or smooth asphalt cap
C. Wood shake
D. Concrete tile

**3. (Beginner)** USA Flat Roof's scope on BUR roofs includes:
A. Installing new BUR roofs
B. Restoration, overlay, and replacement of existing BUR — but not new BUR installation
C. No work on BUR
D. Only emergency repairs

**4. (Beginner)** The central scope question on a BUR inspection is:
A. The color of the gravel
B. Whether the roof is single-layer or multi-layer
C. The age of the building
D. The presence of HVAC equipment

**5. (Intermediate)** USA Flat Roof's Good/Better/Best framework on a single-layer BUR is:
A. Aluminum coating / silicone / TPO overlay
B. Silicone restoration / TPO overlay / full replacement
C. Patching only / overlay / replacement
D. SPF / TPO / PVC

**6. (Intermediate)** Which of the following typically disqualifies a BUR roof from recover work (silicone restoration or TPO overlay)?
A. Light gravel displacement in one area
B. Multiple roof layers, wet insulation, or suspected asbestos
C. Surface dirt and biological staining
D. A single failed pipe boot

**7. (Intermediate)** A property manager asks USA Flat Roof to quote like-for-like BUR replacement. The most appropriate response is:
A. Quote the BUR replacement to capture the work
B. Decline without explanation
C. Explain that USA Flat Roof does not install new BUR, present alternatives — restoration, TPO overlay, or replacement with a modern system — and offer to refer to a BUR specialty contractor if they prefer like-for-like
D. Recommend silicone restoration regardless of the customer's request

**8. (Intermediate)** A 1968 commercial building has a BUR roof with widespread blistering and soft spots underfoot. The most appropriate next step is:
A. Propose silicone restoration immediately
B. Propose TPO overlay immediately
C. Escalate for asbestos testing, moisture survey, and full evaluation before proposing any scope
D. Patch the soft spots and continue monitoring

**9. (Advanced)** A customer says "BUR is obsolete — that's why nobody installs it anymore." The most accurate response is:
A. Confirm that BUR is obsolete
B. Explain that BUR has the longest field track record of any commercial flat-roof system; modern flat-roof construction has shifted to single-ply and modified bitumen, but existing BUR roofs are not obsolete and continue to be serviced through restoration, recover, or replacement
C. Recommend immediate replacement
D. Refer the customer elsewhere

**10. (Advanced)** A 22-year-old single-layer BUR roof has sound gravel coverage, no ponding, no soft spots, and minor flashing detail issues. The customer wants the lowest-cost long-term solution. The most appropriate recommendation is:
A. Full replacement
B. Multiple aluminum coatings every two years
C. Silicone restoration with appropriate detail repairs and prep
D. TPO overlay

---

### Answer Key

1. **B — Built-up roofing.** Standard term.
2. **B — Gravel embedded in asphalt, or smooth asphalt cap.** Defining feature of traditional BUR.
3. **B — Restoration, overlay, and replacement — not new BUR installation.** Specific to USA Flat Roof's scope.
4. **B — Whether the roof is single-layer or multi-layer.** Drives every recommendation. Color (A), age (C), and HVAC (D) matter but aren't the central scope question.
5. **B — Silicone restoration / TPO overlay / full replacement.** USA Flat Roof's specific framework.
6. **B — Multiple roof layers, wet insulation, or suspected asbestos.** These are the disqualifying conditions in Section 12. The other options are addressable conditions.
7. **C — Explain that USA Flat Roof does not install new BUR, present alternatives, and offer to refer.** Quoting BUR (A) violates company policy. Declining without explanation (B) abandons the customer. Recommending silicone regardless (D) ignores the actual request.
8. **C — Escalate for asbestos testing, moisture survey, and full evaluation.** A 1968 building has potential asbestos; soft spots indicate wet insulation. Both disqualify recover work and require investigation before any scope proposal. Proposing coating (A) or overlay (B) without this investigation is the textbook ethics failure. Patching (D) ignores the broader condition.
9. **B — Explain that BUR has the longest field track record; modern construction has shifted but existing BUR is not obsolete.** Confirming "obsolete" (A) is inaccurate. Recommending replacement (C) or referring (D) skips the honest education.
10. **C — Silicone restoration.** Sound single-layer BUR with addressable details qualifies for the Good (lowest-cost long-term) option in the framework. Replacement (A) overshoots; aluminum coatings every 2 years (B) is short-term; TPO overlay (D) is the Better tier, not the most cost-effective for a customer specifically asking for lowest-cost long-term solution.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '21'
);

-- Part 1 / Ch 9 / Sec 22: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for USA Flat Roof's actual scope on BUR work?
- [ ] Matches USA Flat Roof's Good/Better/Best positioning?
- [ ] Are disqualifying conditions in Section 12 aligned with our actual proposal practice?
- [ ] Is the SPF positioning (escalate for senior estimator review) accurate?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 2 (TPO), Chapter 3 (Silicone), and Chapter 10 (SPF)?
- [ ] Does the asbestos guidance reflect our current testing and abatement protocol?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's standard silicone, TPO, and cover board (fanfold/ISO) specifications for BUR recover work.
- Code-dependent items: California recover restrictions, Title 24 requirements for recover and replacement.
- Regional climate assumptions: 20–40+ year NorCal BUR field range. Verify with field experience.
- Asbestos protocol: confirm USA Flat Roof's testing, abatement partner relationships, and customer communication approach for pre-1980s buildings.
- Structural load: verify USA Flat Roof's process for confirming structural capacity before overlay proposals.
- Warranty-related statements.
- Company policy items: every [COMPANY POLICY] placeholder.
- SPF scope: confirm position on when SPF is escalated vs proposed, and link to Chapter 10.
- Cross-references to Chapters 2, 3, and 10 should be verified once those chapters are finalized.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 9 AND s.section_number = '22'
);

-- Part 1 / Ch 10 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Identify SPF roofs on sight and distinguish them from other flat-roof systems with similar appearance.
2. Explain what SPF is, how it's applied, and why USA Flat Roof installs it for specific applications.
3. Recognize the three primary SPF use cases — ponding correction, BUR recover after gravel removal, and insulation upgrade.
4. Inspect an SPF roof and classify common conditions on the Inspection Severity Scale.
5. Recommend SPF maintenance, recoat, repair, or replacement honestly based on roof condition.
6. Recognize when SPF is the right system and when one of the other USA Flat Roof options is better suited.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '1'
);

-- Part 1 / Ch 10 / Sec 2: Simple Overview
UPDATE sections SET
  content_markdown = $mfst$**Spray polyurethane foam** — almost always called **SPF** — is a roof system applied as a liquid spray that expands and cures into a rigid foam layer, then is protected with a top coating. SPF is unique among flat-roof systems in three important ways:

1. **It is sprayed in place**, conforming to whatever surface is underneath. Penetrations, corners, parapets, and irregular substrates are coated continuously without separate flashings.
2. **It is also the insulation.** SPF provides waterproofing *and* significant insulation R-value in a single application. No other flat-roof system does this.
3. **It can be tapered during application** to address drainage problems. SPF can be sprayed thicker at low spots and thinner at drains to create slope where the existing roof has none. This is the central advantage that makes SPF the right answer for ponding-water problems.

USA Flat Roof installs SPF for three primary use cases:

- **Ponding water correction** — when an existing flat roof has significant ponding that no recover or coating can address, SPF can be tapered to create drainage. This is often the single best reason to choose SPF.
- **BUR recover after gravel removal** — SPF is a strong alternative to TPO overlay on existing built-up roofs once the gravel has been swept and the substrate prepped.
- **Insulation upgrade** — SPF adds substantially more R-value per inch than fanfold board and competes with thicker ISO board, making it attractive when the building owner wants meaningful thermal improvement.

The SPF system always includes two components: the foam itself, and a **protective topcoat** (typically silicone or acrylic) that protects the foam from UV exposure. The foam alone is not the finished roof.

> **[CHECK MANUFACTURER]** SPF density, thickness, topcoat chemistry, mil thickness, and warranty terms vary by manufacturer and program tier. Confirm current product data sheets before quoting any specific scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '2'
);

-- Part 1 / Ch 10 / Sec 3: Where It's Commonly Used
UPDATE sections SET
  content_markdown = $mfst$- **Common applications:** flat and low-slope commercial roofs with drainage problems; existing BUR roofs being recovered; cold-storage facilities and other buildings with high insulation needs; roofs with complex penetration patterns where seamless coverage matters
- **Common in:** older commercial buildings being renovated, manufacturing and industrial facilities, refrigerated warehouses, certain food service facilities
- **Less common on:** residential, new commercial construction (where TPO and PVC dominate), structures where the building owner specifically prefers a single-ply system

In Northern California, SPF is encountered on commercial recover projects where ponding is a defining issue, on older industrial buildings, and on buildings where R-value upgrade matters to the owner. It's a smaller share of total roofing work than TPO or silicone, but it's the right answer often enough to deserve full sales-team attention.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '3'
);

-- Part 1 / Ch 10 / Sec 4: What It Looks Like + Recognition
UPDATE sections SET
  content_markdown = $mfst$### Visual identification

- Continuous, monolithic appearance — no seams, no fasteners, no separate flashings
- Surface texture is slightly **orange-peel** — a textured, dimpled look from the spray application that remains visible through the topcoat
- Color is whatever the topcoat is — most commonly white silicone (matching the silicone coating chapter)
- Foam wraps continuously over penetrations, parapet bases, curbs, and drains
- Visible thickness at edges where the foam terminates against walls or metal flashings

### Recognition by viewpoint

- **Drone or roof view:** continuous monolithic surface with visible orange-peel texture, no welded seams, no fastener rows. Smooth wrapping over all details.
- **Roof surface:** the orange-peel texture is the most reliable single indicator. Even with a topcoat, the underlying foam texture shows through.
- **Edges:** at parapet bases and roof edges, the foam thickness is often visible — a clue to the system's depth and confirmation that what you're looking at is foam, not coating alone.
- **Drains:** SPF wraps into the drain area; tapered installations show visible slope toward drains.
- **Interior leak evidence:** SPF leaks are unusual when the system is intact; when they happen, they often trace to topcoat failure exposing foam, or to penetrations where the original spray was not properly applied.

### How to distinguish SPF from coating-only systems

This is the critical recognition skill. A silicone-coated TPO roof and an SPF roof with a silicone topcoat can look similar from a distance.

| Indicator | SPF | Silicone over single-ply or BUR |
|---|---|---|
| Surface texture | Orange-peel from foam visible through topcoat | Smoother brush/spray texture without orange-peel |
| Edge appearance | Visible foam thickness at terminations | Coating-thickness only |
| Detail wrap | Continuous monolithic foam wrap | Coating wraps over original membrane substrate |
| Substrate visible at damaged areas | Yellow/tan rigid foam | Original membrane (white TPO, black BUR, etc.) |
| Drain area | Often shows tapered slope created by foam | Existing drain geometry preserved |

> **[SALES REP BOUNDARY]** Reps may identify a roof as "appears to be SPF" based on the orange-peel texture and visible thickness. Definitive identification requires documentation or substrate inspection at a damaged area.

[IMAGE #1]
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
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '4'
);

-- Part 1 / Ch 10 / Sec 5: Commonly Confused With
UPDATE sections SET
  content_markdown = $mfst$| Confused with | Key difference |
|---|---|
| **Silicone coating over TPO, BUR, or modified bitumen** | Coating-only systems have smoother surface texture without orange-peel. Edge thickness is much thinner than SPF. |
| **Acrylic-coated roof** | Same as silicone coating — coating chemistry doesn't change the underlying-system distinction. |
| **TPO with a coating refresh** | Welded seams visible under coating in some areas; no orange-peel. |
| **BUR with aluminum-pigmented coating** | Metallic silver appearance; gravel may be visible under thin coating; no orange-peel. |
| **Aged silicone restoration** | Sometimes reps confuse the slight texture of an old silicone coating with foam. The orange-peel of true SPF is more pronounced and the edge thickness is a reliable distinguisher. |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '5'
);

-- Part 1 / Ch 10 / Sec 6: Main Components
UPDATE sections SET
  content_markdown = $mfst$An SPF system is unusual among roof systems because it has fewer separate components. From the structure up:

1. **Roof deck** — wood, concrete, metal, or existing roof substrate (after prep). SPF can be applied over many substrates with appropriate prep.
2. **Substrate prep** — varies depending on what's underneath. Existing BUR requires gravel removal; existing single-ply may require cleaning and primer; bare deck requires its own prep.
3. **Primer** *(where required by manufacturer)* — promotes adhesion to certain substrates.
4. **SPF (the foam itself)** — sprayed on at specified thickness, expanding and curing in place. Thickness varies by application:
   - **Standard recover:** typically 1–1.5 inches
   - **Insulation-driven applications:** 2 inches or more
   - **Ponding correction:** variable, with thicker buildup at low spots
5. **Topcoat** — silicone or acrylic protective coating applied over the cured foam. The topcoat is essential — SPF foam without topcoat degrades rapidly under UV.
6. **Granules** *(optional in some systems)* — broadcast into wet topcoat for additional UV protection and walkability.
7. **Drains and scuppers** — preserved from the original system or modified during the SPF application.

> **[CHECK MANUFACTURER]** Foam density (typically 2.5–3.0 pounds per cubic foot for roofing applications), topcoat thickness, primer requirements, and recoat schedules vary by manufacturer and warranty tier.

[IMAGE #2]
Type: Cross-section
Priority: Required
Source preference: Custom diagram
Description: Labeled cross-section of an SPF system showing existing substrate (e.g., BUR with gravel removed), primer, foam at varying thickness for taper, topcoat, and a tapered drainage detail at a drain.
Purpose: Help reps visualize how SPF creates slope and provides insulation simultaneously.
Caption: Cross-section of an SPF system over an existing BUR substrate. Foam thickness is varied to create slope toward drains. Components shown are conceptual.
Alt text: Diagram showing layered SPF assembly with tapered foam thickness, topcoat, and drain detail.
Annotation needed: Yes — label substrate, primer, foam (with thickness variation noted), and topcoat.
Review status: Requires technical review before publication$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '6'
);

-- Part 1 / Ch 10 / Sec 7: How It's Installed
UPDATE sections SET
  content_markdown = $mfst$A typical SPF installation follows this general sequence. This overview is for awareness only — not an installation specification.

1. **Inspection and substrate qualification** — confirm substrate is sound and SPF-appropriate.
2. **Substrate prep** — varies by substrate. For BUR recover: gravel removal, surface preparation, repair of any failures. For existing single-ply: cleaning, removal of incompatible coatings, primer. For ponding correction over any substrate: drainage analysis to plan the taper.
3. **Drainage and taper planning** — for ponding-correction projects, the spray application is planned in advance to create proper slope toward drains.
4. **Primer application** *(where required)* — manufacturer-specified primer applied to promote adhesion.
5. **Foam application** — two-component spray equipment combines the chemicals at the gun, producing foam that expands and cures within seconds. Applied in passes, with care to maintain consistent thickness or planned taper.
6. **Inspection of foam** — visual check for voids, irregular thickness, or surface defects. Cured foam must be sound before topcoat application.
7. **Topcoat application** — silicone or acrylic topcoat sprayed over the cured foam at specified mil thickness.
8. **Optional granule broadcast** — granules embedded in wet topcoat for added UV protection and walkability.
9. **Cure period** — topcoat cure time depends on chemistry and conditions.
10. **Final inspection and warranty registration** — photos, application data, manufacturer submission.

> **[CHECK MANUFACTURER]** Equipment, mix ratios, ambient temperature limits, and weather windows are product-specific and project-specific. SPF is sensitive to wind during application — overspray of foam onto adjacent buildings, vehicles, and surfaces is a real and serious concern that crews must manage actively.

> **[VERIFY LOCALLY]** California Title 24 requirements affect topcoat color and reflectivity. Local jurisdiction may have wind, fire, or insulation requirements relevant to SPF projects.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '7'
);

-- Part 1 / Ch 10 / Sec 8: Expected Lifespan
UPDATE sections SET
  content_markdown = $mfst$SPF lifespan is unusual because the system has two components that age differently:

- **The foam itself** is extremely long-lived when protected from UV. Foam in good condition under an intact topcoat can last 25–30+ years.
- **The topcoat** is the wear layer and requires periodic recoating — typically every **10–15 years** depending on topcoat chemistry, thickness, and conditions.

This creates a maintenance pattern unique to SPF: the topcoat is recoated periodically while the foam continues to perform. A well-maintained SPF roof with periodic topcoat refreshes can have a service life that exceeds most other flat-roof systems.

- **Industry rating range:** Manufacturer warranties commonly run 10, 15, or 20 years on the system depending on topcoat, mil thickness, and contractor program.
- **Real-world field range:** with periodic topcoat recoats, the foam can perform for **25–30+ years**. Without recoats, exposed or thin topcoat allows UV degradation of foam, shortening total service life.
- **Factors that shorten lifespan:** missed topcoat recoats, mechanical damage, bird and rodent damage to exposed foam, hail damage, inadequate original foam application.
- **Factors that extend lifespan:** regular inspection, on-schedule topcoat recoats, prompt repair of any topcoat damage, walk pads at high-traffic areas.

> **[VERIFY LOCALLY]** NorCal climate variation affects SPF and topcoat aging. Confirm specific patterns with field experience.

### What reps must NOT promise
- Specific service-life numbers
- Outcomes contingent on customer maintenance and topcoat recoat schedule
- Warranty payouts on systems with missed recoats
- That SPF is "permanent" — it isn't

### Suggested customer language
> "An SPF system has two parts that age differently. The foam itself is very long-lived — 25 years or more — when it's protected from UV. The topcoat is the wear layer and gets recoated periodically, typically every 10 to 15 years. Done right, with regular topcoat refreshes, this is one of the longest-lived flat-roof systems available. Skip the recoats, though, and the foam degrades."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '8'
);

-- Part 1 / Ch 10 / Sec 9: Strengths
UPDATE sections SET
  content_markdown = $mfst$- **Solves drainage problems** — SPF can be tapered during application to create slope where the existing roof has none. This is the unique advantage that no recover, coating, or single-ply replacement matches cost-effectively.
- **Combines waterproofing and insulation** — significant R-value per inch (more than ISO board per inch in most applications).
- **Monolithic, seamless coverage** — no fasteners, no seams, no separate flashings to fail.
- **Conforms to irregular substrates** — wraps continuously around penetrations, curves, and complex geometry.
- **Long service life with periodic maintenance** — the foam itself can outlast most other flat-roof systems when topcoat is maintained.
- **Lightweight** — SPF adds far less weight than ISO board plus single-ply, important on buildings with structural capacity concerns.
- **Adheres to many substrates** with appropriate prep — BUR, single-ply, concrete, wood, metal.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '9'
);

-- Part 1 / Ch 10 / Sec 10: Limitations & Trade-offs
UPDATE sections SET
  content_markdown = $mfst$- **Weather-sensitive application** — wind is a major concern. Overspray onto adjacent buildings, vehicles, and surfaces is a real risk that requires active crew management. Some sites and conditions are not suitable for SPF application.
- **Requires periodic topcoat recoat** — unlike TPO or single-ply, SPF cannot be installed and forgotten. The maintenance commitment is real.
- **Substrate-sensitive** — SPF requires a sound, prepared substrate. Wet insulation, severe substrate failure, or asbestos-containing materials still need to be addressed before SPF goes on.
- **Damage shows quickly** — small punctures or topcoat scrapes expose foam to UV; damage propagates faster than on single-ply systems if not promptly repaired.
- **Crew expertise matters significantly** — SPF installation quality varies widely between crews. Voids, inconsistent thickness, and poor cure can shorten service life dramatically.
- **Bird and rodent vulnerability** — exposed foam (after topcoat damage) can be damaged by wildlife. Coastal NorCal seagull activity is a real consideration.
- **Removal is more difficult** than mechanically attached systems if the building owner later decides to replace.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '10'
);

-- Part 1 / Ch 10 / Sec 11: Common Problems & Failure Modes
UPDATE sections SET
  content_markdown = $mfst$| Condition | Severity | What it looks like |
|---|---|---|
| Surface dirt and biological staining on topcoat | Monitor → Maintenance | Surface darkening; topcoat may still be fully functional |
| Topcoat chalking | Maintenance | Powdery white residue; recoat planning indicator |
| Topcoat thinning or wear | Maintenance → Repair | Visible reduction in topcoat coverage; foam may be visible in wear areas |
| Topcoat damage exposing foam | Repair → Urgent | Yellow/tan foam visible at scrapes, punctures, or impact areas |
| Foam UV degradation (exposed foam) | Repair → Urgent | Foam darkening, surface deterioration, friability — happens quickly when foam is exposed |
| Bird or rodent damage | Repair | Pecked, gnawed, or excavated areas in foam |
| Hail damage | Repair → Urgent | Impact craters in foam visible through topcoat |
| Foam voids (installation defect) | Repair → Urgent | Hollow or air-filled areas under topcoat; sometimes detectable by tap test |
| Topcoat blistering | Repair | Raised bubbles indicating moisture or substrate issues |
| Failed detail at penetration | Repair | Cracking or pulling at drain rings, pipe penetrations, or curbs |
| Wet substrate beneath SPF (rare but serious) | Urgent | Soft underfoot; widespread topcoat blistering; suggests pre-existing condition not addressed before SPF application |
| Active interior leak | Urgent | Often indicates topcoat damage, foam compromise, or pre-existing substrate issue |

> **[SALES REP BOUNDARY]** Reps document conditions and apply the severity scale. They do not certify topcoat thickness, foam density, void presence, or root cause of leaks without senior review.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '11'
);

-- Part 1 / Ch 10 / Sec 12: Field Inspection Guide
UPDATE sections SET
  content_markdown = $mfst$SPF inspection differs from other flat-roof systems because the foam and topcoat are inspected separately.

### Building exterior walk-around
- Photograph all four elevations
- Note parapet condition, scuppers, downspouts

### Roof surface — general
- Photograph each quadrant of the roof
- Note overall topcoat condition: color, dirt, chalking, biological staining
- Note any areas where foam is visible through worn or damaged topcoat
- Note walk pad coverage if present

### Topcoat-specific inspection
- Look for chalking (rub a finger on the surface)
- Look for thin or worn areas, particularly at walk paths and near equipment
- Photograph any topcoat damage with reference scale
- Note coverage at penetrations, parapets, and details

### Foam-specific inspection
- Look for any exposed foam — yellow/tan color visible
- Note any visible foam degradation: darkening, surface deterioration, friability
- Note any bird or rodent damage
- Note any obvious impact damage or punctures

### Drainage assessment
- Photograph every drain and scupper
- Note ponding extent — **this is critical on SPF roofs because drainage is often why SPF was installed in the first place**
- Note whether tapered drainage from the original SPF application is still functioning

### Detail and penetration inspection
- Photograph every penetration, drain, curb, and termination
- Note any cracking or pulling at high-stress areas
- Note any sealant repairs or unauthorized work

### Substrate inspection
- Note any walk-test soft areas suggesting wet insulation or substrate failure
- Note any visible settlement or deflection

### Documentation
- Original SPF installation date if known
- Last topcoat recoat date if known
- Maintenance history
- Previous repair records

### Red flags requiring immediate escalation

- Active interior leak
- Soft / spongy underfoot
- Visible structural deflection
- Widespread topcoat failure exposing foam
- Widespread foam degradation
- Suspected installation voids (production team or qualified inspector required for assessment)
- Bird or rodent damage requiring biological remediation
- Solar array on the SPF roof — coordination needed for any work
- Customer requesting SPF over a substrate the rep believes does not qualify$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '12'
);

-- Part 1 / Ch 10 / Sec 13: Recommendation Options
UPDATE sections SET
  content_markdown = $mfst$Recommendation logic on existing SPF roofs is different from logic on other flat-roof systems. The relevant options:

### Topcoat recoat (maintenance — most common SPF recommendation)

**When it fits:**
- SPF system in serviceable condition
- Topcoat is approaching end of its service window (chalking, thinning, biological staining)
- No exposed foam or limited exposed foam areas
- No widespread substrate or foam issues

**Scope:**
- Detail repairs at any topcoat damage
- Cleaning to remove dirt and biological growth
- Topcoat recoat at specified mil thickness
- Documentation and warranty extension where program supports

**What reps must explain:**
- This is the standard SPF maintenance pattern, not an emergency repair
- Recoat extends service life; the foam underneath continues performing
- Future recoats will follow on a schedule — typical 10–15 year cycle

### Repair

**When it fits:**
- Localized topcoat damage with foam exposure
- Single penetration failure
- Minor impact damage

**Scope:**
- Foam repair if foam itself is damaged
- Topcoat patch and integration with existing topcoat
- Detail repair as needed

### Recover or replacement

**When it fits:**
- Widespread topcoat failure with extensive foam degradation
- Substrate or insulation issues beneath the SPF
- End-of-life system requiring full replacement
- Rare on properly maintained SPF — usually indicates years of deferred topcoat maintenance

**Scope:**
- Depends on findings — may involve foam removal, substrate work, and a new system entirely

### When SPF is the right answer for a *new* project (not existing SPF)

This is the more common sales scenario for USA Flat Roof. The Good/Better/Best framework from the BUR chapter (Chapter 9) applies, with SPF entering as a fourth option specifically when:

**SPF beats silicone restoration:**
- The roof has significant ponding that needs correction
- The customer wants meaningful R-value improvement (silicone adds none)
- Substrate condition makes SPF preferable for adhesion or coverage

**SPF beats TPO overlay:**
- The roof has significant ponding (TPO overlay does not correct slope)
- The customer wants R-value beyond what fanfold provides, and the cost of thick ISO board approaches SPF
- Substrate is irregular enough that monolithic foam coverage is meaningfully better than mechanically attached membrane

**SPF beats full replacement:**
- Building is in good condition otherwise; full tear-off is not necessary
- Customer wants to avoid the disruption of a tear-off project
- Code permits SPF as recover (single existing layer, no asbestos issues, structural adequacy)

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific criteria for proposing SPF, including ponding thresholds, R-value targets, and substrate requirements.

### The honest-versus-easy moment on SPF

SPF is a strong product for the right situation, but it has real limitations that reps must communicate honestly:

- **SPF requires periodic topcoat recoats.** Customers who don't want to budget for periodic maintenance will be unhappy with SPF over time.
- **Wind-sensitive application means some sites can't have SPF installed reliably.** A tight urban site adjacent to occupied buildings and parked vehicles may not be a good SPF candidate even when the roof is otherwise ideal.
- **SPF is more vulnerable to mechanical damage than single-ply.** Buildings with frequent rooftop traffic from other trades may be better served by TPO.

The temptation is to propose SPF for every drainage-challenged roof regardless of these factors. The right call is to assess the full project context — site conditions, customer maintenance commitment, traffic patterns — before proposing SPF.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '13'
);

-- Part 1 / Ch 10 / Sec 14: Warranty Reality
UPDATE sections SET
  content_markdown = $mfst$SPF warranty structure is similar to other flat-roof systems but with two distinctive elements:

- **Manufacturer system warranty** — covers the SPF and topcoat assembly when installed by certified contractors. Length and tier vary.
- **Workmanship (contractor) warranty** — covers the application.
- **Topcoat recoat requirement** — many SPF system warranties require periodic topcoat recoats to remain valid. Missing the recoat schedule can void the warranty.

### What commonly voids or limits warranties
- Missed topcoat recoats per the manufacturer's schedule
- Damage from foot traffic without protection
- Damage from other trades not properly repaired
- Modifications without manufacturer-approved details
- Substrate failures that pre-existed the SPF installation
- Environmental damage outside warranty terms (extreme hail, etc.)

### What reps must not promise
- That a long warranty length means a long guaranteed service life regardless of maintenance
- That the warranty covers substrate failures
- That future recoat costs are included in the original warranty
- Specific outcomes for damage caused by other trades or weather events

> **[COMPANY POLICY]** Placeholder — USA Flat Roof SPF manufacturer certifications, warranty tier offerings, and standard workmanship terms.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '14'
);

-- Part 1 / Ch 10 / Sec 15: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Simple customer explanation

> "SPF is a sprayed-on foam roof system. It does two things at once: it waterproofs the roof and it insulates the building. The foam is sprayed in place, conforming to whatever's underneath, and it's protected by a topcoat. The unique advantage is that we can spray it thicker in low spots and thinner near drains, which means we can build slope into your roof during installation. For a building with chronic ponding, that's the only real solution short of tearing off the whole roof and rebuilding the deck slope."

### Talking points

1. SPF is the right answer when ponding is the defining problem. No other recover or coating option corrects slope cost-effectively.
2. SPF does two jobs in one application: waterproofing and insulation. For a building owner who wants meaningful R-value improvement, that's a significant advantage.
3. The system has two components — foam and topcoat — that age differently. Periodic topcoat recoats are part of owning an SPF roof.
4. Weather and site conditions matter more for SPF than for other systems. Wind during application is a real concern — we'll evaluate the site honestly before proposing SPF.
5. We install SPF when it's the right answer, not because it's the most profitable option. For roofs without ponding or insulation needs, TPO or silicone restoration is usually the better fit.

### FAQ

- **Q: Does SPF actually fix ponding?** A: Yes, when applied correctly. We taper the foam during application — thicker at low spots, thinner near drains — to build slope into the roof. That's something no other recover system does.
- **Q: How long will it last?** A: The foam itself can last 25 years or more when the topcoat is maintained. The topcoat needs recoating periodically — typically every 10 to 15 years. With on-schedule topcoat refreshes, this is one of the longest-lived systems available. Skip the recoats and the foam degrades.
- **Q: How much insulation does SPF add?** A: Significant R-value, more per inch than ISO board in most applications. We'll calculate the specific R-value for your project based on the foam thickness in the specification.
- **Q: Can SPF be installed in any weather?** A: No. Wind is the biggest concern — overspray onto adjacent buildings or vehicles is a real risk we have to manage actively. Some sites and weather conditions don't work for SPF. We'll evaluate honestly and tell you if the site is a good candidate.
- **Q: What happens if a tree branch falls on the roof and damages it?** A: The damage is repaired with foam and topcoat patching. SPF is repairable, similar to single-ply systems. The key is repairing damage promptly — exposed foam degrades quickly under UV.
- **Q: Why not just do TPO overlay?** A: TPO overlay is a great option when ponding isn't the issue and you don't need significant insulation upgrade. For roofs with ponding or buildings that want meaningful R-value, SPF is often the better answer. We'll walk through both options.
- **Q: Is SPF good for my building?** A: That depends on the building's roof condition, drainage, insulation needs, and site conditions. SPF is the right answer for some projects and not for others. We'll inspect and tell you honestly which option fits.

### Objections & Responses

- **"I've heard SPF is expensive."** A: SPF can carry a premium per square foot, but the comparison depends on what alternative you're comparing it to. If ponding correction would otherwise require deck-level structural work or full tear-off-and-rebuild, SPF is often the more economical answer. If you don't have ponding and don't need insulation upgrade, TPO overlay or silicone restoration are usually less expensive.
- **"Birds will damage the foam."** A: Bird damage to exposed foam is a real concern, but it's almost always damage to topcoat-failed areas where foam is already vulnerable. With on-schedule topcoat maintenance, the foam stays protected. Coastal NorCal sites with significant seagull activity warrant some additional consideration — we'll discuss that if it applies.
- **"My neighbor had SPF and it failed."** A: That happens, and it almost always traces to one of three causes: skipped topcoat recoats, poor original installation (voids, thin areas), or substrate issues that should have been addressed before the foam went on. We can walk through what we'd be doing differently.
- **"I just want the cheapest option."** A: That's a fair priority, and we'll be honest with you. If your roof doesn't have ponding and doesn't need insulation upgrade, SPF probably isn't the most economical choice — TPO overlay or silicone restoration would likely be. SPF is the right answer when its specific advantages match your roof.
- **"I don't want a maintenance commitment."** A: That's important to know up front. SPF does require periodic topcoat recoats — typically every 10 to 15 years — to perform as designed. If a no-maintenance system is your priority, TPO overlay or full replacement may fit better than SPF.

### Common sales mistakes (do not do)

- Quoting a specific lifespan number
- Recommending SPF without confirming ponding, R-value need, or substrate fit
- Failing to disclose the topcoat recoat schedule and maintenance commitment
- Recommending SPF on a windy site adjacent to occupied buildings or vehicles without addressing site risk
- Promising "no maintenance" — SPF requires real maintenance
- Promising warranty outcomes without reading the actual warranty
- Recommending SPF over substrates that don't qualify (wet insulation, multi-layer roofs, asbestos) without escalation
- Talking down TPO or silicone alternatives — both are right answers for different applications$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '15'
);

-- Part 1 / Ch 10 / Sec 16: Proposal Language Examples
UPDATE sections SET
  content_markdown = $mfst$**SPF for ponding correction:**
> Based on inspection, the existing roof has significant ponding water that no recover or coating system can address by adding mass. SPF is recommended to correct slope through tapered application during installation. Recommended scope: substrate prep, primer application, SPF tapered to manufacturer-specified thickness with low spots built up to direct water toward drains, silicone topcoat at specified mil thickness, and warranty registration. Periodic topcoat recoats required to maintain warranty and service life. **[CHECK MANUFACTURER]** Confirm foam density, thickness specifications, topcoat chemistry, and warranty terms.

**SPF over BUR after gravel removal:**
> Existing single-layer BUR roof qualifies for SPF recover. Recommended scope: gravel sweep and removal, substrate prep including detail repairs, primer application as required, SPF application at specified thickness for [recover / R-value upgrade / ponding correction], silicone topcoat at specified mil thickness, and warranty registration. Workmanship and manufacturer warranty per program. **[VERIFY LOCALLY]** Code permission for recover and structural load capacity confirmed.

**SPF for insulation upgrade:**
> Existing roof qualifies for SPF recover with insulation upgrade. Recommended scope: substrate prep, primer application, SPF at [thickness] inches providing approximately R-[value] of additional insulation, silicone topcoat, and warranty registration. R-value improvement subject to manufacturer-specified foam density and thickness. **[CHECK MANUFACTURER]** Confirm foam density and R-value calculation against current product documentation.

**Topcoat recoat (maintenance):**
> Existing SPF roof in serviceable condition with topcoat approaching end of service window. Recommended scope: detail repairs at any topcoat damage, cleaning, and full topcoat recoat at specified mil thickness. The recoat extends service life of the underlying foam, which continues to perform. Next recoat anticipated in approximately 10–15 years per manufacturer schedule. **[CHECK MANUFACTURER]** Confirm topcoat compatibility with existing system.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '16'
);

-- Part 1 / Ch 10 / Sec 17: Field Photo & Documentation Checklist
UPDATE sections SET
  content_markdown = $mfst$**Photos required for every SPF inspection:**

- All four building elevations
- Each quadrant of the roof from elevated view
- Topcoat condition close-ups (multiple areas)
- Any exposed foam areas with reference scale
- Any visible foam damage or degradation
- Every penetration, drain, scupper, and skylight
- Every parapet and termination detail
- Any ponding evidence (chalk outline preferred)
- Walk pad coverage and condition
- Interior leak evidence if reported

**Documentation to gather:**

- Original SPF installation date
- Topcoat recoat history
- Maintenance and repair history
- Original spec if available — foam thickness, topcoat chemistry, mil thickness

**Severity rating** applied to each documented condition.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '17'
);

-- Part 1 / Ch 10 / Sec 18: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active interior leak with unknown source
- Soft / spongy underfoot
- Visible structural deflection or sagging deck
- Widespread topcoat failure exposing foam
- Widespread foam degradation
- Suspected installation voids
- Substrate condition uncertain (BUR layer count, asbestos potential, wet insulation)
- Site conditions that may disqualify SPF application (wind, adjacent occupied buildings, parking lot exposure)
- Customer requesting SPF over a substrate that doesn't qualify
- Code or jurisdictional questions
- Solar array on the roof
- Suspected hail or storm damage with insurance involvement
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '18'
);

-- Part 1 / Ch 10 / Sec 19: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our preferred SPF manufacturer(s) and certifications: [placeholder]
> - Our standard foam density and thickness specifications by application: [placeholder]
> - Our standard topcoat chemistry, mil thickness, and warranty tiers: [placeholder]
> - Our criteria for proposing SPF — ponding thresholds, R-value targets, substrate qualification: [placeholder]
> - Our site evaluation procedure for wind risk and adjacent structures: [placeholder]
> - Our topcoat recoat schedule and maintenance program offerings: [placeholder]
> - Our escalation rules and contacts: [placeholder]
> - Our standard proposal options: [placeholder]
> - Our workmanship warranty language: [placeholder]
> - Our sales-to-production handoff process for SPF projects: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '19'
);

-- Part 1 / Ch 10 / Sec 20: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They miss that SPF requires periodic topcoat maintenance — and let customers think it's a one-and-done system.
- They confuse SPF with silicone-coated single-ply systems because both can have white silicone topcoats.
- They underestimate site conditions for SPF — wind, adjacent structures, vehicles.
- They don't recognize when SPF is the wrong answer (tight urban sites, no ponding, no R-value need).
- They don't recognize when SPF is uniquely the right answer (ponding correction is the clearest case).
- They confuse "SPF foam thickness" with "topcoat thickness" — different specifications, different roles.
- They underestimate how quickly foam degrades when topcoat is compromised.

**Discussion questions for group training**
- Walk through the three primary SPF use cases. For each, what's the next-best alternative and what would push you toward SPF instead?
- A customer with chronic ponding asks why TPO overlay won't fix the ponding. What's your answer?
- A customer asks for SPF on a tight urban site adjacent to a parking lot. How do you handle the conversation?
- What's the 30-second answer to "doesn't SPF require maintenance forever?"
- An existing SPF roof shows topcoat thinning but no foam exposure. What's the right recommendation?

**Field exercises**
- Pair up. Review three sets of inspection photos. Distinguish SPF from silicone-coated TPO and from silicone-coated BUR. Apply severity ratings.
- Walk a real SPF roof together. Have the trainee identify the foam vs topcoat condition separately.
- Practice the SPF site-evaluation conversation — when is SPF appropriate, when is it not.
- Practice the recoat maintenance conversation with an existing-SPF customer.

**What the manager should test verbally**
- Distinguish SPF from silicone-coated single-ply or BUR.
- Name the three primary use cases for SPF.
- Explain the foam-vs-topcoat aging distinction in customer language.
- Walk through a recommendation conversation for a roof with significant ponding (SPF) versus a roof without ponding (TPO overlay).
- State five things a rep must not promise about SPF.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '20'
);

-- Part 1 / Ch 10 / Sec 21: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Foam density** — pounds per cubic foot, typically 2.5–3.0 for roofing applications.
- **Granule broadcast** — embedding granules in wet topcoat for added UV protection and walkability.
- **Monolithic** — single continuous seamless layer; characteristic of SPF coverage.
- **Orange-peel texture** — characteristic surface texture of cured SPF, visible through topcoat.
- **R-value** — insulation rating; higher numbers indicate better thermal resistance.
- **SPF (spray polyurethane foam)** — sprayed-in-place foam roof system providing waterproofing and insulation.
- **Tapered application** — varying foam thickness during application to create slope; the unique advantage for ponding correction.
- **Topcoat** — protective coating (typically silicone or acrylic) applied over cured SPF; required for UV protection.
- **Topcoat recoat** — periodic reapplication of topcoat to maintain UV protection over the foam; defining maintenance pattern of SPF systems.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '21'
);

-- Part 1 / Ch 10 / Sec 22: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Spray polyurethane foam (SPF) is a roof system applied as a liquid spray that expands and cures into a rigid foam layer protected by a silicone or acrylic topcoat. SPF is unique in three ways: it's sprayed in place and conforms to any substrate; it provides waterproofing and significant insulation R-value in one application; and it can be tapered during application to correct ponding water. USA Flat Roof installs SPF for three primary use cases: ponding correction, BUR recover after gravel removal, and insulation upgrade. The system has two components that age differently — the foam itself can last 25+ years when topcoat is maintained, while the topcoat requires periodic recoating every 10–15 years. SPF is not a one-and-done system; the maintenance commitment is real and must be communicated honestly. Reps should not propose SPF without confirming ponding, R-value need, or substrate fit; should not recommend SPF on tight urban sites without addressing wind risk; and should escalate any uncertainty about substrate condition or installation feasibility. SPF is the right answer when its unique advantages match the project — and TPO overlay or silicone restoration is the right answer when they don't.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '22'
);

-- Part 1 / Ch 10 / Sec 23: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** "SPF" stands for:
A. Spray polymer foam
B. Spray polyurethane foam
C. Sprayed plastic film
D. Silicone-protected foam

**2. (Beginner)** What two roles does SPF perform in one application?
A. Waterproofing and insulation
B. Waterproofing and structural support
C. Insulation and ventilation
D. Decoration and waterproofing

**3. (Beginner)** The protective layer applied over cured SPF foam is called:
A. The base sheet
B. The topcoat
C. The cap sheet
D. The flashing

**4. (Beginner)** What characteristic surface texture identifies SPF?
A. Smooth factory finish
B. Granular surface
C. Orange-peel texture
D. Welded seams

**5. (Intermediate)** USA Flat Roof's three primary use cases for SPF are:
A. Residential roofs, decorative roofs, and metal recover
B. Ponding water correction, BUR recover after gravel removal, and insulation upgrade
C. Steep-slope shingle replacement, parapet flashing, and chimney work
D. Emergency leak repair, attic ventilation, and skylight installation

**6. (Intermediate)** A customer asks how long an SPF roof will last. The most accurate response includes which of the following points?
A. The foam can last 25+ years when the topcoat is maintained; the topcoat requires periodic recoats typically every 10–15 years
B. SPF lasts forever and requires no maintenance
C. SPF lasts 5 years before complete replacement is required
D. SPF lifespan is identical to TPO

**7. (Intermediate)** A roof has significant chronic ponding. The customer wants the most cost-effective long-term solution. SPF is most likely the right answer because:
A. It is the cheapest option
B. It can be tapered during application to correct slope, which other recover systems cannot do cost-effectively
C. It has the longest warranty
D. It looks the most attractive

**8. (Intermediate)** A customer's existing SPF roof shows topcoat thinning and chalking but no exposed foam. The most appropriate recommendation is:
A. Full SPF removal and replacement
B. Switch to TPO overlay
C. Topcoat recoat per the standard maintenance schedule
D. No action; continue monitoring

**9. (Advanced)** A customer wants SPF installed on a tight urban site adjacent to occupied buildings, a parking lot, and street parking. The most appropriate response is:
A. Quote the SPF project as requested
B. Decline the project without explanation
C. Escalate for senior estimator review of site conditions; explain that wind risk and adjacent property exposure may disqualify SPF and that alternatives (TPO overlay, silicone restoration) may be better suited
D. Propose silicone restoration without inspection

**10. (Advanced)** A customer says "I don't want any maintenance commitments — just a roof that lasts." The most honest response is:
A. Recommend SPF and minimize the maintenance discussion
B. Explain that SPF does require periodic topcoat recoats, and a maintenance-free system isn't realistic for any flat roof, but if minimal maintenance is the priority, TPO overlay or full replacement may fit better than SPF
C. Recommend SPF with a longer warranty
D. Recommend SPF and tell the customer the warranty covers all maintenance

---

### Answer Key

1. **B — Spray polyurethane foam.** Standard chemistry name.
2. **A — Waterproofing and insulation.** Defining feature of SPF among flat-roof systems.
3. **B — The topcoat.** Required for UV protection.
4. **C — Orange-peel texture.** The most reliable single visual indicator of SPF.
5. **B — Ponding water correction, BUR recover after gravel removal, and insulation upgrade.** Specific to USA Flat Roof's positioning.
6. **A — Foam can last 25+ years with topcoat maintained; topcoat requires periodic recoats every 10–15 years.** This is the honest framework. (B) overstates; (C) understates; (D) is wrong.
7. **B — It can be tapered during application to correct slope.** Unique advantage. Cost (A) is not the reason; warranty (C) and appearance (D) are not the reason.
8. **C — Topcoat recoat per the standard maintenance schedule.** This is the standard SPF maintenance pattern. Removal (A) is unnecessary; switching systems (B) overshoots; no action (D) leaves the foam vulnerable as topcoat continues to thin.
9. **C — Escalate for senior estimator review; explain wind risk and adjacent property exposure may disqualify SPF.** This is the honest response. Quoting without evaluation (A) ignores real risk. Declining without explanation (B) abandons the customer. Recommending silicone without inspection (D) skips the analysis.
10. **B — SPF requires periodic recoats; if minimal maintenance is the priority, TPO overlay or replacement may fit better.** This is the honest answer. (A) hides the maintenance commitment; (C) doesn't address the actual concern; (D) misrepresents warranty coverage.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '23'
);

-- Part 1 / Ch 10 / Sec 24: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for Northern California commercial market?
- [ ] Accurate for the SPF products and systems USA Flat Roof installs?
- [ ] Matches USA Flat Roof manufacturer certifications and warranty tier offerings?
- [ ] Matches USA Flat Roof workmanship warranty language for SPF?
- [ ] Are the three primary use cases (ponding, BUR recover, insulation) aligned with our actual sales practice?
- [ ] Is the topcoat recoat schedule (10–15 years) accurate for our typical specifications?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 9 (BUR), Chapter 3 (Silicone), and Chapter 2 (TPO)?
- [ ] Does the site evaluation guidance (wind, adjacent structures) match our current practice?

**Technical Items to Verify Before Publishing**

- Manufacturer-specific items: confirm USA Flat Roof's primary SPF manufacturer(s) and certification programs. Insert specific foam density and topcoat thickness standards.
- Code-dependent items: California Title 24 cool-roof requirements, fire ratings, recover restrictions, and structural load.
- Regional climate assumptions: NorCal field range for foam (25+ years with topcoat maintenance) and topcoat (10–15 years). Verify with USA Flat Roof field experience.
- Site evaluation procedure: confirm USA Flat Roof's practice for evaluating wind risk, adjacent properties, and overspray management.
- R-value claims: confirm typical R-value calculations for standard SPF thicknesses USA Flat Roof installs.
- Topcoat recoat schedule and warranty: confirm requirements per USA Flat Roof's standard programs.
- Bird and rodent damage handling: confirm USA Flat Roof's approach in coastal versus inland NorCal markets.
- Cross-references to Chapters 2 (TPO), 3 (Silicone), and 9 (BUR) should be verified once those chapters are finalized.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1 AND c.chapter_number = 10 AND s.section_number = '24'
);

-- Single INSERT capturing all in-scope audit rows.
-- previous_content comes from the temp table populated above (pre-UPDATE values).
-- new_content reads from sections live, which now reflects the post-UPDATE bodies.
INSERT INTO content_revisions (
  section_id, edited_by, previous_content, new_content, edit_note, edited_at
)
SELECT
  ip.section_id,
  (SELECT id FROM profiles WHERE email = 'ikuniversal@gmail.com'),
  ip.previous_content,
  s.content_markdown,
  'Imported from April 2026 source manuscript',
  NOW()
FROM _import_previous ip
JOIN sections s ON s.id = ip.section_id;

-- Defensive safety check: verify exactly N sections in scope are now populated.
-- If any UPDATE silently no-op'd (e.g. lookup subquery returned no rows),
-- the count below will be wrong and the RAISE EXCEPTION rolls back the
-- entire transaction. This catches generator bugs, schema drift, and any
-- partial-state hazard before COMMIT.
DO $$
DECLARE
  populated_count integer;
BEGIN
  SELECT COUNT(*) INTO populated_count
  FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 1
    AND s.content_markdown != ''
    AND s.content_markdown IS NOT NULL;
  IF populated_count != 227 THEN
    RAISE EXCEPTION 'Phase B import safety check failed (Part 1 only): expected 227 populated sections, found %. Transaction rolled back.', populated_count;
  END IF;
END $$;

COMMIT;
