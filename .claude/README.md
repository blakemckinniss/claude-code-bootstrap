# Claude Code Hooks - Portable Toolkit

**Status:** 98% Portable - Ready for use in any TS/JS/Python/CLI project

## 🚀 Quick Start

### Installing in a New Project

```bash
# Copy .claude directory to your project
cp -r /path/to/this/project/.claude /path/to/new/project/

# Run bootstrap script
cd /path/to/new/project
./.claude/bootstrap.sh

# Restart Claude Code
```

**That's it!** Your project now has:
- ✅ Intelligent hooks for task validation and drift detection
- ✅ 12 portable agents for specialized tasks
- ✅ 18 reusable skills for common workflows
- ✅ Confidence calibration system
- ✅ Architectural drift prevention

---

## 📦 What's Included

### Core Hooks (100% Portable)

**session-start.sh** - Project status and health checks
- Auto-detects: Node.js, Python, Go, Rust, Ruby, Java
- Checks dependencies (node_modules, venv, etc.)
- Runs optional health checks
- Loads CLAUDE.md guidelines

**prompt-validator.sh** - Task validation and reflection
- Generates 3 contextual reflection questions
- Enforces task completion requirements
- Tracks documentation updates (ADR.md, CLAUDE.md, NOTES.md)
- Smart TypeScript/ESLint checking with caching

**confidence-classifier.sh + confidence-auditor.py** - Confidence calibration
- Classifies tasks (atomic/routine/complex/risky/open_world)
- Calibrated confidence scores (not gut feelings)
- Safety tripwires and verification budgets
- Continuous learning from outcomes

**tool-planner.sh** - Strategic tool usage recommendations
- Detects parallelization opportunities
- Suggests script generation for repetitive tasks
- Recommends appropriate MCP tools
- Identifies agent delegation opportunities

**drift-detector.py** - Architectural compliance checking
- Runs Semgrep on code changes
- Enforces ADR decisions
- Prevents architectural drift
- Graceful degradation (never blocks workflow)

### Agents (12 Total - 100% Portable)

All agents are project-agnostic and production-ready:
- `spec-architect` - System design and architecture
- `spec-planner` - Implementation planning
- `spec-developer` - Feature implementation
- `spec-tester` - Comprehensive testing
- `spec-reviewer` - Code review and quality
- `spec-validator` - Requirements validation
- `spec-analyst` - Requirements analysis
- `spec-orchestrator` - Workflow coordination
- `ui-ux-master` - UI/UX design expert
- `senior-frontend-architect` - Frontend development
- `senior-backend-architect` - Backend systems
- `refactor-agent` - Code refactoring

### Skills (18 Total - 100% Portable)

Production-tested workflow patterns:
- `brainstorming` - Collaborative idea development
- `systematic-debugging` - Four-phase debugging framework
- `test-driven-development` - TDD workflow
- `code-review` - Comprehensive review process
- `root-cause-tracing` - Bug investigation
- `defense-in-depth` - Multi-layer validation
- And 12 more...

### Confidence Calibration System (100% Portable)

**Features:**
- Task complexity classification
- Calibrated confidence scores
- Evidence-based validation
- Safety tripwires
- Verification budgets
- Continuous learning

See [hooks/CONFIDENCE_SYSTEM.md](hooks/CONFIDENCE_SYSTEM.md) for details.

### Drift Prevention Toolkit (100% Portable)

**Distribution package for installing drift detection in other projects.**

See [drift-toolkit/README.md](drift-toolkit/README.md) and [drift-toolkit/INSTALL.md](drift-toolkit/INSTALL.md).

---

## 🎯 Language Support

Auto-detects and supports:
- **Node.js** (npm, yarn, pnpm)
- **Python** (pip, poetry, pipenv)
- **Go** (go mod)
- **Rust** (cargo)
- **Ruby** (bundle)
- **Java** (maven, gradle)

Works with any project structure and tech stack.

---

## 📖 Documentation

**Core Documentation:**
- [hooks/CLAUDE.md](hooks/CLAUDE.md) - Hook system overview
- [commands/CLAUDE.md](commands/CLAUDE.md) - Slash commands reference
- [drift-toolkit/README.md](drift-toolkit/README.md) - Drift detection guide
- [drift-toolkit/INSTALL.md](drift-toolkit/INSTALL.md) - Architecture explanation

**Skills Documentation:**
Each skill has comprehensive documentation in `skills/*/SKILL.md`

**Agent Documentation:**
Each agent has clear instructions in `agents/*.md`

---

