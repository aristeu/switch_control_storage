// Idea from thingiverse's asbeg, done from scratch since he doesn't allow
// derivative works

// Everything in mm

include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>

// Tolerance - adjust as needed
tolerance = 0.2;

// Place the sd cards along with the joycons instead of sideways
drawer_long = false; // [true,false]
// Number of drawers
drawers = 1; // [1:4]
// Wall thickness
walls = 2;
// Chamfer radius
chamfer_radius = 3;
// Is the first line a logo?
logo_first_line_logo = true; // [true,false]
// Which logo to use
logo="switch_logo.svg"; // ["switch_logo.svg":"Switch"]
// Number of lines (first one might be the logo)
logo_nlines = 1; // [0:3]
// Text lines
logo_line = ["Nintendo", "Switch", "Something"];
// Font Size
font_size = 6;

module __Customizer_Limit__() {}
// Minimum angle
$fa = 0.1;
// Minimum size
$fs = 0.1;

// Switch card width
sw_card_w = 21.5;
// Switch card width notch
sw_card_w_notch = 20.5;
// Switch card depth
sw_card_d = 31;
// Switch card thickness
sw_card_thick = 3.33;
// Switch card bevel radius
sw_card_b_r = 1;

// Switch joycon rail depth
sw_jc_r_depth = 85.4;
// Switch joycon rail width
sw_jc_r_width = 11;
// Switch joycon rail thickness
sw_jc_r_thick = 2.2;
// Switch joycon rail inside depth
sw_jc_r_in_depth = 80;
// Switch joycon rail inside width
sw_jc_r_in_width = 7.5;
// Switch joycon rail inside thickness
sw_jc_r_in_thick = 1;
// Switch joycon rail inside notch offset
sw_jc_r_in_notch_off = 4.2;
// Switch joycon rail inside notch width
sw_jc_r_in_notch_w = 2.2;
// Switch joycon offset from end of rail until the end of the joycon
sw_jc_r_depth_offset = 7;
// Total switch joycon thickness
sw_jc_r_total_thick = sw_jc_r_thick + sw_jc_r_in_thick;

// Switch body depth
sw_depth = 101;

drawer_thickness = sw_card_thick + walls;

module switch_game_card_fillet(l, r, t) {
    fillet_mask(l = l + t, r = r, orient = ORIENT_Z, align=V_UP);
}

