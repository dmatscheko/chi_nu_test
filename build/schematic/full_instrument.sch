# Milestone-1 self-read PoC — THE FULL INSTRUMENT as one real schematic,
# BUILT FROM THE PARTS: the sub-circuits are `import`ed from the detail
# sheets and stamped here — nothing is redrawn:
#   drive_buffer  <- drive_stage.sch   (push-pull TX buffer)
#   CD4066        <- tx_select.sch     (the switch part; pins re-sided here)
#   rx_channel    <- peak_detector.sch (ring + x120 amp + detector, x3)
#   vbias         <- peak_detector.sch (ONE mid-rail divider for all 3)
# Rev 3 (2026-07-05): the three RX channels are now the REAL two-stage
# MCP6022 amp + detector circuits (rev 2 showed placeholder amp blocks).
#
# Flow: Xiao GPIO2 -> drive buffer -> R_drive -> CD4066 common input; CD4066
# (GPIO0/1/18 pick one switch) routes the burst to ONE ring; each ring's hot
# node feeds its x120 amp -> envelope detector; held nodes -> ADS1015
# AIN0/1/2; ADS <-> Xiao over I²C (GPIO22/23); GPIO21 resets the detectors.
sheet "Milestone-1 self-read PoC — full instrument (controller · drive · CD4066 · 3×(ring + ×120 amp + detector) · ADS1015)"
net +3.3V #a31515 "+3.3 V"
net GND #2166ac

import "drive_stage.sch"   drive_buffer
import "tx_select.sch"     CD4066
import "peak_detector.sch" rx_channel vbias

# =====================================================================
# DRIVE STAGE — the push-pull buffer from drive_stage.sch
# =====================================================================
node DRVIN at 300,620
node DRVOUT
use drive_buffer BUF(DRVIN, DRVOUT)

# =====================================================================
# TX SELECT — CD4066 from tx_select.sch (VDD = +3.3 V, in-spec control);
# pin rows re-sided for THIS layout: controls up top, toward the GPIOs
# =====================================================================
chip SW CD4066 at DRVIN +460,0
  left   INA INB INC
  right  OUTA OUTB OUTC
  top    VDD CTLA CTLB CTLC
  bottom VSS
end
DRVOUT -> [res Rdd "R_drive" "100 Ω"] -> SW.INB
SW.INA -> SW.INB -> SW.INC
SW.VDD -> +3.3V
SW.VSS -> GND

# =====================================================================
# THE THREE RX CHANNELS — rx_channel from peak_detector.sch, stamped
# around ONE shared V_BIAS divider. hot nodes: ring 1 level with OUTB;
# rings 0 and 2 stacked ±560 around it (real amp chains need the room).
# =====================================================================
node H1 at SW.OUTB +120,0
node H0 at H1 +0,-560
node H2 at H1 +0,560
SW.OUTB -> H1
SW.OUTA -> right 40 -> H0
SW.OUTC -> right 40 -> H2

node VB at H2 -160,310
use vbias BIAS(VB)

use rx_channel ch0(H0, "Ring 0", VB)
use rx_channel ch1(H1, "Ring 1", VB)
use rx_channel ch2(H2, "Ring 2", VB)

# =====================================================================
# ADS1015 ADC (right of the detector column; AIN1 level with channel 1)
# =====================================================================
chip ADS at H1 +1990,22 220x320 "ADS1015" "I²C ADC · 0x48"
  left   AIN0 AIN1 AIN2 ADDR
  right  SDA SCL
  top    VDD
  bottom GND
end
ch0.RDS.a -> right 220 -> ADS.AIN0
ch1.RDS.a -> ADS.AIN1
ch2.RDS.a -> right 220 -> ADS.AIN2
ADS.VDD -> +3.3V
ADS.GND -> GND
ADS.ADDR -> left 10 -> down 60 -> GND

# =====================================================================
# CONTROLLER — Xiao ESP32-C6 (right of the ADC) + battery on BAT pads
# =====================================================================
chip XIAO at ADS +560,36 280x360 "Xiao ESP32-C6" "ESPHome → Home Assistant"
  top    GPIO2 GPIO0 GPIO1 GPIO18
  left   GPIO22 GPIO23 GPIO21
  right  V33 BAT
  bottom GNDX
end

