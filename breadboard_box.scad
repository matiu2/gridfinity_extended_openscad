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
// in. 1.5 leaves 1.04 mm of deck between neighbouring mouths, and at 45
// degrees makes the lead-in 0.3 mm deep.
mouth_size = 1.5;
lead_in = (mouth_size - hole_size) / 2;
// Printer layer height. The chamfer is built as slices this thick, which is
// how it comes out of the slicer regardless.
layer_height = 0.2;

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
// Gap each side of the panel inside its groove. Generous, because PETG
// prints fat and a sliding fit that is too tight is unusable.
panel_clearance = 0.3;
// How far the opening is inset from each end of the cavity. What is left
// either side becomes the corner pillar the groove is cut into.
panel_inset = 6;
// How deep the groove cuts into each pillar, i.e. how much of the panel
// edge is captured.
groove_depth = 3;
// A bump partway up the groove that the panel clicks past, so it does not
// slide out when the box is tipped or carried.
detent_size = 0.4;
// How far the panel sinks into a recess in the floor below the deck. This
// recess is what locks the panel down: it captures the bottom edge, which a
// thin panel cannot flex away from.
panel_sink = 1;

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

// A set of holes as a single extrusion from its shared bottom to the deck.
module hole_shafts(positions, bottom) {
  if (len(positions) > 0)
    translate([0, 0, bottom])
      linear_extrude(height = deck_z - bottom + 0.01)
        hole_squares(positions);
}

// Every hole is given a flat bottom at one of two levels, rather than being
// clipped against the cup. Clipping sliced any hole straddling the edge of
// a foot into a fragment too thin to print.
module breadboard_holes() {
  hole_shafts(deep_holes, base_clearance);
  hole_shafts(shallow_holes, foot_height + base_clearance);
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

// Slot the panel runs in, centred in the wall so there is a similar skin of
// material either side rather than a sliver on one.
slot_width = panel_thickness + 2 * panel_clearance;
wall_skin = (wall_thickness - slot_width) / 2;

// The panel runs from the bottom of the floor recess to the top of the rim.
panel_height = part_top - deck_z + panel_sink;

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
    // The rim above the opening goes with the panel, so clear it from the
    // box across the panel's width plus its sliding clearance.
    translate([o[0] - groove_depth, -1, body_top])
      cube([pw + 2 * panel_clearance, wall_thickness + 2, lip_rise + 1]);
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
    for (e = [0, 1])
      translate([o[0] - groove_depth + e * (wall_width(w) + groove_depth),
                 wall_skin, deck_z - panel_sink + detent_size])
        rotate([0, 90, 0])
          cylinder(h = groove_depth, r = detent_size, $fn = 16);
}

module panel_voids() { for (w = panel_walls) panel_void_one(w); }
module panel_detents() { for (w = panel_walls) panel_detents_one(w); }

// One panel, in the position it occupies in the box. Built here rather than
// flat so that the top can be intersected with the cup, which gives the
// panel the lip's own stepped profile and keeps the rim continuous when all
// the panels are in.
module panel_in_place(w) {
  o = wall_opening(w);
  pw = panel_width_of(w);
  // The flat part of the panel, from just above the deck up to the body
  // top. It rests a clearance above the deck rather than on it, both so the
  // panel drops in without binding and so the two stay separate bodies.
  in_wall(w)
    translate([o[0] - groove_depth + panel_clearance,
               wall_skin + panel_clearance,
               deck_z - panel_sink + panel_clearance])
      cube([pw, panel_thickness,
            body_top - deck_z + panel_sink - panel_clearance]);
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
                 wall_skin + panel_clearance, body_top])
        cube([pw, panel_thickness, lip_rise + 1]);
  }
}

// One panel, still in its place in the box, with the notches cut that let
// it sit over the detents when fully home.
// The notches are cut oversize by the sliding clearance, so that as
// modelled the panel and the box never touch and stay separate bodies. In
// the printed parts the detent still stands proud of the notch walls, and
// the panel flexes over it on the way in.
module panel_notched(w) {
  difference() {
    panel_in_place(w);
    in_wall(w)
      for (e = [0, 1])
        translate([wall_opening(w)[0] - groove_depth
                     + e * (wall_width(w) + groove_depth),
                   wall_skin, deck_z - panel_sink + detent_size])
          rotate([0, 90, 0])
            cylinder(h = groove_depth + 1, r = detent_size + panel_clearance,
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
        }
        if (panel_enabled) panel_voids();
      }
      // Added back after the void, so they sit proud inside the groove.
      if (panel_enabled) panel_detents();
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
