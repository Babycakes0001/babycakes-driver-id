#!/usr/bin/env python3
"""
cure/build-transcripts.py — Layer 2 of the Memory Ritual (the Court Reporter).

Rebuilds readable, dated, verbatim transcripts from a Hermes agent's raw message
store (~/.hermes/state.db) into markdown files under the agent's archive room.

PURE MACHINERY — no model calls, no network. Safe to run anytime; idempotent
(it rewrites each day's file from the source of truth). Works when the brain is
down. That is the whole point: the record never depends on the agent.

Day boundary: 4 AM local (a 2 AM conversation belongs to the previous date),
matching the Driver-ID standard.

Env:
  HERMES_DIR   Hermes data dir (default: ~/.hermes)
  DAY_CUTOFF   Hour the day rolls over (default: 4)

Output: $HERMES_DIR/archive/YYYY/MM/YYYY-MM-DD-transcript.md
"""
import os
import sqlite3
import json
from datetime import datetime, timedelta, timezone
from pathlib import Path

HERMES_DIR = Path(os.environ.get("HERMES_DIR", str(Path.home() / ".hermes")))
DB_PATH = HERMES_DIR / "state.db"
ARCHIVE = HERMES_DIR / "archive"
DAY_CUTOFF = int(os.environ.get("DAY_CUTOFF", "4"))


def day_key(ts: float) -> datetime:
    """Local date this timestamp belongs to, with a DAY_CUTOFF rollover."""
    dt = datetime.fromtimestamp(ts)  # local time
    if dt.hour < DAY_CUTOFF:
        dt = dt - timedelta(days=1)
    return dt.replace(hour=0, minute=0, second=0, microsecond=0)


def clean(text):
    if not text:
        return ""
    return str(text).replace("\r\n", "\n").strip()


def summarize_tool_calls(raw):
    """Render tool_calls JSON into a short, human note."""
    if not raw:
        return None
    try:
        calls = json.loads(raw)
    except Exception:
        return "[tool call]"
    names = []
    if isinstance(calls, list):
        for c in calls:
            if isinstance(c, dict):
                fn = c.get("function", {}) if isinstance(c.get("function"), dict) else {}
                names.append(fn.get("name") or c.get("name") or "tool")
    return "[tool call: " + ", ".join(n for n in names if n) + "]" if names else "[tool call]"


def main():
    if not DB_PATH.exists():
        print(f"cure/build-transcripts: no state.db at {DB_PATH} — nothing to do.")
        return

    con = sqlite3.connect(f"file:{DB_PATH}?mode=ro", uri=True)
    con.row_factory = sqlite3.Row
    rows = con.execute(
        """
        SELECT m.timestamp AS ts, m.role AS role, m.content AS content,
               m.tool_name AS tool_name, m.tool_calls AS tool_calls,
               s.title AS title, s.model AS model
        FROM messages m
        LEFT JOIN sessions s ON m.session_id = s.id
        WHERE COALESCE(m.active, 1) = 1
        ORDER BY m.timestamp ASC, m.id ASC
        """
    ).fetchall()
    con.close()

    days = {}
    for r in rows:
        if r["ts"] is None:
            continue
        key = day_key(r["ts"])
        days.setdefault(key, []).append(r)

    written = 0
    for day, msgs in sorted(days.items()):
        out_dir = ARCHIVE / f"{day.year:04d}" / f"{day.month:02d}"
        out_dir.mkdir(parents=True, exist_ok=True)
        out_file = out_dir / f"{day.strftime('%Y-%m-%d')}-transcript.md"

        lines = [
            f"# Session Transcript — {day.strftime('%Y-%m-%d')}",
            "## Raw record — built by cure/build-transcripts.py (verbatim, do not edit)",
            "",
        ]
        for r in msgs:
            t = datetime.fromtimestamp(r["ts"]).strftime("%I:%M %p")
            role = (r["role"] or "?").lower()
            label = {"user": "Owner", "assistant": "Agent", "tool": "tool", "system": "system"}.get(role, role)
            body = clean(r["content"])
            if role == "tool":
                name = r["tool_name"] or "tool"
                body = f"[tool result: {name}] {body[:500]}"
            tc = summarize_tool_calls(r["tool_calls"])
            if body:
                lines.append(f"[{t}] {label}: {body}")
            if tc:
                lines.append(f"[{t}] {label}: {tc}")
        lines.append("")
        out_file.write_text("\n".join(lines), encoding="utf-8")
        written += 1

    print(f"cure/build-transcripts: wrote {written} day file(s) from {len(rows)} message(s) → {ARCHIVE}")


if __name__ == "__main__":
    main()
