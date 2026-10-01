# Publication record

The source and evidence in the original Library archive record the completed
local preparation checkpoint before public publication. Its archive SHA256 is
`ccb6c99101a1a5fd3e422c81a9b6ba88b690ad7eb8855d28237f49cb1d800ee2`.
The checkpoint statements about no Git commit or public action describe that
historical stage. They do not assert the later status of this repository.

On 2026-10-01, the project initiator explicitly approved publication as
`Arthur742Ramos/rochet-cyclic-monotonicity-lean` and Palomar submission under
`arthur742psn-byte`. Initial publication preserved the audited preparation
snapshot. Later compatibility and process-history revisions changed packaging
and prose; the mathematical Lean sources remained byte-for-byte unchanged.

The publication author identity was verified against GitHub's account-linked
metadata for the attributed Roberts commit
`0c176c66d2afa62301297f443b1e40eda2387ca2`: its linked account is
`Arthur742Ramos`, with author name `Arthur Freitas Ramos` and the recorded
GitHub noreply email. Git identity settings are confined to this repository.
The formalization's three author names are unchanged.

The manual workflow runs on a standard hosted Ubuntu runner with a 25-minute
timeout and two Lean threads. It runs the pinned official Palomar metadata
and source checks plus separate builds, axiom audits and the toolchain's
official Comparator under Linux bubblewrap. It uses read-only repository
permissions and no supplied secrets. The Linux Lean release digest was
verified from the official GitHub release asset metadata.

The first hosted run completed proof builds and axiom audits but Ubuntu denied
the distribution bubblewrap binary permission to create a user namespace.
The workflow now uses the reviewed Palomar `scripts/install_bwrap.sh` at the
pinned policy commit. It builds checksum-verified bubblewrap v0.12.0 and loads
the official path-specific user-namespace profile on the disposable hosted
runner. Comparator remains sandboxed. This workflow configuration did not
disable a global restriction or add a persistent runner, account permission
or credential.

Palomar browser preflight subsequently identified an intake schema mismatch:
`external_kernels` is a Lake execution option, but is forbidden in a submitted
Palomar configuration. The repair removes only that key from `comparator.json`.
All selected declarations, modules, axiom permissions and Lean sources remain
unchanged. Verification now validates the submitted configuration through the
official loader and generates an execution-only temporary configuration with
the toolchain's bundled NanoDa and con-ron. Both kernel acceptances and Lean's
acceptance remain mandatory. Palomar's production verifier independently
injects its own protected kernel configuration.

Sandboxed hosted preflight of commit
`533f70fc7ad4a8a4a785bcdf1209f8ba1cc644cf` passed in
[run 36884407281](https://github.com/Arthur742Ramos/rochet-cyclic-monotonicity-lean/actions/runs/36884407281).
It accepted all three kernels and the official submitted configuration schema.
The manual repository workflow is separate from Palomar's production profile
and does not create an intake or registration.

The project initiator separately approved repository-scoped write access for
`arthur742psn-byte`; that account accepted the invitation. Its repository role
was verified as write, with no admin or organization access granted.

The parent task submitted the first Palomar intake at the same pinned commit.
Mechanical checks passed, and automated review found no mathematical blocker.
Registration was withheld because the README still described the earlier local
preparation stage as the current state. This revision corrects that process
account. At this correction's preparation checkpoint on 2026-10-01, the project
had not been registered and Palomar had directed a new intake for the corrected
commit. This editing task did not create or withdraw an intake. Later intake
and registration events are recorded by Palomar separately from this history.
