#!/usr/bin/env bash
# cure/nightly-backup.sh — Layer 3, the fortress. Pure machinery, no model calls.
#
# Runs at 04:00 via launchd. Order matches MEMORY-RITUAL.md:
#   1. SOUL CHECK   — hash-verify constitution (log-only)
#   2. TRANSCRIPT   — rebuild today's readable transcripts from state.db
#   3. GIT COMMIT   — local time-machine commit of the memory workspace
#   4. OFFSITE      — rsync a second copy to <agent>-backups (keys excluded by .gitignore)
#
# Three copies: working disk, git history, offsite folder. Nothing rides on one.
# Env: HERMES_DIR (default ~/.hermes), OFFSITE_DIR (default ~/<basename>-backups)
set -uo pipefail
HERMES_DIR="${HERMES_DIR:-$HOME/.hermes}"
OFFSITE_DIR="${OFFSITE_DIR:-$HOME/$(basename "$HERMES_DIR" | sed 's/^\.//')-backups}"
CURE="$HERMES_DIR/cure"
LOG_DIR="$HERMES_DIR/logs"; mkdir -p "$LOG_DIR"
LOG="$LOG_DIR/cure-nightly.log"
PY="$(command -v python3 || echo /usr/bin/python3)"

stamp() { date '+%Y-%m-%d %H:%M:%S'; }
log() { echo "[$(stamp)] $*" | tee -a "$LOG"; }

log "=== nightly cure run start ==="

# 1. SOUL CHECK (never blocks)
HERMES_DIR="$HERMES_DIR" bash "$CURE/soul-check.sh" 2>&1 | tee -a "$LOG" || true

# 2. TRANSCRIPT PASS
HERMES_DIR="$HERMES_DIR" "$PY" "$CURE/build-transcripts.py" 2>&1 | tee -a "$LOG" || log "transcript pass FAILED (continuing)"

# 3. GIT COMMIT (memory workspace only; .gitignore keeps secrets/binaries out)
cd "$HERMES_DIR" || { log "cannot cd $HERMES_DIR"; exit 1; }
if [ ! -d .git ]; then
  git init -q && log "git initialized"
fi
git add -A 2>>"$LOG"
if git diff --cached --quiet 2>/dev/null; then
  log "git: nothing changed"
else
  git -c user.name="cure" -c user.email="cure@driver-id.local" \
      commit -q -m "nightly cure — $(date +%Y-%m-%d)" 2>>"$LOG" && log "git: committed"
fi

# 4. OFFSITE (second medium). Mirrors the working tree minus the ignored set.
mkdir -p "$OFFSITE_DIR"
rsync -a --delete \
  --exclude '.env' --exclude '*.db' --exclude '*.db-*' \
  --exclude 'bin/' --exclude 'node/' --exclude 'hermes-agent/' \
  --exclude 'venv/' --exclude 'sessions/' --exclude 'logs/' \
  "$HERMES_DIR/" "$OFFSITE_DIR/" 2>>"$LOG" && log "offsite: synced → $OFFSITE_DIR" || log "offsite: rsync FAILED"

log "=== nightly cure run done ==="
exit 0
