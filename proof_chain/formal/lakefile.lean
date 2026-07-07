import Lake
open Lake DSL

require "leanprover-community" / "mathlib" @ git "v4.29.1"

package «OPHProofChainFormal» where
  leanOptions := #[
    ⟨`autoImplicit, false⟩,
    ⟨`relaxedAutoImplicit, false⟩,
    ⟨`pp.unicode.fun, true⟩
  ]

@[default_target]
lean_lib «OPHProofChain» where
