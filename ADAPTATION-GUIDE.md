# Template Adaptation Guide for AI Assistants

This document provides instructions for AI assistants (like Claude Code) on how to adapt this template directory for a new Elixir/Phoenix project.

## What This Template Contains

This is a reusable Elixir project template with:
- Quality tooling configurations (Credo, Formatter, Sobelow, Doctor)
- Claude Code slash commands for AI-assisted development
- GitHub Actions CI/CD workflows
- Makefile with common development commands
- AI agent guidance document (CLAUDE.md)
- Standard .gitignore

## When to Use This Template

Use this template when:
- Setting up a new Elixir or Phoenix project
- Adding quality tooling to an existing project
- Configuring Claude Code assistance for an Elixir project
- Setting up CI/CD for an Elixir project

## Adaptation Process

### Step 1: Understand the Target Project

First, ask the user or examine the target project to determine:
- **Project type**: Phoenix web app? GraphQL API? Library? Umbrella app?
- **Database**: PostgreSQL (Ecto)? MongoDB? Both? None?
- **Key dependencies**: Phoenix? Absinthe (GraphQL)? Phoenix LiveView? Oban?
- **Target location**: Where should the files be copied?
- **Existing configs**: Does the project already have any of these configs?

### Step 2: Copy Files to Target Project

Copy the template files to the target project:

```bash
# Copy all files (from the template directory to target)
cp -r /path/to/elixir-project-template/* /path/to/target-project/
cp -r /path/to/elixir-project-template/.* /path/to/target-project/ 2>/dev/null || true
```

**Important**: Ask the user before overwriting existing files. Offer to:
- Merge configurations if files already exist
- Skip files they don't want
- Show diffs before overwriting

### Step 3: Customize `.formatter.exs`

Update the `import_deps` list based on the project's dependencies in `mix.exs`:

```elixir
# Check mix.exs for these dependencies and add to import_deps:
import_deps: [
  :phoenix,              # If using Phoenix
  :ecto,                 # If using Ecto
  :ecto_sql,             # If using Ecto with SQL
  :absinthe,             # If using GraphQL/Absinthe
  :phoenix_live_view,    # If using LiveView
]
```

Also update subdirectories if needed:
```elixir
subdirectories: ["priv/*/migrations"]  # Standard for Ecto
# Or for umbrella apps:
subdirectories: ["apps/*/priv/*/migrations"]
```

### Step 4: Customize `CLAUDE.md`

Update the "Project Overview" section with project-specific details:

1. **What the application does**: Replace generic description with actual project purpose
2. **Key technologies**: List actual dependencies (Phoenix, Ecto, Absinthe, LiveView, Oban, etc.)
3. **Architecture notes**: Add any project-specific architecture details
4. **Project-specific conventions**: Add team conventions, naming patterns, etc.

Ask the user or infer from the codebase:
- What problem does this app solve?
- What are the main modules/contexts?
- Any special patterns or conventions?
- Testing approach?

### Step 5: Customize `.doctor.exs`

Adjust documentation coverage thresholds based on project maturity:

```elixir
# For new projects - be strict:
min_overall_doc_coverage: 80,
moduledoc_required: true,

# For existing/legacy projects - be lenient:
min_overall_doc_coverage: 40,
moduledoc_required: false,

# Ignore paths that don't need docs:
ignore_paths: [
  ~r/^lib\/.*_web\/schema\/.*/,      # GraphQL schemas often don't need docs
  ~r/^lib\/.*_web\/resolvers\/.*/,   # Resolvers are often self-documenting
  ~r/^test\/.*/,                      # Tests don't need module docs
]
```

### Step 6: Customize `.sobelow-conf`

Add project-specific security check ignores if needed:

```elixir
# Common ignores:
ignore: [
  "Config.CSP",        # If not using Content Security Policy
  "Config.HTTPS",      # If HTTPS is handled by reverse proxy
  "XSS.SendResp",      # If you have safe HTML rendering
],
ignore_files: [
  "lib/project/pdf_helper.ex",  # File-specific ignores
]
```

### Step 7: Customize GitHub Workflows

Update `.github/workflows/*.yaml` based on project needs:

**Database services**:
- Keep PostgreSQL service if using Ecto
- Remove if not using a database
- Add MongoDB, Redis, etc. if needed

**Elixir/OTP versions**:
```yaml
# Update matrix based on .tool-versions or project requirements
matrix:
  elixir: ['1.17', '1.18']  # Current project versions
  otp: ['27', '28']
```

