# RX channel — ~x120 amplifier + peak detector, one channel (repeat x3).
# Rev 2 (2026-07-05): Stage-0 measured the coupled ring signals at 2-10 mV —
# far below a Schottky's conduction knee — so a bare diode detector cannot see
# them. Each RX channel now amplifies ~x120 (two single-supply non-inverting
# stages) BEFORE the 1N5819 envelope detector. C_hold is 10 nF (tau = 100 ms
# with R_bleed 10 M), so the three sequential ADS reads see <6% droop.
# Single-supply design on the +3.3 V rail; V_BIAS = mid-rail from a divider.
#
# The whole channel is the reusable group `rx_channel`, the divider is
# `vbias` (both imported by full_instrument.sch, which stamps the channel
# x3 around ONE shared divider); this sheet stamps each once.
sheet "RX channel — x120 amp + peak detector (one of three)"
net +3.3V #a31515 "+3.3 V"
net GND #2166ac

# --- GROUP: V_BIAS mid-rail divider (one serves all three channels) ---
def vbias(vb)
  vb -> up 20 -> [res RB1 "R_b1" "100 kΩ"].b -> up 20 -> +3.3V
  vb -> down 20 -> [res RB2 "R_b2" "100 kΩ"] -> GND
  vb -> right 120 -> _CB
  _CB -> down 20 -> [cap CB "C_b" "100 nF"] -> GND
end

# --- GROUP: one full RX channel — ring at `hot`, x120 amp, detector,
#     hold cap, reset leg. All positions hot-relative, so it stamps
#     anywhere. Reset drive enters at RRB.b; held node taps at RDS.a. ---
def rx_channel(hot, ring, vb)
  # the ring hangs at the hot node; R_ref gives it a DC return
  hot -> [piezo RNG ring "C0 ≈ 2.3 nF" down lpos left] at hot -> GND
  hot -> right 80 -> down -> [res RRF "R_ref" "1 MΩ"] -> GND

  # stage 1: non-inverting x21 (DC gain 1: R_g1 blocked by C_g1)
  opamp A1 "A1 ½ MCP6022" "x21" at hot +350,-10 lpos down
  hot -> right 160 -> [cap CIN "C_in" "10 nF"] -> INP
  INP -> A1.in+
  INP -> down 120 -> [res RBI "R_bias" "1 MΩ"] -> down 130 -> vb
  A1.vcc -> up 25 +3.3V
  A1.vee -> right 55 -> down 40 GND
  A1.in- -> left 30 -> up 120 -> F1
  F1 -> left 20 -> [res RG1 "R_g1" "5.1 kΩ"] -> [cap CG1 "C_g1" "1 µF"] -> GND
  F1 -> right 30 -> [res RF1 "R_f1" "100 kΩ"].b -> right 80 -> down 90 -> _O1
  A1.out -> _O1

  # stage 2: non-inverting x5.7 (DC-coupled: stage-1 out sits at V_BIAS)
  opamp A2 "A2 ½ MCP6022" "x5.7" at hot +830,-10 lpos down
  _O1 -> A2.in+
  A2.vcc -> up 25 +3.3V
  A2.vee -> right 55 -> down 40 GND
  A2.in- -> left 30 -> up 120 -> F2
  F2 -> left 20 -> [res RG2 "R_g2" "10 kΩ"] -> [cap CG2 "C_g2" "1 µF"] -> GND
  F2 -> right 30 -> [res RF2 "R_f2" "47 kΩ"].b -> right 80 -> down 90 -> _O2
  A2.out -> _O2

  # envelope detector: AC-coupled, ground-referenced, held on C_hold
  _O2 -> [res RS "R_s" "100 Ω"] -> [cap CC "C_c" "100 nF"] -> DA
  DA -> down -> [res RDC "R_dc" "100 kΩ"] -> GND
  DA -> right 60 -> [schottky D "D 1N5819" "Schottky"] -> N
  N -> down -> [cap CH "C_hold" "10 nF"] -> GND
  N -> right 120 -> _NB1 -> down -> [res RBL "R_bleed" "10 MΩ"] -> GND
  _NB1 -> right 120 -> _NB2 -> down -> [res RDS "R_dis" "100 Ω"]

  # reset leg: transistor under R_dis, base resistor out to the right
  RDS.b -> down 60 -> [npn QR "Q_rst" "S8050" mirror lpos left].C
  QR.E -> GND
  QR.B -> [res RRB "R_b" "10 kΩ"]
end

# --- this sheet: one channel + the divider, stamped once ---
node H  at 150,200
node VB at 100,510
use vbias BIAS(VB)
use rx_channel CH(H, "Piezo ring (RX)", VB)

# --- the ADC, raised so its body clears the reset leg below the bus ---
chip ADS at CH.RDS.a +250,-60 200x200 "ADS1015" "I²C · 4-ch mux · PGA"
  left  AIN0 AIN1 AIN2 AIN3
  right VDD SDA SCL
end
CH.RDS.a -> ADS.AIN0

# --- reset drive: GPIO21 stub into the base resistor ---
port RST "RESET" "GPIO21" mirror at CH.RRB.b +60,0
CH.RRB.b -> RST.p

note Gain: A1 x21 (1+100k/5.1k), A2 x5.7 (1+47k/10k) → ~x120 total. 2 mV ring signal → ~0.24 V at the detector → ~0.1 V held; 10 mV → ~1 V held. Op-amp: MCP6022 / TLV2372 (GBW ≥ 3 MHz, rail-to-rail, one dual per channel). LM358 fallback: works at reduced accuracy (GBW 1 MHz → real gain ~x55 and supply-limited swing; bias V_B ~0.9 V via R_b2 = 39 kΩ, run it from 5 V if available).
note Capture is reset-AFTER-burst (firmware): drive off → TX switches open → 100 µs reset pulse → C_hold recharges from pure ringdown, so burst feedthrough never enters C_ij. The DRIVEN ring saturates the amp; its diagonal C_ii is read on a second burst after diag_tail_ms ~ 3 ms, when the tail is back in range.
note Hold: C_hold 10 nF × R_bleed 10 MΩ = 100 ms; reading all three channels a few ms after reset keeps >94% on every channel. Reset: Q_rst discharges C_hold in ~1 µs through R_dis.
note One V_BIAS divider (R_b1/R_b2/C_b) serves all three channels — each channel adds only its own R_bias 1 MΩ. AIN1/AIN2 ← the other two identical channels. ADS VDD ← 3V3, SDA ← GPIO22, SCL ← GPIO23 (see controller_power.svg).
