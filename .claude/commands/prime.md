# Prime
Useful to initialize the project context at the beginning of a new Claude Code session.

> Execute the following sections to understand the codebase then summarize your understanding.

## Safety Checks

1. Check for uncommitted changes:
   ```bash
   git status --short
   ```
   If there are uncommitted changes, warn the user.

2. Validate template setup (if validation script exists):
   ```bash
   [ -x bin/validate-template ] && bin/validate-template || echo "Validation script not found"
   ```

## Context Loading

1. Run to see project structure:
   ```bash
   git ls-files
   ```

2. Read project configuration and guidance:
   - CLAUDE.md (AI agent guidance)
   - README.md (project overview)
   - .claude/context/agentic-best-practices.md (if exists)
   - .claude/context/safety-checklist.md (if exists)

3. Read project-specific files:
   - mix.exs (dependencies and project config)
   - Look for any ARCHITECTURE.md or docs/ files

4. Check for existing plans:
   ```bash
   find specs -name "*.md" 2>/dev/null || echo "No specs directory"
   ```

## Summarize Understanding

Provide a summary including:
- Project name and type
- Key technologies and dependencies
- Main application contexts/modules
- Development conventions from CLAUDE.md
- Any active plans in specs/
- Recommended next steps for this session
