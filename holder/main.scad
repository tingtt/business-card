// main.scad - parametric honeycomb business-card holder for Japanese cards.
/*
  Spec:
    Japanese business cards: 91 mm wide x 55 mm deep
    Cards lie flat on the bottom plate, parallel to the XY plane.
    Usable internal height: 60 mm

  Public API:
  - card_holder()
    Anchor: front-left-bottom of the nominal outer bounding box.

  Geometry:
  - The card bay is bounded by a bottom plate, two full-height U-shaped long
    side walls, and two full-height honeycomb short-end plates.
  - Short-end plate padding is created by assembly overlap at the bottom/front/
    rear plus a thin top rail, not by the honeycomb plate module itself.

  Placement / orientation:
  - +X is right, +Y is rear, +Z is up.
  - Dimensions are in millimeters.
*/

// --- Global render settings ---------------------------------------------------

$fn = 48; // global curve segment count for preview-quality circular cuts

// --- Card and fit parameters --------------------------------------------------

card_width = 91;       // Japanese business-card width along X
card_depth = 55;       // Japanese business-card depth along Y
inner_height = 60;     // usable internal height above the bottom plate
fit_clearance_x = 0.6; // total clearance added to card width for easy insertion
fit_clearance_y = 0.6; // total clearance added to card depth for easy insertion

// --- Structural parameters ----------------------------------------------------

wall_thickness = 2.4;    // thickness of side/front/rear retaining walls
bottom_thickness = 2.4;  // bottom plate thickness under cards
top_rail_height = 2.4;   // solid strip covering the top of each honeycomb end
corner_radius = 0.8;     // outside 3D corner radius for rectangular bodies

// --- Honeycomb parameters -----------------------------------------------------

hex_flat_radius = 3.4; // hexagonal hole radius measured to flat sides
hex_rib_width = 1.2;   // minimum web left between neighboring hex holes

// --- Long-side cutout parameters ---------------------------------------------

thumb_cutout_width = 30;        // centered U-shaped access opening width
thumb_cutout_bottom = 4.5;      // material below the rounded U bottom
thumb_cutout_corner_radius = 2; // 2D corner radius for the U outline
thumb_cutout_inner_fillet_radius = 0.6; // rounded material added inside the U cut

// --- Derived dimensions -------------------------------------------------------

inner_width = card_width + fit_clearance_x;     // internal left-right card bay
inner_depth = card_depth + fit_clearance_y;     // internal front-rear card bay
long_wall_height = inner_height;                // long-side wall height
short_plate_height = inner_height;              // short-end plate height
outer_width = inner_width + 2 * wall_thickness; // total model width
outer_depth = inner_depth + 2 * wall_thickness; // total model depth
outer_height = bottom_thickness + short_plate_height; // total model height
hex_corner_radius = hex_flat_radius / cos(30);  // radius to hex vertices
hex_pitch_x = sqrt(3) * hex_corner_radius + hex_rib_width; // honeycomb pitch X
hex_pitch_y = 1.5 * hex_corner_radius + hex_rib_width;     // honeycomb pitch Y

// --- Validation ---------------------------------------------------------------

assert(card_width > 0, "card_width must be positive");
assert(card_depth > 0, "card_depth must be positive");
assert(inner_height > 0, "inner_height must be positive");
assert(wall_thickness >= 1.2, "wall_thickness must be at least 1.2 mm");
assert(bottom_thickness >= 1.2, "bottom_thickness must be at least 1.2 mm");
assert(
  long_wall_height == inner_height,
  "long_wall_height must match inner_height"
);
assert(
  short_plate_height == inner_height,
  "short_plate_height must match inner_height"
);
assert(
  long_wall_height > thumb_cutout_bottom + thumb_cutout_width / 2,
  "long wall too low for thumb cutout"
);
assert(
  thumb_cutout_width < outer_width - 2 * wall_thickness,
  "thumb_cutout_width too wide"
);
assert(
  thumb_cutout_corner_radius < thumb_cutout_width / 4,
  "thumb_cutout_corner_radius must be smaller than a quarter of the cutout width"
);
assert(
  thumb_cutout_inner_fillet_radius < wall_thickness / 2,
  "thumb_cutout_inner_fillet_radius must be smaller than half the wall thickness"
);
assert(hex_rib_width >= 0.8, "hex_rib_width must be at least 0.8 mm");
assert(
  top_rail_height <= short_plate_height / 4,
  "top_rail_height must stay small relative to short_plate_height"
);

