# Comparator intake compatibility repair

Historical checkpoint for the repair published at commit
`533f70fc7ad4a8a4a785bcdf1209f8ba1cc644cf`, before its hosted replay and first
Palomar intake. Later process history is in the repository README and
PUBLICATION.md.

The `external_kernels` key is supported by the pinned Lean/Lake Comparator,
but forbidden in submitted Palomar configurations. It is not an obsolete Lake
option. Removing it from the submitted file is required for the reviewed
Palomar schema and does not disable the production independent kernels.

Evidence at PalomarSubmission commit
`65f0154ed776cd26c224254aa57b379137f28b0d`:

- `scripts/verify_submission.py`, `COMPARATOR_ALLOWED_KEYS` and
  `load_comparator_config`: submitted `external_kernels` is an unknown key.
- `protected_comparator_config`: the trusted verifier replaces the Challenge
  name with its canonical alias and injects the two bundled external kernels
  in a protected configuration. Submitted `enable_nanoda` is not authoritative.
- `validate_protected_comparator_config`: requires the protected external
  kernel commands and validates their absolute paths.
- [Official explanation](https://github.com/PalomarRegistry/PalomarSubmission/blob/65f0154ed776cd26c224254aa57b379137f28b0d/README.md#L137)
  describes independent kernel replay as a registry invariant.

The repaired submitted `comparator.json` is structurally identical to the
previous JSON after deleting only `external_kernels`. Its Challenge/Solution
modules, fifteen selected theorems, empty definition-hole list and standard
axiom allowlist are unchanged. All seven Lean files, formalization metadata,
dependency pins, license and notice remain byte-for-byte unchanged.

For standard preflight, `scripts/verification_config.py` validates that
submitted file with the pinned official loader, then writes a temporary
execution-only configuration outside the repository with absolute commands
for the toolchain's bundled NanoDa and con-ron. `verify.sh` requires explicit
acceptance by both external kernels and Lean. It also validates the submitted
schema directly, so this intake mismatch cannot pass the same package gate
again. This preflight does not replace production canonical-Challenge auditing.

Exact local verification after the repair passed separate Challenge/Solution
builds, the full build, binder and module checks, all fifteen axiom audits,
the official metadata and source scan, the submitted Comparator schema and
all three kernel replays. The local Comparator printed `Your solution is okay!`.
macOS replay remains explicitly unsandboxed; Linux hosted replay is a separate
required check at the published repaired commit.

No intake was created by this task. The original Library archive is the
historical pre-repair checkpoint; the repaired immutable GitHub commit is the
artifact to use for the next intake.
