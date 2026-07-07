# Symbol gallery — every description forced to the TOP with `lpos up`
# (reference and value stack above the symbol).
# Shared by symbols_us_top.sch / symbols_iec_top.sch, which set the style in
# their `sheet` line and pull this file in with `include`.
# Derived from ../symbols_kit.sch. Not every line takes `lpos`: testpoint,
# port, rail and gnd draw their own labels, chips label their pins, and the
# rc block's inline parts sit on a route — those stay unchanged.
net +5V #e8412f "+5 V"
net GND #2166ac

# --- two-terminal row (res, pot and inductor change with the style) ---
res      R1 "res" "10 kΩ"      at 120,90 lpos up
cap      C1 "cap" "100 nF"     at 260,90 lpos up
cap_pol  C2 "cap_pol" "10 µF"  at 400,90 lpos up
inductor L1 "inductor" "10 µH" at 540,90 lpos up
pot      P1 "pot" "10 kΩ"      at 680,90 lpos up
piezo    PZ "piezo" "4 kHz"    at 820,90 lpos up
xtal     X1 "xtal" "16 MHz"    at 960,90 lpos up

# --- diode / switch row ---
diode    D1 "diode" "1N4148" at 120,210 lpos up
schottky D2 "schottky" "BAT54" at 260,210 lpos up
zener    D3 "zener" "5.1 V"  at 400,210 lpos up
led      D4 "led" "red"      at 540,210 lpos up
switch   S1 "switch" "SPST"  at 680,210 lpos up
button   B1 "button" "6 mm"  at 820,210 lpos up
battery  BT "battery" "9 V" at 960,210 lpos up

# --- transistor / active row ---
npn   Q1 "npn"  "S8050" at 140,340 lpos up
pnp   Q2 "pnp"  "S8550" at 300,340 lpos up
nmos  M1 "nmos" "AO3400" at 460,340 lpos up
pmos  M2 "pmos" "AO3401" at 620,340 lpos up
opamp U1 "opamp" "LM358" at 810,340 lpos up

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

note Same gallery as ../symbols_kit.sch, but every part that accepts it carries "lpos up": reference and value stack above the symbol. testpoint/port/rail/gnd, the NE555 and the rc block's inline parts place their own labels and are unchanged.
