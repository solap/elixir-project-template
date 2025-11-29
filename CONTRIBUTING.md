# Contributing to Elixir Project Template

Thank you for considering contributing to this template! This document provides guidelines for contributing improvements.

## How to Contribute

### Reporting Issues

If you find a problem with the template:

1. **Search existing issues** to avoid duplicates
2. **Create a new issue** with:
   - Clear description of the problem
   - Steps to reproduce (if applicable)
   - Expected vs. actual behavior
   - Your environment (OS, Elixir version, etc.)
   - Suggested fix (if you have one)

### Suggesting Enhancements

We welcome suggestions for improvements:

1. **Check existing issues** for similar suggestions
2. **Create an enhancement issue** describing:
   - The problem you're trying to solve
   - Your proposed solution
   - Why this would benefit template users
   - Any alternatives you've considered

### Submitting Changes

1. **Fork the repository**
2. **Create a feature branch** (`git checkout -b feature/my-improvement`)
3. **Make your changes** following the guidelines below
4. **Test your changes** thoroughly
5. **Commit your changes** with clear messages
6. **Push to your fork** (`git push origin feature/my-improvement`)
7. **Create a Pull Request** with:
   - Description of changes
   - Motivation for the changes
   - How to test the changes
   - Any breaking changes or migration notes

## Development Guidelines

### Testing Template Changes

Before submitting, test your changes:

```bash
# 1. Create a test project
./bin/create-project test_project --type phoenix --dir /tmp/test_project

# 2. Verify the project works
cd /tmp/test_project
mix deps.get
mix compile
make quality

# 3. Clean up
rm -rf /tmp/test_project
```

### Documentation Standards

- **All scripts** must have `--help` flags
- **All new features** need documentation
- **Update CHANGELOG.md** with your changes
- **Update README.md** if adding user-facing features
- Keep documentation concise and actionable

### Code Style

**Bash scripts:**
- Use `#!/usr/bin/env bash` shebang
- Include `set -euo pipefail`
- Add comments for complex logic
- Use functions for reusability
- Include error handling

**Markdown:**
- Use clear headings
- Include code examples
- Keep line length reasonable
- Use lists for actionable items

**Elixir templates:**
- Follow Elixir style guide
- Include helpful comments
- Use placeholders like `{{PROJECT_NAME}}`
- Test that templates compile

### Commit Messages

Write clear, descriptive commit messages:

```
Add validation script for template integrity

- Checks all required files exist
- Validates YAML and Elixir syntax
- Provides clear error messages
- Returns appropriate exit codes

Closes #42
```

**Format:**
- Start with verb (Add, Fix, Update, Remove)
- Keep first line under 50 characters
- Add details in body if needed
- Reference issues with `Closes #n` or `Fixes #n`

## Types of Contributions

### High Priority

These are always welcome:

- **Bug fixes** in scripts or configurations
- **Documentation improvements** (clarity, examples, fixes)
- **Better error messages** in scripts
- **Test coverage** for template functionality
- **Security improvements**

### Medium Priority

These are valuable but may need discussion:

- **New slash commands** for Claude Code
- **Additional example projects**
- **Enhanced workflows** (GitHub Actions, etc.)
- **New configuration templates**
- **Quality tool improvements**

### Needs Discussion

Open an issue first for these:

- **Major architectural changes**
- **New dependencies**
- **Breaking changes**
- **Removing existing features**
- **Large refactorings**

## Versioning

This template follows semantic versioning:

- **Patch (1.0.X)**: Bug fixes, docs, small improvements
- **Minor (1.X.0)**: New features, backward-compatible changes
- **Major (X.0.0)**: Breaking changes, major restructuring

Version is tracked in:
- `VERSION` file (single source of truth)
- `CHANGELOG.md` (detailed change history)
- All scripts reference VERSION variable

## Review Process

1. **Automated checks** run on all PRs
   - Bash script linting (if shellcheck available)
   - Markdown linting
   - Basic validation tests

2. **Manual review** by maintainers
   - Code quality
   - Documentation completeness
   - Test coverage
   - Breaking change assessment

3. **Feedback and iteration**
   - Address review comments
   - Make requested changes
   - Update documentation

4. **Merge**
   - Squash commits for clean history
   - Update VERSION and CHANGELOG
   - Create release (for significant changes)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inspiring community for all.

### Our Standards

**Positive behavior:**
- Being respectful and inclusive
- Gracefully accepting constructive feedback
- Focusing on what's best for the community
- Showing empathy towards others

**Unacceptable behavior:**
- Harassment or discriminatory language
- Trolling or insulting comments
- Public or private harassment
- Publishing others' private information
- Other conduct inappropriate in a professional setting

### Enforcement

Unacceptable behavior can be reported to [maintainer email]. All complaints will be reviewed and investigated promptly and fairly.

## Questions?

- **Usage questions**: Open an issue with the "question" label
- **Feature discussions**: Start a discussion in issues
- **Security concerns**: Email maintainers directly (don't open public issue)

## Recognition

Contributors will be:
- Listed in CONTRIBUTORS.md (if we create one)
- Mentioned in release notes for significant contributions
- Thanked in commit messages

Thank you for helping improve this template! 🎉
