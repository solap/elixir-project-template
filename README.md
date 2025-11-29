# Elixir Project Template

Production-ready template for Elixir/Phoenix projects with quality tooling, CI/CD, and AI-assisted development capabilities. Get from zero to productive in minutes with automated setup, comprehensive testing infrastructure, and Claude Code integration for autonomous development.

**Version:** 1.0.0

## ⚡ Quick Start

### Create a New Project (Recommended)

```bash
# Bootstrap a new Phoenix project with template
./bin/create-project my_app --type phoenix

# Or create a library
./bin/create-project my_lib --type library
```

### Add Template to Existing Project

```bash
# Interactive setup (recommended)
./bin/setup-template

# Or manual copy
cp -r elixir-project-template/* /path/to/your/project/
cd /path/to/your/project
./bin/setup-template
```

### Validate Setup

```bash
make validate
make quality
```

## 🤖 For AI Assistants (Claude Code)

**If you're an AI assistant being asked to use this template:**

👉 **Read `ADAPTATION-GUIDE.md` first** - Complete instructions for adapting this template, including customization, user questions, and verification.

👉 **Load context with `/prime`** - Initialize project understanding at session start.

👉 **Follow safety guidelines** - Read `.claude/context/safety-checklist.md` before making changes.

## 📖 For Developers

Continue reading for what's included and detailed usage instructions.

## What's Included

### Quality Tooling Configs

These configuration files enforce code quality, security, and documentation standards:

- **`.credo.exs`** - Credo static code analysis configuration (strict mode enabled)
- **`.formatter.exs`** - Code formatting configuration for `mix format`
- **`.sobelow-conf`** - Sobelow security analysis configuration
- **`.doctor.exs`** - Documentation coverage checking configuration

### Claude Code AI Assistant

Files that help AI coding assistants understand your project and work effectively:

- **`CLAUDE.md`** - Agent guidance with development principles, conventions, and safety guardrails
- **`.claude/commands/`** - Custom slash commands for AI-assisted development
  - `/prime` - Initialize project context with safety checks
  - `/start` - Start development server
  - `/plan-feature` - Create detailed feature plans with rollback strategies
  - `/plan-bug` - Create bug fix plans with root cause analysis
  - `/plan-chore` - Create maintenance/refactoring plans
  - `/implement-plan` - Execute plans step-by-step with validation
  - `/quick-fix` - Rapid fixes for simple bugs
  - `/review-plan` - Review plan quality and completeness
  - `/validate-setup` - Verify project configuration
- **`.claude/context/`** - Agentic development guidance
  - `agentic-best-practices.md` - Autonomous development patterns
  - `safety-checklist.md` - Pre-flight and validation checklists

### Automation Scripts

Reduce manual work with automated setup and validation:

- **`bin/setup-template`** - Interactive configuration for project customization
- **`bin/validate-template`** - Validate template integrity and configuration
- **`bin/create-project`** - Bootstrap new projects with template applied
- **`scripts/setup-git-hooks.sh`** - Install pre-commit/pre-push hooks
- **`scripts/check-quality.sh`** - Run quality checks with colored output

### Configuration Templates

Ready-to-use templates for new projects:

- **`mix.exs.template`** - Mix project with quality tools pre-configured
- **`config/*.template`** - Config files for all environments
- **`test/test_helper.exs.template`** - Test setup with best practices
- **`.tool-versions.example`** - Version management example

### CI/CD Workflows

GitHub Actions workflows for automated quality checks:

- **`.github/workflows/quality-checks.yaml`** - Comprehensive quality checks (format, credo, sobelow, dialyzer, tests)
- **`.github/workflows/ci.yaml`** - Multi-version testing matrix (Elixir 1.17-1.18, OTP 27-28)

### Build Automation

- **`Makefile`** - Common development commands (`make quality`, `make test`, `make dev`, etc.)

## Documentation

- **[AGENTIC-DEVELOPMENT.md](docs/AGENTIC-DEVELOPMENT.md)** - Guide for using Claude Code effectively
- **[TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md)** - Common issues and solutions
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - How to contribute improvements
- **[CHANGELOG.md](CHANGELOG.md)** - Version history and migration guides

## Detailed Usage

### Option 1: Automated Setup (Recommended)

Use the provided scripts for the easiest setup experience:

```bash
# Create new project
./bin/create-project my_app --type phoenix

# Customize interactively
cd my_app
./bin/setup-template

# Validate
make validate
make quality
```

### Option 2: Manual Setup

### 1. Copy Files to Your Project

Copy the entire template directory contents into your new Elixir project:

```bash
# From outside the container
cp -r elixir-project-template/* /path/to/your/elixir/project/
cp -r elixir-project-template/.* /path/to/your/elixir/project/ 2>/dev/null || true
```

Or selectively copy what you need:

```bash
# Just quality configs
cp elixir-project-template/.credo.exs your-project/
cp elixir-project-template/.formatter.exs your-project/
cp elixir-project-template/.sobelow-conf your-project/
cp elixir-project-template/.doctor.exs your-project/

# Claude Code commands
cp -r elixir-project-template/.claude your-project/
cp elixir-project-template/CLAUDE.md your-project/

# GitHub workflows
cp -r elixir-project-template/.github your-project/

# Makefile
cp elixir-project-template/Makefile your-project/
```

### 2. Customize for Your Project

After copying, customize these files for your specific project:

#### Update `CLAUDE.md`

Edit the "Project Overview" section with your project details:
- What the application does
- Key technologies used (Phoenix, Ecto, Absinthe, etc.)
- Architecture notes
- Project-specific conventions

#### Update `.formatter.exs`

Adjust the `import_deps` list based on your dependencies:
```elixir
import_deps: [:phoenix, :ecto, :absinthe]  # Add/remove as needed
```

