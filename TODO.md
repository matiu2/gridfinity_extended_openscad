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
- Hole depth: not one depth. Each hole stops 1 mm (5 layers at 0.2 mm)
  above whatever solid is under it, done by intersecting the hole columns
  with a copy of the cup raised by that 1 mm. Over a foot a hole is 9.45 mm
  deep (bottom at Z = 1.0); over a gap between feet it is 5.45 mm
  (bottom at Z = 5.0), because the floor spanning the gap sits higher.
  Earlier a single 8.45 mm depth broke through in the three lengthways
  gaps between the feet.
- Undrilled strips across the short way at X = 0, +/-21, over the joins
  between the four feet, matching the lengthways strip down the middle.
  These are exactly where a hole had no foot beneath it, so with them in
  place every remaining hole is full depth and nothing is shallow.
  `strip_width` is 4.8 mm, the measured gap between feet at the z = 1 hole
  bottom level -- not a standard, just the gap. Dropping whole columns
  rounds the finished strips up to 6.72 mm at the centre and 9.26 mm at the
  outer joins; they differ because 21 mm is not a multiple of 2.54 mm.
- `strip_margin` (0.4 mm, one nozzle) keeps a hole from landing on the edge
  of a foot, where the depth clip would slice it into an unprintable sliver.
  Verified: all 220 holes come out exactly 0.9 x 0.9 mm.
- The hole grid is centred on the part, not the cavity. The cavity is
  0.05 mm off centre in X, which made the strips asymmetric.
- Breadboard middle: left as solid deck, not cut as a groove. Rows sit at
  +/-(1.5 + n) * 2.54 so the two innermost rows are 7.62 mm apart (the
  0.3 inch DIP pin spacing) with an undrilled strip between them, like the
  centre divider of a breadboard. An earlier version cut a 5 mm trench there;
  removed on request.

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
- [x] 0.9 mm square holes on a 2.54 mm pitch, 28 columns x 10 rows
- [x] Holes clipped per position: bottoms verified at Z = 1.0 over feet and
      Z = 5.0 over the gaps, nothing breaking through the underside
- [x] Centre strip left solid, verified as no gap in the deck plane
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

## Possible follow-ups (not requested)
- Chamfer the hole mouths slightly so legs self-centre when pushed in.
- A matching lid, or a version with the channel running the short way.
