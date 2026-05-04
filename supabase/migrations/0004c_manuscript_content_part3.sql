-- Phase B content import: manuscript bodies -> sections.content_markdown (Part 3 only)
-- Source: data/manuscript/extracted-content.json
-- Scope: Part(s) 3, 176 sections
-- Companion to scripts/extract-and-import-content.ts (the live equivalent).
-- Atomicity: single transaction. Either all in-scope sections update + their
-- content_revisions rows insert, or nothing changes (defensive count check
-- before COMMIT raises and rolls back if the post-import populated count is
-- not exactly 176).
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
WHERE p.part_number = 3;

-- 176 UPDATE statements: one per manuscript section.
-- Subquery resolves section.id by (part_number, chapter_number, section_number).
-- Each UPDATE writes the manuscript body and bumps updated_at.

-- Part 3 / Ch 1 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Roof age comes up on almost every inspection. The customer wants to know how old their roof is, how old it should be, and how much life is left. Reps who handle this conversation poorly create problems in three directions:

- **Quoting specific lifespan numbers** ("you've got about 7 years left") sets up the customer to feel cheated when the roof underperforms or overperforms that prediction
- **Using age as the only diagnostic factor** ("the roof is 18 years old, so it needs replacement") misses condition-driven realities and leads to overselling and underselling in equal measure
- **Avoiding the age conversation** because it feels uncomfortable forfeits the chance to set realistic expectations and frame the recommendation honestly

This module gives reps a consistent way to talk about age across systems — one that builds trust and keeps the conversation grounded in observable conditions.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '1'
);

-- Part 3 / Ch 1 / Sec 2: What Roof Age Actually Tells You
UPDATE sections SET
  content_markdown = $mfst$Roof age is one data point. It's useful, but it doesn't determine condition on its own.

Two roofs of the same age, in the same neighborhood, with the same shingles, can be in radically different condition because of:

- Ventilation
- Slope orientation (south- and west-facing slopes age faster in inland NorCal)
- Tree cover and debris exposure
- Original installation quality
- Maintenance history
- Storm and hail exposure
- Foot traffic and damage from other trades

A 12-year-old roof can look like a 5-year-old roof. A 12-year-old roof can also look like a 20-year-old roof. Age sets the *expectation range*; condition sets the *actual answer*.

The honest framing for reps: **age is the question, condition is the answer.**$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '2'
);

-- Part 3 / Ch 1 / Sec 3: What Reps Must NOT Do
UPDATE sections SET
  content_markdown = $mfst$- **Quote specific remaining-life numbers.** "Your roof has 7 more years" is the textbook fake-precision violation. Reps don't have a remaining-life algorithm.
- **Treat manufacturer warranty length as lifespan.** A 30-year shingle is not a 30-year roof. (See Chapter 1.)
- **Use age alone as a recommendation driver.** "You're at 18 years, so you need replacement" skips the condition lens.
- **Tell customers their roof is "shot" or "done" based on age alone.** Reps inspect; reps don't pronounce.
- **Promise an exact match between current age and expected service.** Field range is wide.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '3'
);

-- Part 3 / Ch 1 / Sec 4: The Honest Customer Language
UPDATE sections SET
  content_markdown = $mfst$The structure that works across systems:

> "[System type] in this area commonly performs in the range of about [low] to [high] years, depending on ventilation, exposure, and maintenance. Your roof is at [age range]. Based on what we're seeing on it today, here's what we'd expect…"

Three things this language does:
1. Uses a range, not a number
2. Acknowledges variables that drive variation
3. Anchors the answer to what the rep observed, not to age alone

### Sample by system

**Composition shingle:**
> "Architectural shingles in NorCal commonly perform in the range of about 18 to 25 years, depending on ventilation, exposure, and maintenance. Your roof is at about 14 years. Based on the granule coverage and flashing condition, you're tracking solidly within that range — we don't see signs of accelerated aging."

**TPO:**
> "60-mil mechanically attached TPO commonly performs in the range of about 18 to 25 years here, depending on drainage, maintenance, and how much rooftop traffic there is. Your roof is at about 16 years. The seams are sound and there's no chronic ponding, so it's in the back half of its expected service but not at end of life."

**Concrete tile (where the underlayment-vs-tile distinction matters):**
> "The tiles themselves can last 50 years or more. The underlayment underneath, which is what actually waterproofs the roof, typically performs in the range of about 20 to 30 years. Your roof is at about 22. The tiles look fine — that's not the part we're worried about. The question is the underlayment underneath."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '4'
);

-- Part 3 / Ch 1 / Sec 5: The Age + Condition Framework
UPDATE sections SET
  content_markdown = $mfst$When the customer asks about age, the rep responds with both:

1. **Age range expected for the system** — what's normal field service life
2. **Where the customer's roof falls in that range**
3. **What condition is actually showing**
4. **What the combination of age and condition suggests**

The four parts together produce an honest answer. The first two parts alone produce overconfident predictions. The last two parts alone leave the customer without context.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '5'
);

-- Part 3 / Ch 1 / Sec 6: Common Customer Questions and Honest Answers
UPDATE sections SET
  content_markdown = $mfst$**Q: How long should this roof last?**
A: [System] in this area commonly performs in the range of [low] to [high] years, depending on conditions and maintenance. We won't quote you a specific number — that's not honest. We can tell you what the range is and where your roof falls based on what we're seeing today.

**Q: How much life does my roof have left?**
A: I can't give you a specific number of years remaining — anyone who does is guessing. What I can tell you is that based on the age and condition together, the roof is [in early life / mid-life / approaching end of life / past end of life]. Here's what that means for your options today and your planning over the next [timeframe].

**Q: My roof is 25 years old — does that mean I need a new one?**
A: Age alone doesn't decide it. We see 25-year-old roofs in serviceable condition and 12-year-old roofs that need replacement. The condition is what matters. Let me walk you through what we found and what makes sense for your roof.

**Q: My roof is only 8 years old — why is it leaking?**
A: That's a fair question, and the answer usually traces to something other than age — installation quality, ventilation, a specific detail failure, or damage from another trade. We'll find the source rather than blaming the age.

**Q: My neighbor's roof is the same age as mine and looks fine. Why is mine worse?**
A: Same age, same neighborhood, sometimes the same builder — but slope orientation, tree cover, ventilation, and original installation quality can create big differences. Yours may have been installed differently, or it may face more sun exposure, or have less ventilation than the neighbor's.

**Q: Will my warranty cover it since the roof is still under the warranty period?**
A: Possibly — but warranty coverage is detailed. Manufacturer warranties on aging roofs are often prorated and have specific exclusions. We'll review your documentation and walk through what's actually covered. (See Chapter 14 if ventilation may be the issue.)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '6'
);

-- Part 3 / Ch 1 / Sec 7: The Older-Owner / Inherited-Roof Conversation
UPDATE sections SET
  content_markdown = $mfst$Reps regularly meet customers who don't know how old their roof is. The roof was there when they bought the home, the prior owner didn't keep records, and the customer is guessing.

This is fine — and it's an opportunity for honest framing:

> "If you don't know the age, we'll work from what we can observe. Roofs of certain ages have certain visual signatures, and based on what we're seeing, the roof appears to be in the [estimated range] of its life. We won't pin down a specific year, but we can tell you what condition is showing and what the next steps look like."

This avoids the trap of demanding age information the customer can't provide, and refocuses the conversation on what the rep can actually observe.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '7'
);

-- Part 3 / Ch 1 / Sec 8: When Age Does Drive the Recommendation
UPDATE sections SET
  content_markdown = $mfst$Sometimes age is genuinely a major factor. Examples:

- **Composition shingle past 20 years with widespread granule loss and multiple leak points** — age plus condition together point to end of life (Chapter 1, Scenario C)
- **TPO past 25 years with seam failures and chronic ponding** — same pattern (Chapter 2, Scenario C)
- **Concrete tile underlayment at 25–30 years with active leaks** — underlayment age is the recommendation driver, not the tiles (Chapter 8)

In these cases, the rep names the age + condition combination explicitly:

> "Your roof is at 28 years and we documented [conditions]. Both factors together point to replacement as the right answer. If the roof were younger or the conditions were better, we'd be having a different conversation. As it stands, this is what the inspection shows."

The age is part of the answer, not the whole answer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '8'
);

-- Part 3 / Ch 1 / Sec 9: Common Sales Mistakes on Age
UPDATE sections SET
  content_markdown = $mfst$- Quoting specific remaining-life numbers
- Telling customers their roof is "old" without the context that age and condition together drive recommendations
- Letting customer anxiety about age push the conversation toward replacement when condition doesn't support it
- Letting customer optimism about age ("the roof is only 15 years old, so it must be fine") prevent the rep from naming real condition issues
- Avoiding the age conversation because it feels uncomfortable
- Treating manufacturer warranty length as lifespan$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '9'
);

-- Part 3 / Ch 1 / Sec 10: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Field range claim | OK to use? |
|---|---|
| "Architectural shingles in NorCal commonly perform in the range of 18–25 years" | Yes — range with location and product specified |
| "Your roof has 7 more years" | No — fake precision |
| "Your warranty is 30 years so the roof should last 30 years" | No — confuses warranty with lifespan |
| "Age plus condition together point to replacement" | Yes — names both factors honestly |
| "Your roof is shot" | No — pronouncement, not inspection finding |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '10'
);

-- Part 3 / Ch 1 / Sec 11: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Roof age is one data point, not the answer. The honest framing is "age is the question, condition is the answer." Reps use ranges, not specific lifespan numbers; reference the variables that drive variation (ventilation, exposure, maintenance, installation quality); and anchor every age-related answer to observed condition. When age does drive the recommendation, reps name age and condition together explicitly. The conversation about age is constant across systems and routine on every inspection — getting it right is one of the higher-leverage trust-building skills a rep can develop.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 1 AND s.section_number = '11'
);

-- Part 3 / Ch 2 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Leaks are the most common reason customers call. They're also the most commonly mishandled call type — by reps who patch where the customer points instead of finding the actual source, by reps who promise the leak is solved when they can't be sure, and by reps who undersell or oversell the broader work the leak suggests.

The leak conversation gets handled correctly when reps internalize one rule: **the entry point is rarely directly above the interior drip.** Everything else flows from this.

This module gives reps the consistent framework to investigate leaks, communicate findings honestly, and avoid the recurring mistakes that turn one leak call into a broken customer relationship.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '1'
);

-- Part 3 / Ch 2 / Sec 2: The Core Rule: Entry Point ≠ Interior Drip
UPDATE sections SET
  content_markdown = $mfst$Water doesn't fall straight down through a roof. Once water gets past the waterproofing layer, it travels:

- Along structural members (rafters, joists, trusses)
- Along the underside of the roof deck
- Along electrical conduit, plumbing pipes, and HVAC ductwork
- Through insulation
- Across substrate before reaching a low point or seam where it finally shows inside

A leak entry point is often **several feet to several dozen feet** away from the visible interior damage. On commercial flat roofs with parapet walls and complex penetrations, water can travel even farther before showing inside.

This is the single most important fact in this module. Patching directly above the interior damage when that's not the entry point produces:

- A continued leak (because the actual entry is still open)
- An unhappy customer (because they paid for a fix that didn't fix anything)
- Eroded trust (because the rep "fixed" something that's still broken)
- Often a callback where the customer is angrier than the original call$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '2'
);

-- Part 3 / Ch 2 / Sec 3: Why This Mistake Happens
UPDATE sections SET
  content_markdown = $mfst$Reps patch the wrong location for predictable reasons:

- **Time pressure.** A focused patch above the interior damage is faster than a full roof inspection.
- **Customer pressure.** The customer points at the ceiling and says "the leak is right there." The rep follows the customer's framing instead of investigating.
- **Inexperience.** New reps assume water falls straight down because that's the intuitive expectation.
- **Margin thinking.** A small patch is a quick close; a full inspection plus a real scope feels like more work for similar money.
- **Surface bias.** The rep finds *something* visible above the interior damage (a small crack, a sealant line, anything) and assumes that's it without confirming.

Recognizing these patterns is the first step to avoiding them.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '3'
);

-- Part 3 / Ch 2 / Sec 4: The Honest Investigation Process
UPDATE sections SET
  content_markdown = $mfst$When a leak is reported, the rep follows a consistent process regardless of system.

### Step 1: Listen carefully to the customer report

Customers describe leaks in patterns that point to investigation areas:

- **"It only happens during heavy rain"** → suggests a marginal detail that handles light rain but overwhelms during heavy events
- **"It only happens with wind from a certain direction"** → suggests a wall-roof transition, parapet, or wind-driven detail
- **"It started after [event]"** → suggests recent damage from storm, trade work, or roof activity
- **"It's been getting worse over time"** → suggests progressive failure of an aging detail
- **"It happens even in dry weather"** → not a roof leak; could be plumbing, condensation, or HVAC
- **"There's a stain but I've never seen water"** → could be old leak, condensation, or vapor (Chapter 14)

### Step 2: Inspect the interior damage location

- Photograph the staining, drip pattern, or damage
- Note ceiling structure direction (joist or truss orientation)
- Check adjacent walls, electrical fixtures, HVAC vents
- Note proximity to any plumbing, exterior walls, or structural features that water might travel along

### Step 3: Inspect the full roof, not just the area "above" the interior damage

The full roof inspection per Chapter 12 is mandatory on leak calls. Water travel patterns mean the entry point can be anywhere on the roof, not just upslope of the interior damage.

Focus areas:
- Every detail (penetrations, flashings, transitions, valleys, drains) — Chapter 15
- Any condition consistent with the customer's reported leak pattern (heavy rain → check drains and capacity; wind-driven → check sidewalls; recent event → check for damage)
- The area above the interior damage (still inspect it; just don't stop there)

### Step 4: Trace water travel paths

For each detail failure or suspect area, ask: **could water entering here travel to the visible interior damage?**

- Look at structural orientation
- Look at substrate slope
- Look at conduit and pipe paths
- Look at parapet wall water tracking patterns

The honest answer to "is this the source?" is sometimes "yes," sometimes "maybe," and sometimes "I can't be certain without further investigation."

### Step 5: Document findings honestly

Findings on a leak call fall into three categories:

- **Confirmed source identified** — a clear failure that traces to the interior damage path; document it with photos and severity rating
- **Probable source identified** — a clear failure that's consistent with the leak but can't be definitively confirmed without water testing or further investigation
- **No clear source identified after full inspection** — the investigation didn't conclusively identify the source; this happens and requires escalation

### Step 6: Communicate honestly with the customer

The conversation differs based on what the investigation found. See "Sample Customer Language" below.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '4'
);

-- Part 3 / Ch 2 / Sec 5: When the Source Can't Be Found
UPDATE sections SET
  content_markdown = $mfst$Sometimes a full inspection doesn't identify a clear source. This is uncomfortable but real.

Possible reasons:
- The leak is intermittent and conditions don't reproduce during inspection
- The source is hidden under coatings, recovers, or solar arrays
- The leak is being driven by something other than a roof failure (condensation, vapor — Chapter 14; HVAC; plumbing)
- The actual source requires water testing or moisture survey to identify

The honest response: escalate, recommend further investigation (water testing, moisture survey, qualified inspector), and resist the temptation to patch "something visible" just to provide an answer.

> **[SALES REP BOUNDARY]** When a leak source can't be confidently identified, the rep documents findings, communicates the uncertainty to the customer, and escalates. Patching a visible-but-uncertain detail to "do something" is one of the most common ways callbacks happen.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '5'
);

-- Part 3 / Ch 2 / Sec 6: Sample Customer Language
UPDATE sections SET
  content_markdown = $mfst$### When the source is confirmed

> "We found the leak source. It's not directly above where you're seeing the damage — water travels along [structure] before showing inside. The actual entry point is at [specific detail], about [distance] away from your interior damage. That's a real, fixable repair. We'll address [scope] and document the work."

### When the source is probable but not certain

> "We found a clear failure at [detail] that's consistent with the interior leak you described. I want to be honest — until we repair this and watch through a few rain events, we can't be 100% certain it's the only source. Our recommendation is to address [detail] first, monitor for further leaks, and re-inspect if anything else shows up. If the leak continues after this repair, we'll come back and investigate further at no additional inspection cost."

### When the source can't be found

> "I want to be straight with you. We did a complete inspection and we documented several conditions, but I can't confidently identify a single source for the leak you're describing. Patching something just to give you an answer wouldn't be honest. I'd recommend [water testing / moisture survey / further investigation] to identify the source before any repair work. I'll flag this for our senior estimator and we'll come back to you with a plan."

### When the source is part of a broader pattern

> "We found the leak source — it's [specific detail]. While we were inspecting, we also documented [broader conditions]. The leak we'll fix is a real repair. The broader conditions are a separate conversation. I want to be clear about both so you have the full picture, not just the leak fix."

### When the customer pushes back on a full inspection

> "I hear you — you want the leak fixed and you're not asking for a full inspection. The reason we look at the whole roof on a leak call is that the entry point is almost never directly above where the water shows inside. Water travels. If we just patch where you saw the drip without finding the actual source, you'd be paying for work that didn't solve your problem. The full inspection is part of giving you a real fix."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '6'
);

-- Part 3 / Ch 2 / Sec 7: When the Customer Reports the Leak Is "Solved" After Prior Work
UPDATE sections SET
  content_markdown = $mfst$Sometimes customers say a previous contractor "fixed" the leak but a stain remains. The rep's job:

- Document the stain
- Inspect to confirm whether the prior repair actually addressed the source
- Be careful not to bash the prior contractor without evidence
- If the prior repair appears insufficient, communicate honestly without overpromising

> "The stain you're describing could be from the previous leak that's already been repaired — old stains don't always go away on their own. It could also be from a new or continuing source. Let's inspect and document conditions before drawing conclusions. If the prior repair held, we'll let you know. If we see signs that the leak is continuing, we'll document that too."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '7'
);

-- Part 3 / Ch 2 / Sec 8: When Insurance Is Involved
UPDATE sections SET
  content_markdown = $mfst$Leaks tied to storm or hail damage often involve insurance. The rep's role here is documentation, not insurance interpretation.

What reps may do:
- Document conditions thoroughly
- Photograph damage with reference scale
- Provide the customer with documentation suitable for their carrier
- Note when conditions appear consistent with storm or hail damage

What reps may NOT do:
- Certify hail damage for insurance purposes (unless qualified and authorized)
- Promise specific insurance outcomes
- Recommend specific scopes "to maximize the claim"
- File or interpret the insurance claim

> "We can document conditions for your claim, but we won't promise an outcome — that's between you and your carrier. We'll do our part honestly."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '8'
);

-- Part 3 / Ch 2 / Sec 9: The Repair-Plus-Plan Conversation
UPDATE sections SET
  content_markdown = $mfst$When a leak is on a roof at the older end of its service range, or part of a pattern of repeat repairs, the rep adds the broader context honestly. (See Chapter 11, Section 7.)

> "We can patch this leak today. While we're up there we also documented [conditions]. The patch buys you time. The bigger picture is your roof is at [age range] and showing [aging signs]. I can put a longer-term plan on paper for whenever you're ready. No pressure right now — I just want to be straight with you about the full picture."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '9'
);

-- Part 3 / Ch 2 / Sec 10: Common Sales Mistakes on Leak Calls
UPDATE sections SET
  content_markdown = $mfst$- Patching the wrong location because the rep didn't investigate the source
- Promising a specific patch will solve all future leak issues
- Skipping the full roof inspection on a "small leak" call
- Telling the customer the leak is "complicated" and quoting a large scope without first identifying the source
- Recommending replacement based on a single leak without inspection
- Bashing the previous contractor's repair without inspection evidence
- Promising insurance approval or claim outcomes
- Capitulating when a customer pushes back on a thorough inspection$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '10'
);

-- Part 3 / Ch 2 / Sec 11: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "The leak is right there" | Inspect there, then inspect the rest of the roof |
| "Just patch it" | Patch when patching is the right answer; identify the source first |
| "It only happens in heavy rain" | Investigate marginal details and drainage capacity |
| "It only leaks when wind blows from the south" | Investigate sidewall transitions and wind-driven entry points |
| "I had this fixed before but the stain is still there" | Inspect to confirm; old stains don't always go away |
| "Insurance will cover this" | Document; don't promise outcomes |
| "The roof is only 8 years old, what's wrong?" | Look at installation quality, ventilation, detail failures, trade damage — not age |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '11'
);

-- Part 3 / Ch 2 / Sec 12: Module Summary
UPDATE sections SET
  content_markdown = $mfst$The entry point on a roof leak is rarely directly above the interior drip — water travels along structure, conduit, and substrate before showing inside. Patching where the customer points without identifying the actual source is the most common way a leak call goes wrong. The honest investigation process is: listen carefully to the customer report, inspect the interior, inspect the full roof (not just the area above the damage), trace water travel paths, document findings honestly, and communicate with appropriate certainty language. Sometimes the source can't be found — escalation and further investigation are the right answers, not patching something visible to "do something." When insurance is involved, reps document but don't certify or promise outcomes. When the leak is part of a broader pattern, reps offer the repair-plus-plan conversation honestly. The leak conversation is one of the highest-volume customer interactions reps will have; getting it right is the foundation of trust that drives long-term customer relationships and referrals.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 2 AND s.section_number = '12'
);

