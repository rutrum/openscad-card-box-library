use <BOSL/math.scad>;
use <dotSCAD/multi_line_text.scad>;

card_width = 56.5;
lr_padding = 1;

card_height = 87;
top_padding = 1.5;

divider_width = 7;

tolerance_check = false;

deck_names = [
    "Mystery",
    //"Special Encounter",
    "Research Encounter"
];

// 8 cards: 2.2
// 12 cards: 2.7
// 24 cards: 7.8
deck_depths = [
    2.2, 2.7, 7.8
];

wall_thickness = 1.5;
div_thickness = 1;
cutout_radius = 16;

include_binder_text = true;
binder_text = "Cthulhu";
binder_size = 10;
binder_font = "Keraleeyam";
binder_padding = 6;

back_text = ["The Madness", "From the Sea"];
back_size = 8;
line_spacing = 10;
back_font = "URW Chancery L";

// Calculated fields
width = wall_thickness * 2 + card_width + lr_padding;
height = wall_thickness + card_height + top_padding;
depth = wall_thickness * 2 
    + (len(deck_depths) - 1) * div_thickness
    + sum(deck_depths);

window_width = width - 12; // not really, check b value
window_height = height - 16;
window_y = 10;

module box() {
    module opening(i, depth) {
        translate([
            wall_thickness, 
            depth,
            wall_thickness
        ])
        cube([card_width + lr_padding, deck_depths[i], card_height + 10]);
        
        if (i + 1 < len(deck_depths)) {
            opening(i+1, depth + deck_depths[i] + div_thickness);
        }
    }
    
    difference() {
        cube([width, depth, height]);
        opening(0, wall_thickness);
    }
}

module finger_cutout() {
    $fn = 50;
    translate([width / 2, depth / 2, height])
    rotate([90, 0, 0])
    cylinder(h=depth + 5, r=cutout_radius, center=true);
}

module inside_cutout() {
    translate([
        divider_width + .5 * lr_padding + wall_thickness,
        wall_thickness,
        wall_thickness,
    ])
    cube([
        card_width - 2 * divider_width,
        depth - 2 * wall_thickness,
        height
    ]);
}

module binder_text() {
    h = height - binder_padding;
    
    module the_text() {
        linear_extrude(wall_thickness)
        text(binder_text,
            size=binder_size,
            font=binder_font,
            valign="center", 
            halign="left"
        );
    }
    
    translate([width - wall_thickness / 2, depth / 2, h])
    rotate([0, 90, 0])
    the_text();
    
    translate([wall_thickness / 2, depth / 2, h])
    rotate([0, 90, 180])
    the_text();
}

module back_text() {
    module the_text() {
        linear_extrude(wall_thickness)
        multi_line_text(back_text,
            size=back_size,
            font=back_font,
            line_spacing=line_spacing,
            valign="center", 
            halign="center"
        );
    }
    
    translate([width / 2, depth - wall_thickness / 2, (height + cutout_radius) * .5])
    rotate([90, 0, 180])
    the_text();
}

module art_window() {
    hull() {
        translate([
            (width - window_width) / 2,
            0, 
            window_y
        ])
        cube([window_width, wall_thickness, window_height]);
        
        # translate([width / 2 - cutout_radius, 0, wall_thickness])
        cube([cutout_radius * 2, wall_thickness, 2]);
    }
}

difference() {
    box();
    binder_text();
    # back_text();
    if (tolerance_check) {
        translate([0, 0, wall_thickness * 5])
        cube([width, depth, height]);
        
        cube([width, depth, wall_thickness]);
    } else {
        inside_cutout();
        art_window();
        translate([0, 0, -card_height])
        finger_cutout();
    }
}
