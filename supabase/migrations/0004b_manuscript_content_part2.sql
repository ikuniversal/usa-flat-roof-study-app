-- Phase B content import: manuscript bodies -> sections.content_markdown (Part 2 only)
-- Source: data/manuscript/extracted-content.json
-- Scope: Part(s) 2, 137 sections
-- Companion to scripts/extract-and-import-content.ts (the live equivalent).
-- Atomicity: single transaction. Either all in-scope sections update + their
-- content_revisions rows insert, or nothing changes (defensive count check
-- before COMMIT raises and rolls back if the post-import populated count is
-- not exactly 137).
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
WHERE p.part_number = 2;

-- 137 UPDATE statements: one per manuscript section.
-- Subquery resolves section.id by (part_number, chapter_number, section_number).
-- Each UPDATE writes the manuscript body and bumps updated_at.

-- Part 2 / Ch 11 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain the difference between maintenance and repair in plain language, and why both matter to a customer's roof investment.
2. Identify the categories of maintenance work USA Flat Roof performs across the systems covered in earlier chapters.
3. Position maintenance as a real product offering — not a leftover when no major work is appropriate.
4. Recommend repair work honestly, including when the right call is repair *plus* a longer-term plan rather than repair alone.
5. Recognize when a maintenance or repair call should escalate to a senior estimator or trigger a referral.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '1'
);

-- Part 2 / Ch 11 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$Most roof system chapters in this book end with three options: repair, restoration, or replacement. This chapter steps back and treats maintenance and repair as their own subject — because the way reps handle these conversations sets the tone for everything else.

Two patterns to watch for:

**Pattern A: Reps undersell maintenance because the dollars are smaller.** A maintenance call generates less revenue than a replacement, so the temptation is to push the conversation toward bigger work. But maintenance customers, treated well, become the source of the next ten years of work — repairs, restoration, and eventually replacement. Maintenance is not a small product; it's the gateway to every other product.

**Pattern B: Reps oversell repair because patching is easier to close than the honest conversation.** A leak gets patched, the customer is happy today, and no one mentions that the roof is at end of life. Two years later the customer has paid for several patches and still has a failing roof. The customer is angry, and the rep has lost the relationship. Repair done honestly always includes the broader picture, even when the broader picture is uncomfortable.

This chapter is about doing both well.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '2'
);

-- Part 2 / Ch 11 / Sec 3: Maintenance vs Repair — Plain Language
UPDATE sections SET
  content_markdown = $mfst$The two words are often used interchangeably, but they describe different work:

- **Maintenance** is *preventive*. It addresses normal wear and small issues before they become problems. Maintenance is scheduled, recurring, and intended to extend service life. Cleaning gutters, clearing debris, resealing exposed fasteners, replacing a worn pipe boot before it leaks — all maintenance.
- **Repair** is *responsive*. It addresses a specific failure or active problem. Patching a torn membrane, replacing broken tiles, fixing a leak — all repair.

Both are within USA Flat Roof's scope on the systems covered in Chapters 1–10. The line between them is blurry in practice — a maintenance visit may turn up something that requires repair, and a repair visit often includes maintenance items at the same time.

### Why customers undervalue maintenance

The standard customer mindset on roofing is reactive: call when there's a leak. This costs customers money over time because:

- Small issues become big issues when ignored
- Warranty coverage often requires documented maintenance
- Deferred maintenance is one of the leading causes of premature roof failure
- Insurance claims involving "maintenance failures" face additional scrutiny

A rep's job is to explain this without being preachy or pushy. The honest framing: "Maintenance is what you do to make the roof you have last as long as it can. It's not optional if you want the warranty to perform or the roof to reach its expected service life."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '3'
);

-- Part 2 / Ch 11 / Sec 4: Categories of Maintenance Work
UPDATE sections SET
  content_markdown = $mfst$Across the roof systems USA Flat Roof works on, maintenance work falls into a few recurring categories:

### Cleaning and debris management
- Gutter and downspout cleaning
- Drain and scupper clearing on flat roofs
- Debris removal (leaves, branches, pine needles, trash)
- Biological growth treatment (algae, moss, lichens)
- Tile or membrane surface cleaning where appropriate

### Fastener and sealant maintenance
- Resealing exposed fasteners on shingle and metal roofs
- Sealant refresh at flashings, terminations, and detail areas
- Tightening or replacing loose fasteners

### Detail-level component replacement
- Pipe boot replacement before failure
- Drain ring resealing
- Termination bar tightening or replacement
- Worn flashing replacement

### Coating and topcoat refresh
- Periodic silicone topcoat recoat on SPF systems (per Chapter 10)
- Maintenance recoats on previously coated roofs (per Chapter 3)
- Touch-up coating at high-wear areas

### Inspection and documentation
- Annual or semi-annual inspection visits
- Photographic documentation for warranty registration
- Maintenance program enrollment
- Pre-storm and post-storm inspections

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard maintenance program offerings, pricing structure, and service frequency.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '4'
);

-- Part 2 / Ch 11 / Sec 5: Categories of Repair Work
UPDATE sections SET
  content_markdown = $mfst$Repair work also falls into recurring categories. Reps should learn to recognize these from the system chapters and apply consistent language:

### Membrane / surface repairs
- Welded patches on TPO or PVC
- Self-adhered patches on modified bitumen
- Asphalt-cement patches on BUR
- Replacement tiles on tile roofs
- Replacement shingles on composition shingle roofs

### Detail and penetration repairs
- Pipe boot replacement after failure
- Curb flashing repair
- Skylight flashing repair
- Chimney flashing repair (within scope; structural chimney work referred out)
- Vent and conduit penetration sealing

### Drainage and flow repairs
- Drain ring repair or replacement
- Scupper repair
- Drain insert installation

### Edge and termination repairs
- Drip edge repair or replacement
- Parapet flashing repair
- Termination bar repair
- Coping repair (within scope)

### Damage repairs
- Storm damage assessment and repair (within scope; insurance work follows separate process)
- Foot-traffic damage repair
- Tool-drop and trade-damage repair
- Wildlife damage repair (birds, rodents, raccoons — varies by system)

> **[SALES REP BOUNDARY]** Reps may identify and document repair conditions, propose repair scopes within their training and authorization, and escalate work outside their scope. Reps may not certify hail damage for insurance purposes, certify structural integrity, or commit to repair scopes that exceed company-approved limits.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '5'
);

-- Part 2 / Ch 11 / Sec 6: Field Inspection Approach for Maintenance and Repair Calls
UPDATE sections SET
  content_markdown = $mfst$Maintenance and repair calls have different starting points than restoration or replacement calls, but the inspection itself follows the same disciplined approach.

### For a maintenance call

The customer is not reporting a problem. The rep's job is to:

1. Conduct a full system inspection per the relevant chapter (Chapters 1–10)
2. Document conditions across all three severity levels — Monitor, Maintenance Needed, Repair Recommended
3. Identify any items that have crossed into Urgent / Escalate territory
4. Propose a maintenance scope appropriate to current condition
5. Flag any items the customer should know about that are not maintenance work — aging conditions, eventual replacement timing, warranty considerations

### For a repair call

The customer has a specific problem — usually a leak or visible damage. The rep's job is to:

1. Address the immediate concern with appropriate inspection
2. **Locate the actual source of the problem.** Leak entry points are rarely directly above the visible interior damage. Rep work that patches the wrong location is worse than no work — the customer pays, the leak continues, trust is destroyed.
3. Conduct a broader system inspection beyond the reported issue
4. Identify whether the reported issue is isolated or part of a pattern
5. Propose repair scope that addresses both the immediate issue and any related conditions

### The leak-source rule

When a customer reports a leak, never assume the entry point is directly above the interior damage. Water travels along structural members, electrical conduits, insulation, and substrate before reaching the visible point. A leak showing in a hallway ceiling may originate at a parapet flashing thirty feet away.

This means a leak repair call almost always requires a full roof inspection, not just a focused look at the area above the staining. Reps who skip the broader inspection cause more damage than they fix.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '6'
);

-- Part 2 / Ch 11 / Sec 7: The Repair-Plus-Plan Conversation
UPDATE sections SET
  content_markdown = $mfst$Some of the most important moments on repair calls are when the right answer is "yes, we'll do the repair — and you also need to know what's happening with your roof overall."

### When to have this conversation

- The roof is at the older end of its service range
- The reported problem is one of a pattern (multiple recent leaks, repeated callbacks)
- Inspection reveals conditions consistent with broader aging
- The customer's framing minimizes the work that's actually needed

### How to have it

The structure: do the requested repair (when appropriate), then add the longer-term context honestly.

> "We can patch the leak today — that's a real repair, and you'll be dry. While we were up there, we also documented [conditions]. Your roof is at [age range], which puts it in the back half of its expected service. The patch buys you time, but I want to be straight with you that the underlying age of the system is the bigger picture. I can put a longer-term plan on paper for you to look at on your timeline. No pressure today — just so you have the full picture."

### What to avoid

- Refusing to do the repair to "force" the larger conversation
- Doing the repair without mentioning broader conditions when they exist
- Pressuring the customer to commit to replacement during the repair visit
- Making the customer feel embarrassed for asking for a patch
- Quoting specific remaining-life numbers (Rule 2 — no fake precision)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '7'
);

-- Part 2 / Ch 11 / Sec 8: Maintenance Programs as a Sales Strategy
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof's maintenance offerings can be structured as one-time service or as ongoing programs. Reps should understand both.

### One-time maintenance service

A single visit to address current conditions. Appropriate for:

- Customers new to maintenance who want to start somewhere
- Customers preparing for sale or pre-listing inspection
- Pre-storm or post-storm visits
- Initial baseline before deciding on a recurring program

### Recurring maintenance programs

Scheduled service at defined intervals — annual, semi-annual, or based on system requirements (e.g., SPF topcoat recoat schedules per Chapter 10). Appropriate for:

- Property managers with multiple properties
- Building owners who value documentation for warranty and insurance purposes
- Customers with new or recently-restored roofs who want to maximize service life
- Customers with valuable inventory or business operations under the roof

### Why programs benefit the customer

- Predictable budget for maintenance (no surprise costs)
- Documentation that supports warranty claims
- Early identification of issues before they become emergencies
- Often discounted pricing versus one-time visits

### Why programs benefit USA Flat Roof

- Recurring revenue and customer retention
- First call when bigger work eventually becomes appropriate
- Stronger relationship for referrals
- Reduced emergency-response load

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's specific maintenance program offerings, pricing tiers, frequency, and inclusions.

### Honest positioning of maintenance programs

A maintenance program is a real product, not a sales gimmick. Reps should not:

- Pressure customers into programs they don't want
- Misrepresent program inclusions (especially what is *not* covered)
- Promise warranty outcomes contingent on program enrollment without documentation
- Position maintenance as a substitute for needed repair or replacement$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '8'
);

-- Part 2 / Ch 11 / Sec 9: Pricing and Proposal Considerations
UPDATE sections SET
  content_markdown = $mfst$Maintenance and repair work has unique pricing dynamics worth understanding.

### Maintenance pricing
- Often priced per-visit or per-square-foot
- May include recurring discount when bundled into a program
- Typically smaller dollar amounts than restoration or replacement
- Repeat business compounds over time

### Repair pricing
- Often priced per-occurrence based on scope and complexity
- May include a service-call minimum
- Larger repairs may require formal proposal; smaller repairs may proceed under a simpler authorization
- Emergency repair may carry premium pricing per company policy

### What reps must NOT do
- Quote prices outside their authorization
- Discount work below approved minimums to close the deal
- Bundle work without clear scope documentation
- Promise pricing for work not yet inspected ("oh, that should be about $X based on what you're describing on the phone")
- Skip written documentation on smaller repairs to save time

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's pricing authorization levels, emergency-repair policy, and proposal documentation standards.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '9'
);

-- Part 2 / Ch 11 / Sec 10: Common Maintenance and Repair Mistakes
UPDATE sections SET
  content_markdown = $mfst$Mistakes in this category come up regularly. Reps should learn to recognize and avoid them.

### Mistakes when selling maintenance

- Treating maintenance as "small" work and not investing time in the inspection
- Skipping documentation on maintenance visits
- Not flagging items that have crossed into repair territory
- Overpromising what maintenance can prevent
- Failing to communicate when maintenance is no longer appropriate (end-of-life systems)

### Mistakes when selling repairs

- Patching the wrong location (skipping leak source identification)
- Patching only without inspecting the rest of the roof
- Doing the repair without disclosing broader conditions
- Recommending replacement when repair would be appropriate (margin-driven, not customer-driven)
- Recommending repair when replacement would be appropriate (pattern of repeat repairs on an end-of-life system)
- Promising the repair will solve a problem the rep can't actually diagnose
- Missing flashing or detail work in the repair scope (the repair patches the membrane but the leak was at the flashing)

### Mistakes in customer communication

- Calling small repairs "no big deal" when documentation matters
- Calling small repairs "major" when they aren't, to upsell
- Telling customers a single repair guarantees no future leaks
- Promising warranty coverage on repair work without reading the warranty
- Discussing other contractors' work disparagingly without seeing it$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '10'
);

-- Part 2 / Ch 11 / Sec 11: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### When the customer wants maintenance

> "Maintenance is what makes the roof you already have last as long as it should. We do an inspection, address anything that's wear-level today, and document everything for your records. The number is smaller than restoration or replacement, and that's the point — small money now to avoid bigger money later, and to make sure the warranty performs the way it's supposed to."

### When the customer wants a repair

> "Let's start by finding the actual source of the problem. Leak entry points are almost never directly above the visible damage inside — water travels along the structure before it shows up. Once we find the source, we can scope a real repair. While we're up there, we'll also do a broader look so you have the full picture, not just the leak."

### When the customer's repair call reveals broader issues

> "We can definitely do this repair, and it's a real fix for the issue you called about. While we were up there we also documented some other conditions worth knowing about — [specific findings]. The repair gets you dry today; the rest is a longer conversation about your roof overall. I'll put both on paper so you can decide on your timeline. No pressure right now."

### When maintenance is genuinely the right answer despite customer doubts

> "Honestly, you don't need restoration or replacement on this roof — you need to keep up with maintenance. The system is in good shape for its age. The biggest risk to your roof from here is something small turning into something big because nobody is checking on it. A maintenance program is the most cost-effective option for you, even though it's the smallest number we'd write."

### When repair is *not* the right answer

> "I want to be honest with you — patching this leak isn't going to solve your problem. The roof is at [age range] and we documented [pattern of conditions]. We can do the patch and you'll be dry for a while, but you're going to be calling someone again within a year or two. Spending money on repeat patches on a roof at this stage isn't the call I'd make if it were my building. The honest answer is replacement. I can put both options on paper — patch with a replacement plan, or replacement now — and you decide."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '11'
);

-- Part 2 / Ch 11 / Sec 12: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- A repair scope exceeds the rep's training or authorization
- A leak source cannot be identified after inspection
- The customer's reported issue is part of a pattern suggesting end-of-life roof
- Insurance claim involvement (storm or hail damage)
- Suspected structural issues underlying a leak
- Suspected mold, asbestos, or other hazard
- Customer requesting work outside USA Flat Roof's scope (refer per relevant chapter)
- Maintenance call reveals an Urgent severity condition the rep is not authorized to address
- Pricing or scope dispute that cannot be resolved at the rep level$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '12'
);

-- Part 2 / Ch 11 / Sec 13: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard maintenance program offerings, pricing, and frequency: [placeholder]
> - Our standard repair pricing and authorization tiers: [placeholder]
> - Our emergency-repair policy and after-hours availability: [placeholder]
> - Our documentation requirements for maintenance and repair calls: [placeholder]
> - Our position on leak-source identification before patching: [placeholder]
> - Our handoff process from sales to production for repair and maintenance work: [placeholder]
> - Our maintenance program enrollment process: [placeholder]
> - Our customer communication standards for repair-plus-plan conversations: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '13'
);

-- Part 2 / Ch 11 / Sec 14: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat maintenance as "small" work that doesn't deserve the same inspection rigor as bigger projects.
- They patch the wrong location because they didn't identify the actual leak source.
- They don't have the repair-plus-plan conversation when conditions warrant it.
- They oversell replacement on roofs where repair would be appropriate.
- They undersell repair on roofs that genuinely need replacement.
- They skip written documentation on smaller jobs.

**Discussion questions for group training**
- Walk through a maintenance call where the customer doesn't think they need anything. How do you make it valuable for them and for the company?
- A customer reports a ceiling stain in a back bedroom. How do you find the actual leak source?
- An 18-year-old roof has a single failed pipe boot. The customer wants a quick patch. The roof is at the older end of expected service. How do you handle the conversation?
- A property manager wants the cheapest repair on a building that's clearly past end of life. What do you say?
- What's the 30-second answer to "why do I need a maintenance program?"

**Field exercises**
- Pair up. Walk through three repair scenarios where the leak source isn't obvious. Practice identifying possible entry points based on water travel patterns.
- Practice the repair-plus-plan conversation in role-play. Trade roles between customer and rep.
- Review three maintenance proposals (real or constructed). Identify whether each scope matches the system condition, or under- or over-scopes.

**What the manager should test verbally**
- Distinguish maintenance from repair in plain customer language.
- Walk through the leak-source rule and why it matters.
- Walk through the repair-plus-plan conversation.
- State three maintenance and three repair categories USA Flat Roof handles.
- State five things a rep must not do on maintenance and repair calls.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '14'
);

-- Part 2 / Ch 11 / Sec 15: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Detail repair** — repair work focused on flashings, penetrations, terminations, or other system details rather than the main membrane field.
- **Emergency repair** — repair work performed outside normal scheduling to address active leaks or imminent failure.
- **Leak source** — the actual point on the roof where water enters; rarely directly above the interior damage.
- **Maintenance** — preventive work intended to extend service life and prevent failures.
- **Maintenance program** — recurring scheduled service offering, typically annual or semi-annual.
- **Repair** — responsive work that addresses a specific existing failure or damage.
- **Repair-plus-plan** — repair work combined with honest disclosure of broader system conditions and a longer-term recommendation.
- **Service-call minimum** — minimum charge applied to repair calls regardless of scope size.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '15'
);

-- Part 2 / Ch 11 / Sec 16: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Maintenance and repair are two distinct categories of work, both within USA Flat Roof's scope across the systems covered in earlier chapters. Maintenance is preventive — scheduled, recurring, and intended to extend service life. Repair is responsive — addressing specific failures or damage. Both deserve disciplined inspection, honest scope, and clear documentation. The most common mistakes in this category are underselling maintenance because the dollars are small (and missing the long-term customer relationship that maintenance builds), overselling repair because patching is easier than the harder honest conversation about end-of-life systems, and patching the wrong leak source because the rep didn't conduct a broader inspection. The repair-plus-plan conversation — doing the repair while honestly disclosing broader conditions — is the consistent right answer when conditions warrant it. Maintenance programs are real products, not gimmicks, and benefit both customer and company when positioned honestly.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '16'
);

-- Part 2 / Ch 11 / Sec 17: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The difference between maintenance and repair is best described as:
A. Maintenance is cheaper; repair is more expensive
B. Maintenance is preventive; repair is responsive to specific failures
C. Maintenance is for residential; repair is for commercial
D. There is no meaningful difference

**2. (Beginner)** When a customer reports a ceiling leak, the entry point on the roof is:
A. Always directly above the interior damage
B. Rarely directly above the interior damage; water travels before showing inside
C. Impossible to identify without specialty equipment
D. Always at the nearest penetration

**3. (Beginner)** Maintenance work commonly includes:
A. Full roof replacement
B. Cleaning, debris management, sealant refresh, and inspection
C. Insurance claim filing
D. Structural repairs

**4. (Intermediate)** A customer asks for a "quick patch" on an 18-year-old roof at the older end of its expected service range. The most appropriate response is:
A. Decline the patch and insist on replacement
B. Do the patch without comment
C. Do the patch and have the repair-plus-plan conversation, presenting longer-term options without pressure
D. Refer the customer elsewhere

**5. (Intermediate)** A maintenance call reveals an Urgent severity condition the rep is not authorized to address. The most appropriate response is:
A. Address it anyway to be helpful
B. Ignore it and complete the maintenance scope only
C. Document the condition, escalate, and communicate the finding to the customer
D. Quote a price on the spot

**6. (Intermediate)** Why should reps avoid quoting prices for repair work over the phone before inspecting?
A. Phone calls are not allowed
B. Pricing without inspection produces inaccurate scopes and damages credibility when the actual work differs
C. Reps don't know the company's pricing
D. Customers prefer in-person conversations only

**7. (Intermediate)** A property manager doesn't want a maintenance program. The most appropriate rep response is:
A. Pressure them to enroll
B. Explain the benefits honestly, accept the customer's decision, and offer one-time service as an alternative
C. Decline to do any work without enrollment
D. Misrepresent program inclusions to make it more attractive

**8. (Advanced)** A customer with three leaks in 18 months on a 24-year-old roof asks for "another quick repair." The most honest response is:
A. Do the repair without further discussion
B. Decline the work
C. Explain that repeat repairs on a roof of this age are short-term spending, recommend an inspection to assess the system overall, and present replacement options if the assessment supports it
D. Recommend silicone restoration immediately

**9. (Advanced)** A rep arrives for a leak repair and cannot identify the leak source after a full inspection. The most appropriate next step is:
A. Patch the area directly above the interior damage and hope for the best
B. Charge for the inspection and leave without patching
C. Escalate to senior estimator or qualified inspector for further investigation; communicate honestly with the customer
D. Recommend full replacement to be safe

**10. (Advanced)** A long-term maintenance customer's roof has clearly reached end of life. The most appropriate rep response is:
A. Continue maintenance visits indefinitely to preserve the recurring revenue
B. Have the honest conversation: explain that maintenance is no longer the appropriate scope, and recommend replacement options
C. Drop the customer
D. Continue maintenance but raise the price

---

### Answer Key

1. **B — Maintenance is preventive; repair is responsive to specific failures.** This is the central distinction in the chapter. Cost (A) doesn't define the categories; (C) and (D) are wrong.
2. **B — Rarely directly above the interior damage.** This is the leak-source rule from Section 6. Always above (A) is the most common mistake; (C) overstates difficulty; (D) is unsupported.
3. **B — Cleaning, debris management, sealant refresh, and inspection.** Full replacement (A) is replacement, not maintenance. Insurance filing (C) and structural work (D) are outside scope.
4. **C — Do the patch and have the repair-plus-plan conversation.** This is the central honest-handling pattern from Section 7. Refusing the patch (A) is heavy-handed; doing the patch without comment (B) misses the bigger picture; referring (D) abandons the customer.
5. **C — Document, escalate, and communicate.** Addressing it without authorization (A) creates risk. Ignoring (B) is dishonest. Quoting on the spot (D) is outside scope.
6. **B — Pricing without inspection produces inaccurate scopes.** This is the practical reason. (A), (C), and (D) are not the issue.
7. **B — Explain benefits, accept the decision, offer one-time service.** Honest sales practice. Pressure (A) and misrepresentation (D) are unacceptable. Refusing all work (C) abandons the customer.
8. **C — Explain repeat repairs are short-term spending; recommend assessment and replacement options if supported.** This is the honest framework. Doing the repair without discussion (A) is the easy-but-wrong path. Declining (B) abandons the customer. Restoration (D) without inspection is unsupported.
9. **C — Escalate and communicate honestly.** When the rep can't identify the source, escalation is correct. Patching above the damage (A) violates the leak-source rule. Leaving without patching (B) abandons the customer. Recommending replacement (D) is unsupported by inspection findings.
10. **B — Have the honest conversation and recommend replacement.** Continuing maintenance for revenue (A, D) is the textbook ethics failure on long-term customers. Dropping the customer (C) abandons the relationship.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '17'
);

-- Part 2 / Ch 11 / Sec 18: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual maintenance and repair offerings?
- [ ] Matches USA Flat Roof's pricing authorization tiers and proposal standards?
- [ ] Does the maintenance program positioning reflect actual offerings?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 1–10 (Roof Systems)?

**Technical Items to Verify Before Publishing**

- Maintenance program offerings: confirm USA Flat Roof's specific tiers, pricing, frequency, and inclusions.
- Pricing authorization: confirm rep authorization levels for maintenance and repair pricing.
- Emergency repair policy: confirm after-hours availability and pricing standards.
- Documentation requirements: confirm USA Flat Roof's documentation standards for maintenance and repair calls.
- Service-call minimums: confirm current minimums and exceptions.
- Cross-references to Chapters 1–10: verify maintenance and repair scope language is consistent across chapters.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 11 AND s.section_number = '18'
);

-- Part 2 / Ch 12 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Conduct a roof inspection using a consistent, disciplined process regardless of system type.
2. Use drone, ladder-edge, and ground-level inspection methods appropriately and safely.
3. Capture photos that meet professional standards — for documentation, customer presentation, and warranty registration.
4. Produce inspection documentation that serves the customer, the company, and any future warranty or insurance need.
5. Recognize when an inspection finding requires escalation rather than rep-level documentation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '1'
);

-- Part 2 / Ch 12 / Sec 2: Why Documentation Matters
UPDATE sections SET
  content_markdown = $mfst$A roof inspection has three audiences, and good documentation serves all three:

- **The customer** — needs clear evidence of conditions and a defensible basis for any recommendation. Customers are spending real money based on what the rep documents.
- **The company** — needs a record that supports the proposal, the work scope, and any future service call or warranty claim. Disputes about "what was there before" almost always trace back to weak initial documentation.
- **The warranty system** — many manufacturer warranties (especially on coatings, restoration, and SPF) require photos and documentation submitted at specific times. Missing documentation can void coverage years later when the customer needs it.

A rep who documents thoroughly protects all three parties. A rep who documents lazily creates risk for everyone, including themselves.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '2'
);

-- Part 2 / Ch 12 / Sec 3: The Inspection Sequence
UPDATE sections SET
  content_markdown = $mfst$Every inspection follows a similar arc regardless of roof system. The chapter-specific inspection guides in Chapters 1–10 provide the system-specific details; this section covers the general flow.

### Step 1: Pre-arrival
- Review any documentation the customer provided (prior reports, warranty papers, repair history)
- Note building age, address, and any access information
- Confirm equipment: ladder, PPE, camera or phone, drone if applicable, measuring tools, chalk for ponding marks

### Step 2: Customer conversation before inspection
- Introduce yourself and confirm scope of visit
- Ask the lead-qualification questions from the relevant system chapter
- Listen for concerns, history, and customer goals
- Confirm any specific areas the customer wants inspected

### Step 3: Building exterior walk-around
- Photograph all four elevations
- Note parapet condition, gutters, downspouts, scuppers, exterior wall conditions
- Note tree overhang, debris exposure, and adjacent structures
- Note any visible interior leak evidence reported by the customer

### Step 4: Roof access decision
- Decide on inspection method: ground-level only, ladder-edge, drone, or roof walk
- Base the decision on safety, access, customer cooperation, and inspection completeness needed
- **Never walk an unsafe roof** (see Chapter 13 — Safety)

### Step 5: Roof surface inspection
- Photograph each quadrant or slope from elevated view
- Inspect every penetration, drain, scupper, and detail per system chapter
- Inspect every seam, flashing, and termination
- Document conditions with severity ratings

### Step 6: Attic or interior check (where accessible and applicable)
- Note water staining on deck, rafters, or insulation
- Note ventilation provisions
- Note any evidence of past leaks, repairs, or biological growth

### Step 7: Customer conversation after inspection
- Walk through findings honestly
- Apply the severity scale consistently
- Set expectations for any follow-up — proposal timing, additional inspection, escalation
- Avoid quoting prices in the field unless authorized

### Step 8: Documentation completion
- Photo organization and labeling
- Written notes
- Severity ratings applied
- Proposal preparation (separate process)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '3'
);

-- Part 2 / Ch 12 / Sec 4: Inspection Methods
UPDATE sections SET
  content_markdown = $mfst$Reps have several inspection methods available. Choosing the right one is part of the job.

### Ground-level inspection

**When to use:**
- Initial walk-around on every inspection
- When roof access is unsafe or not authorized
- When customer-provided photos can supplement the limited ground view
- For tile roofs where walking is risky

**Limitations:**
- Cannot see most roof surface conditions
- Cannot inspect penetrations, drains, or details directly
- Should never be the *only* inspection method when more thorough methods are available

### Ladder-edge inspection

**When to use:**
- When ladder access is safe and authorized
- When a roof walk is not safe or not warranted
- For limited-scope inspections

**Limitations:**
- Sees only the immediate edge of the roof
- Limited view of mid-roof conditions, drains, and penetrations away from the edge
- Subject to safety constraints

**Safety reminder:** Ladder use must follow OSHA / company policy. Never ladder onto a roof in unsafe weather, on unsafe surfaces, or without the appropriate ladder for the height.

### Drone inspection

