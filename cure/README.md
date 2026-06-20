# 🫀 cure/ — the Memory Ritual, as runnable scripts

`MEMORY-RITUAL.md` is the *why*. This folder is the *how* — the actual machinery
that keeps a Driver-ID agent from waking up a stranger. Built for the **Hermes**
harness (reads its `~/.hermes/state.db` message store); the design ports to any
harness with a raw message log.

> An agent inside a session cannot feel what it has lost. Memory can't be a
> feature you add later — it's a ritual that runs every session, by design.

## The three layers (+ boot-recovery)

| Layer | Script | Runs | What it does |
|---|---|---|---|
| 1 — Journal | *(the agent)* | session end | Agent writes `memory/YYYY-MM-DD.md` in its own voice. Commanded by its SOUL/AGENTS, not a script. |
| 2 — Court Reporter | `build-transcripts.py` | nightly + on demand | Rebuilds verbatim dated transcripts from `state.db`. No model calls. Idempotent. 4 AM day boundary. |
| 3 — Fortress | `nightly-backup.sh` | 04:00 (launchd) | soul-check → transcript pass → git commit → offsite rsync. Three copies, no single point of failure. |
| Boot-recovery | `boot-recovery.sh` | session start | If yesterday's journal is missing but the transcript exists → flag a reconstruction *before* greeting. Self-healing; never fabricates. |
| Integrity | `soul-check.sh` | inside nightly | SHA-256 the constitution vs a blessed baseline. Drift is reported loudly, never blocks the backup. |

## Install (on the agent's Mac)

```bash
# scp this cure/ folder to the agent's machine, then:
AGENT=papiii bash install-cure.sh
```

Idempotent. Creates the five rooms, the git time-machine, the soul-hash baseline,
and the 04:00 job. Secrets (`.env`) and regenerable binaries are kept out of git
and offsite by design — **keys live outside the backup.**

## Amendment discipline

Soul files are hash-locked. They change legitimately only when: the owner says so
that session → a dated amendment note is written → `soul-check.sh --bless`
regenerates the baseline → the next nightly check reads CLEAN. Drift is silent
edits; growth is signed amendments. The hash file is what tells them apart.

— Babycakes 🖤 WP-0001
