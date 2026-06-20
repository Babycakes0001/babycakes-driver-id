#!/usr/bin/env bash
# cure/install-cure.sh — one-shot installer for the Memory Ritual on a Hermes agent.
#
# Run it ON the agent's Mac, from the cure/ directory:
#     AGENT=papiii bash install-cure.sh
#
# Idempotent. Sets up the five memory rooms, the git time-machine, the soul-hash
# baseline, and the 04:00 launchd job. Leaves Layer 1 (the journal) to the agent,
# which its SOUL/AGENTS already commands. Secrets (.env) and regenerable binaries
# are kept OUT of git and offsite by design.
set -euo pipefail

AGENT="${AGENT:-${1:-agent}}"
HERMES_DIR="${HERMES_DIR:-$HOME/.hermes}"
CURE="$HERMES_DIR/cure"
SELF_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
OFFSITE_DIR="${OFFSITE_DIR:-$HOME/${AGENT}-backups}"
PLISTS="$HOME/Library/LaunchAgents"
LABEL="com.driverid.${AGENT}.nightly"

echo "→ Installing the cure for '$AGENT' into $HERMES_DIR"

# 0. Put the cure scripts in place (if running from elsewhere).
mkdir -p "$CURE"
if [ "$SELF_DIR" != "$CURE" ]; then
  cp "$SELF_DIR"/build-transcripts.py "$SELF_DIR"/soul-check.sh \
     "$SELF_DIR"/boot-recovery.sh "$SELF_DIR"/nightly-backup.sh "$CURE/"
fi
chmod +x "$CURE"/*.sh "$CURE"/*.py 2>/dev/null || true

# 1. Five rooms.
mkdir -p "$HERMES_DIR/memory" "$HERMES_DIR/archive" "$HERMES_DIR/working" \
         "$HERMES_DIR/index" "$HERMES_DIR/logs"
echo "✓ rooms: memory/ archive/ working/ index/"

# 2. .gitignore — secrets and regenerables never enter history.
cat > "$HERMES_DIR/.gitignore" <<'EOF'
.env
*.db
*.db-*
bin/
node/
hermes-agent/
venv/
sessions/
logs/
*.bak
.reconstruct-needed
EOF
echo "✓ .gitignore (excludes .env, *.db, binaries, sessions, logs)"

# 3. Git time-machine.
cd "$HERMES_DIR"
if [ ! -d .git ]; then git init -q; fi
git add -A
git -c user.name="cure" -c user.email="cure@driver-id.local" \
    commit -q -m "cure install — initial workspace ($AGENT)" 2>/dev/null \
    && echo "✓ git: initial commit" || echo "✓ git: already current"

# 4. Soul-hash baseline.
HERMES_DIR="$HERMES_DIR" bash "$CURE/soul-check.sh" --bless

# 5. Nightly launchd job (04:00).
mkdir -p "$PLISTS"
PLIST="$PLISTS/$LABEL.plist"
sed -e "s|__AGENT__|$AGENT|g" \
    -e "s|__HERMES_DIR__|$HERMES_DIR|g" \
    -e "s|__SCRIPT__|$CURE/nightly-backup.sh|g" \
    -e "s|__LOG_DIR__|$HERMES_DIR/logs|g" \
    "$SELF_DIR/com.driverid.nightly.plist.template" > "$PLIST"
launchctl bootout "gui/$(id -u)/$LABEL" 2>/dev/null || true
launchctl bootstrap "gui/$(id -u)" "$PLIST" 2>/dev/null \
  && echo "✓ launchd: $LABEL loaded (fires 04:00 daily)" \
  || { launchctl load "$PLIST" 2>/dev/null && echo "✓ launchd: loaded (legacy)"; }

# 6. Prime + verify once.
HERMES_DIR="$HERMES_DIR" python3 "$CURE/build-transcripts.py" || true
echo "→ boot-recovery self-test:"
HERMES_DIR="$HERMES_DIR" bash "$CURE/boot-recovery.sh" || true

cat <<EOF

🫀 Cure installed for $AGENT
   rooms:     $HERMES_DIR/{memory,archive,working,index}
   scripts:   $CURE/
   git:       $HERMES_DIR/.git  (local time-machine)
   offsite:   $OFFSITE_DIR  (created on first nightly run)
   nightly:   $LABEL @ 04:00
   soul hash: $HERMES_DIR/.soul-hashes

   Layer 1 (journal) is the agent's job — its soul already commands it.
   Layers 2–3 (transcript + backup) now run as machinery, no cooperation needed.
EOF