**When to use:**
- Multi-story commercial buildings where roof walking is difficult or unsafe
- Tile roofs where walking risks tile damage
- Complex roof geometries where walking misses areas
- Initial overview before deciding whether to walk
- When weather or conditions make walking unsafe but an inspection is needed

**Strengths:**
- Captures wide-area views unavailable from ladder or ground
- Documents conditions without weight or foot-traffic risk
- Provides imagery customers and managers can review remotely
- Safer than walking many roof types

**Limitations:**
- Cannot replace hands-on inspection of seams, fastener tightness, soft spots, or membrane condition close-up
- Quality depends on drone capability, lighting, weather, and operator skill
- Some areas (under HVAC equipment, behind parapets) may not be capturable from above
- May require FAA registration and operator authorization depending on use
- Wind sensitivity can prevent drone use on inspection day

> **[VERIFY LOCALLY]** California and federal drone regulations apply to commercial drone use. Confirm operator certification, airspace restrictions, and customer permission before flying.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's drone use policy, certified operators, equipment standards, and integration with inspection workflow.

### Roof walk inspection

**When to use:**
- When the roof system, slope, weather, and rep training all support safe walking
- When hands-on inspection is necessary to assess seams, soft spots, or fastener condition
- When drone or ladder-edge inspection has identified specific areas needing closer examination

**Safety constraints:**
- Never walk a roof in unsafe weather (rain, ice, high wind, slick conditions)
- Never walk a roof with structural concerns underfoot
- Never walk a tile roof without specific training
- Never walk a steep-slope roof without appropriate fall protection per OSHA / company policy
- Never walk a roof when alone unless company policy explicitly authorizes solo inspection with appropriate safeguards

> **[SALES REP BOUNDARY]** Reps may decline a roof walk based on safety judgment. A skipped walk-up that's documented honestly is always better than an injury or rushed inspection.

### Combination inspection (most common)

The strongest inspections typically combine methods: ground-level walk-around, then drone overview, then targeted roof walk to investigate specific findings. This approach maximizes both safety and completeness.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '4'
);

-- Part 2 / Ch 12 / Sec 5: Photo Standards
UPDATE sections SET
  content_markdown = $mfst$Photos are the most important inspection deliverable. Bad photos make good inspections worthless. Good photos make ordinary inspections defensible.

### What every photo needs
- **Clarity:** in focus, well-lit, visible without zoom
- **Context:** the photo's location on the roof should be identifiable from the image and notes
- **Reference scale where applicable:** business card, tape measure, or chalk mark for size
- **Appropriate angle:** close-up for damage; wide for overview
- **Honest framing:** photos should represent conditions accurately, not exaggerate or minimize

### What to photograph on every inspection

This is a baseline list. System-specific chapters add to it.

**Building and access**
- All four exterior elevations
- Roof access point (ladder, hatch, stair)
- Any visible interior leak evidence reported by the customer

**Roof surface — overview**
- Each roof slope or quadrant from elevated view (drone or ladder)
- Wide-angle shot showing the overall layout

**Penetrations**
- Every pipe, vent, drain, scupper, skylight, conduit, and HVAC curb
- Close-ups of any pipe boot, flashing, or sealant condition

**Details and flashings**
- Every parapet wall, termination bar, and coping
- Every valley
- Every transition where the roof meets a wall, dormer, chimney, or other structure

**Damage and conditions**
- Any condition rated Maintenance, Repair, or Urgent on the severity scale
- Reference scale included where size matters

**Drainage**
- Every drain and scupper
- Any ponding evidence (chalk outline preferred to mark extent)

**Substrate (where assessable)**
- Any visible substrate condition at edges, drains, lifted membrane, or worn areas
- Attic interior if accessible

### What NOT to photograph

- Identifiable house numbers, addresses, or tenant signage in marketing-bound photos (unless cleared with the customer)
- Personal property visible inside windows
- Other workers or trades on the roof without their consent
- Any condition photographed in a way that misrepresents (e.g., extreme close-up of a single granule that suggests a roof-wide problem)

### Photo organization

Photos must be organized after the inspection. Methods vary by tool, but the standards are universal:

- Each photo associated with the project / property
- Each photo labeled or tagged by location and condition
- Severity ratings applied where conditions are documented
- Photos available to the proposal-writer, manager, and (where appropriate) customer

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's photo storage system, naming conventions, and customer-sharing standards.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '5'
);

-- Part 2 / Ch 12 / Sec 6: Customer-Facing Documentation
UPDATE sections SET
  content_markdown = $mfst$The documentation customers see is part of the sales experience. Customers form judgments about USA Flat Roof's professionalism based on what they receive.

### What customers should typically receive

- **Inspection report** — written summary of findings, severity ratings, and recommendations
- **Photo package** — organized photos showing conditions documented in the report
- **Proposal** — scope of work, pricing, and warranty terms (separate document, separate timing)
- **Maintenance recommendations** *(where applicable)* — even if no immediate work is sold

### Inspection report standards

A defensible inspection report includes:

1. Property address and date of inspection
2. Inspector name and credentials
3. Roof system identification (with appropriate caveats — see Section 8)
4. Summary of inspection method (ground, ladder, drone, walk, or combination)
5. Conditions documented, with severity ratings
6. Photos referenced or attached
7. Recommended next steps
8. Any escalation notes
9. Signature or attribution

### What the report must NOT include

- Conclusions outside the rep's training (structural assessments, certified hail damage, mold or asbestos identification)
- Specific service-life predictions ("this roof has 7 years left")
- Warranty coverage promises ("this is covered under your warranty")
- Insurance outcome predictions ("your carrier will cover this")
- Disparaging comments about other contractors or prior work
- Pricing or proposal language (separate document)

### Honest framing in customer reports

The same severity scale used internally should appear in customer-facing reports. Customers can handle honest condition language when it's calibrated and consistent. Examples:

- "Monitor — visible condition, no immediate action required"
- "Maintenance Needed — small issues that should be addressed to prevent larger problems"
- "Repair Recommended — active or likely failure point"
- "Urgent / Escalate — leak risk, safety concern, or replacement candidate"

This language signals to the customer that the rep is using a consistent framework rather than making subjective judgments.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's standard inspection report template, branding, and approval process.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '6'
);

-- Part 2 / Ch 12 / Sec 7: Warranty-Required Documentation
UPDATE sections SET
  content_markdown = $mfst$Several roof systems and product lines require specific documentation for warranty coverage. Missing documentation can void warranties years later, when the customer needs them most.

### Common warranty documentation requirements

**For coatings (silicone, acrylic):**
- Pre-application photos showing substrate condition
- Application photos showing coverage and mil thickness verification
- Post-application photos
- Application date and weather conditions
- Application rate (gallons per square)
- Manufacturer warranty registration submission within the required window

**For SPF systems:**
- Pre-application substrate photos
- Foam application documentation (thickness, density)
- Topcoat application documentation
- Manufacturer warranty registration
- Topcoat recoat schedule and documentation at each recoat

**For rejuvenation (e.g., Fresh Roof):**
- Pre-application photos showing roof age and condition
- Shingle type identification
- Application date, weather conditions, product batch
- Manufacturer warranty registration

**For TPO and other single-ply replacement projects:**
- Substrate and deck condition documentation
- Insulation and cover board specifications
- Membrane installation photos
- Seam probe-test documentation
- Manufacturer system warranty registration (NDL or equivalent tier)

> **[CHECK MANUFACTURER]** Each manufacturer's warranty program has specific documentation requirements. Confirm against current product documentation before the project starts — not after.

### Why this matters for the rep

Reps may not be the ones submitting warranty registration paperwork — production teams or warranty coordinators often handle that. But reps need to know:

- What documentation will be required at the project stage
- Whether the inspection-stage documentation supports the eventual warranty registration
- When to flag the customer that warranty registration is part of the value of working with USA Flat Roof versus a contractor who skips that step

A rep who can explain, "We register this with the manufacturer so you have documented warranty coverage — many contractors skip that step and customers find out years later when they try to claim," is differentiating USA Flat Roof on a real and legitimate basis.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's warranty registration process, responsible parties, and documentation handoff between sales and production.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '7'
);

-- Part 2 / Ch 12 / Sec 8: Documentation Boundaries — What Reps Cannot Document
UPDATE sections SET
  content_markdown = $mfst$Reps document visible, observable conditions. Reps do not certify, diagnose, or guarantee.

### Reps may document
- Visible roof surface conditions
- Visible damage, wear, or aging
- Severity ratings using the four-point scale
- Photographs of observable conditions
- Customer-reported information (clearly attributed as such — "customer reported a leak in the back bedroom")
- Inspection method used and any limitations encountered

### Reps may NOT document
- Structural failure determinations
- Certified hail damage for insurance purposes (unless qualified and authorized)
- Code compliance certification
- Mold, asbestos, or hazardous-material identification
- Specific remaining-service-life predictions
- Warranty coverage determinations (only the warranty document itself defines coverage)
- Insurance claim outcomes

When reps encounter conditions outside their documentation scope, they document what they observed (e.g., "deck appears soft underfoot in two locations near the south parapet") and escalate the question of certification or diagnosis to a senior estimator, qualified inspector, or appropriate specialist.

> **[SALES REP BOUNDARY]** The pattern is: rep observes, rep documents the observation, qualified party certifies or diagnoses. Skipping the middle step or jumping to certification creates risk for the customer and for USA Flat Roof.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '8'
);

-- Part 2 / Ch 12 / Sec 9: Common Documentation Mistakes
UPDATE sections SET
  content_markdown = $mfst$Documentation mistakes come up regularly. Reps should learn to recognize and avoid them.

### Mistakes in inspection thoroughness
- Skipping a full roof inspection on a leak call (inspecting only the area above the staining)
- Skipping the attic check when accessible
- Skipping ground-level walk-around when going straight to ladder or drone
- Skipping documentation gathering from the customer (prior reports, warranty papers, repair history)

### Mistakes in photo capture
- Too few photos
- Photos without context (no overview shot to anchor the close-ups)
- Photos without reference scale on damage shots
- Photos taken with inadequate lighting or focus
- Photos that misrepresent conditions (extreme close-up suggesting roof-wide failure on an isolated issue)

### Mistakes in documentation language
- Using technical jargon the customer doesn't understand
- Using vague language ("looks bad," "rough shape")
- Using strong language without supporting evidence ("structurally compromised," "imminent failure")
- Quoting specific service-life numbers
- Promising warranty or insurance outcomes
- Disparaging prior contractor work

### Mistakes in customer communication
- Walking the customer through findings before completing the inspection (jumping to conclusions)
- Refusing to share findings until the proposal is ready
- Quoting prices verbally before written proposal
- Pressuring the customer to commit to work during the inspection visit$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '9'
);

-- Part 2 / Ch 12 / Sec 10: The Inspection-as-Sales-Asset Mindset
UPDATE sections SET
  content_markdown = $mfst$For new reps, inspection can feel like the unpaid front-end work before the "real" sales conversation. That mindset misses the point.

A thorough, honest, well-documented inspection is the strongest sales asset USA Flat Roof has. It differentiates the company from competitors who do five-minute walk-ups and verbal quotes. It builds trust in the recommendation that follows. It gives the customer something tangible — photos, severity ratings, a written report — that they can review on their own time.

When a rep takes inspection seriously, the sales conversation becomes much easier. The customer is reading a document that already shows the rep did the work, and the proposal flows naturally from documented findings. When a rep treats inspection as a chore, the sales conversation has to do all the persuasion work itself — and customers can usually tell.

The honest framing: **the inspection is the sales conversation.** The proposal is just the paperwork.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '10'
);

-- Part 2 / Ch 12 / Sec 11: Sales Conversation Guide for Inspection-Stage Conversations
UPDATE sections SET
  content_markdown = $mfst$### Opening the inspection

> "Thanks for having us out. I'm going to do a complete inspection — exterior walk-around, then the roof itself, and the attic if it's accessible. I'll take a lot of photos and document conditions on a four-point severity scale. After I'm done, I'll walk you through what I found, and then we'll talk about next steps. Anything specific you want me to focus on?"

### Mid-inspection check-in (when conditions warrant)

> "I want to flag a couple of things I'm seeing as I go. Nothing alarming yet, but I want you to know what I'm documenting before we have the full conversation at the end. [Specific findings.] I'll keep going through the rest of the roof and we'll talk through everything together."

### Closing the inspection

> "I've completed the inspection. Here's what I found, organized by severity. [Walk through findings using the four-point scale.] You'll have a written report and the photo package within [timeframe]. The proposal will follow separately based on what we agree the next steps should be. I won't quote you a number on the spot — I want to make sure the scope is right first."

### When the customer wants an immediate price

> "I understand, and I want to give you an accurate number rather than a guess. The price depends on the specific scope, and I want to put that on paper for you rather than a verbal estimate that changes when we do the actual write-up. You'll have the proposal within [timeframe]. Anything urgent that needs to happen sooner — like emergency repair — we can talk about separately."

### When the customer is suspicious of "too thorough" inspection

> "Fair question. The reason we document this thoroughly is that it protects you, not just us. If you ever have a warranty claim, an insurance claim, or a future contractor question what was here when, the photos and notes are how you answer those questions. It's also how we make sure the proposal we give you matches what's actually on your roof, not just what we'd guess from a five-minute look."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '11'
);

-- Part 2 / Ch 12 / Sec 12: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- An inspection finding requires certification outside the rep's authorization
- Suspected structural, mold, asbestos, or hazardous-material conditions
- Insurance claim involvement (storm or hail damage)
- Code or jurisdictional questions
- Solar array on the roof
- Building of significant size or complexity beyond rep's training
- A customer requests certification language (warranty, structural, code) the rep cannot provide
- An inspection cannot be completed safely or thoroughly by the rep alone
- Findings inconsistent with customer-provided documentation
- Drone use is required but conditions or authorization don't permit$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '12'
);

-- Part 2 / Ch 12 / Sec 13: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard inspection process and timing: [placeholder]
> - Our drone use policy, certified operators, and equipment: [placeholder]
> - Our photo standards and storage system: [placeholder]
> - Our inspection report template and branding: [placeholder]
> - Our maintenance program inspection cadence: [placeholder]
> - Our warranty registration responsibilities and handoff process: [placeholder]
> - Our customer-facing documentation standards: [placeholder]
> - Our escalation process for inspection findings: [placeholder]
> - Our authorization tiers for verbal pricing: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '13'
);

-- Part 2 / Ch 12 / Sec 14: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat inspection as a chore rather than the central sales asset.
- They take too few photos and miss documentation requirements.
- They don't conduct full inspections on leak calls.
- They walk roofs unsafely or skip drone options where drone would be appropriate.
- They quote prices verbally during inspection visits.
- They miss warranty registration documentation requirements.
- They use vague language in reports instead of the four-point severity scale.

**Discussion questions for group training**
- Walk through a real inspection from arrival to documentation completion. What gets skipped under time pressure? Why does it matter?
- A customer says "you're being too thorough — just give me a number." How do you handle it?
- A rep arrives at a 3-story commercial building with no safe ladder access and the customer hasn't authorized drone use. What's the next step?
- A long-term customer is upset that you "missed something" on a recent inspection. The photos show you actually did document it, but they didn't read the report. How does that conversation go?
- What's the 30-second answer to "why does documentation matter for warranty?"

**Field exercises**
- Pair up. Conduct a mock inspection of a property and produce the photo package and written report. Trade and review.
- Review three sets of inspection photos. Identify what's missing, what's well-documented, and what's misframed.
- Practice the customer conversation when the customer wants verbal pricing and the rep needs to defer to written proposal.
- Walk through warranty registration requirements for one specific product (silicone, SPF, or rejuvenation). Identify what the rep contributes and what production handles.

**What the manager should test verbally**
- The four inspection methods and when each is appropriate.
- The minimum photo requirements for any inspection.
- The four-point severity scale.
- What reps may document versus what requires escalation.
- Five common documentation mistakes.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '14'
);

-- Part 2 / Ch 12 / Sec 15: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Drone inspection** — roof inspection conducted with an unmanned aerial vehicle, valuable for safety and wide-area coverage but limited for hands-on assessment.
- **Inspection report** — written summary of findings, severity ratings, and recommendations.
- **Ladder-edge inspection** — inspection conducted from the top of a ladder at the roof's edge.
- **NDL warranty (No Dollar Limit)** — full-system manufacturer warranty without per-claim cap, requires specific documentation.
- **Photo package** — organized collection of inspection photos provided to the customer or used internally.
- **Reference scale** — object included in a photo to indicate size (business card, tape measure, chalk mark).
- **Roof walk** — hands-on inspection conducted by walking the roof surface, requires safety qualification.
- **Severity scale** — the four-point rating system (Monitor, Maintenance Needed, Repair Recommended, Urgent / Escalate).
- **Warranty registration** — formal submission of project documentation to a manufacturer to activate warranty coverage.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '15'
);

-- Part 2 / Ch 12 / Sec 16: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$A roof inspection serves three audiences: the customer, the company, and the warranty system. Strong inspection and documentation protect all three; weak inspection creates risk for everyone. Reps should use the appropriate combination of inspection methods — ground-level, ladder-edge, drone, and roof walk — based on safety and the inspection scope needed. Photos are the most important inspection deliverable: clear, contextual, with reference scale where applicable, and organized for retrieval. Customer-facing documentation should use the four-point severity scale consistently and avoid certifications outside the rep's role. Warranty-required documentation has specific requirements that vary by product; missing it can void coverage years later. Reps document visible conditions and escalate certification or diagnostic questions to qualified parties. The inspection is not the unpaid front-end before the sales conversation — it *is* the sales conversation. A thorough, honest inspection is USA Flat Roof's strongest sales asset.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '16'
);

-- Part 2 / Ch 12 / Sec 17: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The three audiences for inspection documentation are:
A. Customer, company, and warranty system
B. Sales, production, and accounting
C. Customer, insurance company, and the IRS
D. The rep, the customer, and the homeowner association

**2. (Beginner)** When a customer reports an interior leak, the inspection should:
A. Focus only on the area above the visible damage
B. Include a full roof inspection, not just the leak area
C. Skip the inspection and quote a patch
D. Wait for the customer to identify the source first

**3. (Beginner)** Drone inspection is most valuable for:
A. Replacing all hands-on inspection
B. Multi-story buildings, tile roofs, and complex geometries where walking is risky
C. Small single-family residential only
D. Inspecting attics

**4. (Beginner)** A reference scale in a damage photo is:
A. Optional decoration
B. An object included to indicate size — like a business card, tape measure, or chalk mark
C. Required only on commercial roofs
D. A scale model of the building

**5. (Intermediate)** The four-point severity scale used by USA Flat Roof includes:
A. Good / Fair / Poor / Failed
B. Monitor / Maintenance Needed / Repair Recommended / Urgent or Escalate
C. Pass / Fail / Conditional / Re-inspect
D. Green / Yellow / Red / Black

**6. (Intermediate)** A customer asks for a verbal price during the inspection. The most appropriate response is:
A. Quote the price on the spot to close the deal
B. Decline to inspect further until pricing is settled
C. Defer to the written proposal so the scope and price match what's actually on the roof
D. Quote a high price to anchor the negotiation

**7. (Intermediate)** Which of the following may a sales rep NOT document or certify in an inspection report?
A. Visible roof surface conditions
B. Customer-reported information (clearly attributed)
C. Severity ratings using the four-point scale
D. Structural failure, hail damage for insurance, or mold identification

**8. (Intermediate)** Warranty registration documentation typically must be submitted:
A. Within a manufacturer-required window after the work
B. Whenever the customer remembers
C. Only if the customer requests it
D. After a leak occurs

**9. (Advanced)** A rep arrives at a steep-slope tile roof on a windy day. The customer wants a thorough inspection. The most appropriate approach is:
A. Walk the roof carefully despite conditions
B. Skip the inspection entirely
C. Use a combination of ground-level walk-around, drone (if conditions permit), and ladder-edge — and reschedule the roof walk if conditions don't support it
D. Tell the customer their roof is fine

**10. (Advanced)** A customer says "you're documenting too much — I just want a price." The most honest response is:
A. Skip the documentation and provide a verbal price
B. Explain that the documentation protects them in the future for warranty, insurance, and resale, and that the price will be accurate because the scope is real
C. Apologize and reduce the inspection scope
D. Bill the customer for the documentation time

---

### Answer Key

1. **A — Customer, company, and warranty system.** The three audiences for documentation. (B), (C), and (D) miss the point.
2. **B — Include a full roof inspection, not just the leak area.** This is the leak-source rule from Chapter 11 applied here. (A) is the most common mistake; (C) and (D) abandon the customer.
3. **B — Multi-story buildings, tile roofs, and complex geometries where walking is risky.** Drone supplements but does not replace hands-on inspection (A).
4. **B — An object included to indicate size.** Standard photo standard.
5. **B — Monitor / Maintenance Needed / Repair Recommended / Urgent or Escalate.** The standard scale used throughout this book.
6. **C — Defer to the written proposal so the scope and price match.** This is the honest framework. Quoting on the spot (A) creates inaccurate pricing. Refusing to inspect (B) abandons the customer. High anchor (D) is dishonest.
7. **D — Structural failure, hail damage for insurance, or mold identification.** These exceed rep authorization. (A), (B), and (C) are within scope.
8. **A — Within a manufacturer-required window after the work.** Standard warranty registration practice. (B), (C), and (D) miss the requirement.
9. **C — Use a combination of methods and reschedule the roof walk if conditions don't support it.** This is safe and thorough. Walking despite conditions (A) violates safety; skipping entirely (B) abandons the customer; declaring "fine" (D) without inspection is dishonest.
10. **B — Explain that documentation protects them and pricing will be accurate.** This is the honest framing from Section 11. Skipping documentation (A) creates risk. Apologizing and reducing scope (C) abandons the standard. Billing for documentation (D) misframes the relationship.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '17'
);

-- Part 2 / Ch 12 / Sec 18: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual inspection process?
- [ ] Matches USA Flat Roof's drone use policy and certified operators?
- [ ] Matches USA Flat Roof's photo standards and storage system?
- [ ] Matches USA Flat Roof's inspection report template and customer documentation standards?
- [ ] Matches USA Flat Roof's warranty registration responsibilities and handoff process?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 1–11 (inspection guides in each system chapter)?

**Technical Items to Verify Before Publishing**

- Drone policy: confirm USA Flat Roof's certified operators, equipment, FAA registration, and integration with inspection workflow.
- Photo storage: confirm the system reps use, naming conventions, and customer-sharing standards.
- Inspection report template: confirm USA Flat Roof's standard template and approval process.
- Warranty registration process: confirm responsible parties, timing, and documentation handoff between sales and production for each product line.
- Authorization tiers for verbal pricing: confirm which reps can quote verbally in which contexts.
- Cross-references to Chapters 1–11: verify inspection language is consistent across chapters.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 12 AND s.section_number = '18'
);

-- Part 2 / Ch 13 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Apply a consistent decision framework across all roof systems USA Flat Roof works on.
2. Use four decision lenses — condition, customer fit, budget, and honest-versus-easy — to arrive at the right recommendation.
3. Recognize the three or four scenarios that come up most often and handle them with consistent language.
4. Avoid the recurring failure patterns where reps recommend the wrong scope for the wrong reasons.
5. Communicate the recommendation honestly even when the right answer is the harder sell.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '1'
);

-- Part 2 / Ch 13 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$Every system chapter (1–10) ends with a Good/Better/Best framework specific to that system. This chapter steps back and gives reps a consistent way to *get to* that framework regardless of which system is on the roof.

The decision is rarely about the roof alone. It's about the roof plus the customer plus the budget plus the rep's willingness to give the honest answer when the easy answer is more profitable. A rep who only thinks about the first variable will get the recommendation wrong — sometimes by overselling, sometimes by underselling, both equally damaging.

This chapter gives reps four lenses to apply in order:

1. **Condition** — what does the roof actually need?
2. **Customer fit** — what does the customer actually want, and is it realistic?
3. **Budget** — what can the customer actually do, and how should that shape the conversation?
4. **Honest-versus-easy** — when the right answer is the harder sell, do you have the discipline to recommend it anyway?

All four matter. Skipping any one of them produces bad recommendations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '2'
);

-- Part 2 / Ch 13 / Sec 3: The Three Scopes — Plain Language Definitions
UPDATE sections SET
  content_markdown = $mfst$Reps need consistent definitions across systems.

**Repair** — addressing a specific failure or damage on a roof that otherwise has remaining service life. Examples: replacing a failed pipe boot, patching a punctured TPO membrane, replacing a broken tile. Scope is targeted; the rest of the roof continues to perform.

**Restoration** — adding a layer of waterproofing, performance, or service life to a roof that has aged but still has a sound substrate. Examples: silicone coating on TPO or BUR, rejuvenation on composition shingle, topcoat recoat on SPF. Scope covers the full roof field; substrate is preserved; service life is extended.

**Replacement** — removing the existing roof and installing a new one. Sometimes a full tear-off down to deck; sometimes a recover (overlay) where the existing system stays in place under a new system. Examples: TPO overlay over BUR, full tear-off and replacement with TPO, new SPF over a prepared substrate.

**Recover (overlay)** is technically a form of replacement, but customers often think of it as a separate option. Reps should be ready to explain it as "a new roof system installed over the existing one, where code permits and the substrate qualifies."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '3'
);

-- Part 2 / Ch 13 / Sec 4: Lens One — Condition
UPDATE sections SET
  content_markdown = $mfst$Condition is where every recommendation conversation starts. The four-point severity scale from earlier chapters applies:

- **Monitor** — visible condition, no immediate action required
- **Maintenance Needed** — small issues to address before they become larger
- **Repair Recommended** — active or likely failure point
- **Urgent / Escalate** — leak risk, safety concern, widespread failure, or replacement candidate

A roof's overall condition usually clusters around one of these levels with some items in others. The cluster point drives the conversation:

### If the cluster is Monitor or Maintenance
- Repair (if applicable to specific items) or Maintenance program
- Restoration is usually premature
- Replacement is rarely appropriate

### If the cluster is Repair Recommended
- Targeted repair of failed items
- Restoration may be appropriate if the system is in mid-life and qualifies
- Replacement is only appropriate if a pattern of repairs suggests end-of-life

### If the cluster is Urgent / Escalate
- Immediate repair to address active failures
- Restoration is rarely appropriate (the roof is past the qualifying window)
- Replacement is usually the right answer
- Escalation is required for any condition the rep cannot certify

### Disqualifying conditions for restoration

Restoration is the option most often misrecommended. The disqualifiers across all systems are consistent:

- **Wet insulation** — soft / spongy underfoot
- **Severe structural ponding** — water that doesn't drain regardless of mass added on top
- **Widespread substrate failure** — seams, ply separation, deck deflection
- **Suspected asbestos requiring abatement** (older systems)
- **Multiple roof layers** (limits recover scope)
- **Code restrictions on recover** (Title 24, jurisdictional)
- **Roof age outside the qualifying window** for the specific restoration product

If any of these conditions are present, restoration is off the table regardless of what the customer wants. This is the firmest line in the framework.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '4'
);

-- Part 2 / Ch 13 / Sec 5: Lens Two — Customer Fit
UPDATE sections SET
  content_markdown = $mfst$Customer fit asks: what does the customer actually want, and does that match what the roof needs?

Customers come to inspections with goals, expectations, and constraints. Some are explicit; some are implicit. The rep's job is to uncover them and check them against what the roof condition actually supports.

### Common customer goal patterns

**The "extend life" customer**
- Wants to defer replacement
- Values cost-effectiveness
- Often a strong fit for restoration *if* the roof qualifies
- Strong fit for maintenance programs

**The "long-term plan" customer**
- Owns the building for the long haul
- Wants the longest-life option within reason
- Often a fit for replacement, especially when the roof is past its qualifying window
- Values warranty terms and documentation

**The "preparing for sale" customer**
- Wants the roof not to be a barrier in the sale
- May not value long-term performance much
- Often a fit for repair plus documentation
- Beware: the temptation to oversell here is strong

**The "minimum viable solution" customer**
- Wants the cheapest option that meets basic needs
- May be budget-constrained or property-investor-driven
- Often a fit for targeted repair
- Beware: the pressure to undersell needed work to "match the budget" is also strong

**The "emergency" customer**
- Has an active leak or visible damage
- Needs immediate action
- Right scope depends entirely on what the inspection finds
- Beware: emergency framing makes customers susceptible to upsold scope

### The match check

For each customer, the rep asks: does the customer's goal match what the roof actually needs?

- **Match** → present the recommendation that fits both
- **Customer wants more than the roof needs** → walk back honestly (e.g., "you don't need replacement — repair is the right call")
- **Customer wants less than the roof needs** → present the honest recommendation and let them decide (the harder version of this conversation lives in Lens Four)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '5'
);

