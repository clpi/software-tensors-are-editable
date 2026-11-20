# Transition semantics for editable tensors — first form

The semantics of one step of the recursive semantic feedback
loop: what a view is, what a delta is, when a delta may be
applied, how an edit is reversed, and how the next view is
derived. Written at agent-proof resolution: an implementer
following this text builds exactly this semantics or cannot
help but build it. Every claim carries its state — settled
intent, proposed, implemented, or verified — and its proof
obligation where one is owed. Prose states never blur: a
structural result is never stated as a behavioral one, and
unknown behavior is printed as unknown.

The machine-checked core of this spec lives in the proof
directory of clpi/software-tensors-are-editable (the Tensor
module). Claims marked PROVED are theorems there, under the
family gate. Claims marked CITED are theorems of
clpi/software-tensors-are-editable's sibling
clpi/software-is-a-parametric-language-model at pin
ca4ca2b39181bb93a717b3edbb58ab476761fa5c, reused by citation
and never recomputed.

## 1. Presentations and coordinates

1.1 (settled intent, definition). A presentation of a
checkpoint is: the checkpoint file, its hash, and a fixed
coordinate order — the list of its tensors in header order,
each tensor's coordinates enumerated row major over its
stored shape. A coordinate is a flat index into this order.
Every lane uses the same order for the same presentation;
the order is part of the presentation, and a receipt names
the presentation by the checkpoint hash, which fixes it.

1.2 (verified firsthand for one presentation). The ternary
checkpoint on this machine (safetensors, 542 tensors, hash
in the program census) has its order read from its own
header: one embedding table, thirty layers of seven packed
matrices with paired scale tensors and four norm vectors,
one final norm. Its 210 packed matrices are also sliced out
unchanged, one file per matrix, beside the checkpoint, with
a per-matrix field census — a second presentation of the
same coordinates, and the two agree on the subject matrix
count for count (census, program record).

1.3 (settled intent, definition). A state is the total
assignment of decoded values to coordinates that a
presentation fixes. For a packed ternary matrix the decoded
value at a coordinate is the tensor's scalar scale times the
coordinate's symbol, the symbol in {−1, 0, +1} read from the
2-bit field as field minus one, fields in bit order 0, 2, 4,
6 within each byte (the convention the on-disk decompiler
proves against the packed bytes by an exact round trip;
agreement with any external runtime's unpack order is a
separate, unverified claim and is not assumed).

## 2. The delta language

2.1 (settled intent, definition). A delta is a finite list
of entries, each entry a coordinate and a value. Applying a
delta to a state yields the state that agrees with the delta
at every coordinate the delta assigns — the first entry for
a coordinate wins — and with the original state everywhere
else. This is the overlay form. The empty delta is the
identity (PROVED: the empty-application theorem).

2.2 (settled intent, definition). Composition is sequential
application, and it is again a delta: applying a second
delta after a first is applying their join, second first
(PROVED: the composition-form theorem). A policy sequence
therefore has a single composed delta, which is what a cycle
control inspects.

2.3 (settled intent, definition). Protection is a list of
coordinates. The protected bytes of a presentation are the
byte ranges that present protected coordinates: for a packed
matrix, the bytes holding a protected coordinate's field,
together with the tensor's scale bytes whenever any of its
coordinates is protected (a scale change moves every value
in the tensor, so the scale is protected exactly when the
tensor is touched by protection at all). A delta that
assigns a protected coordinate is inadmissible (section 3),
and an admissible delta provably leaves every protected
coordinate at its state value (PROVED: the protection
theorem).

2.4 (settled intent, definition). A tie relation is a
declared boolean relation on coordinates, named by the
policy in force and recorded in every receipt it governs.
Tied coordinates are coordinates whose decoded values the
declared semantics requires to move together — the standing
example is a value row and the corresponding output column
under a paired transform, and a weight shared between two
sites in the presentation. Which ties hold of a given
checkpoint is evidence, stated per checkpoint; the mechanism
— how a tie constrains a delta — is section 3, and is
settled whether or not any particular tie is.

