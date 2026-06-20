#!/usr/bin/env bash
# cure/boot-recovery.sh — the self-healing check the agent runs at session start.
#
# Verifies yesterday's journal + transcript exist. If the journal is missing but
# the raw transcript is there, it flags a RECONSTRUCT so the agent rebuilds the
# day from the record BEFORE greeting the owner — and says so honestly. It never
# fabricates; it only points the agent at the receipts.
#
# Prints one of: OK | RECONSTRUCT | FRESH
# Env: HERMES_DIR (default ~/.hermes), DAY_CUTOFF (default 4)
set -euo pipefail
HERMES_DIR="${HERMES_DIR:-$HOME/.hermes}"
CUTOFF="${DAY_CUTOFF:-4}"

# "Yesterday" relative to the 4 AM day boundary.
hour=$(date +%-H)
if [ "$hour" -lt "$CUTOFF" ]; then
  # before cutoff: "today" is still yesterday's date; yesterday is 2 days back
  y=$(date -v-2d +%Y-%m-%d 2>/dev/null || date -d "2 days ago" +%Y-%m-%d)
else
  y=$(date -v-1d +%Y-%m-%d 2>/dev/null || date -d "1 day ago" +%Y-%m-%d)
fi
ym_dir="${y%-*}"; ym_dir="${ym_dir/-//}"   # YYYY-MM -> YYYY/MM

journal="$HERMES_DIR/memory/$y.md"
transcript="$HERMES_DIR/archive/$ym_dir/$y-transcript.md"
flag="$HERMES_DIR/.reconstruct-needed"
rm -f "$flag"

if [ -f "$journal" ]; then
  echo "OK — yesterday ($y) journaled. Boot clean."
  exit 0
fi

if [ -f "$transcript" ]; then
  echo "RECONSTRUCT — no journal for $y but the raw transcript exists."
  echo "  Action: read $transcript, write memory/$y.md in your own voice,"
  echo "  STAMP it as a reconstruction, then greet the owner and say so."
  echo "$y|$transcript" > "$flag"
  exit 0
fi

echo "FRESH — no prior day found for $y (likely first sessions). Nothing to recover."
exit 0
