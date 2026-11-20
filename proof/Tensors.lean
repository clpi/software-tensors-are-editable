/-
  Editable tensors: the abstract core of the transition
  semantics for recursive semantic feedback over model
  tensors.

  A tensor state is treated at the level the semantics needs:
  a total assignment of integer values to flat coordinates.
  A concrete checkpoint is a finite presentation of such an
  assignment — a byte string plus a decoding — and every
  theorem here is about the assignment the bytes decode to.
  Nothing here claims a behavioral effect: an edit is a
  structural fact about the assignment, and behavior enters
  only through evidence a view carries, never through the
  delta itself.

  The delta form is the overlay form: a finite list of
  coordinate-value entries, first match wins, exactly the
  shape whose round trip and cone invariance are already
  proved for the parametric language model core at its
  founding pin (cited in the census, not reproved here).
  What is new here is the same algebra lifted from path
  weights to the tensor assignment itself, plus the
  admissibility discipline (protection, a declared value
  range, tied coordinates) and the view construction.
-/

namespace Tensor

/-- A coordinate: a flat index into the tensor's value
    space. A concrete presentation fixes the coordinate
    order (for the ternary checkpoint on disk: tensor by
    tensor in header order, row major inside each tensor);
    the semantics here needs only that the order is fixed
    and shared by every lane. -/
abbrev Coord := Nat

/-- A tensor state at the abstract level: a total assignment
    of integer values to coordinates. -/
abbrev State := Coord → Int

/-- One edit entry: a coordinate and the value it is set
    to. -/
abbrev Entry := Coord × Int

/-- A delta: a finite list of edit entries. -/
abbrev Delta := List Entry

/-- The value a delta assigns at a coordinate, if it assigns
    one: the first entry for that coordinate, reading the
    list from the head. -/
def look : Delta → Coord → Option Int
  | [], _ => none
  | (k, v) :: es, c => if k = c then some v else look es c

/-- Applying a delta to a state: at each coordinate, the
    delta's assigned value where it assigns one, and the
    state's own value everywhere else. -/
def applyEd (d : Delta) (s : State) : State :=
  fun c => match look d c with
    | some v => v
    | none => s c

/-- The recorded inverse of a delta against the state it was
    derived from: at every coordinate the delta touches, the
    value that state held there, in the delta's own order. -/
def invOf (s : State) : Delta → Delta
  | [] => []
  | (k, _) :: es => (k, s k) :: invOf s es

/-- A coordinate a delta never mentions keeps the state's
    value under the delta. -/
theorem applyEd_untouched {d : Delta} {s : State} {c : Coord}
    (h : look d c = none) : applyEd d s c = s c := by
  unfold applyEd
  rw [h]

/-- The empty delta is the identity on states. -/
theorem applyEd_empty (s : State) : applyEd [] s = s := by
  funext c
  rfl

/-- Lookup over a joined delta: the left part wins where it
    assigns, else the right part decides. -/
theorem look_append (a b : Delta) (c : Coord) :
    look (a ++ b) c
      = match look a c with
        | some v => some v
        | none => look b c := by
  induction a with
  | nil => rfl
  | cons e es ih =>
    cases e with
    | mk k v =>
      by_cases hk : k = c
      · simp only [List.cons_append, look, if_pos hk]
      · simp only [List.cons_append, look, if_neg hk]
        exact ih

/-- Composition of deltas is a single delta: applying the
    second after the first is applying their join, second
    first. -/
theorem applyEd_append (d₁ d₂ : Delta) (s : State) :
    applyEd (d₂ ++ d₁) s = applyEd d₂ (applyEd d₁ s) := by
  funext c
  unfold applyEd
  rw [look_append]
  cases look d₂ c with
  | some v => rfl
  | none => rfl

/-- Lookup in the recorded inverse: where the delta assigns,
    the inverse assigns the value the source state held;
    where the delta is silent, the inverse is silent. -/
theorem look_invOf {s : State} {d : Delta} {c : Coord} :
    look (invOf s d) c
      = match look d c with
        | some _ => some (s c)
        | none => none := by
  induction d with
  | nil => rfl
  | cons e es ih =>
    cases e with
    | mk k v =>
      by_cases hk : k = c
      · subst hk
        simp only [invOf, look, if_pos rfl, if_true]
      · simp only [invOf, look, if_neg hk]
        exact ih

/-- Reversal exactness, the overlay form: a delta applied
    and then its recorded inverse applied restores the
    original state exactly, at every coordinate. This is the
    abstract form of the byte-for-byte recovery the program
    contract requires of every edit. -/
