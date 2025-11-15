#!/bin/bash
# Claude Code Hooks - Universal Bootstrap Script
# Ultra-portable: Copy .claude/ to any project and run this script

set -euo pipefail

echo "🚀 Claude Code Hooks - Universal Setup"
echo "======================================="
echo ""

# Detect project root
PROJECT_ROOT="${CLAUDE_PROJECT_DIR:-$(git rev-parse --show-toplevel 2>/dev/null || pwd)}"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "📁 Project root: $PROJECT_ROOT"
echo "📁 Script location: $SCRIPT_DIR"
echo ""

# Check if this is a cloned template repo that needs git reinitialization
if [ -d "$PROJECT_ROOT/.git" ]; then
    REMOTE_URL=$(git -C "$PROJECT_ROOT" remote get-url origin 2>/dev/null || echo "")
    if [[ "$REMOTE_URL" == *"claude-code-bootstrap"* ]]; then
        echo "⚠️  Detected cloned template repository"
        echo "   This appears to be a direct clone of claude-code-bootstrap"
        echo ""
        echo "   Recommendation: Reinitialize git for a fresh start"
        echo "   This will:"
        echo "     - Remove connection to template repo"
        echo "     - Clear commit history"
        echo "     - Start with clean git repository"
        echo ""
        read -p "   Reinitialize git? (Y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Nn]$ ]]; then
            echo "   🔄 Reinitializing git repository..."
            rm -rf "$PROJECT_ROOT/.git"
            cd "$PROJECT_ROOT"
            git init
            git branch -M main
            echo "   ✓ Git reinitialized on branch 'main'"
            echo ""
        else
            echo "   Skipping git reinitialization"
            echo ""
        fi
    fi
fi

# Detect if running from within .claude/ or external
if [[ "$SCRIPT_DIR" == *"/.claude"* ]]; then
    # Running from installed .claude/
    CLAUDE_DIR="$SCRIPT_DIR"
    INSTALL_MODE="update"
else
    # Running from external source
    CLAUDE_DIR="$PROJECT_ROOT/.claude"
    INSTALL_MODE="install"
fi

# Detect project type
detect_project_type() {
    if [ -f "$PROJECT_ROOT/package.json" ]; then
        echo "nodejs"
    elif [ -f "$PROJECT_ROOT/requirements.txt" ] || [ -f "$PROJECT_ROOT/pyproject.toml" ]; then
        echo "python"
    elif [ -f "$PROJECT_ROOT/go.mod" ]; then
        echo "go"
    elif [ -f "$PROJECT_ROOT/Cargo.toml" ]; then
        echo "rust"
    elif [ -f "$PROJECT_ROOT/Gemfile" ]; then
        echo "ruby"
    elif [ -f "$PROJECT_ROOT/pom.xml" ] || [ -f "$PROJECT_ROOT/build.gradle" ]; then
        echo "java"
    else
        echo "generic"
    fi
}

PROJECT_TYPE=$(detect_project_type)
echo "✓ Detected: $PROJECT_TYPE project"
echo ""

# Install dependencies
echo "📦 Installing dependencies..."

# Check jq (required for hooks)
if ! command -v jq &> /dev/null; then
    echo "  ⚠️  jq not found - required for hooks"
    echo "     Install: sudo apt-get install jq (Linux) or brew install jq (Mac)"
    JQ_MISSING=true
else
    echo "  ✓ jq installed"
    JQ_MISSING=false
fi

# Check git (required for project detection)
if ! command -v git &> /dev/null; then
    echo "  ⚠️  git not found - recommended for version control"
else
    echo "  ✓ git installed"
fi

# Install Semgrep (for drift detection)
if ! command -v semgrep &> /dev/null; then
    echo "  - Installing Semgrep (drift detection)..."
    if command -v pip3 &> /dev/null; then
        pip3 install --user semgrep 2>/dev/null || echo "    ⚠️ Semgrep install failed (may need manual install)"
    elif command -v pip &> /dev/null; then
        pip install --user semgrep 2>/dev/null || echo "    ⚠️ Semgrep install failed (may need manual install)"
    else
        echo "    ⚠️ pip not found - install manually: pip install semgrep"
    fi
