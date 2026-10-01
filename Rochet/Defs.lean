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


/-! Shared mathematical definitions. Their identical values also appear in Challenge. -/
set_option autoImplicit false

@[expose] public section

namespace Rochet
universe u w z

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

section Multiagent
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

end Multiagent

/-- Three true types (rows) and three outcomes (columns):
[0,-2,1], [1,0,-2], [-2,1,0]. -/
def exampleValuation (t x : Fin 3) : ℝ :=
  if t = x then 0 else if (t.val + 1) % 3 = x.val then -2 else 1

end Rochet
