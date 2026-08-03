// main.scad - hinged two-part business card case reconstructed from STEP/STL.
/*
  Spec:
    The reference "Visitenkarten Dose" model is a two-part hinged card case.
    A pair of larger lower hinge pins/holes provide the rotation axis. Smaller
    upper connector pegs/holes temporarily hold the case closed.

  Public API:
  - business_card_case(open_angle = 180)
    Assembly preview. The fixed half stays at the public origin and the moving
    half rotates around the hinge axis, which is parallel to +Y.
  - socket_half()
    Hole-side half. Anchor: front-left-bottom of its nominal bounding box.
  - pin_half()
    Peg-side half. Anchor: front-left-bottom of its nominal bounding box.

  Geometry:
    Both halves are upright tray shells with an open top. Their bodies are
    parameterized from the measured component envelopes:
    socket half: 31.0 x 92.43 x 60.0 mm in closed assembly
    pin half:    31.0 x 94.0 x 60.0 mm

  Placement / orientation:
    +X is right, +Y is rear, +Z is up. Dimensions are in millimeters.
*/

// --- Global render settings ---------------------------------------------------

$fn = 64; // global curve segment count for circular connector features

// --- Preview selection --------------------------------------------------------

preview_part = "closed"; // "assembly", "closed", "socket", or "pin"
preview_open_angle = 180; // default visual opening angle around the hinge axis
print_part = ""; // export selector: "", "body", or "cover"

// --- Card fit dimensions ------------------------------------------------------

card_length = 91.0; // Japanese business card length along Y
card_width = 55.0; // Japanese business card width along Z
card_length_clearance = 0.4; // clearance added at each card length edge
card_height_clearance = 1.0; // clearance added at each card height edge for opening motion
card_clear_length = card_length + 2 * card_length_clearance; // required clear length in Y
card_clear_width = card_width + 2 * card_height_clearance; // required clear height in Z

// --- Shell dimensions ---------------------------------------------------------

wall_thickness = 1.2; // tray side and end wall thickness
bottom_thickness = 1.2; // tray bottom thickness
rim_height = 0.8; // shallow top rim height on the open side
corner_radius = 0.5; // exposed edge fillet radius
rim_radius = 0.35; // small radius for printable rim strips
cover_case_gap = 0.8; // clearance between overlapping cover and case faces
pin_end_projection = 2.0; // end connector zone included in pin_depth
l_join_overlap = wall_thickness; // overlap at L-shaped plate joints to bury one plate thickness

// --- Reference component dimensions ------------------------------------------

pin_width = 31.0; // peg-side half width along X
pin_depth = card_clear_length + 2 * pin_end_projection + 2 * wall_thickness; // peg-side half depth along Y
pin_height = card_clear_width + bottom_thickness; // peg-side half height along Z

pin_core_depth = pin_depth - 2 * pin_end_projection; // tray body length
pin_inner_depth = pin_core_depth - 2 * wall_thickness; // clear length in Y

socket_width = pin_width; // cover-side half width follows the case reference width
socket_depth_clearance = 0.03; // small allowance over the case body depth
socket_depth = pin_core_depth + 2 * wall_thickness + socket_depth_clearance; // cover spans the case body ends
socket_height = pin_height; // cover-side half height along Z
socket_end_projection = wall_thickness; // thickness of each cover end plate

// --- Hinge dimensions ---------------------------------------------------------

hinge_pin_radius = 2.5; // left-lower opening hinge pin radius
hinge_radial_clearance = 0.2; // radius clearance so printed hinge rotates freely
hinge_axial_clearance = 0.25; // end clearance that prevents hinge faces from rubbing
hinge_socket_radius = hinge_pin_radius + hinge_radial_clearance; // left-lower opening hinge hole radius
hinge_outer_radius = 3.6; // visible reinforcing boss around hinge
hinge_projection = 1.25; // extra hinge peg length inside end zones
hinge_pin_length = pin_end_projection + hinge_projection - hinge_axial_clearance; // printed hinge peg length along Y
hinge_center_inset = 8.0; // hinge center distance from the left and bottom faces
hinge_pin_x = hinge_center_inset; // hinge pin center from case left face
hinge_pin_z = hinge_center_inset; // hinge pin center above bottom
hinge_socket_x = hinge_pin_x; // hinge hole center from cover left face
hinge_socket_z = hinge_pin_z; // hinge hole center above bottom

// --- Connector dimensions -----------------------------------------------------

connector_peg_radius = 0.6; // right-upper closing connector peg radius
connector_hole_radius = 1; // right-upper closing connector hole radius
connector_outer_radius = 2.5; // visible reinforcing boss around connector
connector_cap_overlap = 0.2; // shallow overlap that anchors the rounded connector cap
connector_peg_x = 27.5; // connector peg center from case left face
connector_peg_z = 44.99; // connector peg center above bottom
connector_hole_x = connector_peg_x; // connector hole center from cover left face
connector_hole_z = connector_peg_z; // connector hole center above bottom

