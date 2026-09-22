# TODO — Breadboard-hole electronics box

Gridfinity cup, 84 x 42 x 21 mm (2x1 grid units, half-pitch base pads), no
label, no magnets/screws, with a raised inner floor drilled like a
breadboard so component legs can be pushed in.

File: `breadboard_box.scad`

## Measured facts (verified against rendered geometry, not assumed)
- Outer size 83.49 x 41.50 mm (84 x 42 less the 0.5 mm clearance),
  Z 0 .. 24.74 mm (21 mm body + 3.74 mm stacking lip).
- Foot stack 0.8 + 1.8 + 2.15 = 4.75 mm, plus the 0.7 mm cup floor
  -> stock inner floor at Z = 5.45 mm.
- The cavity just above the floor is X -38.0 .. 37.9, Y -17.0 .. 17.0.
  The wall is thicker than `wall_thickness` there because of the taper, and
  the cavity is 0.05 mm off centre in X. Both are taken from a measured
  cross-section rather than derived.
- With subPitch = 2 the feet are a 4 x 2 grid of 21 mm pads. At Z = 0.4 the
  clear channels between feet are X = 0, +/-21, +/-42 (5.61 mm) and
  Y = 0 (5.62 mm).

## Decisions
- Centre strip: 6 mm of solid deck, hole edge to hole edge, measured off the
  user's own breadboard. That puts the two innermost rows 6.9 mm apart
  centre to centre, a little under the 7.62 mm (0.3 inch) DIP standard, but
  it matches what components actually sit in. Off the 2.54 mm grid by
  design: the grid can only give 4.18 or 6.72 mm.
- Only the one lengthways strip. No strips over the joins between the feet.
- Hole depth is per hole, flat bottomed, at one of two levels: z = 1.0 where
  there is foot underneath (9.45 mm deep), z = 5.75 where there is not
  (4.7 mm deep, stopping above the gap between the feet).
  Earlier versions clipped the hole columns against a raised copy of the
  cup, which sliced any hole straddling the edge of a foot into a 0.1-0.4 mm
  sliver. Choosing a flat bottom per hole avoids that entirely; verified
  that all 300 holes come out exactly 0.9 x 0.9 mm.
- `foot_gap` is the 4.8 mm measured gap plus 0.8 mm of margin, so a hole
  landing on the edge of a pad is treated as unsupported rather than
  breaking through the corner of a foot.
- Chamfered mouths, 1.5 mm across and 0.3 mm deep, guide a component leg
  into each hole. A chamfer rather than a rounded fillet because the sloped
  wall prints without overhang.
- The holes are cut with three extrusions (deep shafts, shallow shafts, and
  the chamfer slices) rather than a pair of solids per hole. Six hundred
  primitives overflows OpenCSG, and preview (F5) then shows nothing at all
  with "CSG normalization resulted in an empty tree", while the F6 render
  stays correct. The chamfer is built as 0.2 mm slices stepping outward
  because linear_extrude's scale works about the origin, so a scaled
  extrude per hole would need 300 more primitives.

## Stage 1 — plain box  [DONE]
- [x] `breadboard_box.scad` wrapping `gridfinity_cup`
- [x] 2x1 grid units = 84 x 42 mm, height 3 units = 21 mm
- [x] `subPitch = 2` -> 21 mm base pads (half units in x + y)
- [x] label disabled; no magnets, no screws
- [x] Renders clean, STL measured at 83.49 x 41.50 x 24.74 mm

## Stage 2 — raised floor + breadboard holes  [DONE]
- [x] Inner floor raised 5 mm, to Z = 10.45
- [x] Slab trimmed by intersecting a solid (`filled_in`) cup, so it meets
      the tapered wall with no gap and no bulge
- [x] 0.9 mm square holes on a 2.54 mm pitch, continuous across the deck
- [x] Per hole flat bottoms at Z = 1.0 or Z = 5.75, all holes exactly
      0.9 x 0.9 mm, genus 0 so nothing breaks through the underside
- [x] Centre strip left solid, verified at exactly 6.00 mm
- [x] Chamfered lead-in mouths on every hole
- [x] Renders manifold, dimensions and pitch verified from the STL

## Notes for next time
- OpenSCAD resolves `include`/`use` relative to the script's own directory,
  so probe scripts must live in the project root, not in `.build/`.
- The preview renderer drops sub-pixel features: early top views appeared to
  show only 6 columns when all 28 were present. Verify counts from the STL,
  not from the image.

## Print settings assumed
- 0.4 mm nozzle, 0.2 mm layers. Clearances are chosen as whole layer
  multiples (1 mm = 5 layers). The 0.9 mm holes are narrower than the
  nozzle, so expect them to print round and a little tight, which suits
  gripping legs; raise `hole_size` to 1.0-1.1 if they close up.

## Stage 3 - sliding panels  [DONE]
- [x] All four walls slide out. `panel_walls` selects which; [0] gives just
      the front. Openings inset 6 mm from each cavity end.
- [x] Openings run from the deck right to the top of the part, THROUGH the
      stacking lip, so the rim does not bridge across and trap a panel.
      Each panel carries its own section of rim.
- [x] Two detents per groove: one near the bottom, one just under the rim.
      The upper one holds the pillars together at the top, which the lip
      would otherwise have done.
- [x] Corner pillars 9.74 mm, keeping 6.74 mm of material between the two
      grooves that meet at each corner. The deck slab ties all four
      pillars together at the bottom.
- [x] Groove in each pillar, 3 mm deep, for the panel edges
- [x] Panel 1.6 mm thick in a 2.2 mm slot, 0.3 mm clearance per side. The
      slot is CENTRED in the 3.75 mm wall, leaving 0.775 mm of skin either
      side; an earlier version put it 1 mm in from the outer face and left
      only 0.55 mm inboard, too thin.
- [x] Detent ridges in each groove. They must be anchored ON the outboard
      face of the groove so half the cylinder is buried in the wall skin.
      Placed anywhere else they render as separate floating bodies - watch
      the body count, not just the genus.
- [x] `part` selects box / panel / both; `panel_enabled` reverts to a plain
      four-walled box
- [x] Two panel sizes: 69.30 x 1.60 x 27.99 mm for the long walls, 27.40
      wide for the short ends. Both engage 2.7 mm into each pillar.
- [x] In the "both" layout each panel is translated 25 mm straight out from
      its wall, so the five parts are disconnected bodies. STL carries no
      part names, so physical separation is the only way a slicer can split
      the file into objects; left in place the panels touch at the corners
      and the whole thing imports as one body.
- [x] Deck and hole grid untouched: the opening starts at the deck, so no
      holes are cut and the deck keeps its support

## Possible follow-ups (not requested)
- Chamfer the hole mouths slightly so legs self-centre when pushed in.
- A matching lid, or a version with the channel running the short way.