-- Part 3 / Ch 3 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Ponding water is one of the most common findings on commercial flat-roof inspections — and one of the most commonly mishandled in customer conversations. The customer either thinks it's a non-issue ("water just sits there sometimes, it's fine") or thinks it's a catastrophe ("there's a swimming pool on my roof"). Both framings are wrong. Reps who handle the conversation well give customers the calibrated middle ground: ponding becomes a problem at a specific threshold, and the right scope depends on how far past that threshold the roof has gone.

This module is the standalone training piece for the ponding conversation. The full drainage content lives in Chapter 16; this module focuses on what reps actually say to customers and how they hold the line when customers want shortcuts the roof can't support.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '1'
);

-- Part 3 / Ch 3 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$Ponding water that drains within 48 hours is acceptable. Ponding water that persists longer is a problem — and a coating won't fix it.

That's the entire conversation in two sentences. Everything else in this module is how to deliver that message in real customer situations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '2'
);

-- Part 3 / Ch 3 / Sec 3: The 48-Hour Standard
UPDATE sections SET
  content_markdown = $mfst$The industry standard most commonly cited and used in manufacturer warranties:

- **Acceptable ponding** — water that drains within 48 hours of rain stopping
- **Problematic ponding** — water persisting longer than 48 hours
- **Severe ponding** — water that essentially never drains

> **[CHECK MANUFACTURER]** Specific warranty terms vary. Some warranties exclude ponding-related damage; others define ponding tolerances differently. Confirm against the actual warranty document.

The 48-hour number is concrete, defensible, and easy for customers to understand. Reps should use it.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '3'
);

-- Part 3 / Ch 3 / Sec 4: Why Ponding Matters (In Customer Language)
UPDATE sections SET
  content_markdown = $mfst$Reps need a short version of the "why" that lands with non-technical customers.

> "Water is what roofs are designed to keep out. The faster water leaves, the less time it has to find a weakness or accelerate aging. When water sits on a roof beyond what the system was designed to handle — past about 48 hours after rain stops — it starts wearing the membrane faster than the rest of the roof. We see it as dirt rings, biological growth, and accelerated wear concentrated in the ponding areas. It's not always an emergency, but it's not 'normal' either."

Three things this language does:
1. Anchors the answer in something physical and intuitive (water is the enemy)
2. Names the threshold (48 hours)
3. Describes what reps actually see during inspection$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '4'
);

-- Part 3 / Ch 3 / Sec 5: The Most Important Customer Conversation: Coating Won't Fix Ponding
UPDATE sections SET
  content_markdown = $mfst$This is the moment that comes up most often, and it's where reps either build trust or fail Rule 5.

The customer's framing: "Can we just put a coating over the ponding to seal it up?"

The honest answer: **No. Coatings don't add slope. A coating applied over chronic ponding will fail before its expected life and won't be supported by manufacturer warranty.**

### Why this matters specifically

A coating proposal is easier to sell than ponding correction:
- Lower cost
- Faster project
- Less customer disruption
- The customer often *prefers* this answer

But it's wrong for chronically ponded roofs. The disqualifying condition is real (Chapter 3, Section 13). The coating will fail in the ponded areas first, the warranty won't pay for the replacement, and the customer will end up paying for both the coating and the eventual replacement.

The honest path requires the harder conversation up front.

### Sample customer language

> "I'd love to put restoration on the table for you, but I have to be straight: with the ponding we documented, restoration isn't the right call. A silicone coating doesn't add slope, and applying one on a chronically ponded roof would fail before the warranty period and wouldn't be supported by the manufacturer. The honest options for this roof are SPF, which can correct slope during application, or replacement with tapered insulation. Both are bigger investments than coating; both actually solve the underlying problem."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '5'
);

-- Part 3 / Ch 3 / Sec 6: The Real Solutions to Ponding
UPDATE sections SET
  content_markdown = $mfst$Three real options exist for fixing ponding:

1. **SPF (Spray Polyurethane Foam)** — sprayed thicker at low spots and thinner near drains to create slope during application. Unique among standard flat-roof systems for this capability. (Chapter 10.)
2. **Replacement with tapered insulation** — full tear-off and rebuild with insulation cut at varying thicknesses to create slope. Highest cost, longest life.
3. **Drainage modifications** — adding drains, scuppers, or addressing structural causes of the ponding. Specialty work, sometimes structural.

What does *not* fix ponding:
- Any coating system
- TPO overlay without tapered insulation
- "Adding more drains anywhere" without engineering analysis
- Multiple aluminum coatings or short-term fixes

When the customer asks for the cheapest option to fix ponding, the honest answer is that the cheapest option that actually fixes ponding is SPF or tapered-insulation replacement — not a coating, even if a coating costs less.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '6'
);

-- Part 3 / Ch 3 / Sec 7: Acceptable Ponding vs. Problematic Ponding — How to Tell
UPDATE sections SET
  content_markdown = $mfst$On a dry-day inspection, reps document ponding evidence rather than current standing water. Indicators:

- **Dirt rings** — circular or oblong patterns marking where water has been sitting (the most reliable indicator on a dry roof)
- **Biological growth patterns** — algae or moss concentrated in low areas
- **Membrane discoloration** — ponding areas often look visibly different
- **Granule or surface wear concentrated in patterns** — on cap-sheet systems and BUR
- **Sediment or debris accumulation** — settles in low areas

On a rainy or post-rain inspection:
- Photograph standing water
- Note depth where possible (chalk on parapet, ruler in pond)
- Note time elapsed since rain stopped (when known)

Reps should use chalk to outline the extent of ponding marked by dirt rings, photograph extensively, and apply severity ratings:

| Severity | Description |
|---|---|
| Monitor | Light ponding, drains within 48 hours, faint dirt rings |
| Maintenance Needed | Persistent ponding, drains slowly, visible dirt rings, addressable through maintenance (clogged drains) |
| Repair Recommended | Chronic ponding consistently past 48 hours, biological growth, accelerated wear |
| Urgent / Escalate | Severe ponding that essentially never drains, suspected structural deflection, depths approaching warranty limits |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '7'
);

-- Part 3 / Ch 3 / Sec 8: Common Customer Beliefs and Honest Responses
UPDATE sections SET
  content_markdown = $mfst$### "All flat roofs pond — it's just how they are."

Partially true and commonly misused. Brief ponding after rain is normal — flat roofs aren't designed to shed water as quickly as sloped roofs. Persistent ponding is not normal and not acceptable. The 48-hour standard is the line.

> "Some water sitting on a flat roof briefly after rain is normal. The issue isn't whether water sits at all — it's how long. The industry standard is 48 hours. After that, you're not just dealing with water; you're dealing with wear."

### "It's been like that since I bought the building."

Often true. Inherited ponding is common. The fact that it's pre-existing doesn't make it harmless — it usually means the roof has been aging faster in those spots for years.

> "That tells me this isn't a recent failure but a long-standing slope or structural pattern. The fact that it's been like this doesn't mean it's harmless — it usually means the roof above those spots has been aging faster than the rest of the system. We can document the current condition and talk about how to address it as part of any future scope, or maintain it as-is with eyes open about the trade-offs."

### "Another contractor said it's fine."

Sometimes true (light, transient ponding really is fine). Sometimes the other contractor wasn't honest. Reps shouldn't dismiss the other contractor without evidence; reps should explain what *they* observed and why.

> "Possibly. Some ponding is fine — within the 48-hour window. What we documented [is / isn't] within that window, and here's what the dirt rings and biological growth show. You can compare what we found with what the other contractor said and decide."

### "Will my warranty cover damage from ponding?"

Probably not. Most manufacturer warranties limit or exclude ponding-related damage. Reps should not promise warranty coverage on ponded conditions.

> "Possibly, but ponding is a common warranty exclusion. We'd need to review your specific warranty document. Most manufacturers limit or exclude ponding-related damage."

### "My roof will be fine — it's just a little water."

Reps push back honestly without being alarmist.

> "Maybe — if it's draining within 48 hours, it probably is fine. What we documented is past that. Whether or not you act on it today, the roof above the pond is aging faster than the rest of the system, and any restoration coating won't be a real option if the ponding stays. I'd rather you have that information now than find out later."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '8'
);

-- Part 3 / Ch 3 / Sec 9: When the Customer Pushes Back Hard
UPDATE sections SET
  content_markdown = $mfst$A repeat customer or property manager who wants restoration on a chronically ponded roof is the textbook honest-versus-easy moment from Chapter 13. The rep maintains the position without capitulating.

> "I hear what you're asking for, and I'd love to put it on paper. But based on what we documented, applying a coating over the ponding wouldn't perform. The manufacturer warranty wouldn't cover it, and the coating would likely fail before its expected life. I'm not going to write a restoration proposal I don't believe will perform. What I can do is put SPF or replacement-with-tapered-insulation options on paper, or I can put a phased plan on paper that addresses [interim scope] now and the broader scope later. Your call."

The customer may take the proposal elsewhere. That's their right. The rep's job is to give the honest answer, not to capitulate when pressed.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '9'
);

-- Part 3 / Ch 3 / Sec 10: When SPF Is the Right Recommendation
UPDATE sections SET
  content_markdown = $mfst$When ponding is the defining problem on a roof and the customer wants a real solution, SPF is often the right answer because it can correct slope through tapered application during installation. (See Chapter 10.)

The conversation:

> "Your roof's ponding is significant enough that the recommendation isn't 'which restoration coating' but 'how do we actually fix the slope.' SPF is the option that does this — we spray it thicker in the low spots and thinner near the drains to create slope during installation. The alternative is full replacement with tapered insulation, which is bigger scope and higher cost but also longer service life. Both are real options. A coating-only proposal isn't on the table for this roof."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '10'
);

-- Part 3 / Ch 3 / Sec 11: Common Sales Mistakes on Ponding
UPDATE sections SET
  content_markdown = $mfst$- Telling customers all flat roofs pond and it's normal (without the 48-hour qualifier)
- Recommending coating over chronically ponded substrates
- Failing to document ponding evidence on dry-day inspections (no chalk outlines, no ponding ring photos)
- Promising that a TPO overlay "fixes" ponding (it doesn't — overlay raises the whole roof but preserves the same low spots, unless tapered insulation is included)
- Quoting recover or replacement scope without addressing the underlying ponding cause
- Capitulating when customers push back on the honest answer
- Promising warranty coverage on ponded conditions$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '11'
);

-- Part 3 / Ch 3 / Sec 12: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Water just sits there sometimes" | Ask how long; reference the 48-hour standard |
| "Can we just put a coating on it?" | Honest no on chronic ponding; explain why; offer real options |
| "It's been like that for years" | Acknowledge; explain that long-standing ponding usually means accelerated aging in those spots |
| "Another contractor said it's fine" | Explain what was observed; let customer compare |
| "What's the cheapest fix?" | Explain that the cheapest option that actually fixes ponding is SPF or tapered insulation |
| "Will my warranty cover this?" | Check the warranty document; most exclude ponding-related damage |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '12'
);

-- Part 3 / Ch 3 / Sec 13: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Ponding water that drains within 48 hours is acceptable; water persisting longer is a problem. The most important customer conversation in this module is that coatings do not fix ponding — they don't add slope, and they fail in ponded areas faster than elsewhere. The real solutions are SPF (which can correct slope during application), replacement with tapered insulation, or drainage modifications. Reps document ponding evidence on dry days through dirt rings, biological patterns, and chalk-outlined extent. When customers push back on the honest answer — usually because a coating is cheaper and easier — reps maintain the position without capitulating. The 48-hour standard converts a fuzzy customer concept ("water sits there sometimes") into a concrete framework that shapes the recommendation, and using it consistently is one of the more useful pieces of customer education a rep can deliver on flat-roof commercial work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 3 AND s.section_number = '13'
);

-- Part 3 / Ch 4 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Customers regularly conflate four different things that look similar in marketing but mean very different things in practice. They use "coating" and "restoration" and "repair" interchangeably. They think "replacement" means tear-off, when it sometimes means recover. They believe a coating fixes leaks. They think rejuvenation extends warranty automatically. The result: customers shop quotes that aren't actually comparable, and reps who don't clarify the differences end up either losing the deal to a misleading competitor or selling work that doesn't perform.

This module gives reps consistent language to define what each scope actually is, draw the lines between them honestly, and handle the common moments where customers get pushed toward the wrong scope by other contractors or their own assumptions.

The full decision framework lives in Chapter 13. This module focuses on the customer-conversation language.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '1'
);

-- Part 3 / Ch 4 / Sec 2: The Four Scopes — In Plain Customer Language
UPDATE sections SET
  content_markdown = $mfst$A rep should be able to define each scope in two sentences, in plain English, on a moment's notice.

### Repair

> "Repair means we fix a specific failure — a torn membrane, a failed pipe boot, a broken tile. The rest of the roof keeps doing its job; we're addressing one or more specific issues."

### Restoration (typically a coating, sometimes rejuvenation)

> "Restoration means we add a layer to your existing roof to extend its useful service life. The roof you have continues to perform; we're adding waterproofing, reflectivity, and a maintenance reset on top of a substrate that's still sound."

### Replacement (tear-off)

> "Replacement means we remove the existing roof down to the deck and install a new system from scratch. Highest cost, longest expected life, fresh start."

### Recover (overlay)

> "Recover, sometimes called overlay, means we install a new roof system over your existing one. The old roof stays in place underneath. It's technically a form of replacement, but the existing system isn't torn off. Code only allows this once — you can't keep stacking layers."

These four definitions are the foundation. Customers who hear them clearly stop confusing the categories.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '2'
);

-- Part 3 / Ch 4 / Sec 3: The Most Common Customer Confusions
UPDATE sections SET
  content_markdown = $mfst$### Confusion 1: "Coating" = "Restoration" = "Painting the Roof"

Customers often hear "coating" and picture roof paint. The reality is more specific.

The honest framing:
> "Coatings aren't roof paint. They're engineered liquid-applied membranes that bond to your existing roof and form a continuous waterproof layer. Done right, on a substrate that qualifies, they extend service life by years. Done wrong, on a roof that doesn't qualify, they fail. The product matters less than whether your roof qualifies and whether the prep is done correctly."

### Confusion 2: "Coatings Fix Leaks"

Customers — and unfortunately some contractors — frame coatings as leak repair products. They're not.

> "A coating isn't a leak fix. If your roof is leaking, we have to find the leak source and repair it before any coating goes on. Otherwise the coating goes over a still-leaking roof and traps moisture under the new layer. The coating is what extends life *after* the roof is watertight, not what makes it watertight."

### Confusion 3: "Replacement" = "Tear-Off"

Customers think replacement always means full tear-off. Sometimes it means recover.

> "Replacement covers two approaches. Tear-off is the full version — old roof comes off, new one goes on. Recover is overlay — the new system installs over the existing one, where code permits and the substrate qualifies. Tear-off is more disruptive and more expensive, but produces a fresh start. Recover is faster and cheaper but you can only do it once before you're back to tear-off territory."

### Confusion 4: "Rejuvenation" = "Coating" = "Restoration"

Rejuvenation is genuinely different from coating restoration. (See Chapter 4.)

> "Rejuvenation isn't a coating — it's a chemical treatment that absorbs into your shingles to replace some of the oils they've lost as they aged. There's no surface film, and after it cures the roof looks largely the same. Coatings are a continuous waterproof layer added on top; they're a different category of product for a different category of problem."

### Confusion 5: "Restoration" = "Lifetime Solution"

Customers sometimes treat restoration as a one-and-done life extension.

> "Restoration extends your roof's useful service life — but it doesn't reset the clock. The substrate underneath continues aging. Eventually full replacement becomes the right answer no matter how good the restoration was. The honest framing is: restoration buys time; replacement is the long-term answer."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '3'
);

-- Part 3 / Ch 4 / Sec 4: When Each Scope Is Right — In One Sentence Each
UPDATE sections SET
  content_markdown = $mfst$Reps should be able to summarize the right scope for each common scenario in one sentence.

| Roof situation | Honest scope |
|---|---|
| Localized failure on a young or mid-life roof in good condition | Repair |
| Mid-life roof with sound substrate, addressable details, no disqualifying conditions | Restoration |
| End-of-life roof, widespread failures, or disqualifying conditions present | Replacement |
| End-of-life roof with sound substrate where code permits recover | Recover (a form of replacement, sometimes the right cost-life fit) |
| Mid-life shingle roof in the qualifying age window | Rejuvenation (per Chapter 4) |
| Roof with chronic ponding | Not coating; SPF or tapered-insulation replacement |
| Roof with widespread wet insulation, structural issues, or asbestos | Replacement (with appropriate handling) |

These aren't recommendations the rep makes from the front seat of the truck — they require inspection. But they're the framework reps carry into every inspection so they can categorize findings honestly.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '4'
);

-- Part 3 / Ch 4 / Sec 5: The Comparison Conversation: When Customers Have Multiple Quotes
UPDATE sections SET
  content_markdown = $mfst$This is where reps most often face the test. Customer says: "I have three quotes. One contractor said coating, one said TPO overlay, one said full replacement. They're all different prices. What do I actually need?"

The honest framework:

> "Those three contractors gave you three different scopes, which is why the prices are different. The question isn't which contractor is cheapest — it's which scope is actually right for your roof. Let me walk you through what each scope is and isn't, what conditions make each one appropriate, and what we found on our inspection. You'll have the full picture and you can compare apples to apples instead of just comparing dollar amounts."

Then walk through:
- What each scope is (the four definitions above)
- What conditions justify each scope
- What was actually found on the roof
- Which scope fits the findings honestly
- What's missing or wrong in the quotes that don't match

Reps should never bash other contractors. Reps should explain the *scopes* honestly and let the customer compare.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '5'
);

-- Part 3 / Ch 4 / Sec 6: When the Customer Wants the Cheapest Scope That Doesn't Fit
UPDATE sections SET
  content_markdown = $mfst$A common moment: customer's roof needs replacement. Customer wants to do restoration because it's cheaper. The rep faces the honest-versus-easy choice (Chapter 13, Section 7).

The honest response:

> "I hear you on cost. Restoration would be the cheaper number on paper. The problem is that for your roof, restoration won't perform — [specific disqualifying conditions]. Spending money on restoration that won't last isn't actually cheaper; it's just a smaller bill that doesn't solve the problem. Your real options for this roof are repair-plus-replacement-plan, full replacement now, or — if cost is the real constraint — phased work that addresses the most urgent items now and plans the rest."

The rep doesn't refuse to consider the customer's budget. The rep refuses to pretend a scope will perform when it won't.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '6'
);

-- Part 3 / Ch 4 / Sec 7: When the Customer Wants More Scope Than the Roof Needs
UPDATE sections SET
  content_markdown = $mfst$Less common but real: customer wants replacement on a roof that genuinely doesn't need it.

> "I want to give you the honest answer. Your roof has remaining service life and the issues we found are localized. Replacement isn't the right call here — both for your wallet and for any contractor who'd recommend it. Repair, plus a maintenance program if you want documentation and ongoing inspection, is what makes sense for this roof. If you want, I can put both options on paper so you can see the difference."

The temptation to write the bigger proposal because the customer wants it is real. The honest response is to recommend what the roof actually needs.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '7'
);

-- Part 3 / Ch 4 / Sec 8: The Honest Phrases Reps Should Have Ready
UPDATE sections SET
  content_markdown = $mfst$Some short phrases reps should be able to deliver naturally:

- "Coating isn't a leak fix."
- "The coating extends life. The repair fixes leaks."
- "Restoration buys time. Replacement is the long-term answer."
- "A coating doesn't add slope. SPF or tapered insulation does."
- "If your roof doesn't qualify, the coating doesn't perform — and the warranty doesn't pay."
- "We don't recommend the most expensive option for the sake of a bigger sale."
- "We don't recommend the cheapest option just to win the bid."

Reps who can deliver these phrases naturally — not as scripts but as language they actually believe — handle the conversation cleanly.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '8'
);

-- Part 3 / Ch 4 / Sec 9: Pricing Comparison Pitfalls
UPDATE sections SET
  content_markdown = $mfst$Customers often compare quotes by price alone. The rep's job is to help them compare scopes.

Common pitfalls:

- **The cheap coating quote vs. the proper restoration scope** — the cheap quote may skip detail repair, primer, fabric reinforcement, mil thickness, or warranty registration. Same product name, different actual scope.
- **The TPO overlay quote vs. the TPO overlay with tapered insulation quote** — same name, completely different scopes; the second addresses ponding, the first doesn't.
- **The shingle replacement quote vs. the shingle replacement with ventilation upgrade quote** — same name, but one handles the underlying ventilation problem driving premature aging, the other doesn't.
- **The "full replacement" quote that's actually a recover** — vocabulary differences hide the actual scope.

Reps should walk customers through what each line of the proposal includes — and what's missing from comparison quotes that may matter.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '9'
);

-- Part 3 / Ch 4 / Sec 10: What Reps Must NOT Do
UPDATE sections SET
  content_markdown = $mfst$- Conflate coating with leak repair
- Recommend restoration on a roof that doesn't qualify because it's an easier sell
- Recommend replacement on a roof that doesn't need it because the proposal is bigger
- Bash competitors' proposals without seeing them
- Guarantee that any scope will perform without inspection-supported reasoning
- Promise warranty coverage on a scope the manufacturer wouldn't actually warrant
- Use vocabulary loosely (calling rejuvenation "coating" or recover "tear-off")
- Capitulate when customers push back on the honest answer$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '10'
);

