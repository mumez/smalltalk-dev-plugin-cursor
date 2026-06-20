---
name: st-setup-project
description: Pharo project boilerplate creator. Use when the user asks to create a new Pharo/Smalltalk project from scratch, when project structure is missing (no src/ directory or .project file), when the user wants to start a new Smalltalk development project, or when setting up BaselineOf, Core, and Tests package structure.
allowed-tools: Bash AskUserQuestion Read
---

# Set Up Pharo Project Boilerplate

Create a complete Pharo project structure with BaselineOf, Core package, and Tests package.

## When to Use This Skill

- User asks to "create a new project", "start a Smalltalk project", or "set up project structure"
- No `src/` directory or `.project` file exists in the current directory
- User provides a project name and wants to begin development

## Project Name Rules

- **PascalCase required**: Must start with uppercase, alphanumeric only
- Valid: `MyProject`, `RedisClient`, `JSONParser`
- Invalid: `my-project`, `my_project`, `myProject`

**If no name provided**: Ask with `AskUserQuestion`: "What is your project name? (Use PascalCase like MyProject)"

## Pre-flight Checks

**1. Validate PascalCase:**
```bash
if [[ ! "$PROJECT_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
  echo "Error: Project name must be in PascalCase (e.g., MyProject, RedisClient)"
  exit 1
fi
```

**2. Check for existing project:**
```bash
if [ -d "src" ] && [ "$(find src -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)" -gt 0 ]; then
  echo "Error: Project already exists (src/ directory contains packages)"
  exit 1
fi
```

## Created Structure

```
MyProject/
├── .project                          # srcDirectory: 'src'
└── src/
    ├── .properties                   # format: tonel
    ├── BaselineOfMyProject/
    │   ├── package.st
    │   └── BaselineOfMyProject.class.st
    ├── MyProject-Core/
    │   └── package.st
    └── MyProject-Tests/
        └── package.st
```

## Implementation

Run the setup script with the validated project name. The full bash implementation is below.

```bash
#!/bin/bash
set -e

PROJECT_NAME="$1"

# Validate PascalCase
if [[ ! "$PROJECT_NAME" =~ ^[A-Z][a-zA-Z0-9]*$ ]]; then
  echo "Error: Project name must be in PascalCase (e.g., MyProject, RedisClient)"
  exit 1
fi

# Check for existing project
if [ -d "src" ] && [ "$(find src -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)" -gt 0 ]; then
  echo "Error: Project already exists (src/ directory contains packages)"
  echo "This command is for starting new projects from scratch"
  exit 1
fi

# Create directories
mkdir -p "src/BaselineOf${PROJECT_NAME}"
mkdir -p "src/${PROJECT_NAME}-Core"
mkdir -p "src/${PROJECT_NAME}-Tests"

# Create .project if it doesn't exist
if [ ! -f ".project" ]; then
  cat > .project << 'EOF'
{
	'srcDirectory' : 'src'
}
EOF
fi

# Create src/.properties if it doesn't exist
if [ ! -f "src/.properties" ]; then
  cat > "src/.properties" << EOF
{
	#format : #tonel
}
EOF
fi

# Create package.st files
cat > "src/BaselineOf${PROJECT_NAME}/package.st" << EOF
Package { #name : 'BaselineOf${PROJECT_NAME}' }
EOF

cat > "src/${PROJECT_NAME}-Core/package.st" << EOF
Package { #name : '${PROJECT_NAME}-Core' }
EOF

cat > "src/${PROJECT_NAME}-Tests/package.st" << EOF
Package { #name : '${PROJECT_NAME}-Tests' }
EOF

# Create BaselineOf class file (use placeholder to avoid heredoc variable expansion)
cat > "src/BaselineOf${PROJECT_NAME}/BaselineOf${PROJECT_NAME}.class.st" << 'EOF'
Class {
	#name : 'BaselineOfPROJECT_NAME',
	#superclass : 'BaselineOf',
	#category : 'BaselineOfPROJECT_NAME'
}

{ #category : 'baselines' }
BaselineOfPROJECT_NAME >> baseline: spec [
	<baseline>

	spec for: #common do: [
		"Packages"
		spec
			package: 'PROJECT_NAME-Core';
			package: 'PROJECT_NAME-Tests' with: [ spec requires: #('PROJECT_NAME-Core') ].

		"Groups"
		spec
			group: 'Core' with: #('PROJECT_NAME-Core');
			group: 'Tests' with: #('PROJECT_NAME-Tests');
			group: 'all' with: #('Core' 'Tests');
			group: 'default' with: #('Core') ]
]
EOF

# Replace PROJECT_NAME placeholder (portable for Linux and macOS)
if sed --version 2>&1 | grep -q GNU; then
  sed -i "s/PROJECT_NAME/${PROJECT_NAME}/g" "src/BaselineOf${PROJECT_NAME}/BaselineOf${PROJECT_NAME}.class.st"
else
  sed -i '' "s/PROJECT_NAME/${PROJECT_NAME}/g" "src/BaselineOf${PROJECT_NAME}/BaselineOf${PROJECT_NAME}.class.st"
fi

# Show success message
echo "✓ Pharo project '${PROJECT_NAME}' created successfully!"
echo ""
echo "Project structure:"
tree -L 2 src/ 2>/dev/null || find src -type f | sed 's|[^/]*/| |g'
echo ""
echo "Next steps:"
echo "  1. Use /st-init to verify Pharo connection"
echo "  2. Start adding classes to ${PROJECT_NAME}-Core"
echo "  3. Write tests in ${PROJECT_NAME}-Tests"
```

**Key files created:**

**.project** (Pharo STON format with single quotes):
```
{
	'srcDirectory' : 'src'
}
```

**src/.properties** (Tonel format declaration):
```
{
	#format : #tonel
}
```

**BaselineOf class** defines package dependencies and groups:
- `Core` group: `ProjectName-Core`
- `Tests` group: `ProjectName-Tests` (requires Core)
- `all` group: Core + Tests
- `default` group: Core only

## After Setup

Show the user what was created and next steps:

```
✓ Pharo project 'ProjectName' created successfully!

Next steps:
  1. Use /st-init to verify Pharo connection and start development
  2. Start adding classes to ProjectName-Core
  3. Write tests in ProjectName-Tests
```

Then suggest using the `smalltalk-dev:st-init` skill to start the development session.

## Error Handling

| Situation | Action |
|-----------|--------|
| Invalid project name | Show error with PascalCase example, stop |
| Project already exists | Stop immediately, suggest this is for new projects |
| File system errors | Let bash errors propagate naturally (`set -e`) |

## Related Skills

- `smalltalk-dev:st-init` — Start development session after project is created
- `smalltalk-dev:smalltalk-developer` — Development workflow (Edit → Import → Test)
