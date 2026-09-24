// Gridfinity box for storing electronics pushed into breadboard-style holes.
//
//   - 2 x 1 grid units (42 mm), giving 84 x 42 mm
//   - base pads at half pitch (21 mm), so it sits on half-unit grid offsets
//   - height 5 units of 7 mm = 35 mm, 38.74 mm including the stacking lip
//   - no label holder, no magnet or screw holes in the feet
//   - inner floor raised, then drilled on a 2.54 mm breadboard grid with a
//     solid undrilled strip down the middle
//
// Geometry notes, measured from the rendered model:
//   The foot stack is 0.8 + 1.8 + 2.15 = 4.75 mm and the cup floor is
//   0.7 mm, so the stock inner floor sits at Z = 5.45 mm.
//
//   The middle strip is left solid, like the centre divider of a
//   breadboard. The two hole rows either side of it are 7.62 mm apart, the
//   0.3 inch DIP pin spacing, so a chip straddles the strip with each row
//   of pins in its own holes.

include <modules/gridfinity_constants.scad>
use <modules/module_gridfinity_cup.scad>

/* [Size] */
// X dimension, in grid units of 42 mm.
width = [2, 0];
// Y dimension, in grid units of 42 mm.
depth = [1, 0];
// Z dimension, in grid units of 7 mm.
height = [5, 0];

/* [Breadboard] */
// How far to raise the inner floor above the stock cup floor.
floor_rise = 5;
// Width of the square holes.
hole_size = 0.9;
// Centre to centre spacing, 0.1 inch.
hole_pitch = 2.54;
// Keep this much solid material under every hole. Over a foot that means
// clearance above the table; over a gap between feet it means thickness
// above open air. 1 mm is 5 layers at 0.2 mm.
base_clearance = 1;
// Margin from the cavity wall to the outermost hole.
hole_margin = 0.5;
// Solid strip down the middle, hole edge to hole edge. Measured off a real
// breadboard at 6 mm, which is what components are built to sit in.
centre_gap = 6;
// Width of the chamfered mouth at the top of each hole, which guides a leg
// in. At 45 degrees the lead-in is half the difference from hole_size, so
// 2.0 gives a 0.55 mm lead-in and leaves 0.54 mm of flat deck between
// neighbouring mouths - just over one extrusion, so the deck still prints
// as a surface. This is about the practical maximum: the mouths meet at
// 2.54 and a 1 mm lead-in would need a 2.9 mm mouth, wider than the pitch.
mouth_size = 2.0;
lead_in = (mouth_size - hole_size) / 2;
// Printer layer height. The chamfer is built as slices this thick, which is
// how it comes out of the slicer regardless.
layer_height = 0.2;

/* [Hole grip] */
// The holes taper inwards going down, so a leg pushed in wedges and is held
// rather than falling out when the bin is tipped. Set equal to hole_size to
// turn the taper off.
//
// This is now the ONLY grip mechanism. An earlier version cut the deck into
// long thin ribs meant to act as springs; printed, they gripped well but
// the solid skin above them had nothing to anchor to and dropped loose
// strands across the holes, which had to be picked out one at a time with a
// needle. Not worth it - see rib_slot below.
hole_size_bottom = 0.6;
// Straight section at the top of each hole before the taper begins. Zero
// means the hole narrows from the deck surface all the way down, which is
// what you want with a solid deck: the leg meets a gently closing hole
// rather than a step. It was 1 mm when the ribs existed, to keep the top of
// the hole clear of them.
deck_skin = 0;
// Below the skin the deck is cut into long parallel ribs by continuous
// slots running the length of the box, one in each gap between rows of
// holes. Each rib carries a whole row and is anchored only at its two ends,
// so it bows along its full ~69 mm rather than being caged in a 2.54 mm
// cell. Beam deflection goes as length cubed, so a rib is thousands of
// times more compliant than a per-hole wall of the same thickness - the
// difference between technically flexing and actually springing.
//
// This replaced a per-hole pocket scheme, which barely flexed because every
// wall was welded to its neighbours at each crossing in both axes.
//
// 0.6 leaves 1.94 mm ribs with 0.52 mm of material either side of a hole.
// That 0.52 is sized to survive the slicer's xy_hole_compensation, which
// this model NEEDS: without it a 0.9 mm hole gets a full perimeter bead
// round it and prints with only ~0.06 mm of opening, far too small for a
// component leg. Compensation of 0.2 takes 0.1 mm from each side, leaving
// 0.42 mm - one extrusion, still printable.
//
// This is the binding constraint in the whole design. On a 2.54 mm pitch
// the cell budget is hole + wall + wall + slot, and at 0.8 slots the wall
// dropped to 0.32 mm after compensation and the ribs broke into posts.
// Set to 0 for a solid deck.
// OFF. The ribs worked mechanically - components gripped noticeably better
// - but the solid deck skin above them had nothing to anchor to and printed
// loose strands criss-crossing the holes, first in the corners and then in
// the middle. Clearing them needed a needle in every hole, which is more
// work than the grip was worth. 15% infill in the band reduced it but did
// not fix it. Set to 0.6 to bring them back.
rib_slot = 0;