2.5 (settled intent, definition). The recorded inverse of a
delta against the state it was derived from is the delta
whose entries are, at every coordinate the original delta
touches, the value that state held there, in the original
delta's own order. The inverse is recorded with the edit,
never recomputed from the edited state (the edited state has
forgotten the values the inverse exists to restore).

## 3. Admissibility

3.1 (settled intent, definition). A delta is admissible
against a protection list, a declared value range, and a tie
relation when all three hold: (a) no entry assigns a
protected coordinate; (b) every assigned value lies in the
declared range, endpoints included; (c) any two entries at
tied coordinates assign the same value. Each condition is
checkable by a finite scan of the delta; an implementation
refuses an inadmissible delta by name — which condition,
which entry — and changes no bytes.

3.2 (verified, PROVED). Admissibility is preserved under
composition under exactly one side condition: cross
agreement — any entry of either delta at a coordinate tied
to an entry of the other assigns the same value, in both
directions of the tie. Protection and range need no side
condition; they are per-entry.

3.3 (verified, refuted control standing). The unconditional
form of 3.2 is false. The proof tree carries the control:
two deltas over the tie that joins distinct coordinates,
each admissible alone (one sets coordinate 0 to 1, the other
coordinate 1 to 2, range −10 to 10, no protection), whose
join is inadmissible because the tied entries disagree. Any
future strengthening of the admissibility definition must
keep this control compiling or answer it.

3.4 (verified, refuted control standing). Admissibility is
state-independent by construction, and deliberately: the
plausible state-dependent form — every entry changes the
value the state holds at its coordinate — is not preserved
under composition (control standing in the proof tree: a
delta setting coordinate 0 from 0 to 1, then one setting it
from 1 back to 0, each satisfying the condition against the
state it was derived from, whose composition against the
original state contains an entry that changes nothing). A
condition that composition breaks cannot govern a loop whose
steps compose, so no state-dependent condition is part of
admissibility. Whether an edit changed anything is a receipt
fact, not an admissibility condition.

## 4. Reversal

4.1 (verified, PROVED). Reversal exactness, overlay form:
a delta applied to a state, followed by its recorded inverse
applied to the result, restores the original state at every
coordinate. Proof obligation for the abstract form:
discharged (the reversal theorem, resting on the inverse
lookup lemma).

4.2 (settled intent, contract). At the byte level the same
requirement reads: apply the edit to the editable copy,
record the edited hash; apply the inverse; the resulting
file's hash equals the source hash. A reversal that does not
recover exactly is a defect that halts the loop, never a
caveat carried forward. Obligation: on the executable lane,
per edit, checked by the independent lane from the receipts.

4.3 (verified, CITED). For the path-weight overlay of the
parametric language model, the round trip restores every
weight and every path score exactly, and scores outside an
edit's cone are unchanged fraction for fraction — the same
algebra, proved at the sibling pin. This program's tensor
form is 4.1; the citation is the precedent that the overlay
form carries exactness in this family, not a substitute for
4.1 or 4.2.

## 5. The view

5.1 (settled intent, definition). A view of a state, over a
declared universe of coordinates and an evidence list, is a
pair: the found list — each evidenced coordinate with its
value, in evidence order — and the obscure list — the
universe's coordinates the evidence does not cover. The
obscurity is a component of the view, stated, never an
omission: a consumer of a view can always say what the view
does not know.

5.2 (settled intent, definition). The schema layer over 5.1
is parametric: a schema declares a partition of the universe
into named semantic categories; per category the view
carries the recovered metrics the presentation permits —
exact where recovery is exact (for the ternary presentation:
the per-matrix symbol census, zero share, and scale are
exact), a certified bound where only a bound is recoverable,
and the category's obscure remainder. A category or
coordinate moves from obscure to found only on evidence
named in the view's derivation record; a schema change is a
view edit (section 6), never a silent re-derivation.

5.3 (verified, PROVED). View determinism: the obscurity
depends on the universe and the evidence alone, never on the
state; and two states agreeing on every evidenced coordinate
have the same view under the same universe and evidence. The
view is a function of the state restricted to the evidence
and of nothing else about the state. Obligation discharged
for the pair form of 5.1; the schema layer of 5.2 inherits
it exactly when each category metric is itself a function of
the found list and the declared bounds — a per-schema check,
owed by whichever lane first fixes a concrete schema
(proposed; owner: this lane, with the first schema).

