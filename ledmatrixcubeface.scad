/*
  Spidermaf  64 NeoPixel Matrix PCB Frame - front loading friction-fit version
  reference video: 
  https://www.youtube.com/watch?v=cWp9GtUtEwg

  PCB: 65.4 x 66.5 mm
  Outer frame: 69.5 x 69.5 mm

  Board pushes in from the front.
  Rear lip will face inside the future cube.
*/

outer_size = 69.5;

pcb_w = 65.4;
pcb_h = 66.5;

pcb_w_clearance = 0.40;  // tighter side - visible gap before
pcb_h_clearance = 0.55;  // already looked close, so only slightly tighter

frame_depth = 4.0;

rear_lip_height = 1.2;
rear_lip_width = 1.0;

outer_corner_radius = 2.0;
pocket_corner_radius = 0.35;

$fn = 40;

module rounded_rect(w, h, r) {
    offset(r = r)
        square([w - r * 2, h - r * 2], center = true);
}

module matrix_frame_front_load() {
    difference() {
        linear_extrude(frame_depth)
            rounded_rect(outer_size, outer_size, outer_corner_radius);

        translate([0, 0, rear_lip_height])
            linear_extrude(frame_depth - rear_lip_height + 0.1)
                rounded_rect(
                    pcb_w + pcb_w_clearance,
                    pcb_h + pcb_h_clearance,
                    pocket_corner_radius
                );

        translate([0, 0, -0.1])
            linear_extrude(rear_lip_height + 0.2)
                rounded_rect(
                    pcb_w - rear_lip_width * 2,
                    pcb_h - rear_lip_width * 2,
                    pocket_corner_radius
                );
    }
}

matrix_frame_front_load();