-- Part 3 / Ch 4 / Sec 11: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Just coat the roof" | Confirm the substrate qualifies; if it doesn't, explain why and offer real alternatives |
| "Coating will fix the leak" | Honestly: no — coating extends life on a watertight roof; the leak gets repaired first |
| "I want the cheapest option" | Present what actually performs at lower cost; don't recommend a scope that won't perform just because it's cheaper |
| "All these quotes are different — which is right?" | Explain the scope differences, not the price differences |
| "Replacement means tear-off, right?" | Sometimes; sometimes recover. Explain both. |
| "Rejuvenation is the same as a coating" | They're different categories; explain the chemistry difference briefly |
| "Will the warranty cover this?" | Check the warranty document; don't promise outcomes |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '11'
);

-- Part 3 / Ch 4 / Sec 12: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Customers conflate four different scopes — coating, repair, restoration, replacement — that mean very different things in practice. Reps need to define each in plain language, two sentences each, on demand. The most common customer confusions are: treating coating as roof paint, expecting coating to fix leaks, conflating replacement with tear-off (when recover is sometimes the answer), and assuming rejuvenation is the same as coating. When customers compare multiple quotes, the rep's job is to help them compare scopes, not prices — different scopes with the same vocabulary are the most common pricing-comparison trap. The honest-versus-easy moments come up most often when a customer wants a cheaper scope that doesn't fit the roof or a bigger scope than the roof needs; in both cases, reps recommend what the roof actually needs and resist the pull in either direction. The vocabulary discipline in this module — using each term precisely and consistently — is what separates reps customers trust from reps who get cycled through and forgotten.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 4 AND s.section_number = '12'
);

-- Part 3 / Ch 5 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Roof rejuvenation is one of the harder products in the industry to sell honestly. Customers don't intuitively understand what it is. The visible result is subtle. The marketing in the broader industry has sometimes been overhyped, leaving some customers suspicious that "rejuvenation" is a gimmick. And the qualifying window is narrow enough that reps face real ethics tests when customers want it on roofs that don't qualify.

USA Flat Roof offers Fresh Roof rejuvenation as a proactive maintenance service for shingle roofs in the mid-life window. This module is the standalone training piece for the customer conversation. The full chapter is Chapter 4; this module focuses on language reps actually use in the field and the three specific moments where customers most often misunderstand or push back.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '1'
);

-- Part 3 / Ch 5 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation is a chemical treatment that replaces some of the oils aging shingles have lost — proactively, while the roof is still in good shape — to extend useful service life by years. It's not a coating, it's not a leak fix, and it doesn't work on roofs outside a specific age and condition window.

That's the entire conversation in three sentences. Everything else in this module is how to deliver that message in real customer situations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '2'
);

-- Part 3 / Ch 5 / Sec 3: The Proactive Maintenance Positioning
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof leads with rejuvenation as **proactive maintenance** — applied while the roof is still in good condition, not as a last-ditch effort to save a failing roof. This positioning matters because:

- It's honest about when the product actually performs
- It reaches customers in the right mindset (extending life of a working roof, not rescuing a broken one)
- It separates Fresh Roof's legitimate offering from the "rejuvenation as miracle cure" pitch some contractors use
- It builds the long-term relationship — proactive maintenance customers come back

### Sample customer language

> "Rejuvenation isn't a fix for a roof that's already failing — that's not what the product does. It's a maintenance treatment we apply while your roof is still in good shape, to slow the aging process and extend useful service life. The right time to do it is in the middle of your roof's life — not when it's brand new, not when it's at end of life. Done at the right time on the right roof, it adds years."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '3'
);

-- Part 3 / Ch 5 / Sec 4: The Chemistry — In 30 Seconds
UPDATE sections SET
  content_markdown = $mfst$Reps need a short, plain-language explanation of what's actually happening at the chemical level. The technical answer keeps the conversation grounded and helps customers separate Fresh Roof from generic "roof spray" pitches.

> "Asphalt shingles age in part because the oils that keep them flexible dry out over time. Once shingles get brittle, they crack and shed granules faster, and the roof ages quicker. Rejuvenation is a treatment we spray on that's designed to replace some of those lost oils, restore flexibility, and slow further aging. The product absorbs into the shingles. There's no surface coating left behind."

Three things this language does:
1. Names the actual aging mechanism (plasticizer loss)
2. Explains what the treatment does (replaces lost oils)
3. Sets the visual expectation (no surface coating, no dramatic change)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '4'
);

-- Part 3 / Ch 5 / Sec 5: The Three Moments Where the Conversation Goes Sideways
UPDATE sections SET
  content_markdown = $mfst$Three specific moments come up regularly, and each requires a clear, honest response.

### Moment 1: "Is This a Scam?"

Customers who've seen overpromised rejuvenation marketing online or heard skeptical neighbors will sometimes lead with this concern.

The rep's job: take it seriously, don't get defensive, and walk through the chemistry and the qualifying conditions.

> "Fair concern. There's been some hype in the industry around rejuvenation that has overpromised what it does, and I understand the skepticism. The chemistry is real — asphalt shingles do lose oils as they age, and the right product can replace some of those oils. The manufacturer publishes warranty terms and qualifying conditions, and there's documentation behind the claim. What separates legitimate rejuvenation from the hype is whether the contractor inspects honestly and only applies it to roofs that actually qualify. If your roof doesn't qualify, we won't recommend it — even if you ask for it."

The closing — *we won't recommend it even if you ask for it* — does more for trust than any defensive justification.

### Moment 2: "How Many Years Will This Add?"

Customers want a specific number. Specific numbers are exactly what reps must not give. (Rule 2.)

> "The manufacturer publishes service life extension ranges, and we'll walk you through what's realistic for your roof based on its current condition. We won't quote a specific number — that depends on the roof, the maintenance, and the conditions. What we can say is that for roofs in the qualifying window with sound substrate, the treatment provides meaningful life extension that's documented in the manufacturer's warranty terms."

Customers sometimes push: "Just give me a number." The rep doesn't capitulate.

> "I'd rather give you a range that turns out to be accurate than a specific number that turns out to be wrong. Anyone who quotes you a specific number on roof life extension is guessing. The manufacturer's range and your roof's condition are the honest answer."

### Moment 3: "My Neighbor's Roof Looks Brand New After Rejuvenation"

The visual-expectation trap. Customers expect dramatic visible change because they've seen before/after photos online or heard a neighbor's pitch.

The rep's job: reset the expectation honestly without being dismissive.

> "Honestly, you shouldn't expect dramatic visible change. The treatment absorbs into the shingles and works at the asphalt level, not on the surface. After it cures, your roof will look largely the same. If your neighbor's roof looks brand new, that's almost certainly from cleaning — moss removal, biological growth treatment, or pressure washing — not from rejuvenation itself. Rejuvenation does its work invisibly. The before/after photos you've seen online are usually misleading."

The honest answer up front prevents the "I paid for this and nothing changed" complaint after the fact.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '5'
);

-- Part 3 / Ch 5 / Sec 6: The Window — Why Timing Matters
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation has a specific window of effectiveness, and reps need to communicate it clearly.

- **Too early (new roof):** no benefit; the shingles haven't lost enough oils for the treatment to do meaningful work
- **Too late (end of life):** no benefit; the shingles don't have enough remaining structure to benefit from oil replacement
- **In the window (mid-life):** real benefit, and warranty registration is most valuable

Reps should describe this in plain language:

> "Rejuvenation works best when the roof is in mid-life — past the early period where there's no benefit, but well before end of life when it's too late to help. If your roof is in that window, the treatment does real work. If it's outside the window, we won't recommend it — the manufacturer's warranty wouldn't honor it on a roof that doesn't qualify, and you wouldn't get the extension you're paying for."

> **[CHECK MANUFACTURER]** Specific qualifying age window varies by product. Confirm against current Fresh Roof contractor documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '6'
);

-- Part 3 / Ch 5 / Sec 7: The Honest-Versus-Easy Moment
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation is one of the easier products to oversell. The pattern:

- Customer wants it
- Customer's roof is past the qualifying window
- Rep agrees because it's an easy close
- Treatment fails to perform; warranty doesn't honor; customer is angry months later

The rep's discipline: when the roof doesn't qualify, the rep doesn't recommend it. Period.

> "I want to give you the honest answer. Your roof is past the window where rejuvenation provides real benefit. The granule loss is significant, and the shingles are losing structure, not just oils. If we applied the treatment today, the manufacturer warranty wouldn't honor it because the roof doesn't qualify, and you wouldn't get the extension you're paying for. I'd rather tell you that now than take your money for something that won't perform. The honest answer for this roof is replacement."

This is the same honest-versus-easy moment from Chapter 4 (Scenario C) and Chapter 13. Reps need to recognize it and hold the line.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '7'
);

-- Part 3 / Ch 5 / Sec 8: What Rejuvenation Is Not
UPDATE sections SET
  content_markdown = $mfst$Reps should be ready to clarify each of these distinctions when customers conflate them.

| Customer might think | Honest reality |
|---|---|
| Rejuvenation is a coating | No — it absorbs into the shingles, no surface film |
| Rejuvenation fixes leaks | No — leaks get repaired first; rejuvenation is for an already-watertight roof |
| Rejuvenation makes the roof look new | No — visible change is subtle to none |
| Rejuvenation works on any age roof | No — there's a specific qualifying window |
| Rejuvenation works on any roof type | No — it's specifically for asphalt shingle |
| Rejuvenation gives a guaranteed number of additional years | No — manufacturer publishes ranges; specific years can't be promised |
| Rejuvenation is the same as rejuvenation products from the hardware store | No — engineered manufacturer-warranted products are different from generic "roof spray" |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '8'
);

-- Part 3 / Ch 5 / Sec 9: The Maintenance Program Conversation
UPDATE sections SET
  content_markdown = $mfst$Rejuvenation fits naturally into a broader maintenance program offering — annual inspection, gutter and debris service, minor repairs, and rejuvenation when the roof reaches the qualifying window.

> "Rejuvenation works best as part of how you take care of the roof overall, not as a one-time thing. The same homeowners who benefit from rejuvenation are the ones who clean their gutters, address small repairs early, and keep up with the small stuff. We can build that into a maintenance program if you want, or you can manage it yourself — but the value of rejuvenation is highest when the rest of the maintenance is also being done."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '9'
);

-- Part 3 / Ch 5 / Sec 10: When NOT to Propose Rejuvenation
UPDATE sections SET
  content_markdown = $mfst$Reps should decline rejuvenation in any of these scenarios:

- Roof outside the manufacturer's qualifying age window (too new or too old)
- Active leaks present (repair first; if conditions still qualify, then rejuvenation)
- Widespread granule loss with exposed asphalt
- Multiple damaged or missing shingles
- Soft or sagging deck
- Suspected wet decking or insulation
- Roof type other than asphalt shingle (won't work on tile, metal, flat roofs)
- Customer expects rejuvenation to fix a problem rejuvenation doesn't address

In each case, the rep names the disqualifying condition and recommends the appropriate alternative — repair, replacement, or no action — depending on what the inspection found.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '10'
);

-- Part 3 / Ch 5 / Sec 11: Common Sales Mistakes on Rejuvenation
UPDATE sections SET
  content_markdown = $mfst$- Quoting a specific number of additional years
- Recommending rejuvenation on roofs outside the qualifying window
- Calling rejuvenation a "leak fix" or implying it solves problems it doesn't
- Promising dramatic visible improvement
- Comparing rejuvenation to coatings as if they're the same product category
- Selling rejuvenation as a one-time thing rather than part of broader maintenance
- Capitulating when customers push for rejuvenation on non-qualifying roofs
- Promising warranty coverage without confirming registration requirements$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '11'
);

-- Part 3 / Ch 5 / Sec 12: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Is rejuvenation a scam?" | Acknowledge the concern; explain the chemistry; emphasize the qualification process |
| "How many years will this add?" | Use the manufacturer's range; never quote a specific number |
| "My neighbor's roof looks brand new" | Reset the expectation honestly; cleaning is what produced the visible change, not rejuvenation |
| "My roof is 25 years old, let's do this" | Explain the qualifying window; if the roof is past it, decline and recommend replacement |
| "Will this fix my leak?" | Honest no; explain the leak gets repaired first; rejuvenation is for a watertight roof |
| "Why is rejuvenation cheaper than coating?" | Different products doing different jobs; explain the category difference briefly |
| "Will my insurance cover this?" | Insurance covers damage events, not maintenance; rejuvenation is preventive maintenance |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '12'
);

-- Part 3 / Ch 5 / Sec 13: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Roof rejuvenation is a chemical treatment that replaces oils aging shingles have lost. USA Flat Roof positions Fresh Roof rejuvenation as proactive maintenance, applied while the roof is still in good condition, in a specific mid-life window. Reps need to handle three recurring moments well: the "is this a scam" skepticism (acknowledge, explain chemistry, emphasize qualification), the "how many years" question (use ranges, not specific numbers), and the visual-expectation trap ("my neighbor's roof looks brand new" — reset honestly). The qualifying window is real and reps must hold the line: roofs outside the window get an honest decline and an alternative recommendation, not a rejuvenation proposal that won't perform. Rejuvenation is not a coating, not a leak fix, and not a substitute for replacement; conflating any of those is the textbook ethics failure on this product. Done well, rejuvenation is a real product that fits naturally into a broader maintenance program — the rep who positions it as proactive care rather than as a miracle cure builds long-term trust and repeat business.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 5 AND s.section_number = '13'
);

-- Part 3 / Ch 6 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Storm-related calls are some of the most sensitive a rep will handle. The customer is anxious, often facing real damage, and frequently focused on insurance. The pull toward overpromising is strong — promising a claim approval, certifying damage as storm-related when it isn't, or scoping work to maximize the claim rather than to address what actually needs fixing.

This is also where reps most often run afoul of regulatory boundaries. In some states, storm-chaser contractors have produced enough customer harm that regulators watch this category closely. California has its own framework that affects what reps can and can't say.

This module gives reps the discipline to handle storm-damage calls honestly: document thoroughly, communicate clearly, hold the line on what they can and can't certify, and maintain professional integrity when customers and sometimes insurance adjusters push for more aggressive positioning.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '1'
);

-- Part 3 / Ch 6 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof documents what we observe; we don't certify damage causation, predict insurance outcomes, or scope work to maximize claims. We do honest inspection, honest documentation, and honest scope.

That's the entire framework. Everything in this module is how to live up to it in real customer situations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '2'
);

-- Part 3 / Ch 6 / Sec 3: What Reps Can Do on Storm-Damage Calls
UPDATE sections SET
  content_markdown = $mfst$- Inspect the roof thoroughly per Chapter 12
- Document conditions with photos, severity ratings, and written notes
- Identify conditions consistent with storm or hail damage (with appropriate caveats)
- Provide the customer with documentation suitable for an insurance carrier
- Recommend repair or replacement scope based on what was observed
- Coordinate timing with insurance adjuster visits when appropriate
- Refer the customer to qualified inspectors or specialists when needed$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '3'
);

-- Part 3 / Ch 6 / Sec 4: What Reps Cannot Do
UPDATE sections SET
  content_markdown = $mfst$- **Certify hail damage or storm damage for insurance purposes** unless specifically qualified, trained, and authorized
- **Promise insurance approval** or specific claim outcomes
- **Promise specific insurance payout amounts**
- **Scope work to "maximize the claim"** rather than to address what actually needs fixing
- **Tell customers their carrier "must" cover the work** — coverage is between the customer and their carrier
- **Negotiate with insurance adjusters** on behalf of the customer in ways that exceed the rep's role
- **Sign documents that certify storm causation** without qualification and authorization

> **[SALES REP BOUNDARY]** Storm damage certification for insurance purposes is qualified work. Reps document conditions and observe; reps do not certify causation. When a customer needs certification beyond inspection-level documentation, the rep escalates.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '4'
);

-- Part 3 / Ch 6 / Sec 5: The Honest Customer Language
UPDATE sections SET
  content_markdown = $mfst$The opening conversation when a customer calls about possible storm damage:

> "I'll do a complete inspection and document conditions thoroughly. We'll photograph everything, apply our severity ratings, and provide you a written report you can share with your insurance carrier. What I can't do is promise you what your carrier will or won't approve — that's between you and them, and it depends on your policy, your adjuster, and the specific findings. We do honest documentation and honest scope. We don't promise insurance outcomes, and any contractor who does should make you cautious."

Three things this language does:
1. Sets clear expectations about what the rep will and won't do
2. Reinforces the rep's role as documenter, not certifier
3. Plants a flag against contractors who overpromise — without bashing them by name$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '5'
);

-- Part 3 / Ch 6 / Sec 6: The Storm Damage vs. Trade Damage vs. Aging Damage Distinction
UPDATE sections SET
  content_markdown = $mfst$One of the most important things reps need to do on storm-damage calls is honestly distinguish between three sources of damage that often co-exist:

- **Storm damage** — wind-lifted shingles, hail bruising, debris impact, water-driven entry from extreme weather
- **Trade damage** — damage from HVAC technicians, electricians, painters, antenna installers, or other contractors who walked the roof
- **Aging damage** — normal wear and weathering consistent with the roof's age

These often look similar, especially to non-experts. A bruised shingle could be hail or a dropped tool. A lifted shingle could be wind or someone walking on it. A failed pipe boot could be storm-driven or simply aged out.

The rep's job is to document what's observed without overcertifying causation:

> "I see [condition]. That could be from [storm event / aging / trade work / impact damage]. I'm documenting what I observe, not certifying what caused it. Your carrier or a qualified inspector with authorization to certify storm damage will make that determination."

This language protects the customer, the rep, and USA Flat Roof's reputation. Customers frequently don't realize that the contractor who certifies damage as storm-related is taking on real responsibility — when the certification turns out to be inaccurate, problems follow.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '6'
);

-- Part 3 / Ch 6 / Sec 7: Hail Damage — A Specific Caution
UPDATE sections SET
  content_markdown = $mfst$Hail damage is the most common point where reps overstep. Hail bruising on shingles can be subtle, can look similar to other forms of damage, and is typically certified by qualified inspectors using specific training and protocols.

What reps may do:
- Photograph any conditions that may be consistent with hail (impact craters, soft spots in shingles, granule displacement patterns)
- Note the customer's report of recent hail events
- Recommend the customer have a qualified hail inspector or insurance adjuster evaluate

What reps may NOT do:
- Mark conditions as "hail damage" in a way that certifies causation
- Promise the carrier will accept hail damage findings
- Encourage the customer to file a claim based on the rep's observations alone

> "I see some impact-style marks on your shingles. They could be hail. They could also be from foot traffic, dropped tools, or other impacts. I'm not qualified to certify hail damage for insurance purposes. What I can do is document what I observe and recommend you have a qualified hail inspector evaluate. Your carrier will likely send their own adjuster."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '7'
);

-- Part 3 / Ch 6 / Sec 8: The Insurance Adjuster Conversation
UPDATE sections SET
  content_markdown = $mfst$Reps sometimes coordinate inspection timing with adjuster visits. The role is documentation and presence, not advocacy in ways that exceed the rep's authorization.

What reps may do:
- Be present during the adjuster's inspection if the customer requests it
- Walk the adjuster through observed conditions
- Provide the rep's documentation as a reference
- Answer the adjuster's questions about what was observed
- Explain proposed scope of work

What reps may NOT do:
- Argue with the adjuster about coverage decisions
- Push the adjuster toward specific findings
- Promise the customer the adjuster will agree with the rep's documentation
- Imply the rep has more authority over the claim than they actually do

> "I'm happy to be there when the adjuster visits. I'll walk through what I documented and answer their questions. The decision on coverage is between you and your carrier — I'm not there to advocate for a specific outcome, just to provide the information I gathered during inspection."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '8'
);

-- Part 3 / Ch 6 / Sec 9: When the Customer Says "Insurance Will Cover It"
UPDATE sections SET
  content_markdown = $mfst$Customers often arrive convinced their insurance will cover the work, sometimes based on what other contractors told them. The rep handles this without dismissing the possibility but without confirming an outcome the rep can't control.

> "Possibly. We'll document conditions thoroughly and you'll have what you need to file the claim. Coverage depends on your specific policy, your deductible, the carrier's findings, and the specific damage. I won't promise you an outcome — that's not honest. What I'll do is provide the documentation that supports your claim, and you'll work with your carrier on the coverage decision. If the claim is approved, great. If it's partially approved or denied, we'll talk about how you want to proceed."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '9'
);

-- Part 3 / Ch 6 / Sec 10: When Insurance Doesn't Cover (or Partially Covers)
UPDATE sections SET
  content_markdown = $mfst$Sometimes the carrier denies the claim or covers less than the customer expected. The rep's role is to handle the conversation honestly without bashing the carrier.

> "I understand this isn't the outcome you were hoping for. The carrier's decision is theirs to make based on your policy and their adjuster's findings. We'll proceed based on what you decide — the work still needs to be done, and we'll find an honest path forward whether the claim covers it fully, partially, or not at all. If you want, we can discuss phased work or financing options."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '10'
);

