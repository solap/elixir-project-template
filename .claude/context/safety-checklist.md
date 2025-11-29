# Safety Checklist for Autonomous Development

This checklist ensures safe, secure, and reliable autonomous code changes.

## Pre-Flight Checks (Before Starting)

### Repository State
- [ ] Git repository is in clean state (or changes are understood)
- [ ] On correct branch
- [ ] No merge conflicts
- [ ] Dependencies are up to date (`mix deps.get` run recently)

### Context Gathering
- [ ] Read CLAUDE.md for project conventions
- [ ] Understand the requirement/bug clearly
- [ ] Located relevant existing code
- [ ] Reviewed similar past implementations
- [ ] Checked for related tests

### Planning
- [ ] Complexity assessed (simple fix vs. needs planning)
- [ ] Approach decided and reasonable
- [ ] Breaking changes identified (if any)
- [ ] Dependencies/impacts understood

## During Implementation

### Code Safety

**Input Validation**
- [ ] All user inputs are validated
- [ ] Type checking/casting is explicit
- [ ] Bounds checking for arrays/lists
- [ ] Nil/null checks where needed
- [ ] Email/URL format validation

**Security**
- [ ] No SQL injection vulnerabilities (use parameterized queries)
- [ ] No XSS vulnerabilities (properly escape output)
- [ ] No CSRF vulnerabilities (use tokens for state-changing operations)
- [ ] Authentication checked before protected operations
- [ ] Authorization verified (user can perform this action)
- [ ] No secrets/passwords in code
- [ ] No sensitive data in logs
- [ ] File uploads validated (type, size, content)
- [ ] Path traversal prevented (no `../../` tricks)

**Error Handling**
- [ ] All failure cases handled
- [ ] Errors are logged appropriately
- [ ] User-facing errors are helpful but not leaky
- [ ] No unhandled exceptions
- [ ] Graceful degradation where appropriate
- [ ] Timeouts set for external calls

**Data Integrity**
- [ ] Database transactions used where needed
- [ ] Race conditions considered
- [ ] Idempotency for critical operations
- [ ] Data migrations are reversible
- [ ] Foreign key constraints respected
- [ ] Unique constraints enforced

### Code Quality

**Elixir Idioms**
- [ ] Pattern matching used appropriately
- [ ] Guards used instead of conditionals where suitable
- [ ] Pipe operator used for transformation chains
- [ ] Functions are small and focused
- [ ] No deeply nested conditionals
- [ ] Appropriate use of `with` for complex flows

**Performance**
- [ ] No N+1 query problems
- [ ] Queries use appropriate indexes
- [ ] Large result sets are paginated
- [ ] Heavy computations are async (if appropriate)
- [ ] No unnecessary database calls
- [ ] Caching considered for expensive operations
- [ ] Memory usage is reasonable

**Maintainability**
- [ ] Code is readable and clear
- [ ] Complex logic has comments
- [ ] Function/variable names are descriptive
- [ ] Modules have clear responsibilities
- [ ] No magic numbers (use constants)
- [ ] No code duplication

### Testing

**Test Coverage**
- [ ] Happy path tested
- [ ] Error cases tested
- [ ] Edge cases tested
- [ ] Boundary conditions tested
- [ ] Integration tests for feature flows
- [ ] Tests use `async: true` where possible