/* [Sliding panel] */
// Set false for a plain box with four solid walls.
panel_enabled = true;
// Which walls slide out: 0 front (-Y), 1 back (+Y), 2 left (-X), 3 right
// (+X). All four by default; [0] gives just the front.
panel_walls = [0, 1, 2, 3];
// Which part to render.
//   assembled - panels seated in the box, as it ends up in use. The lip
//               reads as continuous, which is what the carry box's roof and
//               floor plugins grip. One connected body, not for printing.
//   print     - the same five parts with each panel moved clear of the box,
//               so a slicer can split the STL into objects. STL carries no
//               part names, so separation is the only signal it has.
//   box       - just the box; panel - just the panels.
part = "print"; // [assembled, print, box, panel]
// Thickness of the panel itself.
panel_thickness = 1.6;
// Gap each side of the panel inside its groove.
//
// Small on purpose. The panel is printed FLAT, so its 1.6 mm thickness is 8
// layers of 0.2 and comes out accurate; the slot is an XY feature on a box
// printed upright, which is the looser axis. On top of that the slicer runs
// xy_hole_compensation = 0.2 for the 0.9 mm breadboard holes, and that
// widens this slot too - so 0.1 modelled lands near 0.2 per side printed,
// and the 0.3 this started at landed near 0.4 per side, which rattles.
//
// Raise it if the panels bind; the printed fit is roughly this plus 0.1.
panel_clearance = 0.1;
// Gap used only to keep the panel a separate body from the box in the
// model, where two touching solids would fuse into one. Nothing to do with
// the printed fit, so it stays put when panel_clearance is tuned. It has to
// survive STL rounding, so do not take it below about 0.05.
panel_model_gap = 0.15;
// How far the opening is inset from each end of the cavity. What is left
// either side becomes the corner pillar the groove is cut into.
panel_inset = 6;
// How deep the groove cuts into each pillar, i.e. how much of the panel
// edge is captured.
groove_depth = 3;
// A bump partway up the groove that the panel clicks past, so it does not
// slide out when the box is tipped or carried.
//
// OFF by default. Printed, these stopped the panel going in at all: they
// were sized when the clearance was 0.3 mm per side and the panel could
// rattle. At 0.1 mm modelled - nearer 0.2 printed, once the slicer's hole
// compensation has widened the slot - friction against the slot and the
// pillars' 1 mm wrap already hold the panel, so the bumps only got in the
// way. Set to 0.4 to bring them back if a panel ever works loose.
detent_size = 0;
// Square pillars at each end of a panel, standing at the very edge of the
// box. These are the corner, fattened: the groove is cut into them, so the
// pillar wraps the panel on three sides rather than the wall holding it.
// Set to 0 to leave them off and fall back to a plain slot.
hug_size = 3;
// How far the pillar wraps back over the panel's inner face. This lip is
// what holds the panel in: it has to be crossed to get the panel out
// sideways, which it cannot do, so the only way out is straight up.
hug_intrusion = 1;
// How far the panel's outer face sits inside the box's outer surface. The
// pillar needs material on both sides of the panel to form a channel, and
// this is the outboard half of it. Without it the slot would break out
// through the side of the box.
panel_recess = 1;
// How far the panel sinks into a recess in the floor below the deck. This
// recess is what locks the panel down: it captures the bottom edge, which a
// thin panel cannot flex away from.
panel_sink = 1;
// Lead-in chamfer at the top of the channel, flaring it open so the panel
// can be aimed roughly and still find the slot. Coming down from above the
// panel meets nothing until body_top and then hits a square edge, which
// makes a 2.2 mm slot a blind target; this turns it into a funnel.
// Measured across the slot, per side, at the mouth.
//
// Capped by what the skin can spare. The outboard skin and the inboard wrap
// are both 1 mm, and the chamfer thins them at the mouth; 0.4 mm leaves
// 0.6 mm, which is still over one 0.4 mm extrusion width. Taking the full
// 0.8 mm would leave 0.2 mm, thinner than the nozzle can lay down, and the
// slicer would simply drop it.
panel_lead_in = 0.4;
// How far down the chamfer runs. Taller is easier to aim into but eats the
// grip at the top of the panel, so keep it a small fraction of the height.
panel_lead_in_depth = 2.5;