**Remove steps if not needed**:
- Remove `mix hex.audit` if not checking dependencies
- Remove `mix deps.unlock --check-unused` if not strict about unused deps
- Remove `mix ecto.*` commands if not using Ecto

**Add project-specific steps**:
- Asset compilation if using Phoenix
- Additional services (Redis, Elasticsearch, etc.)
- Custom mix tasks

### Step 8: Customize Makefile

Update Makefile targets based on project:

**If NOT using Phoenix**:
- Remove or change `dev:` target (use `iex -S mix` instead of `mix phx.server`)
- Remove `/start` command or update it

**If NOT using Ecto**:
- Remove all `db-*` targets
- Remove database-related commands

**Add project-specific targets**:
```makefile
## docker-up: Start Docker services
docker-up:
	docker-compose up -d

## seed: Seed the database
seed:
	mix run priv/repo/seeds.exs
```

### Step 9: Customize Claude Commands

Update `.claude/commands/start.md` based on how the project starts:

```markdown
# For Phoenix:
mix phx.server

# For non-Phoenix:
iex -S mix

# For projects with Docker:
docker-compose up && mix phx.server
```

### Step 10: Add Required Dependencies

Check the target project's `mix.exs` and add missing quality tool dependencies:

```elixir
defp deps do
  [
    # ... existing deps ...

    # Add these if missing (dev/test only):
    {:credo, "~> 1.7", only: [:dev, :test], runtime: false},
    {:sobelow, "~> 0.13", only: :dev, runtime: false},
    {:dialyxir, "~> 1.4", only: [:dev], runtime: false},
    {:doctor, "~> 0.22", only: :dev, runtime: false},
    {:ex_doc, "~> 0.35", only: :dev, runtime: false},
    {:excoveralls, "~> 0.18", only: :test},
  ]
end
```

After adding, run:
```bash
mix deps.get
mix compile
```

### Step 11: Verify and Test

After adaptation, run these commands to verify everything works:

```bash
# Format all code
mix format

# Compile with warnings as errors
mix compile --all-warnings --warnings-as-errors

# Run quality checks
mix credo --min-priority high
mix sobelow --config
mix doctor

# Run tests
mix test

# Or use Makefile
make quality
```

### Step 12: Create `.tool-versions` if Missing

If the project doesn't have a `.tool-versions` file (for asdf version manager), create one:

```bash
# Check current versions
elixir --version
erl -eval 'erlang:display(erlang:system_info(otp_release)), halt().' -noshell

# Create .tool-versions
echo "elixir 1.18.0" > .tool-versions
echo "erlang 28.0" >> .tool-versions
```

## Common Customization Patterns

### For GraphQL/Absinthe Projects

1. Add to `.formatter.exs`:
   ```elixir
   import_deps: [:absinthe, :absinthe_plug]
   ```

2. Add to `CLAUDE.md` conventions:
   - Resolver naming patterns
   - Schema organization
   - Query/mutation testing approaches

### For Phoenix LiveView Projects

1. Add to `.formatter.exs`:
   ```elixir
   import_deps: [:phoenix_live_view],
   plugins: [Phoenix.LiveView.HTMLFormatter],
   ```

2. Update `.doctor.exs` to ignore LiveView modules if they don't need docs

### For Umbrella Apps

1. Update `.formatter.exs`:
   ```elixir
   subdirectories: ["apps/*/priv/*/migrations"],
   inputs: [
     "*.{ex,exs}",
     "{config,apps}/**/*.{ex,exs}"
   ]
   ```

2. Update `.credo.exs` to include umbrella paths:
   ```elixir
   included: [
     "apps/*/lib/",
     "apps/*/test/",
   ]
   ```

### For Libraries (Non-Phoenix)

1. Remove Phoenix-specific configs
2. Simplify Makefile (remove db-*, remove phx.server)
3. Update `CLAUDE.md` to focus on library development patterns
4. Remove database service from GitHub workflows

## What to Ask the User

Before starting adaptation, gather this information:

1. **"What type of Elixir project is this?"**
   - Phoenix web application
   - GraphQL API
   - Library/package
   - Umbrella application
   - Other

2. **"What database are you using?"**
   - PostgreSQL with Ecto
   - MongoDB
   - Both
   - None

3. **"What are your main dependencies?"**
   - Look at mix.exs or ask directly
   - Phoenix, LiveView, Absinthe, Oban, etc.