-- Part 3 / Ch 6 / Sec 11: When Other Contractors Overpromise
UPDATE sections SET
  content_markdown = $mfst$Reps will encounter customers who've been quoted by storm-chaser contractors with aggressive insurance promises. The rep handles this without dismissing the customer's concern but without bashing the other contractors directly.

> "I hear what they told you. I can't speak to their proposal specifically. What I'll tell you is that any contractor who promises a specific insurance outcome is making a promise they can't actually keep — your carrier makes that decision, not the contractor. We do honest inspection and documentation, and we let your carrier make the coverage call. If the other contractor's promise turns out to be accurate, great. If it doesn't, you'd want to be working with someone who's been honest with you from the start."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '11'
);

-- Part 3 / Ch 6 / Sec 12: When the Customer Wants Scope Inflated to "Maximize the Claim"
UPDATE sections SET
  content_markdown = $mfst$This comes up. Customers, sometimes coached by aggressive contractors, want extra work added to the proposal to "make sure the claim covers everything."

The rep's response:

> "I hear what you're asking. We don't scope work to maximize claims — we scope work to address what actually needs fixing. If the inspection shows additional issues that should be in the scope, we'll include them. If it doesn't, we won't add them just to inflate the claim. That practice creates problems for the customer down the road — sometimes legal problems — and it's not how we operate. The scope on paper will reflect what your roof actually needs."

The rep doesn't capitulate on this even when the customer is frustrated. Inflated scope is fraud, and reps don't participate.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '12'
);

-- Part 3 / Ch 6 / Sec 13: Documentation Standards on Storm-Damage Calls
UPDATE sections SET
  content_markdown = $mfst$Documentation matters more on storm-damage calls than on most other inspections. Reps should:

- Photograph all four building elevations
- Photograph each roof slope or quadrant from elevated view
- Photograph every observed condition with reference scale
- Photograph the broader context, not just close-ups (a close-up of one bruised shingle without a wider photo is less useful)
- Note date and time of inspection
- Note any customer-reported event date (storm date, etc.) clearly attributed as customer report
- Note inspection method (drone, ladder edge, roof walk)
- Apply severity ratings using the four-point scale
- Avoid certification language ("hail damage confirmed") in favor of observational language ("conditions consistent with hail or other impact")

The documentation should be defensible, honest, and clearly attributable to what the rep observed.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '13'
);

-- Part 3 / Ch 6 / Sec 14: Common Sales Mistakes on Storm-Damage Calls
UPDATE sections SET
  content_markdown = $mfst$- Promising insurance approval
- Certifying hail damage without qualification
- Inflating scope to "maximize the claim"
- Telling customers the carrier "must" cover specific items
- Bashing other contractors who made aggressive promises
- Capitulating to pressure from customers or adjusters
- Skipping thorough documentation because the call feels urgent
- Conflating storm damage with aging or trade damage in the documentation
- Using certification language ("confirmed hail damage") instead of observational language
- Refusing to inspect because the call feels insurance-driven (the customer still deserves an honest inspection)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '14'
);

-- Part 3 / Ch 6 / Sec 15: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Insurance will cover this" | Document thoroughly; explain you can't promise carrier outcomes |
| "Other contractor said this is hail damage" | Note the report; document what you observe; recommend qualified hail inspector if needed |
| "Can you mark this as storm damage?" | Document what you observe with appropriate language; don't certify causation |
| "Add more to the scope so insurance covers it" | Decline; explain the scope reflects what the roof needs, not what the claim might cover |
| "Why won't you just say it's hail?" | Explain that you document observations, not certify causation; suggest qualified inspector |
| "My adjuster is coming next week — can you be there?" | Yes; clarify your role is documentation, not advocacy |
| "My claim was denied — what now?" | Acknowledge; offer honest path forward (phased work, financing, etc.) |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '15'
);

-- Part 3 / Ch 6 / Sec 16: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Storm-damage calls are sensitive because customer anxiety, insurance dynamics, and contractor temptation all converge. The rep's discipline: document conditions thoroughly, communicate observations clearly, and hold the line on what reps can and cannot certify. Reps observe; reps don't certify causation. Reps document; reps don't promise insurance outcomes. Reps scope based on what the roof needs; reps don't inflate scope to maximize claims. The conversation works when reps use observational language ("conditions consistent with hail") rather than certification language ("hail damage confirmed"), and when reps clearly distinguish their role from the carrier's role and from a qualified inspector's role. Customers will sometimes push for more aggressive positioning — they've been coached by contractors who promised more than they could deliver. The honest answer remains the same regardless of pressure: USA Flat Roof does honest inspection, honest documentation, and honest scope. That position protects the customer, the rep, and the company's reputation in a category where reputational risk is genuinely real.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 6 AND s.section_number = '16'
);

-- Part 3 / Ch 7 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Photos are the most important inspection deliverable a rep produces. Bad photos make good inspections worthless. Good photos make ordinary inspections defensible. A rep who can document a roof thoroughly with quality photographs has built the foundation for every conversation that follows: the customer's understanding, the proposal's credibility, the production team's planning, and the warranty system's eventual coverage.

Photography on roof inspections is not an art — it's a discipline. Reps who treat it as a checklist deliver consistent results. Reps who treat it as "snap a few pictures while you're up there" deliver inconsistent results that come back to bite the company months later when documentation is needed.

This module is the dedicated photo training piece for USA Flat Roof. It expands beyond the photo standards in Chapter 12 to cover the practical mechanics, framing decisions, drone-specific considerations, customer-presentation considerations, and the difference between photos that serve sales and photos that serve litigation, warranty, and production.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '1'
);

-- Part 3 / Ch 7 / Sec 2: The Three Audiences for Roof Photos
UPDATE sections SET
  content_markdown = $mfst$Before any photo is taken, reps should remember who will see it.

### The customer

Photos show customers what they can't see for themselves. Most homeowners and property managers will never walk their own roof. Photos give them a basis to understand findings, compare options, and trust the rep's recommendation.

What the customer needs from photos:
- **Clarity** — they can see the condition the rep is describing
- **Context** — they can locate the photo on the roof
- **Honest framing** — the photo represents conditions accurately, not exaggerated to upsell or minimized to placate

### The company

Photos protect USA Flat Roof's interests across the project lifecycle.

What the company needs from photos:
- Pre-work documentation establishing existing conditions
- Scope-supporting evidence
- Defensible records for any future dispute
- Production planning detail

### The warranty system

Many manufacturer warranties — especially on coatings, restoration, SPF, and rejuvenation — require specific documentation submitted within defined windows. Photos that don't meet the manufacturer's documentation standard can void coverage years later.

What the warranty system needs:
- Pre-application photos showing substrate and condition
- Application photos showing coverage and workmanship
- Post-application photos
- Documentation suitable for manufacturer review

A single photo often serves all three audiences. The discipline is taking it well enough that it does.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '2'
);

-- Part 3 / Ch 7 / Sec 3: The Equipment Reps Use
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof reps typically work with:

- **Smartphone camera** — primary tool for most inspections; modern phone cameras are entirely sufficient for inspection-quality photos
- **Drone** — for multi-story commercial, tile roofs, and complex geometries (Section on drone-specific guidance below)
- **Reference scale items** — business card, retractable tape measure, ruler, chalk, or wooden marker for size and ponding outline
- **Cleaning cloth** — phone lens gets fingerprints, dust, and (on commercial roofs) gravel grit; clean it
- **Backup power** — phone battery dies on long inspections; a portable charger is part of the kit

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard equipment kit, drone authorization, and any company-issued imaging tools.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '3'
);

-- Part 3 / Ch 7 / Sec 4: The Eight Universal Photo Rules
UPDATE sections SET
  content_markdown = $mfst$These apply to every photo on every inspection, regardless of system or context.

### Rule 1: Clean the lens

A smudged lens produces blurry, low-contrast photos. Reps should clean their lens before starting and again whenever they notice it's dirty. This is the single most-overlooked photography practice.

### Rule 2: Hold the phone or camera steady

Movement during capture produces blur. Hold the phone with both hands, brace against a stable surface where possible, exhale before pressing the shutter. On a roof in light wind, this matters even more.

### Rule 3: Take overview shots before close-ups

Every inspection should produce a series that goes from wide to specific. The customer and the production team need to know *where* the close-up is on the roof. A close-up of a damaged shingle without a wide-angle context shot is much less useful.

The pattern:
1. Wide shot of the roof or quadrant
2. Medium shot showing the area with the issue
3. Close-up of the specific condition with reference scale

### Rule 4: Use reference scale on damage shots

Without scale, photos misrepresent size. A small crack and a large crack look identical without something for comparison. Use a business card, retractable tape, ruler, or chalk mark for size reference.

### Rule 5: Photograph honestly

Photos can be framed to make a problem look bigger or smaller than it is. Reps don't do this. The framing should represent the condition as it actually exists, neither exaggerated for sales effect nor minimized to avoid customer alarm.

### Rule 6: Capture in even lighting where possible

Harsh midday shadows obscure detail. Backlighting blows out highlights. Reps work with the light they have, but they pay attention. If a critical condition is hard to see in current light, take multiple angles or note that follow-up photography may be needed.

### Rule 7: Frame for the condition, not the rep

The photo's purpose is to show the condition, not to feature the rep's hand, foot, or shadow. Body parts in frame should be intentional (e.g., a hand for scale) or out of frame entirely.

### Rule 8: Stay in focus on what matters

Modern phones autofocus reliably but sometimes lock onto the wrong element. Tap the screen to set focus on the actual subject — usually the closest element of damage or interest. A photo focused on the wrong thing wastes the trip.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '4'
);

-- Part 3 / Ch 7 / Sec 5: The Five Photo Types Every Inspection Needs
UPDATE sections SET
  content_markdown = $mfst$Reps should think in terms of five photo categories. Every inspection produces some of each.

### Type 1: Building and access photos

Establish the property and the inspection scope.

- All four exterior elevations from ground level
- Roof access point (ladder position, hatch, stair)
- Property identifying features (without identifiable house numbers if photos may be used in marketing)
- Adjacent structures and surroundings if relevant

### Type 2: Roof overview photos

Show the roof as a whole.

- Each slope or quadrant from elevated viewpoint (drone or ladder edge)
- Wide-angle shot showing the full layout
- Penetration and equipment layout
- Drainage layout (drains, scuppers, downspouts)

### Type 3: Detail and condition photos

Show specific items.

- Every penetration (pipe boot, vent, skylight, drain, scupper, conduit, HVAC curb)
- Every transition (parapet, sidewall, headwall, dormer, chimney)
- Every flashing
- Every valley
- Every termination

### Type 4: Damage and severity photos

Show what's wrong, with appropriate scale.

- Each documented condition with severity rating
- Reference scale included on size-relevant shots
- Multiple angles on significant findings
- Context shots showing where the damage sits on the roof

### Type 5: Substrate, drainage, and supporting photos

Show conditions that affect recommendation logic.

- Substrate visible at edges, drains, or worn areas (especially on coated or recovered roofs)
- Ponding evidence (chalk-outlined extent, dirt rings, biological growth in low areas)
- Walk-test soft areas marked
- Attic interior if accessible (deck, insulation, ventilation, water staining)
- Interior leak evidence if reported$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '5'
);

-- Part 3 / Ch 7 / Sec 6: Before and After Documentation
UPDATE sections SET
  content_markdown = $mfst$For any project that involves work — repair, restoration, replacement — before-and-after documentation is critical. The standard:

### Before photos

Establish existing conditions before any work begins. Comprehensive set following the five photo types above. The before set is what the customer compares the after set to, and it's what the warranty system uses to confirm work was done over qualifying conditions.

### Progress photos

Document work in progress. For coating projects: substrate prep, primer application, fabric reinforcement, detail coat, field coat. For replacement projects: tear-off, deck condition, insulation and cover board, membrane installation, flashing details.

### After photos

Document completed work. Same locations as the before photos, same angles where possible, same lighting where possible. The customer should be able to do a side-by-side comparison.

### Best practices for before-and-after pairs

- Same location, same angle, same approximate framing
- Same time of day where possible (lighting consistency)
- Reference items in both photos where possible
- Date-stamped or otherwise logged so the timeline is clear

> **[CHECK MANUFACTURER]** Many manufacturer warranties on coatings, restoration, and SPF require before-and-after documentation submitted within specified windows. Confirm against current warranty documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '6'
);

-- Part 3 / Ch 7 / Sec 7: Reference Scale and Measurement Photos
UPDATE sections SET
  content_markdown = $mfst$Reps need a consistent practice for showing size in photos.

### What reference scale items work

- **Business card** — universally recognized size; reps almost always have one
- **Retractable tape measure** — extended to show specific dimensions; best for damage areas where exact size matters
- **Ruler** — same purpose, smaller scale
- **Chalk mark** — for outlining ponding extent or marking inspection points
- **Hand or finger** — last resort; less reliable than dedicated scale items

### When reference scale matters most

- Hail or impact damage close-ups
- Crack or split close-ups
- Granule loss patches
- Membrane punctures or tears
- Ponding ring extent
- Substrate damage close-ups
- Any condition where size is a relevant variable for severity rating or scope

### When reference scale isn't necessary

- Wide overview shots
- Penetration photos where the penetration itself provides obvious scale
- Aesthetic roof photos for the customer's records$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '7'
);

-- Part 3 / Ch 7 / Sec 8: Documenting Ponding Water
UPDATE sections SET
  content_markdown = $mfst$Ponding deserves its own photographic discipline because it's so commonly mishandled.

### On a dry-day inspection (most common)

Ponding evidence is documented even though water isn't currently present.

- **Outline the extent** with chalk where dirt rings show ponding boundaries
- **Photograph the chalk outline** with a wide context shot showing the ponding area relative to drains
- **Photograph the dirt ring** with reference scale
- **Photograph any biological growth** in the ponded area
- **Photograph the membrane condition** within the pond — discoloration, accelerated wear, or surface damage

### On a wet-day inspection

When water is currently standing:

- Photograph the standing water with depth indication where possible (parapet height, ruler in pond)
- Photograph the time elapsed since rain stopped (if known)
- Photograph the relationship to drains and overflow

### Why this matters

A customer who's told "your roof has chronic ponding" needs to see the dirt rings, the biological growth, and the chalk-outlined extent. Without photos, "chronic ponding" is the rep's word against the customer's belief that "it just sits sometimes." With photos, the conversation has evidence.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '8'
);

-- Part 3 / Ch 7 / Sec 9: Substrate and Coating-Layer Documentation
UPDATE sections SET
  content_markdown = $mfst$On coated roofs, recovered roofs, or any system where what's underneath matters to the recommendation, photos of the substrate are critical.

### Where to photograph substrate

- **At edges** — where the membrane or coating terminates against parapets, terminations, or coping
- **At drains** — where wear or thinning often exposes substrate
- **At damaged or worn areas** — where the original system shows through
- **At cut areas or repairs** — where the cross-section is visible

### What to capture

- The material type visible (BUR gravel, modified bitumen cap sheet, TPO membrane, etc.)
- Layer transitions if multiple substrates are visible
- Condition of the substrate at the visible point
- Reference scale where the substrate area's size matters

The substrate determines future scope options. A rep who skips substrate documentation forces follow-up inspections and undermines proposal credibility.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '9'
);

-- Part 3 / Ch 7 / Sec 10: Drone Photography
UPDATE sections SET
  content_markdown = $mfst$Drone use has grown significantly in commercial and complex residential inspections. Drones produce wide-area photos no ladder can match, and they let reps inspect tile roofs, multi-story commercial, and other complex geometries safely.

### When drone photography is the right choice

- Multi-story commercial buildings where roof access is difficult or unsafe
- Tile roofs where walking risks tile damage
- Complex roof geometries where walking would miss areas
- Initial overview before deciding whether to walk
- Conditions or weather that make walking unsafe but inspection is needed

### Drone-specific photography rules

The eight universal rules apply, plus:

- **Maintain consistent altitude** for comparable photos across a roof
- **Capture orthographic-style overheads** (camera pointed straight down) for the cleanest documentation; supplement with angled views where needed
- **Pay attention to wind effects** on photo stability — drones in wind produce shaky photos
- **Plan the flight pattern** to ensure all areas are covered
- **Confirm photo coverage before landing** — easier to fly back up than to return another day
- **Document the flight** with the date, time, weather, and operator

### Drone limitations reps need to remember

- Drones can't replace hands-on inspection of seams, fastener tightness, soft spots underfoot, or membrane condition close-up
- Drones may miss areas under HVAC equipment, behind parapets, or in shadow
- Drone photos at extreme zoom degrade quickly; close-ups should be taken in person where possible

> **[VERIFY LOCALLY]** California and federal drone regulations apply to commercial drone use. Confirm operator certification, airspace restrictions, and customer permission before flying.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's drone use policy, certified operators, equipment standards, and integration with inspection workflow.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '10'
);

-- Part 3 / Ch 7 / Sec 11: Customer-Facing Photo Presentation
UPDATE sections SET
  content_markdown = $mfst$Photos that serve the customer well differ from photos that serve only internal documentation. The customer needs to *understand* what they're seeing.

### Organizing photos for the customer

The customer's photo package typically includes:

1. Property and access establishing shots
2. Roof overview shots (each slope or quadrant)
3. Findings organized by severity rating, with each finding's location identified
4. Detail close-ups for findings that warrant them
5. Reference shots showing scope context (where work would happen)

### Captions and context

Photos without explanation can confuse customers. Each significant finding should have a caption or note that:

- Identifies where on the roof the photo was taken
- Describes what condition is visible
- States the severity rating
- Notes any scope implication

> "South slope, near the chimney — failed pipe boot showing visible cracking at the collar. Severity: Repair Recommended. Scope: replace pipe boot during proposed work."

### What to avoid in customer-facing photos

- **Misleading framing** that exaggerates problems for sales effect
- **Cherry-picking** photos to support a recommendation while hiding conditions that complicate it
- **Aesthetic-only photos** without documentation value
- **Photos taken at unusual angles** that customers can't relate to the actual roof
- **Stock photos or generic illustrations** mixed with property-specific photos in ways that aren't clear$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '11'
);

-- Part 3 / Ch 7 / Sec 12: Good vs Bad Photo Examples
UPDATE sections SET
  content_markdown = $mfst$Reps should learn to recognize the difference between a good inspection photo and a bad one.

### A good photo

- In focus on the relevant subject
- Even lighting on the subject
- Clear context (the photo's location on the roof is identifiable)
- Reference scale where size matters
- Honest framing — no exaggeration, no minimization
- Clean lens, no smudges or obstructions
- Steady capture, no motion blur
- Wide enough to provide context, close enough to show detail

### A bad photo

- Out of focus or focused on the wrong element
- Harsh shadows obscuring the subject
- No context — can't tell where the photo was taken
- Missing scale on damage shots
- Framed at extreme angles that exaggerate or minimize
- Smudged lens producing blur
- Motion blur from unsteady capture
- Either too wide (no detail) or too close (no context)

### Practical training: review your own photos

After every inspection, reps should review their photo set before leaving the property. Common issues to catch:

- Did I get all four building elevations?
- Did I get every penetration?
- Did I get reference scale on damage shots?
- Are any photos blurry, dark, or poorly framed?
- Can I locate every photo on the roof from the photo alone?
- If I had to hand this set to someone else for proposal writing, would they understand the roof?

If the answer to any of these is no, the rep takes additional photos before leaving. Returning later for missed photos is expensive and unprofessional.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '12'
);

-- Part 3 / Ch 7 / Sec 13: Safety Reference in Photos
UPDATE sections SET
  content_markdown = $mfst$Some photos serve as safety documentation: the rep's PPE, the ladder position, the access conditions. These photos protect the company in case of incident or dispute about how the inspection was conducted.

When safety reference is appropriate:

- Ladder access conditions for any roof access
- PPE worn during inspection
- Conditions encountered (wet roof, debris, broken tiles, structural concerns)
- Decision points where the rep declined to walk a roof for safety reasons

Safety reference photos don't need to dominate the inspection set, but a few establishing shots are good practice.

> **[SALES REP BOUNDARY]** Reps may decline a roof walk based on safety judgment. A photo documenting the conditions that led to declining the walk is appropriate documentation, not an admission of incomplete inspection.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '13'
);

-- Part 3 / Ch 7 / Sec 14: Photo Organization After the Inspection
UPDATE sections SET
  content_markdown = $mfst$Photos must be organized after the inspection. This is part of the documentation responsibility, not an afterthought.

### Organization standards

- Each photo associated with the project / property
- Each photo labeled or tagged by location, condition, and severity rating
- Before, during, and after sets clearly separated for projects involving work
- Customer-facing photos prepared in a separate package from internal-only photos
- Original files preserved (not edited or compressed beyond the originals)

### What to avoid

- Mixing photos from multiple properties without clear separation
- Editing photos in ways that change condition representation (color correction is fine; cropping that misrepresents framing is not)
- Deleting photos that don't support the recommendation (keep the full set; let the proposal communicate selectively)
- Using customer-facing photos for marketing without explicit permission

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's photo storage system, naming conventions, retention period, and customer-sharing standards.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '14'
);

-- Part 3 / Ch 7 / Sec 15: Common Photo Mistakes Reps Make
UPDATE sections SET
  content_markdown = $mfst$### Mistakes in capture

