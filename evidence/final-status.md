# Historical final local-preparation checkpoint

This records the stage before public publication, hosted verification and
the first Palomar intake. Its process statements describe that checkpoint;
later publication and intake history is recorded in README and PUBLICATION.md.

2026-10-01. The implementation, independent mathematical review, independent
prose/binder/attribution review, and local validation are complete.

The formalized contract uses arbitrary nonempty report types, arbitrary outcome
types and real valuations. It constructs anchored infimum payments with explicit
path-set nonemptiness and return-edge boundedness, proves zero normalization and
all implementing inequalities, and establishes the heterogeneous multiagent
characterization with exactly DecidableEq I and nonempty T i. The three-type
example has every two-cycle nonnegative and a three-cycle of weight −3, and is
proved nonimplementable. No uniqueness, IR, budget-balance or novelty claim is made.

An independent packaging review found the current module-header requirement
missing from the earlier checkpoint. All Lean sources were ported to the module
system with public imports/interfaces and exposed definitions. Independent
review confirmed that the mathematical bodies were preserved byte-for-byte.
That finding and the metadata relationship/PATH/reproduction observations are
resolved in the final source and scripts.

Validation on the final mathematical source:
- Separate Challenge build: 1018 jobs, success.
- Separate Solution build: 1020 jobs, success.
- Complete default build: 1024 jobs, success.
- Every selected theorem printed only propext, Classical.choice, Quot.sound.
- Official lake comparator: Your solution is okay!
- Lean default, NanoDa and con-ron accepted; con-ron checked 7388 declarations.
- Official pinned Palomar metadata validator and full static source scan passed;
  seven regular Lean sources use module headers and satisfy line limits.
- Lean's header parser reports Challenge isModule=true, no errors.
- Challenge imports only Mathlib; 267 physical lines / 11167 bytes.
- Both independent final reviews accepted the exact recorded source hashes.
- Python verification/packaging scripts passed syntax compilation; shell script
  passed sh -n. The archive builder verifies all archived bytes against its
  snapshot and the core-file validation manifest.

Lean v4.35.0-rc2 (compiler commit 11acb17ec6b07a8f9e9173e6845197929540936b)
is pinned with matching Mathlib 065356127b1dc0016f66b7283ce0ce2c4055aa55.
Palomar policy was inspected at 65f0154ed776cd26c224254aa57b379137f28b0d.
Author names and explicit arXiv/MSC2020 classifications passed the official
metadata validator. Original Roberts BSD-3-Clause LICENSE is retained exactly.

Execution limitation: Comparator's local Mac replay explicitly disabled the
Linux bubblewrap sandbox. These are local statement, axiom and kernel checks,
not sandboxed hosted Palomar verification. No hosted render/editorial review,
registration, or public-index result is claimed. No public repository, push,
submission, withdrawal or acceptance of terms occurred.

No configured real Git author name/email was available, so no commit was made.
That does not block this source-only local deliverable. A public immutable
repository commit and subsequent Palomar actions require separate authorization
and an established Git identity. The original Rochet DOI full text was unavailable
in source review; attribution and the independently derived contract were checked
against the readable arXiv v4 classical finite-real construction.

Earlier checkpoint files/logs are preserved locally as history. The delivered
archive selects the final validation logs and final reviews, excludes .lake,
Git internals, generated binaries, Python caches, and external source checkouts,
and supplies SHA256SUMS. All Lean builds were serial with two threads.