else
    echo "  ✓ Semgrep installed"
fi

# Language-specific tools
case $PROJECT_TYPE in
    nodejs)
        PKG_MGR="npm"
        if command -v pnpm &> /dev/null; then
            PKG_MGR="pnpm"
        elif command -v yarn &> /dev/null; then
            PKG_MGR="yarn"
        fi
        echo "  ✓ Node.js package manager: $PKG_MGR"
        ;;
esac

echo ""

# Copy .claude/ if in install mode
if [ "$INSTALL_MODE" = "install" ]; then
    echo "📋 Copying .claude/ toolkit to project..."
    if [ -d "$CLAUDE_DIR" ]; then
        echo "  ⚠️  $CLAUDE_DIR already exists"
        read -p "  Overwrite? (y/N) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            echo "  Cancelled."
            exit 1
        fi
        rm -rf "$CLAUDE_DIR"
    fi

    cp -r "$SCRIPT_DIR" "$CLAUDE_DIR"
    echo "  ✓ Copied .claude/ toolkit"
    echo ""
fi

# Create directory structure
echo "🔧 Setting up directory structure..."
mkdir -p "$CLAUDE_DIR/"{logs,drift}
touch "$CLAUDE_DIR/logs/.gitkeep"
echo "  ✓ Created logs/ and drift/ directories"

# Create .gitignore if it doesn't exist
if [ ! -f "$CLAUDE_DIR/.gitignore" ]; then
    cat > "$CLAUDE_DIR/.gitignore" << 'GITIGNORE'