- Skipping reference scale on damage shots
- Taking too few photos (treating it as a chore rather than a discipline)
- Skipping the wide-overview shots that anchor close-ups
- Capturing in harsh light or shadow without alternatives
- Failing to clean the lens before starting
- Not reviewing the set before leaving the property

### Mistakes in framing

- Misleading framing that makes problems look bigger or smaller
- Cherry-picking only condition that supports the recommendation
- Cropping out context that affects interpretation
- Including the rep's body or shadow in the frame unintentionally

### Mistakes in organization

- Not labeling photos by location and condition
- Mixing photos from multiple properties
- Not preserving originals
- Skipping documentation of safety conditions or refused inspections
- Deleting photos to "clean up" the set

### Mistakes in customer presentation

- Sharing the full unorganized set with the customer
- Sharing only photos that support the most expensive scope
- Sharing without captions or context
- Sharing photos that are technically defensible but misleading in framing$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '15'
);

-- Part 3 / Ch 7 / Sec 16: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Situation | Photo discipline |
|---|---|
| Damage close-up | Include reference scale |
| Roof overview | Wide-angle, even lighting, multiple angles |
| Coated roof | Substrate visible at edges where possible |
| Ponding evidence | Chalk-outline extent on dry day; depth indication on wet day |
| Penetration | Wide context plus close detail |
| Drone use | Orthographic plus angled; consistent altitude; document flight |
| Before / after | Same location, angle, and lighting where possible |
| Refused walk | Document the conditions that led to declining |
| Customer package | Captions, context, severity ratings; honest framing |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '16'
);

-- Part 3 / Ch 7 / Sec 17: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Roof photography is a discipline, not an art. Reps follow eight universal rules — clean lens, steady capture, overview before close-ups, reference scale on damage, honest framing, even lighting, frame for the condition, focus on what matters. Five photo types should appear on every inspection: building and access, roof overview, detail and condition, damage and severity, substrate and drainage. Reference scale matters on size-relevant shots. Ponding gets chalk-outlined and photographed even on dry days. Substrate photos matter on coated roofs. Before-and-after pairs serve customers, the company, and warranty registration. Drones supplement but don't replace hands-on inspection. Customer-facing photos need captions and context, organized by severity and location. Reps review their photo set before leaving the property to catch missed shots while it's still cheap to fix. Photos are the most important inspection deliverable — taking them well is what separates a thorough inspection from a sales pitch.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 7 AND s.section_number = '17'
);

-- Part 3 / Ch 8 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Roofing has a reputation problem. Customers walk into roof conversations carrying memories of pushy contractors, manufactured urgency, and the storm-chaser pattern. Some of those memories are direct experience; some are inherited from neighbors, news stories, and a category-wide pattern that's earned the reputation it has. A rep who walks into that conversation using pressure tactics — even subtle ones — confirms what the customer already feared and loses the deal, the relationship, or both.

The alternative isn't passive. The alternative is *consultative selling*: a disciplined approach where the rep's value is the inspection, the documentation, the clarity of options, and the honest recommendation. Consultative reps close deals — sometimes more than pressure reps do, because consultative reps build the long-term relationship account that pressure reps spend down to zero.

This module is the philosophy and the practical patterns. It's the module that explains how every other module in this book actually gets delivered to the customer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '1'
);

-- Part 3 / Ch 8 / Sec 2: What Pressure Selling Actually Looks Like
UPDATE sections SET
  content_markdown = $mfst$Pressure selling isn't always loud. The high-volume, hard-close, sign-tonight version exists, but the more common version is subtler:

- **Manufactured urgency** — "this price is only good through Friday," "we have a crew in your neighborhood Tuesday so we can give you a deal"
- **Anchored fear** — "your roof could collapse," "this could fail any day," without inspection-supported reasoning
- **Exclusionary framing** — "you don't want to be the only home on the block with the old roof"
- **Authority pressure** — "I've been doing this 30 years, trust me"
- **Quote shopping discouragement** — "I can give you the best price right now if we don't have to wait for other quotes"
- **Withholding information** — not explaining alternatives, not showing the cheaper option that would also work, not naming the disqualifying conditions
- **Scope inflation** — adding work the roof doesn't need to support a higher number
- **Insurance overpromising** — "we'll get this approved for sure" (Module 6)
- **Decision shortcuts** — pushing the customer to commit before they've understood
- **Same-day-only discounts** — "if you sign today, I can take 15% off"

These tactics work in the short term and fail in the long term. Reps who use them get the close, lose the relationship, and watch the customer warn others.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '2'
);

-- Part 3 / Ch 8 / Sec 3: What Consultative Selling Actually Looks Like
UPDATE sections SET
  content_markdown = $mfst$Consultative selling treats the rep as an advisor whose value is honest expertise, not a closer whose value is the sale. The pattern across every interaction:

- **Inspect thoroughly before recommending anything**
- **Document conditions with photos and severity ratings**
- **Walk the customer through findings honestly**
- **Present options that span the realistic range**
- **Recommend what the roof actually needs, not what's easiest to close**
- **Acknowledge limitations, uncertainties, and trade-offs honestly**
- **Defer to the written proposal rather than verbal pricing**
- **Accept the customer's pace — including their right to take time, get other quotes, and sleep on it**
- **Decline work that doesn't fit even when the customer wants it**

The consultative rep is not slower or less effective than the pressure rep. The consultative rep produces better-fit work, fewer callbacks, more referrals, and longer-term customer relationships.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '3'
);

-- Part 3 / Ch 8 / Sec 4: The Mindset Shift
UPDATE sections SET
  content_markdown = $mfst$The most important shift is internal. Reps who think of customers as "deals to close" behave differently from reps who think of customers as "relationships to start."

A deal-to-close mindset asks:
- How fast can I close this?
- What scope produces the highest margin I can support?
- What can I say to overcome the objection?
- Will I lose this if the customer talks to anyone else first?

A relationship-to-start mindset asks:
- What does this customer's roof actually need?
- What's the right scope for this customer's situation?
- What information does the customer need to decide well?
- How does this customer remember me in five years when their roof needs more work?

Reps who internalize the second mindset don't have to remember to do the right thing — they default to it.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '4'
);

-- Part 3 / Ch 8 / Sec 5: The Long-Term Relationship Math
UPDATE sections SET
  content_markdown = $mfst$Reps sometimes ask whether consultative selling actually pays off. The math:

A residential customer who buys a $15,000 re-roof from a pressure rep is unlikely to call the same contractor when the next maintenance need comes up — because they remember being pressured, even if the work was fine. They're also unlikely to refer neighbors.

A residential customer who buys the same $15,000 re-roof from a consultative rep — including being told honestly that they didn't need a more expensive scope — is likely to call back for maintenance, repairs, and eventually replacement on the next roof. They're also likely to refer neighbors, family, and the people who ask "who did your roof?" when they see the work in progress.

Over 10 years, the consultative customer is worth multiples of the pressure customer. Over 20 years, the math isn't close. Reps who understand this don't have to be talked into consultative selling — the incentive structure already rewards it.

The same logic applies even more strongly on commercial work, where property managers and building owners often manage multiple buildings and refer contractors to peers.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '5'
);

-- Part 3 / Ch 8 / Sec 6: Recognizing Pressure Tactics in Others
UPDATE sections SET
  content_markdown = $mfst$Customers comparing USA Flat Roof's quote against a pressure-selling competitor often need help recognizing the pattern. The rep doesn't bash the competitor — but the rep does explain the patterns customers should be alert to.

> "When you're comparing quotes, here are a few things worth noticing. Are the proposals giving you the same scope, or are they actually different? Is anyone pushing you to decide today or this week? Is anyone promising specific insurance outcomes? Is anyone giving you a number without seeing the roof in person? If any of those show up, slow down. We don't operate that way, and any contractor who does should make you cautious — about their pricing, their scope, and their long-term reliability."

This language calls out pressure tactics without naming the competitor, and it positions USA Flat Roof's behavior as the contrast.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '6'
);

-- Part 3 / Ch 8 / Sec 7: The Patterns Reps Should Practice
UPDATE sections SET
  content_markdown = $mfst$### Pattern 1: Inspect first, recommend second

The rep doesn't recommend during inspection. The rep observes, documents, and saves the recommendation for after the inspection is complete. Customers who watch a rep make pronouncements while still on the roof are watching a pressure pattern.

> "Let me finish the inspection before I give you my read. I want to see everything, document conditions, and put the recommendation together based on the full picture — not based on whatever I happened to notice first."

### Pattern 2: Defer verbal pricing to written proposals

The customer asks for a number. The rep deflects to the proposal honestly.

> "I'd rather give you an accurate number on paper than a guess in person. The price depends on the specific scope, and I want that scope written down so we're both working from the same understanding. You'll have the proposal within [timeframe]."

### Pattern 3: Present options across the realistic range

The customer should see what the cheapest realistic option is, what the recommended option is, and what the longest-life option is. Hiding the cheaper option to push the more expensive one is a pressure tactic, even when subtle.

> "Here are three options that all make sense for your roof. The first is the cheapest realistic answer; the second is what I'd recommend if it were my building; the third is the longest-life option. I'll walk you through what each one does, what it doesn't do, and why I'd lean toward the middle one."

### Pattern 4: Acknowledge limitations and trade-offs

Every option has trade-offs. Reps who only describe upsides are selling, not advising.

> "The trade-off on this option is that it costs more up front but extends life by [range]. If you're staying in the building long-term, the math probably works in your favor. If you might sell in two years, the cheaper option is probably the right call. Both are valid; the answer depends on your situation."

### Pattern 5: Accept the customer's pace

Customers want time to think, get other quotes, talk to a partner, sleep on the decision. The consultative rep accepts this without pressure.

> "Take whatever time you need. Get other quotes if you want — I'd rather you compare and feel confident than feel rushed. The proposal is good for [timeframe]; if you have questions, I'm happy to walk through anything. No pressure on timing from our end."

### Pattern 6: Decline work that doesn't fit

The customer wants restoration on a non-qualifying roof. The customer wants replacement on a roof that doesn't need it. The customer wants scope inflated for an insurance claim. The consultative rep declines, honestly and without drama.

> "I'm not going to write that proposal because I don't believe it'll perform on this roof. I know it's not the answer you were hoping for. What I can do is [alternative], and you decide from there."

### Pattern 7: Be honest about uncertainty

Reps don't know everything. Pretending to know is a pressure tactic. Acknowledging uncertainty is consultative.

> "Honestly, without [further investigation / documentation / inspection], I can't tell you for certain. What I can tell you is what I observed and what's likely. If certainty matters for your decision, here's what we'd need to do to get it."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '7'
);

-- Part 3 / Ch 8 / Sec 8: When the Customer Mistakes Honesty for Weakness
UPDATE sections SET
  content_markdown = $mfst$Some customers — usually those who've been conditioned by pressure-selling experiences — interpret honesty as uncertainty and consultative behavior as lack of expertise. They want the confident pronouncement, the same-day discount, the urgent close.

The rep doesn't capitulate to match that expectation. The rep explains the difference.

> "I notice you're looking for a more definitive answer. I want to give you one. The reason I'm being careful is that giving you false certainty would be easier in the moment but worse in the long run. You'd make a decision based on something I don't actually know, and either it works out by luck or it doesn't and we both regret it. I'd rather give you the honest version, even when it's less satisfying than a confident pronouncement."

Most customers, given this framing, recognize that the consultative rep is being more professional, not less.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '8'
);

-- Part 3 / Ch 8 / Sec 9: The Quiet Confidence Pattern
UPDATE sections SET
  content_markdown = $mfst$Consultative selling isn't passive. The best consultative reps project quiet confidence — confident enough to recommend honestly, confident enough to decline work, confident enough to let the customer decide without pressure.

What this looks like:

- **Recommend the right answer clearly** — "for this roof, replacement is the right call" — without hedging
- **Maintain the recommendation under pressure** — "I understand the cheaper option appeals, but for this roof it won't perform"
- **Decline gracefully** — "I'm not going to write that proposal" — without apology or drama
- **Walk away from bad-fit work** — "we may not be the right contractor for what you're asking"
- **Accept losing the deal** — "I'd rather lose this and keep the relationship intact than win it and lose your trust"

Quiet confidence is what separates the consultative rep from the doormat. The rep advises, recommends, and decides what work to take on — without pressuring the customer's decision.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '9'
);

-- Part 3 / Ch 8 / Sec 10: When the Customer Tries to Pressure the Rep
UPDATE sections SET
  content_markdown = $mfst$Sometimes customers apply pressure to the rep — for a faster price, a deeper discount, a scope they want, a promise they want. The consultative rep handles this calmly.

> "I hear you on [request]. Let me explain why I'm not going to do that, and then we can talk about what I can do instead."

The rep doesn't capitulate to customer pressure for the same reason the rep doesn't apply pressure to the customer: pressure-driven decisions damage the relationship long-term.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '10'
);

-- Part 3 / Ch 8 / Sec 11: Common Sales Mistakes That Erode Trust
UPDATE sections SET
  content_markdown = $mfst$- Quoting prices verbally before the proposal is written
- Recommending scope before completing the inspection
- Hiding cheaper options to push more expensive ones
- Pushing same-day decisions
- Promising insurance outcomes
- Inflating scope to support higher prices
- Bashing competitors directly
- Capitulating when customers push back on the honest answer
- Manufacturing urgency that doesn't reflect actual roof conditions
- Telling customers their roof is "shot" or "done" without inspection-supported language$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '11'
);

-- Part 3 / Ch 8 / Sec 12: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Pressure pattern | Consultative alternative |
|---|---|
| "This price is only good through Friday" | "The proposal is good for [reasonable timeframe]" |
| "Sign today and I'll take 15% off" | "The price reflects the scope, not the timing" |
| "I'll give you a number right now" | "I'll have the written proposal within [timeframe]" |
| "Trust me, I've been doing this 30 years" | "Here's what I observed, here's what I'd recommend, here's why" |
| "Insurance will definitely cover this" | "We document conditions; coverage is between you and your carrier" |
| "Your roof could fail any day" | "Based on what I observed, here's the severity rating and what it means" |
| "Don't bother getting other quotes" | "Compare quotes if you want — slow decisions are usually better decisions" |
| Hiding the cheaper option | Presenting options across the realistic range |
| Inflating scope for higher margin | Recommending what the roof actually needs |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '12'
);

-- Part 3 / Ch 8 / Sec 13: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Pressure selling damages customer relationships, USA Flat Roof's reputation, and the rep's long-term career. Consultative selling is the alternative: inspect first, document thoroughly, recommend honestly, present options across the realistic range, acknowledge limitations and trade-offs, defer to written proposals, accept the customer's pace, and decline work that doesn't fit. The mindset shift is from "deals to close" to "relationships to start." The long-term math favors consultative selling because consultative customers come back, refer others, and trust the rep on bigger decisions over time. Quiet confidence — recommending clearly, holding the recommendation under pressure, declining gracefully — is what separates the consultative rep from the passive rep. The patterns in this module aren't restrictive; they're freeing. Reps who internalize them stop having to choose between being honest and being effective. The two become the same.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 8 AND s.section_number = '13'
);

-- Part 3 / Ch 9 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Repair-versus-replacement is one of the most common decisions a rep faces, and one of the most commonly mishandled. Reps oversell replacement on roofs that don't need it. Reps undersell repair on roofs that genuinely need replacement. Reps avoid the conversation when the answer is in the middle. Each pattern damages the customer relationship and erodes long-term trust.

This module gives reps a clear, repeatable approach to the repair-versus-replacement conversation. The full four-lens decision framework lives in Chapter 13. This module focuses on the specific repair-versus-replacement question and the language reps actually use to handle it well in the field.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '1'
);

-- Part 3 / Ch 9 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$Repair is right when the roof has remaining service life and the failures are localized. Replacement is right when the roof is at end of life or has disqualifying conditions. The middle cases — where the answer is close to the line — get the repair-plus-plan conversation.

That's the framework. Everything in this module is how to deliver it in real customer situations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '2'
);

-- Part 3 / Ch 9 / Sec 3: When Repair Is Clearly the Right Answer
UPDATE sections SET
  content_markdown = $mfst$Repair is the recommendation when:

- The roof has significant remaining service life based on system, age, and condition
- The failures are localized — specific tiles, specific pipe boots, specific seam areas, specific flashing details
- The rest of the roof is performing as expected
- No disqualifying conditions are present (wet insulation, severe ponding, structural concerns)
- The customer's goals match (maintaining the existing roof rather than replacing it)

### Sample customer language

> "Your roof has remaining service life and the issues we found are localized — [specific items]. The honest answer is repair, not replacement. We address [scope], document the work, and you stay on top of regular maintenance. Replacement on this roof would be wrong, both for your wallet and for any contractor who recommended it."

The clarity matters. Customers who hear a clear "this is the right answer for this roof" feel served, not sold.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '3'
);

-- Part 3 / Ch 9 / Sec 4: When Replacement Is Clearly the Right Answer
UPDATE sections SET
  content_markdown = $mfst$Replacement is the recommendation when:

- The roof is at the end of its useful service life given the system and age
- Failures are widespread, not localized
- Multiple recent leak repairs suggest a pattern, not isolated incidents
- Disqualifying conditions are present that take repair off the table:
  - Wet insulation across significant areas
  - Severe structural ponding
  - Multiple roof layers that prevent further recover
  - Asbestos requiring abatement
  - Substrate failure too widespread to address through repair
  - Code restrictions that force replacement scope
- The customer's goals match (long-term plan, preparing for sale at full disclosure, etc.)

### Sample customer language

> "Your roof has reached the end of its useful service life. I want to be straight with you — repair is short-term spending at this point. We documented [conditions], and patching individual items doesn't address the bigger picture. Replacement is the right answer. I know it's the biggest number on the page; I'd rather tell you that now than sell you something that won't last."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '4'
);

-- Part 3 / Ch 9 / Sec 5: When the Answer Is in the Middle: The Repair-Plus-Plan Conversation
UPDATE sections SET
  content_markdown = $mfst$The harder case — and the more common one — is when the roof isn't clearly at one end of the spectrum. The roof has issues worth addressing, but it also has remaining life. Replacement is on the horizon but not urgent. Repair-only leaves the customer underprepared for the bigger conversation coming.

The honest pattern: do the repair (when appropriate), and add the broader context.

### When to use it

- The roof is at the older end of its service range but not yet at end of life
- The reported issue is one of an emerging pattern
- Inspection revealed conditions consistent with broader aging
- The customer's framing minimizes the work that's actually needed

### How to deliver it

> "We can patch this leak today — that's a real repair, and you'll be dry. While we were up there, we also documented [conditions]. Your roof is at [age range], which puts it in the back half of its expected service. The patch buys you time, but I want to be straight with you that the underlying age of the system is the bigger picture. I can put a longer-term plan on paper for you to look at on your timeline. No pressure today — just so you have the full picture."

### Why this pattern matters

The repair-plus-plan conversation does three things at once:

1. **Solves the customer's immediate problem** (the leak)
2. **Sets honest expectations** about the broader situation
3. **Respects the customer's pace** without pressuring a replacement decision

A rep who does only the repair without the conversation leaves the customer underprepared. A rep who pushes replacement during the repair call applies pressure the customer didn't ask for. The repair-plus-plan pattern is the calibrated middle.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '5'
);

-- Part 3 / Ch 9 / Sec 6: Patterns That Point Toward Repair
UPDATE sections SET
  content_markdown = $mfst$Reps build pattern recognition over time. These patterns suggest repair is likely the right call:

- **Young or mid-life roof in good condition with one or two specific failures** — almost always repair
- **Localized damage from a recent event (storm, debris, single trade incident)** — almost always repair
- **Single failed pipe boot, single broken tile, single damaged shingle area** — repair
- **Roof with documented maintenance history and consistent condition for its age** — repair on specific failures
- **Customer's first leak after years of no issues** — investigate and repair the source

When the inspection lines up with these patterns, reps should be confident in the repair recommendation and clear about why.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '6'
);

-- Part 3 / Ch 9 / Sec 7: Patterns That Point Toward Replacement
UPDATE sections SET
  content_markdown = $mfst$These patterns suggest replacement is likely the right call:

- **Roof significantly past expected service range with multiple condition issues** — replacement
- **Three or more leak repairs in 18–24 months** — pattern of failure, not isolated incidents
- **Widespread substrate failure** — wet insulation, severe ponding, structural issues
- **Disqualifying conditions for restoration AND repair-only** — replacement is the remaining option
- **Roof age plus multiple aging signs (granule loss, brittleness, seam failures, flashing failures across multiple locations)** — system-wide aging
- **Asbestos in older substrate combined with end-of-life condition** — replacement with abatement

When the inspection lines up with these patterns, reps should be clear about why replacement is the call — and prepared to maintain the recommendation when customers push back on the cost.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '7'
);

-- Part 3 / Ch 9 / Sec 8: The Honest Patterns That Aren't Always Obvious
UPDATE sections SET
  content_markdown = $mfst$A few patterns are worth naming because they're commonly misread.

### "It's only one leak — patch it"

Sometimes that's right. But sometimes one visible leak is the first symptom of system-wide aging that hasn't shown elsewhere yet. The rep's inspection determines which it is. Reps should not default to "just patch it" without confirming the rest of the roof supports that recommendation.