// --- Derived dimensions -------------------------------------------------------

socket_inner_width = socket_width - wall_thickness; // open tray space in X
socket_core_depth = socket_depth - 2 * socket_end_projection; // tray body length
socket_inner_depth = socket_core_depth - 2 * wall_thickness; // clear length in Y
socket_inner_height = socket_height - bottom_thickness; // clear height in Z

pin_inner_width = pin_width - wall_thickness; // open tray space in X
pin_inner_height = pin_height - bottom_thickness; // clear height in Z

case_y_offset = -wall_thickness / 2; // assembly-only case shift along Y
cover_y_offset = case_y_offset + pin_end_projection - wall_thickness; // cover front inner face aligns to the case body front

// --- Case and lid face dimensions --------------------------------------------

pin_hinge_pad_size = 6.0; // local backing pad around the lower hinge
pin_low_wall_height = 35.7; // lower side height in the XZ cross-section
pin_slope_top_z = 53.0; // sloped mouth height near the opposite side
pin_high_wall_x = 29.0; // start of the tall side wall in X
pin_low_wall_x = 0.7; // inner edge of the low side wall in X
pin_low_wall_outer_x = pin_low_wall_x + wall_thickness / 2; // low side wall width overlapped by end plates

// --- Validation ---------------------------------------------------------------

assert(socket_width > 2 * wall_thickness, "socket_width too small");
assert(pin_width > 2 * wall_thickness, "pin_width too small");
assert(socket_depth > 2 * wall_thickness, "socket_depth too small");
assert(pin_depth > 2 * wall_thickness, "pin_depth too small");
assert(socket_core_depth > 2 * wall_thickness, "socket_core_depth too small");
assert(pin_core_depth > 2 * wall_thickness, "pin_core_depth too small");
assert(socket_height > bottom_thickness + rim_height, "socket_height too small");
assert(pin_height > bottom_thickness + rim_height, "pin_height too small");
assert(pin_inner_depth >= card_clear_length, "case body inner depth must fit the card length clearance");
assert(socket_inner_depth >= card_clear_length, "cover inner depth must fit the card length clearance");
assert(pin_inner_height >= card_clear_width, "case body inner height must fit the card width clearance");
assert(socket_inner_height >= card_clear_width, "cover inner height must fit the card width clearance");
assert(corner_radius < wall_thickness, "corner_radius must fit within walls");
assert(hinge_pin_radius < hinge_socket_radius, "hinge pin needs socket clearance");
assert(
  hinge_pin_length > socket_end_projection,
  "hinge_pin_length must still engage the cover end plate"
);
assert(
  connector_peg_radius < connector_hole_radius,
  "connector peg needs hole clearance"
);
assert(
  hinge_outer_radius > hinge_socket_radius,
  "hinge boss must be larger than hinge socket"
);
assert(
  connector_outer_radius > connector_hole_radius,
  "connector boss must be larger than connector hole"
);

// --- 2D profiles --------------------------------------------------------------

// rounded_rect_2d creates a front-left anchored rounded rectangle in XY.
module rounded_rect_2d(width, depth, radius) {
  assert(width > 2 * radius, "width must be larger than 2 * radius");
  assert(depth > 2 * radius, "depth must be larger than 2 * radius");

  translate([radius, radius])
    offset(r=radius)
      square([width - 2 * radius, depth - 2 * radius]);
}

// --- 3D utility modules -------------------------------------------------------

// rounded_prism creates a front-left-bottom anchored box filleted on all edges.
module rounded_prism(size, radius = corner_radius) {
  assert(len(size) == 3, "size must be a 3D vector");
  assert(size[0] > 2 * radius, "size[0] must be larger than 2 * radius");
  assert(size[1] > 2 * radius, "size[1] must be larger than 2 * radius");
  assert(size[2] > 2 * radius, "size[2] must be larger than 2 * radius");

  translate([radius, radius, radius])
    minkowski() {
      cube(
        [
          size[0] - 2 * radius,
          size[1] - 2 * radius,
          size[2] - 2 * radius,
        ]
      );

      sphere(r=radius);
    }
}

// rounded_xz_prism_y creates an XZ profile extruded in +Y with all edges filleted.
module rounded_xz_prism_y(points, depth, radius = corner_radius) {
  assert(len(points) >= 3, "points must define a polygon");
  assert(depth > 2 * radius, "depth must be larger than 2 * radius");

  translate([0, radius, 0])
    minkowski() {
      multmatrix(
        [
          [1, 0, 0, 0],
          [0, 0, 1, 0],
          [0, 1, 0, 0],
          [0, 0, 0, 1],
        ]
      )
        linear_extrude(height=depth - 2 * radius)
          offset(delta=-radius)
            polygon(points=points);

      sphere(r=radius);
    }
}