theorem reversal_exact (s : State) (d : Delta) :
    applyEd (invOf s d) (applyEd d s) = s := by
  funext c
  unfold applyEd
  rw [look_invOf]
  cases look d c with
  | none => rfl
  | some v => rfl

/- Admissibility. A delta is admissible against a protection
   list, a declared value range, and a tie relation when:
   it touches no protected coordinate; every value it
   assigns lies in the range; and any two entries it carries
   at tied coordinates assign the same value. The first two
   conditions and the third's within-delta part are
   state-independent, which is exactly what makes the
   composition theorem below hold under one cross condition
   and no other hypothesis. -/

/-- Admissibility of a delta: protection, range, and
    within-delta tie consistency. The tie relation is a
    boolean function on coordinate pairs, declared by the
    policy in force. -/
def Adm (prot : List Coord) (lo hi : Int)
    (tie : Coord → Coord → Bool) (d : Delta) : Prop :=
  (∀ e ∈ d, e.1 ∉ prot) ∧
  (∀ e ∈ d, lo ≤ e.2 ∧ e.2 ≤ hi) ∧
  (∀ e₁ ∈ d, ∀ e₂ ∈ d, tie e₁.1 e₂.1 = true → e₁.2 = e₂.2)

/-- A lookup that succeeds names an entry of the delta at
    that coordinate with that value. -/
theorem look_some_mem {d : Delta} {c : Coord} {v : Int}
    (h : look d c = some v) : (c, v) ∈ d := by
  induction d with
  | nil => simp only [look] at h; cases h
  | cons e es ih =>
    cases e with
    | mk k w =>
      by_cases hk : k = c
      · simp only [look, if_pos hk] at h
        cases h
        subst hk
        exact List.mem_cons.mpr (Or.inl rfl)
      · simp only [look, if_neg hk] at h
        exact List.mem_cons_of_mem _ (ih h)

/-- An admissible delta leaves every protected coordinate at
    the state's own value. -/
theorem adm_protects {prot : List Coord} {lo hi : Int}
    {tie : Coord → Coord → Bool} {d : Delta} {s : State}
    (hadm : Adm prot lo hi tie d) {c : Coord} (hc : c ∈ prot) :
    applyEd d s c = s c := by
  apply applyEd_untouched
  cases hl : look d c with
  | none => rfl
  | some v =>
    have hmem := look_some_mem hl
    have hnp := hadm.1 (c, v) hmem
    exact absurd hc hnp

/-- Composition of admissible deltas, with its precise side
    condition: two admissible deltas compose to an admissible
    delta exactly when they also agree across the pair — any
    entry of one at a coordinate tied to an entry of the
    other assigns the same value, in both directions of the
    tie. Protection and range need no side condition: they
    are per-entry and state-independent. -/
theorem adm_append {prot : List Coord} {lo hi : Int}
    {tie : Coord → Coord → Bool} {d₁ d₂ : Delta}
    (h₁ : Adm prot lo hi tie d₁) (h₂ : Adm prot lo hi tie d₂)
    (hcross : ∀ e ∈ d₂, ∀ e' ∈ d₁,
      (tie e.1 e'.1 = true → e.2 = e'.2) ∧
      (tie e'.1 e.1 = true → e'.2 = e.2)) :
    Adm prot lo hi tie (d₂ ++ d₁) := by
  refine ⟨?_, ?_, ?_⟩
  · intro e he
    cases List.mem_append.mp he with
    | inl h => exact h₂.1 e h
    | inr h => exact h₁.1 e h
  · intro e he
    cases List.mem_append.mp he with
    | inl h => exact h₂.2.1 e h
    | inr h => exact h₁.2.1 e h
  · intro e₁ he₁ e₂ he₂ htie
    cases List.mem_append.mp he₁ with
    | inl h₁m =>
      cases List.mem_append.mp he₂ with
      | inl h₂m => exact h₂.2.2 e₁ h₁m e₂ h₂m htie
      | inr h₂m => exact (hcross e₁ h₁m e₂ h₂m).1 htie
    | inr h₁m =>
      cases List.mem_append.mp he₂ with
      | inl h₂m => exact (hcross e₂ h₂m e₁ h₁m).2 htie
      | inr h₂m => exact h₁.2.2 e₁ h₁m e₂ h₂m htie

/- Standing controls. Each control is a proved fact over a
   concrete instance that a load-bearing condition guards:
   the unconditional form of a claim the program does not
   make, refuted by computation-sized proof, kept in the
   tree so a future change that breaks the condition breaks
   the build. -/

/-- The tie relation of the first control: distinct
    coordinates are tied, a coordinate is not tied to
    itself. -/
