BEGIN;
-- Chunk E: comparison tables + glossary + checklists (part 2/4)
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Acceptable ponding', 'Water that drains within 48 hours of rain stopping. The industry standard threshold for ponding that is not considered problematic.', '["Chapter 16","Module 3"]'::jsonb),
  ('Acrylic coating', 'Liquid-applied roof coating using acrylic chemistry. Lower cost than silicone, less ponding tolerance, more recoat flexibility with other chemistries. USA Flat Roof recognizes but does not typically lead with acrylic.', '["Chapter 7"]'::jsonb),
  ('Aging signs', 'Observable indicators that a roof is moving through its service life: granule loss on shingles, chalking on coatings, plasticizer migration on PVC, blistering on modified bitumen, and similar system-specific patterns.', '[]'::jsonb),
  ('Aluminum-pigmented asphalt coating', 'Older reflective coating applied over BUR or modified bitumen. 2–5 year life-extension product, not a true restoration system. Recognized but not typically proposed by USA Flat Roof.', '[]'::jsonb),
  ('Apron flashing', 'Metal flashing at the downslope side of a chimney or curb, redirecting water away from the penetration.', '["Chapter 15"]'::jsonb),
  ('Architectural and era lens', 'Recognition heuristic using the home''s architectural style and construction era to anticipate likely roof system before inspection.', '["Chapter 18"]'::jsonb),
  ('Architectural shingle', 'Composition shingle with two layers bonded together creating a dimensional, shadowed appearance. Industry standard on new residential installs since the 2000s.', '["Chapter 1"]'::jsonb),
  ('Asbestos', 'Fibrous mineral commonly used in pre-1980s roofing materials. Requires testing before disturbance and abatement procedures during tear-off on older buildings.', '["Chapter 9"]'::jsonb),
  ('Asphalt cement', 'Plastic-bodied asphalt-based sealant used for repairs on BUR and modified bitumen.', '["Chapter 6","Chapter 9"]'::jsonb),
  ('Asphalt squeeze-out', 'Visible asphalt bead at seams where torch-down or hot-mopped modified bitumen has been installed. Distinguishes torch-down from cleaner self-adhered seams.', '["Chapter 6","Chapter 17"]'::jsonb),
  ('Attic ventilation', 'System of intake vents (typically at soffits) and exhaust vents (typically at ridge or upper roof) that allows air to flow through an attic, preventing heat and moisture buildup.', '["Chapter 14"]'::jsonb),
  ('Authorization tier', 'A company-defined level of decision-making authority granted to a sales rep, indicating what they may and may not commit to without escalation.', '[]'::jsonb),
  ('Backer rod', 'Closed-cell foam rod placed in joints before sealant application to control depth and improve sealant performance.', '[]'::jsonb),
  ('Balanced ventilation', 'Attic ventilation configuration with appropriate proportions of intake and exhaust, allowing air to move through the full attic space.', '["Chapter 14"]'::jsonb),
  ('Base sheet', 'First ply in a multi-ply roof system, attached to the substrate as the foundation for subsequent plies.', '[]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Bird stop', 'Closure detail at the eave on tile roofs preventing birds and pests from entering under tiles.', '["Chapter 8"]'::jsonb),
  ('Blistering', 'Bubble or bubble-cluster formation in roof membranes, typically caused by trapped moisture or air. Common on modified bitumen and BUR.', '["Chapter 6","Chapter 9"]'::jsonb),
  ('Boot (pipe boot)', 'Flexible flashing component that wraps around a roof penetration (vent stack, plumbing pipe) to seal against the membrane or shingle.', '["Chapter 15"]'::jsonb),
  ('Brittleness', 'Loss of flexibility in roofing materials due to age, UV exposure, or chemistry change. Indicates advanced aging.', '[]'::jsonb),
  ('Building-use lens', 'Recognition heuristic using the building''s purpose (restaurant, cold storage, etc.) to anticipate likely roof system.', '["Chapter 17"]'::jsonb),
  ('BUR (Built-Up Roofing)', 'Multi-ply asphalt-and-felt roofing system, often gravel-surfaced. Long field track record. USA Flat Roof restores, recovers, or replaces but does not install new BUR.', '["Chapter 9"]'::jsonb),
  ('Cap sheet', 'Top ply of a multi-ply roof system, often granule-surfaced for UV protection.', '[]'::jsonb),
  ('Chalking', 'White powder appearance on coating surfaces, indicating UV-driven surface degradation. Approaching recoat window.', '["Chapter 3","Chapter 10"]'::jsonb),
  ('Chronic ponding', 'Water that consistently persists beyond 48 hours after rain. Disqualifies most restoration coatings.', '["Chapter 16","Module 3"]'::jsonb),
  ('Clay tile', 'Roofing tile made of fired clay (terracotta). Distinctive aesthetic, very long tile life, separate underlayment. Outside USA Flat Roof''s standard scope.', '["Chapter 18"]'::jsonb),
  ('Coating', 'Liquid-applied roof material that cures into a continuous waterproof layer on the roof surface. Includes silicone, acrylic, and aluminum-pigmented chemistries.', '["Chapter 3","Chapter 7"]'::jsonb),
  ('Coating chemistry', 'The base resin or material composition of a coating product, e.g., silicone, acrylic, polyurethane. Compatibility between coating chemistries during recoat is not guaranteed.', '["Chapter 3","Chapter 7"]'::jsonb),
  ('Composition shingle', 'Asphalt-based shingle with mineral granule surface. Most common residential roof system in the United States.', '["Chapter 1"]'::jsonb),
  ('Compression', 'In ventilation, the loss of insulation R-value when compressed; in flat-roof systems, the loss of slope when tapered insulation is crushed by foot traffic or equipment.', '["Chapter 14","Chapter 16"]'::jsonb),
  ('Conductive heat transfer', 'Heat moving through solid materials. One of the modes ventilation manages.', '[]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Coping', 'Top covering of a parapet wall, typically metal, designed to shed water and protect the wall assembly.', '["Chapter 15"]'::jsonb),
  ('Core sample', 'Small cross-section cut into a roof assembly to confirm layer count, substrate, or moisture content. Production team task.', '["Chapter 17"]'::jsonb),
  ('Counter-flashing', 'Metal flashing installed over a base flashing (such as step flashing) to direct water away and protect the joint.', '["Chapter 15"]'::jsonb),
  ('Cricket', 'Sloped diversion built behind a chimney or curb to direct water around the obstruction.', '["Chapter 15"]'::jsonb),
  ('Cross-section inspection', 'Examining edges, terminations, or cut areas to assess multi-ply construction or substrate.', '["Chapter 17"]'::jsonb),
  ('Curb (HVAC curb)', 'Raised platform on which rooftop equipment is mounted, requiring its own flashing details.', '["Chapter 15"]'::jsonb),
  ('Daylight visible', 'Light visible through small openings, indicating gaps in the roof or flashing assembly. Common attic-side indicator of penetration failures.', '[]'::jsonb),
  ('Deck', 'The structural surface beneath the roofing system. Wood sheathing on residential; concrete, metal, or wood on commercial.', '[]'::jsonb),
  ('Decoy option', 'In Good/Better/Best presentations, a tier included only to make another tier look more reasonable. Manipulative practice.', '["Module 10"]'::jsonb),
  ('Designer shingle', 'Premium composition shingle, typically multi-layer, designed to mimic slate, shake, or other specialty materials.', '["Chapter 1"]'::jsonb),
  ('Detail coat', 'Reinforced coating layer at penetrations, transitions, and other high-stress areas, typically applied with embedded fabric.', '["Chapter 3","Chapter 10"]'::jsonb),
  ('Detail repair', 'Targeted repair work at penetrations, transitions, or specific failure locations rather than field-wide repair.', '[]'::jsonb),
  ('Disqualifying conditions', 'Specific conditions that make a roof unsuitable for restoration: wet insulation, chronic ponding, widespread substrate failure, asbestos, end-of-life condition, etc.', '["Chapter 13","Table 6"]'::jsonb),
  ('Drain ring (clamping ring)', 'Metal ring that clamps a flat-roof membrane to a roof drain.', '["Chapter 16"]'::jsonb),
  ('Drip edge', 'Metal flashing at the eave designed to direct water into the gutter rather than back behind the gutter into the fascia.', '["Chapter 15"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Drone inspection', 'Aerial photography of a roof using a drone, valuable for multi-story commercial, tile roofs, and complex geometries. Supplements but does not replace hands-on inspection.', '["Chapter 12","Module 7"]'::jsonb),
  ('Edge drainage', 'Flat-roof drainage off an unparapeted edge into a gutter.', '["Chapter 16"]'::jsonb),
  ('Efflorescence', 'White mineral deposits on masonry surfaces, indicating water has been moving through the masonry. Common around chimney bases.', '[]'::jsonb),
  ('Elevation (building elevation)', 'Each face of the building (north, south, east, west). Documented during inspection.', '["Chapter 12"]'::jsonb),
  ('End-of-life', 'Stage at which a roof system has exhausted its useful service life and replacement is the appropriate scope.', '["Chapter 13"]'::jsonb),
  ('EPDM (Ethylene Propylene Diene Monomer)', 'Single-ply rubber roof membrane, almost always black. Common on older commercial buildings nationally; smaller share of NorCal commercial. Limited USA Flat Roof scope.', '[]'::jsonb),
  ('Escalation', 'Process of routing a finding, condition, or customer scenario beyond the rep''s authorization to a senior estimator, production manager, or qualified inspector.', '[]'::jsonb),
  ('Exhaust ventilation', 'Outflow point of an attic ventilation system, typically at the ridge or upper roof.', '["Chapter 14"]'::jsonb),
  ('Fabric reinforcement', 'Embedded fabric (typically polyester) used in coating systems at high-stress areas to bridge cracks, reinforce seams, and improve performance.', '[]'::jsonb),
  ('Fanfold', 'Insulation board used as a recover layer over BUR before TPO overlay, providing a smooth substrate.', '["Chapter 9"]'::jsonb),
  ('Fascia', 'Vertical board at the eave of a residential roof, behind which the gutter typically attaches.', '[]'::jsonb),
  ('Field range', 'The range of years a roof system typically performs in actual NorCal conditions, accounting for variation in installation, ventilation, exposure, and maintenance.', '["Module 1","Table 3"]'::jsonb),
  ('Fishmouth', 'Localized seam separation forming a small bubble or open pocket. Common single-ply seam failure.', '["Chapter 2","Chapter 5"]'::jsonb),
  ('Flashing', 'Metal or membrane component that directs water away from joints, transitions, and penetrations.', '["Chapter 15"]'::jsonb),
  ('Foam (SPF)', 'See Spray Polyurethane Foam.', '[]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Four-step decision tree (commercial)', 'Quick-recognition process for commercial flat-roof systems: surface color → seam type → surface texture → edge appearance.', '["Chapter 17"]'::jsonb),
  ('Four-step decision tree (residential)', 'Quick-recognition process for residential steep-slope systems: shape and weight → surface texture → tap sound → age and architectural context.', '["Chapter 18"]'::jsonb),
  ('Fresh Roof', 'USA Flat Roof''s brand for rejuvenation services. Manufacturer-specific product applied to qualifying composition shingle roofs.', '["Chapter 4"]'::jsonb),
  ('Granule broadcast', 'Application of mineral granules onto a wet coating to add walkability, aesthetic, or warranty-required surfacing.', '[]'::jsonb),
  ('Granule loss', 'Erosion of the protective mineral granules from composition shingle surfaces, indicating aging. Significant granule loss with exposed asphalt is an aging marker.', '["Chapter 1"]'::jsonb),
  ('Gutter', 'Channel along the eave of a residential roof that collects rainwater and directs it to downspouts.', '["Chapter 16"]'::jsonb),
  ('Hail damage', 'Impact damage from hail, characterized by craters, soft spots, or granule displacement on shingles; impact bruising on membranes. Certification requires qualified inspector.', '["Module 6"]'::jsonb),
  ('Headwall flashing', 'Flashing where a sloped roof meets a vertical wall above (e.g., where a lower roof meets the higher house wall).', '["Chapter 15"]'::jsonb),
  ('Honest-versus-easy moment', 'Recurring scenario where the rep can take an easier sale (writing a proposal that won''t perform, capitulating to a customer''s preferred but inappropriate scope) or hold the line on the honest answer.', '["Chapter 13","Module 13"]'::jsonb),
  ('Insulation upgrade', 'Adding insulation thickness during a roof recover or replacement, typically to meet code, energy targets, or to add R-value. One of three USA Flat Roof SPF use cases.', '["Chapter 10"]'::jsonb),
  ('Intake ventilation', 'Inflow point of an attic ventilation system, typically at the soffit.', '["Chapter 14"]'::jsonb),
  ('Interior leak evidence', 'Stains, drips, or moisture damage visible from inside the building. Documented during inspection.', '["Chapter 12"]'::jsonb),
  ('Internal drain', 'Roof drain located within the roof field, with piping carrying water through the building''s interior.', '["Chapter 16"]'::jsonb),
  ('Kettle asphalt', 'Heated asphalt used in hot-mopped BUR or modified bitumen installation. Not used by USA Flat Roof on new installs.', '[]'::jsonb),
  ('Kick-out flashing', 'Small piece of flashing at the bottom of a sidewall step flashing line that diverts water away from the wall and into the gutter. Frequently missing on older homes.', '["Chapter 15"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Layer count', 'Number of distinct roofing systems on a building. Central inspection question on BUR substrates for recover decisions.', '["Chapter 9","Chapter 17"]'::jsonb),
  ('Lead-qualification questions', 'Initial conversation with the customer to establish history, concerns, and goals before inspection.', '["Chapter 12"]'::jsonb),
  ('Leak entry point', 'The actual location where water enters the roof assembly. Rarely directly above the visible interior damage.', '["Chapter 11","Module 2"]'::jsonb),
  ('Lifetime warranty', 'Warranty term commonly used in marketing for shingles. Typically structured as a non-prorated period followed by prorated coverage that decreases over time.', '["Module 12"]'::jsonb),
  ('Maintenance program', 'Subscription or recurring service offering for ongoing roof care. Captures customers who don''t need major work today and supports long-term relationship.', '["Module 13"]'::jsonb),
  ('Manager Review Checklist', 'Section at the end of each chapter listing items the manager should verify before publication.', '[]'::jsonb),
  ('Manufacturer system warranty (NDL)', 'Stronger manufacturer warranty available when full system is installed by certified contractor following specifications. NDL = No Dollar Limit.', '["Module 12"]'::jsonb),
  ('Mil', 'One-thousandth of an inch. Standard unit for membrane and coating thickness.', '["Chapter 2"]'::jsonb),
  ('Mixed-roof home', 'Residential home with both pitched and flat-roof sections. Requires both Chapter 17 and Chapter 18 recognition skills.', '["Chapter 18"]'::jsonb),
  ('Modified bitumen', 'Asphalt-based multi-ply roofing system with polymer modifiers. Available in self-adhered, torch-down, or hot-mopped installation methods; USA Flat Roof installs only self-adhered.', '["Chapter 6"]'::jsonb),
  ('Monitor (severity rating)', 'Lowest severity level on the four-point scale; condition warrants documentation and re-inspection but no immediate action.', '["Chapter 12"]'::jsonb),
  ('Monolithic', 'Single continuous seamless layer. Characteristic of coatings and SPF.', '["Chapter 17"]'::jsonb),
  ('Mortar (tile roofing)', 'Mortar used at ridge and hip lines on tile roofs. Subject to deterioration and a common maintenance item.', '["Chapter 8"]'::jsonb),
  ('NDL (No Dollar Limit)', 'See manufacturer system warranty.', '[]'::jsonb),
  ('Orange-peel texture', 'Characteristic surface texture of cured SPF foam. Most reliable visual identifier.', '["Chapter 10","Chapter 17"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Overflow drain (overflow scupper)', 'Secondary drainage at higher elevation than primary, intended to handle water if primary clogs. Required by code on most commercial flat roofs.', '["Chapter 16"]'::jsonb),
  ('Overlay (recover)', 'Installation of a new roof system over an existing one. Code typically permits one overlay before tear-off becomes required.', '["Chapter 13"]'::jsonb),
  ('Parapet', 'Low wall extending above the roof line on a commercial building. Often involves complex flashing details.', '["Chapter 15"]'::jsonb),
  ('Penetration', 'Anything that passes through the roof: pipes, vents, drains, conduit, skylights, etc.', '["Chapter 15"]'::jsonb),
  ('Phased work', 'Approach where a roof scope is divided into stages, addressing the most urgent items first and planning the broader scope later. Honest alternative when budget doesn''t support full scope.', '["Chapter 13","Module 11"]'::jsonb),
  ('Pitch pan', 'Sealed enclosure used at irregular penetrations on BUR and similar systems. Sealant-dependent; high-failure detail.', '["Chapter 9","Chapter 15"]'::jsonb),
  ('Plasticizer migration', 'Aging mechanism in PVC where plasticizers leach out, causing stiffening and brittleness. Visible on aged PVC (15+ years).', '["Chapter 5"]'::jsonb),
  ('Ply', 'Individual layer of a multi-ply roofing system.', '[]'::jsonb),
  ('Ponding', 'Water remaining on a roof beyond the time intended by design. Acceptable up to 48 hours; problematic beyond.', '["Chapter 16","Module 3"]'::jsonb),
  ('Ponding ring', 'Dirt accumulation pattern marking where water has been sitting on the roof. Most reliable indicator of past ponding on a dry roof.', '["Chapter 16"]'::jsonb),
  ('Primer (coating)', 'Preparatory coat applied before main coating, designed to improve adhesion and substrate compatibility.', '["Chapter 3"]'::jsonb),
  ('Profile', 'The shape and configuration of a roof covering: three-tab, architectural, S-tile, barrel, etc.', '["Chapter 1","Chapter 8"]'::jsonb),
  ('Prorated coverage', 'Warranty coverage that decreases over time. Common on shingle ''lifetime'' warranties.', '["Module 12"]'::jsonb),
  ('PVC (Polyvinyl Chloride)', 'Single-ply thermoplastic roof membrane; premium positioning; chemical-resistant.', '["Chapter 5"]'::jsonb),
  ('R-value', 'Measure of thermal resistance of insulation. Higher R-value = better insulation.', '[]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Recover (overlay)', 'See overlay.', '[]'::jsonb),
  ('Reference scale', 'An object included in a photo to indicate size: business card, tape measure, ruler, chalk mark.', '["Module 7"]'::jsonb),
  ('Rejuvenation', 'Chemical treatment that absorbs into asphalt shingles to replace lost oils and extend service life. USA Flat Roof''s brand: Fresh Roof.', '["Chapter 4"]'::jsonb),
  ('Repair', 'Targeted fix of a specific failure on a roof that otherwise has remaining service life.', '["Chapter 13"]'::jsonb),
  ('Repair-plus-plan', 'Conversation pattern where the rep addresses the immediate issue and surfaces the broader situation honestly.', '["Chapter 11","Module 9"]'::jsonb),
  ('Replacement', 'Full removal of the existing roof down to the deck and installation of a new system.', '["Chapter 13"]'::jsonb),
  ('Restoration', 'Adding a layer to extend the useful service life of a roof. Usually a coating; can include rejuvenation.', '["Chapter 13"]'::jsonb),
  ('Ridge cap', 'Course of shingles or specialized component at the peak of a sloped roof.', '["Chapter 1"]'::jsonb),
  ('Ridge vent', 'Continuous exhaust ventilation at the ridge of a sloped roof.', '["Chapter 14"]'::jsonb),
  ('Roll-out test', 'Walk-test on a flat roof to identify soft or spongy areas suggesting wet insulation or substrate failure.', '[]'::jsonb),
  ('Sales rep boundary', 'Recurring callout in the book identifying tasks or judgments that exceed the rep''s role and require escalation.', '[]'::jsonb),
  ('Scupper', 'Opening through a parapet wall for drainage.', '["Chapter 16"]'::jsonb),
  ('Seam (membrane seam)', 'Joint between two pieces of membrane material. Welded on TPO and PVC; asphalt-bonded on modified bitumen; glued or taped on EPDM.', '[]'::jsonb),
  ('Self-adhered', 'Installation method where the membrane has a peel-and-stick backing. The only modified bitumen installation method USA Flat Roof uses on new installs.', '["Chapter 6"]'::jsonb),
  ('Severity scale', 'The four-point inspection rating used throughout this book: Monitor, Maintenance Needed, Repair Recommended, Urgent / Escalate.', '["Chapter 12"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
INSERT INTO glossary_terms (term, definition, references_json) VALUES
  ('Short-circuit (ventilation)', 'Pattern where two exhaust types (e.g., gable vents and ridge vents on the same roof) pull from each other instead of pulling air through the full attic.', '["Chapter 14"]'::jsonb),
  ('Sidewall flashing', 'Flashing where a sloped roof meets a vertical wall to the side. Includes step flashing and counter-flashing.', '["Chapter 15"]'::jsonb),
  ('Silicone coating', 'High-build liquid-applied roof coating using silicone chemistry. Excellent ponding tolerance, UV-resistant. USA Flat Roof''s primary restoration product.', '["Chapter 3"]'::jsonb),
  ('Single-ply', 'Roof system using a single layer of membrane (TPO, PVC, EPDM).', '[]'::jsonb),
  ('Slope (flat-roof)', 'The intentional minor slope (typically 1/4 inch per foot or less) built into flat-roof design to direct water toward drainage.', '["Chapter 16"]'::jsonb),
  ('Soffit', 'The horizontal underside of a roof eave, typically containing intake vents on residential homes.', '["Chapter 14"]'::jsonb),
  ('SPF (Spray Polyurethane Foam)', 'Sprayed foam roofing system, applied with a topcoat. Three USA Flat Roof use cases: ponding correction, BUR recover, insulation upgrade.', '["Chapter 10"]'::jsonb),
  ('Stack pattern', 'Typical sequence of original system + recovers/coatings over time on a commercial roof.', '["Chapter 17"]'::jsonb),
  ('Step flashing', 'Stepped metal flashing at the sidewall of a sloped roof, with each piece overlapping the one below.', '["Chapter 15"]'::jsonb),
  ('Stone-coated metal', 'Metal roof panels with stone-coated surface designed to mimic shake or tile. Specialty trade; outside USA Flat Roof''s standard scope.', '["Chapter 18"]'::jsonb),
  ('Substrate', 'The existing roof beneath a coating, recover, or new system.', '["Chapter 17"]'::jsonb),
  ('Synthetic / composite tile or slate', 'Manufactured tile- or slate-look roofing made of polymer, rubber, or composite materials. Lighter than real tile or slate. Limited USA Flat Roof scope.', '["Chapter 18"]'::jsonb),
  ('Tab (three-tab shingle)', 'Visible cutout segments on three-tab composition shingles creating the three-tab pattern.', '["Chapter 1"]'::jsonb),
  ('Tap test', 'Light tapping on roofing materials to distinguish concrete (dull thud), clay (ring), synthetic (plastic pop), or metal (metallic).', '["Chapter 8","Chapter 18"]'::jsonb),
  ('Tapered insulation', 'Insulation manufactured or installed with thickness variation to create slope. Alternative to SPF taper for ponding correction.', '["Chapter 16"]'::jsonb)
ON CONFLICT (term) DO UPDATE SET
  definition = EXCLUDED.definition,
  references_json = EXCLUDED.references_json;
COMMIT;