#### Update `.doctor.exs`

Set appropriate documentation coverage thresholds:
```elixir
min_overall_doc_coverage: 40  # Adjust based on your standards
moduledoc_required: true      # Set to false for legacy projects
```

#### Update `.sobelow-conf`

Add any project-specific security check ignores:
```elixir
ignore: ["Config.CSP"],  # Add checks to ignore
ignore_files: []         # Add files to skip
```

#### Update GitHub Workflows

- Change database service configurations if not using PostgreSQL
- Add MongoDB, Redis, or other services as needed
- Adjust Elixir/OTP version matrix based on your requirements
- Remove `mix hex.audit` if you don't need dependency audits

#### Update Makefile

- Remove database commands if not using Ecto
- Add project-specific commands
- Customize the `dev` command for your start script

### 3. Install Required Dependencies

Add these tools to your `mix.exs` dependencies:

```elixir
def deps do
  [
    # ... your existing deps ...

    # Quality tools (only in dev/test)
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:sobelow, "~> 0.13", only: :dev, runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
    {:doctor, "~> 0.22", only: :dev, runtime: false},
    {:ex_doc, "~> 0.35", only: :dev, runtime: false},
    {:excoveralls, "~> 0.18", only: :test},
  ]
end
```

### 4. Run Initial Setup

```bash
# Install dependencies
mix deps.get

# Format code
mix format

# Run quality checks
make quality
```

## Using the Quality Tools

### Quick Commands

```bash
make quality    # Run all quality checks
make test       # Run tests
make dev        # Start development server
make help       # See all available commands
```

### Individual Quality Checks

```bash
mix format              # Format code
mix credo               # Static analysis
mix sobelow --config    # Security analysis
mix dialyzer            # Type checking
mix doctor              # Documentation coverage
mix test                # Run tests
```

## Using Claude Code Commands

Once `.claude/commands/` is copied to your project, you can use these commands in Claude Code:

### Planning a Feature

```
/plan-feature Add user authentication with email/password
```

This creates a detailed plan in `specs/features/user-authentication-feature.md` including:
- Feature description and user story
- Implementation phases
- Step-by-step tasks
- Testing strategy
- Acceptance criteria

### Implementing the Plan

```
/implement-plan specs/features/user-authentication-feature.md
```

Claude will read the plan and implement it step by step, running validation commands at the end.

### Starting a New Session

```
/prime
```

This helps Claude understand your project structure and conventions at the start of each session.

## CI/CD Integration

The GitHub Actions workflows will automatically:

### On Every Pull Request:
- Check code formatting
- Run Credo analysis
- Run security checks
- Compile with warnings as errors
- Run all tests
- Generate coverage reports
- Check for unused/retired dependencies

### Multi-Version Testing:
- Tests against Elixir 1.17 & 1.18
- Tests against OTP 27 & 28
- Ensures compatibility across versions

## Customization Tips

### For Non-Phoenix Projects

Remove Phoenix-specific items:
- Remove `phoenix` from `.formatter.exs` import_deps
- Remove `mix phx.server` from Makefile and `/start` command
- Remove database setup commands if not using Ecto

### For GraphQL Projects

Keep Absinthe in `.formatter.exs`:
```elixir
import_deps: [:absinthe]
```

### For Projects Without Databases

Remove from Makefile:
- All `db-*` targets
- Ecto-related commands

Remove from `.formatter.exs`:
- `:ecto` and `:ecto_sql` from import_deps

## Quality Standards Enforced

These configurations enforce:

✅ **Code Quality**
- Consistent formatting (mix format)
- No compile warnings
- High-priority Credo checks pass
- Clean code patterns

✅ **Security**
- Sobelow security scans
- No known vulnerable dependencies
- Security best practices

✅ **Type Safety**
- Dialyzer type checking
- Type specifications encouraged

✅ **Documentation**
- Module documentation coverage
- Public function documentation
- Minimum overall coverage thresholds

✅ **Testing**
- Test coverage tracking
- Async test execution
- Coverage reporting

## Benefits

### For Developers

- **Faster onboarding**: Clear conventions and automated checks
- **Better code quality**: Catches issues before code review
- **Security built-in**: Automated security scanning
- **Consistent style**: Automated formatting

### For AI Assistants (Claude Code)

- **Better context**: `CLAUDE.md` provides project conventions
- **Structured workflow**: Slash commands for planning and implementing
- **Quality built-in**: Plans include validation steps
- **Documentation**: Self-documenting plans in `specs/`

## Maintenance

### Updating Tools

Check for new versions periodically:

```bash
mix hex.outdated
```

Update and test:

```bash
mix deps.update credo sobelow dialyxir doctor
mix quality
```

### Adjusting Standards

As your project matures, adjust thresholds:

- Increase `min_overall_doc_coverage` in `.doctor.exs`
- Enable more Credo checks in `.credo.exs`
- Stricter Dialyzer settings
- Higher test coverage requirements

## Troubleshooting

### Dialyzer Takes Too Long

Dialyzer can be slow on first run. Speed it up:

```bash
# Build PLT files once
mix dialyzer --plt

# Use in CI
mix dialyzer --ignore-exit-status
```

### Credo Too Strict

If Credo is too strict for your project:

```elixir
# In .credo.exs, set strict to false
strict: false,
```

### Formatting Conflicts

If formatting conflicts with your style:

```elixir
# In .formatter.exs, add custom config
inputs: ["*.{ex,exs}", "{config,lib,test}/**/*.{ex,exs}"],
line_length: 120,  # Adjust as needed
```

## Contributing

This template is extracted from a production Elixir/Phoenix project. Feel free to customize it for your needs.

## License

Use freely in your projects. Originally based on configurations from the Kuali Platform project.