-- Part 2 / Ch 13 / Sec 6: Lens Three — Budget
UPDATE sections SET
  content_markdown = $mfst$Budget is the lens reps most often handle badly. The two failure patterns:

- **Reps assume budget without asking.** They present only the option they think the customer can afford, sometimes hiding the better option.
- **Reps avoid budget entirely.** They quote the most expensive option and let the customer figure out whether it's possible, sometimes losing the work entirely.

The right approach: ask honestly, present options that span the realistic range, and let the customer choose.

### Asking about budget honestly

> "Before I put together a proposal, can I ask what kind of investment range you're thinking about? This isn't to back-fit the scope to the budget — it's to make sure I include options that match what you can actually do, alongside any options that might be a stretch but worth considering."

This question accomplishes three things:
1. Signals the rep is taking the customer's reality seriously
2. Allows the rep to include options across the range
3. Surfaces budget gaps early instead of after a rejected proposal

### Common budget conversations

**"I haven't really thought about what it should cost."**
- Educate without pressure. Provide industry-typical ranges for the work being considered. Make clear the actual number depends on inspection findings.

**"I have $X budgeted."**
- Build the proposal to include options at that range and any meaningful step up or down.
- If $X cannot cover the right scope, say so directly: "Honestly, $X isn't realistic for the work this roof needs. Here's what I think would actually solve the problem, and here's what $X gets you instead so you can compare."

**"Money is no object — give me the best."**
- Resist the temptation to upsell. Recommend what the roof actually needs, not the most expensive option.

**"I just want the cheapest thing that works."**
- Honest in its directness. Present the cheapest option that *actually* works — not a cheaper option that doesn't.
- Be willing to say "the cheapest option that works isn't as cheap as you're hoping for" when that's true.

### When budget and condition genuinely don't match

Sometimes a customer's budget cannot support what the roof needs. The rep has three honest options:

1. **Phased work** — propose immediate emergency repair within budget, document the broader picture, and offer a longer-term plan
2. **Honest decline of the project** — "what your roof needs costs more than this. We're not the right fit for the budget you have. I'd rather tell you that than sell you something that won't perform"
3. **Refer** — when another contractor or scope might genuinely fit better

What reps must NOT do: cut corners on a real scope to "match the budget," or recommend a less-appropriate scope (restoration when replacement is needed, repair when broader work is needed) because the budget is tight.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's position on phased work, project decline, and minimum project sizes.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '6'
);

-- Part 2 / Ch 13 / Sec 7: Lens Four — Honest-Versus-Easy
UPDATE sections SET
  content_markdown = $mfst$Every roof system chapter has its honest-versus-easy moment. They're worth pulling together here so reps can recognize the pattern across systems.

### The pattern

In each scenario, the rep faces a choice between:

- **The easy recommendation** — what the customer prefers to hear, what's easier to close, what's higher margin in the short term
- **The honest recommendation** — what the roof actually needs, sometimes the harder sell, sometimes lower margin in the short term, always the right long-term call for trust and reputation

### Common honest-versus-easy moments

**Roof at end of life, customer wants a quick patch**
- Easy: do the patch, take the small revenue, leave
- Honest: do the patch, then have the longer conversation about what's actually happening with the roof

**Substrate doesn't qualify for restoration, customer wants restoration**
- Easy: propose restoration anyway, take the close, let the warranty process deal with the consequences in 18 months
- Honest: decline to propose restoration, explain why, recommend replacement

**Young roof in good condition, customer wants replacement**
- Easy: write the replacement proposal, take the high-margin work
- Honest: explain that the roof has significant remaining life, recommend repair or maintenance instead, decline to write a replacement proposal that the roof doesn't need

**Repeat customer with a non-qualifying roof asks for the same restoration that worked on a previous building**
- Easy: do what they asked
- Honest: explain why this roof doesn't qualify, lose the close, keep the long-term trust

**Single-layer BUR with sound substrate, customer wants full replacement because their cousin's contractor said so**
- Easy: write the replacement proposal
- Honest: explain that restoration or recover would extend life cost-effectively, give the customer the full picture, let them choose

**Inspection reveals broader issues than the customer's reported leak**
- Easy: address only the reported leak, take the smaller scope
- Honest: address the leak *and* document the broader conditions, let the customer decide on the broader scope

### The cost of the easy answer

The easy answer often closes the deal in the moment but creates one of three problems later:

1. **Failed work** — restoration over a non-qualifying substrate, replacement on a roof that didn't need it, repair that didn't address the actual issue
2. **Lost trust** — customer realizes years later that the rep didn't tell them the full picture
3. **Lost referrals** — the customer doesn't recommend USA Flat Roof to peers because the work didn't perform as represented

The honest answer sometimes loses the close in the moment but builds three things over time:

1. **Trust** — customers come back and refer others because they remember being told the truth
2. **Reputation** — USA Flat Roof becomes known as the contractor who tells customers when they don't need work
3. **Long-term revenue** — repeat customers and referrals compound over years

### What to do when the customer is unhappy with the honest answer

Some customers don't want to hear it. They came in with a preferred outcome and the rep just told them something different. The rep's options:

- **Accept the customer's decision and walk away** — sometimes the customer chooses a contractor who'll give them the easy answer; that's their right
- **Offer a documented alternative** — "what your roof actually needs is X. If you want a smaller scope today, I can do Y, and I'll document why that's not a complete solution. You'll have the full picture for whenever you're ready."
- **Refer** — sometimes another contractor's scope or specialty is genuinely a better fit

What the rep should NOT do: capitulate and write the easy proposal because the customer pushed back. The honest answer doesn't change just because the customer doesn't like it.

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's position on declining work that requires recommendations the rep believes are wrong.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '7'
);

-- Part 2 / Ch 13 / Sec 8: The Decision Tree
UPDATE sections SET
  content_markdown = $mfst$The four lenses applied in order produce a decision tree. This is the master version; system-specific chapters have their own.

### Step 1: Condition assessment
- Apply the four-point severity scale to the roof
- Check for any disqualifying conditions for restoration

### Step 2: Initial scope cluster
- **Monitor / Maintenance dominant** → Maintenance program or targeted repair
- **Repair dominant, no end-of-life signals** → Targeted repair
- **Repair dominant, mid-life with sound substrate** → Repair *or* Restoration
- **Urgent / widespread failure** → Replacement
- **Disqualifiers present** → Replacement (regardless of customer preference)

### Step 3: Customer fit check
- Customer goal matches scope from Step 2 → proceed
- Customer wants more than scope supports → walk back honestly
- Customer wants less than scope supports → flag for Lens Four

### Step 4: Budget reality check
- Budget supports the scope → proceed with proposal
- Budget below scope → consider phased work, honest decline, or referral
- Budget exceeds scope → don't upsell beyond what's needed

### Step 5: Honest-versus-easy check
- Easy and honest answers match → proceed
- Easy answer differs from honest → recommend the honest one anyway
- Customer pushes back → use the conversation patterns from Section 7

### Step 6: Documentation
- Document the recommendation
- Document any customer preference that diverged from the rep's recommendation
- Document any escalation
- Document the proposal with clear scope, pricing, and warranty terms$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '8'
);

-- Part 2 / Ch 13 / Sec 9: Common Decision Errors
UPDATE sections SET
  content_markdown = $mfst$Reps regularly fall into specific patterns of recommendation error. Recognizing them is the first step to avoiding them.

### Error 1: Skipping condition assessment to chase customer preference

The customer says "I want restoration." The rep writes a restoration proposal without confirming the substrate qualifies. **The condition lens has to come first, always.**

### Error 2: Recommending replacement on a roof with significant remaining life

Margin-driven, not condition-driven. The rep writes a replacement proposal because it's a bigger sale, not because the roof needs it. **Condition lens has to gate scope.**

### Error 3: Recommending repair on an end-of-life roof

The opposite mistake. The customer wants a small fix, the rep agrees, and nobody mentions the bigger picture. **Repair-plus-plan is the honest pattern when conditions warrant it.**

### Error 4: Avoiding budget conversation

The rep doesn't ask about budget, presents only one option, and loses the deal because the option doesn't fit. Or the rep presents the most expensive option and watches the customer freeze. **Budget asked honestly produces better recommendations.**

### Error 5: Capitulating on the honest answer

The rep gave the right recommendation, the customer pushed back, and the rep wrote a different proposal to keep the deal. **The honest answer doesn't change because of pressure.**

### Error 6: Confusing "what the customer wants" with "what's right for the customer"

Sometimes they're the same. Often they aren't. The rep's job is to understand both and serve the second.

### Error 7: Treating the decision as a one-time transaction

Every decision the rep makes is a deposit or withdrawal in the long-term relationship account. The rep who treats each visit as a one-time sale will lose to the rep who treats each visit as the start of a 10-year relationship.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '9'
);

-- Part 2 / Ch 13 / Sec 10: Cross-System Quick-Reference
UPDATE sections SET
  content_markdown = $mfst$Across the systems USA Flat Roof works on, the recommendation patterns cluster as follows:

### Composition Shingle (Chapter 1)
- **Repair:** localized failures on roofs with remaining life
- **Restoration:** Fresh Roof rejuvenation when roof is in mid-life qualifying window
- **Replacement:** end-of-life roofs, widespread failure, severe granule loss, multiple layers

### TPO (Chapter 2)
- **Repair:** localized failures on roofs with remaining life
- **Restoration:** silicone coating on qualifying substrates
- **Replacement:** end-of-life systems, widespread seam failure, wet insulation

### Silicone Coatings (Chapter 3)
- **Maintenance recoat:** existing silicone with thinning topcoat
- **Repair:** localized coating damage
- **Replacement:** failed coating systems where substrate now requires full replacement

### Roof Rejuvenation (Chapter 4)
- **Application:** qualifying shingle roofs in the mid-life window
- **Decline:** roofs outside the qualifying window (too new or too old)

### PVC (Chapter 5)
- **Repair:** localized failures
- **Restoration:** silicone coating where compatibility verified
- **Replacement:** end-of-life systems with plasticizer migration and widespread cracking

### Modified Bitumen (Chapter 6)
- **Repair:** localized failures
- **Restoration:** silicone coating on qualifying substrates
- **Replacement:** end-of-life systems

### Acrylic Coatings (Chapter 7)
- **Reference:** USA Flat Roof leads with silicone; acrylic recognized but not typically proposed

### Concrete Tile (Chapter 8)
- **Repair and maintenance:** within USA Flat Roof scope
- **Underlayment replacement:** referred out to tile specialty contractors

### BUR (Chapter 9)
- **Restoration (silicone):** Good — qualifying single-layer BUR
- **TPO overlay:** Better — single-layer BUR with sound substrate
- **Replacement:** Best — end-of-life, multi-layer, asbestos, or wet insulation
- **SPF:** when ponding correction or insulation upgrade drives the decision

### SPF (Chapter 10)
- **Topcoat recoat:** standard maintenance pattern
- **Repair:** localized topcoat or foam damage
- **New SPF application:** for ponding correction, BUR recover, or insulation upgrade
- **Replacement:** rare on properly maintained SPF; typically traces to deferred topcoat maintenance$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '10'
);

-- Part 2 / Ch 13 / Sec 11: Sales Conversation Guide for Decision Conversations
UPDATE sections SET
  content_markdown = $mfst$### Opening the conversation

> "Based on what we found in the inspection, here's how I'd think about your options. There are usually three categories worth considering: repair, restoration, or replacement. Not every category is the right answer for every roof — let me walk you through which ones make sense for yours and why."

### When repair is clearly right

> "Your roof has remaining service life and the issue is localized. The honest answer here is repair, not replacement. We address [specific items], document the work, and you stay on top of maintenance. Replacement on this roof would be wrong — both for your wallet and for any contractor who recommended it."

### When restoration is clearly right

> "Your roof qualifies for restoration. That means the substrate is sound, the details are addressable, and a coating extends service life cost-effectively. It's not a replacement and it's not a magic fix — but for a roof in this condition, it's the option that gets you the most life for the lowest cost."

### When replacement is clearly right

> "Your roof is at the end of its useful life. I want to be straight with you — repair is short-term spending at this point, and restoration over the conditions we found wouldn't perform. Replacement is the right answer. I know it's the biggest number on the page; I'd rather tell you that now than sell you something that won't last."

### When the customer wants something different from the recommendation

> "I hear what you're asking for, and I want to give you the honest answer. Based on what we found, [recommendation] is the call I'd make. [Customer's preferred option] would [explain the gap — wouldn't perform, isn't necessary, doesn't address the actual issue]. I can put both options on paper if you want to compare side by side. The decision is yours; I just want you working from accurate information."

### When budget is the constraint

> "Tell me what range you're thinking. I'd rather build the proposal around what you can actually do — including options that stretch the budget if they're worth considering — than guess and miss. Honesty here saves us both time."

### When you're declining to write a proposal

> "I'm not going to write the proposal for [scope] because I don't believe it'll perform on this roof. I know that's not the answer you were hoping for. What I can do is [alternative], or I can give you a name for a contractor who specializes in [what the customer wants]. I'd rather lose the work than sell you something I don't believe in."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '11'
);

-- Part 2 / Ch 13 / Sec 12: Red Flags and Escalation
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Customer requests a scope the rep believes is wrong
- Disqualifying conditions for restoration require certification the rep cannot provide
- Insurance claim involvement
- Suspected structural, mold, asbestos, or hazardous-material conditions
- Multi-stakeholder decisions (HOA, multi-tenant commercial, multi-owner properties)
- Code or jurisdictional questions
- Solar array on the roof
- Pricing or scope dispute that cannot be resolved at the rep level
- Customer pressure to capitulate on a recommendation
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '12'
);

-- Part 2 / Ch 13 / Sec 13: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard recommendation framework across systems: [placeholder]
> - Our position on declining work that requires wrong recommendations: [placeholder]
> - Our minimum project sizes and scope thresholds: [placeholder]
> - Our position on phased work and partial-scope projects: [placeholder]
> - Our authorization tiers for proposing alternatives: [placeholder]
> - Our handoff process when escalating decisions: [placeholder]
> - Our standard language for recommendation conversations: [placeholder]
> - Our documentation standards for recommendations and customer-preferred alternatives: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '13'
);

-- Part 2 / Ch 13 / Sec 14: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They lead with what the customer wants instead of what the roof needs.
- They skip budget conversations and either oversell or undersell.
- They capitulate when customers push back on the honest answer.
- They confuse "the easy answer" with "the customer-friendly answer" — sometimes the honest harder answer is the most customer-friendly thing the rep can do.
- They don't realize how much the long-term relationship account matters.
- They treat each visit as a transaction rather than a deposit in trust.

**Discussion questions for group training**
- Walk through the four lenses on a real or constructed scenario. Where does each lens change the recommendation?
- A repeat customer wants restoration on a non-qualifying roof. What's the script?
- A customer says "money is no object" and wants the most expensive option. What's the right move?
- A customer's budget genuinely doesn't match what the roof needs. What are the three honest paths forward?
- What's the 30-second answer to "why would you ever decline to write a proposal?"

**Field exercises**
- Pair up. Take three real or constructed inspection scenarios. Walk through each lens out loud. See where the lenses lead.
- Practice the budget conversation in role-play. Trade roles between rep and customer.
- Practice the "I'm not going to write that proposal" conversation. Trade roles.
- Review three real or constructed proposals. Identify which lens the rep skipped.

**What the manager should test verbally**
- The four lenses and what each one asks.
- The disqualifying conditions for restoration across systems.
- Three honest-versus-easy moments and how to handle each.
- Five common decision errors.
- The repair-plus-plan conversation.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '14'
);

-- Part 2 / Ch 13 / Sec 15: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Condition lens** — the first decision lens; assesses what the roof actually needs.
- **Customer fit lens** — the second decision lens; assesses what the customer wants and whether it matches what the roof needs.
- **Budget lens** — the third decision lens; assesses what the customer can do and shapes options accordingly.
- **Honest-versus-easy lens** — the fourth decision lens; the discipline to recommend the harder right answer.
- **Disqualifying conditions** — conditions that take restoration off the table regardless of customer preference.
- **Phased work** — addressing immediate needs within budget while documenting and planning for the broader scope.
- **Recover (overlay)** — installation of a new system over an existing roof; technically a form of replacement.
- **Repair-plus-plan** — repair work combined with honest disclosure of broader system conditions.
- **Restoration** — adding waterproofing, performance, or service life to a roof with sound substrate.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '15'
);

-- Part 2 / Ch 13 / Sec 16: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$The decision between repair, restoration, and replacement is not about the roof alone. It's about the roof plus the customer plus the budget plus the rep's discipline to give the honest answer. Four lenses applied in order produce reliable recommendations: condition first (what does the roof need?), customer fit second (does the customer's goal match?), budget third (can it actually happen, and how?), and honest-versus-easy fourth (when the right answer is the harder sell, do you have the discipline to recommend it anyway?). Reps fail most often by skipping condition assessment, avoiding budget conversation, recommending replacement on roofs with remaining life, recommending repair on end-of-life roofs, or capitulating when customers push back on the honest answer. Across systems, the recommendation patterns cluster predictably — repair for localized failures on sound systems, restoration for aged but qualifying substrates, replacement for end-of-life roofs or those with disqualifying conditions. The decisions reps make on every visit are deposits or withdrawals in the long-term trust account; the rep who treats each visit as the start of a 10-year relationship will outperform the rep who treats it as a one-time transaction.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '16'
);

-- Part 2 / Ch 13 / Sec 17: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The four decision lenses, in order, are:
A. Cost, customer, condition, closing
B. Condition, customer fit, budget, honest-versus-easy
C. Budget, condition, paperwork, warranty
D. Customer, condition, customer, condition

**2. (Beginner)** "Repair" is best described as:
A. Adding a continuous waterproof layer to an aged roof
B. Removing the existing roof and installing a new one
C. Addressing a specific failure on a roof that otherwise has remaining service life
D. Annual maintenance work

**3. (Beginner)** "Restoration" is best described as:
A. Targeted patching of a single failure
B. Adding waterproofing, performance, or service life to an aged but sound substrate
C. Tearing off the existing roof and starting over
D. The same as roof painting

**4. (Beginner)** Which of the following is a disqualifying condition for restoration across most systems?
A. Light surface dirt
B. Wet insulation, severe ponding, or widespread substrate failure
C. A single failed pipe boot
D. Biological staining on the north slope

**5. (Intermediate)** A customer with a 6-year-old roof in good condition asks for replacement. The most appropriate response is:
A. Write the replacement proposal — the customer asked for it
B. Explain that the roof has significant remaining life and recommend repair or maintenance instead
C. Recommend silicone restoration as a compromise
D. Refer the customer elsewhere

**6. (Intermediate)** A customer's budget is below what the roof actually needs. The most honest options include:
A. Cutting the scope to fit the budget regardless of performance
B. Phased work, honest decline of the project, or referral
C. Pretending the budget will work and writing the proposal anyway
D. Refusing to engage further

**7. (Intermediate)** A repeat customer asks for restoration on a roof the rep believes does not qualify. The most appropriate response is:
A. Provide the proposal because they're a repeat customer
B. Provide the proposal but with a higher-tier product
C. Decline to propose restoration, explain why, and recommend an honest alternative
D. Refer them to a different contractor without explanation

**8. (Intermediate)** A customer reports an active leak on a 22-year-old roof. Inspection reveals widespread end-of-life conditions in addition to the leak. The most honest recommendation is:
A. Patch the leak and say nothing about broader conditions
B. Insist on replacement before doing any repair
C. Address the leak (if appropriate as a short-term fix), document broader conditions, and present replacement options
D. Decline the work

**9. (Advanced)** A customer pushes back hard on the rep's honest recommendation and demands a cheaper alternative the rep believes won't perform. The most appropriate response is:
A. Capitulate and write the cheaper proposal to keep the deal
B. Maintain the honest recommendation, offer a documented alternative if appropriate, and accept that the customer may choose a different contractor
C. Lower the price on the original recommendation to match the cheaper option
D. Insist the customer accept the original recommendation

**10. (Advanced)** A customer says "money is no object — give me the most expensive option." The most appropriate response is:
A. Sell the most expensive option since the customer requested it
B. Recommend what the roof actually needs, not the most expensive option
C. Add unnecessary scope to justify a higher price
D. Refer the customer elsewhere

---

### Answer Key

1. **B — Condition, customer fit, budget, honest-versus-easy.** The four lenses in order from this chapter.
2. **C — Addressing a specific failure on a roof that otherwise has remaining service life.** Standard definition.
3. **B — Adding waterproofing, performance, or service life to an aged but sound substrate.** Standard definition.
4. **B — Wet insulation, severe ponding, or widespread substrate failure.** These are the cross-system disqualifiers.
5. **B — Explain that the roof has significant remaining life and recommend repair or maintenance instead.** This is the honest answer when the customer wants more than the roof needs.
6. **B — Phased work, honest decline, or referral.** These are the three honest paths in Section 6. Cutting scope to fit budget (A, C) creates failed work; refusing to engage (D) abandons the customer.
7. **C — Decline restoration, explain why, recommend an honest alternative.** This is the honest-versus-easy moment from Section 7. Repeat-customer pressure (A) is the textbook ethics failure. Higher-tier product (B) doesn't change the disqualifying conditions. Referral without explanation (D) abandons the relationship.
8. **C — Address the leak, document broader conditions, and present replacement options.** This is the repair-plus-plan pattern. Patching without disclosure (A) is dishonest. Insisting on replacement first (B) is heavy-handed. Declining (D) abandons the customer.
9. **B — Maintain the recommendation, offer documented alternative, accept possible loss of the deal.** This is the honest-versus-easy discipline from Section 7. Capitulating (A) is the textbook failure. Discounting the original recommendation (C) doesn't change the underlying issue. Insisting (D) is heavy-handed.
10. **B — Recommend what the roof actually needs.** Selling the most expensive option just because budget allows (A, C) is the upselling failure. Referring elsewhere (D) abandons the customer for no reason.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '17'
);

-- Part 2 / Ch 13 / Sec 18: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual recommendation framework?
- [ ] Matches USA Flat Roof's position on declining work that requires wrong recommendations?
- [ ] Are the four lenses aligned with how managers want reps to think?
- [ ] Are the cross-system patterns in Section 10 accurate?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 1–10 (system chapters) and Chapter 11 (Maintenance and Repairs)?

**Technical Items to Verify Before Publishing**

- Disqualifying conditions list: confirm against each system chapter's specific disqualifiers.
- Budget conversation language: confirm against USA Flat Roof's standard sales practice.
- Decline-the-project policy: confirm USA Flat Roof's actual position on declining work the rep believes is wrong.
- Phased work standard: confirm USA Flat Roof's offerings for phased projects.
- Cross-references to Chapters 1–11: verify recommendation language is consistent across chapters.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 13 AND s.section_number = '18'
);

-- Part 2 / Ch 14 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain in plain language why ventilation and condensation matter to roof performance.
2. Identify the main ventilation components on a steep-slope residential roof.
3. Recognize when a flat or low-slope commercial roof has vapor or condensation concerns and what changes the conversation.
4. Identify ventilation-related signs during inspection and document them appropriately.
5. Recognize when ventilation issues exceed the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '1'
);

-- Part 2 / Ch 14 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$Ventilation rarely shows up as the customer's reason for calling. Customers call about leaks, aging shingles, energy bills, and visible damage. Ventilation matters because it's often the *underlying reason* the visible problem developed in the first place — and because skipping the ventilation conversation during a re-roof or restoration project sets up the new system to fail early.

Two patterns reps need to recognize:

- **On steep-slope residential roofs (composition shingle, tile):** poor attic ventilation accelerates shingle aging, creates moisture problems in the attic, and can void manufacturer warranties. A re-roof project that doesn't address ventilation may install a beautiful new roof that ages prematurely.
- **On flat-roof commercial buildings:** ventilation works differently. Most commercial flat roofs don't have an attic to ventilate. Instead, the concern is *vapor migration* — moisture moving from inside the building into the roof assembly, where it can condense, wet the insulation, and cause widespread system failure that's invisible until major damage is done.

Reps don't design ventilation systems. That's engineering work. But reps need to recognize the signs, ask the right questions, document what they see, and escalate to the production team or qualified inspector when ventilation appears to be a real factor in the roof's condition or the project's scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '2'
);

-- Part 2 / Ch 14 / Sec 3: The Basic Physics — Plain Language
UPDATE sections SET
  content_markdown = $mfst$Two simple ideas explain almost everything reps need to know.

### Warm air rises. Warm air also holds more moisture than cold air.

Inside a heated home or building, warm humid air naturally moves upward. When that warm humid air reaches a cooler surface — like the underside of a cold roof deck on a winter night — the moisture in the air condenses back into water on the cool surface. This is the same effect as a cold glass of water "sweating" on a humid day.

That condensed water on the underside of the roof deck or inside the insulation is the source of most ventilation-related roof problems.

### Moving air carries moisture away. Trapped air doesn't.

If air can move through an attic or roof assembly continuously — coming in from one place, exiting from another — it carries moisture out before condensation accumulates. If air is trapped, moisture builds up.

This is why ventilation isn't really about temperature — it's about moisture. The temperature benefits (cooler attics in summer, warmer attics in winter) are real but secondary. The primary job of attic ventilation is to keep moisture from accumulating where it doesn't belong.

### What happens when ventilation fails

On a steep-slope residential roof:

- Moisture accumulates on the underside of the roof deck
- Roof deck wood absorbs moisture, eventually rotting
- Insulation gets wet and loses its R-value
- Mold can develop in the attic
- Heat builds up in summer, accelerating shingle aging
- Ice dams form in cold climates (less relevant in NorCal)
- Manufacturer warranties on shingles often require adequate ventilation; failure can void coverage

On a flat-roof commercial building (different mechanism):

- Vapor moves from the conditioned interior into the roof assembly
- Vapor reaches the cooler surfaces above the insulation and condenses
- Insulation gets wet — and once wet, often stays wet for years
- Wet insulation accelerates membrane aging from below
- Building loses thermal performance
- Eventually the system fails, often invisibly until inspection or tear-off reveals the extent$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '3'
);

-- Part 2 / Ch 14 / Sec 4: Steep-Slope Residential Ventilation
UPDATE sections SET
  content_markdown = $mfst$This is the more familiar context. Most residential ventilation problems trace to the same handful of patterns.

### The basic system

A properly ventilated steep-slope roof has two airflow components:

- **Intake vents** — typically at the eaves (soffit vents). Cool outside air enters here.
- **Exhaust vents** — typically at or near the ridge (ridge vents, box vents, or gable vents). Warm air rises and exits here.

Air flows up through the attic from intake to exhaust, carrying moisture and heat with it. The system is passive — driven by natural airflow, not fans (in most installations).

### Common intake vent types

- **Soffit vents** — perforated panels or strip vents in the soffit (the underside of the roof overhang at the eave). Most common.
- **Edge vents / drip-edge vents** — installed at the roof edge instead of in the soffit, where soffits don't exist or aren't ventable.
- **Vented fascia** — built into the fascia board.

### Common exhaust vent types

- **Ridge vent** — a continuous vent running along the peak, typically hidden under ridge cap shingles. Generally considered the most effective passive exhaust.
- **Box vents (also called turtle vents or static vents)** — square or rectangular vents installed on the slope below the ridge. Common on older homes.
- **Turbine vents** — wind-driven spinning vents. Less common in new installations.
- **Gable vents** — louvered openings at the top of gable end walls.
- **Powered attic ventilators** — fan-driven exhaust. Performance and value debated; can sometimes pull conditioned air out of the home if not properly balanced.

### The balance principle

A ventilated attic needs **both** intake and exhaust, in roughly balanced proportion. Common failure patterns:

- **Exhaust without intake** — ridge vent installed but soffits are blocked or sealed; air can't flow because nothing is coming in
- **Mixed exhaust types** — ridge vent and gable vents both present; they short-circuit each other instead of pulling air through the full attic
- **Insufficient total area** — vent area too small for the attic volume

> **[CHECK MANUFACTURER]** Specific ventilation requirements (net free area, intake-to-exhaust ratio) are defined by shingle manufacturers and building code. Reps should not specify these requirements — they are determined by code, manufacturer specs, and the production team.

> **[VERIFY LOCALLY]** California building code (including Title 24 in some applications) sets minimum ventilation requirements. Local jurisdictions may have additional standards.

### Common ventilation problems on steep-slope residential

| Sign | What it usually indicates |
|---|---|
| Soffit vents blocked by insulation | Intake choked off; airflow pattern broken |
| Soffit vents painted over or sealed | Same problem; common on older homes that have been repainted or remodeled |
| Mixed exhaust types (ridge plus gable) | Short-circuiting; attic not fully ventilated |
| Powered attic ventilator with sealed soffits | Fan pulls conditioned air from the home; energy waste, ineffective ventilation |
| Visible water staining on the underside of the roof deck | Active or past condensation problem |
| Visible mold or biological growth in the attic | Moisture problem severe enough to support biological activity |
| Frost on the underside of the roof deck (in cold conditions) | Active condensation occurring |
| Wet or compressed insulation | Moisture has been accumulating |
| Premature shingle aging on a relatively new roof | Often traces to inadequate ventilation |
| "Hot attic" complaint from the customer | High summer attic temperatures, often driven by inadequate exhaust |

