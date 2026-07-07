// ============================================================
// Milestone-1 piezo self-read jig  (parametric, OpenSCAD)
// Holds the piezo rings at fixed, repeatable spacing on a shared
// carrier plate (the plate is the mechanical coupling medium),
// plus a shelf for the Xiao + protoboard.
//
// Your rings: OD 38 mm, ID 14.8 mm, thickness 5 mm, qty 3.
// Print: PETG or PLA, NO steel inserts (stay nonmagnetic).
//        0.2 mm layers, 30-40% infill, no supports needed.
// Export: set show_rings = false, then render (F6) + export STL.
// ============================================================

// ---------- ring geometry (your parts) ----------
ring_od = 38;        // outer diameter [mm]
ring_id = 14.8;      // inner hole [mm]
ring_h  = 5;         // thickness [mm]
n_rings = 3;

// ---------- fit ----------
pocket_clear = 0.4;  // diametral clearance, ring drops into pocket
peg_clear    = 0.4;  // diametral clearance, center peg vs ring ID
pocket_depth = 1.5;  // locating-rim depth (ring sits mostly proud)
use_center_peg = true;
peg_extra    = 3;    // peg height ABOVE the plate top [mm] (< ring_h)

// ---------- layout ----------
// "row"      -> clean coupling-matrix geometry: a near/far distance gradient
//               (expect C01 > C02). Easiest to validate. START HERE for M1.
// "triangle" -> symmetric coupling (C01 ~ C02 ~ C12) AND the minimal in-plane
//               pattern for later pitch/roll control (3 points span a plane).
// NOTE: in the chi_nu model the lift force is VERTICAL only. In-plane layout
//       gives differential-vertical -> tilt/torque, never lateral thrust. The
//       lift CONTRAST itself is top/bottom -> a separate vertical-stack variant.
layout   = "row";    // "row" or "triangle"
ring_gap = 6;        // edge-to-edge gap between adjacent pockets [mm]

// ---------- carrier plate (coupling medium) ----------
plate_th     = 3;    // thickness; stiffer plate -> different coupling
plate_margin = 10;   // border around the pockets [mm]

// ---------- wire routing ----------
notch_w     = 3;     // channel width for ring leads (fits both face wires) [mm]
notch_dir   = "back";// "back" = toward the electronics shelf (short runs), or "front"
notch_under = 5;     // how far the channel reaches UNDER the ring [mm] (solder relief)
//                      the channel is cut THROUGH the plate, so the underside
//                      solder joint + wire are never squeezed against the print

// ---------- electronics shelf ----------
shelf      = true;
shelf_w    = 45;     // Xiao + small protoboard footprint [mm]
shelf_d    = 35;
shelf_gap  = 8;      // neck gap between active plate and shelf [mm]
shelf_hole_d = 2.6;  // mounting holes (self-tap / M2.5)

// ---------- preview ----------
show_rings = false;   // translucent ghost rings for a fit check (turn OFF to export)

$fn = 96;

// ---------- derived ----------
pocket_d = ring_od + pocket_clear;
pitch    = pocket_d + ring_gap;

function row_positions(n, p) = [ for (i = [0:n-1]) [ (i - (n-1)/2) * p, 0 ] ];
// equilateral triangle sized from the SAME center-to-center pitch as the row,
// so ring_gap means the same thing in both layouts (circumradius = pitch/sqrt3)
function tri_positions(p)    = [ for (a = [90, 210, 330]) [ (p/sqrt(3))*cos(a), (p/sqrt(3))*sin(a) ] ];

positions = (layout == "triangle")
            ? tri_positions(pitch)
            : row_positions(n_rings, pitch);

xs = [ for (p = positions) p[0] ];
ys = [ for (p = positions) p[1] ];
cx = (max(xs) + min(xs)) / 2;
cy = (max(ys) + min(ys)) / 2;
plate_w = (max(xs) - min(xs)) + pocket_d + 2*plate_margin;
plate_d = (max(ys) - min(ys)) + pocket_d + 2*plate_margin;

front_y = cy - plate_d/2;   // edge the wire notches exit toward

// ---------- modules ----------
module base_plate() {
    translate([cx - plate_w/2, cy - plate_d/2, 0])
        cube([plate_w, plate_d, plate_th]);
}

module pocket(pos) {                 // recess that locates a ring
    translate([pos[0], pos[1], plate_th - pocket_depth])
        cylinder(h = pocket_depth + 0.1, d = pocket_d);
}

module peg(pos) {                    // center locator, rises from pocket floor
    if (use_center_peg)
        translate([pos[0], pos[1], plate_th - pocket_depth])
            cylinder(h = pocket_depth + peg_extra, d = ring_id - peg_clear);
}

module notch(pos) {                  // through-slot: solder relief UNDER the ring + wire channel to edge
    z0 = -1;
    h  = plate_th + 2;               // cut full thickness so the underside joint has clearance
    if (notch_dir == "front") {
        edge = front_y + 5;                              // plate front edge
        innr = pos[1] - pocket_d/2 + notch_under;        // reach under the ring
        translate([pos[0] - notch_w/2, edge, z0])
            cube([notch_w, innr - edge, h]);
    } else {                         // "back" -> toward the electronics shelf
        edge = cy + plate_d/2 - 5;                       // plate back edge
        innr = pos[1] + pocket_d/2 - notch_under;        // reach under the ring
        translate([pos[0] - notch_w/2, innr, z0])
            cube([notch_w, edge - innr, h]);
    }
}

module shelf_body() {
    if (shelf) {
        sy = cy + plate_d/2 + shelf_gap;
        // neck
        translate([cx - 9, cy + plate_d/2 - 0.1, 0])
            cube([18, shelf_gap + 0.2, plate_th]);
        // shelf plate
        translate([cx - shelf_w/2, sy, 0])
            cube([shelf_w, shelf_d, plate_th]);
    }
}

module shelf_holes() {
    if (shelf) {
        sy = cy + plate_d/2 + shelf_gap;
        for (hx = [ -shelf_w/2 + 5, shelf_w/2 - 5 ])
            for (hy = [ 5, shelf_d - 5 ])
                translate([cx + hx, sy + hy, -1])
                    cylinder(h = plate_th + 2, d = shelf_hole_d);
    }
}

module ghost_ring(pos) {             // preview only
    color([0.55, 0.55, 0.6, 0.45])
    translate([pos[0], pos[1], plate_th - pocket_depth])
        difference() {
            cylinder(h = ring_h, d = ring_od);
            translate([0,0,-1]) cylinder(h = ring_h + 2, d = ring_id);
        }
}

// ---------- assembly ----------
difference() {
    union() {
        base_plate();
        shelf_body();
    }
    for (p = positions) pocket(p);
    for (p = positions) notch(p);
    shelf_holes();
}
for (p = positions) peg(p);          // pegs added after the cut so they survive

if (show_rings) for (p = positions) ghost_ring(p);