/* [Model detail] */
fa = 6;
fs = 0.4;

$fa = fa;
$fs = fs;

// Stock cup floor height: foot stack plus the printed floor.
foot_height = gf_cupbase_lower_taper_height
            + gf_cupbase_riser_height
            + gf_cupbase_upper_taper_height;
floor_z = foot_height + gf_cup_floor_thickness;

// The drilled surface, and how deep the holes may run.
deck_z = floor_z + floor_rise;
hole_depth = deck_z - base_clearance;

// The cavity, measured from a cross-section of the stock cup just above the
// floor. The wall is thicker than the nominal wall_thickness at this height
// because of the taper, and the cavity is a whisker off centre in X, so
// these are taken from the model rather than derived.
cavity_x = [-38.0, 37.9];
cavity_y = [-17.0, 17.0];
inner_x = cavity_x[1] - cavity_x[0];
inner_y = cavity_y[1] - cavity_y[0];

// The hole grid is centred on the part, not on the cavity, so that it stays
// symmetric about the feet and the strips over the joins between them. The
// cavity is 0.05 mm off centre in X, which is not worth chasing.
mid_x = 0;
mid_y = 0;

// The innermost rows sit either side of the centre gap, then the rest march
// outward on pitch. The gap is set by measurement off a real breadboard
// rather than by the grid, so the two innermost rows are centre_gap +
// hole_size apart, which is 6.9 mm: a little under the 7.62 mm of the 0.3
// inch DIP standard, but it is what components actually sit in.
// Distance from the middle to the first row of holes, in mm.
row_offset = (centre_gap + hole_size) / 2;
rows = floor((inner_y / 2 - hole_margin - hole_size / 2 - row_offset) / hole_pitch) + 1;
cols = floor((inner_x / 2 - hole_margin - hole_size / 2) / hole_pitch - 0.5) + 1;

// Hole centres, mirrored either side of the middle in both axes. The grid
// runs right across the joins between the feet; holes over a join simply
// come out shallower, which the depth clip handles.
hole_xs = [for (sx = [-1, 1]) for (i = [0 : cols - 1]) mid_x + sx * (0.5 + i) * hole_pitch];
hole_ys = [for (sy = [-1, 1]) for (j = [0 : rows - 1]) mid_y + sy * (row_offset + j * hole_pitch)];

// Where the feet are, so a hole can tell whether it has one underneath.
// The feet are a grid of pads pitch/sub_pitch across, centred on the part;
// between them is a gap that is widest at the bottom and closes as it
// rises. A hole sitting wholly over a pad can go deep; one that overlaps a
// gap at all must stop above it, or the clip would slice it into a sliver.
pad_pitch = gf_pitch / 2;
// The gap measures 4.8 mm at the z = 1 hole bottom, plus a margin so a hole
// that lands right on the edge of a pad is treated as unsupported rather
// than breaking through the corner of the foot.
foot_gap = 4.8 + 0.8;

// True when the hole at c is clear of every gap between pads on that axis.
function over_pad(c, n) =
  let (nearest = round(c / pad_pitch) * pad_pitch)
  abs(c - nearest) > (foot_gap + hole_size) / 2 || abs(nearest) > n * pad_pitch;

// Bottom of the hole at (x, y): down to the table clearance when there is
// foot under it, otherwise stopping base_clearance above the top of the
// foot stack, which is where the gap between the feet has closed.
function hole_bottom(x, y) =
  over_pad(x, 2) && over_pad(y, 1) ? base_clearance : foot_height + base_clearance;

// Every hole position, split by which of the two bottom levels it takes.
// Grouping them this way lets the whole set be cut with three extrusions
// rather than one pair of solids per hole. Six hundred primitives overflows
// the preview renderer, which then shows nothing at all ("CSG normalization
// resulted in an empty tree"); the final F6 render was always correct.
deep_holes = [for (x = hole_xs) for (y = hole_ys)
                if (hole_bottom(x, y) == base_clearance) [x, y]];
