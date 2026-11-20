#!/bin/sh
# Family check gate, widened: covers every Lean file in the tree
# recursively, rejects every proof escape token, compiles with
# warnings as errors, prints axiom dependencies per theorem, and
# fails if any printed axiom lies outside the allowed set
# {propext, Classical.choice, Quot.sound}.
set -eu
cd "$(dirname "$0")"
LEAN="${LEAN:-lean}"
export LEAN_PATH=".:${LEAN_PATH:-}"
LOG="CHECK.log"
: > "$LOG"

# Reject source admissions and escape hatches, in every .lean file
# in the tree, subfolders included.
FILES="$(find . -name '*.lean' | sort)"
if grep -En '(^|[^[:alnum:]_])(sorry|admit|axiom|native_decide|implemented_by|extern|unsafe|opaque|partial)([^[:alnum:]_]|$)' $FILES; then
  echo "Rejected prohibited proof escape hatch" >> "$LOG"
  cat "$LOG" >&2
  exit 1
fi

"$LEAN" --version >> "$LOG" 2>&1

# Compile every .lean file, retrying deferred files so that
# importers are compiled after the modules they import.
TMPD="$(mktemp -d)"
trap 'rm -rf "$TMPD"' EXIT HUP INT TERM
REMAINING="$FILES"
PASSES=0
while [ -n "$REMAINING" ]; do
  PASSES=$((PASSES + 1))
  if [ "$PASSES" -gt 10 ]; then
    echo "Rejected: could not compile every Lean file" >> "$LOG"
    cat "$LOG"
    exit 1
  fi
  NEXT=""
  PROGRESS=0
  for f in $REMAINING; do
    base="$(basename "$f" .lean)"
    if "$LEAN" -DwarningAsError=true -o "$base.olean" "$f" > "$TMPD/out" 2>&1; then
      cat "$TMPD/out" >> "$LOG"
      PROGRESS=1
    else
      cp "$TMPD/out" "$TMPD/last"
      NEXT="$NEXT $f"
    fi
  done
  if grep -Eq 'sorryAx|error:|warning:' "$LOG"; then
    echo "Rejected checker diagnostics/admitted axiom" >> "$LOG"
    cat "$LOG"
    exit 1
  fi
  REMAINING="$NEXT"
  if [ -n "$REMAINING" ] && [ "$PROGRESS" -eq 0 ]; then
    cat "$TMPD/last" >> "$LOG"
    echo "Rejected: Lean compilation failed" >> "$LOG"
    cat "$LOG"
    exit 1
  fi
done

# Axiom audit enforced by the gate: every axiom printed for any
# theorem must lie in the allowed set.
PRINTED="$(grep -c 'depends on axioms' "$LOG" || true)"
if [ "$PRINTED" -eq 0 ]; then
  echo "Rejected: no axiom printouts found" >> "$LOG"
  cat "$LOG"
  exit 1
fi
USED="$(sed -n 's/.*depends on axioms: \[\([^]]*\)\].*/\1/p' "$LOG" | tr ',' '\n' | sed 's/^ *//; s/ *$//' | sort -u)"
for a in $USED; do
  case "$a" in
    propext|Classical.choice|Quot.sound) ;;
    *)
      echo "Rejected: axiom outside the allowed set: $a" >> "$LOG"
      cat "$LOG"
      exit 1
      ;;
  esac
done
echo "Axiom subset check passed: printed axioms are a subset of {propext, Classical.choice, Quot.sound}" >> "$LOG"
echo "Axioms printed: $(echo $USED | tr '\n' ' ')" >> "$LOG"
cat "$LOG"
