/*
  Spidermaf NeoPixel Matrix Cube
  reference video: 
  https://www.youtube.com/watch?v=cWp9GtUtEwg

  - Six overlapping push-fit face frames
  - Faces moved 3.5mm towards cube centre
  - PCB retaining lip is 0.6mm deep
  - PCB corner relief is cut AFTER cube assembly
  - Relief enters from the OUTSIDE/front of every face
  - Outer structural cube frame remains intact
*/

mode = "cube"; // "frame" or "cube"


// ---------- PCB ----------

pcb_w = 65.6;
pcb_h = 66.7;

pcb_w_clearance = 0.40;
pcb_h_clearance = 0.55;


// ---------- FRAME ----------

outer_size = 69.5;
frame_depth = 4.0;

// Extra inward depth to help adjacent faces fuse
extra_inward_depth = 1.0;
cube_frame_depth = frame_depth + extra_inward_depth;

// Move each complete face towards the cube centre
face_inset = 3.5;

// PCB retaining lip
rear_lip_height = 0.6;
rear_lip_width = 1.0;

outer_corner_radius = 2.0;
pocket_corner_radius = 0.35;


// ---------- PCB CORNER RELIEF ----------

// Size of clearance at each PCB corner
lip_corner_relief = 6.0;

// How far the cutter continues behind the retaining lip
// into the cube interior
corner_back_clearance = 1.5;


// ---------- REMOVAL NOTCH ----------

notch_enabled = true;
notch_on_face = "bottom";

notch_width = 5.0;
notch_depth = 2.5;


eps = 0.1;
$fn = 40;


// ---------- SHAPES ----------

module rounded_rect(w, h, r) {
    offset(r = r)
        square(
            [w - r * 2, h - r * 2],
            center = true
        );
}


// ---------- FACE FRAME ----------

module matrix_frame_front_load(
    depth = frame_depth,
    with_notch = false
) {
    difference() {

        // Main frame body
        linear_extrude(depth)
            rounded_rect(
                outer_size,
                outer_size,
                outer_corner_radius
            );

        // PCB pocket.
        // The PCB enters from the high-Z/front side.
        translate([0, 0, rear_lip_height])
            linear_extrude(
                depth - rear_lip_height + eps
            )
                rounded_rect(
                    pcb_w + pcb_w_clearance,
                    pcb_h + pcb_h_clearance,
                    pocket_corner_radius
                );

        // Through-opening, leaving the retaining lip
        translate([0, 0, -eps])
            linear_extrude(
                rear_lip_height + eps * 2
            )
                rounded_rect(
                    pcb_w - rear_lip_width * 2,
                    pcb_h - rear_lip_width * 2,
                    pocket_corner_radius
                );

        // Screwdriver removal notch
        if (with_notch) {
            translate([
                0,
                outer_size / 2 - notch_depth / 2,
                depth / 2
            ])
                cube(
                    [
                        notch_width,
                        notch_depth + eps,
                        depth + eps * 2
                    ],
                    center = true
                );
        }
    }
}


// ---------- CORNER RELIEF FOR ONE FACE ----------

module face_corner_relief_cuts(depth = cube_frame_depth) {
    /*
      Local face coordinates:

        Z = depth:
            visible outside/front of the cube

        Z = rear_lip_height:
            front surface of the PCB retaining lip

        Z = 0:
            rear/inside surface of the retaining lip

      Each cutter enters from the visible front, passes
      through the PCB corner and lip, then continues a
      short distance into the cube.

      Its X/Y footprint stays entirely within the PCB
      pocket, so it does not cut the outer radial frame.
    */

    pocket_w = pcb_w + pcb_w_clearance;
    pocket_h = pcb_h + pcb_h_clearance;

    relief_x =
        pocket_w / 2
        - lip_corner_relief / 2;

    relief_y =
        pocket_h / 2
        - lip_corner_relief / 2;

    // Start slightly behind the lip
    cutter_low_z =
        -corner_back_clearance;

    // Continue completely through the visible/front face
    cutter_high_z =
        depth + eps;

    cutter_depth =
        cutter_high_z - cutter_low_z;

    cutter_centre_z =
        (cutter_high_z + cutter_low_z) / 2;

    for (x_sign = [-1, 1])
        for (y_sign = [-1, 1])
            translate([
                x_sign * relief_x,
                y_sign * relief_y,
                cutter_centre_z
            ])
                cube(
                    [
                        lip_corner_relief,
                        lip_corner_relief,
                        cutter_depth
                    ],
                    center = true
                );
}


// ---------- SIX FACE FRAMES ----------

module six_face_frames() {
    half = outer_size / 2;

    union() {

        // Front
        translate([0, -half + face_inset, 0])
            rotate([90, 0, 0])
                matrix_frame_front_load(
                    cube_frame_depth,
                    notch_enabled &&
                    notch_on_face == "front"
                );

        // Back
        translate([0, half - face_inset, 0])
            rotate([-90, 0, 0])
                matrix_frame_front_load(
                    cube_frame_depth,
                    notch_enabled &&
                    notch_on_face == "back"
                );

        // Right
        translate([half - face_inset, 0, 0])
            rotate([0, 90, 0])
                matrix_frame_front_load(
                    cube_frame_depth,
                    notch_enabled &&
                    notch_on_face == "right"
                );

        // Left
        translate([-half + face_inset, 0, 0])
            rotate([0, -90, 0])
                matrix_frame_front_load(
                    cube_frame_depth,
                    notch_enabled &&
                    notch_on_face == "left"
                );

        // Top
        translate([0, 0, half - face_inset])
            matrix_frame_front_load(
                cube_frame_depth,
                notch_enabled &&
                notch_on_face == "top"
            );

        // Bottom
        translate([0, 0, -half + face_inset])
            rotate([180, 0, 0])
                matrix_frame_front_load(
                    cube_frame_depth,
                    notch_enabled &&
                    notch_on_face == "bottom"
                );
    }
}


// ---------- POST-ASSEMBLY RELIEF CUTTERS ----------

module assembled_cube_corner_reliefs() {
    half = outer_size / 2;

    // Front
    translate([0, -half + face_inset, 0])
        rotate([90, 0, 0])
            face_corner_relief_cuts(cube_frame_depth);

    // Back
    translate([0, half - face_inset, 0])
        rotate([-90, 0, 0])
            face_corner_relief_cuts(cube_frame_depth);

    // Right
    translate([half - face_inset, 0, 0])
        rotate([0, 90, 0])
            face_corner_relief_cuts(cube_frame_depth);

    // Left
    translate([-half + face_inset, 0, 0])
        rotate([0, -90, 0])
            face_corner_relief_cuts(cube_frame_depth);

    // Top
    translate([0, 0, half - face_inset])
        face_corner_relief_cuts(cube_frame_depth);

    // Bottom
    translate([0, 0, -half + face_inset])
        rotate([180, 0, 0])
            face_corner_relief_cuts(cube_frame_depth);
}


// ---------- COMPLETE CUBE ----------

module cube_frame() {
    difference() {

        // First assemble all six overlapping faces
        six_face_frames();

        // Then cut the solder-pad clearances from
        // the outside/front of all six faces
        assembled_cube_corner_reliefs();
    }
}


// ---------- SINGLE FRAME PREVIEW ----------

module single_frame_preview() {
    difference() {

        matrix_frame_front_load(
            frame_depth,
            notch_enabled
        );

        face_corner_relief_cuts(frame_depth);
    }
}


// ---------- OUTPUT ----------

if (mode == "frame") {
    single_frame_preview();
}

if (mode == "cube") {
    cube_frame();
}
