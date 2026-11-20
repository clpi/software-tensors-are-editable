# Census — every claim at its evidence

States follow the family discipline: proved here, proved by
citation at a named pin, premise, proposed, blocked, or
unknown. Nothing sits higher than its evidence.

## Proved here (proof/Tensors.lean, gate at the founding pin)

- Reversal exactness, overlay form: a delta applied, then
  its recorded inverse applied, restores the original state
  at every coordinate. (reversal_exact, resting on
  look_invOf.)
- Composition form: applying a second delta after a first is
  applying their join, second first. (applyEd_append,
  resting on look_append.)
- The empty delta is the identity. (applyEd_empty.)
- An untouched coordinate keeps its value. (applyEd_untouched.)
- A successful lookup names an entry of the delta.
  (look_some_mem.)
- Protection soundness: an admissible delta leaves every
  protected coordinate at its state value. (adm_protects.)
- Admissibility under composition, with the cross-tie side
  condition stated in the theorem. (adm_append.)
- View obscurity is state-independent. (view_obscure_free.)
- View determinism, agreement form: states agreeing on the
  evidenced coordinates have the same view. (view_agree.)
- View determinism, plain form. (view_det.)

## Standing controls (refutations, kept in the tree)

- Admissibility is not preserved under composition without
  the cross condition: two singly admissible deltas at tied
  coordinates whose join disagrees. (tie_control.)
- The state-dependent change condition is not preserved
  under composition. (chg_control.)

## Proved by citation, never recomputed

- The path-weight overlay round trip (every weight and every
  path score restored exactly) and cone invariance, in
  clpi/software-is-a-parametric-language-model at pin
  ca4ca2b39181bb93a717b3edbb58ab476761fa5c (its theorems named
  overlay_roundtrip and overlay_cone in that tree). Cited as
  the family precedent for overlay exactness; this repo's
  tensor form is proved here, not borrowed.

## Premises and proof obligations

- O-scale: the abstract core's value type is the integers —
  the symbol layer. Transport through a fixed nonzero
  per-tensor scale, or a restatement over exact rationals,
  is owed. Owner: the proof lane, next theorem wave.
- O-schema: the per-schema check that each category metric
  is a function of the found list and the declared bounds
  (spec 5.3). Owner: the proof lane, with the first concrete
  schema.
- O-tie-evidence: a stated method for evidencing a tie claim
  about a concrete checkpoint. Blocked with the fixtures
  below.

## Blocked

- The paired sign-flip behavioral claim (a value row and
  output column flipped together preserving scoped attention
  behavior in exact arithmetic, unpaired edits and stale
  caches as controls): its Qwen fixtures are not on this
  machine. Verified by exhaustive search 2026-11-20: no
  Pythia material and no deterministic-llms repository
  exists on disk, and the sign-flip experiment's own
  checkpoint is absent — a different Qwen checkpoint is
  present (the Ollama entry below) and is not that
  experiment's fixture. One search pass reported a Qwen3
  GGUF file at a workspace path; no direct read ever
  confirmed it and a name-exact re-sweep of every plausible
  root found nothing, so that file is recorded as not
  present, with the discrepancy named in the program
  record.
- The Pythia causal mask reconstruction and the 72-run
  fixture benchmark receipt: same access blocker — the
  fixtures and the receipt are not on this machine.

## Verified firsthand on disk (census, 2026-11-20)

- The ternary BitNet checkpoint: safetensors, 1,178,623,988
  bytes, 542 tensors, SHA-256
  8143ae115ed6babe5e5ada8fb8c5b769d8f417802b2db042ad98b4f7ed73975b.
  Its layer-0 value projection decompiles to an exact
  semantic form and rebuilds byte for byte (round trip
  executed in this census: exact on all 409,600 packed bytes
  and both scale bytes, verdict PASS). Its 210 packed
  matrices are also sliced unchanged beside it with a
  per-matrix census from a second code path.
- The decompiled semantic form of that matrix: 1,638,402
  bytes, SHA-256
  6e8d080b8907b6450755e9e0e1442ce6501aa6e9c5ff3b56d5a359f17f1d32c7.
- A Qwen2.5 1.5B Instruct checkpoint in a local Ollama
  store (~/workspace/tools/ollama-vm/models): the model
  layer is a GGUF version 3 file, 986,048,512 bytes, 338
  tensors, SHA-256
  183715c435899236895da3869489cc30ac241476b4971a20285b1a462818a5b4
  (computed in full; it matches the blob's content-addressed
  name). Correction, 2026-11-20: the founding census missed
  this store — its blobs carry no file extension, so the
  extension-based search could not see them — and wrongly
  recorded that no Ollama store exists on disk. The
  completed full sweep found it. No blocked item above
  depends on this checkpoint: it is not any blocked
  experiment's fixture.

## Unknown

- Every behavioral effect of every concrete delta, until
  proved under a stated model or verified against held-out
  evidence. Printed as unknown, per the program contract.
