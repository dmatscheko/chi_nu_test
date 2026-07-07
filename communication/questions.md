# χ_ν Hoverboard Lift Test

We want to test the χ_ν coherent-matter lift for real. A clean force measurement
is relatively cheap with lab gear. Before building anything, one finding from
reading the OPH papers reshapes the plan, and it needs an answer from the OPH side.

## Headline finding: OPH-as-written may predict *zero* for the device as specified

The lift force needs a nonzero coherence scalar:
`F = C_geom · A · χ_can · ΔS_coh^can`, with `ΔS_coh^can = 1_self-read · R · P · C`
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:444–468`). OPH's own **null-conditions
theorem** says this scalar is **zero** unless the substrate is *self-reading*,
has a stable record algebra, and has predictive boundary coupling
(`:543–555`; mirrored as "awareness mass" in
`OPH:/extra/thinking_as_patch_net_fixed_point_search.tex`).

Searching the OPH corpus, "self-read" is defined operationally — but as a
**self-bounded read-write substrate** (the Echosahedron 12-port cavity, where the
same ports emit and read), *not* in terms of any material. **Nothing in the
corpus links BiFeO₃, multiferroics, strain, or polarization to self-read.** As
written, the BTTF-chi stack is a passive poled film with no read-write element,
which would place it on OPH's *null branch* — unless the active coupon also
carries a self-reading element that puts it on the *signal branch*.

This is actually good news for designing a decisive test. OPH draws a clean line:
substrates that are not self-reading sit on a **null branch** (`S_coh = 0 ⇒ F = 0`), and
self-reading substrates sit on a **signal branch** where `S_coh` can be nonzero
and lift can appear. So we need to **make sure the coupon is built on the signal
branch**, the one where OPH actually predicts a force — rather than
weighing an arbitrary stack and hoping. Pinning that down on paper first is how we
give the effect its best chance to show up.

## What this is *not*

This is not a dismissal. The χ_ν math, the Poisson→MOND derivation, the lattice
arithmetic note, and the falsifiability discipline all stand on their own. The
point is narrow: the *lift application* has one precondition that the published
device does not obviously meet. Likely the intent runs ahead of what's written —
which is exactly what these two questions are for.

## The two questions for the OPH side

1. **The number.** What `ΔS_coh^can` (bottom-minus-top canonical coherence
   contrast) does the coupon produce? This is the one quantity the papers leave
   open, and it is what turns the force law into a testable prediction (see [A2]).

2. **Self-read.** Does the passive BiFeO₃ stack satisfy OPH's self-read criterion
   (read-write / Echosahedron-class + record algebra + predictive boundary), or
   does the active element need to *be* such a self-reading system? (see [A3])

## What happens with each answer

- **Both supplied** → we lock the prediction and build. The apparatus
  over-resolves the predicted force by ~10⁷ (see [A4]), so sensitivity is
  not the obstacle — only the precondition is.
- **The coupon needs a self-reading element not yet in the build** → that is a
  real design insight, found for the price of a conversation, and we redesign the
  active coupon around it.
- **The number / criterion can't yet be pinned** → then the highest-value next step
  is theoretical rather than experimental: deriving `S_coh^can` from material
  observables is the bridge that would make the whole device predictive. Pinpointing
  exactly where that bridge is missing (see [A5]) is a concrete result in its
  own right — it names the one piece to build next.

## Appendix — supporting numbers and sources

**[A1] Force-law coefficient.** `C_geom = g²/(4πG) ≈ 1.15×10¹¹ N·m⁻²`
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:839`). The coefficient is large, so
even a tiny coherence contrast gives a weighable force.

**[A2] The contrast has no published value.** The OPH papers define `ΔS_coh^can`
but give no numeric value for any material (corpus search of `OPH:/paper/`,
`OPH:/paper/tex_fragments/`, `OPH:/extra/`). It is the one free input — hence
Question 1.

**[A3] Self-read criterion, and the two cases.** Null-conditions theorem:
`S_coh = 0` unless the substrate is self-reading, has a stable record algebra, and
has predictive boundary coupling
(`OPH:/extra/chi_nu_susceptibility_bounds.tex:543–555`). OPH's operational
self-read is a self-bounded read-write substrate — the Echosahedron 12-port cavity
(`OPH:/extra/thinking_as_patch_net_fixed_point_search.tex`;
`OPH:/paper/screen_microphysics_and_observer_synchronization.tex:201–215`); nothing
in the corpus links it to BiFeO₃, multiferroics, strain, or polarization. The two
cases for Question 2: **(i)** the passive stack already qualifies; **(ii)** the
active coupon needs an added self-reading element.

**[A4] Sensitivity vs. prediction.** On a single-zone coupon (≈ 80×60 mm,
`A ≈ 4.8×10⁻³ m²`), the OPH design target `Δν ≈ 1×10⁻⁹` predicts
`F = C_geom·A·Δν ≈ 0.5 N` (≈ 50 g of lift; coefficient from [A1]). A 0.1 mg
analytical balance resolves ~10⁻⁶ N, and ~5×10⁻⁸ N with phase-locked detection —
so the predicted force sits ~10⁷ above the noise floor. Sensitivity is not the
obstacle; the self-read precondition is.

**[A5] If neither can be pinned yet.** Then the lift law makes no numerical
prediction for the coupon, and the useful result is theoretical: locating exactly
where the bridge from material observables (strain, polarization, magnetization,
and port read-write topology) to `S_coh^can` is missing. That bridge
is the one piece that would make the device predictive.

A full written pre-registration (predicted force, run sequence, instrument, and
error budget) is prepared and available on request.
