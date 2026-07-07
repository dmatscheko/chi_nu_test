#!/usr/bin/env python3
"""
decodability_checker.py — the machine record for the two computational-evidence
claims of proof-chain v6/v6.1 (committed in v7; holes-audit F22).

The audit ("OPH_PROOF_CHAIN_HOLES.md", F22) correctly observed that two claims
of computational evidence appeared with no artifact in the repository:

  (1) the stride classification (T25) was "confirmed computationally for all
      n <= 28 ... minimal decoding horizon t* = ceil(n/2) - 1 exactly at every
      coprime stride; no decoding up to t = 80 at every non-coprime stride";
  (2) width-2 screens at slopes 1/2, 1/3, 2/3, 1/4, 3/4 "decode at exactly the
      sharp threshold for all n <= 20".

This file IS the artifact. It also states the convention the docs omitted:

  SLOPE-SCREEN CONVENTION (floor convention). The width-2 screen of rational
  slope s anchored at column j0 reads, at each time i in [0, t], the two cells
      (i, j0 + floor(s*i))  and  (i, j0 + floor(s*i) + 1)   (columns mod n).

Method: Rule 90 on the n-cylinder is linear over F2, so "the screen readout
determines the seed" is a rank condition: build the seed -> readout matrix by
evolving the n basis seeds, and the screen is an information set iff the
readout vectors of the basis seeds are linearly independent (rank = n).
Everything is exact integer/F2 arithmetic (bitmask Gaussian elimination).

Outputs (committed next to this file):
  stride_sweep.txt — claim (1), n <= 28, all strides g in [1, n-1], horizon
                     search up to t = 80;
  slope_sweep.txt  — claim (2), n <= 20, slopes 1/2, 1/3, 2/3, 1/4, 3/4,
                     horizon search up to t = 200.

Both claims verify exactly as stated. Note the stride claim is *subsumed* by
the theorem T25 (`Rule90Stride.lean`) — this record is kept because the docs
cite the computation as the discovery path; the slope claim remains evidence
for a conjecture (open-list item), now with its receipt attached.
"""

from math import gcd, floor
from fractions import Fraction


def evolve(x: int, n: int) -> int:
    """One Rule-90 step on the n-cylinder; rows are n-bit ints (bit j = cell j)."""
    left = ((x << 1) | (x >> (n - 1))) & ((1 << n) - 1)   # cell j reads x[j-1]
    right = ((x >> 1) | ((x & 1) << (n - 1))) & ((1 << n) - 1)  # and x[j+1]
    return left ^ right


def readout(seed: int, n: int, t: int, cells) -> int:
    """The screen readout of the trajectory of `seed`, packed as a bit vector.

    `cells` is a list of (i, j) spacetime cells with 0 <= i <= t; j arbitrary
    (reduced mod n here)."""
    rows = [seed]
    for _ in range(t):
        rows.append(evolve(rows[-1], n))
    out = 0
    for k, (i, j) in enumerate(cells):
        if (rows[i] >> (j % n)) & 1:
            out |= 1 << k
    return out


def is_information_set(n: int, t: int, cells) -> bool:
    """F2-rank check: the linear map seed -> readout is injective iff the
    readouts of the n basis seeds are linearly independent."""
    vecs = [readout(1 << k, n, t, cells) for k in range(n)]
    rank = 0
    basis = []
    for v in vecs:
        for b in basis:
            v = min(v, v ^ b)
        if v:
            basis.append(v)
            rank += 1
    return rank == n


def stride_cells(j0: int, g: int, t: int):
    return [(i, j0) for i in range(t + 1)] + [(i, j0 + g) for i in range(t + 1)]


def slope_cells(j0: int, s: Fraction, t: int):
    return ([(i, j0 + floor(s * i)) for i in range(t + 1)]
            + [(i, j0 + floor(s * i) + 1) for i in range(t + 1)])


def minimal_horizon(n: int, cells_of_t, t_max: int):
    """Smallest t <= t_max with an information set, else None."""
    for t in range(0, t_max + 1):
        if is_information_set(n, t, cells_of_t(t)):
            return t
    return None


def stride_sweep(n_max=28, t_max=80, out="stride_sweep.txt"):
    lines = ["# stride sweep: two-column screens {j0, j0+g} x [0,t] on the n-cylinder",
             "# claim (T25's computational-discovery record): information set iff",
             "#   gcd(g,n) = 1 and n <= 2(t+1); minimal horizon t* = ceil(n/2) - 1",
             "#   at every coprime stride; no decode up to t = %d otherwise." % t_max,
             "# columns: n g gcd t*(found) t*(predicted) verdict"]
    ok = True
    for n in range(1, n_max + 1):
        for g in range(1, n):
            tstar = minimal_horizon(n, lambda t: stride_cells(0, g, t), t_max)
            if gcd(g, n) == 1:
                pred = (n + 1) // 2 - 1 if n > 1 else 0
                pred = max(pred, 0)
                good = (tstar == pred)
            else:
                pred = None
                good = (tstar is None)
            ok &= good
            lines.append(f"{n:3d} {g:3d} {gcd(g, n):3d} "
                         f"{'-' if tstar is None else tstar:>4} "
                         f"{'-' if pred is None else pred:>4} "
                         f"{'OK' if good else 'MISMATCH'}")
    lines.append(f"# RESULT: {'ALL OK' if ok else 'MISMATCHES PRESENT'}")
    with open(out, "w") as f:
        f.write("\n".join(lines) + "\n")
    return ok


def slope_sweep(n_max=20, t_max=200, out="slope_sweep.txt"):
    slopes = [Fraction(1, 2), Fraction(1, 3), Fraction(2, 3),
              Fraction(1, 4), Fraction(3, 4)]
    lines = ["# slope sweep: width-2 screens at rational slope s, floor convention:",
             "#   cells {(i, j0+floor(s*i)), (i, j0+floor(s*i)+1)}, i in [0,t], j0 = 0",
             "# claim: minimal horizon t* equals the adjacent-screen threshold,",
             "#   i.e. the least t with n <= 2(t+1)  (t* = ceil(n/2) - 1).",
             "# columns: n slope t*(found) t*(predicted) verdict"]
    ok = True
    for n in range(1, n_max + 1):
        for s in slopes:
            tstar = minimal_horizon(n, lambda t: slope_cells(0, s, t), t_max)
            pred = max((n + 1) // 2 - 1, 0)
            good = (tstar == pred)
            ok &= good
            lines.append(f"{n:3d} {str(s):>4} "
                         f"{'-' if tstar is None else tstar:>4} {pred:>4} "
                         f"{'OK' if good else 'MISMATCH'}")
    lines.append(f"# RESULT: {'ALL OK' if ok else 'MISMATCHES PRESENT'}")
    with open(out, "w") as f:
        f.write("\n".join(lines) + "\n")
    return ok


if __name__ == "__main__":
    import os
    os.chdir(os.path.dirname(os.path.abspath(__file__)))
    ok1 = stride_sweep()
    ok2 = slope_sweep()
    print("stride sweep:", "ALL OK" if ok1 else "MISMATCH")
    print("slope sweep:", "ALL OK" if ok2 else "MISMATCH")
