# TX select (Stage 1b) — CD4066 routes ONE drive buffer to the active ring.
# Matches the firmware: GPIO0/GPIO1/GPIO18 are three independent TX-enable
# lines (tx0/tx1/tx2 in chi_nu_poc.yaml), exactly one closed at a time
# (XIAO ESP32-C6 pins D0/D1/D10 — GPIO3/4/5 are NOT on the C6 headers). The open
# switches leave their rings high-Z, so each ring's RX peak detector (Ch.4)
# reads it cleanly. One buffer (Ch.3) feeds the common switch-input bus.
# Grid layout: chip pins on an 80/50 pitch; rings, taps and grounds aligned.
sheet "TX select — CD4066 routes one drive buffer to the active ring (Stage 1b)"
net +3.3V #a31515 "+3.3 V"
net GND #2166ac

# --- CD4066 quad bilateral switch (3 of 4 switches used) ---
# defchip: the PART is importable (full_instrument.sch imports it and
# overrides the pin sides to suit its own layout)
defchip CD4066 250x320 "CD4066" "quad bilateral switch"
  left   INA INB INC
  right  OUTA OUTB OUTC
  top    VDD
  bottom CTLA CTLB CTLC VSS
end
chip SW CD4066 at 500,350

# --- drive input from the Chapter-3 push-pull buffer ---
port DRV "Drive buffer OUT" "push-pull, Ch.3" at 160,350
DRV.p -> [res Rd "R_drive" "100 Ω"] -> SW.INB
SW.INA -> SW.INB -> SW.INC          # common input bus: all three switches fed

# --- each switch output -> its ring hot; ring cold -> GND ---
SW.OUTA -> right 200 -> [piezo R0 "Ring 0" "C0 ≈ 2 nF"] -> right 80 -> GND
SW.OUTB -> right 200 -> [piezo R1 "Ring 1" "C0 ≈ 2 nF"] -> right 80 -> GND
SW.OUTC -> right 200 -> [piezo R2 "Ring 2" "C0 ≈ 2 nF"] -> right 80 -> GND

# RX taps: each ring's hot node also runs to its peak detector (Chapter 4),
# raised into the gap between the switch and the ring
port X0 "→ RX det 0 (Ch.4)" at SW.OUTA +140,-50
port X1 "→ RX det 1 (Ch.4)" at SW.OUTB +140,-50
port X2 "→ RX det 2 (Ch.4)" at SW.OUTC +140,-50
R0.a -> X0.p
R1.a -> X1.p
R2.a -> X2.p

# --- select lines from the Xiao, pins exactly below their switch controls ---
port S0 "GPIO0" at SW.CTLA -30,40
port S1 "GPIO1" at SW.CTLB -30,70
port S2 "GPIO18" at SW.CTLC -30,100
SW.CTLA -> S0.p
SW.CTLB -> S1.p
SW.CTLC -> S2.p

# --- power ---
SW.VDD -> +3.3V
SW.VSS -> GND

note Exactly one of GPIO0/GPIO1/GPIO18 high at a time (firmware enforces this) closes one switch; the driven ring gets the burst, the other two stay high-Z so their RX amp+detector chains read clean coupled ringdown. This replaces the hardwired single-ring TX of drive_stage.svg for the full 3x3 sweep.
note CD4066 VDD = +3.3 V, VSS = GND. This is deliberate: at VDD = 5 V the CD4066B worst-case control threshold is V_IH = 3.5 V, so a 3.3 V GPIO is OUT OF SPEC (it usually works at room temperature — and fails in the field). At VDD = 3.3 V the GPIO swings the full rail and the 0.7–2.6 V drive swing still fits. Cost: R_on rises to ~0.5–2 kΩ, in series with R_drive into the ~1.6 kΩ ring — the absolute drive amplitude drops, all channels equally; the relative matrix and the x120 RX gain absorb it. Want low R_on at 3.3 V? Order a 74HC4066 (~50 Ω) — drop-in.
note After each burst the firmware opens ALL switches before the capture window, so even the driven ring rings down high-Z (its ringdown swings ±1.5 V; the open switch's input clamp only nibbles below −0.5 V, gone by the time the diagonal tail is read).
note Alternative: a CD4051 8:1 mux (3 binary address lines A/B/C + INH) also works, but that needs firmware to drive a 2-bit address, not three independent enables — so the CD4066 matches chi_nu_poc.yaml as written.