# Logs
logs/*.jsonl
logs/*.log
*.log
last_conversation.txt

# Python
__pycache__/
*.pyc
*.pyo
*.pyd
.Python

# Cache
*.cache
.cache/

# Temporary files
*.tmp
*.temp
tmp-*

# OS files
.DS_Store
Thumbs.db

# Keep structure
!logs/.gitkeep
GITIGNORE
    echo "  ✓ Created .claude/.gitignore"
else
    echo "  ✓ .claude/.gitignore exists"
fi

# Make all scripts executable
echo ""
echo "🔑 Setting permissions..."

# Make bootstrap.sh itself executable
chmod +x "$CLAUDE_DIR/bootstrap.sh" 2>/dev/null || true

# Make all .sh and .py files executable in the entire .claude directory
find "$CLAUDE_DIR" -type f \( -name "*.sh" -o -name "*.py" \) -exec chmod +x {} \; 2>/dev/null || true

echo "  ✓ Made all scripts executable (.sh, .py)"
echo "  ✓ Hooks, bootstrap, and utilities are now executable"

# Initialize drift detection if rules don't exist
if [ ! -f "$CLAUDE_DIR/drift/rejected.yaml" ]; then
    echo ""
    echo "🛡️ Initializing drift detection..."
    if [ -f "$CLAUDE_DIR/drift-toolkit/rules/semgrep/rejected.yaml.template" ]; then
        cp "$CLAUDE_DIR/drift-toolkit/rules/semgrep/rejected.yaml.template" "$CLAUDE_DIR/drift/rejected.yaml"
        echo "  ✓ Created drift/rejected.yaml from template"
    else
        echo "  ⚠️ Template not found, skipping drift init"
    fi
fi

# Setup documentation structure
echo ""
echo "📚 Setting up documentation..."

# Create CLAUDE.md if it doesn't exist
if [ ! -f "$PROJECT_ROOT/CLAUDE.md" ]; then
    cat > "$PROJECT_ROOT/CLAUDE.md" << 'CLAUDEMD'
# Claude Code - Project Guidelines

## Response Format (MANDATORY)

**All responses MUST follow this exact order:**

1. **JSON Confidence Rubric** - Data block at the very top (easy to scroll past)
2. **Main Response Content** - Answer, explanations, work performed
3. **Summary Sections** - Always at the bottom in this order:
   - Final Confidence (0-100%)
   - Documentation Updates Required
   - Technical Debt & Risks
   - Next Steps & Considerations

**Rationale:** JSON first = scroll past data, read content, actionable summary at bottom.

---

## Project Overview
<!-- Brief description of what this project does -->

## Architecture
<!-- High-level architecture and key design decisions -->

## Development Workflow
<!-- How to set up, build, test, and deploy -->

## Important Context
<!-- Things Claude should know when working on this project -->

## Constraints & Standards
<!-- Code standards, prohibited patterns, architectural rules -->

## ADRs (Architecture Decision Records)
See `docs/adr/` for all architectural decisions.

## Common Tasks
<!-- Frequent operations, debugging tips, deployment steps -->

CLAUDEMD
    echo "  ✓ Created CLAUDE.md template with response format"
else
    echo "  ✓ CLAUDE.md already exists"
fi

# Create docs directory structure
mkdir -p "$PROJECT_ROOT/docs/adr"
echo "  ✓ Created docs/adr/ directory"

# Create ADR template
if [ ! -f "$PROJECT_ROOT/docs/adr/template.md" ]; then
    cat > "$PROJECT_ROOT/docs/adr/template.md" << 'ADRTEMPLATE'
# ADR-XXXX: [Short Title]

**Date:** YYYY-MM-DD
**Status:** [Proposed | Accepted | Deprecated | Superseded]
**Deciders:** [List of people involved]

## Context
<!-- What is the issue we're addressing? -->

## Decision
<!-- What is the change that we're proposing or doing? -->

## Consequences
<!-- What becomes easier or harder as a result of this decision? -->

### Positive
-

### Negative
-

### Neutral
-

## Alternatives Considered
<!-- What other options did we evaluate? -->

## References
<!-- Links to related documents, issues, PRs -->

ADRTEMPLATE
    echo "  ✓ Created ADR template"
else
    echo "  ✓ ADR template already exists"
fi

# Create docs README
if [ ! -f "$PROJECT_ROOT/docs/README.md" ]; then
    cat > "$PROJECT_ROOT/docs/README.md" << 'DOCSREADME'
# Project Documentation

## Architecture Decision Records (ADR)

Architecture decisions are documented in the `adr/` directory.

### Creating a New ADR

1. Copy `adr/template.md` to `adr/ADR-XXXX-title.md`
2. Replace XXXX with the next sequential number
3. Fill in all sections
4. Update the status as the decision evolves

### ADR Index
<!-- Maintain a list of all ADRs here -->

DOCSREADME
    echo "  ✓ Created docs/README.md"
else
    echo "  ✓ docs/README.md already exists"
fi

# Create ADR.md (main ADR index)
if [ ! -f "$PROJECT_ROOT/docs/ADR.md" ]; then
    cat > "$PROJECT_ROOT/docs/ADR.md" << 'ADRMD'
# Architecture Decision Records (ADR)

This document tracks key architectural decisions for this project.

## Index

<!-- ADRs will be listed here as they are created -->

---

## How to Add a New ADR

1. Use the template in `adr/template.md`
2. Create a new file: `adr/ADR-XXXX-descriptive-title.md`
3. Fill in all sections with your decision
4. Add an entry to the Index above
5. Link related ADRs if applicable

---

## Decision Log

<!-- Most recent decisions appear at the top -->

ADRMD
    echo "  ✓ Created docs/ADR.md"
else
    echo "  ✓ docs/ADR.md already exists"
fi

# Create NOTES.md (auto-log for critical items)
if [ ! -f "$PROJECT_ROOT/docs/NOTES.md" ]; then
    cat > "$PROJECT_ROOT/docs/NOTES.md" << 'NOTESMD'
# Project Notes

This file serves as an auto-log for critical items tracked during development.

## Legend

- 🔴 CRITICAL Documentation/Debt (76-100 severity)
- ⭐ ESSENTIAL Next Steps (76-100 priority)

---

## Auto-Logged Items

<!-- Critical items (severity/priority ≥76) are automatically appended below -->

NOTESMD
    echo "  ✓ Created docs/NOTES.md"
else
    echo "  ✓ docs/NOTES.md already exists"
fi

# Setup settings.json
echo ""
echo "⚙️ Setting up Claude Code configuration..."
if [ ! -f "$CLAUDE_DIR/settings.json" ]; then
    echo "  Creating default settings.json..."
    cat > "$CLAUDE_DIR/settings.json" << 'SETTINGSJSON'
{
  "hooks": {
    "SessionStart": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-start.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/prompt-validator.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/tool-awareness.py",
            "timeout": 5
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/confidence-classifier.sh",
            "timeout": 5,
            "comment": "Confidence Calibration System - Task Classification"
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/tool-planner.sh",
            "timeout": 15,
            "comment": "Tool Planning Hook - Strategic Tool Usage Recommendations"
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/drift-awareness.sh",
            "timeout": 2,
            "comment": "Drift Prevention - Pre-Execution ADR Warnings"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/pre-tool-pattern-prevention.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "mcp__playwright__*",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/suggest-chrome-devtools.sh",
            "timeout": 5,
            "comment": "Chrome DevTools MCP Suggestion - Advisory guidance for debugging tasks"
          }
        ]
      },
      {
        "matcher": "mcp__filesystem__create_directory",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-directory-creation.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-markdown-creation.sh",
            "timeout": 10
          }
        ]
      },
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-directory-creation.sh",
            "timeout": 10
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/validate-markdown-creation.sh",
            "timeout": 10
          }
        ]
      }
    ],
    "PostToolUse": [
      {
        "matcher": "*",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/posttooluse-metacognition.py",
            "timeout": 15
          },
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/confidence-auditor.py",
            "timeout": 10,
            "comment": "Confidence Calibration System - Rubric Audit"
          }
        ]
      },
      {
        "matcher": "Write|Edit|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/drift-detector.py",
            "timeout": 5,
            "comment": "Drift Prevention - Semgrep Architecture Validation"
          }
        ]
      },
      {
        "matcher": "Edit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/post-edit-format.sh",
            "timeout": 30
          }
        ]
      }
    ],
    "Stop": [
      {
        "hooks": [
          {
            "type": "command",
            "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/session-logger.sh",
            "timeout": 10
          }
        ]
      }
    ]
  },
  "spinnerTipsEnabled": false
}
SETTINGSJSON
    echo "  ✓ Created settings.json with all hooks configured"
else
    echo "  ✓ settings.json already exists"
fi

echo "  💡 All hooks use \$CLAUDE_PROJECT_DIR (set automatically by Claude Code)"

# Summary
echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "✅ Setup complete!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Show what's included
echo "📦 What's Included:"
echo ""
echo "  🎯 Core Hooks ($PROJECT_TYPE project)"
echo "     - session-start.sh - Project status & health checks"
echo "     - prompt-validator.sh - Task validation & reflection"
echo "     - confidence-calibration - Calibrated confidence assessment"
echo "     - tool-planner.sh - Strategic tool recommendations"
echo "     - drift-detector.py - ADR compliance checking"
echo ""
echo "  🤖 Agents (12 total)"
echo "     - All portable, production-ready"
echo ""
echo "  📚 Skills (18 total)"
echo "     - Systematic debugging, TDD, code review, etc."
echo ""
echo "  🛡️ Drift Prevention"
echo "     - Semgrep-based architectural guardrails"
echo ""

# Next steps
echo "📋 Next Steps:"
echo ""
if [ "$JQ_MISSING" = true ]; then
    echo "  1. ⚠️  Install jq: sudo apt-get install jq (required)"
fi
echo "  2. 📝 Customize CLAUDE.md with project-specific guidelines"
echo "  3. 📝 Customize drift/rejected.yaml with your ADRs"
echo "  4. 📝 Document architectural decisions in docs/adr/"
echo "  5. 🔄 Restart Claude Code to activate hooks"
echo "  6. 🧪 Test: Run a simple task and check hook output"
echo ""
echo "📚 Documentation:"
echo "  - .claude/hooks/CLAUDE.md - Hook system overview"
echo "  - .claude/drift-toolkit/README.md - Drift detection guide"
echo "  - .claude/commands/CLAUDE.md - Slash commands reference"
echo ""
echo "🎉 Your project is now equipped with Claude Code hooks!"
echo ""
