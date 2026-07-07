# Milestone 1 — Self-Reading Piezo PoC (build)

Hardware for **Milestone 1** of the χ_ν lift test: a small, self-contained object
that drives its own piezo rings, senses the response, and logs a reproducible
**coupling matrix** — the OPH "self-read receipt." No weighing and no lift claim
yet; this stage only proves that the self-reading object the experiment depends on
actually exists. Scope and decision rules live in
[`../test/DOCUMENT_A_prediction_ledger.md`](../test/DOCUMENT_A_prediction_ledger.md).

## Files

| File | What it is |
|---|---|
| [`MILESTONE_1_build.md`](MILESTONE_1_build.md) | The staged build plan — Stage 0 (characterise the rings on the Rigol) → Stage 1 (ESP32 logs the coupling matrix to Home Assistant). **Start here.** |
| [`electronics.md`](electronics.md) | Every subsystem as a chapter, each opening with a schematic: characterize the rings (Stage 0), system overview, controller/power/I²C, drive stage, ×120 amp + peak detector, TX select. **Rev 2 (2026-07-05):** real XIAO-C6 pinout, single 3.3 V rail, amplified RX chain, reset-after-burst capture — see the rev-2 notes in each chapter. |
| [`STAGE0_results_run1.md`](STAGE0_results_run1.md) | Lab-notebook record of the Stage-0 bench measurements (resonance, Q, coupling matrix, ring-2 finding). Versioned per run — copy to `…_run2.md` to repeat. |
| [`milestone1_jig.scad`](milestone1_jig.scad) | Parametric OpenSCAD carrier/ring jig — nonmagnetic, fixed ring spacing. |
| [`chi_nu_poc.yaml`](chi_nu_poc.yaml) | ESPHome firmware — drives the rings and publishes the timestamped C_ij matrix (+ shuffled control). |
| [`schematic/`](schematic/README.md) | Schematic sources (`*.sch`) and the generator that builds the `*.svg` diagrams embedded in `electronics.md`. |

## Regenerate the diagrams

```sh
cd schematic && make        # rebuild ../*.svg from the .sch sources
```

The `.sch` files are the source of truth; the `*.svg` are build artifacts.