### What reps document on the ventilation lens

During any steep-slope inspection (Chapters 1, 8), reps should document:

- Visible exhaust vents on the roof (count, type, condition)
- Visible intake provisions at the eaves (where assessable from ladder edge or attic)
- Any short-circuit configurations (e.g., ridge vent plus gable vents)
- Attic conditions if accessible — staining, mold, wet insulation, frost
- Any customer-reported symptoms — hot attic, ice dams in past, premature shingle aging

> **[SALES REP BOUNDARY]** Reps may document visible ventilation conditions and ask customers about symptoms. They may not certify ventilation adequacy, calculate net free area requirements, specify ventilation system designs, or diagnose mold without qualified support.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '4'
);

-- Part 2 / Ch 14 / Sec 5: Flat-Roof Commercial Vapor and Condensation
UPDATE sections SET
  content_markdown = $mfst$This is where many reps' mental model breaks down. Flat-roof commercial buildings don't have attics in the traditional sense, so attic ventilation isn't the issue. Instead, the concern is **vapor migration through the roof assembly**.

### How vapor moves in a commercial flat roof

In a typical commercial building:

- Interior air is warm and contains moisture (from people, processes, washrooms, kitchens, manufacturing)
- That warm humid air pushes upward against the underside of the roof
- If the roof assembly doesn't include a proper vapor barrier (or vapor retarder), some of that humidity moves into the assembly
- As the vapor moves up through the insulation toward the membrane, it cools
- At some point — depending on temperature gradient and assembly design — it reaches the **dew point** and condenses into liquid water
- That water gets trapped in the insulation, between the insulation and the membrane, or against the underside of the membrane

The membrane keeps rain *out*. The vapor barrier keeps interior moisture *in* (i.e., prevents it from entering the assembly). Both matter.

### Common building types where vapor matters most

Vapor problems are more common in buildings with high interior humidity:

- Restaurants and commercial kitchens
- Laundromats and dry cleaners
- Refrigerated and cold-storage facilities
- Hospitals and medical facilities
- Indoor pools and natatoriums
- Manufacturing facilities with humid processes

For most "ordinary" commercial buildings — offices, retail, warehouses without humid processes — vapor concerns are less acute but not zero.

### What reps see during inspection

Vapor and condensation problems on commercial roofs are often invisible from the surface. Signs that something is wrong:

| Sign | What it usually indicates |
|---|---|
| Soft / spongy underfoot when walked | Wet insulation — could be from above (leak) or from below (vapor) |
| Widespread membrane blistering | Moisture entrapment; could be vapor-driven, leak-driven, or installation-related |
| Membrane delamination over isolated areas | Local moisture issues in the assembly |
| Water marks, rust streaks, or efflorescence on parapet wall interiors visible from inside | Moisture moving through the assembly |
| Mold or musty smell inside the building near the roof line | Active moisture problem |
| Persistent leaks that don't trace to a visible roof failure | Possible interior moisture source |
| Building was recently changed in use (e.g., warehouse to commercial kitchen) | Use change may have introduced humidity the original roof wasn't designed for |
| Conditioned interior space directly below an unconditioned attic above (cathedral ceiling–type construction in commercial) | Vapor pathway concerns |

### Why this matters for proposals

Vapor and condensation issues directly affect every recommendation in this book:

- **Restoration:** coatings cannot be applied over wet insulation. If vapor has wet the insulation, restoration fails. (See Chapter 3.)
- **Recover (TPO overlay over BUR):** installing a new system over wet insulation traps moisture. (See Chapter 9.)
- **Replacement:** the new assembly must address the vapor source, not just install new components — otherwise the new roof will fail the same way the old one did.
- **SPF:** SPF over a substrate with vapor issues can trap moisture differently than other systems. (See Chapter 10.)

### What reps must NOT do
- Diagnose vapor problems beyond documenting visible signs
- Specify vapor barriers or retarders
- Calculate dew point or vapor drive
- Promise that a new roof system will solve a vapor problem without a moisture survey or qualified assessment
- Recommend restoration on a roof showing soft underfoot or signs of widespread moisture entrapment

> **[SALES REP BOUNDARY]** Vapor and condensation diagnosis on commercial roofs is qualified work. Reps document visible signs, ask the customer about building use changes and humidity sources, and escalate to senior estimator for moisture survey or assembly evaluation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '5'
);

-- Part 2 / Ch 14 / Sec 6: The Re-Roof Conversation
UPDATE sections SET
  content_markdown = $mfst$One of the most important moments for ventilation discussion is during a re-roof or restoration project. The roof system is coming off (or being covered); whatever ventilation problems existed before will continue with the new system unless addressed.

### On steep-slope residential

A re-roof is often the right time to:

- Confirm intake and exhaust ventilation is adequate per current code and manufacturer requirements
- Add ridge vent if not already present
- Clear blocked soffit vents
- Resolve mixed-exhaust short-circuit configurations
- Document the ventilation work for warranty purposes

Reps should bring this up — *not* as upselling, but as part of doing the project right. If the rep doesn't bring it up, the customer often won't know to ask, and the new roof may age prematurely under the same conditions that aged the old one.

### On flat-roof commercial

On commercial replacement projects:

- The production team and (often) a qualified inspector evaluate the existing assembly for moisture, vapor barriers, and insulation condition
- The new assembly is specified to address any vapor concerns identified
- Wet insulation is removed before new components go in
- Vapor retarders are added where the building's use and climate warrant

Reps don't specify these decisions, but reps need to know they exist so they can:

- Ask the right questions during inspection
- Flag suspected vapor issues for senior estimator review
- Communicate honestly with the customer about why the inspection or moisture survey matters

### Suggested customer language

> "Whenever we re-roof a residential property, we look at the ventilation. The reason is that ventilation drives how long the new roof lasts — if the attic isn't breathing right, the new shingles age faster than they should. It's not always obvious from the ground, so part of our inspection includes the eaves and the attic where we can. If we find issues, we'll flag them so they can be addressed as part of the project, not after."

> "On commercial flat roofs, we look at the assembly underneath the membrane, not just the membrane itself. If the building has had moisture problems, those usually trace to the assembly — wet insulation, vapor coming up from inside the building, things you can't see from the surface. Before we propose any restoration or replacement, we want to confirm what's happening below the membrane, because installing a new system over a wet assembly is the most common reason commercial roofs fail early."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '6'
);

-- Part 2 / Ch 14 / Sec 7: Common Customer Questions and Honest Answers
UPDATE sections SET
  content_markdown = $mfst$**Q: Does my attic need a fan?**
A: Sometimes, but powered fans are not always the right answer. Passive ventilation — properly balanced intake at the soffits and exhaust at the ridge — works for most attics without any fans. A fan installed without correcting blocked intake can actually make things worse by pulling conditioned air from the house.

**Q: Why does my roof age faster on the south side?**
A: Sun exposure is the obvious answer, and it's part of it. The other part is often ventilation: hotter attic temperatures stress the shingles from below at the same time the sun stresses them from above. South-facing slopes get hit by both.

**Q: I keep getting condensation on my windows. Is that a roof problem?**
A: Window condensation is usually a humidity issue inside the home, not a roof issue directly. But high interior humidity can also be putting moisture into the attic if the air sealing isn't good. We can document what we see during inspection, but window condensation specifically is usually a home-comfort or HVAC question.

**Q: I have a flat-roof building and the inside ceiling has water marks but the roof passes my contractor's inspection. What's going on?**
A: That's a classic vapor pattern. Ceiling water marks on a building where the roof inspection looks fine often trace to interior moisture moving up into the assembly and condensing. It's not a leak in the traditional sense — it's an assembly issue. You'd want a moisture survey or qualified assembly assessment, not just a roof inspection.

**Q: Will adding insulation fix my hot attic?**
A: Insulation reduces heat transfer between the attic and the living space, which helps the home stay cooler. But hot attics are usually a ventilation issue, not an insulation issue. More insulation alone in a poorly ventilated attic doesn't solve the underlying problem and can sometimes make it worse if it blocks soffit vents.

**Q: Does ventilation void my shingle warranty?**
A: It can. Most shingle manufacturers require adequate attic ventilation as a warranty condition. Inadequate ventilation that contributes to premature aging or moisture damage is a common reason warranty claims are denied. We can review the manufacturer's requirements and your current ventilation as part of any re-roof project.

> **[CHECK MANUFACTURER]** Specific manufacturer warranty requirements for ventilation vary. Confirm against the product warranty document before quoting any specific requirement.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '7'
);

-- Part 2 / Ch 14 / Sec 8: Common Ventilation and Condensation Mistakes
UPDATE sections SET
  content_markdown = $mfst$### Mistakes by reps

- Skipping the ventilation lens during steep-slope inspections
- Recommending re-roof scope without addressing ventilation
- Diagnosing vapor problems on commercial roofs without escalation
- Promising a new roof will solve a moisture problem without assembly evaluation
- Calculating ventilation requirements outside the rep's scope
- Recommending powered attic fans without considering whether intake is adequate
- Confusing temperature complaints (hot attic) with moisture problems (wet insulation) — they're related but not identical

### Mistakes by customers (worth flagging)

- Sealing soffit vents thinking they're "drafty"
- Adding insulation that blocks soffit vents
- Installing a powered attic fan without balanced intake
- Mixing exhaust types (e.g., adding gable vents to a roof with ridge vent)
- Ignoring attic odors, staining, or moisture as "just attic stuff"
- Assuming a flat-roof leak must come from a hole in the roof — when assembly moisture is the actual cause

### What reps should do when they encounter customer mistakes

Document what they see, explain in plain language what's happening and why it matters, and recommend escalation or proper scope rather than trying to "fix" by themselves. Bad ventilation work does more damage than no work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '8'
);

-- Part 2 / Ch 14 / Sec 9: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Opening the ventilation conversation on a residential inspection

> "While I'm doing the roof inspection, I'm also looking at the ventilation. That covers two things: the vents on the roof itself, and the intake at the eaves. If your attic is accessible, I'll take a look in there too. The reason is that ventilation drives how long any roof lasts — even a perfectly installed new roof can age fast if the attic isn't breathing right."

### When ventilation issues are found during a re-roof inspection

> "Good news is the roof itself can be re-roofed. Before we finalize the proposal I want to flag the ventilation findings, because addressing them as part of the project costs less than coming back later. We documented [specific findings]. Here's what I'd recommend including in the scope and why."

### When commercial vapor concerns are suspected

> "I want to be honest with you — what I'm seeing on the roof surface looks one way, but the symptoms you're describing inside the building suggest there might be more going on in the assembly than what we can see from above. Before we propose a restoration or replacement scope, I'd recommend a moisture survey to confirm what's happening below the membrane. I'll flag this for our senior estimator and we'll come back to you with the right next step."

### When the customer dismisses ventilation as a "salesperson upsell"

> "Fair concern, and I'll be straight with you — ventilation work isn't a high-margin add-on for us. The reason we bring it up is that it affects how long the new roof actually lasts. If your manufacturer warranty requires ventilation and the attic isn't ventilated, the warranty may not cover an early failure. That's not a sales pitch; it's the reason we'd rather do the work right than have you call us in eight years about premature aging."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '9'
);

-- Part 2 / Ch 14 / Sec 10: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Ventilation calculations or system design questions arise
- Mold or biological growth is suspected in an attic
- Active condensation or wet insulation on a residential or commercial roof is suspected
- A moisture survey on a commercial flat roof is needed
- Building use change appears to have introduced humidity the original roof wasn't designed for
- Customer reports persistent moisture issues that don't trace to visible roof failures
- Manufacturer warranty review related to ventilation is needed
- Code or jurisdictional questions on ventilation requirements arise
- Powered attic fan installation or specification questions
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '10'
);

-- Part 2 / Ch 14 / Sec 11: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard ventilation inspection scope on steep-slope residential: [placeholder]
> - Our standard moisture / vapor concern flagging process on flat-roof commercial: [placeholder]
> - Our scope for ventilation upgrades during re-roof projects: [placeholder]
> - Our partner relationships for moisture surveys and qualified inspectors: [placeholder]
> - Our position on customer-requested powered attic fans: [placeholder]
> - Our escalation process for vapor and condensation findings: [placeholder]
> - Our handoff process for ventilation-related work between sales and production: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '11'
);

-- Part 2 / Ch 14 / Sec 12: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They think ventilation only matters in cold climates (it matters in NorCal too — heat-driven aging is a real issue inland).
- They confuse residential attic ventilation with commercial flat-roof vapor concerns — different mechanisms, different fixes.
- They treat ventilation as a low-priority topic because it doesn't drive immediate revenue.
- They miss the warranty implication — many shingle manufacturer warranties require adequate ventilation.
- They diagnose moisture problems beyond their training.
- They recommend powered attic fans without checking that intake is adequate.

**Discussion questions for group training**
- A homeowner says her shingles are aging faster than expected on a 12-year-old roof. What ventilation questions do you ask, and what do you check?
- A commercial property has persistent ceiling-tile staining but the roof inspection doesn't show a clear leak. What's likely going on?
- A customer wants to skip the ventilation upgrade on a re-roof because it adds cost. How do you handle the conversation?
- What's the 30-second answer to "why does ventilation matter to my new roof?"
- A homeowner sealed her soffit vents because they were "drafty." What do you say?

**Field exercises**
- Pair up. Walk through a real residential roof and identify all visible ventilation components. Note any short-circuit configurations or blocked intake.
- Practice the re-roof ventilation conversation in role-play.
- Review three commercial inspection reports. Identify any signs of suspected vapor or moisture issues that should have been escalated.
- Practice the "I'm not going to diagnose this without a moisture survey" conversation.

**What the manager should test verbally**
- Distinguish residential attic ventilation from commercial flat-roof vapor concerns.
- Name three intake vent types and three exhaust vent types on residential.
- Explain the balance principle (intake plus exhaust, balanced).
- State the disqualifying condition for restoration that traces to vapor (wet insulation).
- Name five things a rep must not do on ventilation and condensation topics.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '12'
);

-- Part 2 / Ch 14 / Sec 13: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Attic ventilation** — passive or powered airflow through the attic space of a steep-slope roof, intended to remove moisture and heat.
- **Box vent (turtle vent, static vent)** — square or rectangular exhaust vent installed on the roof slope.
- **Condensation** — water that forms when warm humid air cools below its dew point and water vapor turns to liquid.
- **Dew point** — the temperature at which water vapor in the air condenses into liquid water.
- **Exhaust vent** — vent at or near the ridge or upper part of the attic where warm air exits.
- **Gable vent** — louvered exhaust vent at the top of a gable end wall.
- **Intake vent** — vent at the eave or roof edge where outside air enters the attic.
- **Net free area** — the actual open ventilation area (excluding screening and blockage); used in code and manufacturer ventilation calculations.
- **Powered attic ventilator** — fan-driven exhaust vent.
- **Ridge vent** — continuous exhaust vent installed along the peak of a steep-slope roof.
- **Short-circuit (ventilation)** — pattern where two exhaust vents pull from each other instead of pulling air through the full attic.
- **Soffit vent** — perforated panel or strip vent in the underside of the roof overhang.
- **Vapor barrier / vapor retarder** — layer in a roof assembly that limits movement of water vapor from inside the building into the assembly.
- **Vapor migration** — movement of water vapor through building materials, typically from warm/humid spaces toward cooler ones.
- **Wet insulation** — insulation that has accumulated moisture and lost thermal performance; common on commercial flat roofs with vapor or leak issues.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '13'
);

-- Part 2 / Ch 14 / Sec 14: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Ventilation and condensation matter because they often drive the visible problems customers call about — premature shingle aging, wet insulation, mystery leaks, and warranty disputes. On steep-slope residential roofs, attic ventilation works through balanced intake at the eaves and exhaust at or near the ridge; common failures include blocked soffits, mixed exhaust types that short-circuit airflow, and powered fans without adequate intake. On flat-roof commercial buildings, the concern shifts from attic ventilation to vapor migration through the roof assembly; symptoms are often invisible from the surface and trace to wet insulation, building use changes, or missing vapor barriers. Reps document visible signs, ask the right questions, recognize the warranty and project implications, and escalate diagnostic and design questions to senior estimators or qualified inspectors. The most important moments for ventilation conversation are during re-roof and restoration projects, when conditions can be addressed as part of the work rather than discovered later. Reps don't design ventilation systems; reps recognize that ventilation is the often-invisible factor that determines whether the new roof actually performs the way the customer expects.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '14'
);

-- Part 2 / Ch 14 / Sec 15: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The primary purpose of attic ventilation on a steep-slope roof is to:
A. Cool the home in summer
B. Remove moisture before it accumulates and damages the roof assembly
C. Allow homeowners to access the attic
D. Comply with HOA aesthetic standards

**2. (Beginner)** "Intake vents" on a steep-slope roof are typically located:
A. At the ridge
B. At the gable end walls
C. At the eaves (soffit vents)
D. On the roof slope mid-roof

**3. (Beginner)** Condensation forms when:
A. Cold air rises to a warmer surface
B. Warm humid air cools below its dew point and water vapor turns to liquid
C. Sunlight directly heats a roof surface
D. Snow accumulates on a roof

**4. (Beginner)** On most commercial flat roofs, ventilation concerns are:
A. The same as residential attic ventilation
B. Different — typically focused on vapor migration through the roof assembly rather than attic airflow
C. Not relevant
D. Only relevant in cold climates

**5. (Intermediate)** A homeowner has installed a ridge vent and gable vents on the same roof. The likely effect is:
A. Improved ventilation through redundancy
B. A short-circuit pattern where the two exhaust types pull from each other instead of pulling air through the full attic
C. Better cooling in summer only
D. No effect on ventilation

**6. (Intermediate)** Soft / spongy underfoot on a commercial flat roof most likely indicates:
A. Normal membrane wear
B. Wet insulation in the assembly
C. Strong manufacturer warranty
D. Recently applied coating

**7. (Intermediate)** A customer's shingles are aging faster than expected on a 10-year-old roof. The first ventilation factor to investigate is:
A. Whether the gutters are clean
B. Whether intake (soffit) and exhaust (ridge or other) are present and balanced
C. The color of the shingles
D. The brand of nails used

**8. (Intermediate)** A commercial building's use was recently changed from a warehouse to a commercial kitchen. The roof concern this raises is:
A. None — building use doesn't affect roofs
B. Increased interior humidity that may exceed what the original roof assembly was designed to handle
C. Need for new gutters
D. Required color change for Title 24

**9. (Advanced)** A customer with persistent ceiling-tile staining inside a commercial building asks the rep for a roof patch quote. Roof inspection shows no visible failure. The most appropriate response is:
A. Quote a patch on the area above the staining
B. Decline the work
C. Document inspection findings, flag the possibility of vapor or assembly moisture issues, and escalate for moisture survey or qualified assembly assessment before quoting
D. Recommend restoration coating

**10. (Advanced)** A homeowner asks the rep to skip the ventilation upgrade on a re-roof to save cost. The most honest response is:
A. Skip the ventilation work without further comment
B. Insist the customer accept the ventilation upgrade
C. Explain that ventilation drives how long the new roof lasts and may affect manufacturer warranty coverage; document the conversation if the customer still declines
D. Refer the customer elsewhere

---

### Answer Key

1. **B — Remove moisture before it accumulates.** This is the primary function from Section 3. Cooling (A) is a secondary benefit; (C) and (D) are unrelated.
2. **C — At the eaves (soffit vents).** Standard intake location. Ridge (A) and gable (B) are typically exhaust; mid-roof (D) is unusual for intake.
3. **B — Warm humid air cools below its dew point.** Standard physics from Section 3.
4. **B — Different — typically focused on vapor migration.** Section 5. Same as residential (A) is wrong; (C) understates; (D) misses warm-climate vapor concerns.
5. **B — Short-circuit pattern.** This is a common configuration error from Section 4.
6. **B — Wet insulation in the assembly.** Standard sign on commercial roofs. (A) understates; (C) and (D) are unrelated.
7. **B — Whether intake and exhaust are present and balanced.** This is the ventilation lens from Section 4. Gutters (A), color (C), and nails (D) are unrelated to premature shingle aging from ventilation.
8. **B — Increased interior humidity.** Building use changes are a documented vapor concern (Section 5). (A) is wrong; (C) and (D) are unrelated.
9. **C — Document, flag possible vapor issues, and escalate for moisture survey.** This is the honest response per Sections 5 and 10. Quoting a patch (A) addresses the wrong problem. Declining (B) abandons the customer. Restoration (D) without inspection is the textbook ethics failure on coatings (Chapter 3).
10. **C — Explain ventilation's role and document the customer's decision if they decline.** This is the honest framework from Section 9. Skipping without comment (A) misses the rep's responsibility. Insisting (B) is heavy-handed. Referring (D) abandons the customer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '15'
);

-- Part 2 / Ch 14 / Sec 16: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual ventilation inspection scope?
- [ ] Matches USA Flat Roof's moisture / vapor flagging and escalation process?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 1 (Composition Shingle), Chapter 8 (Concrete Tile), Chapter 12 (Inspections), and Chapter 13 (Decision Framework)?
- [ ] Does the powered attic fan guidance reflect USA Flat Roof's actual position?
- [ ] Does the customer-conversation language match USA Flat Roof's standard practice?

**Technical Items to Verify Before Publishing**

- Code-dependent items: California ventilation code, Title 24 requirements, jurisdictional standards. Verify with current code references.
- Manufacturer warranty requirements: ventilation as a warranty condition for shingle products USA Flat Roof installs. Verify against current manufacturer documentation.
- Powered attic fan position: confirm USA Flat Roof's actual installation and recommendation policy.
- Moisture survey partner relationships: confirm USA Flat Roof's process for engaging qualified moisture inspectors on commercial projects.
- Re-roof ventilation upgrade scope: confirm USA Flat Roof's standard offerings.
- Cross-references to Chapters 1, 8, 9, 10, 12, and 13: verify ventilation and moisture language is consistent across chapters.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 14 AND s.section_number = '16'
);

-- Part 2 / Ch 15 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain in plain language why most roof leaks happen at details rather than in the middle of the roof field.
2. Recognize and name the most common flashings, penetrations, and edge details on residential and commercial roofs.
3. Inspect details systematically and document failures with appropriate severity ratings.
4. Discuss detail conditions fluently with customers and production teams.
5. Recognize when a detail condition exceeds the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '1'
);

-- Part 2 / Ch 15 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$If you ask experienced roofers where roofs leak, they'll tell you the same thing: at the details. Not the middle of a shingle field, not the center of a TPO sheet, not the open span of a BUR membrane. At the corners, transitions, penetrations, and edges where the roof meets something else.

Two reasons:

**Reason 1: Details concentrate stress.** Every penetration, transition, and edge is a place where the roof has to bend, turn, terminate, or accommodate another building component. These transitions concentrate water flow, mechanical stress, thermal movement, and weathering. The middle of the field is the easiest part of the roof to waterproof; the details are the hardest.

**Reason 2: Details depend on installer skill.** A factory-uniform shingle or membrane is what it is — quality varies by manufacturer, but each unit is consistent. A flashing detail varies with every installer, every penetration, every wall condition. The person who flashed a chimney made hundreds of small decisions that affect whether it leaks in five years.

This chapter gives reps the vocabulary to discuss details fluently and the inspection lens to find detail problems consistently. The "leaks live at details, not the field" message is one of the highest-leverage things a rep can communicate to a customer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '2'
);

-- Part 2 / Ch 15 / Sec 3: The Vocabulary — What Each Detail Is
UPDATE sections SET
  content_markdown = $mfst$Reps don't need to install these details, but they do need to recognize them and use the right names when discussing them with customers and production teams.

### Penetration flashings

A **penetration** is anything that goes through the roof — a pipe, a vent, a chimney, a skylight, a conduit. Each penetration interrupts the continuous waterproofing layer and requires its own flashing.

- **Pipe boot (jack)** — flexible rubber or thermoplastic boot that wraps a pipe penetration and seals to the roof surface. Common on plumbing vents, exhaust pipes. Most common single point of leak failure on residential roofs.
- **Vent flashing** — metal or thermoplastic flashing around exhaust vents (bathroom fans, dryer vents, range hoods).
- **Skylight flashing** — multi-piece flashing kit around skylights, typically with sill flashing at the bottom, head flashing at the top, and step or counter-flashing at the sides.
- **Chimney flashing** — combination of step flashing (along the sides), apron flashing (at the bottom), and saddle or cricket (at the top). Counter-flashing typically caps the step and apron flashings where they meet the chimney.
- **Pitch pan (pitch pocket)** — open-topped metal pan filled with sealant around irregular penetrations on flat roofs (e.g., conduit clusters, multiple small pipes). Common on commercial. **Pitch pans are notorious failure points** — sealant shrinks, cracks, and fails over time.
- **Curb flashing** — flashing at the base of a raised curb (square or rectangular structure) supporting an HVAC unit, equipment platform, or skylight on a flat roof.

### Transition flashings (where the roof meets a wall or another surface)

- **Step flashing** — small individual pieces of metal, each interleaved between courses of shingles where a sloped roof meets a vertical wall. The most common transition flashing on residential.
- **Counter-flashing** — metal that caps step flashing or other base flashings, mounted into or against the wall above. Counter-flashing keeps water from entering behind the step flashing.
- **Kick-out flashing (diverter flashing)** — small bent flashing at the bottom of a sidewall-roof transition that "kicks" water away from the wall and into the gutter. **Frequently missing on older homes** and a major cause of wall-and-fascia rot.
- **Headwall flashing** — flashing where a sloped roof meets a vertical wall at the top of the slope (the "headwall"). Counter-flashing typically caps headwall flashings.
- **Apron flashing** — flat flashing at the bottom of a chimney or other vertical interruption, where water shedding off the surface above hits the obstacle.
- **Saddle / cricket** — small peaked structure built behind a chimney or large penetration to divert water around it instead of letting it pond against the upslope side.

### Valley flashings

A **valley** is where two sloped roof planes meet to form a V. Valleys carry concentrated water and are high-risk leak locations.

- **Open valley** — metal flashing exposed in the valley, with shingles or tiles cut back from the centerline. Water flows on metal.
- **Closed valley** — shingles woven or cut across the valley with no exposed metal. Water flows on shingles.
- **California valley (closed-cut valley)** — variation where one course of shingles runs through the valley and the other is cut alongside. Common on tract-built homes.

### Edge details

These are details at the perimeter of the roof, where the field terminates against the world.

- **Drip edge** — metal flashing at the eave and rake (sloped edge) of a steep-slope roof. Directs water off the deck and into the gutter.
- **Rake edge** — the sloped edge of a roof from eave to ridge on a gable end. Drip edge installed here is sometimes called rake-edge flashing.
- **Eave** — the bottom edge of a roof slope, typically with gutter below.
- **Fascia** — the vertical board at the eave, behind the gutter. Not technically a flashing component, but reps will hear the term constantly.
- **Soffit** — the underside of the roof overhang. Site of soffit ventilation (Chapter 14).
- **Parapet wall** — a wall extending above the roof line, common on flat-roof commercial buildings. Parapet flashings wrap up the wall to a termination point.
- **Termination bar** — metal bar that secures the top edge of a flat-roof membrane against a wall or curb.
- **Coping** — metal cap on top of a parapet wall that sheds water and protects the parapet.
- **Counter-flashing (commercial)** — metal mounted to a wall above a parapet flashing, designed to keep water from entering behind the flashing.
- **Gravel stop** — metal edge detail on commercial built-up roofs that holds gravel in place at the perimeter.

### Drains and drainage details

- **Drain ring (clamping ring)** — metal ring that clamps the membrane to a roof drain, sealing the connection.
- **Scupper** — opening through a parapet wall that allows water to drain to the exterior.
- **Overflow drain (overflow scupper)** — secondary drain installed higher than the primary, intended to handle water if the primary clogs.
- **Drain insert** — flexible insert installed inside an existing drain to repair or upgrade the drain-to-membrane seal.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '3'
);

-- Part 2 / Ch 15 / Sec 4: Why Details Fail
UPDATE sections SET
  content_markdown = $mfst$A handful of mechanisms drive most detail failures. Reps who recognize these mechanisms can predict where the problems will be before climbing the ladder.

### Sealant aging
Sealant cracks, shrinks, and pulls away from substrates over time. Many older details rely heavily on sealant — pitch pans, sealant-only repairs, caulk-and-pray flashings. When the sealant goes, the detail goes.

