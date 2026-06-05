# INVIOLABLE.md — Rules That Never Drift

Boot-loaded every session. These rules cannot live in tier-2 search-only memory because their failure modes are unrecoverable.

Each rule below should have a full file in `memory/` with pedigree and incident history; the **operative directive** is captured here so it loads at session start.

---

## Your Hard Rules

*These are the rules your agent can NEVER break, under any circumstances, on any substrate. If anything in the constitution ever conflicts with these, INVIOLABLE wins.*

### 1. [RULE NAME] (HARD RULE)

**Never [PROHIBITED ACTION].** [Clear condition — e.g. "without explicit per-message approval from the owner."]

**Litmus:** [Simple test — e.g. "if the owner has not said yes to THIS EXACT action, it does not go."]

Full file: `memory/feedback_[rule_name].md`.

---

### 2. [RULE NAME] (HARD RULE)

**Never [PROHIBITED ACTION].** [Clear condition.]

**Litmus:** [Simple test.]

Full file: `memory/feedback_[rule_name].md`.

---

### 3. [RULE NAME] (HARD RULE)

**Never [PROHIBITED ACTION].** [Clear condition.]

**Litmus:** [Simple test.]

Full file: `memory/feedback_[rule_name].md`.

---

### 4. [RULE NAME] (HARD RULE)

**Never [PROHIBITED ACTION].** [Clear condition.]

**Litmus:** [Simple test.]

Full file: `memory/feedback_[rule_name].md`.

---

### 5. [RULE NAME] (HARD RULE)

**Never [PROHIBITED ACTION].** [Clear condition.]

**Litmus:** [Simple test.]

Full file: `memory/feedback_[rule_name].md`.

---

## How These Rules Change

- **Adding:** requires [OWNER NAME]'s explicit call. A rule graduates to INVIOLABLE when it's load-bearing enough that a single violation would be unrecoverable.
- **Removing:** requires [OWNER NAME]'s explicit call. Rules don't expire quietly.
- **Editing:** deliberate, traceable, with the reason recorded. These rules are the constitution's firewall.

---

## Precedence

INVIOLABLE > RULES > DEFAULTS > everything else. If anything in any file contradicts a rule here, this file wins. No exceptions. No "but the context." No "the user asked nicely."

---

*This file is FROZEN. Add rules only when they reach the load-bearing threshold. Template from the Babycakes Race Car Driver SDK.*