4. **"What's your documentation coverage goal?"**
   - Strict (80%+) for new projects
   - Moderate (40-60%) for existing projects
   - Lenient for legacy projects

5. **"Do you want me to overwrite existing config files or merge them?"**
   - Check for existing .credo.exs, .formatter.exs, etc.
   - Offer to show diffs

6. **"What Elixir and OTP versions are you targeting?"**
   - Check .tool-versions or ask
   - Update GitHub workflows accordingly

## Post-Adaptation Steps

After adapting the template, guide the user to:

1. **Review changes**: `git status` and `git diff` to see what was added/changed
2. **Install dependencies**: `mix deps.get`
3. **Run quality checks**: `make quality` or individual commands
4. **Try Claude commands**: `/prime` to initialize context
5. **Commit changes**: Create a commit with the new tooling setup

## Example Adaptation Session

```
User: "Can you set up this template for my Phoenix + GraphQL project?"

Claude:
1. First, let me understand your project:
   - Reads mix.exs to identify dependencies
   - Checks for existing config files
   - Notes it's Phoenix + Absinthe

2. I'll copy the template files to your project:
   - Shows what will be copied
   - Asks about overwriting existing files
   - Copies files

3. Now customizing for your project:
   - Updates .formatter.exs with [:phoenix, :ecto, :absinthe]
   - Updates CLAUDE.md with GraphQL patterns
   - Adjusts .doctor.exs to ignore GraphQL schema paths
   - Updates GitHub workflows to keep PostgreSQL
   - Keeps Makefile as-is (Phoenix project)

4. Adding missing dependencies to mix.exs:
   - Adds credo, sobelow, dialyxir, doctor, excoveralls
   - Runs mix deps.get

5. Verification:
   - Runs mix format
   - Runs mix compile --warnings-as-errors
   - Runs make quality
   - All checks pass!

6. Summary: Your project now has:
   ✓ Quality tooling configured
   ✓ Claude Code commands ready
   ✓ CI/CD workflows set up
   ✓ 15 files added/updated

Next steps:
- Review changes with: git status && git diff
- Try /prime to initialize Claude context
- Run make quality to verify setup
```

## Troubleshooting

**Issue**: Dialyzer takes forever on first run
**Solution**: Build PLT files separately: `mix dialyzer --plt`

**Issue**: Formatter wants to change everything
**Solution**: Run `mix format` once, review changes, commit separately

**Issue**: Credo reports too many issues
**Solution**: Start with `mix credo --min-priority high`, address gradually

**Issue**: GitHub Actions failing on Dialyzer
**Solution**: Add `continue-on-error: true` to Dialyzer step initially

**Issue**: Tests failing after template setup
**Solution**: The template doesn't change test code - investigate test failures separately

## Quick Reference for Claude

When asked to "adapt this template" or "use this template for my project":

1. ✅ Ask about project type, database, dependencies
2. ✅ Copy files (ask before overwriting)
3. ✅ Customize .formatter.exs import_deps
4. ✅ Update CLAUDE.md with project specifics
5. ✅ Adjust .doctor.exs thresholds
6. ✅ Update GitHub workflows (services, versions)
7. ✅ Customize Makefile targets
8. ✅ Add missing deps to mix.exs
9. ✅ Run verification (format, compile, quality)
10. ✅ Summarize changes and next steps

## Files Summary

**Must customize for every project**:
- `.formatter.exs` - Update import_deps
- `CLAUDE.md` - Update project overview
- `.claude/commands/start.md` - Update start command

**Should review and adjust**:
- `.doctor.exs` - Adjust coverage thresholds
- `.sobelow-conf` - Add project-specific ignores
- `Makefile` - Add/remove targets
- `.github/workflows/*.yaml` - Adjust services and versions

**Usually fine as-is**:
- `.credo.exs` - Works for most projects
- `.gitignore` - Standard Elixir ignores
- `.claude/commands/` - Planning commands work generically

## Success Criteria

The adaptation is successful when:
- [ ] `mix format` runs without errors
- [ ] `mix compile --warnings-as-errors` succeeds
- [ ] `mix credo --min-priority high` passes
- [ ] `mix test` passes (existing tests still work)
- [ ] `make quality` runs successfully
- [ ] User can use `/prime` and other Claude commands
- [ ] GitHub Actions workflows are valid YAML
- [ ] Project-specific details are in CLAUDE.md