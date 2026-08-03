// cover.scad - cover-side shell and holes for the hinged card case.

socket_front_face_height = socket_height - pin_low_wall_height - cover_case_gap; // upper side cover face height below the top
socket_top_side_clearance = socket_width - pin_high_wall_x; // cut only the case high wall width
socket_top_width = socket_width - socket_top_side_clearance; // avoids the case high wall when closed
socket_lower_left_round_step = 10; // angular step for the lid lower-left opening relief

// socket_end_profile_points returns the lid end wall profile in the XZ plane.
function socket_end_profile_points() = concat(
  [
    [hinge_center_inset, 0],
    [socket_width, 0],
    [socket_width, socket_height],
    [0, socket_height],
    [0, hinge_center_inset]
  ],
  [
    for (angle = [180 + socket_lower_left_round_step:socket_lower_left_round_step:270])
      [
        hinge_center_inset + hinge_center_inset * cos(angle),
        hinge_center_inset + hinge_center_inset * sin(angle)
      ]
  ]
);

// socket_end_plate builds a front/rear plate that carries the two holes.
module socket_end_plate() {
  rounded_xz_prism_y(socket_end_profile_points(), wall_thickness, corner_radius);
}

// socket_body is the hole-side lid shell. It keeps the top cover, a single
// upper rear-side cover face, and simple front/rear hole-bearing plates.
module socket_body() {
  union() {
    translate([
      0,
      socket_end_projection - l_join_overlap,
      socket_height - wall_thickness
    ])
      rounded_prism(
        [socket_top_width, socket_core_depth + 2 * l_join_overlap, wall_thickness],
        corner_radius
      );

    socket_end_plate();

    translate([0, socket_depth - wall_thickness, 0])
      socket_end_plate();

    translate([
      0,
      socket_end_projection - l_join_overlap,
      socket_height - socket_front_face_height
    ])
      rounded_prism(
        [wall_thickness, socket_core_depth + 2 * l_join_overlap, socket_front_face_height],
        corner_radius
      );
  }
}

// socket_features adds visible bosses around the hinge and connector holes.
module socket_features() {
  union() {
    paired_end_bosses(
      socket_depth,
      hinge_socket_x,
      hinge_socket_z,
      hinge_outer_radius,
      socket_end_projection
    );

    paired_end_bosses(
      socket_depth,
      connector_hole_x,
      connector_hole_z,
      connector_outer_radius,
      socket_end_projection
    );
  }
}

// socket_cutouts removes the hinge and closing connector receiver holes.
module socket_cutouts() {
  paired_end_holes(
    socket_depth,
    hinge_socket_x,
    hinge_socket_z,
    socket_end_projection + wall_thickness,
    hinge_socket_radius
  );

  paired_end_holes(
    socket_depth,
    connector_hole_x,
    connector_hole_z,
    socket_end_projection + wall_thickness,
    connector_hole_radius
  );
}

// socket_half builds the cover-side part.
module socket_half() {
  difference() {
    union() {
      socket_body();
      socket_features();
    }

    socket_cutouts();
  }
}