def tiePair (a b : Coord) : Bool := a != b

/-- Control one: admissibility is NOT preserved under
    composition without the cross condition. Each delta
    below is admissible alone; their join is not, because
    the two entries sit at tied coordinates and disagree. -/
theorem tie_control :
    Adm [] (-10) 10 tiePair [(0, 1)] ∧
    Adm [] (-10) 10 tiePair [(1, 2)] ∧
    ¬ Adm [] (-10) 10 tiePair ([(1, 2)] ++ [(0, 1)]) := by
  refine ⟨?_, ?_, ?_⟩
  · refine ⟨?_, ?_, ?_⟩
    · intro e he
      simp only [List.mem_singleton] at he
      cases he
      simp
    · intro e he
      simp only [List.mem_singleton] at he
      cases he
      exact ⟨by decide, by decide⟩
    · intro e₁ h₁ e₂ h₂ _
      simp only [List.mem_singleton] at h₁ h₂
      cases h₁
      cases h₂
      rfl
  · refine ⟨?_, ?_, ?_⟩
    · intro e he
      simp only [List.mem_singleton] at he
      cases he
      simp
    · intro e he
      simp only [List.mem_singleton] at he
      cases he
      exact ⟨by decide, by decide⟩
    · intro e₁ h₁ e₂ h₂ _
      simp only [List.mem_singleton] at h₁ h₂
      cases h₁
      cases h₂
      rfl
  · intro h
    have htie := h.2.2 (1, 2) (by simp) (0, 1) (by simp) (by rfl)
    exact absurd htie (by decide)

/-- The state-dependent change condition: every entry of the
    delta changes the value the given state holds at its
    coordinate. Plausible as an admissibility condition, and
    the wrong one: the second control shows it is not
    preserved under composition, which is why admissibility
    above is state-independent. -/
def Chg (s : State) (d : Delta) : Prop :=
  ∀ e ∈ d, s e.1 ≠ e.2

/-- Control two: the change condition holds of each delta
    against the state it was derived from, and fails of the
    composed delta against the original state. -/
theorem chg_control :
    Chg (fun _ => 0) [(0, 1)] ∧
    Chg (applyEd [(0, 1)] (fun _ => 0)) [(0, 0)] ∧
    ¬ Chg (fun _ => 0) ([(0, 0)] ++ [(0, 1)]) := by
  refine ⟨?_, ?_, ?_⟩
  · intro e he
    simp only [List.mem_singleton] at he
    cases he
    decide
  · intro e he
    simp only [List.mem_singleton] at he
    cases he
    have h1 : applyEd [(0, 1)] (fun _ => (0 : Int)) 0 = 1 := rfl
    rw [h1]
    decide
  · intro h
    have hbad := h (0, 0) (by simp)
    exact hbad rfl

/- The view. A view of a state under evidence is two lists:
   the recovered entries — coordinate and value, in evidence
   order — and the obscurity, the declared universe's
   coordinates the evidence does not cover. The obscurity is
   a component of the view, not an omission from it: a
   consumer of the view can always state what the view does
   not know. -/

/-- A view: recovered entries plus the explicit obscurity
    list. -/
structure View where
  found : List (Coord × Int)
  obscure : List Coord
deriving DecidableEq, Repr

/-- The view of a state over a declared universe under an
    evidence list: the evidenced coordinates with their
    values, and the unevidenced remainder of the universe. -/
def viewOf (univ ev : List Coord) (s : State) : View :=
  { found := ev.map (fun c => (c, s c)),
    obscure := univ.filter (fun c => c ∉ ev) }

/-- The obscurity of a view does not depend on the state at
    all: it is a function of the universe and the evidence
    alone. -/
theorem view_obscure_free (univ ev : List Coord) (s : State) :
    (viewOf univ ev s).obscure
      = univ.filter (fun c => c ∉ ev) := rfl

/-- View determinism, the agreement form: two states that
    agree on every evidenced coordinate have the same view
    under the same universe and evidence. The view is a
    function of the state restricted to the evidence, and of
    nothing else about the state. -/
theorem view_agree {univ ev : List Coord} {s₁ s₂ : State}
    (h : ∀ c ∈ ev, s₁ c = s₂ c) :
    viewOf univ ev s₁ = viewOf univ ev s₂ := by
  unfold viewOf
  congr 1
  apply List.map_congr_left
  intro c hc
  rw [h c hc]

/-- View determinism, the plain form: the same state and the
    same evidence yield the same next view. -/
theorem view_det (univ ev : List Coord) (s : State) :
    viewOf univ ev s = viewOf univ ev s := rfl

end Tensor
