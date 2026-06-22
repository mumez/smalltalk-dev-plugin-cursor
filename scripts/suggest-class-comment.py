#!/usr/bin/env python3
"""Cursor postToolUse hook (matcher: Write).

After a sizeable Tonel (.st) class file is written that still lacks a class
comment, inject context into the conversation suggesting /smalltalk-commenter.

Implemented in Python and launched via `uv run python` so it works
cross-platform (including Windows), unlike a shell script.

Cursor hooks spec (https://cursor.com/docs/hooks):
  - postToolUse honors the top-level "additional_context" output field, which
    is injected into the conversation after the tool result.
  - afterFileEdit is fire-and-forget (stdout ignored); prompt hooks only return
    {ok, reason} for gating. Neither can surface a suggestion, so postToolUse
    is the correct event here.

Input:  postToolUse JSON on stdin (tool_name, tool_input, ...).
Output: {"additional_context": "..."} to nudge the agent, or {} for a no-op.
"""
import json
import os
import re
import sys


def noop():
    print("{}")
    sys.exit(0)


def main():
    raw = sys.stdin.read()
    try:
        payload = json.loads(raw) if raw.strip() else {}
    except json.JSONDecodeError:
        noop()

    tool_input = payload.get("tool_input") or {}
    file_path = tool_input.get("file_path") or tool_input.get("path") or ""

    # Must be a Tonel file that now exists on disk.
    if not file_path or not file_path.endswith(".st") or not os.path.isfile(file_path):
        noop()

    try:
        with open(file_path, "r", encoding="utf-8", errors="replace") as handle:
            content = handle.read()
    except OSError:
        noop()

    # Must be a class-definition file (skip package.st, extension files, etc.).
    if "#superclass" not in content:
        noop()

    # Must be of some scale.
    try:
        min_lines = int(os.environ.get("SMALLTALK_COMMENTER_MIN_LINES", "20"))
    except ValueError:
        min_lines = 20
    if content.count("\n") < min_lines:
        noop()

    # Skip if a Tonel class comment already exists: a leading "..." block placed
    # before the `Class { }` definition (the only form Pharo recognizes).
    if content.lstrip().startswith('"'):
        noop()

    # Best-effort class name for a friendlier message.
    match = re.search(r"#name\s*:\s*#?'?([A-Za-z0-9_]+)", content)
    suffix = " (class {0})".format(match.group(1)) if match else ""

    message = (
        "A sizeable Tonel class file was just written: {path}{suffix}. "
        'It has no leading "..." class comment yet \u2014 consider running '
        "/smalltalk-commenter to add a CRC-style class comment."
    ).format(path=file_path, suffix=suffix)

    print(json.dumps({"additional_context": message}))


if __name__ == "__main__":
    main()
