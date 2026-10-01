# Rochet's Cyclic-Monotonicity Characterization

A Lean formalization of the finite-real implementability theorem attributed to
Jean-Charles Rochet (1987), by Arthur Freitas Ramos, David Barros Hulak, and
Ruy Jose Guerra Barretto de Queiroz.

For an arbitrary nonempty report/type set `T`, an arbitrary outcome set `X`,
a valuation `v : T → X → ℝ`, and allocation `f : T → X`, payments `p : T → ℝ`
implement truthful reporting precisely when every finite closed walk has
nonnegative total weight for

```text
ℓ(s,t) = v(t,f(t)) − v(t,f(s)).
```

Utility is valuation minus payment. Thus DSIC is exactly the family of
inequalities `p(t) − p(s) ≤ ℓ(s,t)`. The walk definition allows repeated
vertices and the zero-edge walk. No finite-cardinality, countability,
continuity, measurability, surjectivity, or uniform valuation bound is assumed.
`X` has no separate nonemptiness assumption; the supplied allocation from
nonempty `T` already provides outcomes.

Fix an anchor `r`. The implementing payment at `t` is the infimum of the
weights of all finite walks from `r` to `t`. The direct edge makes this set
nonempty. Appending the return edge to any such path proves the explicit
lower bound `−ℓ(t,r)`. The infimum's order properties are invoked only with
those prerequisites proved. The construction satisfies `p(r)=0`, every
implementing difference inequality, and the bounds
`−ℓ(t,r) ≤ p(t) ≤ ℓ(r,t)`.

The multiagent theorem uses an arbitrary agent type `I`, heterogeneous report
spaces `T : I → Type`, a common outcome type, and valuations
`v : ∀ i, T i → X → ℝ`. Its exact binders require `[DecidableEq I]` and
`[∀ i, Nonempty (T i)]`. Global DSIC payments exist iff every allocation
slice with other reports fixed is cyclically monotone. The construction uses
a fixed anchor for each agent and proves invariance of the slice under
changing the baseline's own report. Supplying a whole anchor profile removes
the need for separate nonemptiness instances in the construction theorem.

A three-type example has valuation rows `[0,−2,1]`, `[1,0,−2]`,
`[−2,1,0]` and identity allocation. Every distinct two-cycle has weight `1`
(and diagonal two-cycles have weight `0`), while `0→1→2→0` has weight `−3`.
Lean proves all two-cycle inequalities, the exact negative three-cycle
weight, and nonexistence of implementing payments. The common-outcome
payment lemma says two reports yielding the same outcome have equal
payments within a given DSIC mechanism. It asserts no uniqueness across
implementing payment functions. Individual rationality and budget balance
are outside the formalized claims.

## Files and comparison boundary

- `Challenge.lean`: independent Mathlib-only definitions and complete proofs;
  no holes or custom axioms. It remains below Palomar's 300-line warning threshold.
- `Rochet/Defs.lean`: identical public mathematical definitions for library use.
- `Rochet/Implementation.lean`: reusable proofs under `Rochet.Implementation`.
- `Solution.lean`: public theorem surface proved through the implementation.
- `comparator.json`: fifteen selected theorems; no definition holes.
- `Audit.lean`: axiom printout for every selected theorem.
- `ContractAudit.lean`: compiled binder and definition printout.
- `evidence/`: recorded checks and independent mathematical/source review.

Challenge and Solution are built separately and are never imported together:
both expose the same public declaration names for comparison. Comparator
checks the statements and all ordinary definition dependencies for equality.
`definition_names` is empty; each definition has its specified concrete value.

## Reproduction

Lean `v4.35.0-rc2` and Mathlib
`065356127b1dc0016f66b7283ce0ce2c4055aa55` are pinned in the project and manifest.
All Lean sources use the required module system, with public interfaces and
exposed concrete definitions. The current Palomar minimum was checked at PalomarSubmission revision
`65f0154ed776cd26c224254aa57b379137f28b0d` on 2026-10-01.

Reproduction requires Python 3.11 or later with PyYAML, plus a checkout of
the official validator at the reviewed commit. `verify.sh` checks that
revision and runs its metadata and complete repository-source scans. It also
records actual Lean binders, verifies module parsing, and prints every
selected theorem's axioms.

```sh
git clone https://github.com/PalomarRegistry/PalomarSubmission.git ../palomar-validator
git -C ../palomar-validator checkout 65f0154ed776cd26c224254aa57b379137f28b0d
export PALOMAR_SUBMISSION_DIR="$PWD/../palomar-validator"
MATHLIB_NO_CACHE_ON_UPDATE=1 lake update
LEAN_NUM_THREADS=2 lake exe cache get \
  Mathlib.Algebra.Order.Archimedean.Real.Basic \
  Mathlib.Order.ConditionallyCompleteLattice.Basic \
  Mathlib.Tactic.Linarith Mathlib.Tactic.FinCases Mathlib.Data.Fintype.Fin
./scripts/verify.sh
```

On Linux, the verification script uses the official comparator's bubblewrap
sandbox. On macOS, its explicit unsandboxed mode is required; that local
replay is evidence of statement, axiom, and kernel checks, with a weaker
execution boundary. It does not establish hosted Palomar mechanical
verification, rendering, editorial acceptance, or registration.

## Sources and provenance

[Rochet (1987)](https://doi.org/10.1016/0304-4068(87)90007-3) is the mathematical
attribution. The DOI full text was unavailable during this review.
[Artstein-Avidan, Sadovsky and Wyczesany, arXiv v4](https://arxiv.org/pdf/2011.13263v4),
sections 2.6 and 3.6, gives a readable reference for the finite-real
arbitrary-set potential construction and the return-edge bound. The
extended-real results in that paper are outside this project.

The utility convention and common-outcome two-comparison argument adapt
[Roberts/Defs.lean and Roberts/Taxation.lean](https://github.com/Arthur742Ramos/roberts-theorem-lean/tree/0c176c66d2afa62301297f443b1e40eda2387ca2)
at the cited immutable commit. Their finite-agent/outcome setup cannot
supply this arbitrary-set theorem directly. The BSD-3-Clause notice,
conditions, and disclaimer are retained in `LICENSE` and described in `NOTICE`.
No Roberts module is imported. Lean proof development and independent AI
review are disclosed in `formalization.yaml`; no human mathematical review
is claimed. Bounded earlier registry/library searches found no matching
theorem, which provides no novelty guarantee.

The deliverable is a local preparation package. No public repository, push,
Palomar intake, registration, withdrawal, or acceptance of terms has occurred.
