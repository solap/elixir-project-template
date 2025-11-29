#!/usr/bin/env bash
set -euo pipefail

# check-quality.sh - Run all quality checks with colorful output
# Usage: ./scripts/check-quality.sh [--format|--compile|--credo|--test|--all]

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

CHECKS_RUN=0
CHECKS_PASSED=0
CHECKS_FAILED=0

info() { echo -e "${BLUE}→${NC} $1"; }
success() { echo -e "${GREEN}✓${NC} $1"; ((CHECKS_PASSED++)); }
fail() { echo -e "${RED}✗${NC} $1"; ((CHECKS_FAILED++)); }
header() { echo -e "\n${BLUE}═══${NC} $1 ${BLUE}═══${NC}"; }

run_check() {
    local name="$1"
    local cmd="$2"

    ((CHECKS_RUN++))
    info "Running $name..."

    if eval "$cmd" > /dev/null 2>&1; then
        success "$name passed"
        return 0
    else
        fail "$name failed"
        return 1
    fi
}

run_check_verbose() {
    local name="$1"
    local cmd="$2"

    ((CHECKS_RUN++))
    info "Running $name..."

    if eval "$cmd"; then
        success "$name passed"
        return 0
    else
        fail "$name failed"
        return 1
    fi
}

# Parse arguments
RUN_FORMAT=false
RUN_COMPILE=false
RUN_CREDO=false
RUN_DIALYZER=false
RUN_DOCTOR=false
RUN_TEST=false
RUN_ALL=false

if [ $# -eq 0 ]; then
    RUN_ALL=true
fi

while [[ $# -gt 0 ]]; do
    case $1 in
        --format) RUN_FORMAT=true; shift ;;
        --compile) RUN_COMPILE=true; shift ;;
        --credo) RUN_CREDO=true; shift ;;
        --dialyzer) RUN_DIALYZER=true; shift ;;
        --doctor) RUN_DOCTOR=true; shift ;;
        --test) RUN_TEST=true; shift ;;
        --all) RUN_ALL=true; shift ;;
        --help)
            echo "Usage: $0 [OPTIONS]"
            echo "Options:"
            echo "  --format      Run mix format check"
            echo "  --compile     Run mix compile"
            echo "  --credo       Run credo"
            echo "  --dialyzer    Run dialyzer"
            echo "  --doctor      Run doctor"
            echo "  --test        Run tests"
            echo "  --all         Run all checks (default)"
            exit 0
            ;;
        *) echo "Unknown option: $1"; exit 1 ;;
    esac
done

if [ "$RUN_ALL" = true ]; then
    RUN_FORMAT=true
    RUN_COMPILE=true
    RUN_CREDO=true
    RUN_DIALYZER=true
    RUN_DOCTOR=true
    RUN_TEST=true
fi

header "Quality Checks"

# Format check
if [ "$RUN_FORMAT" = true ]; then
    run_check "Format check" "mix format --check-formatted"
fi

# Compilation
if [ "$RUN_COMPILE" = true ]; then
    run_check "Compilation" "mix compile --warnings-as-errors"
fi

# Credo
if [ "$RUN_CREDO" = true ]; then
    run_check "Credo" "mix credo --min-priority high"
fi

# Dialyzer (can be slow)
if [ "$RUN_DIALYZER" = true ]; then
    if mix dialyzer --version > /dev/null 2>&1; then
        info "Running Dialyzer (this may take a while)..."
        if run_check_verbose "Dialyzer" "mix dialyzer"; then
            :
        else
            echo "(Dialyzer failures are often non-critical)"
        fi
    else
        echo -e "${YELLOW}⊘${NC} Dialyzer not available, skipping"
    fi
fi

# Doctor
if [ "$RUN_DOCTOR" = true ]; then
    if mix doctor --version > /dev/null 2>&1; then
        run_check "Documentation coverage" "mix doctor"
    else
        echo -e "${YELLOW}⊘${NC} Doctor not available, skipping"
    fi
fi

# Tests
if [ "$RUN_TEST" = true ]; then
    run_check_verbose "Tests" "mix test"
fi

# Summary
header "Summary"
echo "Checks run: $CHECKS_RUN"
success "Passed: $CHECKS_PASSED"

if [ $CHECKS_FAILED -gt 0 ]; then
    fail "Failed: $CHECKS_FAILED"
    echo ""
    echo "Fix the failures and run again"
    exit 1
else
    echo ""
    success "All checks passed! 🎉"
    exit 0
fi
