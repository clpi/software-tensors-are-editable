# software-tensors-are-editable

The transition semantics and machine-checked proof core for
the editable tensors and recursive semantic feedback program:
a deterministic view of a model checkpoint is edited, the
edit lands on the actual tensor bytes of an editable copy,
the next view is constructed from the edited state, and that
view drives the next edit. Both the tensor state and the
represented intelligence participate in the recurrence. An
archive that simply reselects old observations is a baseline,
not the result.

This repo is the semantics and proof home. The executable
edit-and-reproject loop, the independent check, and the
tensor ingest lanes are separate lanes of the same program;
their briefs are staged in the program record at
~/workspace/research/editable-tensors-feedback-2026-11-20.md.

## Contents

- spec.md — the transition semantics at agent-proof
  resolution: presentations and coordinates, the delta
  language (the overlay form, protection, tied coordinates),
  admissibility and its composition law with its precise side
  condition, reversal, the view with its explicit obscurity
  component, policies and typed view edits (retune, add,
  drop, replace an axis), the recurrence step, and the
  receipt contract. Every claim labeled with its state and
  its proof obligation.
- proof/ — the Lean core: 12 theorems and 2 standing controls
  (reversal exactness for the overlay form, the composition
  form of sequential edits, admissibility under composition
  with the cross-tie side condition, protection soundness,
  view determinism in its agreement form, and the two
  refuted unconditional forms kept as controls). The family
  gate: proof/check.sh, cold, Lean 4.19.0, warnings as
  errors, escape scan, dependency audit inside {propext,
  Classical.choice, Quot.sound}.
- census.md — every claim of the program at its evidence:
  proved here, proved by citation at pins, premises named,
  blocked, unknown.

## Headline results

- Reversal is exact: a delta applied and then its recorded
  inverse applied restores the original state at every
  coordinate (proved, abstract tensor level).
- Admissibility composes under exactly one side condition —
  cross agreement at tied coordinates — and the unconditional
  form is refuted by a standing control, as is the
  state-dependent change condition. Admissibility is
  state-independent by construction.
- The view is deterministic: its obscurity depends on the
  universe and evidence alone, and states agreeing on the
  evidenced coordinates have the same view.
- No behavioral claim is made anywhere in this repo. A
  structural tensor result is only a structural result;
  behavioral effects are proved under a stated model or
  verified against held-out evidence, per claim, or printed
  as unknown.
