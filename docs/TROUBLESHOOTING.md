# Troubleshooting

Common issues and solutions when using the Elixir Project Template.

## Setup Issues

### "mix command not found"

**Problem:** Elixir is not installed or not in PATH.

**Solution:**
```bash
# Install Elixir (macOS with Homebrew)
brew install elixir

# Or use asdf
asdf install elixir latest
```

### "Git repository not initialized"

**Problem:** Running setup script outside a git repository.

**Solution:**
```bash
git init
git add .
git commit -m "Initial commit"
```

## Quality Tool Issues

### Dialyzer Takes Too Long

**Problem:** First Dialyzer run is very slow.

**Solution:**
```bash
# Build PLT files once
mix dialyzer --plt

# Use continue-on-error in CI (already configured)
```

### Credo Too Strict

**Problem:** Too many Credo warnings.

**Solution:**
```elixir
# In .credo.exs, set strict to false
strict: false

# Or run with lower priority only
mix credo --min-priority high
```

### Formatting Conflicts

**Problem:** Formatter changes too much code.

**Solution:**
```bash
# Format once and commit separately
mix format
git add -A
git commit -m "Run mix format"

# Then continue with actual changes
```

## Compilation Issues

### Warnings as Errors Failing

**Problem:** Compilation fails due to warnings.

**Solution:**
```bash
# Find all warnings
mix compile --force

# Fix warnings, or temporarily compile without flag
mix compile
```

### Dependency Conflicts

**Problem:** Dependencies won't resolve.

**Solution:**
```bash
# Clean and retry
mix deps.clean --all
mix deps.get

# Or update deps
mix deps.update --all
```

## Test Issues

### Tests Failing After Setup

**Problem:** Tests fail immediately after applying template.

**Solution:**
The template doesn't modify test code. Check:
```bash
# Did mix.exs change?
git diff mix.exs

# Are all deps installed?
mix deps.get

# Is database set up? (if using Ecto)
mix ecto.create && mix ecto.migrate
```

### Async Test Failures

**Problem:** Tests fail when run with `async: true`.

**Solution:**
```elixir
# Tests that share state should not use async
use MyApp.DataCase, async: false
```

## Script Issues

### Scripts Not Executable

**Problem:** Permission denied when running scripts.

**Solution:**
```bash
chmod +x bin/*
chmod +x scripts/*
```

### Validation Script Warnings

**Problem:** bin/validate-template shows warnings.

**Solution:**
Review warnings - they're often safe but indicate customization needed:
```bash
# Run with verbose for details
bin/validate-template --verbose
```

## CI/CD Issues

### GitHub Actions Failing

**Problem:** Workflows failing in CI but passing locally.

**Solution:**
Check:
1. Database service is configured (PostgreSQL in workflows)
2. Environment variables are set
3. Secrets are configured (if needed)
4. Dependencies are cached correctly

### Dialyzer Failing in CI

**Problem:** Dialyzer succeeds locally but fails in CI.

**Solution:**
```yaml
# Already set to continue-on-error in quality-checks.yaml
- name: Run Dialyzer
  run: mix dialyzer
  continue-on-error: true
```

## Database Issues

### "Database does not exist"

**Problem:** Tests fail with database error.

**Solution:**
```bash
# Create test database
MIX_ENV=test mix ecto.create
MIX_ENV=test mix ecto.migrate
```

### Connection Refused

**Problem:** Can't connect to PostgreSQL.

**Solution:**
```bash
# Check PostgreSQL is running
brew services list  # macOS
systemctl status postgresql  # Linux

# Start if not running
brew services start postgresql  # macOS
sudo systemctl start postgresql  # Linux
```

## Getting Help

If you're still stuck:

1. **Check existing issues:** [GitHub Issues](https://github.com/your-org/elixir-project-template/issues)
2. **Search discussions:** Look for similar problems
3. **Create an issue:** Use the bug report template
4. **Include details:** Version, OS, error messages, steps to reproduce

## Common Error Messages

### "Protocol Ecto.Queryable not implemented"

**Cause:** Passing wrong type to Ecto query.

**Fix:** Ensure you're passing a queryable (schema module or Ecto.Query).

### "UndefinedFunctionError"

**Cause:** Function doesn't exist or module not imported.

**Fix:** Check spelling, import statement, or module name.

### "CompileError: undefined function"

**Cause:** Referencing undefined function.

**Fix:** Define the function or check if it's in another module.

## Prevention Tips

### Before Making Changes

```bash
# Always start from clean state
git status
mix deps.get
mix compile
mix test
```

### During Development

```bash
# Run checks frequently
mix format
mix compile --warnings-as-errors
mix test
```

### Before Committing

```bash
# Full quality check
make quality

# Or use git hooks
scripts/setup-git-hooks.sh
```
