# Drive stage — push-pull (complementary emitter-follower) buffer, one TX ring.
# Rev 2: runs from the +3.3 V rail. The output swing is set by the BASE drive
# (0–3.3 V from the GPIO), not by the rail: 0.7–2.6 V out either way, so the
# old +5 V rail bought nothing. Single-rail keeps the whole PoC on 3.3 V.
# Grid layout: signal runs left→right on y=250; both grounds share y=410,
# the rail sits at y=90; all part pitches are multiples of 20.
#
# The buffer itself is the reusable group `drive_buffer` (imported by
# full_instrument.sch); this sheet stamps it once and adds the ring load.
sheet "Drive stage — push-pull buffer (one TX ring)"
net +3.3V #a31515 "+3.3 V"
net GND #2166ac

# --- GROUP: the push-pull buffer, in -> R_base -> Q1/Q2 -> out ---
def drive_buffer(in, out)
  in -> [res Rb "R_base" "1k"] -> BASE
  [npn Q1 "Q1" "S8050 NPN" lpos right].B -> BASE <- [pnp Q2 "Q2" "S8550 PNP" lpos right].B
  Q1.C -> +3.3V
  Q2.C -> GND
  Q1.E -> out <- Q2.E
end

port LEDC "LEDC GPIO2" "f_r square" at 120,250
node OUT                       # the buffer's output binds to THIS node
use drive_buffer BUF(LEDC.p, OUT)

# OUT through R_drive into the ring; the ring's return drops to the same
# ground baseline as Q2's
OUT -> [res Rd "R_drive" "100 Ω"] -> [piezo RING "Ring 0 (TX)" "C0 ≈ 2 nF"] -> right 10 -> down 160 -> GND

note Stage 1a: this one buffer drives ring 0 only (rings 1,2 = RX). Full 3x3 later via the CD4066 select on GPIO0/GPIO1/GPIO18 (tx_select.svg).
note Output swing ~1.9 Vpp (0.7–2.6 V) — set by the 0–3.3 V base drive, identical on a 3.3 V or 5 V rail. More amplitude needs a lifted BASE swing (level shifter / gate driver), not just a higher rail; the LM386 (needs ≥4 V supply → the optional 5 V rail) can drive the radial mode harder. With the x120 RX amps, ~2 Vpp is enough for the receipt.
