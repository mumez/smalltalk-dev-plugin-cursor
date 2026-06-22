#!/bin/bash
# Cursor postToolUse hook (matcher: Write).
#
# After a sizeable Tonel (.st) class file is written that still lacks a class
# comment, inject context into the conversation suggesting /smalltalk-commenter.
#
# Why postToolUse (and not afterFileEdit)?
# Per the Cursor hooks spec (https://cursor.com/docs/hooks):
#   - postToolUse "is useful for ... injecting context" and honors the
#     "additional_context" output field, which is injected into the conversation.
#   - afterFileEdit is fire-and-forget: its stdout is ignored, so it cannot
#     surface a suggestion to the agent.
#   - prompt hooks ("type": "prompt") only return { ok, reason } for allow/deny
#     gating on blocking events, so they cannot inject a suggestion either.
#
# Input: postToolUse JSON on stdin (tool_name, tool_input, tool_output, ...).
# Output: {"additional_context": "..."} to nudge the agent, or {} to do nothing.

set -uo pipefail

# Minimum line count for a class file to be considered "sizeable".
MIN_LINES="${SMALLTALK_COMMENTER_MIN_LINES:-20}"

INPUT=$(cat)

emit_noop() { echo '{}'; exit 0; }

# Resolve the written file path from the Write tool input.
FILE_PATH=$(printf '%s' "$INPUT" | jq -r '.tool_input.file_path // .tool_input.path // empty' 2>/dev/null || true)

# Must be a Tonel file that now exists on disk.
[ -n "$FILE_PATH" ] || emit_noop
[[ "$FILE_PATH" =~ \.st$ ]] || emit_noop
[ -f "$FILE_PATH" ] || emit_noop

# Must be a class-definition file (skip package.st, extension method files, etc.).
grep -q '#superclass' "$FILE_PATH" 2>/dev/null || emit_noop

# Must be of some scale.
LINES=$(wc -l < "$FILE_PATH" 2>/dev/null || echo 0)
[ "${LINES:-0}" -ge "$MIN_LINES" ] || emit_noop

# Skip if a Tonel class comment already exists: a leading "..." block placed
# before the `Class { }` definition (the only form Pharo recognizes).
FIRST_CHAR=$(grep -m1 -v '^[[:space:]]*$' "$FILE_PATH" 2>/dev/null | head -c1 || true)
[ "$FIRST_CHAR" = '"' ] && emit_noop

# Best-effort class name for a friendlier message.
CLASS_NAME=$(grep -m1 '#name :' "$FILE_PATH" 2>/dev/null | sed -E "s/.*#name :[[:space:]]*#?'?([A-Za-z0-9_]+).*/\1/" || true)
SUFFIX=""
[ -n "$CLASS_NAME" ] && SUFFIX=" (class ${CLASS_NAME})"

MSG="A sizeable Tonel class file was just written: ${FILE_PATH}${SUFFIX}. It has no leading \"...\" class comment yet — consider running /smalltalk-commenter to add a CRC-style class comment."

# jq -n guarantees valid, properly escaped JSON output.
jq -n --arg ctx "$MSG" '{additional_context: $ctx}'
