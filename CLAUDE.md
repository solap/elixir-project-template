# Agent Guidance

This file provides guidance to AI engineering tools when working with code in this repository.

## Project Overview

This is an Elixir/Phoenix application. Customize this section with your project details.

## Core Development Principles

### 1. Test Through Public APIs

**Test behavior through the public interface, not internal implementation details.**

```elixir
# ❌ WRONG: Testing private function directly
test "some_private_function" do
  result = MyModule.some_private_function(args)
  # This couples tests to implementation
end

# ✅ CORRECT: Test through public API
test "public behavior" do
  result = MyModule.public_function(args)
  assert result == expected
end
```

### 2. Pattern Matching and Guards

**Use Elixir's pattern matching effectively:**

```elixir
# ✅ GOOD: Clear pattern matching
defp process(%{type: "active", data: data}) when is_list(data) do
  # Handle active with list data
end

defp process(%{type: "inactive"} = item) do
  # Handle inactive
end

# ❌ BAD: Complex conditionals
defp process(item) do
  if Map.get(item, :type) == "active" and is_list(Map.get(item, :data)) do
    # Less idiomatic
  end
end
```

## Testing Best Practices

1. **Use `async: true`** - Enable parallel test execution where possible
2. **Test public APIs** - Not private functions
3. **Use descriptive test names** - Clearly state what is being tested
4. **Follow AAA pattern** - Arrange, Act, Assert

## Development Cycle

Do the following as part of each development cycle:

1. `mix format` - Ensure code is formatted
2. `mix compile --all-warnings --warnings-as-errors` - Fix warnings
3. `mix credo --min-priority high` - Fix high priority issues
4. `mix test` - Ensure tests pass
5. `mix quality` - Run all quality checks (if configured)

## Common Development Commands

### Running the Application

```bash
mix deps.get          # Install dependencies
mix phx.server        # Start the server
iex -S mix phx.server # Start with IEx shell
```

### Testing

```bash
mix test                            # Run all tests
mix test test/path/to/test.exs      # Run specific test file
mix test test/path/to/test.exs:42   # Run test at line 42
mix test --failed                   # Run only failed tests
mix coveralls.html                  # Generate coverage report
```

### Quality Checks

```bash
mix format                                      # Format code
mix format --check-formatted                    # Check if formatted
mix compile --all-warnings --warnings-as-errors # Strict compilation
mix credo                                       # Static analysis
mix credo --min-priority high                   # High priority only
mix sobelow --config                            # Security analysis
mix dialyzer                                    # Type checking
mix doctor                                      # Documentation coverage
```

### Documentation

```bash
mix docs                      # Generate documentation
mix docs && open doc/index.html  # Generate and open
```

### Database (if using Ecto)

```bash
mix ecto.create              # Create database
mix ecto.migrate             # Run migrations
mix ecto.rollback            # Rollback last migration
mix ecto.gen.migration name  # Generate migration
```

## Code Conventions

### Tests

- Use `=~` instead of `String.contains?` for string matching
- Always use `async: true` when tests don't depend on shared state
- Test public behavior, not implementation details

**Good:**

```elixir
test "validates email format" do
  assert error_message =~ "invalid email"
end
```

**Bad:**

```elixir
test "validates email format" do
  assert String.contains?(error_message, "invalid email")
end
```

### Time Constants

Use the `:timer` module for time values:

**Good:**

```elixir
@timeout :timer.minutes(5)
@interval :timer.seconds(30)
```

**Bad:**

```elixir
@timeout 300_000  # What unit?
@interval 30000
```

### Documentation Standards

- All modules should have `@moduledoc` definitions
- All public functions should have `@doc` definitions
- Use `@spec` for type specifications where helpful

## Development Notes

### Quality Requirements

The project enforces quality checks:

- No compile warnings (warnings as errors)
- Code must be formatted
- Credo checks must pass
- Security checks (Sobelow)
- Type checks (Dialyzer)
- Documentation coverage

## Agentic Development Guidelines

### When Working Autonomously

**Pre-Flight Checks:**
- Load context with `/prime` at session start
- Read `.claude/context/safety-checklist.md` before changes
- Understand requirements fully before starting
- Check for existing patterns and conventions

**During Development:**
- Follow test-driven development
- Make small, focused commits
- Run quality checks frequently
- Validate after each major step

**Safety Requirements:**
- All user inputs must be validated
- Error handling for all operations
- No SQL injection or XSS vulnerabilities
- Authentication/authorization checked
- No secrets in code
- Tests must pass before completion

### When to Ask vs. Decide

**Ask the user when:**
- Multiple valid approaches exist
- Architecture decisions needed
- Breaking changes required
- Security implications exist
- Requirements unclear

**Decide autonomously when:**
- Following established patterns
- Implementation details
- Code organization
- Test structure
- Bug fixes (for clear bugs)

### Rollback Procedures

**If tests fail:**
1. Analyze the failure carefully
2. Fix if cause is clear and fix is simple
3. Revert if cause is unclear
4. Ask user if unsure

**If you made a mistake:**
1. Acknowledge the error immediately
2. Explain what went wrong
3. Propose correction
4. Revert if needed

### Resources for AI Agents

- **`.claude/context/agentic-best-practices.md`** - Comprehensive autonomous development guide
- **`.claude/context/safety-checklist.md`** - Pre-flight and validation checklists
- **`docs/AGENTIC-DEVELOPMENT.md`** - Using Claude Code effectively with this template

## Useful References

- [Elixir Style Guide](https://github.com/christopheradams/elixir_style_guide)
- [Phoenix Framework Guides](https://hexdocs.pm/phoenix/overview.html)
- [Testing in Elixir](https://elixir-lang.org/getting-started/mix-otp/introduction-to-mix.html)
