// Splits the box into two touching parts, so a slicer can give the rib
// band its own wall and infill settings.
//
// The bands are meant to act as long springs, and they only do that if the
// slicer leaves them as thin beams. At two wall loops a 1.74 mm rib is
// filled solid wall-to-wall and barely flexes, which defeats the point.
// Giving just that band one wall loop and no infill keeps it thin.
//
// The band covers only the drilled area. Two things are deliberately left
// in the main part: the outer walls, which carry the box and must keep
// their full wall count, and the undrilled centre strip, which is the
// column holding up the deck above it and wants solid infill. The band is
// therefore two blocks, one either side of the strip.
//
// The two parts TOUCH exactly - there is no gap - so loaded as parts of a
// single object they fuse into one solid print. Loading them as separate
// objects would not work: the slicer only keeps bodies apart when the mesh
// is disconnected, which would mean a real air gap and a box in pieces.
//
// Usage:
//   openscad -o rib_band.stl  -D 'piece="band"' split_rib_band.scad
//   openscad -o box_rest.stl  -D 'piece="rest"' split_rib_band.scad
//
// Then in Bambu Studio: load box_rest.stl, right-click it,
// Add part > Load... and pick rib_band.stl. Set the band part to
// 1 wall loop and 0% infill; leave the rest at your usual settings.

use <breadboard_box.scad>

// Which half to emit.
piece = "band"; // [band, rest]

// The slotted band, matching deck_hollow() in breadboard_box.scad:
// from floor_z + floor_skin up to deck_z - deck_skin.
band_z0 = 6.05;
band_z1 = 9.45;

// The band covers ONLY the drilled area, and nothing else.
//
// It stops short of the outer walls, which carry the whole box and must
// keep their full wall count, and it excludes the undrilled centre strip,
// which is the column supporting the deck above it and wants solid infill.
// So the band is two blocks, one each side of the strip.
//
// Bounds are the outermost hole edges: X +/-37.28, Y 3.00 .. 14.06 either
// side of centre. Trimmed in by a margin so the boundary lands in solid
// material rather than clipping a hole wall.
hole_edge_x = 37.28;
hole_edge_y_outer = 14.06;
hole_edge_y_inner = 3.00;
// Keeps the cut off the hole walls themselves.
band_margin = 0.3;

module band_volume() {
  x0 = -hole_edge_x - band_margin;
  w = 2 * (hole_edge_x + band_margin);
  y_in = hole_edge_y_inner - band_margin;
  y_out = hole_edge_y_outer + band_margin;
  for (sy = [-1, 1])
    translate([x0, sy < 0 ? -y_out : y_in, band_z0])
      cube([w, y_out - y_in, band_z1 - band_z0]);
}

// The box is split by intersecting and differencing against the same
// volume, so the two pieces share an exact common face and cannot overlap
// or leave a sliver between them.
if (piece == "band") {
  intersection() { box(); band_volume(); }
} else {
  difference() { box(); band_volume(); }
}