### "The roof looks fine from the ground"

Ground-level appearance often misleads. Composition shingle roofs in their late life can still look uniform from the ground while the granule loss, brittleness, and detail aging are advanced up close. A roof that looks fine from the ground doesn't override what the inspection finds.

### "We just need to patch where it's leaking"

Sometimes that's accurate. Sometimes the customer's framing is the symptom of a broader issue the rep has to surface honestly. The repair-plus-plan conversation handles this.

### "Replacement is wasteful — let's do anything else first"

Sometimes that's reasonable. Sometimes it produces years of repeat repairs that cost more than the replacement would have. The rep names this pattern when it applies.

### "The other contractor said replacement"

Sometimes the other contractor is right. Sometimes they're overselling. The rep doesn't bash the other contractor — the rep explains what *they* observed and lets the customer compare scopes.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '8'
);

-- Part 3 / Ch 9 / Sec 9: When Customers Push Back on the Recommendation
UPDATE sections SET
  content_markdown = $mfst$### "I don't want to spend that much — let's just do the repair"

When repair would actually perform on a roof with remaining life, the rep agrees. When repair is short-term spending on a roof at end of life, the rep maintains the position.

> "I hear you on cost. The reason I'm not recommending repair-only is that the roof is at [age range] and we documented [conditions] across the system. A patch buys you a few months to maybe a year before you're calling someone again — likely a different leak in a different location. You'd be paying for repeat repairs that add up to more than the replacement scope. If cost is the constraint, let's talk about phased work, financing, or scoping replacement around your budget rather than against it."

### "I'd rather replace it — start fresh"

When replacement is genuinely needed, the rep agrees. When replacement is more than the roof requires, the rep walks the customer back honestly.

> "I appreciate the clean-slate appeal. I want to give you the honest answer though: your roof has significant remaining life. Replacing it now means you're paying for service life you wouldn't have used yet. The right call here is repair — and if it would help, a maintenance program so we're catching small issues early. If you want me to put a replacement option on paper for comparison, I'm happy to do that, but I'd be doing it knowing it isn't what your roof needs today."

### "Another contractor said replacement"

Don't bash the other contractor. Explain what was observed and let the customer compare.

> "Without seeing what they observed, I can't speak directly to their proposal. What I can tell you is what I documented and why I think repair is the right scope. If you want to compare side by side, you can show their proposal to me and I'll walk through the differences. The decision is yours; I just want you working from accurate information."

### "Another contractor said repair"

Same approach — explain what was observed.

> "I'd want to see their inspection findings before I could compare. Based on what I observed, repair on this roof is short-term spending — here's why. If their inspection found different conditions or they have access to information I don't, I'd be open to looking at it. If they're recommending repair on conditions consistent with what I found, we'd disagree on the recommendation."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '9'
);

-- Part 3 / Ch 9 / Sec 10: When Honesty Costs the Sale
UPDATE sections SET
  content_markdown = $mfst$Sometimes the rep recommends repair when the customer wanted replacement. Sometimes the rep recommends replacement when the customer wanted repair. Either way, the customer chooses a different contractor whose recommendation matched what they preferred to hear.

This happens. The rep doesn't capitulate to keep the deal. The customer either comes back later — having watched the other contractor's recommendation play out — or doesn't. Either way, the rep's reputation is preserved.

> "I understand. I'm not going to write a proposal I don't believe in just to win the deal. If another contractor is recommending [scope] and that's what you want to do, that's your call. If you change your mind or want a second opinion later, I'm happy to come back."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '10'
);

-- Part 3 / Ch 9 / Sec 11: The Phased Work Option
UPDATE sections SET
  content_markdown = $mfst$When the customer's budget genuinely doesn't support what the roof needs, phased work is sometimes the honest answer. (See Chapter 13.)

> "Your budget doesn't support replacement right now, and I understand that. What we can do is phased work: address the most urgent items immediately to keep you dry and document the broader conditions, then plan the bigger scope for [timeframe]. The phased version costs more in total than doing it all at once, but it spreads the cost out and keeps you protected while you plan. It's a real option when the alternative is doing nothing."

Phased work isn't a way to undersell replacement. It's an honest path for customers whose situations require it.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '11'
);

-- Part 3 / Ch 9 / Sec 12: Common Sales Mistakes on Repair vs Replacement
UPDATE sections SET
  content_markdown = $mfst$- Recommending replacement on a roof with significant remaining life because the proposal is bigger
- Recommending repair on an end-of-life roof because the close is easier
- Avoiding the repair-plus-plan conversation when conditions warrant it
- Capitulating to customer pressure to match the recommendation they wanted
- Quoting specific remaining-life numbers to justify the recommendation
- Bashing other contractors' recommendations directly
- Treating each visit as a one-time transaction rather than a long-term relationship deposit
- Failing to offer phased work when the budget genuinely doesn't support full scope
- Pushing replacement scope to "future-proof" the roof beyond what's actually needed$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '12'
);

-- Part 3 / Ch 9 / Sec 13: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer scenario | Right answer |
|---|---|
| Young or mid-life roof, localized failure | Repair |
| Mid-life roof, multiple recent leaks, sound substrate | Repair-plus-plan |
| Older roof, widespread aging, multiple leak history | Replacement |
| End-of-life roof with disqualifying conditions | Replacement |
| Customer wants replacement on a sound roof | Recommend repair, decline replacement scope |
| Customer wants repair on an end-of-life roof | Repair-plus-plan or replacement; don't undersell |
| Customer's budget doesn't support replacement | Phased work as honest alternative |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '13'
);

-- Part 3 / Ch 9 / Sec 14: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Repair is right when the roof has remaining service life and failures are localized. Replacement is right when the roof is at end of life or has disqualifying conditions. The middle cases — where the answer is close to the line — get the repair-plus-plan conversation: address the immediate issue and surface the broader situation honestly without pressuring a replacement decision. Patterns build over time: young roofs with localized failures point toward repair; older roofs with multiple leak history point toward replacement. Reps should be clear and confident in their recommendation while respecting the customer's right to disagree, get other quotes, or take time to decide. When budget genuinely doesn't support what the roof needs, phased work is the honest alternative. The two failure modes — overselling replacement and underselling repair — both damage trust over time. The rep's discipline is recommending what the roof actually needs and maintaining the recommendation when customers push back, regardless of whether the honest answer is the easier sell.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 9 AND s.section_number = '14'
);

-- Part 3 / Ch 10 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Good / Better / Best is one of the most common sales frameworks in roofing — and one of the most commonly misused. Done well, it gives customers a clear range of honest options that match different situations and budgets. Done poorly, it becomes a manipulation pattern: anchor with an inflated "Best," make the middle option look reasonable by comparison, and steer the customer toward whatever maximizes margin.

The system chapters in this book (especially Chapters 1, 2, 3, 6, 9, 10) include Good / Better / Best framings that are honest by design. This module covers the conversational pattern — how reps actually present three options to a customer in the field, and how to avoid the patterns that turn the framework into a sales gimmick.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '1'
);

-- Part 3 / Ch 10 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$Each option must be a real, honest answer for the roof — not a decoy designed to make another option look better.

That's the entire principle. Everything in this module is how to deliver it honestly.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '2'
);

-- Part 3 / Ch 10 / Sec 3: What Honest Good / Better / Best Looks Like
UPDATE sections SET
  content_markdown = $mfst$Each tier should answer a different real question:

- **Good** — what's the lowest-cost option that actually performs?
- **Better** — what would I recommend if cost weren't a constraint and the customer wanted the best fit for their situation?
- **Best** — what's the longest-life or most comprehensive option, even if it's more than most customers will choose?

When all three are real options, the framework helps the customer think through the decision. When one or more is fake — included only to make another option look better — the framework becomes a manipulation tactic.

### The honesty test for each option

Before presenting any tier, the rep should be able to answer:

- Would this option actually perform on this roof?
- Would I recommend this to a family member?
- Does this option have a real customer who'd reasonably choose it?

If the answer to any of those is no, the option is a decoy and shouldn't be on the page.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '3'
);

-- Part 3 / Ch 10 / Sec 4: When Good / Better / Best Doesn't Apply
UPDATE sections SET
  content_markdown = $mfst$Sometimes the right answer is one option, not three.

- **A young roof with a localized failure** — repair is the answer; restoration and replacement aren't real alternatives. Don't manufacture three options when one is correct.
- **An end-of-life roof with disqualifying conditions** — replacement is the answer; repair and restoration would underperform. Same principle.
- **A customer with a clear request that fits their roof** — sometimes the customer wants the cheapest option that works, or the longest-life option, and the inspection supports their goal. Three options isn't always more useful than one.

Reps should not force a three-option presentation when one option is genuinely the right answer. The honest pattern is "here's what your roof needs," not "here are three options I'm contractually obligated to show you."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '4'
);

-- Part 3 / Ch 10 / Sec 5: The Anchoring Trap
UPDATE sections SET
  content_markdown = $mfst$The most common manipulation in Good / Better / Best presentations: anchoring with a high "Best" to make the middle option look reasonable.

This works in the short term and damages trust in the long term. Customers who later realize they were anchored — by talking to other contractors, by reading the proposal carefully, or by comparing quotes — feel manipulated. They don't refer.

How to avoid the anchoring trap:

- **Don't include a "Best" tier the customer almost certainly won't choose** unless it's a genuine option for their situation
- **Don't price the "Best" option to make "Better" look like a discount**
- **Don't lead with the highest tier in the conversation** — present in order of increasing cost or in order of recommendation, not in order designed to anchor
- **Be honest if the customer asks why you presented three options** — "because three real options exist for your roof," not because of a sales script

A useful self-check: would the rep be comfortable if the customer compared all three options against quotes from three other contractors? If yes, the framework is honest. If no, something in the presentation needs to change.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '5'
);

-- Part 3 / Ch 10 / Sec 6: How to Present the Three Options
UPDATE sections SET
  content_markdown = $mfst$The pattern in the field follows a consistent flow.

### Step 1: Walk through inspection findings first

Before any options, the customer needs to understand what was found. This anchors the options in observed conditions, not in a generic sales script.

> "Before I get into the options, let me walk through what we found on the roof. [Findings, severity ratings, key points.] Now that we're on the same page about conditions, here's how I'd think about your options."

### Step 2: Define each option in plain language

Each option gets a brief definition: what it is, what it does, what it doesn't do.

> "Option one — repair. We address the specific items we found: [scope]. The rest of the roof keeps performing. Lowest cost, shortest scope. Real answer if we're confident the localized issues are the full picture.
>
> "Option two — restoration. We add a silicone coating to extend the life of the existing roof by [range]. This is what I'd recommend if the inspection supports it: substrate has to qualify, ponding has to be acceptable, details have to be addressable. If the roof qualifies, this is the cost-life sweet spot.
>
> "Option three — replacement. Full tear-off and new system. Highest cost, longest life. Right answer if conditions disqualify restoration or if you're planning long-term."

### Step 3: Recommend the option that fits

The rep doesn't pretend all three are equally good for the customer's roof. The rep names which one is the recommendation and why.

> "For your roof specifically, I'd lean toward option two. Here's why: [reasoning based on inspection]. Option one would address the immediate issues but leave the broader aging unaddressed. Option three is bigger than what your roof actually needs today. Option two is what fits."

### Step 4: Present the trade-offs honestly

Each option has trade-offs. Reps name them.

> "Option one's trade-off: cheaper now, but you'll likely be back for more repairs within [timeframe] as the roof keeps aging. Option two's trade-off: extends life by [range] but doesn't reset the roof's age — full replacement eventually becomes the right answer. Option three's trade-off: highest up-front cost, but the longest service life and the cleanest start."

### Step 5: Accept the customer's decision

Once the rep has explained the options, the recommendation, and the trade-offs, the decision is the customer's.

> "Take your time with this. If you have questions about any of the three, I'm happy to walk through them. The proposal is good for [timeframe], and there's no pressure on the timing from our end."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '6'
);

-- Part 3 / Ch 10 / Sec 7: When Customers Want to Skip the Analysis
UPDATE sections SET
  content_markdown = $mfst$Some customers don't want to think through three options. They want the rep to just tell them what to do, or they want to jump straight to pricing.

The rep accommodates without skipping the honest framing.

> "I can absolutely tell you what I'd recommend — for your roof, it's option two, and here's the short version of why. Take a look at the proposal when you have time; if you want to dig into the differences, we can. If you want to go with the recommendation as-is, that's also fine. I just want to make sure you have the information."

This respects the customer's preference while still ensuring they can engage with the options if they want to later.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '7'
);

-- Part 3 / Ch 10 / Sec 8: When Customers Want Only the Cheapest
UPDATE sections SET
  content_markdown = $mfst$A common pattern: the customer wants the cheapest option regardless of analysis. The rep handles this honestly.

If the cheapest option is actually a real option for the roof:

> "Option one is the cheapest. It's also a real option for your roof — we'd address [scope] and it would perform. Just so you know what you're choosing: it doesn't address the broader aging picture, so you may be looking at additional work within [timeframe]. If you're comfortable with that trade-off, option one is honest."

If the cheapest option *isn't* a real option for the roof:

> "I hear you on cost. The challenge is that option one — the cheapest — wouldn't actually solve your roof's problem. We'd be doing repair-only on a roof that's past the point where repair-only performs. Spending money on option one in this situation is just delayed spending on option two or three. The honest options for this roof are the middle and the top tiers, or — if cost is the real constraint — phased work that addresses the most urgent items first."

The distinction matters. "Cheapest that performs" is honest; "cheapest, period" sometimes isn't.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '8'
);

-- Part 3 / Ch 10 / Sec 9: When Customers Want Only the Most Expensive
UPDATE sections SET
  content_markdown = $mfst$Less common but real. Some customers default to the most expensive option, assuming it's the best.

If the most expensive option is right for the roof:

> "Option three fits your roof and your situation — long-term plan, you want the cleanest start, you've thought through it. That's the recommendation."

If the most expensive option is more than the roof needs:

> "I appreciate that you're willing to invest in the roof. I want to be straight with you though: option three is more than your roof actually needs today. Spending the extra money doesn't get you proportional value — your roof has significant remaining life, and option two captures most of the benefit at significantly lower cost. If the cost difference doesn't matter to you, option three won't hurt anything. But it's not what I'd recommend if I were making the call."

The rep doesn't upsell just because the customer is willing to spend.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '9'
);

-- Part 3 / Ch 10 / Sec 10: The Comparison-Quote Conversation
UPDATE sections SET
  content_markdown = $mfst$Customers often present USA Flat Roof's three-option proposal alongside competing quotes. This is where reps help customers compare scope, not just price.

> "When you're comparing the proposals, the price gap usually reflects scope differences, not contractor margin. Look at what each one includes: prep work, detail repair, fabric reinforcement, mil thickness on coatings, warranty tier, what's specifically excluded. Two coating proposals can have the same product name and very different actual scopes. I'm happy to walk through the comparison with you — not to bash anyone else's proposal, but to make sure you're comparing apples to apples."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '10'
);

-- Part 3 / Ch 10 / Sec 11: Common Mistakes in Good / Better / Best Presentation
UPDATE sections SET
  content_markdown = $mfst$- Including a fake "Best" tier to anchor the middle option
- Pricing the tiers to make a specific option look like a discount
- Presenting three options when one is genuinely the right answer
- Not making a clear recommendation among the three
- Hiding which option fits the roof and letting the customer guess
- Refusing to recommend because "the customer should decide"
- Pushing a specific tier through pressure rather than through honest reasoning
- Adjusting the recommendation based on what the customer pushed for rather than what the inspection found
- Failing to explain trade-offs honestly
- Presenting tiers without first walking through inspection findings$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '11'
);

-- Part 3 / Ch 10 / Sec 12: The "Reasonable Customer" Test
UPDATE sections SET
  content_markdown = $mfst$A useful internal check before presenting: would a reasonable customer, given the inspection findings, plausibly choose each of the three options?

- **Good** — a reasonable customer who values cost-effectiveness and is comfortable with the trade-offs would choose this
- **Better** — a reasonable customer who wants the cost-life sweet spot would choose this
- **Best** — a reasonable customer who values longest service life or has specific situation factors (long-term plan, disqualifying conditions, etc.) would choose this

If the rep can't construct a plausible reason why a reasonable customer would choose any one of the three options, that option is a decoy and shouldn't be presented.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '12'
);

-- Part 3 / Ch 10 / Sec 13: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Just tell me what to do" | Make the recommendation clearly; offer to walk through the others if they want |
| "I want the cheapest" | Confirm cheapest performs; if it doesn't, name that and offer phased work |
| "I want the most expensive" | Confirm most expensive fits; if it overshoots, name that honestly |
| "Why are you giving me three options?" | Because three real options exist for this roof; explain the differences |
| "Is the middle one really the best for me?" | Yes if true; explain why it fits the roof; recommend something else if not |
| "Other contractors only gave me one option" | Different presentation styles; the inspection findings determine real options |
| "How do I compare these to other quotes?" | Compare scope, not just price; offer to walk through differences |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '13'
);

-- Part 3 / Ch 10 / Sec 14: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Good / Better / Best is honest when each tier is a real option for the roof and the rep can name a reasonable customer who would choose each one. The framework breaks down when "Best" is included as an anchor to make "Better" look reasonable, when "Good" is a decoy, or when the rep refuses to recommend among the three because "the customer should decide." The honest pattern: walk through inspection findings first, define each option in plain language, recommend the option that fits the roof, present trade-offs honestly, and accept the customer's decision. When one option is genuinely the right answer, reps should present that option clearly rather than manufacturing three. When customers want only the cheapest or the most expensive, reps engage honestly with whether their preference fits the roof. The "reasonable customer" test is the internal check before presenting: if no reasonable customer would choose a tier, it's a decoy and doesn't belong on the page. Done well, Good / Better / Best gives customers a structured way to think through their decision. Done poorly, it becomes a manipulation pattern that erodes trust. The rep's discipline is keeping it on the honest side of that line.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 10 AND s.section_number = '14'
);

-- Part 3 / Ch 11 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Pricing is the conversation customers most often want to have first and reps most often need to have last. The customer wants a number. The rep needs an inspection, a documented scope, and a written proposal before any number is meaningful. The gap between those two is where reps either build trust or lose deals.

Pricing also brings out the most common pressure tactics in the industry — same-day discounts, manufactured urgency, "best price right now," anchored numbers, and bait-and-switch scope. A consultative rep handles pricing differently from a pressure rep, and the difference shows.

This module is the practical training piece for pricing conversations. It covers the framework for explaining price, the response when customers ask for verbal numbers, and the honest comparison conversation when customers have multiple quotes.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '1'
);

-- Part 3 / Ch 11 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$Price reflects scope. Different scopes have different prices. The rep's job is to make sure the customer understands the scope before evaluating the number.

That's the framework. Everything in this module is how to deliver it in real customer situations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '2'
);

-- Part 3 / Ch 11 / Sec 3: Why Price Conversations Go Wrong
UPDATE sections SET
  content_markdown = $mfst$The two recurring failure patterns:

### Pattern A: Reps quote prices verbally before they're confident in the scope

A customer asks "what's this going to cost?" mid-inspection. The rep — wanting to be helpful, wanting to seem decisive, wanting to close — gives a number. Two problems follow:

- The verbal number rarely matches the actual scope once it's documented
- The customer anchors on the verbal number; if the written proposal is higher, the rep looks dishonest

### Pattern B: Reps avoid price conversations entirely

A customer asks about cost; the rep deflects vaguely or postpones the conversation indefinitely. The customer feels stonewalled and may go elsewhere — sometimes to a contractor who'll give a verbal number that turns out to be inaccurate.

The honest middle: defer specific pricing to the written proposal, but engage genuinely with the customer's cost concerns and provide reasonable framing when asked.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '3'
);

-- Part 3 / Ch 11 / Sec 4: The Framework: Why Prices Vary
UPDATE sections SET
  content_markdown = $mfst$Customers often expect roof pricing to work like a menu — fixed price for fixed product. Roofing doesn't work that way, and customers benefit from a brief, honest explanation of why.

> "Roof pricing varies for real reasons, not arbitrary ones. The same job — even on what looks like the same roof — can have meaningfully different scopes depending on substrate condition, ventilation needs, code requirements, manufacturer warranty tier, prep work, detail scope, and what's actually under the surface. Two contractors quoting the same roof can have legitimately different prices because they're proposing different work. The price by itself doesn't tell you which one is the right fit; the scope does."

This framing accomplishes three things:
1. Sets the expectation that price will be discussed in context
2. Plants a flag against contractors who quote without inspecting
3. Reframes the customer's question from "what's the price?" to "what's the scope?"$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '4'
);

-- Part 3 / Ch 11 / Sec 5: The Variables That Drive Price
UPDATE sections SET
  content_markdown = $mfst$Reps should be able to explain in plain language what affects price on common projects.