// --- 2D profiles --------------------------------------------------------------

// rounded_rect_2d creates a corner-anchored rounded rectangle.
module rounded_rect_2d(width, depth, radius) {
  assert(width > 2 * radius, "width must be larger than 2 * radius");
  assert(depth > 2 * radius, "depth must be larger than 2 * radius");

  translate([radius, radius])
    offset(r=radius)
      square([width - 2 * radius, depth - 2 * radius]);
}

// hex_hole_2d creates one point-up hexagonal through-hole in its local center.
module hex_hole_2d(flat_radius = hex_flat_radius) {
  assert(flat_radius > 0, "flat_radius must be positive");

  circle(r=flat_radius / cos(30), $fn=6);
}

// honeycomb_holes_2d lays out edge-to-edge staggered hex holes without padding.
module honeycomb_holes_2d(width, height) {
  assert(width > 0, "width must be positive");
  assert(height > 0, "height must be positive");

  col_count = ceil(width / hex_pitch_x) + 2;
  row_count = ceil(height / hex_pitch_y) + 2;

  for (row = [-1 : row_count]) {
    for (col = [-1 : col_count]) {
      x = col * hex_pitch_x + (row % 2) * hex_pitch_x / 2;
      y = row * hex_pitch_y;

      translate([x, y])
        rotate(30)
          hex_hole_2d();
    }
  }
}

// long_wall_cutout_2d creates a smooth top-open U cutout profile.
module long_wall_cutout_2d(width, height) {
  assert(width > 0, "width must be positive");
  assert(height > thumb_cutout_bottom + width / 2, "height too low for cutout");

  center_x = outer_width / 2;
  radius = width / 2;
  center_z = thumb_cutout_bottom + radius;

  assert(
    width > 2 * thumb_cutout_corner_radius,
    "width must exceed 2 * thumb_cutout_corner_radius"
  );

  offset(r=thumb_cutout_corner_radius)
    offset(delta=-thumb_cutout_corner_radius)
      union() {
        translate([center_x - radius, center_z])
          square([width, height - center_z + radius + 1]);
        translate([center_x, center_z])
          circle(r=radius);
      }
}

// u_cutout_inner_fillet_2d creates a thin band inside the U opening boundary.
module u_cutout_inner_fillet_2d(width, cutout_height, wall_height) {
  top_stop_z = wall_height - thumb_cutout_inner_fillet_radius;

  intersection() {
    difference() {
      long_wall_cutout_2d(width, cutout_height);
      offset(delta=-thumb_cutout_inner_fillet_radius)
        long_wall_cutout_2d(width, cutout_height);
    }

    square([outer_width, top_stop_z]);
  }
}

// u_cutout_inner_fillet_3d adds rounded material on the U cutout inner face.
module u_cutout_inner_fillet_3d(width, cutout_height, wall_height, depth) {
  assert(
    depth > 2 * thumb_cutout_inner_fillet_radius,
    "depth too thin for inner fillet"
  );

  translate([0, 0, thumb_cutout_inner_fillet_radius])
    minkowski() {
      linear_extrude(
        height=depth - 2 * thumb_cutout_inner_fillet_radius
      )
        u_cutout_inner_fillet_2d(width, cutout_height, wall_height);
      sphere(r=thumb_cutout_inner_fillet_radius);
    }
}

// --- 3D components ------------------------------------------------------------

// rounded_box builds a corner-anchored box with rounded vertices.
module rounded_box(size, radius = corner_radius) {
  assert(len(size) == 3, "size must be a 3D vector");
  assert(size[0] > 2 * radius, "size[0] must be larger than 2 * radius");
  assert(size[1] > 2 * radius, "size[1] must be larger than 2 * radius");
  assert(size[2] > 2 * radius, "size[2] must be larger than 2 * radius");

