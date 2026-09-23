// Splits the box into two touching parts, so a slicer can give the rib
// band its own wall and infill settings.
//
// The bands are meant to act as long springs, and they only do that if the
// slicer leaves them as thin beams. At two wall loops a 1.74 mm rib is
// filled solid wall-to-wall and barely flexes, which defeats the point.
// Giving just that band one wall loop and no infill keeps it thin.
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

// Comfortably larger than the part in X and Y.
big = 200;

module band_volume() {
  translate([-big / 2, -big / 2, band_z0])
    cube([big, big, band_z1 - band_z0]);
}

// The box is split by intersecting and differencing against the same
// volume, so the two pieces share an exact common face and cannot overlap
// or leave a sliver between them.
if (piece == "band") {
  intersection() { box(); band_volume(); }
} else {
  difference() { box(); band_volume(); }
}
