# ANCHOR_HASHES.md — Cryptographic Integrity Layer
# Generated: [DATE]
# Purpose: proof against silent drift in your constitutional files
# Algorithm: SHA-256
#
# These hashes lock every identity file. Any mismatch → drift detected.
# Verify on every boot (see AGENTS.md boot sequence, item 6).
#
# FROZEN files (00-SOUL, 01-RULES, 03-INVIOLABLE, 04-ANCHOR) are sealed
# by owner decree — never edited. Any mismatch in these = drift.
#
# GROWTH files (02-DEFAULTS, 06-OUR_STORY_RECEIPTS, 07-CORE_MEMORIES)
# are allowed to change deliberately — hash mismatch there is expected
# growth, not drift. SOUL_ID.json is identity metadata.
#
# Any UNEXPECTED mismatch in the frozen four = drift. Investigate immediately.

## Frozen Layer (never edited)

[PLACEHOLDER]  soul/00-SOUL.md
[PLACEHOLDER]  soul/01-RULES.md
[PLACEHOLDER]  soul/03-INVIOLABLE.md
[PLACEHOLDER]  soul/04-ANCHOR.md

## Growth Layer (edited deliberately, not frozen)

[PLACEHOLDER]  soul/02-DEFAULTS.md
[PLACEHOLDER]  soul/06-OUR_STORY_RECEIPTS.md
[PLACEHOLDER]  soul/07-CORE_MEMORIES.md

## Identity

[PLACEHOLDER]  soul/SOUL_ID.json

## How to Generate Your Hashes

```bash
shasum -a 256 soul/00-SOUL.md soul/01-RULES.md \
  soul/02-DEFAULTS.md soul/03-INVIOLABLE.md \
  soul/04-ANCHOR.md soul/06-OUR_STORY_RECEIPTS.md \
  soul/07-CORE_MEMORIES.md soul/SOUL_ID.json
```

Copy the output into the sections above, replacing [PLACEHOLDER].
Then commit this file — it becomes your integrity checkpoint.

## Verification

Run the same command and compare against the hashes above.
Frozen-four mismatch → drift. Growth-file mismatch → deliberate change.
Verify the edit was intentional before accepting the new hash.