shallow_holes = [for (x = hole_xs) for (y = hole_ys)
                   if (hole_bottom(x, y) != base_clearance) [x, y]];

// The square openings of a set of holes, as one 2D shape.
module hole_squares(positions) {
  for (p = positions) translate(p) square(hole_size, center = true);
}

// A set of holes as extrusions from their shared bottom to the deck.
//
// The top deck_skin is a straight shaft at full hole_size - that is the
// solid surface you see from above, and a leg enters it without resistance.
// Everything below tapers down to hole_size_bottom, so the leg wedges as it
// goes in and is held when the bin is tipped.
//
// The taper has to be built one hole at a time, because linear_extrude's
// scale is about the ORIGIN, not about each shape in a 2D union - extruding
// the whole grid with a scale flings the copies outwards. So each tapered
// shaft is extruded at the origin and then translated into place. That is
// one primitive per hole, which is what overflows the preview renderer, so
// the result is wrapped in render() to collapse it to a single mesh.
module hole_shafts(positions, bottom) {
  if (len(positions) > 0) {
    // The straight part, still one extrusion for the whole set. Skipped
    // when deck_skin is 0, where it would be a degenerate sliver and the
    // taper runs from the deck surface instead.
    if (deck_skin > 0)
      translate([0, 0, deck_z - deck_skin])
        linear_extrude(height = deck_skin + 0.01)
          hole_squares(positions);
    // The tapered part below it.
    taper_h = deck_z - deck_skin - bottom;
    if (taper_h > 0)
      render()
        for (p = positions)
          translate([p[0], p[1], bottom])
            linear_extrude(height = taper_h + 0.01,
                           scale = hole_size / hole_size_bottom)
              square(hole_size_bottom, center = true);
  }
}

// The deck cut into long parallel ribs by continuous slots.
//
// One slot in each gap between rows of holes, running the whole length of
// the cavity. What is left is a set of ribs, each carrying one row of
// holes and anchored only at its two ends against the cavity walls.
//
// This is the point of the shape: a rib bows over its full ~69 mm span
// when a leg is pushed into one of its holes, where a per-hole wall is
// welded to its neighbours at every crossing and is caged within 2.54 mm.
// Deflection goes as the cube of the span, so the rib is thousands of
// times more compliant for the same wall thickness.
//
// The slots stay buried under deck_skin, so from above the deck still
// reads as a solid surface. The skin bridges each slot, which prints
// cleanly at this width.
module deck_hollow() {
  if (rib_slot > 0) {
    floor_skin = 0.6;
    z0 = floor_z + floor_skin;
    z1 = deck_z - deck_skin;
    // Slot centres sit in the gaps between adjacent hole rows. Consecutive
    // rows one pitch apart get a slot between them; the pair either side of
    // the undrilled centre strip are further apart and are skipped, so that
    // strip stays solid.
    ys = [for (j = [0 : len(hole_ys) - 2])
            if (abs(hole_ys[j + 1] - hole_ys[j]) < hole_pitch * 1.5)
              (hole_ys[j] + hole_ys[j + 1]) / 2];
    if (z1 > z0)
      intersection() {
        translate([0, 0, z0])
          linear_extrude(height = z1 - z0)
            for (y = ys)
              translate([0, y]) square([inner_x + 10, rib_slot], center = true);
        // Stop short of the cavity walls so the ribs stay anchored at both
        // ends and the slots cannot reach the panel grooves.
        translate([cavity_x[0] + 2, cavity_y[0] + 2, 0])
          cube([inner_x - 4, inner_y - 4, deck_z + 1]);
      }
  }
}

// Every hole is given a flat bottom at one of two levels, rather than being
// clipped against the cup. Clipping sliced any hole straddling the edge of
// a foot into a fragment too thin to print.
module breadboard_holes() {
  hole_shafts(deep_holes, base_clearance);
  hole_shafts(shallow_holes, foot_height + base_clearance);
  deck_hollow();
  // The chamfered mouths, built as a stack of thin slices that step outward
  // towards the deck. A chamfer rather than a rounded fillet because the
  // sloped wall prints without overhang, where a true radius would need
  // support at the lip. Sliced rather than scaled because linear_extrude
  // scales about the origin, and doing it per hole puts enough primitives
  // in the tree to overflow the preview renderer.
  all_holes = concat(deep_holes, shallow_holes);
  steps = ceil(lead_in / layer_height);
  for (i = [0 : steps - 1])
    translate([0, 0, deck_z - lead_in + i * lead_in / steps])
      linear_extrude(height = lead_in / steps + 0.01)
        offset(delta = (i + 1) * lead_in / steps)
          hole_squares(all_holes);
}

