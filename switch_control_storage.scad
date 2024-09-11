// Idea from thingiverse's asbeg, done from scratch since he doesn't allow
// derivative works

// Everything in mm

include <BOSL/constants.scad>
use <BOSL/masks.scad>
use <BOSL/transforms.scad>

// Minimum angle
$fa = 0.1;

// Minimum size
$fs = 0.1;

// Tolerance - adjust as needed
tolerance = 0.2;

// Switch card width
sw_card_w = 21.5;
// Switch card width notch
sw_card_w_notch = 20.5;
// Switch card height
sw_card_h = 31;
// Switch card thickness
sw_card_thick = 3.33;
// Switch card bevel radius
sw_card_b_r = 1;

// Switch joycon rail height
sw_jc_r_height = 85.4;
// Switch joycon rail width
sw_jc_r_width = 11;
// Switch joycon rail thickness
sw_jc_r_thick = 2.2;
// Switch joycon rail inside height
sw_jc_r_in_height = 80;
// Switch joycon rail inside width
sw_jc_r_in_width = 7.5;
// Switch joycon rail inside thickness
sw_jc_r_in_thick = 1;
// Switch joycon rail inside notch offset
sw_jc_r_in_notch_off = 4.2;
// Switch joycon rail inside notch width
sw_jc_r_in_notch_w = 2.2;

module switch_game_card_fillet(l, r, t) {
    fillet_mask(l = l + t, r = r, orient = ORIENT_Z, align=V_UP);
}

module switch_game_card(t) {
    difference() {
	difference() {
	    difference() {
		difference() {
		    cube([sw_card_w + t, sw_card_h + t, sw_card_thick + t]);
		    switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
		}
		right(sw_card_w + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
	    }
	    back(sw_card_h + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
	}
	back(sw_card_h + t) right(sw_card_w + t) switch_game_card_fillet(sw_card_thick, sw_card_b_r, t);
    }
}

// Creates an object for testing switch gamecard fitment
module switch_game_card_test(t) {
    extra = 2;
    difference() {
	difference() {
	    cube([sw_card_w + extra, sw_card_h + extra, sw_card_thick + extra]);
	    right(extra / 2) back(extra / 2) switch_game_card(tolerance);
	}
	up(sw_card_thick) right(extra) back(extra) cube([sw_card_w - extra, sw_card_h - extra, sw_card_thick + extra]);
    }
}

module switch_joycon_notch(t, o) {
    diff = (sw_jc_r_width - sw_jc_r_in_width) + t;
    // The notch starts into the inside rail and extends to the outside rail width
    right(o) up(sw_jc_r_thick) back(sw_jc_r_in_notch_off - t) cube([diff/2, sw_jc_r_in_notch_w + t * 2, sw_jc_r_in_thick + t]);
 }

// Notch for right side joycon
module switch_joycon_notch_right(t) {
    switch_joycon_notch(t, 0);
}

// Notch for left side joycon
module switch_joycon_notch_left(t) {
    diff = (sw_jc_r_width - sw_jc_r_in_width) + t;
    switch_joycon_notch(t, sw_jc_r_in_width + diff/2);
 }

module _switch_joycon_rail(t) {
    union() {
	cube([sw_jc_r_width + t, sw_jc_r_height + t, sw_jc_r_thick + t]);
	up(sw_jc_r_thick) right((sw_jc_r_width - sw_jc_r_in_width) / 2) cube([sw_jc_r_in_width + t, sw_jc_r_in_height + t, sw_jc_r_in_thick + t]);
    }
}
module switch_joycon_rail_right(t) {
    union() {
	_switch_joycon_rail(t);
	switch_joycon_notch_right(t);
    }
}

module switch_joycon_rail_left(t) {
    union() {
	_switch_joycon_rail(t);
	switch_joycon_notch_left(t);
    }
}

module _switch_joycon_rail_test(t, extra) {
    cube([sw_jc_r_width + 2 * extra, sw_jc_r_height + 2 * extra, sw_jc_r_thick + sw_jc_r_in_thick + extra]);
}
module switch_joycon_rail_test(t) {
    extra = 2;
    difference() {
	_switch_joycon_rail_test(t, extra);
	right(extra) up(extra) switch_joycon_rail_right(t);
    }
/*
    right(sw_jc_r_width + 4 * extra) difference() {
	_switch_joycon_rail_test(t, extra);
	right(extra) up(extra) switch_joycon_rail_left(t);	
    }
*/
}

//switch_game_card_test(tolerance);
//switch_joycon_rail(tolerance);
switch_joycon_rail_test(tolerance);
