// Gridfinity box for storing electronics pushed into breadboard-style holes.
//
//   - 2 x 1 grid units (42 mm), giving 84 x 42 mm
//   - base pads at half pitch (21 mm), so it sits on half-unit grid offsets
//   - height 3 units of 7 mm = 21 mm
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
height = [3, 0];

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

// The grid is centred on the cavity, which is a touch off the part centre.
mid_x = (cavity_x[0] + cavity_x[1]) / 2;
mid_y = (cavity_y[0] + cavity_y[1]) / 2;

// Rows sit at +/-(1.5 + n) * pitch, so the two innermost rows are 7.62 mm
// apart: the 0.3 inch spacing of a DIP package, straddling the centre gap.
row_offset = 1.5;
rows = floor((inner_y / 2 - hole_margin - hole_size / 2) / hole_pitch - row_offset) + 1;
cols = floor((inner_x / 2 - hole_margin - hole_size / 2) / hole_pitch - 0.5) + 1;

// Hole centres, mirrored either side of the middle in both axes.
hole_xs = [for (sx = [-1, 1]) for (i = [0 : cols - 1]) mid_x + sx * (0.5 + i) * hole_pitch];
hole_ys = [for (sy = [-1, 1]) for (j = [0 : rows - 1]) mid_y + sy * (row_offset + j) * hole_pitch];

// Full-depth hole columns, before they are clipped to the floor below.
module hole_columns() {
  for (x = hole_xs)
    for (y = hole_ys)
      translate([x - hole_size / 2, y - hole_size / 2, -1])
        cube([hole_size, hole_size, deck_z + 2]);
}

// The holes, each stopping base_clearance above whatever solid lies under
// it. Clipping the columns against a copy of the cup raised by
// base_clearance does this for every hole at once: over a foot the limit is
// the table, and over a gap between feet it is the underside of the floor
// spanning that gap, which is higher. No need to know where the feet are.
module breadboard_holes() {
  intersection() {
    hole_columns();
    translate([0, 0, base_clearance]) solid_cup();
  }
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
  breadboard_holes();
}
