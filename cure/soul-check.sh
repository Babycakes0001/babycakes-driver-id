#!/usr/bin/env bash
# cure/soul-check.sh — hash-verify the constitution (log-only; never blocks).
#
# Layer 3, step 1 of the nightly chain. Computes SHA-256 over the agent's soul
# files and compares to a blessed baseline. Drift = a soul file changed without
# a re-bless. It REPORTS loudly; it never edits, never blocks the backup.
#
# Usage:
#   soul-check.sh            # verify against baseline; print CLEAN / DRIFT
#   soul-check.sh --bless    # (re)generate the baseline after a signed amendment
#
# Env: HERMES_DIR (default ~/.hermes)
set -euo pipefail
HERMES_DIR="${HERMES_DIR:-$HOME/.hermes}"
HASHES="$HERMES_DIR/.soul-hashes"

# Soul files to guard (whichever exist).
CANDIDATES=("SOUL.md" "AGENTS.md")
FILES=()
for f in "${CANDIDATES[@]}"; do
  [ -f "$HERMES_DIR/$f" ] && FILES+=("$f")
done

hash_one() { shasum -a 256 "$HERMES_DIR/$1" | awk '{print $1}'; }

if [ "${1:-}" = "--bless" ]; then
  : > "$HASHES"
  for f in "${FILES[@]}"; do echo "$(hash_one "$f")  $f" >> "$HASHES"; done
  echo "soul-check: blessed $(wc -l < "$HASHES" | tr -d ' ') file(s) → $HASHES"
  exit 0
fi

if [ ! -f "$HASHES" ]; then
  echo "soul-check: NO BASELINE yet — run 'soul-check.sh --bless' once. (not blocking)"
  exit 0
fi

drift=0
while read -r want f; do
  [ -z "${f:-}" ] && continue
  if [ ! -f "$HERMES_DIR/$f" ]; then
    echo "soul-check: ⚠ MISSING $f"; drift=1; continue
  fi
  got="$(hash_one "$f")"
  if [ "$got" != "$want" ]; then
    echo "soul-check: ⚠ DRIFT in $f (changed since last bless)"; drift=1
  fi
done < "$HASHES"

if [ "$drift" = 0 ]; then
  echo "soul-check: ✓ CLEAN — constitution matches baseline."
else
  echo "soul-check: ⚠ drift reported above. If the change was intentional, re-bless; if not, investigate. (not blocking backup)"
fi
exit 0