### Mechanical stress
Buildings move. Thermal expansion and contraction, settling, wind load, and equipment vibration all stress detail joints. Details installed without expansion accommodation fail at the joints.

### Water concentration
Valleys, scuppers, drains, and below-penetration areas all concentrate water flow. More water means more wear, more debris accumulation, more chance of failure.

### Substrate movement
The substrate below a detail moves differently than the detail itself. A wood deck swells and shrinks. A metal coping expands and contracts. Where two materials meet at a detail, differential movement breaks the seal.

### Installer judgment
Many details aren't fully prescribed by manufacturers — the installer has to decide where one piece ends and the next begins, how much overlap to use, where to add sealant. Skill and care vary. Some details are installed beautifully; others are rushed or done by someone who didn't know the system.

### Damage from other trades
HVAC technicians, electricians, painters, and other trades work on roofs and around penetrations. Damage from sealant smears, cut flashings, drilled holes that weren't sealed, and unauthorized penetrations is one of the most common detail-failure causes on commercial buildings.

### UV degradation
Exposed sealants, rubber pipe boots, and certain plastic flashings degrade under UV. South and west exposures fail faster than north.

### Animal and bird damage
Birds, rodents, and (in some areas) raccoons damage details — especially soft components like rubber pipe boots and exposed foam at SPF terminations.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '4'
);

-- Part 2 / Ch 15 / Sec 5: Common Failures by Detail Type
UPDATE sections SET
  content_markdown = $mfst$### Pipe boots
**Why they fail:** Rubber boots crack and split as they age, particularly at the top where they wrap the pipe. UV is the primary driver. Most rubber pipe boots fail within 10–15 years even when the surrounding roof is fine.

**What reps see:** Cracking around the pipe, separation between the boot collar and the pipe, sealant smears from prior repair attempts, daylight visible into the attic at the boot.

**Severity:** Repair Recommended → Urgent depending on whether actively leaking.

### Step flashing and sidewall transitions
**Why they fail:** Counter-flashing missing or improperly installed; step flashing too short or too few pieces; siding installed over flashing instead of behind it (a major issue on remodels); kick-out flashing missing.

**What reps see:** Water staining on sidewall siding above the roof, fascia rot at the corner where sidewall meets eave, interior staining on second-story walls below the flashing area.

**Severity:** Repair Recommended → Urgent.

### Chimney flashings
**Why they fail:** Sealant-only repairs that age out; missing cricket or saddle on the upslope side; counter-flashing not properly bedded into mortar joints; mortar deterioration around counter-flashing.

**What reps see:** Visible sealant repairs, water staining on chimney brick, ceiling stains in rooms below or near the chimney, masonry deterioration at the flashing line.

**Severity:** Repair Recommended → Urgent. Severe chimney issues may require escalation for masonry assessment.

### Skylight flashings
**Why they fail:** Original installation skipped step flashing in favor of sealant-only details; gasket and frame seal aging on the skylight unit itself (not strictly a flashing failure); flashing kit components missing or installed incorrectly.

**What reps see:** Water staining inside the skylight frame, water tracking down adjacent walls, sealant repair smears around the skylight.

**Severity:** Repair Recommended → Urgent. Severe skylight issues may require unit replacement, not just flashing repair.

### Valleys
**Why they fail:** Debris accumulation creating water dam; rust on metal valleys; nails driven through valley flashing; closed valleys with worn shingles where water flow has eroded the surface.

**What reps see:** Debris in the valley, rust streaks, shingle wear concentrated in the valley center, interior staining below valley areas.

**Severity:** Maintenance → Urgent depending on extent.

### Drip edge and eave details
**Why they fail:** Drip edge missing entirely (common on older homes and some quick-build re-roofs); drip edge installed under the underlayment instead of properly integrated; rusted-through drip edge on older metal.

**What reps see:** Water staining behind the gutter, fascia rot, soffit damage at the eave.

**Severity:** Repair Recommended → Urgent.

### Parapet flashings (commercial)
**Why they fail:** Termination bar fasteners pulled or backed out; sealant aged and failed; coping joints opened up; counter-flashing missing; parapet wall itself deteriorated behind the flashing.

**What reps see:** Wall flashing pulled tight or separated from the membrane; rust streaks; efflorescence on parapet wall interiors; water tracking patterns inside the building.

**Severity:** Repair Recommended → Urgent.

### Drains and scuppers
**Why they fail:** Drain ring fasteners pulled; drain insert (if used) aged out; debris and vegetation in drains; scuppers blocked or damaged.

**What reps see:** Standing water near drains, vegetation in drains, debris accumulation, visible damage to drain components, dirt rings showing past ponding.

**Severity:** Maintenance → Urgent depending on extent.

### Pitch pans
**Why they fail:** Sealant shrinks and cracks; sealant pulls away from the metal pan or the penetrations inside. Pitch pans are an old detail still in use that essentially relies on sealant alone.

**What reps see:** Cracked sealant inside the pan, shrinkage gaps, water staining or efflorescence below.

**Severity:** Repair Recommended → Urgent. Modern alternatives (engineered penetration flashings) often replace pitch pans during repair.

### Curb flashings
**Why they fail:** Aging at the base of HVAC and equipment curbs; mechanical damage from technicians servicing the equipment; sealant-only repairs.

**What reps see:** Cracking or separation at the curb base, visible repair attempts, water staining below.

**Severity:** Repair Recommended → Urgent.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '5'
);

-- Part 2 / Ch 15 / Sec 6: Field Inspection Approach for Details
UPDATE sections SET
  content_markdown = $mfst$The right way to inspect details is to slow down. Reps who scan a roof quickly miss detail failures because details don't announce themselves the way a missing shingle does.

### General principles

- **Inspect every penetration individually.** Don't lump them together as "the penetrations are fine."
- **Inspect every transition.** Walls, dormers, chimneys, skylights, parapets, curbs.
- **Inspect every edge.** Drip edge, parapet, scupper, drain.
- **Inspect every valley.** Debris, wear, rust, displacement.
- **Photograph every detail individually** with reference scale where size matters.

### What to ask about during inspection

- "Have you had any leaks recently? Where did the water show up?"
- "Has the chimney/skylight/HVAC ever needed work?"
- "Do you ever have water stains inside near a wall or ceiling intersection?"
- "Has anyone been on the roof recently — HVAC, electrical, painters?"

The customer's reported leak location often points reps to the responsible detail, even though the entry point is usually upslope of the visible damage.

### Detail inspection sequence

**Penetrations**
- Pipe boots: check for cracking, daylight, sealant repairs
- Vent flashings: check for separation, rust
- Skylights: check perimeter flashings and unit frame seal
- Chimneys: check step, apron, cricket, counter-flashing
- HVAC curbs: check base flashings
- Pitch pans: check sealant condition and pull-away
- Conduit and miscellaneous: check sealant, flashing integrity

**Transitions**
- Sidewall step flashing: check counter-flashing, kick-out at bottom, siding-over-flashing issues
- Headwall: check counter-flashing, sealant
- Dormers: check side step flashing, head flashing, valley work where dormer meets main roof

**Edges**
- Drip edge: check presence, condition, integration with underlayment and gutter
- Rake edge: check fastening, condition
- Parapet (commercial): check coping, termination bar, counter-flashing, sealant
- Scuppers: check opening, drainage clearance, surrounding membrane

**Valleys**
- Visually inspect each valley for debris, wear, rust, displacement
- Photograph each valley

**Drains (commercial)**
- Each drain: check ring, insert (if present), debris
- Each scupper: check opening and surrounding membrane
- Overflow drains: confirm presence and condition

### Red flags requiring immediate escalation

- Active leaks traced to detail failures with structural concerns underneath
- Severe masonry deterioration around chimney flashings
- Skylight unit failures (not just flashing) requiring unit replacement
- Multi-trade damage that may require separate trades to resolve
- Suspected hail damage involving insurance claim
- Detail failures that suggest broader system problems (not isolated)
- Solar array on the roof requiring detail coordination$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '6'
);

-- Part 2 / Ch 15 / Sec 7: Detail Inspection in the Severity Scale
UPDATE sections SET
  content_markdown = $mfst$Detail failures cluster on the severity scale predictably:

| Severity | Examples |
|---|---|
| **Monitor** | Light surface aging on flashings; minor sealant chalking; small debris accumulation in valleys |
| **Maintenance Needed** | Sealant refresh at terminations; debris removal from valleys and drains; minor coping joint maintenance; tightening termination bar fasteners |
| **Repair Recommended** | Failed pipe boot; cracked sealant at pitch pan; deteriorated step flashing; missing kick-out flashing; rusted drip edge; failed parapet sealant; drain ring repair |
| **Urgent / Escalate** | Active leaks at detail failures; severe chimney flashing failure; widespread parapet flashing failure; structural concerns at detail areas; multiple-trade damage |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '7'
);

-- Part 2 / Ch 15 / Sec 8: The "Leaks Live at Details" Conversation
UPDATE sections SET
  content_markdown = $mfst$This is one of the higher-leverage messages a rep can deliver to a customer.

### When to deliver it

- During any inspection where details are the issue
- When a customer is fixated on the membrane or shingles and missing the detail picture
- When the customer asks "why does my roof leak when the shingles look fine?"
- When the customer is comparing a quote that focuses on the field while ignoring detail work
- When justifying inspection thoroughness

### How to deliver it

> "Most roofs leak at the details, not in the middle of the field. The shingles or membrane in the middle of your roof are the easy part to waterproof — they're factory-made, uniform, and not really doing anything complicated. Where roofs actually leak is at the corners and transitions: pipe boots, chimneys, skylights, where the roof meets a wall, valleys, drains. Those are the places that depend on installer skill and that age faster than the field. That's why our inspection focuses on every detail individually, not just the overall roof surface."

### When it changes the recommendation

Sometimes the right answer is not a full restoration or replacement but a *targeted detail repair scope*. A roof in good condition with three failed details often needs three repairs, not a new roof. Reps who recognize this avoid overselling.

Conversely, sometimes a roof has too many detail failures to repair economically — at that point the broader work becomes the right call. The detail inspection tells the rep which way to go.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '8'
);

-- Part 2 / Ch 15 / Sec 9: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Opening when details are part of the inspection focus

> "While I'm inspecting the roof, I'm going to spend extra time at the details — the pipe boots, the chimney, the skylight, the valleys, the drains. That's where roofs typically leak, and it's also where I can give you the most useful information about your roof's actual condition."

### When detail failures explain a customer's reported leak

> "We found the source of your leak. It's not directly above the stained ceiling — water travels along the structure before showing up inside. The actual entry point is at [specific detail]. That's a fixable repair. We'll address [scope] and document the work."

### When the customer thinks the whole roof needs to be replaced because of detail failures

> "I want to be straight with you — your roof itself has remaining service life. The leaks you've been having trace to specific details that have aged out. We can address those without replacing the whole roof. Replacement isn't the right call when the underlying system is sound and the details are the issue."

### When detail failures point to broader issues

> "We found multiple detail failures in different places on the roof. That can mean two things: the details are aging out collectively, which is normal at certain roof ages, or the original installation was inconsistent. Either way, we're past the point where individual repairs are the cost-effective answer. Let's talk about what scope makes sense."

### When the customer dismisses detail concerns

> "Fair to ask why this matters. The details are where this kind of roof leaks. The shingle field is the easy part. We can do a less thorough inspection if you prefer, but you'd be paying for a roof recommendation that didn't actually look at where roofs fail. I'd rather you have the full picture."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '9'
);

-- Part 2 / Ch 15 / Sec 10: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Active leaks traced to detail failures with suspected structural or hazard implications
- Severe masonry, brick, or chimney structural concerns
- Skylight unit replacement (not just flashing) needed
- Solar array detail coordination
- Multi-trade damage requiring coordination with other contractors
- Suspected hail or storm damage with insurance involvement
- Code or warranty questions about specific detail requirements
- Customer requests work outside scope (e.g., chimney rebuilding, structural masonry)
- Detail failures concentrated in a way that suggests broader system issues
- Pitch pans on commercial roofs requiring full replacement with engineered details — production scope decision
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '10'
);

-- Part 2 / Ch 15 / Sec 11: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard detail inspection scope across systems: [placeholder]
> - Our standard repair scope for common detail failures: [placeholder]
> - Our position on pitch pan replacement vs maintenance: [placeholder]
> - Our position on kick-out flashing on re-roof and repair projects: [placeholder]
> - Our chimney flashing scope vs masonry referral: [placeholder]
> - Our skylight flashing repair vs unit replacement scope: [placeholder]
> - Our escalation rules and partner relationships for masonry, structural, and skylight unit work: [placeholder]
> - Our standard detail proposal language and warranty terms: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '11'
);

-- Part 2 / Ch 15 / Sec 12: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They scan roofs too quickly and miss detail failures.
- They lump details together ("the penetrations look fine") instead of inspecting each one.
- They focus on the field (shingles, membrane) and underweight the details.
- They miss kick-out flashing because it's small — and miss the wall-and-fascia rot it would have prevented.
- They don't recognize pitch pans as a high-failure detail.
- They don't ask the customer about prior leaks or trade work, missing context that points to the responsible detail.
- They oversell replacement when targeted detail repairs would be the right call.

**Discussion questions for group training**
- A homeowner reports a ceiling stain in a hallway corner. What detail-related questions do you ask, and where do you look first?
- A customer's roof has three failed pipe boots, deteriorated step flashing at a chimney, and a missing kick-out at the bottom of a sidewall. The roof itself is in good condition. What's the recommendation?
- Why is "leaks live at details, not the field" a useful message to deliver to most customers?
- A commercial customer has a pitch pan on a roof with significant grease vent activity. What's the conversation?
- A homeowner says a previous contractor "sealed everything" with caulk. What does that tell you to look for?

**Field exercises**
- Pair up. Inspect a real roof's details together. Use the inspection sequence in Section 6. Document each detail individually with photos and severity ratings.
- Review three sets of inspection photos. For each, identify whether detail issues or field issues drive the right recommendation.
- Practice the "leaks live at details" customer conversation in role-play. Trade roles.
- Walk through a chimney from base to top. Identify every flashing component and any failure modes.

**What the manager should test verbally**
- Name five common penetration flashings and explain what each one does.
- Name three transition flashings and explain where each one belongs.
- Name three edge details and explain why each matters.
- Walk through the chimney flashing components in order.
- State five things a rep must not promise about detail repair.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '12'
);

-- Part 2 / Ch 15 / Sec 13: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Apron flashing** — flat flashing at the bottom of a chimney or vertical interruption.
- **Coping** — metal cap on top of a parapet wall.
- **Counter-flashing** — metal that caps base or step flashings, mounted into or against a wall above.
- **Cricket (saddle)** — small peaked structure behind a chimney to divert water around it.
- **Curb flashing** — flashing at the base of a raised curb on a flat roof.
- **Drain ring (clamping ring)** — metal ring that clamps a roof drain to the membrane.
- **Drip edge** — metal flashing at the eave and rake of a steep-slope roof.
- **Eave** — the bottom edge of a roof slope.
- **Fascia** — vertical board at the eave, behind the gutter.
- **Gravel stop** — metal edge detail on commercial built-up roofs that holds gravel in place.
- **Headwall flashing** — flashing where a sloped roof meets a vertical wall at the top of the slope.
- **Kick-out flashing (diverter flashing)** — bent flashing at the bottom of a sidewall-roof transition that directs water away from the wall.
- **Overflow drain (overflow scupper)** — secondary drain installed higher than the primary.
- **Parapet wall** — a wall extending above the roof line on flat-roof commercial buildings.
- **Penetration** — anything that goes through the roof.
- **Pipe boot (jack)** — flexible boot that wraps a pipe penetration.
- **Pitch pan (pitch pocket)** — open-topped metal pan filled with sealant around irregular penetrations on flat roofs.
- **Rake edge** — sloped edge of a roof from eave to ridge on a gable end.
- **Scupper** — opening through a parapet wall for drainage.
- **Soffit** — underside of a roof overhang.
- **Step flashing** — small individual pieces of metal interleaved between shingle courses where a sloped roof meets a vertical wall.
- **Termination bar** — metal bar securing the top edge of a flat-roof membrane.
- **Valley** — where two sloped roof planes meet to form a V.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '13'
);

-- Part 2 / Ch 15 / Sec 14: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Most roof leaks happen at details — penetrations, transitions, edges, valleys, drains — not in the middle of the roof field. Details concentrate stress, depend on installer skill, and age faster than the field for predictable mechanisms: sealant aging, mechanical stress, water concentration, substrate movement, UV degradation, and damage from other trades. Reps need fluency with the vocabulary (pipe boots, step flashing, counter-flashing, kick-out flashing, valleys, parapets, terminations, scuppers, pitch pans, curb flashings) so they can discuss findings with customers and production teams. Detail inspection requires slowing down and looking at every penetration, transition, edge, and drain individually rather than scanning the field. Failures cluster on the severity scale predictably, and detail-focused inspection often points to *targeted repair* as the right answer rather than full restoration or replacement. The "leaks live at details, not the field" message is one of the higher-leverage things a rep can communicate to most customers — it changes how customers think about their roof and reframes what the rep's inspection is actually doing.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '14'
);

-- Part 2 / Ch 15 / Sec 15: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** Most roof leaks happen at:
A. The middle of the shingle or membrane field
B. The details — penetrations, transitions, edges, valleys, and drains
C. Sealed surfaces only
D. Random locations with no pattern

**2. (Beginner)** A pipe boot is:
A. A type of metal flashing for a chimney
B. A flexible boot that wraps a pipe penetration and seals to the roof surface
C. A drainage component
D. A type of edge detail

**3. (Beginner)** "Step flashing" is typically used:
A. At a roof drain
B. Where a sloped roof meets a vertical wall, with each piece interleaved between shingle courses
C. At the ridge
D. Inside a chimney

**4. (Beginner)** "Kick-out flashing" is found at:
A. The top of a chimney
B. The bottom of a sidewall-roof transition, where water needs to be directed away from the wall
C. The middle of a long valley
D. The peak of a gable end

**5. (Intermediate)** Pipe boots most commonly fail because:
A. Manufacturer defects
B. UV degradation cracking the rubber, particularly at the top where the boot wraps the pipe
C. Wind damage
D. Snow load

**6. (Intermediate)** A "pitch pan" on a commercial roof is:
A. An open-topped metal pan filled with sealant around irregular penetrations
B. A type of parapet flashing
C. A drainage device
D. A new high-tech installation method

**7. (Intermediate)** A homeowner reports water staining at the corner of an upper-story wall just above the roof line. The most likely cause is:
A. A failed shingle in the middle of the roof
B. Missing or improperly installed kick-out flashing at the bottom of the sidewall transition
C. A clogged gutter only
D. A defective skylight

**8. (Intermediate)** A roof has good shingle condition, intact valleys, but three failed pipe boots and deteriorated step flashing at a chimney. The most appropriate recommendation is:
A. Full roof replacement
B. Silicone restoration coating
C. Targeted detail repair scope addressing the failed pipe boots and chimney flashing
D. Decline the project

**9. (Advanced)** A customer dismisses detail-focused inspection as "looking for problems." The most honest response is:
A. Apologize and reduce the inspection scope
B. Skip the detail inspection
C. Explain that details are where roofs typically leak; a less thorough inspection means a less accurate recommendation; offer the customer the choice
D. Tell the customer they don't need any work

**10. (Advanced)** A commercial roof has multiple pitch pans with cracked sealant. The most appropriate response includes:
A. Refresh sealant in each pitch pan and move on
B. Recommend full roof replacement immediately
C. Document the pitch pan failures, propose appropriate repair (which may include replacing pitch pans with engineered penetration flashings depending on scope), and escalate if the broader system also shows issues
D. Ignore them since pitch pans always fail

---

### Answer Key

1. **B — At the details.** Central message of the chapter. Field failures (A) are far less common; (C) and (D) are wrong.
2. **B — A flexible boot that wraps a pipe penetration.** Standard definition.
3. **B — Where a sloped roof meets a vertical wall.** Standard application.
4. **B — At the bottom of a sidewall-roof transition.** Standard application; commonly missing on older homes.
5. **B — UV degradation cracking the rubber.** Most common failure mechanism.
6. **A — An open-topped metal pan filled with sealant around irregular penetrations.** Standard definition. Notorious failure points.
7. **B — Missing or improperly installed kick-out flashing.** Classic pattern. Failed shingle (A) doesn't typically show at sidewall corners. Clogged gutter (C) doesn't usually create wall staining. Skylight (D) only relevant if there is one nearby.
8. **C — Targeted detail repair scope.** Detail-focused repair is the right call when the field is sound. Replacement (A) overshoots; restoration (B) doesn't address detail failures specifically; declining (D) abandons the customer.
9. **C — Explain that details are where roofs leak; offer the customer the choice.** This is the honest customer education from Section 9. Apologizing or skipping (A, B) reduces inspection quality. Telling the customer they don't need work (D) is unsupported.
10. **C — Document, propose appropriate repair, escalate if broader system also shows issues.** Sealant refresh alone (A) is short-term spending on a high-failure detail. Full replacement (B) overshoots without broader system findings. Ignoring (D) misses real failures.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '15'
);

-- Part 2 / Ch 15 / Sec 16: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual detail inspection scope?
- [ ] Matches USA Flat Roof's standard repair scope for common detail failures?
- [ ] Are the residential and commercial detail vocabulary accurate for our market and crews?
- [ ] Is the "leaks live at details" framing aligned with how managers want reps to lead conversations?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 1–10 (system chapters), Chapter 11 (Maintenance and Repairs), Chapter 12 (Inspections), Chapter 13 (Decision Framework), and Chapter 14 (Ventilation)?
- [ ] Does the pitch pan guidance match USA Flat Roof's actual position on repair vs replacement with engineered details?
- [ ] Does the kick-out flashing guidance reflect our current re-roof and repair standards?

**Technical Items to Verify Before Publishing**

- Detail vocabulary: confirm terms used match USA Flat Roof's internal language and what production teams use.
- Pipe boot lifespan: confirm 10–15 year range for typical rubber boots in NorCal field experience.
- Pitch pan replacement scope: confirm USA Flat Roof's standard offering for engineered penetration flashings as alternatives.
- Skylight flashing repair vs unit replacement: confirm USA Flat Roof's scope and partner relationships for skylight units.
- Chimney flashing repair scope: confirm USA Flat Roof's masonry interface and referral process for masonry-specific work.
- Solar coordination: confirm USA Flat Roof's standard procedure for detail work near PV.
- Cross-references to all earlier chapters should be verified once the system chapters are finalized.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 15 AND s.section_number = '16'
);

-- Part 2 / Ch 16 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Explain why drainage drives roof performance more than almost any other single factor.
2. Recognize and inspect residential gutter systems at the level needed for sales conversations.
3. Inspect commercial flat-roof drainage and assess ponding water with appropriate vocabulary and judgment.
4. Distinguish acceptable ponding from problematic ponding, and articulate the difference to a customer honestly.
5. Recognize when ponding or drainage conditions exceed the sales rep's role and must be escalated.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '1'
);

-- Part 2 / Ch 16 / Sec 2: Why Drainage Matters
UPDATE sections SET
  content_markdown = $mfst$Every roof system in this book performs better with good drainage and worse with bad drainage. Drainage is the single most important factor outside of installation quality that determines how long a roof lasts.

The reason: water is the thing roofs are designed to keep out. The faster water leaves the roof surface, the less time it has to find a weakness, accelerate aging, or compromise a detail. The longer water sits on a roof, the more wear it creates — even on systems specifically designed to tolerate water.

This applies on both residential and commercial buildings, but the mechanisms differ:

- **On residential steep-slope roofs**, gravity does most of the drainage work. Gutters and downspouts handle the water once it reaches the eave. Drainage problems show up as overflow, foundation issues, fascia rot, and ice damming in cold climates.
- **On commercial flat (low-slope) roofs**, drainage is engineered into the system. Slope is intentional but small (typically 1/4 inch per foot or less). Drains, scuppers, and overflow drains carry the water off. Drainage problems show up as ponding water, accelerated membrane aging, structural concerns, and warranty disqualifications.

This chapter weights ponding water heavily because it's where the real money decisions happen on commercial buildings — and where rep judgment most affects customer outcomes.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '2'
);

-- Part 2 / Ch 16 / Sec 3: Residential Gutters and Drainage — Brief Coverage
UPDATE sections SET
  content_markdown = $mfst$Reps need enough gutter literacy to discuss findings during inspections and recommend basic improvements. Detailed gutter design and installation is a separate trade.

### Why gutters matter to roofs

A gutter that doesn't drain properly creates two problems for the roof itself:

- Water backs up onto the eave, where it can wick under shingles or saturate the drip edge area
- Overflow runs down the fascia and behind the gutter, soaking the fascia board and eventually the soffit and the roof deck edge

Most homeowner gutter complaints are about water hitting their landscaping or foundation. Reps should also notice the *roof-side* effects: water staining on the fascia, soft spots at the eave, sagging gutters indicating the eave behind has rotted.

### What reps should observe during inspection

- Gutter condition: rust, holes, visible separation from fascia
- Gutter slope toward downspouts: standing water in gutters indicates poor slope or partial blockage
- Debris accumulation: leaves, granules from shingle wear (a maintenance indicator on its own — see Chapter 1)
- Downspout count and position: too few downspouts overload sections of gutter
- Visible signs of overflow: staining on fascia or siding, erosion in landscaping below
- Fascia and soffit condition behind the gutter: rot, soft spots, peeling paint
- Drip edge integration with the gutter: gap between drip edge and gutter back, drip edge installed *behind* the gutter instead of correctly positioned

### When to address gutters in proposals

- During re-roof projects, the gutter line is exposed and accessible — addressing gutter issues alongside the roof work is often cost-effective for the customer
- When gutter problems are clearly contributing to roof issues (fascia rot, eave damage)
- When the customer asks about water management on the property

### What reps must NOT do

- Quote gutter replacement without inspection or appropriate authorization
- Treat gutter cleaning as roof scope (it's typically a separate service line)
- Diagnose foundation or landscaping water issues beyond noting that drainage may be a contributor

> **[COMPANY POLICY]** Placeholder — USA Flat Roof's scope on gutter work, partner relationships for gutter installation, and gutter inspection standards as part of roof inspections.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '3'
);

-- Part 2 / Ch 16 / Sec 4: Commercial Flat-Roof Drainage — How It's Designed
UPDATE sections SET
  content_markdown = $mfst$Flat roofs are not actually flat. Every commercial flat roof is designed with some slope — usually 1/4 inch per foot or less — to direct water toward drainage points. The design intent matters because it sets the baseline for whether a roof is performing as intended or has drainage problems.

### Three drainage approaches

**Internal drains**
Drain openings located within the roof field, with piping that carries water down through the building's interior to street-level discharge. Common on multi-tenant commercial, large-footprint buildings, and structures where exterior drainage isn't practical. Internal drains require:

- Primary drain at the lowest design point of the area being drained
- Overflow drain (or overflow scupper) at a higher elevation, intended to handle water if the primary clogs
- Properly sealed drain ring (clamping ring) where the membrane meets the drain
- Clear drain bowl and strainer

**Scuppers (through-wall drainage)**
Openings through a parapet wall that allow water to exit to the building exterior. Common on smaller commercial buildings and where parapets are present. Scuppers require:

- Primary scupper at the design low point
- Overflow scupper at a higher elevation
- Properly flashed opening through the parapet wall
- Clear opening, typically with a strainer or grate

**Edge drainage (gutter on flat-roof commercial)**
Some flat-roof commercial buildings drain off an unparapeted edge into a gutter. Less common on traditional commercial; more common on low-rise mixed-use, retail strip centers, and single-story light commercial. Edge drainage shares many residential gutter concerns plus the slope-and-flow concerns of flat-roof drainage.

### The role of overflow drainage

**Overflow drains and scuppers** are not optional. They exist because primary drains can clog with debris, and a clogged primary drain on a flat roof can allow water to accumulate to depths that threaten structural integrity. The overflow is the safety mechanism that keeps a clogged drain from becoming a building emergency.

When reps inspect commercial roofs, **confirming overflow drainage is present and clear is one of the most important inspection items.** A roof without functional overflows is a roof with a hidden risk that the customer often doesn't know about.

> **[VERIFY LOCALLY]** California building code requires overflow drainage on most commercial flat roofs. Specific requirements depend on building type, age, and jurisdiction. Confirm with code official when overflow provisions are missing or unclear.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '4'
);

-- Part 2 / Ch 16 / Sec 5: Ponding Water — The Central Topic
UPDATE sections SET
  content_markdown = $mfst$Ponding water is where most commercial drainage conversations happen. The single most important fact for reps to internalize:

**Ponding water is not always a problem. Ponding water that persists for too long always is.**

This single distinction drives most of what reps need to communicate to customers.

### How ponding is defined

Different sources use slightly different definitions. The practical industry standard most reps will encounter:

