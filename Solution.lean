/-
Copyright (c) 2026 Arthur Freitas Ramos. All rights reserved.
Released under BSD-3-Clause as described in LICENSE.
Authors: Arthur Freitas Ramos, David Barros Hulak,
  Ruy Jose Guerra Barretto de Queiroz
-/
module

public import Rochet.Implementation
public import Mathlib.Algebra.Order.Archimedean.Real.Basic
public import Mathlib.Order.ConditionallyCompleteLattice.Basic
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.FinCases
public import Mathlib.Data.Fintype.Fin

/-!
Public theorem surface proved through the reusable Implementation namespace.
The payment convention is utility = valuation minus payment.
-/
set_option autoImplicit false

@[expose] public section

namespace Rochet
universe u w

theorem endpoint_append {T : Type u} (s : T) (xs ys : List T) :
    endpoint s (xs ++ ys) = endpoint (endpoint s xs) ys := by
  exact Implementation.endpoint_append s xs ys
theorem walkWeight_append {T : Type u} (l : T → T → ℝ) (s : T) (xs ys : List T) :
    walkWeight l s (xs ++ ys) = walkWeight l s xs + walkWeight l (endpoint s xs) ys := by
  exact Implementation.walkWeight_append l s xs ys
theorem pathWeights_nonempty {T : Type u} (l : T → T → ℝ) (r t : T) :
    (pathWeights l r t).Nonempty := by
  exact Implementation.pathWeights_nonempty l r t
theorem pathWeights_lower_bound {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) :
    ∀ a ∈ pathWeights l r t, -l t r ≤ a := by
  exact Implementation.pathWeights_lower_bound l hc r t
theorem pathWeights_bddBelow {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) : BddBelow (pathWeights l r t) := by
  exact Implementation.pathWeights_bddBelow l hc r t
theorem potential_anchor {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r : T) : potential l r r = 0 := by
  exact Implementation.potential_anchor l hc r
theorem potential_edge {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r s t : T) :
    potential l r t - potential l r s ≤ l s t := by
  exact Implementation.potential_edge l hc r s t

theorem potential_bounds {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) :
    -l t r ≤ potential l r t ∧ potential l r t ≤ l r t := by
  exact Implementation.potential_bounds l hc r t
theorem walkWeight_ge_difference {T : Type u} (l : T → T → ℝ) (p : T → ℝ)
    (hp : ∀ s t, p t - p s ≤ l s t) (s : T) (ts : List T) :
    p (endpoint s ts) - p s ≤ walkWeight l s ts := by
  exact Implementation.walkWeight_ge_difference l p hp s ts
theorem noNegativeCycles_of_potential {T : Type u} (l : T → T → ℝ) (p : T → ℝ)
    (hp : ∀ s t, p t - p s ≤ l s t) : NoNegativeCycles l := by
  exact Implementation.noNegativeCycles_of_potential l p hp

theorem dsic_iff_edge {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X) (p : T → ℝ) :
    DSIC v f p ↔ ∀ s t, p t - p s ≤ edgeWeight v f s t := by
  exact Implementation.dsic_iff_edge v f p
theorem anchoredPayment_spec {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X)
    (hc : CyclicMonotone v f) (r : T) :
    anchoredPayment v f r r = 0 ∧ DSIC v f (anchoredPayment v f r) := by
  exact Implementation.anchoredPayment_spec v f hc r
theorem rochet {T : Type u} {X : Type w} [Nonempty T] (v : T → X → ℝ) (f : T → X) :
    (∃ p : T → ℝ, DSIC v f p) ↔ CyclicMonotone v f := by
  exact Implementation.rochet v f

theorem payment_eq_of_same_outcome {T : Type u} {X : Type w}
    (v : T → X → ℝ) (f : T → X) (p : T → ℝ) (hp : DSIC v f p)
    (s t : T) (hf : f s = f t) : p s = p t := by
  exact Implementation.payment_eq_of_same_outcome v f p hp s t hf
section Multiagent
universe z
variable {I : Type z} {T : I → Type u} {X : Type w} [DecidableEq I]

theorem slice_update (f : (∀ i, T i) → X) (i : I) (b : ∀ i, T i) (t : T i) :
    slice f i (Function.update b i t) = slice f i b := by
  exact Implementation.slice_update f i b t
theorem slice_self (f : (∀ i, T i) → X) (i : I) (b : ∀ i, T i) :
    slice f i b (b i) = f b := by
  exact Implementation.slice_self f i b
theorem multiPayment_spec (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    (hc : SliceCyclicMonotone v f) (r : ∀ i, T i) :
    MultiDSIC v f (multiPayment v f r) ∧
      ∀ i b, multiPayment v f r (Function.update b i (r i)) i = 0 := by
  exact Implementation.multiPayment_spec v f hc r
theorem multi_rochet (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    [∀ i, Nonempty (T i)] :
    (∃ p : (∀ i, T i) → I → ℝ, MultiDSIC v f p) ↔ SliceCyclicMonotone v f := by
  exact Implementation.multi_rochet v f
end Multiagent

theorem example_two_cycles : ∀ s t : Fin 3,
    0 ≤ edgeWeight exampleValuation id s t + edgeWeight exampleValuation id t s := by
  exact Implementation.example_two_cycles

theorem example_three_cycle :
    walkWeight (edgeWeight exampleValuation id) (0 : Fin 3) [1, 2, 0] = -3 := by
  exact Implementation.example_three_cycle
theorem example_not_implementable : ¬ ∃ p : Fin 3 → ℝ, DSIC exampleValuation id p := by
  exact Implementation.example_not_implementable
end Rochet
