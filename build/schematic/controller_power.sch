# Controller, power & I²C bus — rev 2 (2026-07-05).
# Corrected to the REAL Seeed XIAO ESP32-C6 pinout: the C6 module exposes
# GPIO 0,1,2,21,22,23,16,17,18,19,20 only. I²C is GPIO22 (SDA) / GPIO23 (SCL);
# GPIO3/4/5/6/7 are NOT on the headers (GPIO3 feeds the RF switch). TX-select
# moves to GPIO0/GPIO1/GPIO18. Power is single-rail 3.3 V: USB-C on the bench,
# a 1S LiPo on the XIAO BAT pads (onboard charger) untethered — the old
# 2S + 7805 plan is dropped (7805 dropout needs >7 V; a 2S sags below that,
# and an AMS1117 from 7.4 V overheats at WiFi peaks).
sheet "Controller, power & I²C bus"
net +3.3V #a31515 "+3.3 V"
net GND #2166ac

# --- controller: the hub everything else anchors to ---
chip XIAO 260x260 "Xiao ESP32-C6" "WiFi → Home Assistant"
  left  USB BAT V3 GND
  right GPIO2 GPIO0/1/18 GPIO21 GPIO22 GPIO23
end

# --- power sources (left of the Xiao) ---
port USBC "USB-C" "bench: power + flash" at XIAO.USB -160,0
battery LIPO "1S LiPo" "3.7 V → BAT pads" down at XIAO.BAT -220,60
USBC.p -> XIAO.USB
LIPO.a -> XIAO.BAT color #e8412f
LIPO.b -> GND

# --- the 3.3 V rail comes OUT of the Xiao's regulator/charger ---
# riser to the bus-head node _3V3 (flag above it); the bus threads a named
# node over each consumer, so every drop is a plain NODE -> PIN link
chip ADS at XIAO.GPIO22 +490,20 150x200 "ADS1015" "addr 0x48"
  left  VDD SDA SCL ADDR
  right AIN0 AIN1 AIN2 AIN3
end

res Rsda "Rp" "4.7 kΩ" down lpos
res Rscl "Rp" "4.7 kΩ" down lpos

XIAO.V3 -> left 60 -> up 220 -> _3V3 -> +3.3V
_3V3_START <- left 20 <- _3V3 -> right to XIAO.GPIO22 +200 -> _RSDA ->
        right 80 -> _RSCL -> right 80 -> _VDD -> right 20
_RSDA -> Rsda.a
_RSCL -> Rscl.a
_VDD  -> ADS.VDD

# --- I²C: GPIO22/23 dead straight into the ADC, threading a named node under
# each pull-up; the drops are pure NODE links with no measured distances
# (the SCL pull-up's drop crosses the SDA line as a plain no-connect)
XIAO.GPIO22 -> _SDA -> ADS.SDA
XIAO.GPIO23 -> _SCL -> ADS.SCL
Rsda.b -> _SDA
Rscl.b -> _SCL

# --- GPIO destination stubs (pins 40 px out from their GPIO pins) ---
port P_DRV "DRIVE"   mirror at XIAO.GPIO2 +60,0
port P_SEL "TX SEL ×3"  mirror at XIAO.GPIO0/1/18 +60,0
port P_RST "RESET"   mirror at XIAO.GPIO21 +60,0
XIAO.GPIO2      -> P_DRV.p
XIAO.GPIO0/1/18 -> P_SEL.p
XIAO.GPIO21     -> P_RST.p

# --- grounds share one baseline ---
XIAO.GND -> left 50 -> down 100 -> GND
ADS.ADDR -> left 50 -> down 40 -> GND

note Power, bench: USB-C → Xiao onboard regulator = 3.3 V for EVERYTHING (ESP, ADS1015, amps, CD4066, drive buffer). Untethered: 1S LiPo soldered to the XIAO BAT pads (onboard charger charges it over USB); same 3.3 V rail. One source at a time is not an issue — the charger arbitrates.
note The drive buffer, CD4066 (VDD = 3.3 V) and the x120 RX amps all run from this 3.3 V rail — see drive_stage.svg / tx_select.svg / peak_detector.svg. An OPTIONAL +5 V bench rail (USB or 7805 from a bench supply) is only needed for the LM358-fallback amps or an LM386 drive experiment; nothing in the baseline uses it.
note I²C: SDA = GPIO22 (D4), SCL = GPIO23 (D5), 400 kHz; 4.7 kΩ pull-ups to 3.3 V (the GY-ADS1015 module usually carries its own — add external only if the bus does not ACK). ADDR → GND ⇒ address 0x48.
note Xiao C6 pin budget: GPIO2 = DRIVE (LEDC), GPIO0/GPIO1/GPIO18 = TX selects, GPIO21 = detector RESET, GPIO22/23 = I²C. Free for sensors later: GPIO16/17 (UART), GPIO19/20. GPIO3/4/5/6/7 do not exist on the headers (C3-only pin map — do not copy configs across).
note Single star ground; keep the drive-stage return off the detector grounds; route I²C and the ring/amp analog area away from the WiFi antenna end.
