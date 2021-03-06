angle = 30;
gap = 0.001;
board_beams = 5;

ply_thickness = 0.018;

ply_8 = 2.44;
ply_4 = 1.22;
ply_2 = 0.61;

beam_2 = 0.045;
beam_4 = 0.095;
beam_6 = 0.145;

ply_color = "#DAB888";
beam_color = "#AE936D";

module ply_2x4() {
    color(ply_color)
    cube([ply_4, ply_thickness, ply_2]);
}

module ply_4x8() {
    color(ply_color)
    cube([ply_8, ply_thickness, ply_4]);
}

module beam_2x4(length) {
    color(beam_color)
        cube([beam_2, beam_4, length]);
}

module beam_2x6(length) {
    color(beam_color)
        cube([beam_2, beam_6, length]);
}

module floor(thickness) {
    color("green")
        translate([-1, -1 - 2 * ply_8 * sin(angle), -thickness])
        cube([ply_8 + 2, 2 * ply_8 * sin(angle) + 2, thickness]);
}

module overhang_edge_beam(i) {
    difference() {
        translate([(ply_8 - beam_2) * i, 0, ply_2])
            rotate([angle, 0, 0])
            translate([-gap, ply_thickness, -ply_thickness / 2])
            translate([0, 0, -beam_6 * tan(angle)])
            translate([0, 0, -ply_2 / cos(angle)])
            beam_2x6(ply_8 + (ply_2 / cos(angle)) + (ply_thickness / 2) + (beam_6 * tan(angle)) + 
                (beam_6 / tan(angle)) + (ply_thickness * cos(angle) / sin(angle)));
       
        translate([0, -ply_8 * sin(angle), 0])
            mirror([0, 1, 0])
            translate([-ply_2, 0, 0])
            color(beam_color)
            cube([ply_4 * 3, 1, ply_4 * 3]);
    }
}

module kickboard() {
    // ply wood
    for (i = [0 : 1]) {
        translate([(ply_4 + gap) * i, 0, 0])
            ply_2x4();
    }
    
    // vertical beams
    for (i = [0 : 1]) {
        difference() {
            translate([(2 * i * gap) - gap, gap, 0])
                translate([(ply_8 - beam_2) * i, ply_thickness, 0])
                beam_2x4(ply_2);

            translate([(beam_2 * i) - (beam_2 / 2) - (ply_8 * i), 0, 0])
                scale([2, 1, 1])
                overhang_edge_beam(i);
        }
    }
    
    // horizontal beams
    for (i = [0 : 2]) {
        translate([0, 0, (ply_2 - beam_2) * i / 2])
            translate([beam_2, ply_thickness + gap, beam_2 + gap])
            rotate([0, 90, 0])
            beam_2x4(ply_8 - (2 * beam_2));
    }
    
    // connectors to overhang edge beams
    for (i = [0 : 1]) {
        translate([(ply_8 + beam_2) * i, 0, 0])
            translate([-beam_2, ply_thickness, beam_4])
            rotate([-90, 0, 0])
            beam_2x4(ply_2 * tan(angle) + (beam_6 / cos(angle)));
    }
    
}

module overhang() {
    // ply wood
    for (i = [0 : 1]) {
        translate([0, 0, ply_2])
            rotate([angle, 0, 0])
            translate([0, 0, (ply_4 + gap) * i])
            ply_4x8();
    }
    
    // edge beams
    for (i = [0 : 1]) {
        translate([0, 0, gap])
            difference() {
                overhang_edge_beam(i);
                floor(1);
            }
    }
    
    // top beam
    translate([0, 0, ply_2])
        rotate([angle, 0, 0])
        translate([beam_2, ply_thickness + gap, ply_8 + gap])
        rotate([0, 90, 0])
        beam_2x6(ply_8 - (2 * beam_2));
    
    // bottom beam
    translate([0, 0, ply_2])
        rotate([angle, 0, 0])
        translate([beam_2, ply_thickness + gap, beam_2])
        rotate([0, 90, 0])
        beam_2x6(ply_8 - (2 * beam_2));
    
    // middle beams
    for (i = [1 : board_beams - 1]) {
        translate([0, 0, ply_2 + gap])
        rotate([angle, 0, 0])
        translate([ply_8 * i / board_beams, ply_thickness, beam_2])
        beam_2x4(ply_8 - (2 * beam_2));
    }
}

module aframe() {
    // main frame
    for (i = [0 : 1]) {
            translate([0, -gap, 0])
            translate([0, -ply_8 * sin(angle) * 2, 0])
            mirror([0, 1, 0])
            difference() {
                overhang_edge_beam(i);
                floor(1);
            }
    }

    // 2x4s to connect to board supports
    for (i = [0 : 1]) {
        translate([(ply_8 + beam_2) * i, 0, 0])
            translate([0, -ply_thickness * sin(angle), 0])
            translate([0, beam_6 / cos(angle), 0])
            translate([0, -1.5 * ply_4 * sin(angle), 0])
            translate([0, 0, 1.5 * ply_4 * cos(angle)])
            translate([-beam_2, 0, ply_2 - beam_4 / 2])
            rotate([90, 0, 0])
            beam_2x4(2 * ((ply_2 * sin(angle)) + (beam_6 / cos(angle))) - (beam_4 * tan(angle)) + (ply_thickness * cos(angle) / sin(angle)));
    }
    
    // 2x6 to connect the legs at the base
    translate([0, -beam_2 * tan(angle), 0])
        translate([0, -ply_2 * tan(angle), 0])
        translate([0, -ply_8, 0])
        translate([beam_2, -beam_6, beam_2])
        rotate([0, 90, 0])
        beam_2x6(ply_8 - 2 * beam_2);
}

kickboard();
overhang();
aframe();
floor(gap);