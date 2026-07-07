# Milestone-1 self-read PoC — ONE connected graph of the whole instrument.
# Rev 2 (2026-07-05): real XIAO ESP32-C6 pins (I²C GPIO22/23, TX sel GPIO0/1/18),
# single +3.3 V rail (USB-C or 1S LiPo on the XIAO BAT pads — the 2S+7805 chain
# is gone), CD4066 at 3.3 V, and a ×120 amp in front of every peak detector
# (the measured couplings are 2–10 mV — a bare diode detector cannot see them).
# Made to be readable without electronics knowledge:
#   • DARK-RED line = +3.3 V power   • BLUE line = ground (GND)
#   • solid arrow  = the measurement signal as it travels
#   • dashed arrow = a control / data line from the brain (Xiao) or coupling
sheet "Milestone-1 self-read PoC — the whole instrument as one connected graph"
net +3.3V #a31515
net GND #2166ac

# ============================ TOP: brain, cloud, power ===================
block HA   "Home Assistant" "timestamped log = the receipt" at 470,60 240x60
block XIAO "Xiao ESP32-C6 (the brain)" "runs ESPHome firmware" at 790,210 240x170 accent
  top WIFI V33
  bottom DRIVE SEL RESET I2C
end

block PWR  "Power + 3.3 V rail" "USB-C (bench) or 1S LiPo|(regulator + charger live in the Xiao)" at 300,235 210x92

# ============================ BOTTOM: the signal chain ===================
block BUF "Drive buffer" "push-pull|S8050 + S8550" at 740,520 200x86
  top DRV
  left P33
  right OUT
end
block SEL "TX select" "CD4066 · VDD 3.3 V|picks the active ring" at 1020,540 180x150
  left IN
  top CTL P33
  right OA OB OC
end
block R0 "Ring 0" "piezo · C0≈2.3 nF" at 1320,440 160x60
block R1 "Ring 1" "piezo · C0≈2.3 nF" at 1320,565 160x60
block R2 "Ring 2" "piezo · C0≈2.3 nF" at 1320,690 160x60
block D0 "Amp ×120 + detector 0" "MCP6022 · 1N5819 · reset" at 1600,440 200x60
block D1 "Amp ×120 + detector 1" "MCP6022 · 1N5819 · reset" at 1600,565 200x60
block D2 "Amp ×120 + detector 2" "MCP6022 · 1N5819 · reset" at 1600,690 200x60
block ADS "ADS1015" "I²C analog-to-digital|4-ch · address 0x48" at 1890,565 160x160 accent
  left AIN0 AIN1 AIN2
  top VDD
  bottom I2C
end

# ============================ POWER (coloured wires) =====================
# one rail: the Xiao's onboard regulator/charger makes +3.3 V for everything
PWR.e -> XIAO.w color #8a6d3b
PWR.s -> down 200 -> _V33 -> BUF.P33 color #a31515
_V33 -> up 70 -> right to SEL.P33 -> SEL.P33 color #a31515
XIAO.V33 -> up 40 -> right to ADS.VDD -> ADS.VDD color #a31515

# common ground (blue) — one star point; shown on the source, common to all blocks
PWR.w -> left 30 -> down 80 -> GND

# ============================ CONTROL / DATA (dashed arrows) =============
flow XIAO.WIFI -> HA.s dash                       "WiFi"
flow XIAO.DRIVE -> BUF.DRV dash                   "DRIVE (GPIO2)"
flow XIAO.SEL -> SEL.CTL dash                     "pick ring (GPIO0/1/18)"
flow XIAO.RESET -> down 65 -> right to D0.n -> D0.n dash  "RESET detectors (GPIO21)"
flow XIAO.I2C -> down 515 -> right to ADS.I2C -> ADS.I2C dash "I²C bus — sends results back (GPIO22/23)"

# ============================ SIGNAL PATH (solid arrows) =================
flow BUF.OUT -> SEL.IN                            "~1.9 Vpp burst"
flow SEL.OA -> R0.w                               "drive"
flow SEL.OB -> R1.w
flow SEL.OC -> R2.w
flow R0.e -> D0.w                                 "ringdown (mV)"
flow R1.e -> D1.w
flow R2.e -> D2.w
flow D0.e -> ADS.AIN0                             "held peak (V)"
flow D1.e -> ADS.AIN1
flow D2.e -> ADS.AIN2

# the physics that makes it a "self-read": rings talk through the shared plate
flow R0.s -> R1.n dash                            "plate coupling (no wire)"
flow R1.s -> R2.n dash

# ============================ legend / notes ============================
note Read it left → right. POWER: USB-C on the bench, or a 1S LiPo soldered to the XIAO's BAT pads when untethered (the Xiao charges it over USB and its onboard regulator makes +3.3 V). That ONE dark-red 3.3 V rail feeds the brain, the drive buffer, the CD4066, the six amp op-amps and the ADS1015. All blocks share one common ground (blue).
note SIGNAL (solid arrows): the Xiao makes a square-wave burst → the push-pull buffer makes ~1.9 Vpp → the CD4066 routes it to ONE chosen ring → that ring rings the others through the shared plate (only millivolts arrive) → each ring's signal is amplified ×120, envelope-detected (1N5819 + 10 nF hold) → the held value is read by the ADS1015.
note CONTROL (dashed): the Xiao picks the ring (GPIO0/1/18), fires the burst (GPIO2, 50% duty LEDC), RESETS the detectors right AFTER each burst (GPIO21) so only true post-drive ringdown is held, then reads the three results over I²C (GPIO22/23) and logs them to Home Assistant over WiFi. The reproducible 3×3 table, above the shuffled AND off-resonance controls, is the Milestone-1 receipt.
note Each ring is BOTH a sender and a listener: the CD4066 drives the chosen one while the other two stay high-impedance and just listen — that is the "self-read". The driven ring's own channel saturates its amp during the burst, so its diagonal C_ii is captured on a second burst a few ms later (ringdown tail).
