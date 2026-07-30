# PCB, firmware, and protocol assessment — GPT

## 1. Disposition

**Do not fabricate the current KiCad revision unchanged.**

There are two independent reasons:

1. it is not an OPH force article under the current theory; and
2. the PCB has likely fabrication-blocking electrical/BOM defects even as a
   conventional piezo instrument.

After correction, the architecture can still be useful as a Milestone-1
drive/read/log prototype. It should be quarantined from the anti-gravity claim
and treated as conventional instrumentation until the theory gates are closed.

This is a targeted design/traceability review, not a substitute for ERC, DRC,
signal-integrity review, mechanical modal analysis, or a manufacturing release
review.

## 2. What is already useful

The current work has produced genuine engineering information:

- Stage 0 reports a relative, off-diagonal reciprocal coupling matrix.
- Its reported values show the expected near/far ordering.
- Same-port ringdown capture has a plausible reset-after-drive concept.
- The board has three selectable transmit ports and three amplified read paths.
- Battery operation removes a force-bearing power tether.
- The firmware can exercise and publish the nine amplitude channels.

These are useful results for piezo metrology. They do not distinguish OPH from
standard linear electromechanics.

The existing build document itself correctly describes Milestone 1 as a
self-reading piezo proof of concept with **no weighing and no lift claim**:
`build/MILESTONE_1_build.md:1–7,15–28`.
It also explicitly defers predictive boundary coupling \(P_U\) to Milestone 2:
`:30–37`.

## 3. Fabrication blockers

### 3.1 Unresolved release-blocking BJT pinout mismatch

The intended circuit names S8050/J3Y and S8550/2TY SOT-23 transistors, but does
not lock an exact manufacturer MPN or lot:
`build/electronics.md:383–395`. Those generic types and topmarks do not
uniquely determine a manufacturer pinout.
The intended drive nets put the collectors on the rails and the emitters on
`DRVOUT`: `build/electronics.md:447–458` and
`build/schematic/drive_stage.sch:14–21`.

The PCB symbol/footprint assignment instead uses:

```text
pad 1 = base
pad 2 = collector
pad 3 = emitter
```

Examples:

- Q1:
  `build/kicad/MILESTONE_1_build/full_instrument/full_instrument.kicad_pcb:13186–13214,13537–13565`;
- Q2:
  `:13931–13959`;
- reset transistor Q3:
  `:5191–5234,5542–5570`.

For the two cited manufacturer implementations, the pinouts are:

```text
pad 1 = base
pad 2 = emitter
pad 3 = collector
```

Primary references:

- [HY Electronic S8050/J3Y datasheet](https://www.hygroup.com.tw/upfiles/ADUpload/all_/S8050%20Rev-0.pdf), page 1;
- [Semiware S8550/2TY datasheet](https://en.semiware.com/uploads/datasheet/S8550.pdf), page 1.

The board therefore swaps collector and emitter **if those cited parts are
fitted**. It is not possible to infer Dave's unverified stock from a J3Y/2TY
topmark alone. This unresolved mismatch is nevertheless a release blocker:
lock the exact manufacturer and orderable MPN, bind its datasheet pinout to the
symbol and footprint, and incoming-inspect the actual parts before fabrication
or assembly.

### 3.2 No supply decoupling or bulk capacitance

The design text requires:

- 100 nF at every IC and 10 µF bulk:
  `build/electronics.md:320–329`;
- 100 nF plus 10 µF at the drive pair:
  `:416–418,447–458`;
- 100 nF at each MCP6022:
  `:576–589`.

The complete schematic/PCB contains no capacitor from +3.3 V to GND and no
10 µF footprint. Its capacitors are assigned to signal coupling, hold, gain,
and bias functions. The XIAO module may have its own onboard capacitance, but
U1–U5 have no local PCB bypass.

Six high-gain op-amp stages, drive edges, I²C, ADC conversion, and Wi-Fi share
one rail. Missing local bypass and board-level bulk capacitance is a serious
stability, measurement-integrity, and EMI risk. Add per-IC ceramics, local
analog/ADC decoupling, and bulk capacitance near the drive and controller
loads, then review return paths.

### 3.3 Floating unused CD4066 control

U1 uses three sections of a quad CD4066. PCB pads 10, 11, and 12 have no nets:
`build/kicad/MILESTONE_1_build/full_instrument/full_instrument.kicad_pcb:12747–13153`.
Pad 12 is the unused fourth switch's CMOS control input. It must not float;
terminate the unused control at a defined logic level, normally GND, and
handle the unused analog pins according to the locked manufacturer's
datasheet.

### 3.4 BOM and footprint conflicts

- The build prose specifies a stock GY-ADS1015 module
  (`build/MILESTONE_1_build.md:124–150,255–271`), while the PCB carries a bare
  ADS1015 TSSOP-10. Lock an exact MPN/suffix and its support circuit.
- The selector is only `CD4066`, with 74HC4066 mentioned as an optional
  substitute. This is not a benign interchangeable detail at 3.3 V. The
  [TI CD4066B datasheet](https://www.ti.com/lit/ds/symlink/cd4066b.pdf)
  specifies \(R_{\rm on}=470\,\Omega\) typical and \(1050\,\Omega\) maximum at
  5 V and does not specify it at 3.3 V. It can dominate the declared
  \(100\,\Omega\) drive impedance. Lock the switch MPN and measure drive
  voltage/current and \(R_{\rm on}\) over signal level and temperature.
- The prose calls the detector diode “1N5819 (SS14)”
  (`build/electronics.md:529–570`), while D1–D3 use a generic 1206 diode
  footprint. SS14 is normally SMA; axial 1N5819 is normally DO-41. Choose one
  exact Schottky MPN and correct the symbol/footprint/BOM.
- The prose calls for a 1S LiPo on the XIAO BAT pads
  (`build/electronics.md:278–303`), but the board places an MPD BH-18650-PC
  holder. Besides the documentation mismatch, an unspecified 18650
  cell/holder may contain ferromagnetic steel parts and introduces magnetic
  and center-of-mass variables for a future precision-force article.

These are manufacturing-release/BOM blockers. They do not, by themselves,
prove that every possible assembled variant would be nonfunctional.

### 3.5 Manufacturing package is incomplete

The repository has KiCad source files but no:

- Gerbers or drill files;
- fabrication drawing or stackup sign-off;
- BOM and placement file;
- ERC/DRC report;
- commissioning/test-point plan;
- assembly inspection checklist.

`kicad-cli` is not installed in the audited environment, so this audit could not
run an independent ERC/DRC. The board source declares a four-layer stack, but
all traces and the ground zones are on the outer copper layers. There are no
mounting-hole footprints, fiducials, analog calibration-injection points,
current/drive monitors, sensor header, or obvious AIN3 breakout.

The custom symbol library also declares all ADS1015 pins and all CD4066
signal, control, and power pins as `passive`; MCP6022 signal pins are likewise
`passive`
(`build/kicad/MILESTONE_1_build/full_instrument/schpy.kicad_sym:26–52,118–146,191–223`).
Correct the electrical pin types before treating even a clean ERC as meaningful
for floating inputs, power connectivity, or output conflicts.

Those omissions are not cosmetic for a resonant or precision-force article.
Mounting, return-current geometry, calibration access, and center of mass must
be reproducible.

## 4. Source-gate mapping

| Current requirement | Present state | Assessment |
|---|---|---|
| Bounded active object | PCB, battery, MCU, and three rings are a plausible bounded assembly; enclosure/boundary not frozen. | Partial |
| A1/logical port realization | Three reversible piezo ports; A1's local carrier has twelve primitive boundary ports, while the current manual's engineering minimum is four to twelve active ports. No source-bound logical-port/subfederation map is supplied. | **Absent / not demonstrated** |
| Same-zone drive/read | Reset-after-drive diagonal capture exists in firmware. Diagonals have not been validated on the bench. | Partial |
| Stable records \(R_U\) | External Home Assistant telemetry exists, but no completed acceptance run or stable, internal, atomic, replayable record exists. | **Absent / not demonstrated** |
| Predictive boundary coupling \(P_U\) | No learned/frozen predictor, held-out prediction, or shuffled-history test. | **Absent** |
| Visible mismatch reduction \(C_U\) | Ordinary reciprocal acoustic coupling is measured; no declared mismatch objective is reduced by a repair move. | **Absent** |
| Registered repair/update | Firmware is feed-forward: select, drive, wait, read, publish. | **Absent** |
| Checkpoint continuation | No checkpoint state or post-checkpoint prediction. | **Absent** |
| Durable internal records | Home Assistant is external; firmware has no append-only flash/SD event ledger. | **Absent** |
| Top and bottom scalar estimates | Current three-ring row has no separately validated vertical zones. | **Absent** |
| Integrated scalar and dipole | No frozen scalar estimator or volume integral. | **Absent** |
| Signed operation | No ACTIVE+/ACTIVE− zoning/phase/handedness implementation. | **Absent** |
| Power-matched sham | `SHUFFLE` is no drive; OFF-RES has frequency-dependent impedance. | **Absent** |
| \(q_\star\) calibration | Not implemented or theoretically supplied. | **Absent** |
| Repair charge/current flux | Not measured. | **Absent** |
| External repair field | No source, detector, calibration, or gradient reversal. | **Absent** |
| Field momentum and toggle energy | No complete boundary or energy ledger. | **Absent** |
| Class-H evidence bundle | No closed raw-capture/calibration/custody/control/analysis bundle or independent witness. | **Absent** |

On the current theory's multiplicative source definition, the unimplemented
\(P_U\) and \(C_U\), and undemonstrated \(R_U\), mean this design cannot
establish a nonzero source. Absence of those receipts is not a metaphysical
proof that every hidden physical factor is literally zero; it is a failure of
the claimed inference. It is therefore incorrect to call a passing
\(3\times3\) coupling matrix the current OPH “self-read receipt.”

## 5. Firmware/protocol contradictions

### 5.1 The controls are not the controls their labels imply

`build/chi_nu_poc.yaml:25–30` defines:

- `SHUFFLE`: no drive;
- `OFF-RES`: a different drive frequency.

No-drive is a noise baseline, not shuffled records and not a matched sham.
OFF-RES is useful, but the piezo and switch impedances depend on frequency, so
equal PWM amplitude does not imply equal electrical power, current spectrum,
mechanical energy, or feedthrough. The unfrozen switch \(R_{\rm on}\) makes
that inference weaker still. Voltage and current must be measured.

The Milestone-1 protocol requires interleaved A-S-A-O controls inside every
repeat (`build/MILESTONE_1_build.md:39–57`). The firmware instead selects one
mode and batches all repetitions before another mode is manually selected:
`build/chi_nu_poc.yaml:222–251,343–375`.
It cannot automatically emit the receipt its own build document specifies.

Control selection also has a mid-batch race despite the source comment saying
otherwise. Each button mutates global `ctrl_mode` before invoking the
default-single-instance `sweep_matrix`. A second press while a sweep is
running can therefore be rejected as a new script invocation while still
changing the global mode consumed inside `one_tx`; frequency and `run_state`
were selected only at batch start. The drive/no-drive behavior, frequency, and
label can consequently diverge inside one batch
(`build/chi_nu_poc.yaml:222–241,276–307,343–375`). Reject or disable controls
while busy and snapshot the selected mode into immutable run-local state.

### 5.2 The record is not atomic or self-contained

The nine matrix cells are separate Home Assistant template states, and
`run_state` is published only once per whole batch. There is no single event
record binding:

- monotonic run/sequence ID;
- state and schedule;
- raw ADC values;
- drive voltage/current/power;
- configuration and firmware hashes;
- local clock and checkpoint;
- temperature and battery state;
- control pairing.

Repeated identical states may also be treated differently from raw events by an
external home-automation history. Use append-only local storage and export
content-addressed atomic records after the block. A future force run should
disable radio during measurement.

### 5.3 Required covariates are absent

The architecture text names temperature, acceleration, magnetometer, and
battery monitoring (`build/MILESTONE_1_build.md:61–75`). The firmware has only
a commented spare ADC example and a “later” sensor comment
(`build/chi_nu_poc.yaml:136–166,215`), and the PCB contains none of those
sensors.

This matters already at Milestone 1: the design text expects the weak channel
to move by 2–5%/°C and requires temperature logging every sweep
(`build/MILESTONE_1_build.md:143–150`). It matters even more for any force
measurement, where temperature, vibration, magnetic field, RF current, charge,
and center of mass are leading confounds.

### 5.4 Amplitude-only capture is too lossy

The envelope detector yields one amplitude per burst. It discards:

- phase and signed response;
- waveform shape;
- frequency/decay model residuals;
- harmonic and feedthrough structure;
- transient evidence needed for a prediction/repair loop.

Keep the simple path if it is useful for bring-up, but add a coherent I/Q or
raw-waveform path for the actual source experiment.

## 6. Stage-0 evidence status

Stage 0 is useful but incomplete:

- 43.5 kHz was later recognized as parallel resonance \(f_p\), not series
  resonance \(f_s\); the maximum-coupling drive point remains unmeasured:
  `build/STAGE0_results_run1.md:70–93`;
- \(Q\approx75\) is a rough amplitude-width estimate:
  `:97–112`;
- the matrix is relative and uncalibrated, and the diagonal self-reads were not
  measured:
  `:116–148`;
- the repository presents one rounded/averaged matrix without its underlying
  repeat records, per-cell uncertainty, or a replayable raw receipt;
- \(f_s\), diagonal capture, and ringdown \(\tau\) remain open:
  `:192–209`.

The conclusion that ring 2's deficit is **only** partial depoling is too strong.
The evidence is consistent with depoling, but a tighter conclusion needs a
complex impedance spectrum, piezo coefficient/coupling measurement, and
remount/resolder/substitution controls.

## 7. The planned balance protocol is not ready either

Even if the theory were restored, Documents A and C are drafts and the
measurement model needs additional characterization:

- the quoted \(5\times10^{-8}\,\mathrm N\) floor is about \(5.1\,\mu\mathrm g\)
  apparent mass, roughly 20 times below the specified balance's 0.1 mg
  single-reading readability; the assumed effective sample count and
  correlation time must be measured with injection tests, power spectra, Allan
  deviation, settling, and blind null blocks;
- a few mbar does not generically eliminate gas-mediated forces; use a pressure
  sweep toward high vacuum and matched thermal impulses;
- electrostatic force is not generically confined to \(2f\):
  \((V_{\rm DC}+V_{\rm AC})^2\) contains an \(f\) cross term;
- physical flip and internal sign commands also change center of mass, torque,
  electrode/contact potentials, sensor orientation, wiring, thermal plumes, and
  magnetic-current geometry.

These points are secondary to the theory retraction but should be fixed before
any theory-neutral anomaly search.

## 8. Minimum respin for a useful observer-loop metrology prototype

Before committing to a PCB respin:

1. validate one complete drive/read channel on breadboard and scope;
2. lock exact MPNs, footprints, and BJT pin numbers;
3. add per-IC 100 nF and appropriate local bulk capacitance;
4. add test points, calibration injection, drive voltage/current monitoring,
   and a spare raw acquisition path;
5. add local temperature, accelerometer, magnetometer, battery voltage/current,
   and charge/field provisions;
6. use onboard append-only event storage with configuration/firmware hashes and
   an RF-disable measurement mode;
7. implement real randomized/interleaved active, no-drive, off-resonance,
   record-shuffled, and power-matched controls;
8. implement a frozen held-out predictor, checkpoint, and a declared
   record-conditioned repair/update;
9. either realize the twelve-port A1 carrier or supply a source-bound logical
   port/subfederation construction; the current engineering manual recommends
   four to twelve active ports, so three ports are metrology-only absent that
   construction;
10. provide physically separated zones and a matched detuned/dummy twin;
11. freeze the mechanical mount, center of mass, enclosure, and evidence-bundle
    verifier before any precision measurement.

That respin could produce valuable observer-loop metrology and evidence for an
operational source **candidate**. It would not establish the current OPH
\(S_{\rm coh}^{\rm can}\) until the instrument-independent map in T3 exists,
and it would not be a force article until the theory also supplies
\(q_\star\), charge or flux, \(\theta_{\rm ext}\), sign, and conservation
receipts.