// The same cup rendered solid. Intersecting against this trims a shape to
// the cup's outline, tapered wall and corner radii included.
module solid_cup() {
  set_environment(
    width = width,
    depth = depth,
    height = height,
    lip_enabled = true,
    render_position = "center")
  gridfinity_cup(
    filled_in = "enabled",
    label_settings = LabelSettings(labelStyle = "disabled"),
    lip_settings = LipSettings(lipStyle = "normal", lipNotch = true),
    cupBase_settings = CupBaseSettings(
      magnetSize = [0, 0],
      screwSize = [0, 0],
      subPitch = 2));
}

// --- Sliding panels ------------------------------------------------------
//
// Each of the four walls is replaced by a panel that slides straight up and
// out, running in grooves cut into the corner pillars either side. The
// openings start at the deck, so the hole grid and its support are
// untouched, and run right to the top of the part so the stacking lip does
// not bridge across and trap a panel. Each panel therefore carries its own
// section of rim, and a detent just below the rim holds the pillars
// together at the top the way the lip otherwise would.

body_top = height[0] * gf_zpitch;
// Measured, not derived: the lip constants sum to 5.6 but the rendered lip
// stands 3.74 mm above the body.
lip_rise = 3.74;
part_top = body_top + lip_rise;

// Outer faces of the part, and the wall thickness, measured from a
// cross-section. The wall is the same thickness all the way up.
wall_outer = [(width[0] * gf_pitch - 0.5) / 2, (depth[0] * gf_pitch - 0.5) / 2];
wall_thickness = wall_outer[1] - cavity_y[1];

// Slot the panel runs in. It is pushed out to sit panel_recess inside the
// box's outer surface, rather than centred in the wall, so that the panel
// reads as part of the outside face and the pillar has room on the inboard
// side to wrap back over it. wall_skin is the material left outboard of the
// slot, measured from the wall's outer face inward.
slot_width = panel_thickness + 2 * panel_clearance;
wall_skin = panel_recess;

// The panel runs from the bottom of the floor recess to the top of the rim.
panel_height = part_top - deck_z + panel_sink;

// Heights of the detents up the groove. One in the floor recess catching
// the panel's bottom edge, which is the one that actually locks it; the
// others spaced up the groove to stop the middle of a long panel bowing
// out. Absolute Z, not relative to the panel.
recess_floor = deck_z - panel_sink;
detent_heights = [recess_floor + detent_size,
                  recess_floor + panel_height * 0.4,
                  recess_floor + panel_height * 0.75];

// For wall w (0 = front -Y, 1 = back +Y, 2 = left -X, 3 = right +X):
// is it a long wall, which way does it face, and how wide is its opening?
function wall_is_long(w) = w < 2;
function wall_sign(w) = (w % 2) == 0 ? -1 : 1;
// Along-wall extent of the cavity, and of the opening cut into it.
function wall_span(w) = wall_is_long(w) ? cavity_x : cavity_y;
function wall_opening(w) =
  [wall_span(w)[0] + panel_inset, wall_span(w)[1] - panel_inset];
function wall_width(w) = wall_opening(w)[1] - wall_opening(w)[0];
function panel_width_of(w) =
  wall_width(w) + 2 * groove_depth - 2 * panel_clearance;

// Places the children in the frame of wall w: x runs along the wall, y runs
// outward through its thickness from the slot's inner face.
// Rotation that brings each wall to the front, facing -Y: front stays put,
// back turns 180, left and right turn 90 either way. A rotation rather than
// a mirror, so the handedness is the same for every wall and geometry
// borrowed from the cup (the rim) lines up with the rest.
function wall_rotation(w) = [0, 180, 270, 90][w];

module in_wall(w) {
  rotate([0, 0, wall_rotation(w)])
    translate([0, -wall_outer[wall_is_long(w) ? 1 : 0], 0])
      children();
}

