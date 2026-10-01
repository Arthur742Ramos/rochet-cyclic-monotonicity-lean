# Independent mathematical contract review

Reviewed independently before Lean implementation. No Lean process or build was run for this review.

## Contract and orientation

Let `T` be a nonempty arbitrary type, `X` an arbitrary type, `v : T → X → ℝ`, and `f : T → X`. A payment is `p : T → ℝ`, and DSIC means, for every true type `t` and report `s`,

`v(t,f(t)) − p(t) ≥ v(t,f(s)) − p(s)`.

Define `ℓ(s,t) = v(t,f(t)) − v(t,f(s))`. Rearranging DSIC gives exactly

`p(t) − p(s) ≤ ℓ(s,t)`.

Thus the edge points from the deviating report to the true type. The specified orientation is correct for an infimum of path weights from an anchor to the destination. Reversing the weight arguments without reversing the construction would be incorrect.

A finite walk is a sequence `t₀,…,tₙ`, with weight `Σₖ₌₀ⁿ⁻¹ ℓ(tₖ,tₖ₊₁)`. It is closed when `tₙ=t₀`. Vertices may repeat. The zero-edge walk exists at each vertex, and its endpoints must be equal. The cyclic-monotonicity condition is nonnegativity of every such closed-walk weight. In particular, `ℓ(t,t)=0` by definition. Summing the payment inequalities along any closed walk telescopes its payment differences to zero and proves necessity.

## Anchored construction and all infimum prerequisites

Fix `r : T`. For each `t`, let `S(r,t) ⊆ ℝ` be the set of weights of all finite walks from `r` to `t`, including the zero-edge walk only when `r=t`.

1. The direct edge `r→t` has weight `ℓ(r,t)` and belongs to `S(r,t)`, so the set is nonempty for every `t`.
2. Given any path of weight `a` from `r` to `t`, append the return edge `t→r`. Cyclic monotonicity gives `0 ≤ a + ℓ(t,r)`, hence `−ℓ(t,r) ≤ a`. Therefore `S(r,t)` is bounded below by the explicit real number `−ℓ(t,r)`.
3. Only after establishing these facts use the real conditional-completeness properties of `sInf` and define `p(t) = sInf S(r,t)`. The result satisfies `−ℓ(t,r) ≤ p(t) ≤ ℓ(r,t)`.
4. Every path from `r` to `r` is closed and has nonnegative weight. Its zero-edge path has weight zero. Therefore `p(r)=0`.
5. For `a ∈ S(r,s)`, append edge `s→t`. Then `a + ℓ(s,t) ∈ S(r,t)`. Since `S(r,t)` is bounded below, `p(t) ≤ a + ℓ(s,t)`, so `p(t)−ℓ(s,t) ≤ a`. This holds for every `a ∈ S(r,s)`. The nonemptiness of `S(r,s)` now gives `p(t)−ℓ(s,t) ≤ sInf S(r,s)=p(s)`. Consequently `p(t)−p(s) ≤ ℓ(s,t)`, which is DSIC by the first calculation.

This proof requires no countability, finiteness, topology, convexity, continuity, measurability, surjectivity, or global boundedness assumptions. The required lower bound depends on `r,t` and follows from cyclic monotonicity. `X` needs no separate nonemptiness assumption: the supplied allocation from nonempty `T` already entails it. The anchor theorem can take `r : T` directly; a theorem that chooses an anchor should explicitly assume `Nonempty T`.

The real-valued hypothesis is essential to this elementary complete-graph proof: every direct and return edge is a finite real number. Do not extrapolate its statement to extended-real valuations from the cited paper's more general results.

## Multiple agents

One fully general formulation uses an arbitrary agent type `I`, nonempty possibly dependent type spaces `Tᵢ`, a common outcome type `X`, valuations `vᵢ : Tᵢ → X → ℝ`, and an allocation `F : (Π i, Tᵢ) → X`. Fix agent `i` and the reports `β` of every other agent. Let `σᵢ(β,t)` insert `t` into this fixed context, and use the single-agent allocation `fᵢ,β(t)=F(σᵢ(β,t))`.