### On a re-roof or replacement project
- **Tear-off complexity** — number of layers, asbestos potential, debris handling
- **Deck condition** — repair allowance for unforeseen sheathing damage
- **Underlayment specification** — code-required, premium, or specific manufacturer
- **Ventilation upgrades** — adding ridge vent, addressing soffits, fixing short-circuits
- **Insulation and cover board** (commercial) — R-value, type, thickness
- **Membrane or shingle product line** — base, mid-tier, premium designer
- **Membrane attachment** — mechanically attached vs fully adhered
- **Flashing scope** — replacement of all flashings vs reuse where possible
- **Detail and penetration scope** — how many penetrations, how complex
- **Drainage modifications** — tapered insulation, additional drains, scupper work
- **Warranty tier** — workmanship warranty length, manufacturer system warranty (NDL)
- **Code-driven scope** — Title 24 cool roof, ventilation, fire ratings
- **Access difficulty** — multi-story, tight site, occupied building scheduling

### On a restoration or coating project
- **Substrate prep** — cleaning method, primer, fabric reinforcement scope
- **Detail repair scope** — what's repaired before coating goes on
- **Coating product** — manufacturer, mil thickness specification
- **Number of coats** — single high-build vs two-coat
- **Granule broadcast** — adds cost; affects walkability and warranty
- **Warranty tier** — manufacturer warranty length, contractor program participation

### On a repair project
- **Specific scope** — number and complexity of repairs
- **Access** — ladder, lift, hoist, or special access
- **Material matching** — common shingles vs discontinued profiles
- **Service-call minimums and emergency premiums** — per company policy

### On rejuvenation
- **Roof size and prep** — debris clearing, surface preparation
- **Application scope** — full roof vs specific sections
- **Manufacturer warranty registration** — included in scope

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard pricing structure, authorization tiers, emergency premiums, and minimums.

Reps don't need to memorize every variable. They need to understand that price reflects scope and be able to point to two or three reasons why scope can legitimately vary on any given project.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '5'
);

-- Part 3 / Ch 11 / Sec 6: When Customers Ask for Verbal Pricing
UPDATE sections SET
  content_markdown = $mfst$This is the most common pricing-conversation moment. The customer asks "what's this going to cost?" — sometimes mid-inspection, sometimes at the end, sometimes by phone before any inspection has happened.

### The deferral pattern

> "I'd rather give you an accurate number on paper than a guess in person. The price depends on the specific scope I'm putting together based on what I observed, and I want that scope written down so we're both working from the same understanding. You'll have the proposal within [timeframe]. If you have a budget range you're working with, that's helpful for me to know — I can build options that fit it or honestly tell you if your range doesn't match the work."

This response:
- Doesn't refuse to engage
- Explains *why* the deferral
- Invites the customer to share budget context
- Sets a clear expectation for when the number will arrive

### When the customer pushes harder

> "I understand the want for a number now. The challenge is that any number I give you in person without seeing the full scope on paper is going to be wrong in one direction or the other — and that creates problems either way. If I lowball it, you'll be unhappy when the proposal is higher. If I overestimate it, you'll think I'm overcharging when the proposal is lower. Either way, the verbal number isn't useful. The written proposal is the honest answer."

### When customers compare to competitors who gave verbal numbers

> "Some contractors will give you a number on the spot. The trade-off is that those numbers often change — sometimes significantly — once the actual scope is documented and the contract is written. We don't operate that way. Our number on paper is the number we'll do the work for, with clear scope documentation so you know what's included and what's not. The wait is part of doing it right."

### When verbal pricing is appropriate

There are limited situations where reps may discuss pricing verbally — within company authorization:

- **Service call minimums** for repair work — "our minimum service call is around $X, so any repair starts there"
- **Industry-typical ranges** for awareness — "re-roofs in this range are typically [range], depending on scope"
- **Budget range conversations** — confirming whether a customer's budget aligns with realistic scope before doing extensive proposal work

These ranges aren't quotes. Reps should be clear about that.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's authorization tiers for verbal pricing, ranges, and what reps may and may not communicate.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '6'
);

-- Part 3 / Ch 11 / Sec 7: The Comparison-Quote Conversation
UPDATE sections SET
  content_markdown = $mfst$When customers have multiple quotes, the rep's job is to help them compare scope, not just price. (Module 4 covers this for scope categories; this section focuses on pricing.)

### The opening

> "When you're comparing the proposals, the price difference is almost always a scope difference, not a margin difference. Let me walk through what to look for so you can compare apples to apples."

### What to compare

- **Scope inclusion** — what work is included; what work is excluded
- **Material specifications** — exact products, mil thickness, warranty tier
- **Prep work** — substrate prep, cleaning, primer, fabric reinforcement
- **Detail scope** — flashings, penetrations, terminations
- **Warranty terms** — manufacturer warranty, workmanship warranty, transferability
- **Allowances** — deck repair, unforeseen condition allowances
- **Exclusions** — what's specifically not included

### Common scope differences hidden by similar prices

- A coating proposal at lower mil thickness costs less but performs less
- A re-roof proposal that excludes ventilation upgrades costs less but doesn't address underlying aging drivers
- A coating proposal that skips fabric reinforcement at seams costs less but fails earlier at high-stress areas
- A re-roof proposal with a basic workmanship warranty costs less than one with a manufacturer NDL warranty
- A repair proposal that addresses only the visible damage costs less than one that addresses the broader pattern

### How to handle a customer with a meaningfully cheaper competing quote

> "If their number is significantly lower, the question is what's different. Sometimes it's a real scope difference — they're proposing less work, lower-tier materials, or a less comprehensive warranty. Sometimes it's a contractor who won't actually deliver what they're quoting. Sometimes it's a contractor who'll add change orders once the work starts. I'm happy to walk through the comparison with you so you can see where the gap is. If their scope genuinely matches ours and they're cheaper, you should consider it. If the scopes don't match, the price comparison isn't meaningful."

The rep doesn't bash the competitor. The rep explains how to evaluate.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '7'
);

-- Part 3 / Ch 11 / Sec 8: When Customers Negotiate
UPDATE sections SET
  content_markdown = $mfst$Some customers expect to negotiate on price. The rep handles this honestly.

### When the customer asks for a discount

> "I appreciate the question. Our pricing reflects the scope we're proposing — there's not a discounted version of the same work hiding in the proposal. What I can do is walk through the scope with you and see if there's a different approach that fits your budget — phased work, a different scope tier, or adjusting the specifications. The right path is usually 'different scope, different price' rather than 'same scope, lower price.'"

### When the customer says "another contractor will match this for less"

> "If their proposal is genuinely the same scope and they're meaningfully cheaper, you should consider it. I'd rather you go with the right fit at a fair price than have us do the work at a price that doesn't reflect what we're delivering. What I'd encourage is making sure the scopes are actually equivalent before you decide on price alone. Often they're not."

### When the customer says "I'll go with you if you can do X"

> "I hear what you're asking. Let me check whether that's something we can do within the scope and pricing structure, and I'll come back with an honest answer. If it's a yes, I'll let you know. If it's a no, I'll explain why."

The rep doesn't capitulate to keep the deal on a price that doesn't work. The rep also doesn't dismiss the customer's request — sometimes legitimate adjustments fit within scope flexibility.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '8'
);

-- Part 3 / Ch 11 / Sec 9: When Pricing Genuinely Is the Constraint
UPDATE sections SET
  content_markdown = $mfst$Sometimes a customer's budget genuinely doesn't match what the roof needs. The rep has three honest paths (per Chapter 13):

### Phased work

> "Your budget doesn't support the full scope right now, and I understand that. What we can do is phased work — address the most urgent items now to keep you protected, and plan the broader scope for [timeframe]. Phased work costs more in total than doing it all at once, but it spreads the cost out and is honest about the trade-off."

### Honest decline

> "What your roof needs costs more than this budget can support, even with phased work. We may not be the right contractor for what you have to spend right now. I'd rather tell you that than write a proposal that cuts corners we shouldn't cut."

### Referral

> "Another contractor or a different scope might be a better fit for your situation. I can give you a name if it would help."

In all three cases, the rep is honest about cost without pressuring or capitulating.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '9'
);

-- Part 3 / Ch 11 / Sec 10: Common Mistakes in Pricing Conversations
UPDATE sections SET
  content_markdown = $mfst$- Quoting verbally before the proposal is documented
- Avoiding pricing conversations entirely instead of explaining the deferral
- Discounting work to "win the deal" without changing scope
- Pressuring customers with same-day discounts or "best price right now"
- Failing to explain why prices vary
- Bashing competitors' pricing directly
- Inflating scope to support higher prices
- Cutting corners on scope to support lower prices
- Promising final pricing before inspection is complete
- Capitulating when customers push hard on price
- Treating the price as the conversation rather than the scope as the conversation$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '10'
);

-- Part 3 / Ch 11 / Sec 11: The Honest Closing on Pricing
UPDATE sections SET
  content_markdown = $mfst$When the rep delivers a proposal, the closing on pricing should be calm and clear.

> "Here's the proposal. The price reflects the scope we discussed — [brief recap of the major items]. The number is what it is; we don't have a discounted version of the same scope. If the price doesn't fit your budget, let's talk about whether different scope makes more sense for your situation. If you want to compare to other quotes, I'm happy to walk through differences with you. Take whatever time you need to think about it. The proposal is good for [timeframe]."

This closing:
- Restates the connection between price and scope
- Doesn't apologize for the price
- Offers genuine flexibility on scope
- Respects the customer's pace
- Doesn't manufacture urgency$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '11'
);

-- Part 3 / Ch 11 / Sec 12: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "What's this going to cost?" (mid-inspection) | Defer to written proposal; offer to discuss budget range |
| "Just give me a ballpark" | Provide industry-typical range if appropriate; clarify it's not a quote |
| "Other contractor gave me a number on the spot" | Explain why our number comes after the proposal; note that on-the-spot numbers often change |
| "Can you discount this?" | Explain pricing reflects scope; offer scope adjustments if budget is the issue |
| "Another contractor is cheaper" | Compare scopes; help customer evaluate whether the comparison is meaningful |
| "I'll sign today if you can do X" | Engage honestly; don't capitulate to pressure for unsustainable terms |
| "I can't afford the recommended scope" | Offer phased work or honest decline; don't cut scope to fit budget |
| "Why is roofing so expensive?" | Explain variables that drive price; reframe to scope rather than price alone |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '12'
);

-- Part 3 / Ch 11 / Sec 13: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Price conversations go wrong when reps quote verbally before the scope is documented or avoid the conversation entirely. The honest middle: defer specific pricing to the written proposal, but engage genuinely with the customer's cost concerns. Price reflects scope, and customers benefit from understanding what variables drive cost — substrate prep, ventilation, warranty tier, code requirements, detail scope, and access. When customers compare quotes, reps help them compare scope, not just price; meaningfully different prices usually reflect meaningfully different scopes. When customers push for discounts, reps offer scope adjustments rather than cutting prices on the same work. When budget genuinely doesn't fit, phased work, honest decline, or referral are the three paths. Reps don't capitulate to pricing pressure for the same reason they don't apply pricing pressure: pressure-driven decisions damage relationships long-term. The price by itself isn't the conversation — the scope is, and the price follows from it.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 11 AND s.section_number = '13'
);

-- Part 3 / Ch 12 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$Warranties are the most-promised and least-understood part of roofing. Customers hear "lifetime warranty" and assume the roof is covered forever. They hear "30-year shingle" and assume the roof lasts 30 years. They hear "the warranty covers everything" and assume any future leak is the manufacturer's problem.

None of those is accurate. Warranties are documents — specific in their terms, narrow in what they actually cover, and easy to void through omissions the customer never knew mattered. Reps who understand warranty reality and explain it honestly build trust customers don't get from the contractors who oversell coverage. Reps who misrepresent warranty coverage create the worst kind of customer disappointment: the kind that arrives years later, when the customer needs the warranty most.

This module pulls together the warranty content threaded through the system chapters into a single training piece. The goal is for reps to handle warranty conversations consistently across systems and to recognize the moments where misunderstanding most often happens.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '1'
);

-- Part 3 / Ch 12 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$A warranty is a document. It covers specific things, excludes specific things, requires specific maintenance, and pays out in specific ways. Reps don't promise warranty outcomes — they help customers understand what their actual coverage is.

That's the discipline. Everything in this module is how to deliver it across system types and customer scenarios.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '2'
);

-- Part 3 / Ch 12 / Sec 3: The Three Warranty Layers
UPDATE sections SET
  content_markdown = $mfst$Most roof systems have two or three warranty layers. Customers often conflate them. Reps need to keep them separate.

### Layer 1: Manufacturer Material Warranty

Covers the **product** against manufacturing defects. Issued by the manufacturer of the shingle, membrane, coating, or foam.

What it typically covers:
- Manufacturing defects in the product itself
- Premature product failure attributable to the product, not installation or conditions

What it typically does *not* cover:
- Installation errors
- Damage from other trades
- Wear from conditions beyond the product's design tolerance (ponding, foot traffic, chemical exposure, etc.)
- Damage from inadequate ventilation
- Damage from missed maintenance
- The substrate underneath (on coatings)

### Layer 2: Manufacturer System Warranty (NDL or equivalent)

Stronger coverage available when the **full system** — product, installation, accessories — is installed by a manufacturer-certified contractor following the manufacturer's specifications.

What "NDL" means: **No Dollar Limit.** The manufacturer covers qualifying repairs without a per-claim cap, up to the warranty terms.

What it typically covers:
- The full system: membrane, flashings, accessories, sometimes labor
- Specific labor for qualifying repairs
- Issues that fall within the warranty's defined scope and timeline

What it typically does *not* cover:
- Damage from causes outside the warranty's scope (storm beyond defined limits, vandalism, unauthorized work)
- Substrate failures that pre-existed the installation
- Failures attributable to maintenance lapses the warranty required
- Modifications or additions made without manufacturer approval

### Layer 3: Workmanship (Contractor) Warranty

Covers **installation quality**. Issued by the contractor — USA Flat Roof in this context — not the manufacturer.

What it typically covers:
- Installation defects attributable to the contractor's work
- Issues that arise from how the work was performed, not from product defects or external damage

What it typically does *not* cover:
- Product defects (those go to manufacturer warranty)
- Damage from external causes
- Maintenance items that weren't part of the original scope
- Issues outside the warranty's defined timeline

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard workmanship warranty terms, length, transferability, and registration requirements.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '3'
);

-- Part 3 / Ch 12 / Sec 4: The Critical Distinction Customers Miss
UPDATE sections SET
  content_markdown = $mfst$The most common warranty misunderstanding: customers think a single warranty covers everything. It doesn't. The three layers are separate, with separate triggers, separate exclusions, and separate claim processes.

A leak might be:
- A manufacturing defect (manufacturer material warranty)
- An installation error (workmanship warranty)
- Damage from other trades (likely no warranty coverage; possibly insurance)
- A maintenance failure (typically not covered by any warranty)
- Wear consistent with the system's age and design (not covered — this is just aging)

Reps who explain the layered structure clearly help customers understand why "is this covered?" doesn't have a yes/no answer.

> "Your roof has multiple warranties — the manufacturer's product warranty, the manufacturer's system warranty if you have it, and our workmanship warranty. Each one covers different things and has different terms. When something happens, the question isn't 'is it covered?' — it's 'which warranty applies, and what does that warranty cover?' We'll walk through your specific documents and figure out what fits."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '4'
);

-- Part 3 / Ch 12 / Sec 5: The "Lifetime Warranty" Trap
UPDATE sections SET
  content_markdown = $mfst$"Lifetime warranty" is one of the most misunderstood phrases in roofing.

What customers think it means: the roof lasts a lifetime, and any failure is covered.

What it usually actually means:
- The warranty has a **non-prorated period** — typically the first 5–15 years — where coverage is at full value
- After the non-prorated period, the warranty becomes **prorated** — coverage decreases each year, reaching minimal value well before the "lifetime" ends
- "Lifetime" often means the original homeowner's lifetime in the home, not the roof's actual service life
- Significant exclusions apply throughout, especially in later years

Reps need to communicate this clearly without bashing the manufacturer:

> "'Lifetime warranty' is a marketing phrase that needs context. Most lifetime warranties have a non-prorated period of [range] years where you have full coverage, and then they prorate after that — meaning the manufacturer's payout decreases each year. By year 20, the warranty payout might be a small fraction of the original product cost. The shingles aren't 'lifetime' in any practical sense; the warranty is structured to provide diminishing coverage over time. That's not a scam — it's how these warranties have always worked. But you should know what you actually have, not what the brochure suggests."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '5'
);

-- Part 3 / Ch 12 / Sec 6: What Voids or Limits Coverage — The Common Patterns
UPDATE sections SET
  content_markdown = $mfst$Across systems, certain patterns recur as the most common reasons warranty coverage is denied or limited.

### Pattern 1: Inadequate ventilation (steep-slope residential)

Most shingle manufacturer warranties require adequate attic ventilation. Premature aging, moisture damage, and shingle distortion attributable to inadequate ventilation are common warranty denials. (See Chapter 14.)

### Pattern 2: Ponding water (commercial flat)

Most commercial flat-roof warranties limit or exclude damage attributable to ponding beyond defined tolerances. (See Chapter 16 for the 48-hour standard.)

### Pattern 3: Chemical or grease exposure

Warranties typically exclude damage from chemical or grease exposure outside the system's design tolerance. Restaurants and kitchens with TPO instead of PVC are a common scenario where this matters. (See Chapter 5.)

### Pattern 4: Damage from other trades

HVAC technicians, electricians, painters, and other contractors who damage the roof while working on rooftop equipment create damage that warranties typically exclude. The customer's recourse is usually with the trade that caused the damage, not the roof manufacturer or contractor.

### Pattern 5: Modifications and unauthorized work

New penetrations, equipment additions, or repairs by unapproved contractors can void warranty coverage in the affected area or, in some cases, on the entire roof.

### Pattern 6: Lack of documented maintenance

Some warranty tiers require documented annual inspections or maintenance. Missing the documentation can void coverage years later when the customer needs to file a claim.

### Pattern 7: Application over non-qualifying substrates (coatings)

Coating warranties typically cover only applications over qualifying substrates with proper prep. Coating applied over wet insulation, chronic ponding, or end-of-life roofing usually isn't covered when it fails. (See Chapter 3.)

### Pattern 8: Substrate failures (coatings)

Coating warranties typically cover the **coating**, not the **substrate underneath**. If the substrate fails, the coating warranty doesn't pay for substrate repair or replacement.

### Pattern 9: Missed warranty registration

Many manufacturer warranties — especially on coatings, restoration, SPF, and rejuvenation — require registration submitted within a specific window after the work. Missing the registration can void coverage entirely.

### Pattern 10: Conditions outside the warranty's defined scope

Storms beyond defined wind or hail thresholds, vandalism, fire, structural failure, and similar events typically aren't covered by roof warranties — they fall under building insurance.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '6'
);

-- Part 3 / Ch 12 / Sec 7: What Reps Cannot Promise
UPDATE sections SET
  content_markdown = $mfst$This is the discipline section. Reps must not:

- **Promise that "the warranty covers everything"** — no warranty does
- **Promise specific claim outcomes** — coverage decisions are between the customer and the manufacturer
- **Promise warranty length without reading the actual document**
- **Promise transferability** — many workmanship warranties don't transfer at sale, or require a transfer process
- **Promise that a single warranty covers all aspects of the roof** — the layered structure means no single document does
- **Promise that "you'll be covered" on storm damage** — most warranties exclude or limit storm-related damage outside defined thresholds
- **Promise restoration warranty coverage** on substrates that don't qualify
- **Imply manufacturer warranty length equals roof service life** — they're different things$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '7'
);

-- Part 3 / Ch 12 / Sec 8: The Honest Customer Language
UPDATE sections SET
  content_markdown = $mfst$The pattern for warranty conversations across system types:

> "Your roof has [number] warranties: [list them]. Each one covers different things. The manufacturer warranty covers [scope]; our workmanship warranty covers [scope]. Both have specific exclusions — [name the most relevant ones for this roof]. The warranty isn't a guarantee that nothing will go wrong; it's coverage for specific things going wrong in specific ways. Let's review your documents together so you know what you actually have."

This pattern:
- Names the layered structure
- Identifies what's covered without overpromising
- Surfaces the most relevant exclusions early
- Invites the customer to engage with the actual documents$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '8'
);

-- Part 3 / Ch 12 / Sec 9: Sample Warranty Conversations by System
UPDATE sections SET
  content_markdown = $mfst$### Composition shingle (Chapter 1)

> "On your composition shingle roof, you have the manufacturer's product warranty — typically a 'lifetime' warranty that's actually structured with a non-prorated period followed by a prorated period — and our workmanship warranty on the installation. The product warranty covers manufacturing defects. It doesn't cover wind damage beyond the defined limit, missed maintenance, or premature aging from inadequate ventilation. Our workmanship warranty covers installation. Storm damage typically goes through your building insurance, not the roof warranty."

### TPO commercial replacement (Chapter 2)

> "On a TPO replacement, you have the option of a manufacturer system warranty — sometimes called NDL, no dollar limit — that covers the full assembly when installed by a certified contractor following the manufacturer's specifications. That's stronger coverage than the basic material warranty. It still has exclusions: ponding beyond defined limits, damage from other trades, modifications without approval, and so on. Our workmanship warranty covers installation. Both warranties have specific maintenance and inspection requirements to remain in effect — we'll document what those are at the start of the project."

### Silicone restoration (Chapter 3)

