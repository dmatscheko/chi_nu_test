# Milestone-1 self-read PoC — system overview.  Block/flow diagram.
# Grid layout: the signal chain row has uniform 60-px gaps between blocks.
sheet "Milestone-1 self-read PoC — system overview"

# --- blocks (anchored to neighbours) ---
block POWER "Power" "USB-C / 1S LiPo (BAT pads)|→ one 3.3 V rail" at 130,95 190x66
block XIAO "Xiao ESP32-C6" "LEDC drive · RESET|I²C master · WiFi" at POWER +370,5 200x96 accent
  bottom DRIVE RESET I2C
end
block HA "Home Assistant" "timestamped log|= evidence bundle" at XIAO +360,-5 180x66

block DRIVE  "Drive buffer" "S8050 / S8550"                 at POWER  +0,185 170x62
block RINGTX "Ring 0 (TX)" "piezo"                          at DRIVE  +0,120 170x60
block RINGRX "Rings on jig (RX)" "shared-plate coupling"    at RINGTX +240,0 180x60
block DET    "Amps ×120 + detectors ×3" "MCP6022 · 1N5819 / hold"  at RINGRX +240,0 200x64
block ADS    "ADS1015" "I²C · 4-ch mux · PGA"               at DET    +240,0 180x60 accent

# --- signal / data flow (three signals leave the Xiao via named bottom pins) ---
flow POWER.e -> XIAO.w                    "USB / BAT"
flow POWER.s -> DRIVE.n                   "3.3 V"
flow XIAO.DRIVE -> down -> DRIVE.e        "DRIVE (GPIO2)"
flow DRIVE.s -> RINGTX.n                  "~2 Vpp"
flow RINGTX.e -> RINGRX.w                 "plate|coupling"
flow RINGRX.e -> DET.w                    "ringdown (mV)"
flow DET.e -> ADS.w                       "held peak (V)"
flow ADS.n -> up 70 -> XIAO.I2C           "I²C (SDA/SCL)"
flow XIAO.e -> HA.w dash                  "WiFi"
flow XIAO.RESET -> down -> DET.n          "RESET"

note Loop: drive → self-read → record → (predict). The reproducible coupling matrix logged in HA, standing above the shuffled AND off-resonance controls, is the Milestone-1 receipt. Rev 2: single 3.3 V rail; coupled signals are mV-level, so every detector gets a ×120 amp in front (see peak_detector.svg).
