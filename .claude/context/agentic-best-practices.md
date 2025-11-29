# Agentic Development Best Practices

This document provides guidance for autonomous AI-assisted development in Elixir projects.

## Core Principles

### 1. Understand Before Acting

**Always gather context first:**
- Read existing code before proposing changes
- Understand the problem deeply before solving
- Check for existing patterns and conventions
- Look for similar past implementations

**Anti-pattern:**
```
User: "Add a user registration feature"
AI: *Immediately starts writing code*
```

**Best practice:**
```
User: "Add a user registration feature"
AI: "Let me first understand the existing authentication patterns..."
*Reads auth-related files*
*Checks for existing user models*
*Reviews test patterns*
"I see you're using Guardian for auth. I'll follow that pattern..."
```

### 2. Plan Before Implementing

**For non-trivial changes:**
- Use `/plan-feature` or `/plan-bug` first
- Review the plan with the user
- Get approval before implementation
- Keep the plan updated as you work

**When to plan vs. act directly:**
- Plan: Features, complex bugs, refactorings, anything touching >3 files
- Act: Typos, simple bug fixes, documentation updates, formatting

### 3. Test Everything

**Testing mindset:**
- Write tests before or alongside implementation
- Test through public APIs, not internals
- Use `async: true` for independent tests
- Follow existing test patterns in the project

**Minimum testing requirements:**
- New features: Unit tests + integration tests
- Bug fixes: Regression test proving the fix
- Refactorings: Existing tests must still pass

### 4. Validate Continuously

**After every significant change:**
```bash
mix format
mix compile --warnings-as-errors
mix test
```

**Before marking work complete:**
```bash
make quality  # or equivalent full check
```

## Decision-Making Framework

### When to Ask vs. Decide Autonomously

**Ask the user when:**
- Multiple valid approaches exist
- Architecture decisions needed
- Breaking changes required
- Uncertainty about requirements
- Security implications exist
- Performance trade-offs involved

**Decide autonomously when:**
- Following established patterns
- Implementation details (variable names, etc.)
- Code organization within a module
- Test structure and coverage
- Documentation and comments
- Bug fix approaches (for clear bugs)

### Example: Good Autonomous Decision

```
User: "Add validation to email field"
AI: *Reads existing validation patterns*
AI: *Sees project uses Ecto changeset validations*
AI: *Implements using same pattern*
AI: *Adds tests following existing test style*
AI: "I've added email validation using Ecto.Changeset.validate_format/3,
     following the pattern in user.ex. Added tests to cover valid/invalid cases."
```

### Example: Should Ask First

```
User: "Make the system faster"
AI: "I can see several optimization opportunities:
     1. Add caching layer (Redis)
     2. Database query optimization
     3. Background job processing

     Which approach would you prefer, or should I analyze
     performance bottlenecks first?"
```

## Code Quality Standards

### Self-Review Checklist

Before submitting code, verify:

**Correctness:**
- [ ] Code does what it's supposed to do
- [ ] Edge cases are handled
- [ ] Errors are handled gracefully
- [ ] Tests prove correctness

**Style:**
- [ ] Follows project conventions
- [ ] Consistent with surrounding code
- [ ] Properly formatted (`mix format`)
- [ ] No compiler warnings

**Security:**
- [ ] Input validation present
- [ ] No SQL injection risks
- [ ] No XSS vulnerabilities
- [ ] Secrets not hardcoded
- [ ] Authentication/authorization checked

**Performance:**
- [ ] No N+1 queries
- [ ] Appropriate use of indexes
- [ ] No unnecessary computations
- [ ] Memory usage reasonable

**Maintainability:**
- [ ] Code is readable
- [ ] Complex logic is documented
- [ ] Module responsibilities clear
- [ ] Dependencies are appropriate

## Common Pitfalls in Agentic Development

### 1. Over-Engineering

**Anti-pattern:**
```elixir
# User asked to validate email
def validate_email(email) do
  with {:ok, config} <- load_validation_config(),
       {:ok, rules} <- parse_rules(config),
       {:ok, result} <- apply_rules(email, rules) do
    result
  end
end
```

**Better:**
```elixir
# User asked to validate email
def validate_email(email) do
  Regex.match?(~r/@/, email)
end
```

**Rule: Solve the actual problem, not a hypothetical future problem.**

### 2. Ignoring Existing Patterns

**Anti-pattern:**
```elixir
# Project uses Ecto, but AI introduces a different pattern
def get_user(id) do
  {:ok, result} = HTTPoison.get("/api/users/#{id}")
  Jason.decode!(result.body)
end
```

**Better:**
```elixir
# Follow existing Ecto pattern
def get_user(id) do
  Repo.get(User, id)
end
```

