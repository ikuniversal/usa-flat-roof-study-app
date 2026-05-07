BEGIN;
-- Chunk E: comparison tables + glossary + checklists (part 3/4)
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Tear-off', 'Full removal of existing roof down to the deck.', '["Chapter 13"]'::jsonb),
  ('Termination bar', 'Metal bar that secures the top edge of a flat-roof membrane against a wall or parapet.', '["Chapter 15"]'::jsonb),
  ('Three-tab shingle', 'Composition shingle with cutouts creating three tab segments per shingle. Older style; less common on new installs.', '["Chapter 1"]'::jsonb),
  ('Title 24', 'California''s energy efficiency code, including cool-roof requirements that influence membrane and coating color specifications.', '[]'::jsonb),
  ('Topcoat', 'UV-protective layer applied over SPF foam. Typically silicone (sometimes acrylic). Required for SPF performance and warranty.', '["Chapter 10"]'::jsonb),
  ('Torch-down', 'Modified bitumen installation method using a propane torch to melt and bond plies. Not used by USA Flat Roof on new installs.', '["Chapter 6"]'::jsonb),
  ('TPO (Thermoplastic Polyolefin)', 'Single-ply thermoplastic roof membrane; USA Flat Roof''s flagship commercial system; 60-mil mechanically attached standard.', '["Chapter 2"]'::jsonb),
  ('Transition', 'Junction where two different roof planes, walls, or systems meet.', '["Chapter 15"]'::jsonb),
  ('Underlayment', 'Material installed over the deck before the surface roofing material. On tile roofs, the underlayment is the actual waterproofing layer, not the tiles.', '["Chapter 8"]'::jsonb),
  ('Urgent / Escalate (severity rating)', 'Highest severity level on the four-point scale; condition requires immediate action and rep escalation.', '["Chapter 12"]'::jsonb),
  ('Valley', 'Where two sloped roof planes meet creating a low channel for water flow. High-stress area; common leak location.', '["Chapter 15"]'::jsonb),
  ('Verify locally', 'Recurring callout in the book reminding the rep to confirm code requirements, jurisdiction-specific items, or product details with local authorities or current documentation.', '[]'::jsonb),
  ('Walk pad', 'Protective surface installed on flat roofs at high-traffic areas to prevent membrane wear from foot traffic.', '[]'::jsonb),
  ('Walk-test', 'Walking on a flat roof while feeling for soft or spongy areas indicating wet insulation or substrate failure.', '[]'::jsonb),
  ('Warranty layers', 'The three typical warranty layers on a roof: manufacturer material warranty, manufacturer system warranty, contractor workmanship warranty.', '["Module 12"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Wet insulation', 'Insulation that has absorbed moisture from a leak or vapor migration. Disqualifying condition for restoration.', '["Chapter 13"]'::jsonb),
  ('Wind-driven leak', 'Leak that occurs only during heavy wind events, often at sidewall transitions, parapets, or sealant joints subject to wind-driven rain.', '["Module 2"]'::jsonb),
  ('Workmanship warranty', 'Contractor-issued warranty covering installation quality. Issued by USA Flat Roof, not the manufacturer.', '["Module 12"]'::jsonb),
  ('WUI (Wildland-Urban Interface)', 'Areas where development meets wildland fuel. California fire codes restrict certain roofing materials in WUI zones, particularly wood shake.', '[]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO checklists (checklist_number, title, use_when, display_order) VALUES
  (1, 'General Residential Steep-Slope', 'System is not yet identified or for any residential pitched roof inspection.', 1),
  (2, 'General Commercial Flat-Roof', 'System is not yet identified or for any commercial flat-roof inspection.', 2),
  (3, 'Composition Shingle', 'Any composition shingle inspection. Reference Chapter 1 for full guidance.', 3),
  (4, 'Concrete Tile', 'Any concrete tile inspection. Reference Chapter 8 for full guidance.', 4),
  (5, 'TPO', 'Any TPO inspection. Reference Chapter 2 for full guidance.', 5),
  (6, 'PVC', 'Any PVC inspection. Reference Chapter 5 for full guidance.', 6),
  (7, 'Modified Bitumen (Self-Adhered)', 'Any modified bitumen inspection. Reference Chapter 6 for full guidance.', 7),
  (8, 'BUR (Built-Up Roofing)', 'Any BUR inspection. Reference Chapter 9 for full guidance.', 8),
  (9, 'Silicone Coatings (Existing)', 'Inspecting an existing silicone-coated roof. Reference Chapter 3 for full guidance.', 9),
  (10, 'SPF (Spray Polyurethane Foam)', 'Any SPF inspection. Reference Chapter 10 for full guidance.', 10),
  (11, 'Maintenance Visit Quick Checklist', 'Scheduled maintenance visits on customers in active maintenance programs.', 11)
ON CONFLICT (checklist_number) DO UPDATE SET
  title = EXCLUDED.title,
  use_when = EXCLUDED.use_when,
  display_order = EXCLUDED.display_order;
DELETE FROM checklist_sections WHERE checklist_id IN (
  SELECT id FROM checklists WHERE checklist_number IN (1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11)
);
INSERT INTO checklist_sections (checklist_id, section_title, items_json, display_order)
SELECT cl.id, v.section_title, v.items_json, v.display_order
FROM (VALUES
  (1, 'Pre-Inspection', '["Review any documentation customer provided (prior reports, warranty papers, repair history)","Note home age, address, architectural style","Apply architectural and era lens (Chapter 18) to set expectations","Confirm equipment: ladder, PPE, camera, drone if applicable, reference scale items, cleaning cloth, backup power","Review any customer-reported leak or damage location"]'::jsonb, 1),
  (1, 'Customer Conversation Before Inspection', '["Introduce yourself; confirm scope of visit","Ask lead-qualification questions","Listen for concerns, history, customer goals","Confirm specific areas customer wants inspected","Set expectation for inspection process and timing"]'::jsonb, 2),
  (1, 'Building Exterior Walk-Around', '["Photograph all four elevations","Note parapet, gutter, downspout, fascia, and soffit conditions","Note tree overhang, debris exposure, adjacent structures","Note any visible interior leak evidence reported by customer","Identify roof system per the four-step decision tree (Chapter 18)"]'::jsonb, 3),
  (1, 'System Identification', '["Composition shingle (note profile: three-tab / architectural / designer)","Concrete tile (note profile: flat / S-tile / barrel)","Other (clay tile / wood shake / synthetic / metal / slate — note for escalation or referral)","Mixed roof: any flat-roof sections? (if yes, also use Checklist 2 or system-specific commercial checklist)"]'::jsonb, 4),
  (1, 'Roof Access Decision', '["Ladder access available and safe?","Drone authorized and conditions appropriate?","Roof walk safe and within rep''s training?","If unsafe: ground-level + drone, document conditions that prevent walk"]'::jsonb, 5),
  (1, 'Roof Surface Inspection', '["Photograph each slope from elevated viewpoint","Inspect every penetration: pipe boots, vents, skylights, chimneys, conduits","Inspect every transition: sidewalls, headwalls, dormers","Inspect every valley","Inspect drip edge and rake-edge details","Inspect ridge and hip lines","Note ventilation provisions: ridge vent, box vents, gable vents, soffit vents"]'::jsonb, 6),
  (1, 'Detail Inspection (per Chapter 15)', '["Pipe boots — cracking, sealant condition, daylight visible","Step flashing at sidewalls — counter-flashing present, kick-out at bottom","Headwall flashing — counter-flashing condition, sealant","Chimney flashing — step, apron, cricket, counter-flashing, mortar condition","Skylight flashing — perimeter integrity, frame seal","Valleys — debris, wear, rust, displacement","Ridge / hip — fastening condition, mortar (tile)"]'::jsonb, 7),
  (1, 'Attic Inspection (if accessible)', '["Daylight visible at penetrations or eaves?","Water staining on deck, rafters, insulation?","Ventilation pattern: balanced intake/exhaust?","Insulation condition: dry, compressed, blocking soffits?","Mold or biological growth?","Frost on deck (in cold conditions)?","Condition consistent with reported leak?"]'::jsonb, 8),
  (1, 'Gutter Inspection', '["Gutter condition: rust, holes, separation","Slope toward downspouts; standing water in gutters?","Debris accumulation; granule loss visible?","Downspout count and position","Drip edge integration with gutter"]'::jsonb, 9),
  (1, 'Documentation', '["All four elevations photographed","Each slope photographed","Every penetration photographed","Every detail (flashings, transitions, valleys) photographed","Damage close-ups with reference scale","Substrate visible at any worn or exposed areas","Attic photos if accessible","Interior leak evidence if reported"]'::jsonb, 10),
  (1, 'Severity Ratings Applied', '["Each documented condition rated using the four-point scale"]'::jsonb, 11),
  (1, 'Red Flags Requiring Escalation', '["Active interior leak with unknown source","Visibly sagging roof plane","Soft / spongy deck underfoot","Significant hail or wind damage suspected","Mold or biological growth in attic","Asbestos suspected in older underlayment","Solar array on the roof","Customer requests work outside scope (clay tile replacement, wood shake, etc.)"]'::jsonb, 12),
  (1, 'Post-Inspection Customer Conversation', '["Walk through findings using severity scale","Set expectations for proposal and timing","Defer specific pricing to written proposal","Address any questions; confirm next steps"]'::jsonb, 13),
  (2, 'Pre-Inspection', '["Review documentation customer provided","Note building age, address, occupancy/use","Apply building-use lens (Chapter 17) to set expectations","Confirm equipment: ladder, PPE, camera, drone, chalk for ponding outlines, reference scale, cleaning cloth","Review reported leaks or recent issues"]'::jsonb, 1),
  (2, 'Customer Conversation Before Inspection', '["Confirm scope; ask lead-qualification questions","Note history: leaks, repairs, recover work, prior coatings","Note any rooftop equipment or trade activity","Confirm any active leaks or interior damage"]'::jsonb, 2),
  (2, 'Building Exterior Walk-Around', '["Photograph all four elevations","Note parapet condition, coping, scuppers, downspouts","Note efflorescence or staining on exterior walls","Note tree overhang or adjacent structure issues"]'::jsonb, 3),
  (2, 'Roof Access', '["Confirm ladder, hatch, or stair access is safe","Note any code violations or missing safety equipment","Drone authorized and conditions appropriate?","Roof walk safe?"]'::jsonb, 4),
  (2, 'System Identification (Chapter 17)', '["Apply four-step decision tree: surface color, seam type, surface texture, edge appearance","Identify: TPO / PVC / EPDM / Modified Bitumen / BUR / SPF / Coating / Mixed","If coated or recovered: identify substrate where exposed","Note any uncertainty for escalation"]'::jsonb, 5),
  (2, 'Roof Surface Overview', '["Photograph each quadrant from elevated view","Note overall membrane / surface color and condition","Note dirt, biological staining, walkability","Note walk pad coverage at high-traffic areas"]'::jsonb, 6),
  (2, 'Seams and Field', '["Inspect every seam (single-ply systems)","Note T-joints (high-failure locations)","Inspect ply layers (multi-ply systems)","Note any blistering, alligatoring, or ply separation","Note any membrane or surface damage"]'::jsonb, 7),
  (2, 'Penetrations and Details', '["Photograph every pipe, vent, drain, scupper, skylight","Inspect every HVAC curb and equipment platform","Inspect every conduit and miscellaneous penetration","Note pitch pans (high-failure detail)","Note flashing condition at all details"]'::jsonb, 8),
  (2, 'Drainage (Chapter 16)', '["Inspect every drain ring; check for rust, lifting, sealant failure","Inspect every scupper; check through-wall flashing","Confirm overflow drainage present and functional","Document ponding evidence — chalk-outline extent on dry days","Note dirt rings, biological growth, accelerated wear in ponding areas","Photograph any standing water with depth indication"]'::jsonb, 9),
  (2, 'Parapet and Edge Details', '["Inspect parapet flashing along full length","Note coping condition, fastener integrity, sealant joints","Inspect termination bars","Note any membrane shrinkage at perimeter","Inspect edge and gravel-stop details (BUR)"]'::jsonb, 10),
  (2, 'Substrate Inspection (Coated or Recovered Roofs)', '["Note substrate visible at edges, drains, worn areas","Note coating chemistry indicators (silicone vs acrylic vs SPF)","Note any coating delamination, peeling, or substrate failure","Walk-test for soft / spongy areas suggesting wet insulation"]'::jsonb, 11),
  (2, 'Interior Inspection (if accessible)', '["Note ceiling tile staining, water marks, efflorescence","Note drip patterns relative to known roof penetrations","Note interior moisture indicators that may suggest vapor issues (Chapter 14)"]'::jsonb, 12),
  (2, 'Documentation', '["All four elevations","Each quadrant from elevated view","Every penetration with close-up and context shot","Every flashing and detail","Every seam concern with reference scale","Ponding evidence (chalk outlines on dry days)","Substrate exposed at edges or worn areas","Walk-test soft areas marked","Interior leak evidence if reported"]'::jsonb, 13),
  (2, 'Red Flags Requiring Escalation', '["Active interior leak with unknown source","Soft / spongy underfoot — suspected wet insulation","Visible structural deflection or sagging deck","Widespread seam failure or substrate failure","Multiple roof layers","Pre-1980s building — asbestos potential","Suspected hail or storm damage with insurance involvement","Solar array on the roof","Coating chemistry uncertain and scope depends on it","PVC vs TPO identification uncertain and scope depends on it"]'::jsonb, 14),
  (3, 'Shingle Profile and Condition', '["Profile: three-tab / architectural / designer","Granule coverage — uniform / light loss / significant loss with exposed asphalt","Lifted or curling tab edges","Cracked or split shingles","Missing shingles","Exposed nails (failed seals)","Algae streaking (typically north slope)","Moss growth in shaded areas"]'::jsonb, 1),
  (3, 'Inspection by Slope', '["Inspect each slope separately","Note any soft spots underfoot — escalate immediately","South / west exposure aging signs","North / shaded aging signs (algae, moss)"]'::jsonb, 2),
  (3, 'Detail Inspection', '["Pipe boots — cracking, sealant","Step flashing — counter-flashing, kick-out at bottom of sidewalls","Chimney — step, apron, cricket, counter-flashing, mortar","Skylight flashing","Valleys — debris, rust, wear"]'::jsonb, 3)
) AS v(checklist_number, section_title, items_json, display_order)
JOIN checklists cl ON cl.checklist_number = v.checklist_number;
INSERT INTO checklist_sections (checklist_id, section_title, items_json, display_order)
SELECT cl.id, v.section_title, v.items_json, v.display_order
FROM (VALUES
  (3, 'Gutters', '["Granules in gutters (handful or more = significant aging indicator)","Gutter slope, sagging, detachment","Drip edge integration"]'::jsonb, 4),
  (3, 'Attic Check (if accessible)', '["Daylight visible","Water staining on deck or rafters","Ventilation provisions — balanced intake/exhaust","Insulation condition"]'::jsonb, 5),
  (3, 'Rejuvenation Qualification (Chapter 4)', '["Roof age within qualifying window?","Granule coverage adequate?","Shingle flexibility — significant brittleness?","Active leaks (disqualifying)?","Multiple damaged or missing shingles (disqualifying)?"]'::jsonb, 6),
  (3, 'Severity Quick Reference', '["Monitor: light granule loss; algae streaking","Maintenance: moss growth; gutter granule accumulation; minor sealant","Repair: lifted tabs, cracked shingles, missing shingles, exposed nails, failed pipe boots, deteriorated flashing","Urgent / Escalate: sagging deck, active interior leak, hail damage, multiple layers, suspected asbestos"]'::jsonb, 7),
  (4, 'Safety Reminder', '["Walk only on the lower third of each tile, on supported areas","Do not walk a wet, mossy, or debris-covered tile roof","Use drone or ladder-edge inspection if walking is not safe or trained"]'::jsonb, 1),
  (4, 'Tile and Ridge Inspection', '["Tile profile: flat / S-tile / barrel","Identify concrete vs clay vs synthetic (tap test, edge inspection)","Broken, cracked, or displaced tiles","Slipped tiles","Tile color fade / surface coating wear (aesthetic only)","Mortar condition at ridge and hips","Mortar condition at chimney transitions"]'::jsonb, 2),
  (4, 'Underlayment Indicators (the actual waterproofing layer)', '["Roof age — best estimate","Underlayment age based on roof age and any prior re-felt history","Underlayment visible at any lifted-tile inspection points — note condition","Customer-reported leak history"]'::jsonb, 3),
  (4, 'Detail Inspection', '["Pipe boots and penetration flashings","Valley flashings — rust, debris dam, water tracking under tiles","Chimney flashings","Skylight flashings","Eave closures and bird-stop details"]'::jsonb, 4),
  (4, 'Drainage', '["Gutters — debris, biological growth, granule equivalent buildup","Downspout function"]'::jsonb, 5),
  (4, 'Attic Inspection (if accessible)', '["Daylight visible at penetrations","Water staining on deck underside","Evidence of past leaks or repairs","Deck condition"]'::jsonb, 6),
  (4, 'Severity Quick Reference', '["Monitor: color fade; minor biological growth; light debris","Maintenance: moss treatment; debris removal; minor sealant","Repair: broken or cracked tiles; mortar deterioration; failed pipe boot; failed flashing","Urgent / Escalate: active interior leak; visible underlayment failure; sagging deck; multiple damaged tiles indicating broader issue; full underlayment replacement scope (refer out)"]'::jsonb, 7),
  (4, 'Important Reminder', '["The tiles are not the waterproofing — the underlayment underneath is","Tiles last 50+ years; underlayment typically 20–30 years","USA Flat Roof scope is repair and maintenance; full re-felt is referred out"]'::jsonb, 8),
  (5, 'Membrane and Seam Inspection', '["Membrane color and overall condition","Surface dirt and biological staining","UV degradation / chalking — particularly at seams","Walk every seam if safely accessible","Note any seam separation, fishmouth, or visible weld inconsistency","Note T-joints (where three sheets meet) — high-failure locations","Note membrane shrinkage at perimeter"]'::jsonb, 1),
  (5, 'Mechanical Attachment Indicators', '["Visible fastener back-out (raised bumps)","Membrane separation along seams suggesting attachment failure","Note any unusual fastener patterns"]'::jsonb, 2),
  (5, 'Penetrations and Details', '["Every pipe boot, vent, drain, HVAC curb, conduit, skylight","Note pipe boot condition, sealant, flashing integrity","Any unsealed or improperly detailed penetrations"]'::jsonb, 3),
  (5, 'Drainage', '["Every drain — clamping ring, debris, vegetation","Every scupper","Overflow drains present and clear","Ponding evidence (chalk outline; dirt rings; biological growth)"]'::jsonb, 4),
  (5, 'Parapet and Terminations', '["Wall flashings — pulled, separated, unsealed","Termination bars","Coping condition and joints","Counter-flashing"]'::jsonb, 5),
  (5, 'Substrate / Underfoot', '["Walk-test for soft / spongy areas","Any visible insulation or substrate failure"]'::jsonb, 6),
  (5, 'TPO vs PVC Identification (Chapter 17)', '["Documentation available?","If not: document visual indicators; note that product type cannot be certified by appearance alone"]'::jsonb, 7),
  (5, 'Severity Quick Reference', '["Monitor: surface dirt; light staining","Maintenance: chalking; light ponding; debris in drains","Repair: seam separation; punctures; failed pipe boot; chronic ponding; drain failures","Urgent / Escalate: active interior leak; soft underfoot (wet insulation); structural deflection; widespread seam failure; PV array"]'::jsonb, 8),
  (6, 'Membrane and Seam Inspection (parallel to TPO)', '["Same general scope as TPO","Note any plasticizer migration on aged systems (15+ years) — stiffening, cracking","Confirm chemical or grease exposure environments — restaurant exhaust, kitchen vents, industrial discharge"]'::jsonb, 1),
  (6, 'Building Use Considerations', '["Restaurant / kitchen / hospital / industrial — confirms PVC''s use case","Note any chemical or grease exposure pattern"]'::jsonb, 2),
  (6, 'Penetrations, Details, Drainage, Parapet, Terminations', '["Same as TPO checklist"]'::jsonb, 3),
  (6, 'TPO vs PVC Identification', '["Documentation available?","If not: document visual indicators; note that product type cannot be certified by appearance alone","If product type drives proposal scope: escalate"]'::jsonb, 4),
  (6, 'Severity Quick Reference', '["Monitor: surface dirt; light staining","Maintenance: chalking; light ponding; debris in drains","Repair: seam separation; punctures; failed pipe boot; chronic ponding; drain failures; plasticizer-driven cracking","Urgent / Escalate: active interior leak; soft underfoot; structural deflection; widespread membrane stiffening or cracking on aged PVC"]'::jsonb, 5),
  (7, 'Membrane Finish Identification', '["Granule-surfaced cap sheet (most common)","Smooth-surfaced (often with prior coating)","Identify installation method: self-adhered (clean seams), torch-down (asphalt squeeze-out), hot-mopped (kettle residue)"]'::jsonb, 1),
  (7, 'Membrane and Seam Inspection', '["Granule coverage — uniform / light loss / significant loss with exposed asphalt","Inspect every seam — both lateral overlaps and end laps","Note any seam separation or lifting","Note any blistering (moisture entrapment indicator)","Note alligatoring on smooth-surfaced or aged systems"]'::jsonb, 2),
  (7, 'Penetrations and Details', '["Every pipe boot, vent, drain, scupper, curb","Note flashing condition at all details","Note any prior repair patches (asphalt cement, flashing tape additions)"]'::jsonb, 3),
  (7, 'Drainage', '["Drains, scuppers, overflow drains","Ponding evidence","Debris accumulation"]'::jsonb, 4),
  (7, 'Parapet and Terminations', '["Wall flashings, termination bars, coping"]'::jsonb, 5)
) AS v(checklist_number, section_title, items_json, display_order)
JOIN checklists cl ON cl.checklist_number = v.checklist_number;
COMMIT;
