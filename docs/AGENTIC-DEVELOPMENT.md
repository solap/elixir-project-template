# Agentic Development with Claude Code

Guide for effectively using Claude Code with this template for autonomous development.

## Quick Start

### Initialize Your Session

Start every Claude Code session with:
```
/prime
```

This loads:
- Project structure and conventions
- Agentic best practices
- Safety checklists
- Active plans and context

### Typical Workflow

**For New Features:**
```
1. /prime
2. /plan-feature Add user registration
3. Review plan in specs/features/
4. /implement-plan specs/features/user-registration-feature.md
5. Verify with: make quality
```

**For Bug Fixes:**
```
1. /prime
2. /plan-bug Users can't login with email
3. Review plan in specs/bugs/
4. /implement-plan specs/bugs/login-email-bug.md
5. Verify with: make test
```

**For Quick Fixes:**
```
1. /prime
2. /quick-fix Fix typo in error message
3. Verify with: make quality
```

## Available Commands

### Setup & Validation

**`/prime`** - Initialize project context
- Loads project conventions
- Checks for uncommitted changes
- Reviews existing plans
- Summarizes project state

**`/validate-setup`** - Verify project configuration
- Checks all tools are installed
- Validates configuration
- Tests compilation
- Reports any issues

**`/start`** - Start development server
- Launches `mix phx.server` or equivalent
- Use for manual testing

### Planning Commands

**`/plan-feature [description]`** - Plan new feature
- Creates detailed implementation plan
- Includes testing strategy
- Defines acceptance criteria
- Adds rollback strategy

**`/plan-bug [description]`** - Plan bug fix
- Analyzes root cause
- Creates fix plan
- Includes regression test
- Considers impacts

**`/plan-chore [description]`** - Plan maintenance task
- Details refactoring steps
- Assesses impact
- Includes validation
- No functionality changes

### Implementation Commands

**`/implement-plan [path]`** - Execute a plan
- Reads and follows plan step-by-step
- Runs tests after each major step
- Validates at completion
- Reports changes made

**`/quick-fix [description]`** - Rapid bug fix
- For simple, focused fixes only
- Changes 1-2 files maximum
- Must include test
- No architectural changes

### Review Commands

**`/review-plan [path]`** - Review plan quality
- Checks completeness
- Identifies security concerns
- Suggests improvements
- Rates plan quality

## Best Practices

### 1. Always Plan Non-Trivial Changes

**Plan first for:**
- New features
- Complex bug fixes
- Refactorings
- Multi-file changes

**Act directly for:**
- Typos and formatting
- Simple one-line fixes
- Documentation updates

### 2. Validate Continuously

Run checks frequently:
```bash
# After each significant change
mix format
mix compile --warnings-as-errors
mix test

# Before considering work done
make quality
```

### 3. Work Incrementally

Make small, focused commits:
```bash
# Good: Small, focused commits
git commit -m "Add User schema"
git commit -m "Add user validation tests"
git commit -m "Add user registration controller"

# Bad: One giant commit
git commit -m "Add entire user system"
```

### 4. Test Everything

Follow the testing pyramid:
- **Unit tests**: Test individual functions
- **Integration tests**: Test system interactions
- **E2E tests**: Test complete user flows

Always test:
- Happy path
- Error cases
- Edge cases
- Boundary conditions

## Safety Guidelines

### Pre-Flight Checks

Before starting work:
- [ ] Understood the requirement clearly
- [ ] Located relevant existing code
- [ ] Checked for similar implementations
- [ ] Reviewed project conventions

### During Development

- [ ] Input validation for all user data
- [ ] Error handling for all operations
- [ ] No SQL injection vulnerabilities
- [ ] No XSS vulnerabilities
- [ ] Authentication/authorization checked
- [ ] No secrets in code

### Post-Implementation

- [ ] All tests pass
- [ ] Code is formatted
- [ ] No compiler warnings
- [ ] Documentation updated
- [ ] Quality checks pass

## Communication

### When to Ask vs. Decide

**Ask the user when:**
- Multiple valid approaches exist
- Architecture decisions needed
- Breaking changes required
- Security implications exist
- Unsure about requirements

**Decide autonomously when:**
- Following established patterns
- Implementation details
- Variable/function naming
- Code organization
- Test structure

### Provide Progress Updates

For long operations:
```
"Implementing user authentication...
✓ Created User schema
✓ Added password hashing
→ Writing tests now...
"
```

### Explain Non-Obvious Decisions

```
"I'm using a GenServer here because we need to maintain
state across requests. This follows the pattern used in
the SessionManager module."
```

## Common Scenarios

### Adding a New Feature

```
User: "Add user registration"

AI:
1. /prime (load context)
2. Search for existing auth patterns
3. /plan-feature Add user registration with email/password
4. Review plan, ensure it follows patterns
5. Get user approval
6. /implement-plan specs/features/user-registration.md
7. Run make quality
8. Report completion with summary
```

### Fixing a Bug

```
User: "Login fails with special characters in email"

AI:
1. /prime (load context)
2. Locate login code
3. Identify the issue (missing URL encoding)
4. For simple fix: /quick-fix
   For complex: /plan-bug
5. Add regression test
6. Apply fix
7. Verify: mix test
8. Report fix with before/after example
```

### Refactoring Code

```
User: "Extract common validation logic"

AI:
1. /prime (load context)
2. Identify validation patterns
3. /plan-chore Extract validation helpers
4. Plan module structure
5. Get approval (refactorings can be risky)
6. /implement-plan with frequent test runs
7. Verify no behavior changed
8. Report completion
```

## Advanced Tips

### Working with Existing Patterns

Always check existing code first:
```bash
# Find similar implementations
grep -r "def create_user" lib/

# Look at test patterns
find test -name "*_test.exs" | head -5

# Check for naming conventions
grep -r "defmodule.*Controller" lib/
```

### Handling Uncertainty

When unsure, ask:
```
"I see two patterns for validation in this codebase:
1. Ecto changesets (used in User module)
2. Custom validation (used in legacy Profile module)

Which should I follow for the new Team module?"
```

### Recovery from Mistakes

If you realize you're going the wrong direction:
```
1. Stop immediately
2. Explain the mistake clearly
3. Propose correct approach
4. Offer to revert if needed
5. Learn from it
```

## Resources

- [Agentic Best Practices](.claude/context/agentic-best-practices.md) - Comprehensive guide
- [Safety Checklist](.claude/context/safety-checklist.md) - Validation checklists
- [CLAUDE.md](../CLAUDE.md) - Project-specific conventions
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md) - Common issues

## Success Metrics

Good agentic development means:
- **<5% human intervention** for planned features
- **Zero regressions** in existing tests
- **All quality checks pass** on first try
- **Code follows project patterns** consistently
- **Documentation is complete** and accurate

## Getting Help

If Claude Code isn't working as expected:
1. Check you've run `/prime` this session
2. Verify plans are clear and complete
3. Review error messages carefully
4. Ask specific questions
5. Provide context from project files

Remember: **You're partners**. Claude Code amplifies your productivity, but you guide the direction.
