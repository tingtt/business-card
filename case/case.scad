// case.scad - case-side shell and protrusions for the hinged card case.

// pin_end_profile_points returns the case end wall profile in the XZ plane.
function pin_end_profile_points() = [
  [0, 0],
  [pin_width, 0],
  [pin_width, pin_height],
  [pin_high_wall_x, pin_height],
  [pin_high_wall_x, pin_slope_top_z],
  [0, pin_low_wall_height],
  [0, bottom_thickness]
];

// pin_body is the case shell. The diagonal exists only on the end profiles so
// the card insertion path remains open through the full body depth.
module pin_body() {
  translate([0, pin_end_projection, 0])
    union() {
      rounded_prism([pin_width, pin_core_depth, bottom_thickness], corner_radius);

      rounded_prism(
        [pin_low_wall_outer_x, pin_core_depth, pin_low_wall_height],
        corner_radius
      );

      translate([pin_high_wall_x, 0, 0])
        rounded_prism(
          [pin_width - pin_high_wall_x, pin_core_depth, pin_height],
          corner_radius
        );

      rounded_xz_prism_y(pin_end_profile_points(), wall_thickness, corner_radius);

      translate([
        hinge_pin_x - pin_hinge_pad_size / 2,
        0,
        hinge_pin_z - pin_hinge_pad_size / 2
      ])
        rounded_prism(
          [pin_hinge_pad_size, wall_thickness, pin_hinge_pad_size],
          corner_radius
        );

      translate([0, pin_core_depth - wall_thickness, 0])
        union() {
          rounded_xz_prism_y(pin_end_profile_points(), wall_thickness, corner_radius);

          translate([
            hinge_pin_x - pin_hinge_pad_size / 2,
            0,
            hinge_pin_z - pin_hinge_pad_size / 2
          ])
            rounded_prism(
              [pin_hinge_pad_size, wall_thickness, pin_hinge_pad_size],
              corner_radius
            );
        }
    }
}

// pin_features adds the larger hinge pins and vertical closing ribs.
module pin_features() {
  paired_end_cylinders(
    pin_depth,
    hinge_pin_x,
    hinge_pin_z,
    hinge_pin_length,
    hinge_pin_radius
  );

  paired_end_vertical_ribs(
    pin_depth,
    pin_end_projection,
    connector_rib_x,
    connector_rib_z,
    connector_rib_width,
    connector_rib_height,
    connector_rib_projection,
    connector_rib_overlap
  );
}

// pin_half builds the case-side part.
module pin_half() {
  union() {
    pin_body();
    pin_features();
  }
}
