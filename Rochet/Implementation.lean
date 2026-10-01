/-
Copyright (c) 2026 Arthur Freitas Ramos. All rights reserved.
Released under BSD-3-Clause as described in LICENSE.
Authors: Arthur Freitas Ramos, David Barros Hulak,
  Ruy Jose Guerra Barretto de Queiroz
-/
module

public import Rochet.Defs
public import Mathlib.Algebra.Order.Archimedean.Real.Basic
public import Mathlib.Order.ConditionallyCompleteLattice.Basic
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.FinCases
public import Mathlib.Data.Fintype.Fin

/-!
Reusable proofs of Rochet's finite-real difference-constraint characterization.
The common-outcome argument adapts Roberts/Taxation.lean at the commit in NOTICE.
The payment convention is utility = valuation minus payment.
-/
set_option autoImplicit false

@[expose] public section

namespace Rochet.Implementation
universe u w

theorem endpoint_append {T : Type u} (s : T) (xs ys : List T) :
    endpoint s (xs ++ ys) = endpoint (endpoint s xs) ys := by
  induction xs generalizing s with
  | nil => rfl
  | cons t ts ih => exact ih t

theorem walkWeight_append {T : Type u} (l : T → T → ℝ) (s : T) (xs ys : List T) :
    walkWeight l s (xs ++ ys) = walkWeight l s xs + walkWeight l (endpoint s xs) ys := by
  induction xs generalizing s with
  | nil => simp [walkWeight, endpoint]
  | cons t ts ih => simp [walkWeight, endpoint, ih, add_assoc]

theorem pathWeights_nonempty {T : Type u} (l : T → T → ℝ) (r t : T) :
    (pathWeights l r t).Nonempty := by
  exact ⟨l r t, [t], rfl, by simp [walkWeight]⟩

theorem pathWeights_lower_bound {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) :
    ∀ a ∈ pathWeights l r t, -l t r ≤ a := by
  rintro a ⟨ts, ht, rfl⟩
  have hclose : endpoint r (ts ++ [r]) = r := by
    simp [endpoint_append, endpoint]
  have h := hc r (ts ++ [r]) hclose
  rw [walkWeight_append, ht] at h
  simp only [walkWeight, add_zero] at h
  linarith

theorem pathWeights_bddBelow {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) : BddBelow (pathWeights l r t) :=
  ⟨-l t r, pathWeights_lower_bound l hc r t⟩

theorem potential_anchor {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r : T) : potential l r r = 0 := by
  apply le_antisymm
  · exact csInf_le (pathWeights_bddBelow l hc r r) ⟨[], rfl, rfl⟩
  · apply le_csInf (pathWeights_nonempty l r r)
    rintro a ⟨ts, ht, rfl⟩
    exact hc r ts ht

theorem potential_edge {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r s t : T) :
    potential l r t - potential l r s ≤ l s t := by
  have h : potential l r t - l s t ≤ potential l r s := by
    apply le_csInf (pathWeights_nonempty l r s)
    rintro a ⟨ts, hs, rfl⟩
    have hmem : walkWeight l r ts + l s t ∈ pathWeights l r t := by
      refine ⟨ts ++ [t], ?_, ?_⟩
      · simp [endpoint_append, endpoint]
      · simp [walkWeight_append, hs, walkWeight]
    have hle := csInf_le (pathWeights_bddBelow l hc r t) hmem
    change potential l r t ≤ walkWeight l r ts + l s t at hle
    linarith
  linarith

theorem potential_bounds {T : Type u} (l : T → T → ℝ)
    (hc : NoNegativeCycles l) (r t : T) :
    -l t r ≤ potential l r t ∧ potential l r t ≤ l r t := by
  constructor
  · exact le_csInf (pathWeights_nonempty l r t) (pathWeights_lower_bound l hc r t)
  · exact csInf_le (pathWeights_bddBelow l hc r t) ⟨[t], rfl, by simp [walkWeight]⟩

theorem walkWeight_ge_difference {T : Type u} (l : T → T → ℝ) (p : T → ℝ)
    (hp : ∀ s t, p t - p s ≤ l s t) (s : T) (ts : List T) :
    p (endpoint s ts) - p s ≤ walkWeight l s ts := by
  induction ts generalizing s with
  | nil => simp [endpoint, walkWeight]
  | cons t ts ih =>
    have h := hp s t
    have htail := ih t
    simp only [endpoint, walkWeight]
    linarith

theorem noNegativeCycles_of_potential {T : Type u} (l : T → T → ℝ) (p : T → ℝ)
    (hp : ∀ s t, p t - p s ≤ l s t) : NoNegativeCycles l := by
  intro s ts hs
  have h := walkWeight_ge_difference l p hp s ts
  simpa [hs] using h