module switch_game_card(t) {
    difference() {
	cube([sw_card_w + t, sw_card_d + t, sw_card_thick + t]);
	switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
	right(sw_card_w + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
	back(sw_card_d + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
	back(sw_card_d + t) right(sw_card_w + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
    }
}

// Creates an object for testing switch gamecard fitment
module switch_game_card_test(t) {
    extra = 2;
    difference() {
	cube([sw_card_w + extra, sw_card_d + extra, sw_card_thick + extra]);
	right(extra / 2) back(extra / 2) switch_game_card(tolerance);
	up(sw_card_thick) right(extra) back(extra) cube([sw_card_w - extra, sw_card_d - extra, sw_card_thick + extra]);
    }
}

module switch_joycon_notch(t) {
    diff = (sw_jc_r_width - sw_jc_r_in_width) + t;
    // The notch starts into the inside rail and extends to the outside rail width
    up(sw_jc_r_thick) back(sw_jc_r_in_notch_off - t) cube([diff/2, sw_jc_r_in_notch_w + t * 2, sw_jc_r_in_thick + t]);
 }

/* This is used to carve a path before the proper rail with notch startlogo_liness */
module switch_joycon_rail_bare(t) {
    union() {
	cube([sw_jc_r_width + t, sw_jc_r_depth + t, sw_jc_r_thick + t]);
	/* Notice the inner rail has the same length here, this is on purpose */
	up(sw_jc_r_thick) right((sw_jc_r_width - sw_jc_r_in_width) / 2) cube([sw_jc_r_in_width + t, sw_jc_r_depth + t, sw_jc_r_in_thick + t]);	
    }
}

module switch_joycon_rail(t) {
    union() {
	cube([sw_jc_r_width + t, sw_jc_r_depth + t, sw_jc_r_thick + t]);
	up(sw_jc_r_thick) right((sw_jc_r_width - sw_jc_r_in_width) / 2) cube([sw_jc_r_in_width + t, sw_jc_r_in_depth + t, sw_jc_r_in_thick + t]);
	switch_joycon_notch(t);
    }
}

module switch_joycon_rail_block(t, extra_w, extra_h, extra_d, walls) {
    difference() {
	cube([sw_jc_r_width + 2 * extra_w, sw_jc_r_depth + 2 * extra_d, sw_jc_r_thick + sw_jc_r_in_thick + extra_h]);
	right(extra_w) up(extra_h) back(sw_jc_r_depth_offset) #switch_joycon_rail(t);
	right(extra_w) up(extra_h) back(-(sw_jc_r_depth - sw_jc_r_depth_offset)) #switch_joycon_rail_bare(t);
    }
}

module switch_game_card_slot(t) {
	union() {
	    switch_game_card(t);
	    right(0.1 * sw_card_w) back(0.1 * sw_card_d) down(sw_card_thick) scale([0.8, 0.8, 1]) #switch_game_card(t);
	}
}

module _drawer(t, walls) {
    // We could probably make this configurable someday
    if (drawer_long) {
	slots = 3;
	width = sw_card_w + 2 * walls;
	depth = slots * (sw_card_d + walls) + walls;
	slot_depth = sw_card_d;
	difference() {
	    cube([width, depth, drawer_thickness]);
	    for (i = [0:1:slots-1]) {
		up(walls) right(walls) back(i * slot_depth + (i * walls) + walls) #switch_game_card_slot(t);
	    }
	}
    } else {
	slots = 4;
	width = sw_card_d + 2 * walls;
	depth = slots * (sw_card_w + walls) + walls;
	slot_depth = sw_card_w;
	difference() {
	    cube([width, depth, drawer_thickness]);
	    for (i = [0:1:slots-1]) {
		up(walls) right(sw_card_d + walls) back(i * slot_depth + (i * walls) + walls) rotate([0, 0, 90]) #switch_game_card_slot(t);
	    }
	}
    }
}

module drawer_puller(t, width, depth, height) {
    union() {
	cube([width, depth / 4, height * 2]);
	cube([width, depth, height]);
    }
}

module drawer(t, walls) {
    puller_depth = 2 * walls;
    puller_height = walls;
    puller_width = 4 * walls;
    puller_offset = ((drawer_long? sw_card_w:sw_card_d) + 2 * walls) / 2 - puller_width / 2;
    union() {
	back(puller_depth) _drawer(t, walls);
	right(puller_offset) drawer_puller(t, puller_width, puller_depth, puller_height);
    }
}

module logo_object(w, d, h) {
    lines = logo_nlines;
    right(w / 2) back(d / 2) up(h - walls/2)
    rotate([0, 0, 180])
    if (logo_first_line_logo) {
	lines = lines - 1;
	union() {
	    linear_extrude(walls * 2) {
		import(logo, center = true);
	    }
	    back(-20)
	    for (i = [0:1:lines - 1]) {
		back(-(i * 10)) linear_extrude(walls * 2) text(logo_line[i], size = font_size, halign = "center");
	    }
	}
    } else {
	for (i = [0:1:lines - 1]) {
	    back(-(i * 10)) linear_extrude(walls * 2) text(logo_line[i], size = font_size, halign = "center");
	}
    }
}

module body(t) {
    drawer_spacing = 2 * tolerance;
    drawer_width = (drawer_long? sw_card_w:sw_card_d) + 2 * walls;
    drawer_thickness_total = drawer_thickness + drawer_spacing;
    /* we must account for the space for the drawer, side walls and the joycon rail that will be carved */
    body_width = drawer_spacing * 2 + t * 2 + drawer_width + 2 * walls + 2 * sw_jc_r_total_thick;
    rail_and_walls = sw_jc_r_width + 2 * walls + 2 * drawer_spacing + ((drawers > 1)? chamfer_radius:0);
    drawers_height = drawers * (drawer_thickness_total + walls) + walls + drawer_spacing + ((drawers > 1)? chamfer_radius:0);
    body_height = (rail_and_walls > drawers_height)? rail_and_walls:drawers_height;
    body_depth = sw_depth;
    drawer_height_total = drawer_thickness + drawer_spacing;
    drawer_width_total = drawer_width + drawer_spacing;

    drawer_w_offset = (body_width - drawer_width_total) / 2;
    rail_depth_extra = (body_depth - (sw_jc_r_depth + 2 * walls)) / 2 + walls;
    rail_width = sw_jc_r_thick + sw_jc_r_in_thick + walls;

    difference() {
	cube([body_width, body_depth, body_height]);
	/* Drawer hole */
	for (i = [0:1:drawers-1]) {
	    if (drawers > 1) {
		h_offset = walls + drawer_spacing + ((drawers > 1)? chamfer_radius/2:0) + i * (drawer_thickness_total + walls);
		right(sw_jc_r_total_thick + walls) up(h_offset) #cube([drawer_width_total, sw_depth, drawer_thickness_total]);
	    } else {
		h_offset = (body_height - drawer_thickness_total) / 2;
		right(sw_jc_r_total_thick + walls) up(h_offset) #cube([drawer_width_total, sw_depth, drawer_thickness_total]);
	    }
	}

	rail_h_offset = body_height - walls - sw_jc_r_width;
	/* Left side rail */
	up(rail_h_offset) right(sw_jc_r_total_thick) back(sw_jc_r_depth_offset) rotate([0, 270, 0]) #switch_joycon_rail(t);
	up(rail_h_offset) back(-(sw_jc_r_depth - sw_jc_r_depth_offset)) right(sw_jc_r_total_thick) rotate([0, 270, 0]) #switch_joycon_rail_bare(t);

	/* Right side rail */
	up(rail_h_offset) right(body_width - sw_jc_r_total_thick) back(sw_jc_r_depth_offset) rotate([0, 90, 0]) mirror([1,0,0]) #switch_joycon_rail(t);
	up(rail_h_offset) back(-(sw_jc_r_depth - sw_jc_r_depth_offset)) right(body_width - sw_jc_r_total_thick) rotate([0, 90, 0]) mirror([1,0,0]) #switch_joycon_rail_bare(t);

	/* Chamfer */
	fillet_mask(l = body_width + 2 * rail_width, r = chamfer_radius, orient = ORIENT_X, align=V_RIGHT);
	up(body_height) fillet_mask(l = body_width + 2 * rail_width, r = chamfer_radius, orient = ORIENT_X, align=V_RIGHT);
	back(body_depth) fillet_mask(l = body_width + 2 * rail_width, r = chamfer_radius, orient = ORIENT_X, align=V_RIGHT);
	back(body_depth) up(body_height) fillet_mask(l = body_width + 2 * rail_width, r = chamfer_radius, orient = ORIENT_X, align=V_RIGHT);

	/* Body logo */
	logo_object(body_width, body_depth, body_height);
    }
}

//switch_game_card(tolerance);
//switch_game_card_test(tolerance);
//switch_game_card_slot(tolerance);
//up(sw_jc_r_width) back(sw_jc_r_depth) rotate([0, 90, 180]) switch_joycon_rail_left(tolerance);
//switch_joycon_rail_block(tolerance, 2, 2, 2, 2);
//right(100) mirror([1, 0, 0])switch_joycon_rail_block(tolerance, 2, 2, 2, walls);
body(tolerance);
right(-50) drawer(tolerance, 2);
