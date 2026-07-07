# Symbol gallery — every description forced to the LEFT with `lpos left`
# (reference over value, right-aligned beside the symbol).
# Shared by symbols_us_left.sch / symbols_iec_left.sch, which set the style
# in their `sheet` line and pull this file in with `include`.
# Derived from ../symbols_kit.sch; the two-terminal rows are spread wider
# (160 instead of 140) so side labels clear the neighbouring part's lead.
# Not every line takes `lpos`: testpoint, port, rail and gnd draw their own
# labels, chips label their pins, and the rc block's inline parts sit on a
# route — those stay unchanged.
net +5V #e8412f "+5 V"
net GND #2166ac

# --- two-terminal row (res, pot and inductor change with the style) ---
res      R1 "res" "10 kΩ"      at 120,90 lpos left
cap      C1 "cap" "100 nF"     at 280,90 lpos left
cap_pol  C2 "cap_pol" "10 µF"  at 440,90 lpos left
inductor L1 "inductor" "10 µH" at 600,90 lpos left
pot      P1 "pot" "10 kΩ"      at 760,90 lpos left
piezo    PZ "piezo" "4 kHz"    at 920,90 lpos left
xtal     X1 "xtal" "16 MHz"    at 1080,90 lpos left

# --- diode / switch row ---
diode    D1 "diode" "1N4148" at 120,210 lpos left
schottky D2 "schottky" "BAT54" at 280,210 lpos left
zener    D3 "zener" "5.1 V"  at 440,210 lpos left
led      D4 "led" "red"      at 600,210 lpos left
switch   S1 "switch" "SPST"  at 760,210 lpos left
button   B1 "button" "6 mm"  at 920,210 lpos left
battery  BT "battery" "9 V" at 1080,210 lpos left

# --- transistor / active row (left is already the transistor default) ---
npn   Q1 "npn"  "S8050" at 140,340 lpos left
pnp   Q2 "pnp"  "S8550" at 300,340 lpos left
nmos  M1 "nmos" "AO3400" at 460,340 lpos left
pmos  M2 "pmos" "AO3401" at 620,340 lpos left
opamp U1 "opamp" "LM358" at 810,340 lpos left

# --- points & terminals: these draw their own labels; `lpos` does not apply ---
testpoint TP "TP1"      at 960,340
port      PIN2 "GPIO"   at 1100,340
rail      F1 "+5V"      at 1090,440
gnd       G1            at 1150,420

# --- chips from a shared library + a stamped RC block (chip pins and
#     route-inline parts keep their built-in label placement) ---
include "../lib.sch"
chip T1 NE555 at 260,600

port PIN "GPIO" at T1.TRIG -70,0
PIN.p -> T1.TRIG
T1.VCC -> up 40 -> +5V
T1.GNDP -> GND

def rc(inp)
  inp -> [res Rx "R" "10 kΩ"] -> right 30 -> down -> [cap Cx "C" "100 nF"] -> GND
end
use rc rc0 at T1.OUT

note Same gallery as ../symbols_kit.sch, but every part that accepts it carries "lpos left"; the two-terminal rows are spread wider so the side labels clear the neighbours. testpoint/port/rail/gnd, the NE555 and the rc block's inline parts place their own labels and are unchanged.
