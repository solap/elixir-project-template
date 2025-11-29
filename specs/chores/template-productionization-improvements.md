# Chore: Template Productionization and Improvements

## Chore Description

This template was extracted from an enterprise Elixir/Phoenix project and needs to be enhanced to be production-ready for creating new Elixir projects with full agentic development capabilities in Claude "YOLO mode." The template currently provides quality tooling, CI/CD, and Claude Code commands but lacks several critical components to make it truly foolproof, safer, and easier to use for bootstrapping new projects. This chore will transform the template from a basic configuration copy into a robust, automated project generator that provides comprehensive guardrails, validation, testing infrastructure, and improved developer experience.

The improvements focus on:
1. **Automation** - Reducing manual steps through scripts and generators
2. **Safety** - Adding validation, guards, and clear error messages
3. **Completeness** - Providing missing infrastructure (mix.exs template, example files, testing setup)
4. **Developer Experience** - Better documentation, examples, and interactive setup
5. **Agentic Development** - Enhanced Claude Code commands with more context and safer execution

## Relevant Files

Use these files to resolve the chore:

- **README.md** - Contains template overview, needs updates for new automation scripts and improved setup flow
- **ADAPTATION-GUIDE.md** - Comprehensive guide for AI assistants, needs updates for new validation and automation features
- **CLAUDE.md** - AI agent guidance, needs expansion with agentic development best practices and safety guardrails
- **.claude/commands/*.md** - All command files need safety improvements and better context gathering
- **Makefile** - Needs additional targets for template management and validation
- **.github/workflows/*.yaml** - CI/CD workflows need improvements for better error handling and optional steps
- **.formatter.exs, .credo.exs, .doctor.exs, .sobelow-conf** - Quality tool configs are good but need comments explaining customization points
- **.gitignore** - Good coverage, may need specs/ directory handling

### New Files

- **bin/setup-template** - Interactive setup script for adapting template to new projects
- **bin/validate-template** - Validation script to verify template integrity and configuration
- **bin/create-project** - Generator script to bootstrap new Elixir project with template applied
- **.tool-versions.example** - Example version file showing recommended Elixir/Erlang versions
- **mix.exs.template** - Template mix.exs with quality tools pre-configured
- **config/config.exs.template** - Basic config template
- **config/dev.exs.template** - Development config template
- **config/test.exs.template** - Test config template
- **config/runtime.exs.template** - Runtime config template
- **lib/.gitkeep** - Preserve lib directory structure
- **test/test_helper.exs.template** - Test helper with best practices
- **test/support/.gitkeep** - Test support directory
- **.claude/commands/validate-setup.md** - Command to validate project setup is complete
- **.claude/commands/quick-fix.md** - Command for rapid bug fixes with minimal scope
- **.claude/commands/review-plan.md** - Command to review and improve existing plans
- **.claude/context/agentic-best-practices.md** - Document with agentic development patterns
- **.claude/context/safety-checklist.md** - Safety checklist for autonomous development
- **CONTRIBUTING.md** - Guide for contributing improvements back to template
- **CHANGELOG.md** - Track template changes and versions
- **examples/simple-api/** - Example project showing template in use
- **examples/phoenix-app/** - Example Phoenix app with template applied
- **.github/PULL_REQUEST_TEMPLATE.md** - PR template for projects using this template
- **.github/ISSUE_TEMPLATE/bug_report.md** - Bug report template
- **.github/ISSUE_TEMPLATE/feature_request.md** - Feature request template
- **scripts/check-quality.sh** - Standalone quality check script (no mix required)
- **scripts/setup-git-hooks.sh** - Install git pre-commit hooks for quality checks
- **docs/CUSTOMIZATION.md** - Deep dive guide on customizing the template
- **docs/AGENTIC-DEVELOPMENT.md** - Guide on using Claude Code effectively with this template
- **docs/TROUBLESHOOTING.md** - Common issues and solutions

## Step by Step Tasks

IMPORTANT: Execute every step in order, top to bottom.

### Step 1: Create Directory Structure

- Create `bin/` directory for executable scripts
- Create `specs/` directories for plans (features, bugs, chores)
- Create `examples/` directory with subdirectories for example projects
- Create `docs/` directory for extended documentation
- Create `scripts/` directory for supporting scripts
- Create `.claude/context/` directory for additional AI context
- Create `config/` directory for config templates
- Create `lib/` and `test/support/` directories with .gitkeep files
- Create `.github/ISSUE_TEMPLATE/` directory for issue templates

### Step 2: Add Interactive Setup Script

- Create `bin/setup-template` bash script that:
  - Asks user for project type (Phoenix web app, GraphQL API, library, umbrella)
  - Asks for database choice (PostgreSQL/Ecto, MongoDB, none)
  - Asks for main dependencies (Phoenix, LiveView, Absinthe, Oban, etc.)
  - Asks for documentation coverage targets (strict, moderate, lenient)
  - Asks for project name and description
  - Auto-detects existing files and asks about overwriting
  - Updates `.formatter.exs` with correct import_deps
  - Updates `CLAUDE.md` Project Overview section with user inputs
  - Updates `.doctor.exs` with chosen coverage thresholds
  - Updates `.sobelow-conf` if needed
  - Updates GitHub workflows based on project type
  - Updates Makefile based on project type
  - Generates `mix.exs` from template with correct app name and deps
  - Generates config files from templates
  - Runs `mix deps.get` and `mix compile`
  - Reports summary of changes made
  - Provides next steps to user
- Make script executable with proper shebang

### Step 3: Add Validation Script

- Create `bin/validate-template` bash script that:
  - Checks all required files exist
  - Validates YAML syntax in GitHub workflows
  - Validates Elixir syntax in config files
  - Checks for placeholder values that weren't replaced (e.g., "customize this")
  - Verifies `.formatter.exs` import_deps match dependencies in mix.exs
  - Checks that CLAUDE.md has project-specific content (not generic)
  - Validates Makefile targets are appropriate for project type
  - Checks git repository is initialized
  - Verifies `.tool-versions` or `.envrc` exists
  - Returns exit code 0 if valid, 1 if issues found
  - Provides clear actionable error messages
- Make script executable

### Step 4: Add Project Generator Script

- Create `bin/create-project` bash script that:
  - Takes project name as argument
  - Creates new directory for project
  - Initializes git repository
  - Runs `mix new` or `mix phx.new` based on project type
  - Copies template files into new project
  - Runs `bin/setup-template` in interactive mode
  - Initializes git with initial commit
  - Prints welcome message with next steps
- Make script executable

### Step 5: Add Configuration Templates

- Create `mix.exs.template` with:
  - Placeholders for project name, version, description
  - All quality tool dependencies pre-configured
  - Comments explaining each dependency
  - Recommended hex packages for common use cases
  - Proper version constraints (e.g., `~> 1.7` not `>= 1.0.0`)
- Create `config/config.exs.template` with:
  - Common configuration structure
  - Comments explaining each section
  - Logger configuration
  - Import statements for env configs
- Create `config/dev.exs.template` with:
  - Development-specific settings
  - Database pool size recommendations
  - Code reloading settings
- Create `config/test.exs.template` with:
  - Test database configuration
  - Sandbox settings for Ecto
  - Logger level for tests
- Create `config/runtime.exs.template` with:
  - Runtime configuration pattern
  - Environment variable reading
  - Production settings
- Create `test/test_helper.exs.template` with:
  - ExUnit.start configuration with recommended options
  - Ecto sandbox setup (if using Ecto)
  - Helper module patterns
  - Mock setup examples

### Step 6: Add .tool-versions Example

- Create `.tool-versions.example` with:
  - Current stable Elixir version (e.g., 1.18.1)
  - Current stable OTP version (e.g., 28.0)
  - Comments explaining version compatibility
  - Instructions for asdf users
  - Alternative for rtx/mise users

### Step 7: Enhance Claude Code Commands

- Update `.claude/commands/prime.md` to:
  - Run validation checks before priming
  - Load additional context from `.claude/context/` files
  - Check for uncommitted changes and warn
  - Read project-specific files (mix.exs, README.md, CLAUDE.md)
  - Summarize project architecture and conventions
- Update `.claude/commands/plan-feature.md` to:
  - Include safety checks before planning
  - Verify specs/ directory exists
  - Check for existing similar features
  - Validate plan format before writing
  - Add rollback strategy to plan format
- Update `.claude/commands/plan-bug.md` to:
  - Include reproduction test case requirement
  - Add regression prevention strategy
  - Require root cause analysis before solution
  - Check git history for related past bugs
- Update `.claude/commands/plan-chore.md` to:
  - Include impact analysis section
  - Require validation that no functionality breaks
  - Add performance impact consideration
- Update `.claude/commands/implement-plan.md` to:
  - Run validation checks before implementing
  - Create backup branch automatically
  - Run tests after each major step
  - Require green tests before marking complete
  - Add rollback instructions if tests fail
- Create `.claude/commands/validate-setup.md` that:
  - Runs bin/validate-template
  - Checks mix.exs dependencies are installed
  - Verifies all quality tools work
  - Tests that main commands run (mix compile, mix test)
  - Reports configuration status
- Create `.claude/commands/quick-fix.md` that:
  - Focuses on minimal changes for bugs
  - Requires single file changes when possible
  - Must include test for the fix
  - Limited to high-priority bugs only
- Create `.claude/commands/review-plan.md` that:
  - Reads existing plan file
  - Analyzes for completeness
  - Suggests improvements
  - Checks for security considerations
  - Validates acceptance criteria are measurable

### Step 8: Add Agentic Development Context

- Create `.claude/context/agentic-best-practices.md` with:
  - Autonomous development patterns
  - When to ask vs. when to decide
  - How to gather context effectively
  - Testing strategies for AI-written code
  - Code review checklist for self-review
  - Common pitfalls in agentic development
  - Examples of good and bad autonomous decisions
- Create `.claude/context/safety-checklist.md` with:
  - Pre-flight checks before code changes
  - Validation steps during implementation
  - Post-implementation verification
  - Security considerations checklist
  - Performance impact assessment
  - Backward compatibility checks
  - Database migration safety
  - Deployment considerations

### Step 9: Enhance Quality Tool Configurations

- Update `.credo.exs` to:
  - Add comments explaining each major section
  - Document which checks are disabled and why
  - Provide examples of when to customize
  - Add project-specific customization section at top
  - Include link to Credo documentation
- Update `.formatter.exs` to:
  - Add comments explaining import_deps
  - Document plugin usage
  - Explain subdirectories pattern
  - Provide customization examples
- Update `.doctor.exs` to:
  - Add comments explaining each threshold
  - Provide examples for different project maturities
  - Document ignore_paths patterns
  - Explain when to adjust thresholds
- Update `.sobelow-conf` to:
  - Add comments explaining each setting
  - Document common ignores and why
  - Provide security best practices link
  - Explain exit codes and CI usage

### Step 10: Add Git Hooks Setup

- Create `scripts/setup-git-hooks.sh` that:
  - Installs pre-commit hook running `mix format --check-formatted`
  - Installs pre-commit hook running `mix compile --warnings-as-errors`
  - Installs pre-commit hook running `mix credo --min-priority high`
  - Installs pre-push hook running full test suite
  - Makes hooks optional (can skip with --no-verify)
  - Provides option to uninstall hooks
  - Prints helpful message about hook behavior
- Create `scripts/check-quality.sh` that:
  - Runs all quality checks in correct order
  - Provides colored output for pass/fail
  - Shows progress for long-running checks (Dialyzer)
  - Exits on first failure with clear error
  - Can run individual checks via flags
  - Works even without mix installed (for CI)

### Step 11: Add Example Projects

- Create `examples/simple-api/` directory with:
  - Minimal Elixir application using the template
  - Single Phoenix context example
  - Basic REST API endpoints
  - Complete test coverage example
  - README explaining the example
- Create `examples/phoenix-app/` directory with:
  - Phoenix web application using template
  - LiveView example
  - Database integration with Ecto
  - GraphQL example with Absinthe
  - Comprehensive testing examples
  - README explaining architecture

### Step 12: Improve GitHub Workflows

- Update `.github/workflows/quality-checks.yaml` to:
  - Add job summary with pass/fail counts
  - Generate and upload coverage badge
  - Add annotations for failures
  - Cache Dialyzer PLT files properly
  - Make Dialyzer/Doctor/Sobelow truly optional based on dependencies
  - Add timeout protections
  - Improve error messages
- Update `.github/workflows/ci.yaml` to:
  - Add database matrix if needed (PostgreSQL 14, 15, 16)
  - Add job summary
  - Cache dependencies more effectively
  - Add step to validate mix.lock is up to date
  - Run on more events (release, workflow_dispatch)
- Create `.github/PULL_REQUEST_TEMPLATE.md` with:
  - Checklist for PR authors
  - Testing verification section
  - Breaking changes section
  - Documentation update confirmation
- Create `.github/ISSUE_TEMPLATE/bug_report.md` with:
  - Environment information section
  - Reproduction steps
  - Expected vs actual behavior
  - Stack traces and error messages
- Create `.github/ISSUE_TEMPLATE/feature_request.md` with:
  - User story format
  - Problem statement
  - Proposed solution
  - Alternatives considered

### Step 13: Add Comprehensive Documentation

- Create `docs/CUSTOMIZATION.md` with:
  - Deep dive on each config file
  - Customization patterns for different project types
  - Advanced configuration options
  - Performance tuning tips
  - Integration with other tools
- Create `docs/AGENTIC-DEVELOPMENT.md` with:
  - Guide on using Claude Code effectively
  - Workflow patterns with slash commands
  - Best practices for planning and implementing
  - How to review AI-generated code
  - When to intervene in autonomous development
  - Team adoption strategies
- Create `docs/TROUBLESHOOTING.md` with:
  - Common setup issues and solutions
  - Quality tool problems (Dialyzer slow, Credo too strict)
  - CI/CD issues and fixes
  - Mix dependency conflicts
  - Database connection problems
  - Test failures after setup
- Create `CONTRIBUTING.md` with:
  - How to contribute improvements
  - Template versioning approach
  - Testing changes to template
  - Documentation standards
  - Submitting issues and PRs
- Create `CHANGELOG.md` with:
  - Version numbering approach (semantic versioning)
  - Initial version entry documenting current state
  - Format for future entries
  - Migration guides between versions

### Step 14: Improve Main Documentation

- Update `README.md` to:
  - Add "Quick Start" section at the top
  - Reference new `bin/create-project` script
  - Add troubleshooting section with link to docs
  - Include badges (if publishing to GitHub)
  - Add table of contents
  - Include example command outputs
  - Add comparison with other templates
  - Link to example projects
- Update `ADAPTATION-GUIDE.md` to:
  - Reference new automation scripts
  - Update manual steps to reflect script availability
  - Add troubleshooting section
  - Include validation checklist using `bin/validate-template`
  - Update success criteria to use validation script
- Update `CLAUDE.md` to:
  - Add section on autonomous development guardrails
  - Include safety checklist reference
  - Add section on when to ask for human input
  - Document the new Claude commands
  - Add examples of good vs bad agentic behavior
  - Include rollback procedures
  - Add performance considerations
  - Document testing requirements for AI-written code

### Step 15: Add Makefile Enhancements

- Update `Makefile` to add:
  - `make validate` - run bin/validate-template
  - `make setup-hooks` - run scripts/setup-git-hooks.sh
  - `make example-simple` - cd to examples/simple-api
  - `make example-phoenix` - cd to examples/phoenix-app
  - `make docs-serve` - serve docs locally
  - `make template-test` - test template in tmp directory
  - Improve help text with better descriptions
  - Add color output for better visibility
  - Add `make paranoid` for strictest quality checks

### Step 16: Add Template Versioning

- Create `VERSION` file with:
  - Current version number (e.g., 1.0.0)
  - Semantic versioning approach documented
- Update scripts to check version compatibility
- Add version to README.md and documentation
- Add version check to bin/setup-template

### Step 17: Add Testing Infrastructure

- Create test structure for the template itself:
  - Script to test template generation in temp directory
  - Validation that all scripts execute without errors
  - Tests that example projects compile and run
  - CI job to test template integrity
- Add test matrix for different project types
- Add integration tests for complete workflow

### Step 18: Final Polish

- Ensure all scripts have proper error handling
- Add usage documentation to all scripts (--help flag)
- Ensure consistent formatting across all files
- Add copyright/license headers where appropriate
- Verify all links in documentation work
- Check for typos and grammar issues
- Ensure consistent terminology throughout
- Test the complete setup flow from scratch

### Step 19: Run Validation Commands

- Execute all validation commands to ensure template is complete

## Validation Commands

Execute every command to validate the chore is complete with zero regressions.

```bash
# Verify all directories exist
test -d bin && test -d specs && test -d docs && test -d examples && test -d scripts && test -d .claude/context && echo "✓ All directories created"

# Verify all scripts are executable
test -x bin/setup-template && test -x bin/validate-template && test -x bin/create-project && test -x scripts/setup-git-hooks.sh && test -x scripts/check-quality.sh && echo "✓ All scripts are executable"

# Verify template validation script works
bin/validate-template && echo "✓ Template validation passes"

# Test that all markdown files are valid
find . -name "*.md" -type f -exec echo "Checking {}" \; -exec grep -q "^#" {} \; && echo "✓ All markdown files have headers"

# Verify YAML syntax in workflows
find .github/workflows -name "*.yaml" -o -name "*.yml" -exec echo "Checking {}" \; && echo "✓ Workflow YAML files exist"

# Verify all template files exist
test -f mix.exs.template && test -f .tool-versions.example && test -f config/config.exs.template && test -f test/test_helper.exs.template && echo "✓ All template files created"

# Verify documentation is complete
test -f docs/CUSTOMIZATION.md && test -f docs/AGENTIC-DEVELOPMENT.md && test -f docs/TROUBLESHOOTING.md && test -f CONTRIBUTING.md && test -f CHANGELOG.md && echo "✓ All documentation files created"

# Verify all Claude commands exist
test -f .claude/commands/validate-setup.md && test -f .claude/commands/quick-fix.md && test -f .claude/commands/review-plan.md && echo "✓ All new Claude commands created"

# Verify context files exist
test -f .claude/context/agentic-best-practices.md && test -f .claude/context/safety-checklist.md && echo "✓ All context files created"

# Verify example projects exist
test -d examples/simple-api && test -d examples/phoenix-app && echo "✓ Example projects created"

# Verify issue templates exist
test -f .github/ISSUE_TEMPLATE/bug_report.md && test -f .github/ISSUE_TEMPLATE/feature_request.md && test -f .github/PULL_REQUEST_TEMPLATE.md && echo "✓ GitHub templates created"

# Verify scripts have help text
bin/setup-template --help && bin/validate-template --help && bin/create-project --help && echo "✓ Scripts have help documentation"

# Run Makefile validation targets
make help | grep -q "validate" && echo "✓ Makefile has new targets"

# Check that README has been updated
grep -q "Quick Start" README.md && echo "✓ README has Quick Start section"

# Check VERSION file exists
test -f VERSION && echo "✓ VERSION file created"

# Final validation
echo ""
echo "==================================="
echo "Template Productionization Complete"
echo "==================================="
echo "Run 'bin/validate-template' for full validation"
echo "Run 'make help' to see all available commands"
```

## Notes

### Key Improvements Summary

1. **Automation**: Scripts eliminate manual steps and reduce human error
2. **Safety**: Validation throughout the process with clear error messages
3. **Completeness**: All missing infrastructure added (configs, examples, tests)
4. **Developer Experience**: Interactive setup, comprehensive docs, examples
5. **Agentic Development**: Enhanced Claude commands with safety guardrails and context
6. **Maintenance**: Versioning, changelog, and contribution guidelines
7. **Testing**: Examples and validation ensure template always works

### Design Philosophy

- **Progressive Disclosure**: Simple quick-start, advanced docs for power users
- **Fail Fast**: Validate early and often with clear error messages
- **Escape Hatches**: All automation can be bypassed for manual control
- **Documentation as Code**: Examples that actually run
- **Trust but Verify**: AI autonomy with validation checkpoints

### Future Considerations

- Add support for umbrella applications
- Create web-based template customizer
- Add telemetry and analytics (opt-in) to improve template
- Create VS Code extension for template commands
- Add support for more databases (MongoDB, Redis, etc.)
- Create video tutorials for common workflows
- Add benchmarking infrastructure for performance testing
- Support for multiple languages (i18n) in generated code

### Rollback Strategy

If issues arise during implementation:
1. Each script should be independently functional
2. Test scripts in isolation before integration
3. Keep git history clean with atomic commits per step
4. Document known issues in TROUBLESHOOTING.md as discovered
5. All changes are additive - existing template functionality remains unchanged

### Success Metrics

The template is successful when:
- A developer can go from template to working project in under 5 minutes
- Claude Code can autonomously complete features with <5% human intervention
- Zero configuration bugs reported after setup
- All quality checks pass on first run after setup
- Example projects build and test successfully
- Documentation answers 95% of common questions