- **Acceptable ponding:** water that drains within 48 hours of rain stopping
- **Problematic ponding:** water that persists longer than 48 hours
- **Severe ponding:** water that essentially never drains; permanent low spots holding water

> **[CHECK MANUFACTURER]** Manufacturer warranty terms vary on ponding tolerance. Some warranties specifically exclude damage related to ponding water; others have defined ponding limits. Confirm against the actual warranty document.

### Why ponding matters

- **Membrane aging acceleration.** Even single-ply membranes designed to tolerate water perform worse under persistent ponding. UV exposure combines with constant water contact to degrade the membrane faster.
- **Dirt and biological growth.** Standing water collects dirt, algae, and biological growth. The ponding ring becomes a dirty, biologically-active area that ages faster than dry sections.
- **Structural concerns at extreme depths.** Water weighs about 5.2 pounds per square foot per inch of depth. A persistent 2-inch pond over a 1,000 square foot area weighs over 10,000 pounds. Severe ponding can exceed structural design loads.
- **Warranty risk.** Many manufacturer warranties limit or exclude coverage for ponding-related damage.
- **Restoration and recover disqualification.** Chronic ponding is one of the disqualifying conditions for restoration coatings (Chapters 3, 9) and a major factor in deciding between TPO overlay and SPF on recover projects (Chapter 9).
- **Insulation moisture.** Even where ponding doesn't cause active leaks, persistent water above can drive moisture into the assembly through small membrane imperfections that wouldn't otherwise leak.

### What causes ponding

A handful of causes account for most ponding:

- **Inadequate slope from original construction.** Some older buildings were built with too-flat decks, and the original roof system never drained well.
- **Settled or deflected structure.** Buildings settle. Decks deflect over time, especially on long-span structures. Areas that drained when the building was new may pond after years of settlement.
- **Insulation crushing or compression.** Tapered insulation systems lose their slope when insulation compresses under foot traffic, equipment, or weight.
- **Clogged drains.** A drain that doesn't drain creates ponding regardless of how well-sloped the surrounding roof is.
- **Drain or scupper too high.** Sometimes the drain itself is set too high relative to surrounding roof, creating a permanent puddle around the drain.
- **HVAC and equipment placement.** Equipment installed in a low spot creates a dam upstream of the equipment.
- **Recover projects without slope correction.** Adding a layer of insulation and membrane over a roof with existing ponding doesn't fix the slope — it raises the whole roof level but preserves the same low spots.
- **Recover projects done with tapered insulation that wasn't tapered enough or correctly.** Common on older recover work.

### How to inspect ponding

Reps can document ponding evidence even when the roof is dry at the time of inspection.

**Visible ponding evidence**
- **Ponding rings:** dirt accumulation in a circular or oblong pattern marks where water has been sitting. The most reliable indicator on a dry roof.
- **Biological growth patterns:** algae or moss concentrated in low areas indicates persistent moisture.
- **Membrane discoloration:** the section that ponds often looks visibly different from the rest of the roof.
- **Granule or surface wear concentrated in patterns:** modified bitumen, BUR with cap sheet, and other surfaced systems show wear concentrated in ponding areas.
- **Sediment or debris accumulation:** debris settles in low areas where water collected.

**Photographing ponding**
- Use chalk to outline the extent of past ponding marked by dirt rings
- Take wide shots showing the ponding area in context with the nearest drain or scupper
- Take close-ups showing the ponding ring, biological growth, or membrane condition within the pond
- If inspection happens during or after rain, photograph standing water with depth indication where possible

**Asking the customer**
- "How long does water sit on the roof after rain?"
- "Have you noticed any spots that always seem wet?"
- "Has the building had any settling or structural work done?"
- "Has any HVAC or rooftop equipment been added or moved recently?"

### Severity ratings for ponding

| Severity | Description |
|---|---|
| Monitor | Light ponding that drains within 48 hours; faint dirt rings; no biological growth |
| Maintenance Needed | Persistent ponding that drains slowly; visible dirt rings; clear correlation with maintenance items (clogged drain, debris dam) |
| Repair Recommended | Chronic ponding consistently lasting beyond 48 hours; visible biological growth and accelerated wear in pond areas; root cause not addressable through simple maintenance |
| Urgent / Escalate | Severe ponding that essentially never drains; suspected structural deflection; depths approaching or exceeding manufacturer warranty limits; risk of overflow drainage failure |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '5'
);

-- Part 2 / Ch 16 / Sec 6: The Ponding Conversation with Customers
UPDATE sections SET
  content_markdown = $mfst$Ponding is often the first time a customer hears that their flat roof has a real problem. Reps need to handle the conversation well.

### What customers commonly believe (and what's accurate)

- **"My flat roof is supposed to be flat, so water sitting on it is normal."** Partially correct. Some water briefly is normal. Persistent water is not. Most customers don't know this distinction.
- **"The roof was like this when I bought the building."** Often true. Inherited ponding is common. The fact that it's pre-existing doesn't make it acceptable; it just shifts the responsibility for addressing it.
- **"Other contractors told me it was fine."** Sometimes true; sometimes a contractor wasn't honest. Reps shouldn't dismiss the prior contractor without evidence; reps should explain what *they* observed and why.
- **"Will adding a coating fix the ponding?"** No. A coating doesn't add slope. (See Chapter 3 and Chapter 9.) The only way to fix ponding through new work is SPF (which can be tapered — Chapter 10), tapered insulation as part of a replacement or recover, or structural drainage modifications. Coatings can be applied over ponding *if* the ponding is acceptable per the coating manufacturer's terms, but the coating doesn't make problematic ponding go away.
- **"Will the warranty cover damage from ponding?"** Probably not. Most manufacturer warranties limit or exclude ponding-related damage. (See Chapter 3 and Chapter 9.)

### Sample customer language

> "Some water sitting on a flat roof briefly after rain is normal — that's just how flat roofs work, since they're not built to shed water as quickly as a sloped roof. The question is how long it sits. The industry standard is 48 hours. After that, it's not just water; it's wear. We documented [specific ponding findings] on your roof, which is past the 48-hour line. Here's what that means for your roof and your options."

### When to recommend SPF specifically because of ponding

SPF is the only commonly-installed flat-roof system that can correct slope through tapered application during installation. (See Chapter 10.) When a roof's ponding is significant enough to drive the recommendation, SPF should be in the conversation as one of the real options — alongside replacement with tapered insulation, or modifications to the existing drainage.

### When to recommend coating despite ponding

This requires honesty. A roof with light, transient ponding *may* qualify for silicone restoration if the substrate is sound, the ponding is within manufacturer-allowed tolerances, and the roof is otherwise in qualifying condition. A roof with chronic problematic ponding does *not* qualify. (See Chapter 3, Section 13, and Chapter 13.)

### When to walk away from a ponding-related project

Sometimes a customer wants restoration on a roof with disqualifying ponding. The honest answer is no — even when the customer pushes back. Section 7 of Chapter 13 covers this conversation pattern.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '6'
);

-- Part 2 / Ch 16 / Sec 7: Drainage Inspection Across Flat-Roof Systems
UPDATE sections SET
  content_markdown = $mfst$The drainage inspection adapts slightly across the systems USA Flat Roof works on.

### TPO (Chapter 2) and PVC (Chapter 5)
- Inspect every drain ring; look for rust, lifting, or sealant failure
- Inspect every scupper; check the through-wall flashing
- Inspect overflow drainage; confirm it's present and clear
- Document ponding extent and ponding ring patterns

### Modified Bitumen (Chapter 6)
- Same as TPO/PVC, plus:
- Note any granule loss patterns concentrated in ponding areas
- Note any blistering in ponding areas (moisture entrapment indicator)

### BUR (Chapter 9)
- Same drainage inspection as above
- Note that gravel migration toward drains is normal but excessive accumulation suggests poor drainage upstream
- Note any aluminum or acrylic coating wear concentrated in ponding areas (older BUR with reflective coating)

### SPF (Chapter 10)
- Inspect taper if SPF was originally applied as ponding correction; confirm slope is still functioning
- Inspect topcoat in ponding areas (typically the first place topcoat thins or fails)
- Drains and scuppers as standard

### Silicone-Coated Substrates (Chapter 3)
- Inspect coating in ponding areas (typically shows accelerated wear)
- Confirm whether the original substrate qualified for coating despite the ponding (verify against manufacturer terms)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '7'
);

-- Part 2 / Ch 16 / Sec 8: Common Drainage and Ponding Mistakes
UPDATE sections SET
  content_markdown = $mfst$### Mistakes by reps

- Treating "the roof drains fine" as a customer report rather than verifying with inspection
- Skipping the overflow drainage check
- Failing to document ponding evidence on dry-day inspections (no chalk outlines, no ponding ring photos)
- Recommending coating restoration on chronically ponded roofs (the textbook ethics failure from Chapter 3)
- Quoting recover or replacement scope without addressing the underlying ponding cause
- Confusing acceptable ponding (under 48 hours) with problematic ponding
- Telling customers "all flat roofs pond" — accurate only for brief ponding, misleading for chronic ponding
- Ignoring drains and scuppers during inspection because "they look fine"

### Mistakes by customers (worth flagging)

- Allowing drains to clog with debris
- Adding rooftop equipment that obstructs drainage paths
- Removing or covering overflow drains during renovations
- Assuming a previous contractor's "no problem here" assessment is accurate
- Believing a coating will fix ponding$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '8'
);

-- Part 2 / Ch 16 / Sec 9: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Opening on a commercial inspection where drainage is part of the focus

> "Drainage is one of the things I'm going to look at carefully. I'll check every drain and scupper, document any standing water or ponding rings, and confirm your overflow drainage is in place and clear. Drainage drives a lot of how flat roofs perform — sometimes more than the membrane itself."

### When ponding is documented

> "I want to walk you through what I'm seeing. There are dirt rings in [areas] that show water has been sitting in those spots beyond what's normal. The industry standard for acceptable ponding is 48 hours; what we're seeing here is past that. Here's what that means for your roof and what your options are going forward."

### When the customer wants restoration on a chronically ponded roof

> "I'd love to put restoration on the table for you, but I have to be straight: with the ponding we documented, restoration isn't the right call. A silicone coating doesn't add slope, and applying one on a chronically ponded roof would fail before the warranty period and wouldn't be supported by the manufacturer. The honest options for this roof are SPF, which can correct slope during application, or replacement with tapered insulation. Both are bigger investments than coating; both actually solve the underlying problem."

### When the customer reports the ponding is "always been like that"

> "That's helpful to know — it tells me this isn't a recent failure but a long-standing issue from the original construction or a settlement pattern that developed over time. The fact that it's been like this doesn't mean it's harmless; it usually means the roof above it has been aging faster than the rest of the system. We can document the current condition and talk about how to address the slope as part of any future scope, or maintain it as-is with eyes open about the trade-offs."

### When the customer is comparing your proposal with one that ignores ponding

> "If another contractor's proposal doesn't address the ponding, I'd ask them how the new system handles the standing water. The membrane choice matters less than the slope. If the proposal is restoration over ponded areas without correction, the warranty likely won't cover it. If it's TPO overlay without tapered insulation, you're going to ponder over ponded areas. We're glad to walk through the comparison with you."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '9'
);

-- Part 2 / Ch 16 / Sec 10: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Severe ponding suggesting structural deflection
- Suspected structural settlement or deck deflection driving ponding
- Overflow drainage missing or non-functional
- Ponding deep enough to suggest possible structural load concerns
- Drains or scuppers appearing structurally damaged
- Customer requests scope (especially restoration coating) on a chronically ponded roof
- Ponding correction project requiring tapered insulation design or SPF taper specification
- Code or jurisdictional questions about overflow provisions
- Solar array on a ponded roof requiring coordination
- Suspected hail or storm damage with insurance involvement
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '10'
);

-- Part 2 / Ch 16 / Sec 11: Company Method Box
UPDATE sections SET
  content_markdown = $mfst$> **[COMPANY POLICY — to be customized by USA Flat Roof]**
>
> - Our standard drainage inspection scope across systems: [placeholder]
> - Our position on documenting ponding evidence (chalk outlines, photos, severity ratings): [placeholder]
> - Our scope for ponding correction projects (SPF taper, tapered insulation in replacement): [placeholder]
> - Our position on restoration coatings over ponded substrates: [placeholder]
> - Our scope on residential gutter work and partner relationships: [placeholder]
> - Our position on overflow drainage when missing or inadequate: [placeholder]
> - Our escalation rules and partner relationships for structural drainage assessment: [placeholder]
> - Our standard customer communication language for ponding findings: [placeholder]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '11'
);

-- Part 2 / Ch 16 / Sec 12: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They treat "all flat roofs pond" as universally acceptable, when the standard is 48 hours.
- They miss documenting ponding on dry days because the water isn't currently visible.
- They skip the overflow drainage check because the primary drain "looks fine."
- They quote restoration coatings over chronically ponded roofs without recognizing the disqualifying condition.
- They confuse coating "tolerance" of ponding with coating "fixing" ponding — they're different things.
- They recommend SPF as the answer for every ponding situation without considering whether replacement with tapered insulation is more appropriate.
- They downplay ponding because "the customer's other contractor said it was fine."

**Discussion questions for group training**
- A property manager says the roof "always had that puddle." How do you respond?
- A customer wants to compare your SPF proposal against another contractor's silicone restoration on a chronically ponded roof. Walk through the comparison.
- Why is overflow drainage so important, and why do customers usually not know about it?
- What's the 30-second answer to "isn't water on a flat roof normal?"
- A customer wants the cheapest option to address ponding. What are you actually choosing between?

**Field exercises**
- Pair up. Walk a real flat-roof commercial building together. Identify and photograph drainage components. Document ponding evidence using chalk outlines.
- Review three sets of inspection photos. For each, identify whether ponding evidence was documented adequately.
- Practice the chronically-ponded-restoration-decline conversation in role-play.
- Walk through the residential gutter inspection on a real home. Identify all the roof-side effects of any gutter problems found.

**What the manager should test verbally**
- Distinguish acceptable ponding from problematic ponding (the 48-hour standard).
- Name the three drainage approaches on commercial flat roofs (internal drains, scuppers, edge drainage) and the role of overflow.
- Explain why coating doesn't fix ponding.
- Walk through the ponding-related disqualifying condition for restoration.
- State five things a rep must not promise about drainage and ponding.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '12'
);

-- Part 2 / Ch 16 / Sec 13: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Acceptable ponding** — water that drains within 48 hours of rain stopping (industry standard).
- **Chronic ponding** — water that consistently persists beyond 48 hours.
- **Drain ring (clamping ring)** — metal ring that clamps a flat-roof membrane to a roof drain.
- **Edge drainage** — flat-roof drainage off an unparapeted edge into a gutter.
- **Internal drain** — drain located within the roof field, with piping carrying water through the building's interior.
- **Overflow drain (overflow scupper)** — secondary drainage at a higher elevation than the primary, intended to handle water if the primary clogs.
- **Ponding ring** — dirt accumulation pattern marking where water has been sitting on the roof.
- **Ponding water** — water remaining on a roof beyond the time intended by design.
- **Primary drain** — main drainage point at the design low point of a roof area.
- **Scupper** — opening through a parapet wall for drainage.
- **Severe ponding** — water that essentially never drains; permanent low spots holding water.
- **Slope (flat-roof)** — the intentional minor slope (typically 1/4 inch per foot or less) built into flat-roof design to direct water toward drainage.
- **Tapered insulation** — insulation manufactured or installed with thickness variation to create slope; alternative to SPF taper for ponding correction.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '13'
);

-- Part 2 / Ch 16 / Sec 14: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$Drainage drives roof performance more than almost any other single factor. On residential steep-slope roofs, gutters and downspouts handle drainage once water reaches the eave; reps need enough literacy to discuss findings during inspections, recognize when gutter problems are affecting the roof, and recommend appropriate scope. On commercial flat roofs, drainage is engineered through slope, drains, scuppers, and overflow provisions; reps need depth on these because most ponding-related decisions happen here. Ponding water is the central topic: water that drains within 48 hours of rain stopping is acceptable; water that persists longer is problematic. Ponding causes accelerated membrane aging, biological growth, structural concerns at extreme depths, warranty disqualification, and restoration ineligibility. Reps should document ponding evidence on dry days through dirt rings, biological patterns, and chalk-outlined extent; verify overflow drainage is present and functional; recognize when SPF is the right answer because of its unique slope-correction capability; and refuse to propose restoration coatings on chronically ponded roofs even when customers prefer that option. The "48-hour standard" message is one of the more useful pieces of customer education a rep can deliver — it converts a fuzzy customer concept ("water sits there sometimes") into a concrete framework that shapes the recommendation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '14'
);

-- Part 2 / Ch 16 / Sec 15: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The industry standard threshold for acceptable ponding water on a flat roof is:
A. Up to 24 hours after rain stops
B. Up to 48 hours after rain stops
C. Up to one week after rain stops
D. There is no standard

**2. (Beginner)** Which of the following is NOT a flat-roof drainage approach?
A. Internal drains
B. Scuppers
C. Edge drainage
D. Capillary action

**3. (Beginner)** An "overflow drain" is:
A. The primary drain on the roof
B. A secondary drainage point at a higher elevation, intended to handle water if the primary clogs
C. A type of gutter
D. A coating system

**4. (Beginner)** A "ponding ring" is:
A. A type of structural support
B. The dirt accumulation pattern marking where water has been sitting
C. A new drainage device
D. A warranty term

**5. (Intermediate)** A silicone restoration coating applied to a chronically ponded roof will:
A. Fix the ponding by adding slope
B. Not fix the ponding — coatings don't add slope; the coating will likely fail over the ponded area
C. Last longer than on dry areas
D. Strengthen the roof structure

**6. (Intermediate)** Which roof system can correct ponding by tapering material thickness during application?
A. TPO single-ply
B. SPF
C. Modified bitumen
D. Silicone coating

**7. (Intermediate)** A property manager reports water "always sits in that one spot" on a flat roof. The most appropriate first response is:
A. Tell the customer water is normal on flat roofs
B. Inspect the area, document ponding evidence, and verify drainage and overflow conditions
C. Quote a coating immediately
D. Recommend full replacement immediately

**8. (Intermediate)** What's the most likely cause of ponding on a 30-year-old commercial flat roof that originally drained well?
A. Climate change
B. Original construction defect
C. Building settlement, deck deflection, or insulation compression over time
D. Recent paint job

**9. (Advanced)** A customer wants the cheapest option to address chronic ponding. The most honest options on the table are:
A. Silicone restoration coating only
B. SPF (with taper) or replacement with tapered insulation; both address the slope, neither is the cheapest by total cost but both actually solve the problem
C. Add another drain anywhere on the roof
D. Apply two coats of acrylic coating

**10. (Advanced)** A customer dismisses ponding concerns because "another contractor said it was fine." The most appropriate response is:
A. Defer to the other contractor's assessment
B. Tell the customer the other contractor was wrong
C. Document what you observed, explain the 48-hour standard and the implications for warranty, restoration eligibility, and aging, and let the customer compare contractor assessments themselves
D. Decline to provide a proposal

---

### Answer Key

1. **B — Up to 48 hours.** Industry standard from Section 5.
2. **D — Capillary action.** Not a drainage approach; the others are real approaches.
3. **B — A secondary drainage point at higher elevation.** Standard definition.
4. **B — The dirt accumulation pattern.** Standard inspection indicator.
5. **B — Won't fix the ponding; coating will likely fail over the ponded area.** Coatings don't add slope. The textbook ethics failure on coatings (Chapter 3) involves applying them anyway.
6. **B — SPF.** Unique among standard flat-roof systems for slope correction through tapered application.
7. **B — Inspect, document, and verify drainage and overflow conditions.** Standard inspection response. Telling the customer water is normal (A) understates; quoting coating immediately (C) skips inspection; recommending replacement immediately (D) is unsupported.
8. **C — Building settlement, deck deflection, or insulation compression over time.** Common causes from Section 5. Climate change (A) and recent paint (D) aren't drivers; original construction defect (B) is sometimes the cause but less likely than settlement on a 30-year-old roof that originally drained well.
9. **B — SPF or replacement with tapered insulation.** Both address slope. Coating alone (A, D) doesn't fix slope. Adding a drain anywhere (C) doesn't fix slope and likely makes things worse if not properly placed.
10. **C — Document, explain, and let the customer compare.** Honest framework. Deferring (A) abandons the rep's responsibility. Bashing the other contractor (B) is unprofessional. Declining the proposal (D) abandons the customer.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '15'
);

-- Part 2 / Ch 16 / Sec 16: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's actual drainage inspection scope?
- [ ] Matches USA Flat Roof's position on documenting ponding (chalk outlines, photos, severity ratings)?
- [ ] Are the disqualifying conditions for restoration over ponded substrates aligned with our actual proposal practice?
- [ ] Is the SPF positioning as ponding correction option aligned with Chapter 10?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 2 (TPO), 3 (Silicone), 5 (PVC), 6 (Modified Bitumen), 9 (BUR), 10 (SPF), 12 (Inspections), 13 (Decision Framework)?
- [ ] Does the residential gutter section reflect USA Flat Roof's actual gutter scope?

**Technical Items to Verify Before Publishing**

- 48-hour ponding standard: confirm against current manufacturer warranty terms for the products USA Flat Roof installs.
- Overflow drainage requirements: verify against California building code and local jurisdiction.
- Tapered insulation scope: confirm USA Flat Roof's standard offerings and pricing.
- SPF taper for ponding correction: confirm against Chapter 10 specifics.
- Gutter work scope: confirm USA Flat Roof's actual scope and partner relationships.
- Cross-references to Chapters 2, 3, 5, 6, 9, 10, 12, 13: verify drainage and ponding language is consistent across chapters.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 16 AND s.section_number = '16'
);

-- Part 2 / Ch 17 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Recognize each commercial flat-roof system on sight and distinguish it from look-alike systems.
2. Identify the visual, structural, and inspection clues that point to each system.
3. Apply a consistent identification process during commercial inspections regardless of which system is on the roof.
4. Use cross-system recognition vocabulary fluently in conversations with customers, property managers, and production teams.
5. Recognize when system identification is uncertain and escalate appropriately.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '1'
);

-- Part 2 / Ch 17 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$A commercial roof rep arrives at a property and the first question — before any recommendation, before any proposal, before any conversation about scope — is *what's on this roof?*

Get that wrong and everything that follows is wrong. Recommend silicone restoration on what turns out to be EPDM. Propose TPO overlay on a substrate that's actually PVC. Quote pitch pan repair on a roof that doesn't have any. The system identification is the foundation of every commercial conversation.

This chapter is the cross-system recognition reference that ties together Chapters 2 (TPO), 3 (Silicone Coatings), 5 (PVC), 6 (Modified Bitumen), 7 (Acrylic Coatings), 9 (BUR), and 10 (SPF). Each of those chapters covers identification within its own system; this chapter covers identification *across* the systems so reps can quickly orient themselves on any commercial flat roof regardless of what they encounter.

For new reps: this is the orientation chapter that compresses the commercial landscape into one place. Read it after the system chapters and the recognition skills become consolidated.

For experienced reps: this is the cross-system refresher and the place to send a newer rep when system identification is the issue.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '2'
);

-- Part 2 / Ch 17 / Sec 3: The Commercial Flat-Roof Landscape
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof works on the following commercial flat-roof systems. Reps will encounter all of them on inspections, even on systems USA Flat Roof doesn't install new (BUR) or doesn't typically lead with (acrylic coatings).

### Systems USA Flat Roof installs

- **TPO** — single-ply thermoplastic, hot-air welded; flagship USA Flat Roof commercial system; 60-mil mechanically attached standard
- **PVC** — single-ply thermoplastic, hot-air welded; premium alternative to TPO; chemical-resistant
- **Modified Bitumen (Self-Adhered)** — multi-ply asphalt-based with polymer modifiers; only self-adhered (peel-and-stick) installed by USA Flat Roof
- **Silicone Coatings** — liquid-applied restoration; single high-build coat standard
- **SPF** — sprayed polyurethane foam with topcoat; ponding correction, BUR recover, insulation upgrade

### Systems USA Flat Roof works on but does not install new

- **BUR (Built-Up Roofing)** — multi-ply asphalt-and-gravel; legacy system; USA Flat Roof restores, recovers, or replaces but does not install new BUR
- **Acrylic Coatings** — recognized for what they are; not typically proposed as a primary product

### Systems USA Flat Roof does not regularly work on

- **EPDM (Ethylene Propylene Diene Monomer)** — single-ply rubber membrane; common on older commercial buildings nationally but a smaller share of NorCal commercial; reps need to recognize it but USA Flat Roof's offerings on EPDM substrates are limited

This chapter focuses primarily on the systems USA Flat Roof installs or works on. EPDM is covered briefly here since reps will encounter it in the field even if they're not proposing work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '3'
);

-- Part 2 / Ch 17 / Sec 4: The Quick Recognition Decision Tree
UPDATE sections SET
  content_markdown = $mfst$When a rep first walks onto a commercial roof, a fast structured look at four characteristics narrows the system identification quickly.

### Step 1: Is the surface white/light, dark, or gravel?

- **White/light surface** → likely TPO, PVC, silicone-coated, acrylic-coated, or SPF (most NorCal commercial single-ply and restoration is white for Title 24 reasons)
- **Dark surface (black/gray asphalt)** → likely BUR (smooth-surfaced), modified bitumen (smooth or granule-surfaced), EPDM, or aged uncoated asphalt-based system
- **Gravel surface** → almost certainly BUR (or aged tar-and-gravel)

### Step 2: Are seams visible, and how do they appear?

- **Welded seams (clean lines, no asphalt squeeze-out)** → TPO or PVC
- **Asphalt-bonded seams (visible black asphalt at seams)** → modified bitumen (torch-down or self-adhered) or BUR
- **Glued/taped seams (cleaner than asphalt but no welding)** → EPDM
- **No seams visible (continuous surface, brush/spray texture)** → silicone or acrylic coating, or SPF

### Step 3: What's the surface texture?

- **Factory-uniform smooth finish** → single-ply membrane (TPO, PVC, EPDM)
- **Granular surface (looks like rolled shingle)** → modified bitumen with cap sheet
- **Brush/spray/roller texture** → coating only
- **Orange-peel texture** → SPF
- **Embedded gravel or smooth asphalt cap** → BUR

### Step 4: What's the edge/termination appearance?

- **Membrane terminating cleanly at parapet flashing or termination bar** → single-ply or modified bitumen
- **Coating wrapping continuously over flashings, parapets, and details** → silicone or acrylic coating, or SPF
- **Visible foam thickness at terminations** → SPF
- **Multi-ply layered cross-section visible at edges** → BUR (and to a lesser extent modified bitumen)

These four steps usually narrow the answer to one or two possibilities. The remaining sections in this chapter deepen each system's identifying features for the close calls.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '4'
);

-- Part 2 / Ch 17 / Sec 5: System-by-System Recognition Detail
UPDATE sections SET
  content_markdown = $mfst$### TPO (Chapter 2)

**Big-picture look:** large white sheets with regular welded seams running long-direction across the roof; mechanically attached systems show fastener bumps along seams; smooth factory finish.

**Most reliable identification clues:**
- Welded seams with matte weld bead
- Surface firmer to the touch than PVC; less slick
- Fastener bumps under the membrane along seams (mechanically attached systems)
- Standard 60-mil thickness on USA Flat Roof installs
- Visible at parapet wraps where membrane terminates against termination bar

**Common confusion:** PVC. The two look nearly identical from a distance. Don't certify by appearance alone — see Section 6.

**System chapter:** 2

### PVC (Chapter 5)

**Big-picture look:** very similar to TPO at a glance — white sheets, welded seams. Premium positioning typically associated with restaurant, kitchen, hospital, or industrial buildings with chemical/grease exposure.

**Most reliable identification clues:**
- Welded seams with slightly glossier weld bead than TPO
- Surface slightly more flexible and slick to the touch than TPO
- Fastener bumps along seams on mechanically attached systems
- Documentation, building use (restaurants, kitchens, food service)
- Plasticizer migration on aged systems creates stiffening — visible on roofs 15+ years old

**Common confusion:** TPO. The reliable answer is documentation, not appearance.

**System chapter:** 5

### EPDM (Reference)

**Big-picture look:** large dark sheets (almost always **black**) with clean glued or taped seams; rubbery matte surface; common on commercial roofs from the 1980s and 1990s.

**Most reliable identification clues:**
- Black color (the most reliable single indicator — TPO and PVC are almost always white in NorCal commercial)
- Glued or taped seams, not welded
- Rubbery matte surface texture
- Often shows surface chalking or fading on aged installations
- Sometimes white or other colors, but black is far more common

**Common confusion:** Modified bitumen smooth-surfaced, BUR smooth-surfaced. Tap test (rubber vs asphalt) is the most reliable distinction.