// The void one panel occupies: the window through the wall, plus the slot
// running on into the pillar at each end.
module panel_void_one(w) {
  o = wall_opening(w);
  pw = panel_width_of(w);
  in_wall(w) {
    // The window: the whole wall thickness, between the pillars.
    translate([o[0], -1, deck_z])
      cube([wall_width(w), wall_thickness + 1, panel_height + 1]);
    // The slot, continuing into each pillar, and sunk panel_sink below the
    // deck so the panel drops into a recess in the floor. The recess is
    // what locks the panel: it holds the bottom edge in the one direction a
    // thin panel cannot flex out of.
    translate([o[0] - groove_depth, wall_skin, deck_z - panel_sink])
      cube([wall_width(w) + 2 * groove_depth, slot_width,
            panel_height + panel_sink + 1]);
    // Lead-in chamfer at the top of the channel. The slot's mouth is
    // flared open by panel_lead_in on each face, narrowing back to the
    // slot proper panel_lead_in_depth further down, so a panel offered up
    // roughly square is walked into place instead of having to be lined up
    // with a 2.2 mm target by eye.
    //
    // It runs the whole length of the slot, pillars included: the pillars
    // are where the panel is tightest, so they are exactly where the funnel
    // is worth having. hull() of the two rectangles gives the taper.
    if (panel_lead_in > 0)
      translate([o[0] - groove_depth, 0, 0])
        hull() {
          translate([0, wall_skin - panel_lead_in, body_top])
            cube([wall_width(w) + 2 * groove_depth,
                  slot_width + 2 * panel_lead_in, 0.01]);
          translate([0, wall_skin, body_top - panel_lead_in_depth])
            cube([wall_width(w) + 2 * groove_depth, slot_width, 0.01]);
        }
    // The rim above the opening goes with the panel, so clear it from the
    // box across the panel's width plus its sliding clearance, through the
    // whole wall thickness.
    //
    // The whole thickness matters: the panel's own rim section has to reach
    // the outer surface, because those sections and the corners together
    // are what make the lip read as one continuous profile for the carry
    // box's plugins. Leaving a skin of box standing outboard here breaks
    // the lip into islands - the corners and each panel's rim separately.
    translate([o[0] - groove_depth, -1, body_top])
      cube([pw + 2 * panel_clearance, wall_thickness + 2, lip_rise + 1]);
  }
}

// The corner pillars, fattened where the panel slides into them. Each one
// runs from the box's outer surface inward far enough to cover the slot and
// then wrap hug_intrusion back over the panel's inner face. The slot itself
// is cut out of these by panel_void_one, so what is left is a U-channel:
// material outboard of the panel, material inboard of it, and the solid
// end of the pillar closing the channel off. That is what "the corners hold
// the groove" means - the panel is captured by the corner, not by the wall.
//
// Drawn in section, looking down, at one end of a panel:
//
//     outer surface
//     ---------------+
//      recess  |     |
//      PANEL   |     |  <- slot, cut away
//      wrap    |     |
//     ---------+     |  <- pillar closes the end
//               inside
module panel_huggers_one(w) {
  o = wall_opening(w);
  // How far in from the outer surface the pillar reaches. The channel only
  // needs recess + slot + wrap, but the pillar is taken all the way back to
  // the wall's inner face so the corner is a solid block rather than a
  // sleeve with a void behind it. Solid prints better, gives the wrap
  // something to be stiff against, and costs only the corner volume.
  depth = max(wall_skin + slot_width + hug_intrusion, wall_thickness);
  // The pillar spans the whole run of slot cut into the corner, plus
  // hug_size of solid material past the end of it. The part over the slot
  // becomes the wrap that holds the panel; the part past the end closes the
  // channel off. Sizing it to the slot alone would let the slot cut the
  // whole pillar away, leaving the thin outboard skin and no channel.
  span = groove_depth + hug_size;
  // The pillar is in two pieces vertically, because the panel's rim has to
  // pass through the lip section and the pillar cannot be in its way.
  //
  //   deck .. body_top   the full pillar, over the slot and past its end.
  //                      This is the channel that holds the panel.
  //   body_top .. top    only the part beyond the slot, where no panel rim
  //                      travels. That is the corner proper, and taking it
  //                      up to the lip is what fills the gap that was left
  //                      when the whole pillar stopped at body_top.
  //
  // Both are intersected with the cup so nothing stands proud of the lip's
  // profile, which the carry box's roof and floor plugins grip.
  intersection() {
    solid_cup();
    union() {
      in_wall(w)
        for (e = [0, 1])
          translate([e == 0 ? o[0] - span : o[1], 0, deck_z - panel_sink])
            cube([span, depth, body_top - (deck_z - panel_sink)]);
      // The corner block above, sitting outboard of the rim cut so the
      // panel's own rim section still runs clear to the outer surface.
      // The rim cut reaches groove_depth + panel_clearance past the
      // opening, so the block starts there and runs to the pillar's end.
      rim_end = groove_depth + panel_clearance;
      in_wall(w)
        for (e = [0, 1])
          translate([e == 0 ? o[0] - span : o[1] + rim_end, 0, body_top])
            cube([span - rim_end, depth, lip_rise + 1]);
    }
  }
}

