# Quick Fix

Rapidly fix a bug with minimal scope and changes.

## Safety Guidelines

- **CRITICAL**: This command is for HIGH-PRIORITY bugs only
- Changes should be confined to a SINGLE file when possible
- Maximum 2-3 files if absolutely necessary
- NO architectural changes
- NO refactoring beyond the immediate fix
- MUST include a test that verifies the fix

## Instructions

Given the bug description: $ARGUMENTS

1. **Understand the Bug**
   - Read the bug description carefully
   - Identify the exact file and line causing the issue
   - Understand expected vs actual behavior

2. **Locate the Problem**
   - Use grep/read to find the problematic code
   - Read surrounding context (50 lines before/after)
   - Verify this is the root cause

3. **Create a Test First (if none exists)**
   - Write a failing test that reproduces the bug
   - Run the test to confirm it fails
   - This ensures we can verify the fix

4. **Apply Minimal Fix**
   - Change ONLY what's necessary
   - Keep the fix surgical and focused
   - Preserve existing patterns and style
   - Add inline comments explaining the fix

5. **Verify the Fix**
   - Run the test - it should now pass
   - Run full test suite to ensure no regressions
   - Run: mix format
   - Run: mix compile --warnings-as-errors
   - Run: mix credo --min-priority high

6. **Report**
   - Summarize the bug
   - Explain the fix in 1-2 sentences
   - Show before/after code snippet
   - Confirm all tests pass

## When NOT to Use This Command

- For features (use /plan-feature instead)
- For complex bugs affecting multiple systems (use /plan-bug)
- When root cause is unclear
- When fix requires database migrations
- When fix requires dependency changes