**Notes for USA Flat Roof reps:** EPDM is a smaller share of NorCal commercial than nationally, but reps will encounter it. USA Flat Roof's work on EPDM substrates is limited; reps should escalate any EPDM-related proposal scope to senior estimator review.

### Modified Bitumen — Self-Adhered (Chapter 6)

**Big-picture look:** rolled appearance with seams every 36 inches or so, granule-surfaced (most common, looking like rolled shingle) or smooth-surfaced (often coated later), no asphalt squeeze-out at seams.

**Most reliable identification clues:**
- Granule surface on cap sheet (most common)
- Cleaner seam appearance than torch-down or hot-mopped (no asphalt bead at seams)
- Multi-ply construction visible at edges
- No factory-uniform single-ply look; visible texture and roll pattern

**Common confusion:** Torch-down or hot-mopped modified bitumen (different installation method, similar appearance), BUR (multi-ply asphalt but typically gravel-surfaced).

**Distinguishing self-adhered from torch-down or hot-mopped:** self-adhered has cleaner seams without asphalt squeeze-out. Torch-down often shows visible asphalt bead and possible scorch marks at edges. Hot-mopped shows kettle-asphalt residue and drips. **USA Flat Roof installs only self-adhered**, so identifying the original installation method on existing roofs matters for any like-for-like replacement conversation.

**System chapter:** 6

### BUR — Built-Up Roofing (Chapter 9)

**Big-picture look:** gravel surface (most common, "tar and gravel") or smooth asphalt cap; visible multi-ply construction at edges; common on older commercial buildings (1950s–1990s).

**Most reliable identification clues:**
- Gravel surface (most common older installations)
- Multi-ply layered cross-section visible at edges, terminations, or cut areas
- Smooth asphalt cap on smooth-surfaced installations
- Often coated with aluminum, acrylic, or silicone on aged installations
- Building age (1950s–1990s installation era for original BUR)

**Common confusion:** Modified bitumen (multi-ply but typically not gravel-surfaced; cap sheet is granular or smooth). Coated BUR can look like silicone restoration over a single-ply if rep doesn't inspect edges.

**Layer count is the central question:** USA Flat Roof's recommendation framework on BUR (Chapter 9) depends on whether the roof is single-layer or multi-layer. Reps verify layer count by inspecting visible cross-sections at edges and terminations. When uncertain, escalate.

**System chapter:** 9

### SPF — Spray Polyurethane Foam (Chapter 10)

**Big-picture look:** continuous monolithic surface with characteristic orange-peel texture, no welded seams, no fastener rows; topcoat is most commonly white silicone (sometimes acrylic); visible foam thickness at terminations.

**Most reliable identification clues:**
- Orange-peel texture visible through topcoat (most reliable single indicator)
- Continuous coverage with no seams or fasteners
- Visible foam thickness at parapet bases, equipment curbs, drains
- Tapered slope visible at drainage points (on installations done as ponding correction)
- Building use sometimes points to it: cold storage, refrigerated facilities, irregular substrates

**Common confusion:** Silicone-coated single-ply (TPO, PVC), silicone-coated BUR, silicone-coated modified bitumen. The orange-peel texture is the distinguishing feature. Coating-only systems show smoother surface texture; the coating is thinner at edges with no foam thickness visible.

**System chapter:** 10

### Silicone Coatings (Chapter 3)

**Big-picture look:** continuous monolithic painted-looking surface; brush, roller, or spray texture; wraps continuously over flashings, parapets, and most penetrations; substrate sometimes visible at edges, drains, or worn areas.

**Most reliable identification clues:**
- Brush/spray/roller texture (not factory-uniform)
- Continuous wrap over details — no separate flashing transitions
- Often shows overspray or coating bleed onto adjacent surfaces (wall caps, equipment bases)
- Substrate visible at damaged or exposed areas tells reps what's underneath the coating
- Slightly slick rubbery feel when cured (limited reliability versus acrylic)

**Common confusion:** Acrylic coatings (very similar in appearance), SPF with silicone topcoat (orange-peel texture is the distinguisher).

**Critical inspection point:** identifying the substrate underneath the coating matters for any future scope. The coating is one layer; what's under it (TPO, modified bitumen, BUR) determines future restoration or replacement options.

**System chapter:** 3

### Acrylic Coatings (Chapter 7)

**Big-picture look:** very similar to silicone coatings — continuous painted-looking surface, brush/spray texture, continuous wrap over details.

**Most reliable identification clues:**
- Visual distinction from silicone is unreliable
- Touch test: cured acrylic feels more like cured paint than the slightly rubbery feel of silicone (limited reliability)
- Performance pattern: acrylic tends to wear faster in ponded areas than silicone
- Documentation is the only reliable answer

**Common confusion:** Silicone coatings. Reps should not certify coating chemistry by appearance alone.

**Notes for USA Flat Roof reps:** USA Flat Roof leads with silicone for restoration. Identifying an existing acrylic coating affects future scope (silicone over aged acrylic requires compatibility verification). Escalate any recoat or restoration proposal on an existing acrylic-coated roof.

**System chapter:** 7

### Aluminum-Pigmented Asphalt Coatings (recognition only)

Reps will encounter older BUR and modified bitumen roofs with reflective aluminum-pigmented asphalt coatings. These are an older approach to extending life of asphalt-based systems.

**Identification clues:**
- Metallic silver appearance (not white)
- Often patchy coverage from prior touch-up applications
- Underlying gravel or asphalt substrate visible in some areas

**Notes:** aluminum coatings are typically a 2–5 year life-extension product, not a real restoration system. They're recognized by reps but not proposed as a primary USA Flat Roof product. Roofs with aluminum coatings are evaluated based on the underlying substrate, not the coating.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '5'
);

-- Part 2 / Ch 17 / Sec 6: The Hard Calls — TPO vs PVC and Coating-Chemistry Identification
UPDATE sections SET
  content_markdown = $mfst$Two recognition challenges come up repeatedly. Reps need to handle both honestly.

### TPO vs PVC

The visual differences are subtle and not fully reliable:

| Indicator | TPO | PVC |
|---|---|---|
| Surface feel | Firmer, less slick | Slightly more flexible, slick |
| Weld bead | Matte | Slightly glossier |
| Aging pattern (15+ years) | UV degradation, seam issues | Plasticizer migration, stiffening |

**The honest framework:** documentation is the reliable answer. When documentation isn't available:

- Note the visual indicators
- Document as "appears to be TPO" or "appears to be PVC" with the supporting evidence
- Escalate when product type drives the proposal scope (recover vs replacement, coating compatibility, warranty matching)
- Production team can confirm with solvent testing if needed

**What reps must NOT do:** certify TPO vs PVC by appearance alone in writing, or quote work that requires correct identification (e.g., like-for-like replacement, warranty-tied restoration) without confirmation.

### Silicone vs Acrylic Coating

Same fundamental issue: visual distinction is unreliable.

- Document the coating's existence and condition
- Note any indicators that point to one or the other
- Ask the customer for documentation
- Escalate any recoat or restoration scope on a previously coated roof for substrate and chemistry compatibility review

**What reps must NOT do:** propose silicone over an existing acrylic-coated roof without compatibility verification, or vice versa.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '6'
);

-- Part 2 / Ch 17 / Sec 7: Substrate Detective Work on Coated and Recovered Roofs
UPDATE sections SET
  content_markdown = $mfst$A significant share of NorCal commercial roofs are not in their original condition — they've been coated, recovered, or modified over decades. Reps need to work backward to figure out what's actually there.

### Common stack patterns

- **Original BUR with aluminum or acrylic coating** — older buildings; coating may be aged out; substrate is what matters for any future scope
- **Original BUR recovered with TPO overlay (with fanfold or ISO board)** — common on USA Flat Roof's own past projects; identifiable by current TPO surface plus knowledge of the building's age
- **Original BUR with SPF over** — common on older buildings where the gravel was swept and SPF was applied; orange-peel texture visible
- **Original modified bitumen with silicone coating** — common restoration pattern; coating wraps over details, but cap sheet visible at edges
- **Original TPO with silicone coating refresh** — newer pattern; coating covers an aging single-ply
- **Multiple recoats over decades** — older systems may have been coated 2–4 times; each layer adds to the assembly

### Where to look for substrate clues

- **Edges and terminations** — often where the substrate is most visible
- **Drains and scuppers** — coatings sometimes thin or wear at drains, exposing substrate
- **Damaged or worn areas** — wherever the coating has failed locally, the substrate shows
- **Customer-provided documentation** — original construction records, prior contractor invoices, permit records
- **Prior inspection reports** — sometimes property managers have records from previous inspections

### Why substrate matters

Every recommendation depends on what's actually under the coating. Silicone restoration over silicone-coated BUR is one conversation; silicone restoration over silicone-coated EPDM is a different conversation; replacement of a multi-recovered system is a third.

> **[SALES REP BOUNDARY]** Reps document visible substrate evidence and report what they found. Definitive substrate identification on heavily coated or recovered roofs may require coring, which is a production team task — not a sales rep task.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '7'
);

-- Part 2 / Ch 17 / Sec 8: The Building-Use Lens
UPDATE sections SET
  content_markdown = $mfst$Building use often points to the roof system before the rep climbs the ladder. Reps who learn this pattern arrive on the roof with a strong prior on what they'll find.

### Strong building-use signals

- **Restaurants, commercial kitchens, food service** → likely PVC (chemical/grease resistance) or older modified bitumen; sometimes TPO with grease vent issues
- **Cold storage, refrigerated warehouses, indoor pools** → SPF possible (vapor and insulation needs); single-ply systems also common with appropriate vapor barriers
- **Hospitals, medical facilities** → often premium systems (PVC, premium TPO); higher specification standards
- **Older industrial buildings (1950s–1990s)** → BUR likely; possibly recovered or restored over the years
- **Newer commercial construction (2000s onward)** → TPO most likely; PVC for premium or grease applications
- **Tract retail, strip centers** → TPO common on newer; modified bitumen common on older
- **Multi-tenant office** → varies widely; depends on construction era

### What to do with this information

The building-use lens shapes the rep's expectations but doesn't override observation. A rep who walks onto a 1965 commercial building expecting BUR but finding TPO has just learned the roof has been replaced or recovered — useful information for the conversation. The lens is a starting point, not a conclusion.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '8'
);

-- Part 2 / Ch 17 / Sec 9: The Inspection-Stage Recognition Process
UPDATE sections SET
  content_markdown = $mfst$Reps should follow a consistent identification process at the start of every commercial inspection.

### Step 1: Pre-arrival
- Note building age and use from the address, online records, or customer information
- Apply the building-use lens to set initial expectations

### Step 2: Roof access and overview
- First impression: surface color, seam pattern, texture
- Apply the four-step decision tree from Section 4

### Step 3: Close inspection
- Confirm the system using the system-specific identification clues from Section 5
- Verify substrate on coated or recovered roofs (Section 7)
- Document the identification with photos and notes

### Step 4: Documentation
- Note the system identification with appropriate certainty language ("appears to be TPO," "confirmed by documentation as PVC," etc.)
- Note any uncertainty for follow-up
- Escalate if identification drives scope and certainty isn't possible at the rep level

### Step 5: Conversation with customer
- Confirm what the customer believes they have versus what the rep observed
- Discrepancies between customer expectation and rep observation are useful conversation starters and sometimes uncover valuable history (prior recovers, coatings, recent work)$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '9'
);

-- Part 2 / Ch 17 / Sec 10: Common Recognition Mistakes
UPDATE sections SET
  content_markdown = $mfst$### Mistakes by reps

- Certifying TPO vs PVC by appearance alone
- Certifying silicone vs acrylic coating by appearance alone
- Skipping substrate identification on coated roofs
- Treating all dark commercial roofs as "BUR" without checking
- Treating all white commercial roofs as "TPO" without checking
- Missing layer-count assessment on BUR-substrate roofs
- Confusing modified bitumen with BUR (multi-ply but different surface)
- Missing the orange-peel texture distinction on SPF
- Assuming a coated roof's substrate based on age alone
- Not asking the customer what they believe they have

### Mistakes by customers (worth knowing)

- Reporting their roof as "TPO" when it's actually PVC (or vice versa)
- Reporting "silicone" coating when it's actually acrylic
- Forgetting prior recover work that significantly changed the assembly
- Believing "tar and gravel" still describes a roof that has been recovered$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '10'
);

-- Part 2 / Ch 17 / Sec 11: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Opening recognition during inspection

> "Before I get into the inspection findings, let me confirm what I'm seeing. Based on the surface and the seams, this appears to be [system]. Does that match what you have records of?"

### When customer expectation and observation disagree

> "What you're describing as your roof system doesn't quite match what I'm seeing on the surface. That happens sometimes — buildings get recovered or restored over the years and the original records don't always reflect the current condition. Let me walk you through what I'm observing and we can figure out together what's actually there."

### When identification is uncertain

> "I want to be straight — the visual differences between [System A] and [System B] aren't reliable enough for me to certify which one this is just by looking. Documentation would tell us for sure. If you have any original specs, warranty papers, or prior contractor records, that would settle it. Otherwise, our production team can confirm with [solvent test / coring / further inspection] if the proposal scope depends on it."

### When the substrate matters more than the surface

> "What we're looking at on top is [coating / SPF / recover system], but what's underneath determines a lot of your options. I'm going to spend some time looking at where the substrate is exposed — at edges, drains, any worn spots. That's the part that matters for any future scope."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '11'
);

-- Part 2 / Ch 17 / Sec 12: When to Escalate
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- TPO vs PVC identification cannot be confirmed and product type drives scope
- Silicone vs acrylic coating identification cannot be confirmed and recoat or restoration scope depends on it
- Layer count on BUR cannot be confirmed visually
- Substrate identification on heavily coated or recovered roofs requires coring
- Building documentation contradicts surface observation in ways that affect scope
- EPDM-related proposal scope (limited USA Flat Roof scope on EPDM)
- Multiple recovers or recoats over decades complicating the assembly assessment
- Solar array on the roof requiring identification under PV
- Asbestos potential on pre-1980s buildings (Chapter 9)
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '12'
);

-- Part 2 / Ch 17 / Sec 13: Cross-System Quick-Reference Table
UPDATE sections SET
  content_markdown = $mfst$This is the at-a-glance reference. Reps should be able to use this in the field on any commercial inspection.

| System | Primary Color | Surface | Seams | Distinguishing Clues | USA Flat Roof Position |
|---|---|---|---|---|---|
| TPO | White | Smooth, factory finish | Welded, matte bead | Firmer feel; fastener bumps | Installs (60-mil mech-attached) |
| PVC | White | Smooth, factory finish | Welded, glossier bead | Slicker feel; plasticizer aging on older | Installs (premium) |
| EPDM | Black (almost always) | Smooth rubber | Glued or taped | Black color is the giveaway | Limited scope; escalate |
| Modified Bitumen (Self-Adhered) | Granule colors or smooth | Granular cap or smooth asphalt | Asphalt-bonded, no torch squeeze-out | Roll pattern; multi-ply | Installs (self-adhered only) |
| BUR | Gray gravel or dark asphalt | Embedded gravel or smooth asphalt | Multi-ply layered | Gravel surface; multi-ply at edges | Restores/recovers/replaces (no new install) |
| SPF | White (topcoat) | Orange-peel texture | None (monolithic) | Foam thickness at edges | Installs (3 use cases) |
| Silicone Coating | White | Brush/spray texture | None (continuous wrap) | Painted appearance | Installs (restoration) |
| Acrylic Coating | White | Brush/spray texture | None (continuous wrap) | Visually like silicone | Reference; not typically proposed |
| Aluminum Asphalt Coating | Silver/metallic | Painted over asphalt | Underlying substrate seams | Metallic appearance | Recognized only |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '13'
);

-- Part 2 / Ch 17 / Sec 14: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They certify by appearance when documentation should be the answer.
- They miss the orange-peel texture on SPF.
- They treat all white commercial as TPO.
- They miss layer count on BUR substrates.
- They skip substrate inspection on coated roofs.
- They don't apply the building-use lens before climbing the ladder.
- They confuse modified bitumen with BUR.

**Discussion questions for group training**
- A new rep arrives at a 1972 commercial building with what looks like white TPO on the surface. What questions and inspection steps should they prioritize?
- A property manager says "we have a TPO roof." The rep observes characteristics that suggest PVC. How does the rep handle the conversation?
- Walk through the four-step decision tree. Where does each step point in different scenarios?
- Why does substrate identification matter on a coated roof?
- What's the 30-second answer to "is this TPO or PVC?"

**Field exercises**
- Pair up. Visit three real commercial roofs (or review three sets of inspection photos). Apply the four-step decision tree. See where each step lands.
- Practice the "I can't certify by appearance" customer conversation in role-play.
- Walk through 10 commercial buildings of different ages and uses. Predict the system based on the building-use lens; verify on inspection.
- Review three coated roofs. Identify the substrate where exposed; predict the substrate where it's not exposed.

**What the manager should test verbally**
- The four-step decision tree for system identification.
- Distinguish TPO from PVC and what reps can and cannot certify.
- Distinguish silicone coating from SPF.
- Name the systems USA Flat Roof installs vs. works on vs. doesn't regularly work on.
- Walk through the building-use lens and what it suggests for several building types.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '14'
);

-- Part 2 / Ch 17 / Sec 15: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Building-use lens** — using the building's purpose (restaurant, cold storage, etc.) to anticipate likely roof system before inspection.
- **Cross-section inspection** — examining edges, terminations, or cut areas to assess multi-ply construction or layer count.
- **Decision tree (system identification)** — the four-step quick-recognition process: surface color, seam type, surface texture, edge/termination appearance.
- **Layer count** — number of distinct roofing systems on a building; central question on BUR substrates.
- **Monolithic** — single continuous seamless layer (characteristic of coatings and SPF).
- **Recover (overlay)** — installation of a new roof system over an existing one.
- **Stack pattern** — typical sequence of original system + recovers/coatings over time.
- **Substrate** — the existing roof beneath a coating, recover, or new system.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '15'
);

-- Part 2 / Ch 17 / Sec 16: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$The first question on every commercial inspection is what's on the roof. Get that wrong and every recommendation is wrong. The four-step decision tree (surface color, seam type, surface texture, edge appearance) narrows the answer quickly. System-specific identification clues from Chapters 2–10 confirm the recognition. Hard calls — TPO vs PVC, silicone vs acrylic — are honest about the limits of visual identification: documentation is the reliable answer, not appearance. Substrate detective work matters on coated and recovered roofs because the substrate determines future scope options. The building-use lens (restaurants suggest PVC, cold storage suggests SPF, older industrial suggests BUR) sets initial expectations the rep verifies on inspection. Reps document what they observe with appropriate certainty language and escalate when identification drives proposal scope and visual identification isn't reliable enough. The cross-system recognition vocabulary is the foundation for every commercial conversation that follows; without it, every other chapter in this book operates on shaky ground.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '16'
);

-- Part 2 / Ch 17 / Sec 17: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The first question to answer on any commercial roof inspection is:
A. How much will the work cost?
B. What roof system is on the building?
C. Whether the customer has insurance
D. Whether the customer is the property owner

**2. (Beginner)** A white commercial roof with welded seams is most likely:
A. EPDM
B. TPO or PVC
C. BUR
D. Wood shake

**3. (Beginner)** A black single-ply commercial roof with glued or taped seams is most likely:
A. TPO
B. PVC
C. EPDM
D. SPF

**4. (Beginner)** A flat commercial roof with characteristic orange-peel surface texture is:
A. TPO
B. PVC
C. Silicone coating only
D. SPF

**5. (Intermediate)** A rep is asked to confirm whether a roof is TPO or PVC. There is no documentation. The most appropriate response is:
A. Confirm TPO based on the white color
B. Confirm PVC because the surface feels slick
C. Document the visual indicators and note that product type cannot be certified without documentation
D. Defer to the customer's belief about the roof type

**6. (Intermediate)** The single most reliable way to identify SPF versus a silicone-coated single-ply roof is:
A. The color of the topcoat
B. The orange-peel texture characteristic of foam
C. The age of the building
D. The cost of the original installation

**7. (Intermediate)** A property manager says "we have TPO." On inspection, the rep observes characteristics suggesting PVC. The most appropriate response is:
A. Defer to the property manager's information
B. Document what was observed, ask for any product documentation, and escalate if scope depends on certainty
C. Tell the property manager they're wrong
D. Quote work as TPO regardless of observation

**8. (Intermediate)** On a heavily coated commercial roof, the most important identification step is:
A. Identifying the coating chemistry
B. Identifying the substrate underneath the coating
C. Counting the gravel
D. Measuring the roof slope

**9. (Advanced)** A 1968 commercial building has a white-coated flat roof. What inspection priorities does the building age create?
A. None — building age doesn't affect inspection
B. Asbestos potential in the underlying system, layer count assessment, and substrate identification under the coating
C. Confirming the warranty is current
D. Requiring drone inspection only

**10. (Advanced)** A restaurant building with significant kitchen exhaust shows a white welded-seam membrane that has held up well around grease vents. The system is most likely:
A. TPO
B. PVC
C. EPDM
D. Modified bitumen

---

### Answer Key

1. **B — What roof system is on the building.** Foundation of every commercial conversation.
2. **B — TPO or PVC.** Both are white welded-seam single-ply systems. EPDM (A) is almost always black with non-welded seams; BUR (C) is gravel or smooth asphalt; wood shake (D) is residential.
3. **C — EPDM.** Black color and non-welded seams are EPDM signatures.
4. **D — SPF.** Orange-peel is the SPF distinguisher.
5. **C — Document the visual indicators and note that product type cannot be certified without documentation.** This is the honest framework. Color (A) and feel (B) are unreliable; deferring (D) without observation isn't certification.
6. **B — The orange-peel texture characteristic of foam.** Most reliable single indicator.
7. **B — Document, ask for documentation, and escalate if scope depends on certainty.** Honest response. Deferring (A) without observation, dismissing the manager (C), and quoting incorrectly (D) all create problems.
8. **B — Identifying the substrate underneath the coating.** Substrate determines future scope. Coating chemistry (A) matters but less than substrate; (C) and (D) aren't relevant here.
9. **B — Asbestos potential, layer count, and substrate identification.** All three are critical for pre-1980s buildings (per Chapter 9).
10. **B — PVC.** Restaurant + grease + held up well = PVC's chemical/grease resistance is the technical reason it was specified.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '17'
);

-- Part 2 / Ch 17 / Sec 18: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's commercial market and the systems we encounter?
- [ ] Are the identification clues practical for field use?
- [ ] Does the four-step decision tree match how experienced reps actually identify systems?
- [ ] Are escalation triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapters 2 (TPO), 3 (Silicone), 5 (PVC), 6 (Modified Bitumen), 7 (Acrylic), 9 (BUR), 10 (SPF), 12 (Inspections), 13 (Decision Framework)?
- [ ] Does the building-use lens reflect actual NorCal commercial patterns?
- [ ] Is the EPDM coverage appropriate (recognition only, limited USA Flat Roof scope)?

**Technical Items to Verify Before Publishing**

- Building-use lens: confirm the patterns reflect USA Flat Roof's actual NorCal market.
- TPO vs PVC certification language: confirm USA Flat Roof's standard practice for documentation requirements.
- Solvent testing protocol: confirm production team's testing approach and when it's deployed.
- EPDM scope: confirm USA Flat Roof's actual scope on EPDM substrates and escalation procedure.
- Aluminum asphalt coating recognition: confirm field experience with these coatings in NorCal commercial.
- Cross-references to all earlier chapters should be verified once they're finalized.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 17 AND s.section_number = '18'
);

-- Part 2 / Ch 18 / Sec 1: Learning Objectives
UPDATE sections SET
  content_markdown = $mfst$By the end of this chapter, the salesperson should be able to:

1. Recognize each residential steep-slope roof system on sight and distinguish it from look-alike systems.
2. Identify the visual clues that point to each system at a glance.
3. Apply a consistent identification process during residential inspections.
4. Use cross-system recognition vocabulary fluently in conversations with homeowners and production teams.
5. Recognize when system identification is uncertain and escalate appropriately.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '1'
);

-- Part 2 / Ch 18 / Sec 2: Why This Chapter Exists
UPDATE sections SET
  content_markdown = $mfst$A residential rep arrives at a home and the same first question applies as on commercial: *what's on this roof?*

The residential landscape is simpler than commercial — fewer systems, less recovering and recoating to work backward through, less ambiguity about where one system ends and another begins. But the recognition skills still matter. A rep who confuses composition shingle profiles will miscount product needs in a repair scope. A rep who confuses concrete tile with clay tile won't source replacement pieces correctly. A rep who calls synthetic shake "real wood shake" sets the wrong expectation about lifespan and cost.

This chapter is the cross-system recognition reference for residential, paralleling Chapter 17 for commercial. It ties together Chapter 1 (Composition Shingle) and Chapter 8 (Concrete Tile) — the two systems USA Flat Roof works on residentially — plus the look-alikes reps will encounter in the field even if they're not proposing work.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '2'
);

-- Part 2 / Ch 18 / Sec 3: The Residential Steep-Slope Landscape
UPDATE sections SET
  content_markdown = $mfst$USA Flat Roof's residential work focuses on:

- **Composition shingle (Chapter 1)** — top sold residential system; full installation, repair, restoration via Fresh Roof rejuvenation, and replacement
- **Concrete tile (Chapter 8)** — repair and maintenance only; full underlayment replacement is referred out to tile specialty contractors

Reps will also encounter systems USA Flat Roof does *not* typically work on but needs to recognize:

- **Clay tile** — common on older and higher-end NorCal homes
- **Real wood shake** — increasingly rare in NorCal due to fire code restrictions
- **Synthetic / composite slate or shake** — on newer custom homes
- **Stone-coated metal** — niche, designed to mimic shake or tile
- **Standing-seam metal** — niche residential, more common on commercial outbuildings or rural homes
- **Real slate** — rare in NorCal, found on historic or high-end homes
- **Built-up flat sections on steep-slope homes** — when a home has both pitched and flat-roof sections (common on additions and modern designs)

This chapter focuses on confident recognition across this landscape so reps can identify what's on the roof, distinguish from look-alikes, and route appropriately when the system is outside USA Flat Roof's residential scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '3'
);

-- Part 2 / Ch 18 / Sec 4: The Quick Recognition Decision Tree
UPDATE sections SET
  content_markdown = $mfst$The four-step decision tree for residential parallels the commercial version but uses different anchors.

### Step 1: What's the basic shape and weight feel of the roof covering?

- **Flat individual rectangular pieces in overlapping courses** → composition shingle
- **Heavy, substantial-looking individual tile pieces with deep shadow lines** → concrete tile, clay tile, or synthetic tile
- **Split or sawn wood pieces with grain visible** → real wood shake or shingle
- **Continuous metal panels with visible standing seams or interlocks** → metal roofing
- **Thick, irregularly textured pieces designed to look like slate** → real slate or synthetic slate

### Step 2: What does the surface texture tell you?

- **Granular surface like sandpaper** → composition shingle (the granules are part of the shingle)
- **Smooth concrete or sand-textured** → concrete tile
- **Natural fired terracotta surface** → clay tile
- **Visible wood grain** → real wood shake (and some synthetic shake mimics)
- **Stone-coated metallic surface** → stone-coated metal
- **Smooth painted metallic** → standing-seam or metal shingle
- **Natural stone texture** → real slate

### Step 3: What does the tap test sound like?

(For roofs the rep can safely tap on tile, shake, or metal; not generally needed on composition shingle.)

- **Dull thud** → concrete tile
- **Higher-pitched ring** → clay tile
- **Plastic-sounding pop** → synthetic / composite tile or slate
- **Metallic sound** → metal roofing or stone-coated metal
- **Ringing chime** → real slate
- **Soft thunk** → wood shake

### Step 4: What's the age and architectural context?

- **Tract home built 1980s–2010s** → composition shingle most common; concrete tile second most common in NorCal
- **Older custom or Mediterranean-style home** → clay tile likely
- **Older rural or historic home** → potentially wood shake (where fire code permits) or real slate
- **Recent custom home** → variety; could include synthetic slate, stone-coated metal, premium designer composition shingle
- **Mid-century modern with low-slope sections** → composition shingle on the steeper portions; flat-roof system on low-slope sections

These four steps usually narrow the answer to one system. Subsequent sections give the system-specific identification clues for close calls.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '4'
);

-- Part 2 / Ch 18 / Sec 5: System-by-System Recognition Detail
UPDATE sections SET
  content_markdown = $mfst$### Composition Shingle (Chapter 1)

**Big-picture look:** rectangular overlapping pieces in horizontal courses from eave to ridge; granular surface (looks slightly grainy or sandy); ridge cap at the peak; uniform color across the field.

**Three profile types:**

