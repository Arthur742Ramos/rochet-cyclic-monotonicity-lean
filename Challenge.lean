/-
Copyright (c) 2026 Arthur Freitas Ramos. All rights reserved.
Released under BSD-3-Clause as described in LICENSE.
Authors: Arthur Freitas Ramos, David Barros Hulak,
  Ruy Jose Guerra Barretto de Queiroz
-/
module

public import Mathlib.Algebra.Order.Archimedean.Real.Basic
public import Mathlib.Order.ConditionallyCompleteLattice.Basic
public import Mathlib.Tactic.Linarith
public import Mathlib.Tactic.FinCases
public import Mathlib.Data.Fintype.Fin

/-!
Independent Mathlib-only comparison surface for Rochet's characterization.
Every theorem has a complete proof; there are no statement holes.
The payment convention is utility = valuation minus payment.
-/
set_option autoImplicit false

@[expose] public section

namespace Rochet
universe u w

/-- The endpoint after starting at `s` and visiting every vertex of the list. -/
def endpoint {T : Type u} : T → List T → T
  | s, [] => s
  | _, t :: ts => endpoint t ts

/-- Sum of directed edge weights along a finite walk, including the initial edge. -/
def walkWeight {T : Type u} (l : T → T → ℝ) : T → List T → ℝ
  | _, [] => 0
  | s, t :: ts => l s t + walkWeight l t ts

/-- Every finite closed walk, with repetitions allowed, has nonnegative weight. -/
def NoNegativeCycles {T : Type u} (l : T → T → ℝ) : Prop :=
  ∀ s ts, endpoint s ts = s → 0 ≤ walkWeight l s ts

/-- Real weights of all finite walks from `r` to `t`; the empty walk is admitted
exactly when `r = t`. -/
def pathWeights {T : Type u} (l : T → T → ℝ) (r t : T) : Set ℝ :=
  {a | ∃ ts, endpoint r ts = t ∧ walkWeight l r ts = a}

/-- Anchored shortest-path potential; meaningful under `NoNegativeCycles` because
path weights are nonempty and bounded below, as proved below. -/
noncomputable def potential {T : Type u} (l : T → T → ℝ) (r t : T) : ℝ :=
  sInf (pathWeights l r t)

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

/-- Explicit finite lower and upper bounds for the anchored potential. -/
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

/-- Edge from report `s` to truthful type `t`. -/
def edgeWeight {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X) (s t : T) : ℝ :=
  v t (f t) - v t (f s)

/-- Truthful reporting weakly dominates every alternative report. -/
def DSIC {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X) (p : T → ℝ) : Prop :=
  ∀ t s, v t (f t) - p t ≥ v t (f s) - p s

/-- The allocation has no negative valuation-difference cycle. -/
def CyclicMonotone {T : Type u} {X : Type w} (v : T → X → ℝ) (f : T → X) : Prop :=
  NoNegativeCycles (edgeWeight v f)

/-- Implementing payments normalized at a specified report. -/
noncomputable def anchoredPayment {T : Type u} {X : Type w}
    (v : T → X → ℝ) (f : T → X) (r : T) : T → ℝ := potential (edgeWeight v f) r

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

/-- DSIC forces identical payments at reports giving the same outcome.
Adapted from the two-comparison argument in Roberts/Taxation.lean, BSD-3-Clause. -/
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

/-- Allocation seen by one agent when every other report is held fixed. -/
def slice (f : (∀ i, T i) → X) (i : I) (b : ∀ i, T i) : T i → X :=
  fun t => f (Function.update b i t)

/-- Dominant-strategy truthfulness for arbitrary agents and heterogeneous reports. -/
def MultiDSIC (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    (p : (∀ i, T i) → I → ℝ) : Prop :=
  ∀ i b t, v i (b i) (f b) - p b i ≥
    v i (b i) (f (Function.update b i t)) - p (Function.update b i t) i

/-- Every fixed-other-reports single-agent allocation is cyclically monotone. -/
def SliceCyclicMonotone (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X) : Prop :=
  ∀ i b, CyclicMonotone (v i) (slice f i b)

/-- Assemble anchored slice payments with a fixed anchor for each agent. -/
noncomputable def multiPayment (v : ∀ i, T i → X → ℝ) (f : (∀ i, T i) → X)
    (r : ∀ i, T i) (b : ∀ i, T i) (i : I) : ℝ :=
  anchoredPayment (v i) (slice f i b) (r i) (b i)

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

/-- Three true types (rows) and three outcomes (columns):
[0,-2,1], [1,0,-2], [-2,1,0]. -/
def exampleValuation (t x : Fin 3) : ℝ :=
  if t = x then 0 else if (t.val + 1) % 3 = x.val then -2 else 1

/-- Every two-cycle inequality holds in the three-type example. -/
theorem example_two_cycles : ∀ s t : Fin 3,
    0 ≤ edgeWeight exampleValuation id s t + edgeWeight exampleValuation id t s := by
  intro s t
  fin_cases s <;> fin_cases t <;> norm_num [edgeWeight, exampleValuation]

/-- The closed walk 0→1→2→0 has strictly negative weight. -/
theorem example_three_cycle :
    walkWeight (edgeWeight exampleValuation id) (0 : Fin 3) [1, 2, 0] = -3 := by
  norm_num [walkWeight, edgeWeight, exampleValuation]

theorem example_not_implementable : ¬ ∃ p : Fin 3 → ℝ, DSIC exampleValuation id p := by
  intro hp
  have hc := (rochet exampleValuation id).mp hp
  have h := hc (0 : Fin 3) [1, 2, 0] (by rfl)
  rw [example_three_cycle] at h
  norm_num at h

end Rochet