  translate([radius, radius, radius])
    minkowski() {
      cube([
        size[0] - 2 * radius,
        size[1] - 2 * radius,
        size[2] - 2 * radius
      ]);
      sphere(r=radius);
    }
}

// bottom_plate is the continuous base that ties the holder together.
module bottom_plate() {
  rounded_box([outer_width, outer_depth, bottom_thickness], corner_radius);
}

// honeycomb_plate cuts full-surface hex holes through a rounded cuboid.
module honeycomb_plate(size, cut_axis = "x", radius = corner_radius) {
  assert(len(size) == 3, "size must be a 3D vector");
  assert(size[0] > 2 * radius, "size[0] must be larger than 2 * radius");
  assert(size[1] > 2 * radius, "size[1] must be larger than 2 * radius");
  assert(size[2] > 2 * radius, "size[2] must be larger than 2 * radius");
  assert(
    cut_axis == "x" || cut_axis == "y" || cut_axis == "z",
    "cut_axis must be x, y, or z"
  );

  eps = 0.01; // ensures honeycomb holes cut completely through the plate

  difference() {
    rounded_box(size, radius);

    if (cut_axis == "x")
      translate([-eps, 0, 0])
        multmatrix([
          [0, 0, 1, 0],
          [1, 0, 0, 0],
          [0, 1, 0, 0],
          [0, 0, 0, 1]
        ])
          linear_extrude(height=size[0] + 2 * eps)
            honeycomb_holes_2d(size[1], size[2]);

    if (cut_axis == "y")
      translate([0, -eps, 0])
        multmatrix([
          [1, 0, 0, 0],
          [0, 0, 1, 0],
          [0, 1, 0, 0],
          [0, 0, 0, 1]
        ])
          linear_extrude(height=size[1] + 2 * eps)
            honeycomb_holes_2d(size[0], size[2]);

    if (cut_axis == "z")
      translate([0, 0, -eps])
        linear_extrude(height=size[2] + 2 * eps)
          honeycomb_holes_2d(size[0], size[1]);
  }
}

// long_side_wall is a full-height side wall with a centered U-shaped opening.
module long_side_wall() {
  eps = 0.01; // ensures the cutout passes fully through the long wall
  cutout_depth = wall_thickness + 2 * eps;

  union() {
    difference() {
      rounded_box([outer_width, wall_thickness, outer_height], corner_radius);

      translate([0, wall_thickness + eps, -eps])
        rotate([90, 0, 0])
          linear_extrude(height=cutout_depth)
            long_wall_cutout_2d(thumb_cutout_width, outer_height + 2 * eps);
    }

    intersection() {
      rounded_box([outer_width, wall_thickness, outer_height], corner_radius);

      translate([0, wall_thickness + eps, -eps])
        rotate([90, 0, 0])
          u_cutout_inner_fillet_3d(
            thumb_cutout_width,
            outer_height + 2 * eps,
            outer_height,
            cutout_depth
          );
    }
  }
}

// long_side_walls places the front and rear U-shaped long-side walls.
module long_side_walls() {
  long_side_wall();

  translate([0, outer_depth - wall_thickness, 0])
    long_side_wall();
}

// short_end_panel builds one end plate; assembly overlap supplies its border.
module short_end_panel() {
  honeycomb_plate([wall_thickness, outer_depth, outer_height], "x");

  translate([0, 0, outer_height - top_rail_height])
    rounded_box([wall_thickness, outer_depth, top_rail_height], corner_radius);
}

// short_end_panels places the left and right honeycomb end plates.
module short_end_panels() {
  short_end_panel();

  translate([outer_width - wall_thickness, 0, 0])
    short_end_panel();
}

// solid_body groups gray body surfaces for preview coloring.
module solid_body() {
  bottom_plate();
  long_side_walls();
}

// card_holder assembles the complete printable holder.
module card_holder() {
  union() {
    solid_body();
    short_end_panels();
  }
}

// --- Preview ------------------------------------------------------------------

color([0.62, 0.62, 0.60])
  solid_body();

color([0.02, 0.02, 0.02])
  short_end_panels();
