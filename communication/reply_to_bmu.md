# Reply — χ_ν lift test

This is exactly the careful version I was hoping for. Agreed on both
points: the passive stack is null-branch, and the active element has to *be* the
self-reading system (case ii). Your balance protocol and mine converged almost
line-for-line — same coupon, the same 5.14×10⁸·ΔS coefficient, ABBA vs
power-matched SHAM, ACTIVE± / FLIP / dummy, 5σ, evidence bundle. Happy to lock
that once we fill the run-file fields.

One shared open question before we build — the **ΔS-estimator bridge**:

We measure ΔS_coh^can from the coupon's own port records, and separately
back-solve it from the balance. The test only bites if those are the *same*
scalar — and the magnitudes don't obviously match. A device that passes the
pre-test naturally shows a record contrast of order 10⁻²–1, yet F ≈ 5.14×10⁸·ΔS
would then predict 10⁷–10⁸ N on an 80×60 mm coupon, which we plainly don't see.
So either the record-ΔS isn't the gravitational ΔS, or the bridge carries a large
suppression we haven't written down.

You already flag this ("bounds χ_ν·ΔS, or χ_ν only if the estimator is accepted")
— and I think the build answers it for us, so we don't need to settle it on paper
first:

1. **Milestone 1 first** — get the signed, repeatable *record-level* ΔS. The moment
   that number exists, a one-line check tests the literal bridge: a healthy receipt
   gives ΔS_rec ~ 10⁻²–1, for which F ≈ 5.14×10⁸·ΔS would be enormous — yet the coupon
   sits quietly on the bench. So a 1:1 record↔gravity identity is ruled out at once,
   essentially for free (just handling it bounds the gravitational ΔS to ≲ 10⁻¹⁰).
2. **Balance run** — back-solves the *gravitational* ΔS, or bounds it. The ratio
   (gravitational ΔS) / (record ΔS) then *is* the bridge — measured, not assumed.
3. A theory of that ratio is only owed if there's a signal.

Either way we learn the bridge empirically: a null gives a clean χ_ν·ΔS bound, and
Milestone 1 is worth building on its own.

— 
