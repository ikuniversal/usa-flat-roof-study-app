BEGIN;
-- Chunk E: comparison tables + glossary + checklists (part 4/4)
INSERT INTO checklist_sections (checklist_id, section_title, items_json, display_order)
SELECT cl.id, v.section_title, v.items_json, v.display_order
FROM (VALUES
  (7, 'Substrate / Underfoot', '["Walk-test for soft / spongy areas"]'::jsonb, 6),
  (7, 'Coating Compatibility (if existing coating present)', '["Any prior coating? If yes, note chemistry indicators","Coating condition"]'::jsonb, 7),
  (7, 'Severity Quick Reference', '["Monitor: light surface granule loss; minor biological staining","Maintenance: moderate granule loss; minor sealant work; debris removal","Repair: seam separation; blistering; punctures; failed pipe boot; flashing failures","Urgent / Escalate: active interior leak; soft underfoot; widespread alligatoring; widespread seam failure on aged systems"]'::jsonb, 8),
  (7, 'Important Reminder', '["USA Flat Roof installs only self-adhered modified bitumen","Existing torch-down or hot-mopped roofs may be inspected and repaired, but like-for-like replacement requires escalation or referral"]'::jsonb, 9),
  (8, 'Layer Count Assessment (the central question)', '["Inspect cross-sections at edges, terminations, or cut areas","Estimate layer count from visible evidence","Review any building documentation","Ask customer / property manager about prior recover history","If layer count cannot be confirmed: escalate"]'::jsonb, 1),
  (8, 'Surface Inspection', '["Surface type: gravel-surfaced / smooth asphalt / coated","Gravel displacement and bald spots (where gravel-surfaced)","Surface alligatoring (smooth or coated areas)","Blistering","Ply separation visible at edges"]'::jsonb, 2),
  (8, 'Penetrations and Details', '["Every pipe, vent, drain, curb, skylight","Pitch pans — sealant condition (high-failure detail)","Flashings — asphalt-based and metal"]'::jsonb, 3),
  (8, 'Drainage', '["Drains, scuppers, overflow","Ponding evidence"]'::jsonb, 4),
  (8, 'Substrate / Underfoot', '["Walk-test for soft / spongy areas — common on aged BUR","Any visible deflection"]'::jsonb, 5),
  (8, 'Building Age and Asbestos Consideration', '["Building installation pre-1980s? — asbestos testing required before any tear-off or major disturbance","Document age and any prior testing history"]'::jsonb, 6),
  (8, 'Solar Array Consideration', '["PV present? — coordination required for any restoration or replacement scope"]'::jsonb, 7),
  (8, 'Severity Quick Reference', '["Monitor: light gravel displacement; surface dirt","Maintenance: debris removal; gravel redistribution; minor sealant","Repair: moderate alligatoring; failed pipe boot; pitch pan sealant failure; flashing failures","Urgent / Escalate: active interior leak; soft underfoot; multiple layers; pre-1980s building (asbestos); structural deflection; widespread blistering or ply separation"]'::jsonb, 8),
  (8, 'Recommendation Framework Reminder', '["Single-layer BUR with sound substrate: silicone restoration / TPO overlay / SPF / replacement (per Chapter 9)","Multi-layer or disqualifying conditions: typically full replacement"]'::jsonb, 9),
  (9, 'Coating Identification and Substrate', '["Confirm coating chemistry (silicone vs acrylic — see Chapter 7)","If documentation unavailable, note visual indicators","Identify substrate underneath coating (visible at edges, drains, worn areas)"]'::jsonb, 1),
  (9, 'Coating Condition', '["Surface dirt and biological staining","Chalking (rub-finger test)","Coating thinning or wear in ponded areas","Coating delamination (peeling, lifting)","Coating cracking","Substrate failure visible through coating"]'::jsonb, 2),
  (9, 'Detail Inspection', '["Coating wrap at penetrations, parapets, drains","Fabric reinforcement areas — exposure or lift","Stripe / detail coat condition"]'::jsonb, 3),
  (9, 'Drainage', '["Ponding evidence in coated areas","Drain condition"]'::jsonb, 4),
  (9, 'Substrate / Underfoot', '["Walk-test for soft / spongy areas"]'::jsonb, 5),
  (9, 'Severity Quick Reference', '["Monitor: light dirt; surface staining","Maintenance: chalking; biological growth; surface wear approaching recoat window","Repair: localized delamination; coating cracking; detail-coat failure; substrate visible through worn coating","Urgent / Escalate: active interior leak; widespread delamination; substrate failure under intact coating; soft underfoot; coating applied over non-qualifying substrate"]'::jsonb, 6),
  (9, 'Recommendation Framework Reminder', '["Existing silicone in serviceable condition: maintenance recoat","Damaged coating: repair","Failed coating with substrate issues: replacement scope"]'::jsonb, 7),
  (10, 'System Identification', '["Confirm SPF (orange-peel texture; visible foam thickness at terminations)","Distinguish from silicone-coated single-ply or BUR (Chapter 17)"]'::jsonb, 1),
  (10, 'Topcoat-Specific Inspection', '["Topcoat color and condition","Chalking (rub-finger test)","Thin or worn areas","Any topcoat damage exposing foam — yellow / tan foam visible","Walk pad coverage and condition","Topcoat at penetrations, parapets, details"]'::jsonb, 2),
  (10, 'Foam-Specific Inspection', '["Any exposed foam areas (UV degradation indicator)","Foam darkening, surface deterioration, friability","Bird or rodent damage","Hail damage (impact craters)","Suspected installation voids (tap test, hollow areas)"]'::jsonb, 3),
  (10, 'Drainage', '["Ponding evidence — particularly important on SPF if installed for ponding correction","Tapered drainage at drains still functioning?","Drain condition"]'::jsonb, 4),
  (10, 'Detail and Penetration Inspection', '["Cracking or pulling at drain rings, pipe penetrations, curbs","Sealant repairs or unauthorized modifications"]'::jsonb, 5),
  (10, 'Substrate Inspection', '["Walk-test for soft / spongy areas — wet substrate indicator","Visible substrate failure or deflection"]'::jsonb, 6),
  (10, 'Maintenance History', '["Original SPF installation date if known","Last topcoat recoat date","Maintenance and repair records"]'::jsonb, 7),
  (10, 'Severity Quick Reference', '["Monitor: surface dirt; light topcoat staining","Maintenance: chalking; topcoat thinning approaching recoat schedule; minor walk-pad wear","Repair: topcoat damage exposing foam; localized foam damage; failed detail; bird or impact damage","Urgent / Escalate: active interior leak; widespread topcoat failure with exposed foam; widespread foam degradation; suspected voids; soft underfoot; PV array"]'::jsonb, 8),
  (10, 'Important Reminder', '["Topcoat recoat is part of standard SPF maintenance, not emergency repair","The foam can last 25+ years when topcoat is maintained"]'::jsonb, 9),
  (11, 'Pre-Visit', '["Review prior inspection reports and findings","Note any conditions previously rated Monitor or Maintenance","Confirm equipment and access"]'::jsonb, 1)
) AS v(checklist_number, section_title, items_json, display_order)
JOIN checklists cl ON cl.checklist_number = v.checklist_number;
INSERT INTO checklist_sections (checklist_id, section_title, items_json, display_order)
SELECT cl.id, v.section_title, v.items_json, v.display_order
FROM (VALUES
  (11, 'During Visit', '["Conduct full inspection per the relevant system checklist","Compare current conditions to prior inspection","Note any condition that has progressed to a higher severity level","Note any new conditions","Address maintenance items within scope: cleaning, debris removal, sealant refresh, fastener resealing, drain clearing, walk-pad inspection","Photograph current conditions for warranty and documentation purposes"]'::jsonb, 2),
  (11, 'Documentation', '["Photo update on all major conditions","Severity ratings applied","Note any items that have crossed into Repair Recommended or Urgent territory","Confirm warranty registration documentation if applicable"]'::jsonb, 3),
  (11, 'Customer Conversation', '["Walk through any progression in conditions","Identify any items requiring proposal beyond maintenance scope","Schedule next maintenance visit","Address any customer questions or concerns"]'::jsonb, 4)
) AS v(checklist_number, section_title, items_json, display_order)
JOIN checklists cl ON cl.checklist_number = v.checklist_number;
COMMIT;