// xz_prism_y extrudes an XZ profile along +Y.
module xz_prism_y(points, depth) {
  assert(len(points) >= 3, "points must define a polygon");
  assert(depth > 0, "depth must be positive");

  multmatrix(
    [
      [1, 0, 0, 0],
      [0, 0, 1, 0],
      [0, 1, 0, 0],
      [0, 0, 0, 1],
    ]
  )
    linear_extrude(height=depth)
      polygon(points=points);
}

// cylinder_y creates a cylinder whose local axis runs from Y=0 to Y=length.
module cylinder_y(length, radius) {
  assert(length > 0, "length must be positive");
  assert(radius > 0, "radius must be positive");

  rotate([-90, 0, 0])
    cylinder(h=length, r=radius);
}

// rounded_cylinder_y creates a Y-axis cylinder with filleted circular end rims.
module rounded_cylinder_y(length, radius, edge_radius = corner_radius) {
  assert(length > 2 * edge_radius, "length must be larger than 2 * edge_radius");
  assert(radius > edge_radius, "radius must be larger than edge_radius");

  translate([0, edge_radius, 0])
    minkowski() {
      cylinder_y(length - 2 * edge_radius, radius - edge_radius);

      sphere(r=edge_radius);
    }
}

// paired_end_cylinders places matching front and rear cylinders inside the
// nominal part depth envelope.
module paired_end_cylinders(depth, x, z, length, radius) {
  translate([x, 0, z])
    rounded_cylinder_y(length, radius);

  translate([x, depth - length, z])
    rounded_cylinder_y(length, radius);
}

// hemisphere_y creates a half sphere protruding along the requested Y direction.
module hemisphere_y(radius, direction) {
  assert(radius > 0, "radius must be positive");
  assert(
    direction == -1 || direction == 1,
    "direction must be -1 for front or 1 for rear"
  );

  eps = 0.01; // avoids a zero-thickness clipping boundary
  clip_y = direction > 0 ? -eps : -2 * radius - eps;

  intersection() {
    sphere(r=radius);

    translate([-radius - eps, clip_y, -radius - eps])
      cube([2 * radius + 2 * eps, 2 * radius + 2 * eps, 2 * radius + 2 * eps]);
  }
}

// paired_end_caps places low-profile hemispherical connector bumps on both end faces.
module paired_end_caps(depth, face_offset, x, z, radius, overlap) {
  assert(depth > 2 * face_offset, "depth must be larger than 2 * face_offset");
  assert(overlap >= 0, "overlap must be non-negative");

  translate([x, face_offset + overlap, z])
    hemisphere_y(radius, -1);

  translate([x, depth - face_offset - overlap, z])
    hemisphere_y(radius, 1);
}

// paired_end_holes subtracts front and rear receiver holes.
module paired_end_holes(depth, x, z, length, radius) {
  eps = 0.01; // ensures the subtraction passes fully through the receivers
  cut_len = length + 2 * eps;

  translate([x, -eps, z])
    rounded_cylinder_y(cut_len, radius);

  translate([x, depth - length - eps, z])
    rounded_cylinder_y(cut_len, radius);
}

// paired_end_bosses adds reinforcing bosses at both end connector zones.
module paired_end_bosses(depth, x, z, radius, thickness) {
  translate([x, 0, z])
    rounded_cylinder_y(thickness, radius);

  translate([x, depth - thickness, z])
    rounded_cylinder_y(thickness, radius);
}

// rotate_about_hinge rotates children around a +Y axis at [x, *, z].
module rotate_about_hinge(axis_x, axis_z, angle) {
  translate([axis_x, 0, axis_z])
    rotate([0, angle, 0])
      translate([-axis_x, 0, -axis_z])
        children();
}

include <case.scad>
include <cover.scad>

// --- Assembly preview ---------------------------------------------------------

// business_card_case previews the hinged assembly at the requested open angle.
module business_card_case(open_angle = preview_open_angle) {
  socket_to_pin = [
    hinge_pin_x - hinge_socket_x,
    cover_y_offset,
    hinge_pin_z - hinge_socket_z,
  ];

  color([0.10, 0.42, 0.30])
    translate([0, case_y_offset, 0])
      pin_half();

  color([0.18, 0.58, 0.38])
    rotate_about_hinge(hinge_pin_x, hinge_pin_z, open_angle)
      translate(socket_to_pin)
        socket_half();
}

// --- Printable parts ----------------------------------------------------------

// case_body_part is the case-side printable half.
module case_body_part() {
  pin_half();
}

// case_cover_part is the cover-side printable half.
module case_cover_part() {
  socket_half();
}

// --- Preview ------------------------------------------------------------------

if (print_part == "body")
  case_body_part();
else if (print_part == "cover")
  case_cover_part();
else if (preview_part == "socket")
  socket_half();
else if (preview_part == "pin")
  pin_half();
else if (preview_part == "closed")
  business_card_case(0);
else
  business_card_case(preview_open_angle);
