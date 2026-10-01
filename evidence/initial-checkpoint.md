# Initial contract and source checkpoint

2026-10-01. Isolated workspace; no existing work modified. No inherited AGENTS.md found. Local .agents skills are prose/UI skills, with no Lean-specific workflow. Codex memories were consulted as historical hints, not authority. Repo Bootcamp was observed working on web Q&A state; no Lean build process was active. All Lean work will run serially, with bounded threads and narrow Mathlib cache retrieval.

Current PalomarSubmission revision: 65f0154ed776cd26c224254aa57b379137f28b0d. Its toolchains.json requires v4.35.0-rc2. Installed compiler commit: 11acb17ec6b07a8f9e9173e6845197929540936b. Matching Mathlib tag resolves to 065356127b1dc0016f66b7283ce0ce2c4055aa55.

Independent mathematical review confirmed DSIC is equivalent to p(t)-p(s) ≤ v(t,f(t))-v(t,f(s)). Closing any r→t path with t→r gives lower bound −ℓ(t,r). A direct edge gives nonempty weights. Empty r→r path gives zero normalization. Appending s→t establishes the implementing inequality via the greatest-lower-bound property. No finiteness, countability, topology, or uniform valuation bound is assumed.

Rochet (1987), DOI 10.1016/0304-4068(87)90007-3, is the mathematical attribution. Artstein-Avidan, Sadovsky and Wyczesany, arXiv:2011.13263v4, sections 2.6 and 3.6, support the finite-real arbitrary-set potential construction and return-edge bound. This project does not claim their extended-real theorem.

Roberts/Defs.lean and Roberts/Taxation.lean at 0c176c66d2afa62301297f443b1e40eda2387ca2 were read. They assume finite agents/outcomes and therefore cannot directly supply the arbitrary-set theorem. Their payment sign convention and taxation argument are applicable; the new general interface will retain attribution and BSD-3-Clause license text for any adaptation.

Verified counterexample valuation rows: [0,-2,1], [1,0,-2], [-2,1,0], allocation identity. Edges 0→1→2→0 have weight −1 each; reverse edges have weight 2. Every distinct two-cycle sums to 1; the displayed three-cycle sums to −3.

No public repository, push, intake, registration, withdrawal, or terms acceptance is authorized. Git author name/email were absent in global and inspected local configuration; do not invent commit identity.
