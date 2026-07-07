# Symbol gallery — every built-in symbol, plus include/defchip and def/use.
# Shared by symbols_us.sch / symbols_iec.sch, which set the style in their
# `sheet` line and pull this file in with `include`. No sheet size anywhere:
# the canvas auto-sizes around the content.
net +5V #e8412f "+5 V"
net GND #2166ac

# --- two-terminal row (res, pot and inductor change with the style) ---
res      R1 "res" "10 kΩ"      at 120,90
cap      C1 "cap" "100 nF"     at 260,90
cap_pol  C2 "cap_pol" "10 µF"  at 400,90
inductor L1 "inductor" "10 µH" at 540,90
pot      P1 "pot" "10 kΩ"      at 680,90
piezo    PZ "piezo" "4 kHz"    at 820,90
xtal     X1 "xtal" "16 MHz"    at 960,90

# --- diode / switch row ---
diode    D1 "diode" "1N4148" at 120,210
schottky D2 "schottky" "BAT54" at 260,210
zener    D3 "zener" "5.1 V"  at 400,210
led      D4 "led" "red"      at 540,210
switch   S1 "switch" "SPST"  at 680,210
button   B1 "button" "6 mm"  at 820,210
battery  BT "battery" "9 V" at 960,210

# --- transistor / active row ---
npn   Q1 "npn"  "S8050" at 140,340
pnp   Q2 "pnp"  "S8550" at 300,340
nmos  M1 "nmos" "AO3400" at 460,340
pmos  M2 "pmos" "AO3401" at 620,340
opamp U1 "opamp" "LM358" at 810,340

# --- points & terminals: testpoint, port, and standalone rail/gnd flags.
# A standalone rail/gnd symbol is a real net terminal: its label is the net
# name, so it takes the net's display text and ties into colouring / --nets.
testpoint TP "TP1"      at 960,340
port      PIN2 "GPIO"   at 1100,340
rail      F1 "+5V"      at 1090,440
gnd       G1            at 1150,420

# --- chips from a shared library + a stamped RC block ---
include "lib.sch"
chip T1 NE555 at 260,600

port PIN "GPIO" at T1.TRIG -70,0
PIN.p -> T1.TRIG
T1.VCC -> up 40 -> +5V
T1.GNDP -> GND

def rc(inp)
  inp -> [res Rx "R" "10 kΩ"] -> right 30 -> down -> [cap Cx "C" "100 nF"] -> GND
end
use rc rc0 at T1.OUT

note One of each symbol; res/pot/inductor switch between US zigzag and IEC boxes with the sheet style word. rail/gnd also exist standalone (net-tied via their label). The NE555 comes from lib.sch via include + defchip; the RC low-pass on OUT is a def/use block (parts rc0.Rx, rc0.Cx).