> "Your silicone restoration has two warranties: the manufacturer's coating warranty and our workmanship warranty. Important point on the coating warranty: it covers the coating, not the substrate underneath. If the substrate fails, the coating warranty doesn't pay for substrate repair. That's why qualifying the substrate matters so much — and why we won't apply silicone over substrates that don't qualify, even if you ask. The warranty has no value on a substrate that wasn't fit for restoration."

### Rejuvenation (Chapter 4)

> "Fresh Roof rejuvenation comes with a manufacturer warranty when the roof qualifies and the application is documented properly. Important: the warranty covers the rejuvenation treatment, not the underlying roof. If your roof leaks because of failed flashings or structural issues unrelated to the shingle aging, the rejuvenation warranty doesn't pay for those repairs. Registration has to happen within a specific window — that's part of what we do automatically."

### SPF (Chapter 10)

> "Your SPF system has a manufacturer warranty and our workmanship warranty. Critical point: the SPF warranty typically requires periodic topcoat recoats to remain in effect. If you skip the recoats, the warranty doesn't honor failures attributable to UV-degraded foam. The recoat schedule isn't optional maintenance — it's part of what keeps the warranty active. We'll document the schedule and the registration."

### BUR work (Chapter 9)

> "On BUR work, the warranty layers depend on the scope. Restoration coating has the coating manufacturer's warranty. TPO overlay has the TPO manufacturer's system warranty. Full replacement has whatever system you choose. In all cases, our workmanship warranty covers installation. Common BUR-related warranty issues: pre-existing wet insulation that was missed during prep, multi-layer issues that weren't fully addressed, and asbestos discovered during work. We address these up front so the warranty path is clean."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '9'
);

-- Part 3 / Ch 12 / Sec 10: The Comparison-Quote Conversation on Warranty
UPDATE sections SET
  content_markdown = $mfst$Customers comparing quotes often see different warranty terms and don't know how to evaluate them.

> "When you compare warranties between proposals, look at three things: the length, the type, and what's actually covered. A 30-year material warranty and a 30-year NDL system warranty are very different — the NDL is significantly stronger. A 5-year workmanship warranty and a 25-year workmanship warranty cover different lengths of installation responsibility. Specific exclusions matter too — some warranties exclude ponding entirely; others have defined tolerances. The warranty length on the front of the proposal doesn't tell you much; the actual terms do. I'm happy to walk through the differences."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '10'
);

-- Part 3 / Ch 12 / Sec 11: When Customers File Claims
UPDATE sections SET
  content_markdown = $mfst$Reps occasionally help customers navigate the claim process. The rep's role is documentation and guidance, not advocacy that exceeds authorization.

What reps may do:
- Help the customer locate their warranty documents
- Explain what the warranty covers based on the document text
- Provide inspection documentation that supports the claim
- Coordinate with the manufacturer or production team as the claim proceeds

What reps may NOT do:
- Promise the manufacturer will accept the claim
- Negotiate with the manufacturer on coverage decisions
- Imply the rep has authority over the claim outcome
- Tell the customer what the manufacturer "must" cover

> "We can document conditions and provide what supports your claim. The decision is the manufacturer's based on your warranty terms and their assessment. We'll be straight with you about what we think is covered and what's likely outside the warranty, but the final call is theirs."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '11'
);

-- Part 3 / Ch 12 / Sec 12: Common Sales Mistakes on Warranty
UPDATE sections SET
  content_markdown = $mfst$- Promising "the warranty covers everything"
- Equating manufacturer warranty length with roof service life
- Treating "lifetime warranty" as accurate without context
- Skipping the layered-warranty explanation
- Promising claim outcomes
- Failing to flag the substrate-not-covered point on coating warranties
- Failing to flag the maintenance-required point on SPF warranties
- Promising warranty transferability without verifying terms
- Recommending restoration on substrates that won't be covered, then implying the warranty protects the customer
- Using warranty length to anchor pricing comparisons without addressing actual coverage differences$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '12'
);

-- Part 3 / Ch 12 / Sec 13: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer says | Rep should |
|---|---|
| "Is this covered under warranty?" | Walk through the layered structure; review the specific document |
| "Doesn't lifetime mean lifetime?" | Explain the non-prorated/prorated structure honestly |
| "I have a 30-year shingle so the roof lasts 30 years" | Distinguish warranty length from service life |
| "The warranty will cover any leaks" | Explain what's covered and the common exclusions |
| "Will the manufacturer pay for replacement?" | Don't promise outcomes; explain how claims work |
| "Other contractor said the warranty covers everything" | Don't bash the contractor; explain what warranties typically actually cover |
| "Does the warranty transfer if I sell?" | Check the document; don't promise transferability |
| "What if I miss a maintenance visit?" | Check the warranty's maintenance requirements; explain implications |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '13'
);

-- Part 3 / Ch 12 / Sec 14: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Warranties are documents with specific coverage, specific exclusions, and specific requirements. Most roof systems have multiple warranty layers — manufacturer material, manufacturer system, and contractor workmanship — that customers often conflate. "Lifetime warranty" doesn't mean the roof lasts a lifetime; it usually means a non-prorated period followed by prorated coverage that diminishes over time. Common exclusions across systems include inadequate ventilation, ponding water, chemical exposure, damage from other trades, modifications without approval, missed maintenance, and conditions outside the warranty's scope. Coating warranties cover the coating, not the substrate. SPF warranties typically require periodic topcoat recoats to remain in effect. Reps must not promise that "the warranty covers everything," equate warranty length with service life, or promise specific claim outcomes. The honest pattern is to explain the layered structure, surface the most relevant exclusions, walk through the actual documents with the customer, and engage genuinely with what the warranty does and doesn't do. Customers who understand their actual coverage trust the rep more than customers who were told the warranty covers everything and find out later it doesn't.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 12 AND s.section_number = '14'
);

-- Part 3 / Ch 13 / Sec 1: Why This Module Exists
UPDATE sections SET
  content_markdown = $mfst$There's a common framing in sales training: "sometimes honesty costs you the sale." The idea is that doing the right thing sometimes loses the deal — and reps need the discipline to accept that loss for the sake of integrity.

The framing sounds principled, but it's not quite accurate. Honesty doesn't cost the sale. It changes *which sale you make and when.*

A customer told honestly that their roof needs maintenance, not replacement, becomes a maintenance customer today. They become a restoration customer in five to seven years when the roof reaches the qualifying window. They become a replacement customer in fifteen to twenty years when the roof reaches end of life. They refer their neighbors throughout. The total business from that relationship over twenty years exceeds what a one-time replacement sale would have been — by multiples.

A customer told honestly that their roof doesn't qualify for restoration becomes either a replacement customer today (if budget supports it) or a customer who comes back later when conditions change. The honest no isn't a loss; it's a deferred or different work scope.

A customer told honestly that USA Flat Roof isn't the right contractor for what they're asking becomes a referral source for their friends and a return customer if their needs change to fit USA Flat Roof's scope.

The framing of this module isn't "accept that honesty costs you sales." It's "understand that honesty *is* the long-term sale, and the rep who internalizes that doesn't have to choose between integrity and effectiveness."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '1'
);

-- Part 3 / Ch 13 / Sec 2: The One-Sentence Version
UPDATE sections SET
  content_markdown = $mfst$There's no honest answer that loses the customer. The work just shifts in time.

That's the whole module. Everything else is how to live up to it.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '2'
);

-- Part 3 / Ch 13 / Sec 3: The Three Categories of "Honest Loss" That Aren't Actually Losses
UPDATE sections SET
  content_markdown = $mfst$Reps sometimes think they "lost" a deal by being honest. Look at the three most common patterns and what each one actually produces.

### Category 1: The customer wanted more scope than the roof needs

The customer wanted replacement on a roof with significant remaining life. The rep recommended repair and a maintenance program. The customer expected a $20,000 replacement quote and got a $1,200 repair quote with optional maintenance.

**What the rep "lost":** the $20,000 replacement.

**What actually happens:**
- The customer chooses USA Flat Roof for the repair (or doesn't — but the relationship is intact either way)
- The customer trusts the rep because the rep didn't oversell
- The customer enrolls in a maintenance program, becoming a long-term relationship
- In 8 years, when the roof actually does need replacement, the customer calls USA Flat Roof first
- In the meantime, the customer refers neighbors who watch the rep's honesty play out
- The total relationship over time meaningfully exceeds the one-time inflated sale

The honest answer didn't cost the sale. It created a long-term customer.

### Category 2: The customer wanted scope that doesn't fit the roof

The customer wanted silicone restoration on a chronically ponded roof with wet insulation. The rep declined to write that proposal and recommended replacement instead. The customer chose another contractor who'd write the cheaper coating proposal.

**What the rep "lost":** the coating proposal.

**What actually happens:**
- The other contractor's coating fails within 2–3 years
- The customer is back in the market for replacement, this time with depleted patience for being misled
- The customer remembers that USA Flat Roof was the contractor who told them honestly the coating wouldn't work
- The customer calls back, often with a stronger relationship than if the original transaction had happened
- The customer also tells everyone they know about the contrast between the two contractors

The honest decline didn't cost the sale. It deferred it and added a referral pattern that compounds over years.

### Category 3: The customer wanted work outside USA Flat Roof's scope

The customer wanted full clay tile replacement, or a real wood shake re-roof, or some other system USA Flat Roof doesn't install. The rep referred them to a specialty contractor instead of writing a proposal that wouldn't fit.

**What the rep "lost":** a project they couldn't have delivered well anyway.

**What actually happens:**
- The customer respects the referral and remembers it as professional
- The specialty contractor sometimes refers work back when their customers need flat-roof or composition shingle work
- The original customer, when they have additional needs that fit USA Flat Roof's scope, calls back
- The original customer also refers others who might fit USA Flat Roof's scope better

A referral isn't a loss. It's a relationship deposit with both the customer and the receiving contractor.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '3'
);

-- Part 3 / Ch 13 / Sec 4: The Maintenance Pipeline as the Honesty Engine
UPDATE sections SET
  content_markdown = $mfst$The pattern that makes the math work is simple: USA Flat Roof has a maintenance program that captures customers who don't need major work today. Maintenance customers become the customer base for tomorrow's restoration and replacement work.

The pipeline:

- **Year 1:** Customer enrolls in annual maintenance after honest "you don't need replacement" inspection
- **Years 2–5:** Annual maintenance visits document conditions, build trust, and catch small issues early
- **Years 5–8:** Roof reaches the rejuvenation qualifying window; maintenance customer becomes rejuvenation customer
- **Years 8–15:** Maintenance continues; conditions develop that may eventually warrant restoration coating
- **Years 15+:** Roof approaches end of life; maintenance customer becomes replacement customer with full documentation history

At every stage, the customer chooses USA Flat Roof because the relationship was built on honesty. The maintenance program isn't a consolation prize for not closing a replacement — it's the structural mechanism that converts honesty into long-term revenue.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's maintenance program offerings, pricing tiers, and the rep workflow for enrollment.

The honest framing for this in customer conversation:

> "Your roof doesn't need replacement today. What it needs is maintenance — annual inspection, debris management, and small repairs as they come up. Done well, that maintenance approach extends life by years and makes sure you're not surprised by something that could have been caught early. We have a maintenance program that handles all of that on a schedule, with documentation you keep for warranty and resale purposes. When the roof eventually does need bigger work, we'll have years of documented history that makes the decision and the proposal easy."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '4'
);

-- Part 3 / Ch 13 / Sec 5: The Compound Math
UPDATE sections SET
  content_markdown = $mfst$A simple comparison illustrates why honesty produces more revenue, not less.

### Scenario A: Pressure-driven sale

- Year 1: Customer pressured into $20,000 replacement on a roof that didn't need it
- Customer feels uneasy about the experience but accepts the work
- Years 2–20: Customer never calls USA Flat Roof again
- Customer doesn't refer anyone — actively warns acquaintances
- **Total relationship value: $20,000, with negative referral impact**

### Scenario B: Honest recommendation, same starting customer

- Year 1: Customer told honestly that repair and maintenance is the right call. $1,200 repair + $400 annual maintenance program enrollment
- Years 2–7: Annual maintenance ($400/year × 6 = $2,400)
- Year 8: Rejuvenation when roof qualifies ($3,500)
- Years 8–14: Continued maintenance ($400/year × 6 = $2,400)
- Year 15: Replacement when roof reaches end of life ($22,000)
- Customer refers 2–3 neighbors over the relationship period, with similar long-term patterns
- **Direct relationship value: $31,500, plus referral revenue that often exceeds direct revenue**

The math isn't close. Scenario A produces $20,000 once. Scenario B produces $31,500 directly plus ongoing referral revenue that compounds over years. Honesty doesn't cost the sale; it produces a substantially larger sale spread over time, with relationship benefits that the pressure-driven model can't match.

This isn't theoretical. It's how successful contractors actually grow over decades.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '5'
);

-- Part 3 / Ch 13 / Sec 6: The Moments That Test the Discipline
UPDATE sections SET
  content_markdown = $mfst$Three recurring scenarios test whether the rep actually believes the framing in this module.

### Test 1: The customer who explicitly wants the scope that doesn't fit

The customer says they've thought about it, they want restoration, they understand the rep's concerns, they want to proceed anyway.

The rep's discipline: hold the line.

> "I appreciate that you've considered it. The reason I won't write the restoration proposal isn't about your decision-making — it's that I don't believe restoration will perform on this substrate, and the manufacturer warranty wouldn't honor it. If I write the proposal, I'd be selling you something I don't believe in. What I can do is the alternatives we discussed, or — if you want to proceed with restoration through someone else — I can give you a name and we can revisit when conditions change."

The rep doesn't capitulate. The customer either accepts the alternatives or goes elsewhere. Either way, the relationship is intact for the future.

### Test 2: The "competitor will do it" pressure

The customer says another contractor will do the work the rep declined.

The rep's response: "Then they should do it." Calmly, without competing on the wrong terms.

> "If another contractor is willing to write that scope, that's their call. We won't write a proposal for work we don't believe in just to avoid losing the deal. If their work performs, you saved money. If it doesn't, you'll know who told you the truth up front. We'll be here either way."

This response has no defensiveness in it. The rep isn't worried about losing the deal because losing it on these terms is fine — the deferred sale or the referral comes back over time.

### Test 3: The repeat customer who wants something that doesn't fit

A repeat customer — maintenance enrollment, prior projects, established relationship — asks for restoration on a non-qualifying roof. The pull to capitulate is stronger here than with new customers.

The rep's discipline: the long-term relationship is exactly the reason to hold the line.

> "I value the relationship we've built — that's why I want to be straight with you here. This roof doesn't qualify for restoration, and writing a proposal that won't perform would damage what we've built more than declining the proposal will. Here's the alternative I'd recommend, and we can revisit if conditions change."

A long-term customer who pushes back on this kind of honest decline often respects it more, not less. They've seen the rep's pattern over years. The pattern is what made the relationship valuable.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '6'
);

-- Part 3 / Ch 13 / Sec 7: What "Holding the Line" Actually Looks Like
UPDATE sections SET
  content_markdown = $mfst$The behavioral pattern across all three tests is the same:

- **Acknowledge the customer's preference** without dismissing it
- **State the recommendation clearly** without apologizing for it
- **Explain the reasoning briefly** without lecturing
- **Offer the alternative** without pressure
- **Accept the customer's decision** even if it's to go elsewhere
- **Leave the door open** for future engagement

The rep doesn't argue. The rep doesn't capitulate. The rep doesn't take the customer's choice personally. The rep maintains professional warmth and lets the customer make the call from accurate information.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '7'
);

-- Part 3 / Ch 13 / Sec 8: The Internal Discipline
UPDATE sections SET
  content_markdown = $mfst$Reps who internalize this framing stop experiencing certain conversations as stressful.

The "I'm declining this proposal" conversation isn't a loss to be endured — it's a relationship deposit being made. The customer who walks away today is a future customer who'll remember being told the truth. The customer who stays today is a customer the rep can serve well because the foundation is honest.

This shift produces practical effects:

- **Calmer pricing conversations** because the rep isn't trying to close at all costs
- **Cleaner declines** because the rep doesn't need to soften the no into uselessness
- **Better referrals** because the rep can refer confidently when the project doesn't fit
- **Stronger long-term relationships** because every customer interaction adds to the relationship account
- **Reduced burnout** because the rep doesn't carry the weight of selling work they don't believe in

The discipline becomes natural over time. Reps who've practiced the framing for a year find themselves declining bad-fit work without the discomfort newer reps feel.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '8'
);

-- Part 3 / Ch 13 / Sec 9: Common Phrases the Rep Uses
UPDATE sections SET
  content_markdown = $mfst$The language reps actually use in these moments:

- "We won't write that proposal because we don't believe it'll perform."
- "Take the time you need; we'll be here when you're ready."
- "If another contractor is willing to do this, that's their call."
- "I'd rather lose this deal than sell you something that won't work."
- "Maintenance is the right answer for your roof today, and we'll revisit when conditions change."
- "The work doesn't disappear; it just changes shape over time."
- "I'm not the right contractor for this — here's someone who is."

These phrases aren't scripts. They're the natural expression of the underlying view: there's no honest answer that loses the customer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '9'
);

-- Part 3 / Ch 13 / Sec 10: When the Customer Does Walk Away
UPDATE sections SET
  content_markdown = $mfst$Sometimes the customer takes the work elsewhere despite the rep's honest recommendation. The rep's response: clean exit, door left open.

> "I understand. If your situation changes or you want a second opinion later, we're happy to talk. No hard feelings on the decision — you have to do what's right for your situation."

No bitterness. No "I told you so" energy reserved for later. No subtle pressure. The exit is clean because the relationship account is more valuable than the closed deal.

When the customer comes back — and many do, sometimes years later — they come back to a rep who treated the original "no" with grace. That return engagement is often worth more than the original deal would have been.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '10'
);

-- Part 3 / Ch 13 / Sec 11: When the Customer Stays
UPDATE sections SET
  content_markdown = $mfst$Sometimes the honest answer is also the answer the customer wanted to hear, or close to it. They needed the maintenance recommendation; they got it. They needed the repair-plus-plan conversation; they got it. They needed the referral; they got it.

In these cases, the customer often becomes one of the most loyal accounts USA Flat Roof has — because the rep gave them what they actually needed, communicated honestly, and built trust without pressure.

These customers are the foundation of the long-term business. Every honest interaction is a deposit; over time, the deposits compound.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '11'
);

-- Part 3 / Ch 13 / Sec 12: Common Mistakes That Undermine the Framing
UPDATE sections SET
  content_markdown = $mfst$- Treating the honest decline as a loss the rep has to grit their teeth through
- Subtle pressure tactics that bleed into the conversation when the rep feels the deal slipping
- Capitulating on bad-fit proposals to "keep the customer"
- Bashing the customer privately ("they didn't get it") when they take the work elsewhere
- Failing to enroll maintenance customers because the dollars are small
- Treating maintenance customers as second-class compared to replacement customers
- Not following up appropriately when conditions change

The behavioral pattern that makes this module work is consistent professionalism across all customer outcomes — the deal closes, the deal defers, the deal goes elsewhere. Each is part of the long-term relationship, and the rep treats each accordingly.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '12'
);

-- Part 3 / Ch 13 / Sec 13: Quick Reference
UPDATE sections SET
  content_markdown = $mfst$| Customer outcome | Rep's interpretation |
|---|---|
| Closes the deal honestly | Direct revenue + relationship account deposit |
| Maintenance enrollment instead of replacement | Long-term pipeline + relationship deposit |
| Declines our proposal, goes elsewhere | Deferred sale + referral pattern over time |
| Wants something we won't write | Honest decline + door left open |
| Wants something we don't do | Referral + reciprocal relationship + future return |
| Comes back years later | Validation of the original honesty |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '13'
);

-- Part 3 / Ch 13 / Sec 14: Module Summary
UPDATE sections SET
  content_markdown = $mfst$Honesty doesn't cost the sale. It changes which sale you make and when. Customers told honestly that they need maintenance instead of replacement become long-term maintenance, restoration, and eventually replacement customers — with referrals that compound over years. Customers told honestly that their preferred scope doesn't fit either accept the alternative or come back later when the cheaper contractor's work fails. Customers referred to specialty contractors for work USA Flat Roof doesn't do build reciprocal relationships and return for work that does fit. The maintenance program is the structural mechanism that captures customers who don't need major work today and converts them into long-term relationships. Reps who internalize this framing stop experiencing honest conversations as losses; they recognize each one as a relationship deposit that compounds. The discipline of holding the line on bad-fit proposals isn't sacrifice — it's the path that produces more revenue over time, not less. The work doesn't disappear when the rep tells the truth; it shifts in time, sometimes to USA Flat Roof, sometimes to a referral, always with the rep's reputation intact. There's no honest answer that loses the customer. The rep who internalizes that doesn't have to choose between integrity and effectiveness; the two become the same thing.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 3 AND c.chapter_number = 13 AND s.section_number = '14'
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
  WHERE p.part_number = 3
    AND s.content_markdown != ''
    AND s.content_markdown IS NOT NULL;
  IF populated_count != 176 THEN
    RAISE EXCEPTION 'Phase B import safety check failed (Part 3 only): expected 176 populated sections, found %. Transaction rolled back.', populated_count;
  END IF;
END $$;

COMMIT;
