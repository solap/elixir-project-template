#!/usr/bin/env bash
set -euo pipefail

# setup-git-hooks.sh - Install git hooks for quality checks
# Usage: ./scripts/setup-git-hooks.sh [--uninstall]

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/.." && pwd)"
HOOKS_DIR="$PROJECT_ROOT/.git/hooks"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

success() { echo -e "${GREEN}✓${NC} $1"; }
warn() { echo -e "${YELLOW}⚠${NC} $1"; }
error() { echo -e "${RED}✗${NC} $1"; exit 1; }

# Check if in git repository
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    error "Not in a git repository"
fi

# Uninstall hooks
if [[ "${1:-}" == "--uninstall" ]]; then
    echo "Uninstalling git hooks..."
    rm -f "$HOOKS_DIR/pre-commit"
    rm -f "$HOOKS_DIR/pre-push"
    success "Git hooks uninstalled"
    exit 0
fi

echo "Installing git hooks..."
echo ""

# Create pre-commit hook
cat > "$HOOKS_DIR/pre-commit" << 'EOF'
#!/usr/bin/env bash
# Pre-commit hook - Run format and compilation checks

set -e

echo "Running pre-commit checks..."

# Check formatting
echo "→ Checking code format..."
if ! mix format --check-formatted 2>&1; then
    echo "❌ Code is not formatted. Run: mix format"
    exit 1
fi

# Compile with warnings as errors
echo "→ Compiling with warnings as errors..."
if ! mix compile --warnings-as-errors 2>&1; then
    echo "❌ Compilation failed or has warnings"
    exit 1
fi

# Run Credo
echo "→ Running Credo..."
if ! mix credo --min-priority high 2>&1; then
    echo "❌ Credo found high priority issues"
    exit 1
fi

echo "✅ Pre-commit checks passed"
EOF

chmod +x "$HOOKS_DIR/pre-commit"
success "Installed pre-commit hook"

# Create pre-push hook
cat > "$HOOKS_DIR/pre-push" << 'EOF'
#!/usr/bin/env bash
# Pre-push hook - Run full test suite

set -e

echo "Running pre-push checks..."

# Run tests
echo "→ Running test suite..."
if ! mix test 2>&1; then
    echo "❌ Tests failed"
    exit 1
fi

echo "✅ Pre-push checks passed"
EOF

chmod +x "$HOOKS_DIR/pre-push"
success "Installed pre-push hook"

echo ""
echo "Git hooks installed successfully!"
echo ""
warn "Note: You can skip hooks with --no-verify flag:"
echo "  git commit --no-verify"
echo "  git push --no-verify"
echo ""
echo "To uninstall: ./scripts/setup-git-hooks.sh --uninstall"
echo ""