// The four corner squares, filled solid.
//
// Each wall's pillar reaches its own end of the cavity and stops, so the
// square where two walls meet is left hollow: the slot for one wall is cut
// straight through it, and nothing fills in behind. It shows up from above
// as a void between the outer skin and the neighbouring wall's pillar.
//
// Filling it costs nothing - it is outside every panel's travel, outside
// the hole grid, and clipped to the cup so it follows the rounded outside
// corner - and it ties the two pillars of each corner into one block.
module panel_corner_fill() {
  intersection() {
    solid_cup();
    // Built from explicit outer limits rather than cavity + thickness. The
    // cavity is not symmetric in X (-38.00 against +37.90), so growing a
    // fixed-size block from each cavity corner overshoots on one side and
    // leaves a zero-thickness sliver that renders as a separate body.
    // The inboard faces are pulled back by eps so they do not land exactly
    // on the cavity boundary the raised floor already ends at. Coincident
    // faces there make CGAL emit a degenerate zero-thickness shell, which
    // shows up as a stray 10-triangle body flat in the y = 17 plane.
    for (sx = [-1, 1], sy = [-1, 1])
      let (eps = 0.01,
           x0 = sx < 0 ? -wall_outer[0] - 1 : cavity_x[1] - eps,
           x1 = sx < 0 ? cavity_x[0] + eps : wall_outer[0] + 1,
           y0 = sy < 0 ? -wall_outer[1] - 1 : cavity_y[1] - eps,
           y1 = sy < 0 ? cavity_y[0] + eps : wall_outer[1] + 1)
        translate([x0, y0, deck_z - panel_sink])
          cube([x1 - x0, y1 - y0, part_top - (deck_z - panel_sink) + 1]);
  }
}

// Half-round ridges across the slot, just above the floor recess, that the
// bottom edge of the panel clicks down past. Putting them here rather than
// against the panel's face means the panel is held by its edge, which it
// cannot flex away from, instead of by friction on a face a 1.6 mm sheet
// bows out of easily. They run along the slot's outboard wall so there is
// a skin of material to bury half of each cylinder in.
module panel_detents_one(w) {
  o = wall_opening(w);
  in_wall(w)
    for (e = [0, 1], h = detent_heights)
      translate([o[0] - groove_depth + e * (wall_width(w) + groove_depth),
                 wall_skin, h])
        rotate([0, 90, 0])
          cylinder(h = groove_depth, r = detent_size, $fn = 16);
}

module panel_voids() { for (w = panel_walls) panel_void_one(w); }
module panel_detents() {
  if (detent_size > 0) for (w = panel_walls) panel_detents_one(w);
}
module panel_huggers() {
  if (hug_size > 0) for (w = panel_walls) panel_huggers_one(w);
}

// One panel, in the position it occupies in the box. Built here rather than
// flat so that the top can be intersected with the cup, which gives the
// panel the lip's own stepped profile and keeps the rim continuous when all
// the panels are in.
module panel_in_place(w) {
  o = wall_opening(w);
  pw = panel_width_of(w);
  // Offset that centres the panel across the slot.
  centred = (slot_width - panel_thickness) / 2;
  // The flat part of the panel, from just above the deck up to the body
  // top. It is centred across the slot and stands panel_model_gap off the
  // recess floor, so that as modelled it touches the box nowhere and the
  // two stay separate bodies. That gap is a modelling concern only - the
  // printed fit comes from panel_clearance, which sizes the slot.
  in_wall(w)
    translate([o[0] - groove_depth + panel_clearance,
               wall_skin + centred,
               deck_z - panel_sink + panel_model_gap])
      cube([pw, panel_thickness,
            body_top - deck_z + panel_sink - panel_model_gap]);
  // The rim section on top, taken from the cup itself so the profile
  // matches the lip either side of it exactly. The cup is shrunk by the
  // clearance first, so the panel's rim is a touch inside the box's and the
  // two do not fuse into one body.
  intersection() {
    solid_cup();
    // Confined to the slot, like the rest of the panel, so it does not eat
    // into the skin of wall the box keeps outboard of the slot.
    in_wall(w)
      translate([o[0] - groove_depth + panel_clearance,
                 wall_skin + centred, body_top])
        cube([pw, panel_thickness, lip_rise + 1]);
  }
}