# power: USB-C (bench) or 1S LiPo on the BAT pads (onboard charger);
# the Xiao's regulator sources the system +3.3 V rail from V33
battery LIPO "1S LiPo" "3.7 V → BAT pads" down
XIAO.BAT -> right 60 -> down 30 -> LIPO.a
LIPO.b -> down 20 -> GND
XIAO.V33 -> right 60 -> up 60 -> +3.3V
XIAO.GNDX -> GND

# --- I²C: ADS SDA/SCL -> GPIO22/23, with 4.7k pull-ups to +3.3 V ---
# each I²C line threads a named _ node under its own pull-up, so the drops
# are plain NODE links (the SCL drop crosses the SDA line as a no-connect)
res Rsda "Rp" "4.7 kΩ" down lpos left  at ADS +260,-240
res Rscl "Rp" "4.7 kΩ" down lpos right at Rsda +60,0
node VPU at Rsda +30,-70
XIAO.GPIO22 -> left to Rsda.b -> _SDA -> ADS.SDA
XIAO.GPIO23 -> left to Rscl.b -> _SCL -> ADS.SCL
Rsda.b -> _SDA
Rscl.b -> _SCL
Rsda.a -> VPU
Rscl.a -> VPU
VPU -> +3.3V

# --- RESET: the three R_b ends are collinear, so they ARE the reset bus;
#     GPIO21 drops below the ADC and joins the bottom of that bus. ---
ch0.RRB.b -> ch1.RRB.b color #7a4b1e
ch1.RRB.b -> ch2.RRB.b
XIAO.GPIO21 -> ch2.RRB.b

# --- DRIVE: GPIO2 (top) -> top bus -> down into the buffer input ---
XIAO.GPIO2 -> up 780 -> DRVIN

# --- SELECT: GPIO0/1/18 (top) -> stepped top buses -> CD4066 CTLA/B/C ---
XIAO.GPIO0  -> up 740 -> SW.CTLA
XIAO.GPIO1  -> up 700 -> SW.CTLB
XIAO.GPIO18 -> up 660 -> SW.CTLC

# =====================================================================
note Power (single rail): bench = USB-C into the Xiao; untethered = 1S LiPo on the XIAO BAT pads (the onboard charger manages it). The Xiao regulator sources +3.3 V for EVERYTHING: drive buffer (Q1.C), CD4066 VDD, all six amp op-amps, ADS1015, pull-ups. The rev-1 2S LiPo + 7805 + Mini560 chain is gone — a 7805 needs >7 V in (a 2S sags below), an AMS1117 from 7.4 V overheats at WiFi peaks, and the 5 V rail bought no drive amplitude anyway (the push-pull output is capped at 2.6 V by its 3.3 V base swing, not by the rail).
note Drive: GPIO2 (LEDC, 50% duty at f_drive) → R_base 1k → S8050/S8550 push-pull → R_drive 100 Ω → CD4066 common input (INA=INB=INC). GPIO0/GPIO1/GPIO18 each close one switch (one at a time), routing ~1.9 Vpp to the selected ring; the other two rings stay high-Z and only listen. CD4066 at VDD = 3.3 V keeps the 3.3 V control lines IN SPEC (at VDD = 5 V the CD4066B needs V_IH = 3.5 V); its higher R_on (~0.5–2 kΩ) costs absolute amplitude only, which the ×120 RX gain absorbs.
note Per ring (the full circuit from peak_detector.sch, stamped ×3): hot node H = CD4066 output + ring + R_ref 1 MΩ; C_in 10 nF couples into the ×120 amp (A1 ×21 → A2 ×5.7, one MCP6022 dual per channel, inputs biased at V_BIAS = mid-rail from the ONE shared R_b1/R_b2/C_b divider — measured couplings are 2–10 mV, below a bare Schottky's knee, hence the amp). Amp out → R_s 100 Ω → C_c 100 nF → R_dc 100 kΩ reference → 1N5819 → C_hold 10 nF ∥ R_bleed 10 MΩ (τ = 100 ms) at held node N; Q_rst (base ← GPIO21 via 10 kΩ, collector via R_dis 100 Ω) clears N. Firmware resets AFTER each burst so N holds pure post-drive ringdown, never burst feedthrough.
note Readout: ADS1015 (addr 0x48, ADDR→GND, 12-bit) digitises AIN0/1/2 and returns them to the Xiao over I²C (GPIO22 = SDA, GPIO23 = SCL, 4.7 kΩ pull-ups). The reproducible 3×3 coupling matrix logged in Home Assistant, standing above the shuffled AND off-resonance controls, is the Milestone-1 receipt.
