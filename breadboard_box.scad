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
// Which part to render. "box" and "panel" give one printable part each,
// "both" lays them out side by side on the plate.
part = "both"; // [box, panel, both]
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
detent_height = 6;

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

// --- Sliding panel -------------------------------------------------------
//
// One long wall is replaced by a panel that slides straight up and out,
// running in a groove cut into the corner pillars either side. The opening
// starts at the deck, so the hole grid and its support are untouched.

// The wall is 3.75 mm thick and the same all the way up, measured from a
// cross-section, so the groove has room to sit inside it.
body_top = height[0] * gf_zpitch;
// The front wall runs from the outer face to the cavity. The slot sits
// inside it, set in from the outer face so a skin of wall is left outboard
// of the panel.
wall_outer_y = -(depth[0] * gf_pitch - 0.5) / 2;
wall_thickness = cavity_y[0] - wall_outer_y;
// Centre the slot in the wall, so there is a similar skin of material on
// each side of it rather than a sliver on one.
wall_skin = (wall_thickness - (panel_thickness + 2 * panel_clearance)) / 2;
// Near face of the slot, measured from the outside of the box inwards.
panel_y = wall_outer_y + wall_skin;
// The opening, inset from each end of the cavity.
opening_x = [cavity_x[0] + panel_inset, cavity_x[1] - panel_inset];
opening_width = opening_x[1] - opening_x[0];
// Slot the panel runs in, and the panel that fits it.
slot_width = panel_thickness + 2 * panel_clearance;
panel_width = opening_width + 2 * groove_depth - 2 * panel_clearance;
panel_height = body_top - deck_z;

// The void the panel occupies: the opening itself, widened into each pillar
// by the groove. Cut from the box, this leaves the pillars grooved and the
// wall between them gone.
module panel_void() {
  // Between the pillars the whole wall goes, from the outer face through to
  // the cavity, leaving an open window.
  translate([opening_x[0], wall_outer_y - 1, deck_z])
    cube([opening_width, cavity_y[0] - wall_outer_y + 1, panel_height + 1]);
  // The slot continues into each pillar, capturing the panel edges. It sits
  // within the wall, leaving wall_skin outboard of it.
  translate([opening_x[0] - groove_depth, panel_y, deck_z])
    cube([opening_width + 2 * groove_depth, slot_width, panel_height + 1]);
}

// A bump either side of the groove near the bottom, for the panel to click
// past. Small enough that the panel flexes over it rather than jamming.
// Bumps on the inner face of each groove, near the bottom, for the panel to
// click past. Anchored in the pillar so they are part of the box, not
// floating in the slot: the cylinder runs along Y and is sunk into the
// groove's back wall, leaving only detent_size protruding into the slot.
module panel_detents() {
  // A half-round ridge lying along the outboard wall of each groove, where
  // there is a skin of material to bury it in. The axis sits on that face,
  // so half the cylinder is inside the wall and half stands proud into the
  // slot for the panel to click over.
  for (sx = [0, 1])
    translate([opening_x[0] - groove_depth + sx * (opening_width + groove_depth),
               panel_y,
               deck_z + detent_height])
      rotate([0, 90, 0])
        cylinder(h = groove_depth, r = detent_size, $fn = 16);
}

module sliding_panel() {
  difference() {
    translate([-panel_width / 2, 0, 0])
      cube([panel_width, panel_thickness, panel_height]);
    // Notches for the detents to sit in when the panel is fully down.
    for (sx = [0, 1])
      translate([-panel_width / 2 + sx * panel_width,
                 panel_thickness / 2,
                 detent_height])
        rotate([0, 90, 0])
          cylinder(h = 4, r = detent_size, center = true, $fn = 16);
  }
}

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
        if (panel_enabled) panel_void();
      }
      // Added back after the void, so they sit proud inside the groove.
      if (panel_enabled) panel_detents();
    }
    breadboard_holes();
  }
}

if (part == "box" || !panel_enabled) {
  box();
} else if (part == "panel") {
  sliding_panel();
} else {
  box();
  // Laid out clear of the box, flat on the plate, ready to print together.
  translate([0, -(depth[0] * gf_pitch) / 2 - 15, 0]) sliding_panel();
}