// One panel, still in its place in the box, with the notches cut that let
// it sit over the detents when fully home.
// The notches are cut oversize by panel_model_gap, so that as modelled the
// panel and the box never touch and stay separate bodies. In the printed
// parts the detent still stands proud of the notch walls, and the panel
// flexes over it on the way in.
// With detent_size 0 there are no detents, so the panel stays a plain sheet
// rather than carrying scallops for bumps that are not there.
module panel_notched(w) {
  difference() {
    panel_in_place(w);
    if (detent_size > 0)
    in_wall(w)
      for (e = [0, 1], h = detent_heights)
        translate([wall_opening(w)[0] - groove_depth
                     + e * (wall_width(w) + groove_depth),
                   wall_skin, h])
          rotate([0, 90, 0])
            cylinder(h = groove_depth + 1, r = detent_size + panel_model_gap,
                     $fn = 16);
  }
}

// Everything is left where it belongs in the box. The panels are separate
// bodies sitting in their slots, so the whole thing renders as one model
// with the rim continuous, and the slicer splits it into parts to print.
module sliding_panel(w = 0) { panel_notched(w); }

module raised_floor() {
  // A slab filling the cavity from the stock floor up to the new deck.
  // Oversized then trimmed to the cup, so it meets the tapered wall with
  // no gap and no bulge.
  intersection() {
    translate([cavity_x[0] - 3, cavity_y[0] - 3, floor_z - 0.01])
      cube([inner_x + 6, inner_y + 6, floor_rise + 0.01]);
    solid_cup();
  }
}

module box() {
  difference() {
    union() {
      difference() {
        union() {
          set_environment(
            width = width,
            depth = depth,
            height = height,
            lip_enabled = true,
            render_position = "center")
          gridfinity_cup(
            label_settings = LabelSettings(labelStyle = "disabled"),
            lip_settings = LipSettings(lipStyle = "normal", lipNotch = true),
            cupBase_settings = CupBaseSettings(
              magnetSize = [0, 0],
              screwSize = [0, 0],
              // Half pitch: each 42 mm cell becomes four 21 mm pads.
              subPitch = 2));
          raised_floor();
          // Before the void, not after: the slot is cut through the
          // pillars, which is what turns them into the U-channel that
          // holds the panel. Adding them afterwards would fill it in.
          if (panel_enabled) panel_huggers();
        }
        if (panel_enabled) panel_voids();
      }
      // Added back after the void, so they sit proud inside the groove.
      if (panel_enabled) panel_detents();
      // Also after the void: the slot is cut clear through the corner
      // square on its way into the pillar, so filling the corner before the
      // cut would just have it carved out again. Safe to add afterwards
      // because the corner square is outside every panel's travel.
      if (panel_enabled) panel_corner_fill();
    }
    breadboard_holes();
  }
}

// How far each panel is moved straight out from its wall in the "print"
// layout. Only needs to beat the corner radius for the panels to come away
// cleanly, but a wide gap makes them unambiguously separate bodies, which
// is what lets a slicer split the STL into parts (STL carries no part
// names, so separation is the only signal).
panel_explode = 25;

// Moves the children out along wall w's own outward direction: front -Y,
// back +Y, left -X, right +X. Zero in the assembled view.
module explode(w) {
  d = part == "assembled" ? 0 : panel_explode;
  translate([[0, -1, 0], [0, 1, 0], [-1, 0, 0], [1, 0, 0]][w] * d)
    children();
}

if (part == "box" || !panel_enabled) {
  box();
} else if (part == "panel") {
  // Panels only, spread apart so each is its own body.
  for (w = panel_walls) explode(w) sliding_panel(w);
} else {
  box();
  for (w = panel_walls) explode(w) sliding_panel(w);
}
