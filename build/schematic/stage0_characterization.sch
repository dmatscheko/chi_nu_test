# Stage 0 — piezo characterisation rig (Rigol gen + scope).
# One series sense resistor; two scope channels read the drive node and the
# piezo node. The SAME rig does all three measurements: resonance sweep,
# ringdown (gen = burst), and cross-coupling (read a second ring on the plate).
# Grid layout: both rings share the a-pin column, both grounds the same x.
sheet "Stage 0 — piezo characterisation (Rigol gen + scope, series-R sense)"
net GND #2166ac

# --- drive leg: GEN -> R_sense -> ring 0 -> GND ---
port GEN "Rigol GEN" "sweep / burst" at 130,210
GEN.p -> [res Rs "R_sense" "100 Ω"] -> right 80 -> [piezo R0 "Ring 0 (DUT)" "C0 ≈ 2 nF"] -> right 80 -> GND

# scope taps (×10 probes): CH1 over the drive node, CH2 over the piezo node
port CH1 "CH1 ×10" "drive monitor" at GEN +0,-120
port CH2 "CH2 ×10" "piezo node"    at R0.a -80,-120
GEN.p -> CH1.p
R0.a  -> CH2.p

# --- read ring 1 (cross-coupling): on the shared plate, NOT wired to ring 0 ---
piezo R1 "Ring 1 (RX)" "reads C_01" at R0 +0,160
port  CH3 "CH2/CH3 ×10" "read ring 1" at R1.a -80,0
R1.a -> CH3.p
R1.b -> right 80 -> GND

note Resonance sweep: GEN = sine, 1 kHz → 1 MHz. Current = (CH1 − CH2)/R_sense. Record BOTH marks: the CH2 DIP = series resonance f_s (max current — the frequency that pumps the most energy in through a ~100 Ω source), and the CH2 PEAK slightly above it = parallel resonance f_p (max impedance). k_eff² ≈ (f_p²−f_s²)/f_p² is the coupling. Use the scope's Bode/FRA mode if it has one. Q = f_r / Δf (−3 dB width).
note Which one to drive at Stage 1: sweep the burst frequency between f_s and f_p and keep whatever maximizes the COUPLED ring's response (usually near f_s when driving through ~100 Ω + the CD4066). Run-1 logged the 43.5 kHz CH2 peak — that is f_p, so re-check before freezing drive_freq (bandwidth f_r/Q is only ~0.6 kHz).
note Ringdown / same-port self-read: GEN = burst (20–100 cycles at f_s), watch CH2 decay after the drive stops — that decay IS the self-read signal. Q = π·f_r·τ (τ = 1/e envelope time). The gen idles at 50 Ω and damps the ring → understates Q; set its output High-Z for a truer number.
note Cross-coupling C_ij: rings 0 and 1 share the carrier plate — they are coupled mechanically through it, with NO wire between them. Drive ring 0, read ring 1 amplitude + phase. Repeat per ordered pair → the 3×3 matrix; the row layout expects C01 > C02 (distance gradient).
note Use ×10 (10 MΩ) probes so the high-Z ring is not loaded. Piezo soldering: keep the iron on the silvered electrode under ~1 s — long heat blisters/de-coats and locally depoles it.
