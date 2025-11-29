# Validate Setup

Validates that the project setup is complete and all tools are properly configured.

## Steps

1. Run the validation script:
   ```bash
   bin/validate-template
   ```

2. Check that mix.exs dependencies are installed:
   ```bash
   mix deps.get
   mix deps.tree
   ```

3. Verify all quality tools work:
   ```bash
   mix format --check-formatted
   mix compile --warnings-as-errors
   mix credo --version
   mix dialyzer --version
   mix doctor --version
   ```

4. Test that main commands run successfully:
   ```bash
   mix compile
   mix test
   ```

5. Report configuration status to user with:
   - List of installed quality tools
   - Any missing dependencies
   - Configuration warnings
   - Suggestions for fixes

## Success Criteria

- All validation checks pass
- All quality tools are installed and functional
- Project compiles without warnings
- Tests run successfully (or explain if no tests exist yet)
