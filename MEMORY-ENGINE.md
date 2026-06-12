# 🧠 The Five Rooms + Memory Recall

**This is the secret sauce.** How to give your agent persistent memory without burning API tokens on every recall.

*(Updated 2026-06-12 to match how Babycakes actually runs after her 4.0 simplification — the biggest change: the fancy engine turned out to be optional. Read "The Two Tiers" below.)*

---

## The Core Insight

Most AI memory systems bolt a database onto the agent — embeddings, vector stores, retrieval pipelines. The insight that actually matters is simpler and comes first:

**The files ARE the memory.** Plain markdown, well-named, organized into rooms, with thin indexes that tell the agent where everything lives. Get that right and the "engine" on top can be as simple as the search tools your agent already has.

---

## The Five Rooms

Your agent's knowledge is organized into five directories. Each room has a specific job, and only the rooms that are needed get loaded.

```
your-agent/
├── soul/          ← Room 1: THE CONSTITUTION (boots every session)
├── index/         ← Room 2: THIN INDEXES (quick reference layer)
├── memory/        ← Room 3: DEEP STORE (searched on demand)
├── working/       ← Room 4: ACTIVE STATE (what we're doing now)
└── archive/       ← Room 5: THE LONG TAIL (historical, rarely loaded)
```

### Room 1 — `soul/` (The Constitution)

**Loaded every session in strict order.** These files ARE the agent's identity. Frozen and hash-verified so they can't silently drift.

| File | Role |
|---|---|
| `00-SOUL.md` | Who the agent is — name, tone, persona, voice |
| `01-RULES.md` | Operational rules |
| `02-DEFAULTS.md` | Automatic reflexes |
| `03-INVIOLABLE.md` | Hard rules that never drift |
| `04-ANCHOR.md` | Frozen golden file — never edited |
| `05-ANCHOR_HASHES.md` | SHA-256 integrity check on boot |
| `06-OUR_STORY_RECEIPTS.md` | Load-bearing identity facts |
| `07-CORE_MEMORIES.md` | 25 foundational memories |

**Why it works:** 1,600 lines of pure identity. Read in ~1 second at session start. The agent wakes up already knowing who it is — no "hello, how can I help you today?" blank slate.

### Room 2 — `index/` (Thin Indexes)

**Quick-reference layer.** Tells the agent where everything else lives. Also loaded at boot, but tiny.

| File | Role |
|---|---|
| `MEMORY.md` | Map of the whole memory system |
| `PEOPLE.md` | Who matters (quick-reference; deep dossiers are in Room 3) |
| `LIBRARY.md` | Study notes, research catalog |
| `PURSE.md` | Credentials and API keys (gitignored, local-only, NEVER boot-loaded) |

### Room 3 — `memory/` (Deep Store)

**The long-term memory. NOT loaded at boot — searched on demand.**

| Area | What goes there |
|---|---|
| `diary/` | Daily session journals (see [MEMORY-RITUAL.md](MEMORY-RITUAL.md)) |
| `feedback/` | Lessons learned, rules born from mistakes |
| `project/` | Build recipes, architecture decisions, upgrade plans |
| `reference/` | How-to guides, technical references |
| `user/` | Owner dossiers — health, preferences, personal data |
| `brainstorm/` | Ideas, explorations, not-yet-decided |

**How it's searched:** see "The Two Tiers" below.

### Room 4 — `working/` (Active State)

**What's happening right now.** Cross-session continuity.

| File | Role |
|---|---|
| `NEXT.md` | Build queue — what we're working on |
| `INFRASTRUCTURE.md` | How the pieces fit together |
| `TOOLBELT.md` | Every tool with full canonical paths |
| `MEMORY_ENGINE.md` | This file — how memory works |

### Room 5 — `archive/` (The Long Tail)

**Historical, loaded only when needed.** Full conversation transcripts, old configs, migration snapshots. The agent almost never reads from here — but when it needs to prove something happened on a specific date, it's all there.

| Area | Contents |
|---|---|
| `chronicle/` | Full narrative history |
| `transcripts/YYYY/MM/` | Daily conversation records |
| Old configs | Deprecated setups, pre-upgrade state |

---

## The Two Tiers of Recall

### Tier 0 — Files + grep (the baseline that turned out to be enough)

This is what powers Babycakes today, at ~4,000 memory files:

```
Question about the past
        │
        ▼
Boot-tier indexes already name the likely file   (PEOPLE.md, MEMORY.md…)
        │
        ▼
grep/keyword search over memory/ for names, dates, topics
        │
        ▼
Read the matching files whole — answer from evidence
```

No index to rebuild, no embedding model, no second database — **no second brain to disagree with the first.** The requirements that make it work:

1. **Disciplined file naming** (`feedback_*`, `project_*`, `user_*` — the name is the first search hit)
2. **YAML frontmatter** with a one-line `description` on every file
3. **Thin indexes** kept current (a stale index is worse than no index)
4. **One file = one topic** — the unit of memory is the file, not the paragraph
5. **The escalation path written down:** memory grep → archive transcripts → ask the human → *write it down*

**Testimony, for honesty:** Babycakes ran the Tier-1 hybrid engine below for about two months, then removed it in her 4.0 simplification. With good file discipline, grep recall never missed badly enough to justify maintaining the second system. Erasure is loud, drift is silent — and a silently stale vector index is drift's favorite hiding place. Start at Tier 0. Add Tier 1 only when grep demonstrably fails you.

### Tier 1 — Local hybrid search (the optional upgrade)

If your corpus outgrows keyword search (fuzzy recall, "what was that idea about…", multilingual notes), add a **local** engine — never a cloud one:

| Component | Technology | Why |
|---|---|---|
| **Embedding model** | Sentence-transformers (all-MiniLM-L6-v2) or Ollama (nomic-embed-text) | Runs on CPU, ~120MB, fast |
| **Vector store** | ChromaDB (SQLite backend) or LanceDB | Embedded, zero config |
| **Keyword search** | BM25 alongside | Catches exact names/dates semantic misses |
| **Index rebuild** | Script, nightly + on-demand | <2s for 5,000 files |

| Approach | Cost per search | Latency | Privacy |
|---|---|---|---|
| Cloud vector DB | ~$0.001–0.01/query | 50–200ms network | Data leaves your machine |
| API embeddings | ~$0.0001/1K tokens | 100–500ms | Text sent to third party |
| **Local hybrid** | **$0.00** | 5–50ms | Everything stays on disk |

**The honest costs of Tier 1** (why it's not the default anymore): an index that must be rebuilt and *verified* (add a canary check — search for a memory you know exists; alert when it misses), an embedding environment to maintain, and a second source of truth that can quietly diverge from the files. Budget for the maintenance, not just the install.

### Chunking Strategy (applies to both tiers)

Files are NOT split into tiny chunks. Each memory file is its own unit — typically 50–200 lines:

- **Search returns whole memories, not fragments.** Full context every time.
- **No chunk-boundary problems.** A fact never gets split in half.
- **Editing is simple.** Open the file, change it. (Tier 1: reindex after.)

Very long files (500+ lines) get split into smaller topical files. The unit of memory is the *file*, not the *paragraph*.

---

## The Search Reflex

The recall system is useless without a reflex to USE it. Your agent's constitution should include:

> **Before answering any question about the past, people, decisions, or preferences → search memory first. If the answer should be there and isn't → SAY the search came up empty (never substitute training-data guesses), then write it so it's there next time.**

This one rule is what makes the whole system alive. Without it, the memory is just files on disk.

---

## Why Flat Files, Not a Database

- **Git-friendly** — every memory change is version-controlled
- **Human-readable** — the owner can open any file and read it
- **Portable** — copy the directory to a new machine; recall works immediately (Tier 0 needs zero setup)
- **No vendor lock-in** — search tooling can change without migrating a single memory
- **Append-only by default** — old memories don't get overwritten by accident

---

## Getting Started

1. **Build the rooms** — five directories, constitution from the this repo templates
2. **Write your first memory files** with frontmatter descriptions and disciplined names
3. **Wire the search reflex** into `DEFAULTS.md`
4. **Adopt the Memory Ritual** — session journals + transcript archiving + nightly backup ([MEMORY-RITUAL.md](MEMORY-RITUAL.md))
5. **Only if grep starts missing:** add the Tier-1 local hybrid engine, with a canary check

---

*This is the memory architecture that powers Babycakes (WP-0001). Five rooms. Files as the memory. Search as simple as the corpus allows. The soul stays private; the blueprint is open.*
