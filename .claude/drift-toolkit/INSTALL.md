# Drift-Toolkit Installation Guide

## 🎯 What is drift-toolkit?

**drift-toolkit** is a **portable distribution package** for architectural drift detection.

Think of it like a software installer - you copy this directory to other projects and run the bootstrap script.

---

## 🏗️ Architecture

```
YOUR PROJECT:
.claude/
├── hooks/                      # ACTIVE drift detection (this project)
│   ├── drift-awareness.sh      # Working version
│   └── drift-detector.py       # Working version
│
└── drift-toolkit/              # DISTRIBUTION SOURCE (installer for OTHER projects)
    ├── README.md               # Feature documentation
    ├── INSTALL.md              # This file
    ├── bootstrap.sh            # Installation script
    ├── hooks/                  # Template hooks (synced from .claude/hooks/)
    │   ├── drift-awareness.sh  # Template (copy to target project)
    │   └── drift-detector.py   # Template (copy to target project)
    ├── rules/                  # Semgrep rule templates
    └── docs/                   # Setup and customization guides
```

---

## 📦 Two Use Cases

### 1. Using Drift Detection in THIS Project ✅

**Already set up!** The active drift detection system is in `.claude/hooks/`

- ✅ Hooks are active and running
- ✅ Rules are in `.claude/drift/`
- ✅ No installation needed

### 2. Installing Drift Detection in OTHER Projects 🚀

**Use this drift-toolkit as an installer:**

```bash
# Copy drift-toolkit to another project
cp -r /path/to/this/project/.claude/drift-toolkit /path/to/other/project/.claude/

# Run installer in target project
cd /path/to/other/project
.claude/drift-toolkit/bootstrap.sh

# Restart Claude Code in target project
```

---

## 🔄 Maintenance: Keeping drift-toolkit in Sync

**When you update drift hooks in THIS project:**

1. Edit the active hooks in `.claude/hooks/drift-*.{sh,py}`
2. Test the changes
3. Sync to drift-toolkit for distribution:

```bash
# Sync updated hooks to distribution package
cp .claude/hooks/drift-awareness.sh .claude/drift-toolkit/hooks/
cp .claude/hooks/drift-detector.py .claude/drift-toolkit/hooks/

# Now drift-toolkit has your latest improvements for other projects
```

---

## 🎓 Think of It Like This

| Location | Purpose | Analogy |
|----------|---------|---------|
| `.claude/hooks/` | Active system | Installed software (running) |
| `.claude/drift-toolkit/` | Distribution | Installer package (for copying) |

**Example:**
- Your computer has Chrome installed → `.claude/hooks/` (running)
- You have a Chrome installer.dmg → `.claude/drift-toolkit/` (for installing on other computers)

---

## ✅ Quick Check

**Q: Should I edit drift-toolkit hooks directly?**
**A:** No! Edit `.claude/hooks/drift-*.{sh,py}` and then sync to drift-toolkit.

**Q: Can I delete drift-toolkit?**
**A:** Yes, if you don't plan to install drift detection in other projects. Your active system will continue working.

**Q: How do I update drift-toolkit with my improvements?**
**A:** Copy updated files from `.claude/hooks/` to `.claude/drift-toolkit/hooks/`

---

## 📚 Full Documentation

See [README.md](README.md) for:
- Feature overview
- Rule writing guide
- Customization options
- Troubleshooting

---

**Happy drift-free coding! 🚀**