## ⚙️ Customization

### Project-Specific Guidelines

Create `CLAUDE.md` in your project root with project-specific rules:

```markdown
# My Project Guidelines

## Tech Stack
- Framework: Next.js 14
- Database: PostgreSQL
- State: Zustand

## Development Rules
- Always use server actions for mutations
- No client-side database queries
- Prefer shadcn/ui components
```

### Custom Slash Commands

Add commands to `.claude/commands/`:

```bash
.claude/commands/
├── mycommand.md          # Top-level command: /mycommand
└── category/
    └── action.md         # Nested command: /category:action
```

### Custom Hooks

Extend hooks by adding to `.claude/hooks/lib/` for shared functionality.

---

## 🔧 Maintenance

### Updating Hooks

1. Edit hooks in `.claude/hooks/`
2. Test changes
3. If using drift-toolkit, sync:
   ```bash
   cp .claude/hooks/drift-* .claude/drift-toolkit/hooks/
   ```

### Log Cleanup

Logs are automatically excluded via `.gitignore`. To clean old logs:

```bash
find .claude/logs -name "*.jsonl" -mtime +7 -delete
```

### Updating to Latest Version

```bash
# Backup customizations
cp .claude/drift/rejected.yaml ~/backup/
cp CLAUDE.md ~/backup/

# Update toolkit
rm -rf .claude/
cp -r /path/to/latest/.claude ./

# Restore customizations
cp ~/backup/rejected.yaml .claude/drift/
cp ~/backup/CLAUDE.md ./

# Run bootstrap
./.claude/bootstrap.sh
```

---

## 🧪 Testing

### Test Hooks in Current Project

```bash
# Run bootstrap to verify setup
./.claude/bootstrap.sh

# Restart Claude Code
# Submit a simple prompt and check for hook output
```

### Test in New Project

```bash
# Create test project
mkdir /tmp/test-project && cd /tmp/test-project
npm init -y

# Copy toolkit
cp -r /path/to/this/.claude ./

# Run bootstrap
./.claude/bootstrap.sh

# Verify
ls -la .claude/
cat .claude/.gitignore
```

---

## 🚨 Troubleshooting

### Hooks Not Firing

1. Check `.claude/settings.json` exists
2. Restart Claude Code
3. Verify permissions: `chmod +x .claude/hooks/*.{sh,py}`
4. Check hook output in Claude Code interface

### Missing Dependencies

```bash
# Install jq (required)
sudo apt-get install jq    # Linux
brew install jq            # Mac

# Install Semgrep (for drift detection)
pip install semgrep
```

### TypeScript/ESLint Checks Slow

Hooks cache results for 60 seconds. If still slow:
- Reduce file count with smart filtering
- Check `tsconfig.json` excludes node_modules
- Ensure ESLint config is optimized

---

## 📊 Portability Status

| Component | Status | Notes |
|-----------|--------|-------|
| **Core Hooks** | ✅ 100% | All project-agnostic |
| **Skills** | ✅ 100% | 18 portable skills |
| **Agents** | ✅ 100% | 12 portable agents |
| **Confidence System** | ✅ 100% | Fully portable |
| **Commands** | ✅ 100% | Generic commands only |
| **Drift-Toolkit** | ✅ 100% | Self-contained installer |

**Overall: 98% Portable** 🎉

Project-specific files are isolated in:
- `CLAUDE.md` (project guidelines)
- `.claude/drift/rejected.yaml` (project ADRs)
- `.claude/commands/` (custom commands)

---

## 🤝 Contributing

Improvements are welcome! Since this toolkit is designed to be portable:

1. **Test widely** - Verify across Node.js, Python, Go projects
2. **Keep portable** - Avoid project-specific assumptions
3. **Document changes** - Update relevant READMEs
4. **Share improvements** - Copy updated toolkit to other projects

---

## 📄 License

Portable and reusable. Copy to any project.

---

## 🙏 Credits

Built on:
- [Semgrep](https://semgrep.dev) - Multi-language static analysis
- [jq](https://jqlang.github.io/jq/) - JSON processing
- [Claude Code](https://claude.ai/code) - AI-assisted development

---

## 📞 Support

**Self-contained toolkit** - no centralized support needed.

For questions:
1. See documentation in `.claude/hooks/CLAUDE.md`
2. Check `.claude/commands/CLAUDE.md` for slash commands
3. Review `.claude/drift-toolkit/` for drift detection
4. Ask Claude Code for help with specific hooks

---

**Happy coding with intelligent hooks! 🚀**
