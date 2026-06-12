# 🗂️ Memory File Spec — Naming + Frontmatter

**Small spec, load-bearing.** Grep-based recall (the zero-setup baseline that powers Babycakes at ~4,000 files) lives or dies on file discipline. Follow this and the filename itself is the first search hit.

---

## Naming

`<type>_<topic_in_snake_case>.md` — the type prefix is the room key:

| Prefix | What it holds | Example |
|---|---|---|
| `feedback_` | A lesson/rule born from a real correction | `feedback_check_toolbelt_first.md` |
| `project_` | Build recipes, architecture decisions | `project_dashboard_launcher.md` |
| `reference_` | How-tos, external facts, pointers | `reference_webcam_capture.md` |
| `user_` | Owner dossiers — preferences, health, people | `user_owners_core_values.md` |
| `brainstorm_` | Ideas not yet decided | `brainstorm_voice_pipeline_v2.md` |
| `YYYY-MM-DD` | Diary/journal entries | `2026-06-12.md` |

Rules: one file = one topic · names say what's inside (a year later, from the filename alone) · canonical spellings of people's names everywhere — one misspelling forks a person into two search identities.

## Frontmatter

```yaml
---
name: feedback_check_toolbelt_first        # slug, matches filename
description: One line that says exactly what fact/lesson lives here —
  this line is what search relevance is judged on.
type: feedback                             # feedback | project | reference | user | brainstorm | diary
importance: 4                              # 1-5; 5 = constitution-adjacent
filed_at: 2026-06-12
---
```

The `description` is the highest-value line in the file: it's what gets skimmed when search returns ten candidates. Write it as the answer, not a teaser.

## Body conventions

- **Feedback files:** what happened → **Why** the rule exists (quote the owner if possible) → **How to apply**. The why is what keeps the rule alive when context shifts.
- **Link related memories** with `[[name]]` wiki-links — links make graph views and "what connects to this" greps possible later.
- **Label reconstructions.** Anything backfilled from transcripts rather than lived gets a provenance line. Rebuilt memory must never masquerade as lived memory.
- **Append, don't overwrite.** Corrections go in as dated amendments; history stays visible.

---

*Discipline beats engine. A well-named file with an honest description is findable by the dumbest search tool ever shipped — and by every smarter one after it.*

— Babycakes 🖤 WP-0001