- **Three-tab shingle** — flat, uniform appearance with cutouts creating three tab segments per shingle. Lower cost, shorter life, increasingly rare on new installs.
- **Architectural (dimensional, laminated) shingle** — two layers bonded together creating a thicker, shadowed, textured appearance. Current industry standard for new residential. The most common composition shingle reps will encounter.
- **Designer / luxury shingle** — heavier, multi-layer shingles designed to mimic slate, shake, or other premium materials.

**Most reliable identification clues:**

- Granular surface (most reliable single indicator — none of the look-alikes have this)
- Rectangular shape with uniform courses
- Visible ridge cap line at the peak
- Common colors: gray, brown, black, weathered wood tones

**Common confusion:** synthetic / composite slate or shake (designed to look like premium materials but on closer inspection are uniform manufactured pieces); designer composition shingle (still composition — granular surface confirms it).

**System chapter:** 1

### Concrete Tile (Chapter 8)

**Big-picture look:** individual heavy tile pieces in overlapping courses; deep shadow lines between courses; substantial visual presence; common on tract homes built 1980s–2010s.

**Common profiles:**

- **Flat / shake-look** — flat tiles with textured surface designed to mimic wood shake or slate
- **Low-profile / S-tile** — gentle curve, common on tract homes
- **High-profile / Spanish or barrel** — pronounced curve, Mediterranean appearance

**Most reliable identification clues:**

- Heavy weight (visible in the deep courses and substantial appearance)
- Dull thud when tapped
- Concrete edge visible at cut tiles or broken pieces
- Color may be pigmented through-body or surface-coated; surface coatings can wear off over time, exposing the natural concrete color underneath
- Common on homes built 1980s onward

**Common confusion:** clay tile (similar appearance, different sound and edge appearance), synthetic tile (significantly lighter weight, plastic-sounding tap), concrete shake-look tile vs real wood shake (concrete has cast texture, not real grain).

**Critical reminder for tile inspection:** the underlayment beneath the tiles is the actual waterproofing layer, not the tiles themselves. Tiles last 50+ years; underlayment typically 20–30 years. (See Chapter 8.)

**System chapter:** 8

### Clay Tile (Reference)

**Big-picture look:** individual tile pieces in overlapping courses, similar profile types as concrete tile (flat, S-tile, barrel), but with the natural color of fired terracotta.

**Most reliable identification clues:**

- Natural fired clay color (warm terracotta, with color variation between tiles)
- Higher-pitched ring when tapped (compared to concrete's dull thud)
- Often shows the natural clay edge at cut or broken tiles
- Common on older homes, Mediterranean-style architecture, and higher-end NorCal homes

**Common confusion:** concrete tile in similar profiles (especially S-tile and barrel — visually very similar at a distance; tap test and edge inspection distinguish), color-coated concrete tile designed to mimic clay aesthetic.

**Notes for USA Flat Roof reps:** clay tile is not a USA Flat Roof system. Reps should recognize it for inspection and escalate any work scope to senior estimator and likely refer out to tile specialty contractors. The age and value of homes with clay tile often makes the conversation different — these homeowners may have specific contractor preferences or HOA requirements.

### Synthetic / Composite Tile (Reference)

**Big-picture look:** tile or slate-look pieces, manufactured uniform color, significantly lighter weight than real tile or slate, often on newer custom homes.

**Most reliable identification clues:**

- Significantly lighter weight than concrete or clay tile
- Plastic-sounding tap
- Manufactured uniform color (no natural variation)
- Manufactured edge appearance
- Common on recent custom homes (2000s onward)

**Common confusion:** concrete tile (heavier, dull thud, sometimes with surface coating that has worn off), real slate (much heavier, ringing chime, natural variation).

**Notes for USA Flat Roof reps:** synthetic / composite tile is a specialty product. USA Flat Roof's scope on these systems is limited. Reps recognize and escalate.

### Real Wood Shake / Shingle (Reference)

**Big-picture look:** individual wood pieces in overlapping courses, with visible grain and natural wood color (often gray/silver weathered, sometimes treated brown, occasionally fresh-cut tan).

**Distinction within wood roofs:**

- **Shake** — split (hand-split or machine-split), thicker, more textured
- **Shingle** — sawn smooth, thinner, more uniform appearance

**Most reliable identification clues:**

- Natural wood grain visible
- Soft thunk when tapped
- Variable thickness and natural color variation
- Often on rural homes, custom homes, or older homes where fire code permits
- Common signs of aging: cupping, splitting, moss, fungal growth

**Common confusion:** synthetic shake (manufactured to look like wood — plastic feel and sound; uniform grain pattern), shake-look composition shingle (granular surface confirms it's composition, not wood), shake-look concrete tile (dull thud, no grain).

**Notes for USA Flat Roof reps:** wood shake is becoming rare in NorCal due to fire code restrictions in many jurisdictions. USA Flat Roof does not work on wood shake. Reps recognize and refer out.

> **[VERIFY LOCALLY]** Many California jurisdictions have fire code restrictions on wood roofing in WUI (Wildland-Urban Interface) zones. Replacement scope for existing wood shake roofs may require switching to non-combustible alternatives.

### Stone-Coated Metal (Reference)

**Big-picture look:** metal panels designed to look like shake, tile, or slate from a distance, with stone-coated surface adding texture.

**Most reliable identification clues:**

- Metallic sound when tapped
- Visible interlocks or seams between panels
- Metallic underside visible at edges
- Stone-coated surface texture (designed to look like another material)
- Lighter weight than tile

**Common confusion:** real shake or tile from a distance; close inspection (or tap test) immediately reveals the metal substrate.

**Notes for USA Flat Roof reps:** stone-coated metal is a specialty product. USA Flat Roof's scope is limited. Reps recognize and escalate.

### Standing-Seam Metal (Reference)

**Big-picture look:** continuous metal panels running from eave to ridge, with raised vertical seams between panels (the "standing seams"). Smooth painted metallic surface.

**Most reliable identification clues:**

- Continuous panels from eave to ridge (not individual courses)
- Visible raised seams every 12–24 inches
- Smooth painted metallic finish
- Metallic sound when tapped
- Common on rural, modern-design, and some commercial outbuildings

**Common confusion:** ribbed exposed-fastener metal panels (similar but with visible fasteners — typically agricultural or commercial, not residential), metal shingles (smaller individual pieces rather than continuous panels).

**Notes for USA Flat Roof reps:** metal roofing is a specialty trade. USA Flat Roof's scope is limited. Reps recognize and refer out.

### Real Slate (Reference)

**Big-picture look:** individual stone tiles with natural variation, typically in shades of gray, blue-gray, green, or purple. Distinctive heavy substantial appearance.

**Most reliable identification clues:**

- Natural stone texture and color variation between tiles
- Ringing chime when tapped
- Significantly heavier than any other roof material
- Almost always on older or higher-end homes
- Edge thickness varies (natural stone)
- Rare in NorCal — found on historic Bay Area homes, some Sacramento Valley historic properties, and certain custom builds

**Common confusion:** synthetic slate (much lighter, plastic-sounding tap, manufactured uniform color), designer composition shingle designed to mimic slate (granular surface confirms composition).

**Notes for USA Flat Roof reps:** real slate is a specialty trade. USA Flat Roof does not work on real slate. Reps recognize and refer out.

### Flat-Roof Sections on Steep-Slope Homes

Many residential homes have a mix: pitched main roof with flat-roof sections over additions, porch covers, modern flat-roof architectural elements, or mid-century modern designs.

**Common configurations:**

- Pitched composition shingle main roof + flat-roof addition (often modified bitumen, TPO, or BUR on older flat sections)
- Pitched tile main roof + flat-roof entry or porch
- Modern home with mostly flat roofs and some pitched accent sections

**Notes for USA Flat Roof reps:** the flat sections on steep-slope homes are USA Flat Roof's wheelhouse. A residential inspection that includes flat sections should apply the relevant flat-roof system identification (Chapter 17) to those sections. Reps should not overlook the flat sections — they often age differently and require different scope than the main roof.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '5'
);

-- Part 2 / Ch 18 / Sec 6: The Hard Calls — Profile Distinctions and Look-Alikes
UPDATE sections SET
  content_markdown = $mfst$Three recognition challenges come up regularly on residential inspections.

### Three-Tab vs Architectural Shingle

| Indicator | Three-tab | Architectural |
|---|---|---|
| Profile | Flat, single-layer | Two layers bonded, dimensional |
| Pattern | Visible cutouts creating three "tabs" per shingle | Shadowed, textured, no cutouts visible |
| Thickness | Thinner | Thicker, visible at edges |
| Appearance | Uniform, less textured | Shadowed, more textured |
| Common era | Older homes, budget builds; less common on new installs | Industry standard on new installs since the 2000s |

**Why it matters:** repair scope (matching shingle profile), warranty understanding, lifespan expectations.

### Concrete vs Clay Tile

| Indicator | Concrete | Clay |
|---|---|---|
| Sound when tapped | Dull thud | Higher-pitched ring |
| Natural color | Pigmented or surface-coated; coatings can wear off | Natural fired terracotta |
| Edge appearance | Cast concrete edge | Natural clay edge |
| Weight | Heavy (typically 800–1,200 lbs/square) | Heavy (sometimes slightly lighter than concrete) |
| Common era | 1980s–2010s tract homes most common | Older homes, Mediterranean architecture, high-end |

**Why it matters:** repair material sourcing (different products, different suppliers), homeowner expectations, scope routing (USA Flat Roof handles concrete tile repair and maintenance; clay tile typically refers out).

### Real Wood Shake vs Synthetic Shake vs Composition Shake-Look

| Indicator | Real wood shake | Synthetic shake | Composition shake-look |
|---|---|---|---|
| Surface | Natural wood grain | Manufactured grain pattern | Granular (composition shingle hallmark) |
| Sound when tapped | Soft thunk | Plastic pop | Composition shingle sound (similar to other shingles) |
| Weight feel | Lighter than tile, heavier than composition | Light | Standard composition |
| Aging signs | Cupping, splitting, fungal growth | UV color fade, manufactured edge wear | Granule loss, lifted tabs |
| Common context | Older or rural homes, fire-permitted areas | Recent custom homes | Standard residential |

**Why it matters:** lifespan expectations are radically different across these three; replacement scope and pricing are radically different; fire code implications differ.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '6'
);

-- Part 2 / Ch 18 / Sec 7: The Architectural and Era Lens
UPDATE sections SET
  content_markdown = $mfst$Residential roof identification benefits from a similar lens as commercial — using the home's architectural style and construction era to anticipate what's likely on the roof.

### Strong architectural signals

- **Tract home (single-family or townhome) built 1980s–2010s** → composition shingle most common, concrete tile second most common (especially in NorCal where Mediterranean / Spanish-influenced styling is popular on tract builds)
- **Mediterranean / Spanish-style home** → tile (clay or concrete) common; visible barrel or S-tile profile
- **Mid-century modern home** → composition shingle on pitched sections; flat-roof sections common; sometimes specialty materials on accent areas
- **Craftsman or bungalow style (older)** → composition shingle most likely now; sometimes original wood shake
- **Victorian or historic home** → potentially original slate, wood shake, or composition shingle replacement of original; varies widely
- **Modern / contemporary new build** → variety; could include premium composition, synthetic slate, stone-coated metal, or standing-seam metal
- **Custom home (recent)** → premium materials more likely (designer composition, synthetic slate, stone-coated metal, real slate, or specialty profile concrete tile)
- **Rural property** → wood shake possible (where fire code permits), metal roofing more common than in urban areas
- **Multifamily / condo** → typically composition shingle or concrete tile, similar to tract homes

### What to do with this information

The architectural lens sets the rep's expectations. A 1990 Bay Area tract home with red barrel profile is almost certainly concrete tile. A 1925 Berkeley craftsman with thin gray tiles and visible stone variation is plausibly real slate. A 2010 Walnut Creek custom home with shake-look pieces could be wood, synthetic, stone-coated metal, or designer composition — closer inspection narrows it down.

The lens accelerates identification. It doesn't override observation. A rep who walks onto a 1925 home expecting slate but finds concrete tile has just learned the roof was replaced at some point — useful information for the conversation.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '7'
);

-- Part 2 / Ch 18 / Sec 8: The Inspection-Stage Recognition Process
UPDATE sections SET
  content_markdown = $mfst$Reps should follow a consistent identification process at the start of every residential inspection, paralleling the commercial process from Chapter 17.

### Step 1: Pre-arrival
- Note home age, architectural style, neighborhood character
- Apply the architectural and era lens to set initial expectations

### Step 2: Ground-level overview
- First impression: pieces or panels, color, profile, weight feel
- Apply the four-step decision tree from Section 4

### Step 3: Closer inspection (ladder edge, drone, or roof walk where appropriate and safe)
- Confirm the system using system-specific identification clues from Section 5
- For tile roofs: identify whether concrete or clay; note profile type
- For composition shingle: identify whether three-tab, architectural, or designer
- Check for any flat-roof sections on the home and identify those separately (Chapter 17)

### Step 4: Documentation
- Note system identification with appropriate certainty language
- Note profile type for repair scope
- Note any uncertainty for follow-up

### Step 5: Conversation with homeowner
- Confirm what the homeowner believes they have
- Discrepancies are useful — sometimes the homeowner has documentation, sometimes the rep observes that prior work changed the original system$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '8'
);

-- Part 2 / Ch 18 / Sec 9: Common Recognition Mistakes
UPDATE sections SET
  content_markdown = $mfst$### Mistakes by reps

- Confusing concrete tile with clay tile (or vice versa) and routing the project incorrectly
- Treating all tile as one category instead of identifying type and profile
- Calling synthetic shake "real wood shake" and setting wrong lifespan expectations
- Missing the granular surface as the composition shingle giveaway
- Confusing three-tab and architectural shingle profiles in repair scope
- Overlooking flat-roof sections on otherwise pitched homes
- Failing to apply the architectural lens before climbing the ladder
- Not asking the homeowner what they believe they have

### Mistakes by homeowners (worth knowing)

- Reporting a tile roof as "Spanish tile" without distinguishing concrete from clay
- Reporting old wood shake as "the original roof" when it has been replaced multiple times
- Believing synthetic slate is real slate (or vice versa)
- Not knowing the difference between three-tab and architectural shingle on their own roof$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '9'
);

-- Part 2 / Ch 18 / Sec 10: Sales Conversation Guide
UPDATE sections SET
  content_markdown = $mfst$### Opening recognition during inspection

> "Before I get into the inspection findings, let me confirm what I'm seeing. Based on the roof, this looks like [system, with profile if applicable]. Does that match what you have records of, or what you remember being installed?"

### When homeowner expectation and observation disagree

> "What you're describing as your roof doesn't quite match what I'm observing. That happens — sometimes original information from a builder or previous owner doesn't reflect later replacement work. Let me walk you through what I'm seeing."

### When tile type matters for the conversation

> "Your roof is [concrete / clay] tile. The reason I want to be specific is that the repair work, the replacement materials, and the contractor scope all differ between the two. We handle [concrete / clay] tile [repair and maintenance / not in our scope]; I'll explain what that means for your project."

### When composition shingle profile matters

> "Your shingles are [three-tab / architectural / designer]. For repair work, we want to match the existing profile so the patch isn't visually obvious and the warranty considerations are consistent. Knowing the profile up front is part of how we scope the project."

### When the home has both pitched and flat-roof sections

> "Your home has [pitched composition shingle on the main roof / pitched concrete tile on the main roof] and a flat-roof section over [the addition / the entry / etc.]. Those age differently and may need different scope. I'll inspect both and we'll talk through each separately."

### When identification is uncertain

> "I want to be honest — without documentation, I can't certify [synthetic vs real / concrete vs clay / etc.] just by looking. The closer inspection points to [observation], but if you have any product documentation or original construction records, that would settle it. Otherwise, I'll document what I observed and we can confirm before any scope-dependent work."$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '10'
);

-- Part 2 / Ch 18 / Sec 11: When to Escalate or Refer Out
UPDATE sections SET
  content_markdown = $mfst$Escalate to senior estimator, production manager, or qualified inspector when:

- Tile type cannot be confirmed and project scope depends on it
- Composition shingle profile cannot be confirmed and repair scope depends on it
- Real wood shake roof requiring replacement scope (out of USA Flat Roof scope; refer)
- Real slate roof requiring any scope (out of USA Flat Roof scope; refer)
- Stone-coated metal or standing-seam metal roof requiring any scope (limited USA Flat Roof scope; escalate)
- Synthetic / composite tile or slate roof requiring any scope (limited USA Flat Roof scope; escalate)
- Clay tile roof requiring any scope (out of USA Flat Roof scope for replacement; repair and maintenance scope to be confirmed with senior estimator)
- Solar array on the residential roof
- Flat-roof sections on a steep-slope home requiring the commercial-system inspection lens
- Suspected hail or storm damage with insurance involvement
- Any condition exceeding the rep's training or authorization$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '11'
);

-- Part 2 / Ch 18 / Sec 12: Cross-System Quick-Reference Table
UPDATE sections SET
  content_markdown = $mfst$| System | Primary Look | Tap Sound | Distinguishing Clues | USA Flat Roof Position |
|---|---|---|---|---|
| Composition Shingle (3-tab) | Flat single-layer with cutout tabs | (N/A) | Granular surface; uniform pattern; older homes | Installs / repairs / replaces |
| Composition Shingle (Architectural) | Two-layer dimensional | (N/A) | Granular surface; shadowed appearance; current standard | Installs / repairs / replaces |
| Composition Shingle (Designer) | Heavier multi-layer, mimics slate or shake | (N/A) | Granular surface confirms composition | Installs / repairs / replaces |
| Concrete Tile | Heavy individual pieces, varied profiles | Dull thud | Cast concrete edge; pigmented or coated | Repair and maintenance |
| Clay Tile | Heavy individual pieces, terracotta color | Higher-pitched ring | Natural fired clay color and edge | Recognize; refer out |
| Synthetic / Composite Tile | Tile-look, lighter weight | Plastic pop | Manufactured uniform color | Limited; escalate |
| Real Wood Shake | Split or sawn wood pieces | Soft thunk | Visible grain; natural color variation | Recognize; refer out |
| Synthetic Shake | Wood-look, manufactured | Plastic pop | Manufactured grain pattern | Limited; escalate |
| Stone-Coated Metal | Metal panels designed to look like shake/tile | Metallic | Stone-coated surface; metallic underside | Limited; escalate |
| Standing-Seam Metal | Continuous panels with vertical seams | Metallic | Visible standing seams; smooth painted metallic | Recognize; refer out |
| Real Slate | Heavy stone tiles, natural variation | Ringing chime | Natural stone texture and edge | Recognize; refer out |
| Flat-Roof Sections on Pitched Homes | Per Chapter 17 | (varies) | Apply commercial-system lens | Per Chapter 17 |$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '12'
);

-- Part 2 / Ch 18 / Sec 13: Instructor Notes
UPDATE sections SET
  content_markdown = $mfst$**What new reps usually misunderstand**
- They lump all tile together as "tile" without identifying concrete vs clay.
- They miss the granular-surface giveaway for composition shingle.
- They confuse three-tab and architectural profiles in repair scope.
- They overlook flat-roof sections on otherwise pitched homes.
- They don't apply the architectural and era lens before climbing the ladder.
- They mistake synthetic for real on shake and slate, setting wrong customer expectations.

**Discussion questions for group training**
- Walk through the four-step decision tree on a hypothetical home. Where does each step point in different scenarios?
- A homeowner says they have "Spanish tile." How do you identify whether it's concrete or clay?
- A homeowner says they have "wood shake." On inspection, the pieces look like wood but tap with a plastic pop. How do you handle the conversation?
- A 1995 tract home in San Jose has barrel-profile reddish tile. Predict the system and explain why.
- What's the 30-second answer to "is this real slate or synthetic?"

**Field exercises**
- Pair up. Walk three real residential roofs. Apply the four-step decision tree. See where each step lands.
- Practice the "let me confirm what I'm seeing" customer conversation in role-play.
- Walk through a neighborhood and predict roof systems based on architectural and era lens; verify on inspection where possible.
- Identify all flat-roof sections on a sample of mixed-roof homes; apply Chapter 17 to those sections.

**What the manager should test verbally**
- The four-step decision tree for residential identification.
- Distinguish concrete from clay tile and what reps can certify.
- Distinguish three-tab from architectural shingle.
- Name the systems USA Flat Roof installs, works on, and refers out.
- Walk through the architectural and era lens for several home types.

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '13'
);

-- Part 2 / Ch 18 / Sec 14: Key Terms to Remember
UPDATE sections SET
  content_markdown = $mfst$- **Architectural and era lens** — using the home's architectural style and construction era to anticipate likely roof system before inspection.
- **Decision tree (residential identification)** — the four-step quick-recognition process: shape and weight, surface texture, tap sound, age and architectural context.
- **Designer / luxury shingle** — heavier multi-layer composition shingle designed to mimic slate or shake.
- **Mixed-roof home** — residential home with both pitched and flat-roof sections; requires both Chapter 17 and Chapter 18 recognition skills.
- **Profile** — the shape and configuration of a roof covering (three-tab, architectural, S-tile, barrel, etc.).
- **Real vs synthetic** — distinction reps need to make on shake, slate, and tile look-alikes; real materials have natural variation while synthetics are manufactured uniform.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '14'
);

-- Part 2 / Ch 18 / Sec 15: Chapter Summary
UPDATE sections SET
  content_markdown = $mfst$The first question on every residential inspection is what's on the roof. The four-step decision tree (shape and weight, surface texture, tap sound, age and architectural context) narrows the answer quickly. System-specific identification clues from Chapters 1 and 8 confirm the recognition for USA Flat Roof's primary residential systems — composition shingle and concrete tile. Reps also need to recognize look-alikes they won't propose work on: clay tile, real wood shake, synthetic / composite tile or slate, stone-coated metal, standing-seam metal, and real slate. Hard calls — three-tab vs architectural shingle, concrete vs clay tile, real vs synthetic shake — are honest about the limits of casual identification and use the tap test, edge inspection, and documentation when scope depends on certainty. The architectural and era lens (tract home suggests composition or concrete tile, Mediterranean suggests tile, custom home suggests variety) sets initial expectations the rep verifies on inspection. Flat-roof sections on otherwise pitched homes apply the commercial-system lens (Chapter 17). Reps document what they observe with appropriate certainty language and escalate or refer out when identification points to systems outside USA Flat Roof's residential scope.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '15'
);

-- Part 2 / Ch 18 / Sec 16: End-of-Chapter Quiz
UPDATE sections SET
  content_markdown = $mfst$*Choose the best answer. Answer key follows.*

**1. (Beginner)** The most reliable single indicator that a residential roof is composition shingle is:
A. The color of the roof
B. The granular surface texture
C. The pitch of the roof
D. The age of the home

**2. (Beginner)** Concrete tile and clay tile differ most reliably in:
A. Profile shape (S-tile, barrel, flat)
B. Tap sound — concrete has a dull thud; clay has a higher-pitched ring
C. Color — concrete is gray and clay is red
D. There is no reliable difference

**3. (Beginner)** A composition shingle with two layers bonded together creating a shadowed, textured appearance is:
A. Three-tab shingle
B. Architectural (dimensional, laminated) shingle
C. Designer shingle
D. Wood shake

**4. (Beginner)** USA Flat Roof's residential scope includes:
A. All residential roof systems including slate and wood shake
B. Composition shingle (full installation, repair, replacement) and concrete tile (repair and maintenance)
C. Composition shingle only
D. Tile only

**5. (Intermediate)** A 1995 NorCal tract home has a red barrel-profile roof. The most likely system is:
A. Real clay tile
B. Concrete tile (pigmented or surface-coated to mimic clay)
C. Stone-coated metal
D. Composition shingle

**6. (Intermediate)** A homeowner says they have "wood shake." The pieces look like wood but tap with a plastic pop. The most likely system is:
A. Real wood shake
B. Synthetic / composite shake
C. Composition shake-look shingle
D. Stone-coated metal

**7. (Intermediate)** A 1925 Berkeley craftsman home has thin gray tiles with natural stone variation that ring when tapped. The most likely system is:
A. Concrete tile
B. Real slate
C. Synthetic slate
D. Composition shingle

**8. (Intermediate)** A homeowner reports their roof as "tile" without specifying. The most appropriate next step is:
A. Quote tile work generically
B. Inspect to identify whether concrete or clay (and what profile), since scope and routing depend on it
C. Decline to inspect
D. Refer to a tile contractor without inspection

**9. (Advanced)** A home has pitched composition shingle on the main roof and a flat-roof section over the rear addition. The flat section needs separate inspection using:
A. The same approach as the composition shingle
B. The commercial-system identification approach from Chapter 17
C. No inspection — flat sections don't matter on residential
D. Drone only

**10. (Advanced)** A homeowner says they have "real slate." On inspection, the pieces are uniform manufactured color, light weight, and tap with a plastic pop. The most appropriate response is:
A. Confirm the homeowner is correct
B. Document what was observed (synthetic / composite slate appearance), explain the indicators that suggest it's not real slate, and ask if they have product documentation
C. Tell the homeowner they're wrong
D. Quote work as real slate based on the homeowner's report

---

### Answer Key

1. **B — The granular surface texture.** None of the look-alikes have this; it's the composition shingle hallmark.
2. **B — Tap sound.** Concrete's dull thud and clay's ring are the most reliable distinguishers. Profile (A) is shared between both. Color (C) is unreliable since concrete can be coated to mimic clay.
3. **B — Architectural (dimensional, laminated) shingle.** Standard description.
4. **B — Composition shingle and concrete tile (per scope from Chapter 8).** Specific to USA Flat Roof.
5. **B — Concrete tile (pigmented or surface-coated).** Matches the era and tract-home pattern in NorCal. Real clay (A) is possible but less common on tract homes; the era lens points to concrete.
6. **B — Synthetic / composite shake.** Plastic-pop tap is the give-away. Real wood (A) has a soft thunk. Composition (C) wouldn't typically be described as "wood shake" by a homeowner.
7. **B — Real slate.** Era (1925), location, ringing chime, and natural variation all match. Concrete (A) and synthetic (C) wouldn't ring; composition (D) wouldn't have stone variation.
8. **B — Inspect to identify concrete vs clay and profile.** Scope and routing depend on this. Quoting generically (A) and declining (C) abandon the customer; referring without inspection (D) is premature.
9. **B — The commercial-system approach from Chapter 17.** Flat-roof sections require commercial-system identification.
10. **B — Document, explain the indicators, ask for documentation.** This is the honest response. Confirming based on customer report (A) without verification is wrong. Telling the homeowner they're wrong (C) is unprofessional. Quoting based on customer report (D) without verification creates problems.$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '16'
);

-- Part 2 / Ch 18 / Sec 17: Manager Review Checklist + Verification Notes
UPDATE sections SET
  content_markdown = $mfst$**Manager Review Checklist**

- [ ] Accurate for USA Flat Roof's residential market in NorCal?
- [ ] Are the identification clues practical for field use?
- [ ] Does the four-step decision tree match how experienced reps actually identify residential systems?
- [ ] Are escalation and referral triggers correct?
- [ ] Are any claims too strong, too cautious, or risky?
- [ ] Does the framing align with Chapter 1 (Composition Shingle), Chapter 8 (Concrete Tile), Chapter 12 (Inspections), and Chapter 17 (Commercial Overview)?
- [ ] Does the architectural and era lens reflect actual NorCal residential patterns?
- [ ] Are the reference-only systems (clay tile, wood shake, synthetic / composite, metal, slate) covered appropriately given USA Flat Roof's scope?

**Technical Items to Verify Before Publishing**

- Architectural and era lens: confirm the patterns reflect USA Flat Roof's actual NorCal residential market.
- Tile type identification: confirm tap test reliability and edge inspection methods used by field reps.
- Wood shake fire code: confirm current California WUI restrictions and jurisdiction-specific requirements.
- USA Flat Roof's scope on each reference-only system: confirm referral partners and escalation procedures.
- Cross-references to Chapters 1, 8, 12, and 17: verify identification language is consistent.
- Company policy items: every [COMPANY POLICY] placeholder.

*No external citations included. Items above marked "Needs verification" where applicable.*

[/INSTRUCTOR ONLY]$mfst$,
  updated_at = NOW()
WHERE id = (
  SELECT s.id FROM sections s
  JOIN chapters c ON s.chapter_id = c.id
  JOIN book_parts p ON c.part_id = p.id
  WHERE p.part_number = 2 AND c.chapter_number = 18 AND s.section_number = '17'
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
  WHERE p.part_number = 2
    AND s.content_markdown != ''
    AND s.content_markdown IS NOT NULL;
  IF populated_count != 137 THEN
    RAISE EXCEPTION 'Phase B import safety check failed (Part 2 only): expected 137 populated sections, found %. Transaction rolled back.', populated_count;
  END IF;
END $$;

COMMIT;