theorem dsic_iff_edge {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X) (p : T → ℝ) :
    DSIC v f p ↔ ∀ s t, p t - p s ≤ edgeWeight v f s t := by
  constructor
  · intro h s t
    have h := h t s
    unfold edgeWeight
    linarith
  · intro h t s
    have h := h s t
    unfold edgeWeight at h
    linarith

theorem anchoredPayment_spec {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X)
    (hc : CyclicMonotone v f) (r : T) :
    anchoredPayment v f r r = 0 ∧ DSIC v f (anchoredPayment v f r) := by
  refine ⟨potential_anchor _ hc r, (dsic_iff_edge v f _).mpr ?_⟩
  exact potential_edge _ hc r

theorem rochet {T : Type u} {X : Type w} [Nonempty T] (v : T → X → ℝ) (f : T → X) :
    (∃ p : T → ℝ, DSIC v f p) ↔ CyclicMonotone v f := by
  constructor
  · rintro ⟨p, hp⟩
    exact noNegativeCycles_of_potential _ p ((dsic_iff_edge v f p).mp hp)
  · intro hc
    obtain ⟨r⟩ := ‹Nonempty T›
    exact ⟨anchoredPayment v f r, (anchoredPayment_spec v f hc r).2⟩

theorem payment_eq_of_same_outcome {T : Type u} {X : Type w}
    (v : T → X → ℝ) (f : T → X) (p : T → ℝ) (hp : DSIC v f p)
    (s t : T) (hf : f s = f t) : p s = p t := by
  have hst := hp s t
  have hts := hp t s
  rw [hf] at hst hts
  linarith

section Multiagent
universe z
variable {I : Type z} {T : I → Type u} {X : Type w} [DecidableEq I]

theorem slice_update (f : (∀ i, T i) → X) (i : I) (b : ∀ i, T i) (t : T i) :
    slice f i (Function.update b i t) = slice f i b := by
  funext s
  simp [slice, Function.update_idem]

theorem slice_self (f : (∀ i, T i) → X) (i : I) (b : ∀ i, T i) :
    slice f i b (b i) = f b := by
  simp [slice]

theorem multiPayment_spec (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    (hc : SliceCyclicMonotone v f) (r : ∀ i, T i) :
    MultiDSIC v f (multiPayment v f r) ∧
      ∀ i b, multiPayment v f r (Function.update b i (r i)) i = 0 := by
  constructor
  · intro i b t
    have h := (anchoredPayment_spec (v i) (slice f i b) (hc i b) (r i)).2 (b i) t
    simpa only [multiPayment, slice_update, Function.update_self, slice_self, slice, Function.update_eq_self] using h
  · intro i b
    simpa only [multiPayment, slice_update, Function.update_self] using
      (anchoredPayment_spec (v i) (slice f i b) (hc i b) (r i)).1

theorem multi_rochet (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    [∀ i, Nonempty (T i)] :
    (∃ p : (∀ i, T i) → I → ℝ, MultiDSIC v f p) ↔ SliceCyclicMonotone v f := by
  constructor
  · rintro ⟨p, hp⟩ i b
    have hs : DSIC (v i) (slice f i b) (fun t => p (Function.update b i t) i) := by
      intro t s
      have h := hp i (Function.update b i t) s
      simpa only [Function.update_self, Function.update_idem, slice] using h
    exact noNegativeCycles_of_potential _ _ ((dsic_iff_edge _ _ _).mp hs)
  · intro hc
    classical
    let r : ∀ i, T i := fun i => Classical.choice (inferInstance : Nonempty (T i))
    exact ⟨multiPayment v f r, (multiPayment_spec v f hc r).1⟩

end Multiagent

theorem example_two_cycles : ∀ s t : Fin 3,
    0 ≤ edgeWeight exampleValuation id s t + edgeWeight exampleValuation id t s := by
  intro s t
  fin_cases s <;> fin_cases t <;> norm_num [edgeWeight, exampleValuation]

theorem example_three_cycle :
    walkWeight (edgeWeight exampleValuation id) (0 : Fin 3) [1, 2, 0] = -3 := by
  norm_num [walkWeight, edgeWeight, exampleValuation]

theorem example_not_implementable : ¬ ∃ p : Fin 3 → ℝ, DSIC exampleValuation id p := by
  intro hp
  have hc := (rochet exampleValuation id).mp hp
  have h := hc (0 : Fin 3) [1, 2, 0] (by rfl)
  rw [example_three_cycle] at h
  norm_num at h

end Rochet.Implementation
