# Elixir Project Template

Production-ready template for Elixir/Phoenix projects with AI-assisted development. Just tell Claude what you want - it handles everything.

**Version:** 1.0.0 | **Repository:** https://github.com/solap/elixir-project-template

---

## 🧑‍💻 For Humans (You!)

**You don't need to do anything manually. Just use these commands with Claude Code:**

### Start Every Session
```
/prime
```
This loads the project context. Do this once at the start of each session.

### Create New Projects
```
Create a new Phoenix app called my_app using this template
```
Or:
```
Create a new Elixir library called my_lib using this template
```

### Add Features
```
Add user authentication with email and password
```

### Fix Bugs
```
Fix: Users can't login on mobile devices
```

### Refactor/Maintain
```
Refactor the validation logic into reusable helpers
```

### Quick Fixes (Simple Bugs)
```
/quick-fix Fix typo in welcome email subject line
```

### Review What AI Planned
Plans are saved in `specs/features/`, `specs/bugs/`, or `specs/chores/`. You can review them before implementation.

**That's it! Just describe what you want in plain English.**

---

## 🤖 For AI Assistants (Claude Code)

**👉 Read `CLAUDE.md` first** - Contains all development principles, conventions, and safety guidelines.

**Available Commands:**
- `/prime` - Initialize context (reads CLAUDE.md, checks for uncommitted changes, loads safety checklists)
- `/plan-feature` - Create feature implementation plan
- `/plan-bug` - Create bug fix plan with root cause analysis
- `/plan-chore` - Create maintenance/refactoring plan
- `/implement-plan` - Execute a plan step-by-step with validation
- `/quick-fix` - Rapid fixes for simple bugs (no plan needed)
- `/review-plan` - Review plan quality and completeness
- `/validate-setup` - Verify project configuration
- `/start` - Start development server

**Key Files:**
- `CLAUDE.md` - Project conventions and AI guidance (read this!)
- `.claude/context/agentic-best-practices.md` - Autonomous development patterns
- `.claude/context/safety-checklist.md` - Pre-flight and validation checklists
- `ADAPTATION-GUIDE.md` - How to adapt this template for new projects

**Before making changes:**
1. Run `/prime` to load context
2. Read `.claude/context/safety-checklist.md`
3. Understand requirements fully
4. Follow patterns in `CLAUDE.md`

---

## 📦 What's Included

### Automation Scripts
- **`bin/setup-template`** - Interactive project customization
- **`bin/validate-template`** - Validate template integrity
- **`bin/create-project`** - Bootstrap new projects
- **`scripts/setup-git-hooks.sh`** - Install quality check hooks
- **`scripts/check-quality.sh`** - Run all quality checks

### Quality Tooling
- **`.credo.exs`** - Static code analysis (strict mode)
- **`.formatter.exs`** - Code formatting configuration
- **`.sobelow-conf`** - Security analysis
- **`.doctor.exs`** - Documentation coverage
- **Dialyzer** - Type checking (via mix.exs)

### Configuration Templates
- **`mix.exs.template`** - Mix project with quality tools pre-configured
- **`config/*.template`** - Config files for all environments (dev, test, runtime)
- **`test/test_helper.exs.template`** - Test setup with best practices
- **`.tool-versions.example`** - Version management (asdf/mise)

### GitHub Integration
- **`.github/workflows/`** - CI/CD for quality checks and multi-version testing
- **`.github/ISSUE_TEMPLATE/`** - Bug reports and feature requests
- **`.github/PULL_REQUEST_TEMPLATE.md`** - PR checklist

### Documentation
- **`CLAUDE.md`** - AI agent guidance (conventions, patterns, safety)
- **`docs/AGENTIC-DEVELOPMENT.md`** - Using Claude Code effectively
- **`docs/TROUBLESHOOTING.md`** - Common issues and solutions
- **`CONTRIBUTING.md`** - How to contribute improvements
- **`CHANGELOG.md`** - Version history and migration guides

---

## 🚀 Typical Workflow

### 1. Start New Project
Tell Claude:
> "Create a new Phoenix app called my_blog using this template"

Claude will:
- Run `bin/create-project my_blog --type phoenix`
- Apply template files
- Set up git repository
- Configure everything

### 2. Add a Feature
Tell Claude:
> "Add user authentication with email/password"

Claude will:
- Run `/prime` to load context
- Create plan in `specs/features/user-auth-feature.md`
- Show you the plan for review
- Implement it step-by-step after approval
- Run all quality checks
- Report completion

### 3. Fix a Bug
Tell Claude:
> "Fix: Emails aren't sending to Gmail addresses"

Claude will:
- Analyze the problem
- Create fix plan in `specs/bugs/`
- Implement minimal fix
- Add regression test
- Verify all tests pass

### 4. Refactor
Tell Claude:
> "Extract the validation logic into reusable helper modules"

Claude will:
- Plan the refactoring in `specs/chores/`
- Show you the plan
- Execute with frequent test runs
- Ensure zero behavior changes

---

## ⚙️ Manual Setup (If Needed)

If you prefer to set things up manually:

```bash
# Clone this template
git clone https://github.com/solap/elixir-project-template.git
cd elixir-project-template

# Create new project from scratch
mix new my_app
cd my_app

# Copy template files
cp -r /path/to/elixir-project-template/bin .
cp -r /path/to/elixir-project-template/.claude .
cp -r /path/to/elixir-project-template/.github .
cp /path/to/elixir-project-template/.credo.exs .
cp /path/to/elixir-project-template/.formatter.exs .
# ... etc

# Run interactive setup
./bin/setup-template

# Validate
make validate
make quality
```

But really, just tell Claude to do it!

---

## 📚 Documentation

- **[CLAUDE.md](CLAUDE.md)** - For AI: Development principles and conventions
- **[AGENTIC-DEVELOPMENT.md](docs/AGENTIC-DEVELOPMENT.md)** - For Humans: Using Claude Code effectively
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute improvements
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and migration guides

---

## 🎯 Success Metrics

This template enables:
- ⚡ **5-minute project setup** - From template to working project
- 🤖 **<5% human intervention** - AI handles 95%+ of development
- ✅ **Zero-config quality** - All checks pass on first run
- 🛡️ **Safe experimentation** - Validation checkpoints prevent issues
- 🚀 **Production-ready** - Battle-tested patterns and comprehensive docs

---

## 📝 License

Use freely in your projects.

## 🙏 Acknowledgments

Built with [Claude Code](https://claude.com/claude-code) for autonomous development.