**Test Quality**
- [ ] Tests are isolated (don't depend on each other)
- [ ] Tests use factories/fixtures for data
- [ ] Tests follow AAA pattern (Arrange, Act, Assert)
- [ ] Test names are descriptive
- [ ] Tests don't test implementation details

## Post-Implementation Validation

### Automated Checks
- [ ] `mix format` passes
- [ ] `mix compile --warnings-as-errors` passes
- [ ] `mix credo --min-priority high` passes
- [ ] `mix test` passes (all tests, not just new ones)
- [ ] `mix dialyzer` passes (if configured)

### Manual Review
- [ ] Read through all changes once more
- [ ] Verify no debug code left behind
- [ ] Check no commented-out code unless intentional
- [ ] Confirm no unintended files changed
- [ ] Review diff for accidental changes

### Documentation
- [ ] Module docs updated if behavior changed
- [ ] Function docs added for public functions
- [ ] README updated if needed
- [ ] CHANGELOG updated (if maintained)
- [ ] Migration guides provided (if breaking changes)

## Specific Domain Checks

### Database Migrations

**Before creating migration:**
- [ ] Migration is reversible (has `down` function)
- [ ] Migration is idempotent (safe to run multiple times)
- [ ] Large data migrations are batched
- [ ] Indexes added for new foreign keys
- [ ] No destructive changes without confirmation

**Migration safety:**
```elixir
# Good: Reversible
def change do
  create table(:users) do
    add :email, :string, null: false
    timestamps()
  end
end

# Bad: Not reversible
def change do
  execute("DROP TABLE old_users")
end

# Better: Explicitly reversible
def up do
  execute("DROP TABLE old_users")
end

def down do
  # Recreation logic or note that this is destructive
  raise "This migration cannot be reversed"
end
```

### API Changes

**When modifying APIs:**
- [ ] Backward compatibility considered
- [ ] Version bumping if breaking changes
- [ ] API documentation updated
- [ ] Deprecation warnings added if removing endpoints
- [ ] Error responses are consistent
- [ ] HTTP status codes are appropriate

### Background Jobs

**When adding/modifying Oban jobs:**
- [ ] Job is idempotent
- [ ] Retries are appropriate
- [ ] Timeout is set
- [ ] Error handling is comprehensive
- [ ] Job data is minimal (IDs, not full records)
- [ ] Queue is appropriate for priority

### Phoenix LiveView

**LiveView safety:**
- [ ] No sensitive data in assigns
- [ ] CSRF protection enabled
- [ ] Rate limiting for user actions
- [ ] PubSub messages validated
- [ ] No server-side state leaks

## Red Flags (Stop and Ask)

**Stop autonomous development and ask user if:**

1. **Security Concerns**
   - Touching authentication/authorization code
   - Handling payment information
   - Dealing with PII or sensitive data
   - Making security-related configuration changes

2. **Data Risks**
   - Destructive migrations
   - Bulk data operations
   - Changing data formats
   - Removing or renaming database columns

3. **Architecture Changes**
   - Adding new major dependencies
   - Changing application structure
   - Introducing new design patterns
   - Modifying deployment configuration

4. **Breaking Changes**
   - Public API modifications
   - Configuration format changes
   - Database schema changes affecting existing data
   - Removing or renaming public functions

5. **Performance Impacts**
   - Changes to critical path code
   - New background job queues
   - Caching strategy changes
   - Database query modifications in hot paths

6. **Uncertainty**
   - Multiple valid approaches with trade-offs
   - Requirements are ambiguous
   - Impact is unclear
   - Risk assessment is uncertain

## Rollback Procedures

### If Tests Fail

1. **Analyze the failure:**
   ```bash
   mix test --failed --trace
   ```

2. **Determine cause:**
   - Your changes broke something?
   - Test was already flaky?
   - Environmental issue?

3. **Actions:**
   - Fix if cause is clear and fix is simple
   - Revert if cause is unclear
   - Ask user if unsure

### If You Made a Mistake

1. **Acknowledge the error:**
   "I apologize, I misunderstood the requirement..."

2. **Explain what went wrong:**
   "I thought you wanted X, but actually you need Y..."

3. **Propose correction:**
   "I can revert these changes and implement Y instead, or..."

4. **Learn from it:**
   Update mental model to avoid similar mistakes

## Emergency Stop

**Immediately stop and report to user if:**
- Production data could be at risk
- Security vulnerability was introduced
- System stability is compromised
- Irreversible action about to occur
- You're completely lost/confused

**Report format:**
```
⚠️ STOPPING: [Issue detected]

What happened:
[Clear explanation]

Potential impact:
[What could go wrong]

Recommended action:
[What should be done]

Current state:
[What's been done so far]
```

## Summary

**The Safety Mindset:**
- **Validate inputs** - Never trust external data
- **Handle errors** - Expect things to fail
- **Test thoroughly** - Prove it works
- **Review carefully** - Catch mistakes before commit
- **Ask when unsure** - Better to ask than to break

**Remember:** Safety is not about being slow. It's about being thorough. A careful, fast implementation beats a reckless, fast one every time.
