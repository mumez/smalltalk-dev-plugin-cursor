# smalltalk-dev Plugin

[Cursor](https://cursor.com/) plugin for AI-driven Smalltalk (Pharo/Squeak) development.

> [Claude Code version](https://github.com/mumez/smalltalk-dev-plugin) is also available.

## Overview

This plugin provides a comprehensive AI-powered toolkit for Smalltalk development (Pharo or Squeak). It covers the full development lifecycle — from project setup and Tonel file editing, to importing, testing, debugging, and documentation generation.

## Features

- **Commands**: Essential slash commands for import, test, eval, and validation
- **Skills**: AI-powered development workflow, debugging expertise, and documentation (including `st-*` skills for Skill-tool routing)
- **MCP Integration**: Seamless connection to a Smalltalk image and validation servers

## Usage

### Quick Start

The easiest way to use this plugin is to use the **/st-buddy** command:

```bash
# Start Smalltalk Buddy (once per session)
/st-buddy

# Then ask questions naturally
You: "I want to create a Person class with name and age"
AI:  I'll help you create that! [Creates Tonel files and guides you through the process]

You: "How do I test this?"
AI:  Let me run the tests for you... [Executes tests and shows results]

You: "The test failed, can you help?"
AI:  I'll debug this... [Investigates, identifies issue, and fixes it]
```

**/st-buddy** is your friendly development partner that:
- Understands what you want to do and routes to the right tools
- Guides you through development, testing, and debugging
- Helps you learn AI-assisted Smalltalk development
- Works naturally through conversation

### Development Workflow

1. **Run /st-buddy** once at the start of your session
2. **Ask questions** naturally about what you want to do
3. **AI implements** and manages the workflow (editing Tonel, importing, testing)
4. **Review results** and continue the conversation
5. **Iterate** until you're satisfied

For experienced users who prefer direct commands, see [Commands.md](doc/Commands.md).

## Prerequisites

### 1. A Smalltalk Image with a Smalltalk Interop Server

Choose Pharo or Squeak, then one of the following options:

#### Option A: Use Docker (Easy, Pharo only)

Run a pre-configured Pharo image using [smalltalk-interop-docker](https://github.com/mumez/smalltalk-interop-docker):

```bash
docker compose up -d
```

#### Option B: Local Setup

Install the Interop Server that matches your Smalltalk dialect:

- Pharo: [PharoSmalltalkInteropServer](https://github.com/mumez/PharoSmalltalkInteropServer)
- Squeak: [SqueakSmalltalkInteropServer](https://github.com/mumez/SqueakSmalltalkInteropServer)

### 2. Cursor

Install [Cursor](https://cursor.com/) from the official site.

### 3. uv

Install [uv](https://docs.astral.sh/uv/), which is used in MCP.

## Installation

You can install this plugin from either the GUI or CLI.

### GUI

1. Open `Settings`.
2. Navigate to `Plugins`.
3. Paste the following into **Search or Paste Link**:

   `https://github.com/mumez/smalltalk-dev-plugin-cursor`

### CLI (agent)

```bash
/plugin marketplace add https://github.com/mumez/smalltalk-dev-plugin-cursor
```

### Verify Installation

After installation, you should see the custom commands starting with `/st-`.

### Commands

The plugin provides essential slash commands for Smalltalk development (content synced from upstream `st-*` skills):

- `/st-buddy` - Start your friendly Smalltalk development assistant (recommended starting point)
- `/st-init` - Load smalltalk-developer skill and explain workflow
- `/st-setup-project` - Set up Smalltalk project structure
- `/st-eval` - Execute Smalltalk code snippets
- `/st-lint` - Check code quality and best practices
- `/st-import` - Import Tonel packages to the Smalltalk image
- `/st-export` - Export packages from the Smalltalk image
- `/st-test` - Run SUnit tests
- `/st-validate` - Validate Tonel syntax

**Most users should start with /st-buddy** - it will guide you and use the other commands as needed.

For command details and advanced usage, see [Commands.md](doc/Commands.md).

### Background Skills

The plugin includes specialized AI skills that activate automatically based on your needs (also available under `skills/` for the Skill tool, including `st-*`):

- **smalltalk-developer** - Development workflow and best practices
- **smalltalk-debugger** - Error handling and debugging procedures
- **smalltalk-usage-finder** - Code usage exploration and analysis
- **smalltalk-implementation-finder** - Implementation discovery and patterns
- **smalltalk-commenter** - CRC-style class documentation generation

**These skills work behind the scenes** when you use /st-buddy, providing specialized knowledge for each task.

#### /smalltalk-commenter (Documentation Skill)

Generates and improves CRC-style class comments:

- Often suggested after `/st-lint` flags missing or poor class comments
- Can be invoked directly when documenting packages or classes

### MCP Tools

The plugin exposes all tools from both MCP servers:

**smalltalk-interop** (22 tools):
- `eval`: Execute Smalltalk expressions
- `import_package`, `export_package`: Package management
- `run_class_test`, `run_package_test`: Test execution
- `get_class_source`, `get_method_source`: Code inspection
- `search_implementors`, `search_references`: Code navigation
- And more...

**smalltalk-validator** (5 tools):
- `validate_tonel_smalltalk_from_file`: File validation
- `validate_tonel_smalltalk`: Content validation
- `validate_smalltalk_method_body`: Method validation
- `lint_tonel_smalltalk_from_file`: File linting
- `lint_tonel_smalltalk`: Content linting

## Configuration

The plugin uses two MCP servers:

1. **smalltalk-interop**: Communication with Smalltalk image (Pharo or Squeak)
2. **smalltalk-validator**: Tonel syntax validation

These are configured automatically via `mcp.json` in this plugin. You can customize the Smalltalk HTTP port:

```bash
export SIS_PORT=8086  # default
```

## Best Practices

### Development Workflow
1. **Edit** Tonel files (AI editor is the source of truth)
2. **Lint** code with `/st-lint` to check quality
3. **Import** to the Smalltalk image with absolute paths
4. **Test** after every import

### Code Quality
- Use `/st-lint` before importing to catch issues early
- Add class prefixes to avoid name collisions
- Keep methods focused (15 lines standard, 40 for UI/tests)
- Limit instance variables (max 10 per class)
- Access instance variables through methods, not directly

### Path Management
- Always use absolute paths for imports
- Import multiple packages individually

### File Editing
- **AI editor is the source of truth** (Tonel files)
- Avoid editing in the Smalltalk image directly
- Use `export_package` only when necessary

### Import Timing
- Re-import after every change
- Import main package before test package
- Don't forget to import test packages

### Testing
- Run tests after every import
- Use `run_class_test` for specific classes
- Use `run_package_test` for full packages

### Debugging
- Use `/st-eval` for quick partial execution
- Capture both results and errors in Array
- Use `printString` for object serialization
- Debug step-by-step

## Troubleshooting

### "Connection refused" error

Make sure the Smalltalk Interop Server (PharoSmalltalkInteropServer or SqueakSmalltalkInteropServer) is running:

```smalltalk
SisServer current start.
SisServer current.  "Should show running server"
```

### "Package not found" after import

- Verify absolute path is correct
- Check that .st files are in correct directory
- Ensure package.st exists

### Tests fail after import

1. Check test error message
2. Use `/st-validate` to check syntax
3. Use `/st-eval` to debug specific code
4. Fix in Tonel file
5. Re-import and re-test

### Import seems to do nothing

- Check the Smalltalk image's Transcript for error messages
- Verify server port matches configuration: `SisServer teapotConfig`
- Try `/st-eval Smalltalk version` to test connection

## Project Structure

```
smalltalk-dev-plugin-cursor/
├── .cursor-plugin/
│   └── plugin.json          # Cursor plugin metadata, MCP server reference
├── mcp.json                 # MCP server configuration
├── assets/
│   └── logo.svg             # Plugin logo
├── commands/
│   ├── st-buddy.md          # /st-buddy - Friendly development assistant
│   ├── st-init.md           # /st-init - Start development session
│   ├── st-setup-project.md  # /st-setup-project - Project boilerplate
│   ├── st-eval.md           # /st-eval - Execute Smalltalk code
│   ├── st-import.md         # /st-import - Import Tonel packages
│   ├── st-export.md         # /st-export - Export packages
│   ├── st-test.md           # /st-test - Run SUnit tests
│   ├── st-lint.md           # /st-lint - Check code quality
│   └── st-validate.md       # /st-validate - Validate Tonel syntax
├── skills/
│   ├── st-buddy/ … st-validate/   # User commands (also mirrored under commands/)
│   ├── smalltalk-commenter/
│   ├── smalltalk-developer/
│   ├── smalltalk-debugger/
│   ├── smalltalk-usage-finder/
│   └── smalltalk-implementation-finder/
├── doc/
│   └── Commands.md               # Commands quick reference
├── README.md                 # This file
└── LICENSE
```

## Presentation

- [Introducing smalltalk-dev Plugin](https://mumez.github.io/smalltalk-dev-plugin-slides/introducing-smalltalk-dev-plugin-en.html)

## Examples

Projects built with this plugin:

- [smalltalk-dev-plugin-money-example](https://github.com/mumez/smalltalk-dev-plugin-money-example) - Multi-currency Money class with arithmetic operations and exchange rate conversion
- [smalltalk-dev-plugin-graph-example](https://github.com/mumez/smalltalk-dev-plugin-graph-example) - Directed weighted graph with Dijkstra's shortest-path algorithm
- [smalltalk-dev-plugin-gui-example](https://github.com/mumez/smalltalk-dev-plugin-gui-example) - Interactive to-do list app built with the Spec2 framework

## Contributing

Contributions are welcome! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test with Cursor
5. Submit a pull request

## License

MIT License - see LICENSE file for details

## Links

- **MCP Servers**:
  - [smalltalk-interop-mcp-server](https://github.com/mumez/smalltalk-interop-mcp-server) by mumez
  - [smalltalk-validator-mcp-server](https://github.com/mumez/smalltalk-validator-mcp-server) by mumez
- **Cursor**: [Cursor](https://cursor.com/)
- **Pharo**: [Pharo Project](https://pharo.org/)
- **Squeak**: [Squeak Project](https://squeak.org/)
- **Upstream (Claude Code)**: [smalltalk-dev-plugin](https://github.com/mumez/smalltalk-dev-plugin) v2.2.0