## 6. Policies, view edits, and the recurrence

6.1 (settled intent, definition). A transition policy is a
declared, recorded object: a name, its parameters, and the
epoch it governs. Given the current state and view, a policy
derives a delta and a list of view edits. Nothing about a
derivation is implicit: the receipt records the policy's
name, parameters, and epoch, and each derived item's premise
cone — the view entries and state coordinates it was derived
from.

6.2 (settled intent, definition). A view edit is one of four
typed operations on the view's schema or the policy's
scoring, each recorded with its target and premise cone:
retune (change a named parameter or an axis weight), add an
axis, drop an axis, replace an axis. An axis is a named
component of the schema's categories or of the policy's
scoring function. The concrete axis vocabulary is fixed by
the first executable loop and appended here as a dated
amendment when it lands (proposed; owner: the executable
lane's first run, recorded by this lane).

6.3 (settled intent, definition). One recurrence step: from
state, view, and policy — derive the delta and view edits;
check the delta's admissibility and refuse by name on
failure, changing nothing; apply the delta to the editable
copy and record the receipt (section 7); construct the next
view from the edited state and the edited evidence; verify
the next view independently — a second derivation path or
the checker lane's recomputation — before it feeds the
following step. The epoch strictly increases with each
accepted step. A refused step does not advance the epoch and
leaves state and view untouched.

6.4 (verified at the abstract level). The cycle control: a
policy sequence whose composed delta is a delta followed by
its own recorded inverse returns the state exactly — this is
4.1 read as the control. At the byte level the control is a
hash equality after the cycle (4.2), run by the executable
lane and checked by the independent lane.

6.5 (proposed, contract). Incremental agreement: where an
implementation maintains a view incrementally, the
maintained view equals the clean recomputation from the
edited bytes, at every step. 5.3 is what makes this check
well-defined. Obligation: on the executable lane per step,
verified by the independent lane from receipts; no
incremental figure is claimed until that check has run.

## 7. Receipts

7.1 (settled intent, contract). Every edit records: the
presentation (checkpoint hash), the source hash of the
editable copy before the edit and its hash after, the
affected coordinates, the protected bytes statement, the
constraints in force (the protection list's identity, the
range, the tie relation's identity), the policy's name,
parameters, and epoch, the before and after views, the
admissibility verdict per condition of 3.1, and the reversal
check result of 4.2. A receipt missing a field is not a
receipt; the independent lane treats it as no evidence.

## 8. What the semantics does not claim

8.1 (settled). No behavioral claim follows from any of the
above. A delta's behavioral effect is established only under
a stated model or against independent held-out evidence, per
claim, and until then prints as unknown. The first candidate
behavioral claim in this program — a paired sign flip on a
value row and output column preserving scoped attention
behavior in exact arithmetic, with unpaired edits and stale
caches as controls — is BLOCKED: its fixtures are not on
this machine (census, program record). The semantics is
ready for it; the evidence is not here.

8.2 (proof-owed). The value type of the abstract core is the
integers: it models the symbol layer exactly. A presentation
with a per-tensor scale multiplies every value in the tensor
by that scale. Obligation O-scale: transport the core's
theorems through a fixed nonzero scale per tensor — expected
to be a congruence argument, since the scale is one exactly
representable scalar per tensor — or restate the core over
exact rationals. Owner: this lane, next theorem wave. Until
discharged, every PROVED mark above reads at the symbol
layer, and the spec says so wherever it matters (4.2's byte
form is unaffected: hashes do not pass through the value
type).

8.3 (proof-owed). Obligation O-schema: the per-schema check
named in 5.3. Obligation O-tie-evidence: a stated method by
which a tie claim about a concrete checkpoint is evidenced
rather than asserted — the natural form is a paired-edit
experiment whose controls are the unpaired edits; it rides
on the same fixtures as 8.1 and is blocked with them.