Global DSIC implies cyclic monotonicity of each such slice by necessity above. Conversely, if every slice is cyclically monotone, choose one anchor `rᵢ ∈ Tᵢ` for each agent, construct the slice payment `pᵢ,β`, and define the global payment at profile `θ` by `P(θ,i)=pᵢ,θ₋ᵢ(θᵢ)`. In each unilateral comparison the context `θ₋ᵢ` is unchanged, so the slice's payment inequality proves the global DSIC condition. No coupling across agents' payments is required. In particular, this makes no assertion of budget balance or individual rationality.

If formal slices are represented using a full baseline profile and `Function.update`, establish that their allocation and path-weight sets depend only on the reports outside `i`. A fixed anchor for agent `i` must be shared across those equivalent representations. Anchoring separately at the current own report would make the assembled payment always zero and invalidate the argument. A homogeneous report type `T` is a valid specialization; it should be described as such rather than as a theorem about heterogeneous type spaces. Arbitrary agent sets require no `Fintype I` because no agent sum occurs.

## A strict two-cycle counterexample

Take `T=X={0,1,2}` and `f(t)=t`. Rows of the following matrix are true types; columns are outcomes:

| `v(t,x)` | `x=0` | `x=1` | `x=2` |
|---|---:|---:|---:|
| `t=0` | 0 | −2 | 1 |
| `t=1` | 1 | 0 | −2 |
| `t=2` | −2 | 1 | 0 |

Then `ℓ(0,1)=ℓ(1,2)=ℓ(2,0)=−1`, and the reverse edges all have weight `2`. Every distinct two-cycle has weight `1`; every same-type two-cycle has weight `0`. However, the closed walk `0→1→2→0` has weight `−3`. Therefore all two-cycle inequalities hold, but no DSIC payment exists.

## Source and applicability checks

The checkout `review-sources/roberts-theorem-lean` was verified at commit `0c176c66d2afa62301297f443b1e40eda2387ca2`, with no reported local changes. `Roberts/Defs.lean:18–24` uses the same utility and payment sign convention. Its public `IsDSIC` declaration requires finite agents and outcomes and uses unrestricted valuation reports `A→ℝ`; the current arbitrary-type contract therefore needs a generalized definition. `Roberts/Taxation.lean:34–38` proves equal payment when unilateral reports produce the same outcome, and its two DSIC comparisons are mathematically applicable. That fact does not establish uniqueness of implementing payments. The checkout's BSD 3-Clause license permits adaptation with retained copyright, conditions, and disclaimer.

[Artstein-Avidan, Sadovsky, and Wyczesany, arXiv:2011.13263v4](https://arxiv.org/pdf/2011.13263v4), §2.6, states the classical arbitrary-set result for real-valued costs and presents an anchored infimum construction. It also explains the distinction from infinite-valued costs. Its corrected v4 discusses extra hypotheses in the latter setting; those hypotheses should not be imported into this finite-real contract. With `c(t,x)=−v(t,x)`, the graph of `f` has cost cyclic monotonicity precisely when the closed-walk inequalities above hold, after cyclic reindexing.

The provided Rochet DOI is [10.1016/0304-4068(87)90007-3](https://doi.org/10.1016/0304-4068(87)90007-3). The web fetch of that DOI returned an internal error during this review, so no claim is made here to have inspected its full text. The mathematical conclusions above were independently derived, checked against the local sign convention, and checked against the readable v4 classical-cost statement.

## Review conclusion

The proposed single-agent contract, payment orientation, path-infimum construction, and fixed-other-reports extension are mathematically valid with the hypotheses stated above. The exact final Lean binders and path definitions still need a source audit after implementation. No Lean compilation, comparator validation, axiom audit, or novelty guarantee is supplied by this preimplementation mathematical review.