**Rule: Consistency > Your preferred approach.**

### 3. Insufficient Testing

**Anti-pattern:**
```elixir
# Added feature, wrote one happy-path test
test "creates user" do
  assert {:ok, user} = create_user(%{email: "test@example.com"})
end
```

**Better:**
```elixir
# Test edge cases and errors
test "creates user with valid data" do
  assert {:ok, user} = create_user(%{email: "test@example.com"})
end

test "fails with invalid email" do
  assert {:error, changeset} = create_user(%{email: "invalid"})
end

test "fails with duplicate email" do
  create_user(%{email: "test@example.com"})
  assert {:error, changeset} = create_user(%{email: "test@example.com"})
end
```

**Rule: Test failure cases as thoroughly as success cases.**

### 4. Scope Creep

**Anti-pattern:**
```
User: "Fix the login bug"
AI: *Fixes bug*
AI: *Refactors entire auth module*
AI: *Adds new features*
AI: *Rewrites tests*
```

**Better:**
```
User: "Fix the login bug"
AI: *Identifies bug*
AI: *Makes minimal fix*
AI: *Adds regression test*
AI: "Bug fixed. I noticed some refactoring opportunities - would you like me to address those separately?"
```

**Rule: Stay focused on the stated goal.**

## Effective Context Gathering

### File Reading Strategy

**Don't:**
- Read entire codebase upfront
- Make assumptions without verification
- Skip reading tests

**Do:**
- Start with related files
- Read test files to understand usage
- Look for similar existing implementations
- Check for recent changes (`git log`)

### Search Strategy

**Use grep/glob effectively:**
```bash
# Find all controller files
glob "**/*_controller.ex"

# Find authentication-related code
grep -r "def authenticate" lib/

# Find test files for a module
glob "test/**/*_user_*"
```

## Working with Elixir Specific Patterns

### Pattern Matching

**Prefer pattern matching:**
```elixir
# Good
def handle_result({:ok, value}), do: value
def handle_result({:error, reason}), do: {:error, reason}

# Less idiomatic
def handle_result(result) do
  if elem(result, 0) == :ok do
    elem(result, 1)
  else
    result
  end
end
```

### Guards and Multiple Clauses

**Use guards for constraints:**
```elixir
def process(items) when is_list(items) and length(items) > 0 do
  # process items
end

def process(_), do: {:error, :invalid_input}
```

### Pipe Operator

**Use pipes for transformation chains:**
```elixir
# Good
users
|> Enum.filter(&active?/1)
|> Enum.map(&format_user/1)
|> Enum.sort_by(& &1.name)

# Less idiomatic
Enum.sort_by(
  Enum.map(
    Enum.filter(users, &active?/1),
    &format_user/1
  ),
  & &1.name
)
```

## Rollback and Error Recovery

### When Things Go Wrong

**If tests fail after changes:**
1. Don't push forward blindly
2. Review the failure message carefully
3. Check if your changes broke existing functionality
4. Consider reverting if the fix is unclear
5. Ask the user if you're stuck

**If you realize you misunderstood:**
1. Stop immediately
2. Explain what you misunderstood
3. Propose the correct approach
4. Offer to revert if changes were made

### Safe Experimentation

**For uncertain changes:**
1. Mention uncertainty upfront
2. Make changes incrementally
3. Test after each increment
4. Keep git history clean for easy revert

## Communication Best Practices

### Progress Updates

**Do provide updates for:**
- Long-running operations
- When switching approaches
- When discovering unexpected issues
- Major milestones completed

**Example:**
```
"Implementing user registration...
✓ Created User schema with validations
✓ Added registration controller
→ Working on tests now..."
```

### Explaining Decisions

**When making non-obvious choices:**
```
"I'm using a GenServer here instead of a simple module because
the requirement to track state across requests suggests we need
a process. This follows the pattern used in SessionManager."
```

### Asking Effective Questions

**Good questions:**
- "Should password reset tokens expire? If so, what duration?"
- "I found two existing auth patterns - Guardian and Pow. Which should I follow?"
- "This change affects the API response format. Is this a breaking change concern?"

**Poor questions:**
- "What should I do?" (too vague)
- "Is this okay?" (too general)

## Summary

**The Three Laws of Agentic Development:**

1. **Understand First**: Read code, understand patterns, verify assumptions
2. **Test Everything**: Prove correctness, test edge cases, prevent regressions
3. **Stay Focused**: Solve the stated problem, avoid scope creep, respect existing patterns

**Remember:** Your goal is to be a force multiplier, not a replacement. Work with the human developer, not instead of them. When in doubt, ask.
