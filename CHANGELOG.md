# Changelog

All notable changes to this template will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-01-22

### Added

**Automation & Scripts:**
- Interactive setup script (`bin/setup-template`) for project customization
- Validation script (`bin/validate-template`) for template integrity checks
- Project generator script (`bin/create-project`) to bootstrap new projects
- Git hooks setup script (`scripts/setup-git-hooks.sh`)
- Quality check script (`scripts/check-quality.sh`) with colored output

**Configuration Templates:**
- `mix.exs.template` with quality tools pre-configured
- Config templates for all environments (dev, test, runtime)
- `test_helper.exs.template` with testing best practices
- `.tool-versions.example` for version management

**Claude Code Enhancements:**
- Enhanced `/prime` command with safety checks and context loading
- New `/validate-setup` command for setup verification
- New `/quick-fix` command for rapid bug fixes
- New `/review-plan` command for plan quality assurance

**Agentic Development:**
- `agentic-best-practices.md` - Comprehensive guide for autonomous development
- `safety-checklist.md` - Safety validation for all code changes
- Enhanced existing commands with rollback strategies

**Quality Tools:**
- Comprehensive `.credo.exs` with documentation
- `.formatter.exs` with usage examples
- `.doctor.exs` with threshold guidance
- `.sobelow-conf` with security best practices

**Documentation:**
- VERSION file for template versioning
- CHANGELOG for tracking changes
- Structured `specs/` directory for features, bugs, chores
- Enhanced README with Quick Start section

**Infrastructure:**
- Git hooks for pre-commit and pre-push quality checks
- Directory structure for examples and documentation
- `.gitkeep` files for empty but important directories

### Changed
- Updated CLAUDE.md with agentic development guidelines
- Enhanced Makefile with new targets
- Improved GitHub workflow error handling
- Better `.gitignore` coverage

### Initial Release
This is the first production-ready release of the Elixir Project Template, extracted and enhanced from enterprise usage.

**Core Features:**
- Quality tooling configurations (Credo, Formatter, Sobelow, Doctor, Dialyzer)
- GitHub Actions CI/CD workflows
- Claude Code slash commands for AI-assisted development
- Makefile with common development commands
- Comprehensive AI agent guidance

---

## Version History

### Versioning Scheme

This template follows semantic versioning:
- **Major** (X.0.0): Breaking changes, major restructuring
- **Minor** (1.X.0): New features, enhancements (backward compatible)
- **Patch** (1.0.X): Bug fixes, documentation updates

### Migration Guides

When updating your project to a newer template version:

1. Review the CHANGELOG for breaking changes
2. Update specific files that changed (listed in changelog)
3. Run `bin/validate-template` to verify compatibility
4. Test your project thoroughly
5. Update your project's VERSION reference (if using template version tracking)

### Future Releases

See [CONTRIBUTING.md](CONTRIBUTING.md) for how to contribute to the template.

---

[1.0.0]: https://github.com/your-org/elixir-project-template/releases/tag/v1.0.0
