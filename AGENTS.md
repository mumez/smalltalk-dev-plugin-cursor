# AGENTS.md

## Cursor Cloud specific instructions

### What this repo is
`smalltalk-dev` is a **Cursor plugin** for AI-driven Pharo Smalltalk development. It is not a
buildable application — it is declarative content: slash commands (`commands/*.md`), AI skills
(`skills/*/SKILL.md`), a `postToolUse` hook (`hooks/hooks.json` → `scripts/suggest-class-comment.sh`,
matcher `Write`, needs `jq`; emits `additional_context` to nudge `/smalltalk-commenter` after a
sizeable uncommented Tonel class file is written), and MCP server wiring (`mcp.json`). There is no
compile/build/lint/test step for the repo itself. See `README.md` and `doc/Commands.md` for the
user-facing command reference.

The plugin's actual functionality is delivered by two MCP servers (launched via `uvx`, defined in
`mcp.json`) plus a live Pharo image:

- `smalltalk-validator` — stateless Tonel lint/validate (no Pharo needed). Built from
  `git+https://github.com/mumez/smalltalk-validator-mcp-server.git@main`.
- `smalltalk-interop` — bridges to a running Pharo image over HTTP (`PHARO_SIS_PORT`, default `8086`).
  Built from `git+https://github.com/mumez/pharo-smalltalk-interop-mcp-server.git`.

### Non-obvious environment caveats
- **`uv`/`uvx` is the runtime for both MCP servers** and lives in `~/.local/bin` (on `PATH` via
  `~/.bashrc`). The startup update script reinstalls it if missing.
- **The validator MCP server compiles a C extension** (`tree-sitter-tonel-smalltalk`) on first `uvx`
  fetch. This requires `python3-dev` + `build-essential` (already installed in the VM snapshot). If a
  fresh image ever lacks them: `sudo apt-get install -y python3-dev build-essential`.
- **MCP servers are normally driven by Cursor**, not by hand. To exercise/verify them outside Cursor,
  drive their stdio JSON-RPC directly (initialize → notifications/initialized → tools/list →
  tools/call). Validator content tools take `file_content` (not `content`); `*_from_file` tools take
  `file_path`. Interop `import_package` takes `package_name`+`path`; `run_class_test` takes `class_name`.

### Pharo image (required for end-to-end interop)
- Pharo 13.1 (VM + image) is installed at `~/pharo` with `PharoSmalltalkInteropServer` already loaded
  into the saved image (`~/pharo/Pharo.image`). Headless launcher: `~/pharo/pharo`.
- **Services are never auto-started by the update script.** Start the interop server manually when you
  need import/test/eval against Pharo:
  ```bash
  cd ~/pharo && PHARO_SIS_PORT=8086 ./pharo Pharo.image eval --no-quit "SisServer current start"
  ```
  Run it in a tmux session (it stays in the foreground keeping the headless VM alive). Health check:
  ```bash
  curl -X POST http://localhost:8086/eval/ -H "Content-Type: application/json" -d '{"code":"Smalltalk version"}'
  ```
- **Do not run a second `./pharo Pharo.image ...` while the server VM is running** — both lock the same
  image file and the second one silently produces no output. Use the HTTP endpoint (or the interop MCP)
  to talk to the running image instead.
- The validator path (lint/validate Tonel) works **without** Pharo running.
