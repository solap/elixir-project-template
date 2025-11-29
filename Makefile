# Makefile for Elixir/Phoenix Project

.PHONY: help setup deps compile test quality format credo dialyzer doctor clean dev

## help: Display this help message
help:
	@echo "Available commands:"
	@grep -E '^## ' Makefile | sed 's/^## /  /'

## setup: Initial project setup (install dependencies, setup DB, compile)
setup:
	mix deps.get
	mix compile
	mix ecto.setup

## deps: Install dependencies
deps:
	mix deps.get

## compile: Compile the project
compile:
	mix compile --all-warnings --warnings-as-errors

## test: Run all tests
test:
	mix test

## test-watch: Run tests in watch mode
test-watch:
	mix test.watch

## test-coverage: Generate test coverage report
test-coverage:
	mix coveralls.html
	@echo "Coverage report generated at cover/excoveralls.html"

## quality: Run all quality checks (format, credo, dialyzer, tests)
quality: format-check compile credo dialyzer doctor test
	@echo "✓ All quality checks passed!"

## kuality: Run all quality checks (alias for quality)
kuality: quality

## format: Format code with mix format
format:
	mix format

## format-check: Check if code is formatted
format-check:
	mix format --check-formatted

## credo: Run Credo static code analysis
credo:
	mix credo --min-priority high

## credo-all: Run Credo with all checks
credo-all:
	mix credo --strict

## sobelow: Run Sobelow security analysis
sobelow:
	mix sobelow --config

## dialyzer: Run Dialyzer type checking
dialyzer:
	mix dialyzer

## doctor: Check documentation coverage
doctor:
	mix doctor

## audit: Check for security vulnerabilities and retired packages
audit:
	mix hex.audit
	mix deps.unlock --check-unused

## clean: Clean build artifacts
clean:
	mix clean
	rm -rf _build deps

## dev: Start development server
dev:
	mix phx.server

## dev-iex: Start development server with IEx
dev-iex:
	iex -S mix phx.server

## db-setup: Setup database (create, migrate, seed)
db-setup:
	mix ecto.setup

## db-reset: Reset database (drop, create, migrate, seed)
db-reset:
	mix ecto.reset

## db-migrate: Run database migrations
db-migrate:
	mix ecto.migrate

## db-rollback: Rollback last database migration
db-rollback:
	mix ecto.rollback

## docs: Generate project documentation
docs:
	mix docs
	@echo "Documentation generated at doc/index.html"

## validate: Validate template setup
validate:
	@[ -x bin/validate-template ] && bin/validate-template || echo "Validation script not found"

## setup-hooks: Install git hooks for quality checks
setup-hooks:
	@[ -x scripts/setup-git-hooks.sh ] && scripts/setup-git-hooks.sh || echo "Setup hooks script not found"

## check-quality: Run quality checks with colored output
check-quality:
	@[ -x scripts/check-quality.sh ] && scripts/check-quality.sh || make quality

## paranoid: Run all checks with maximum strictness
paranoid:
	mix format --check-formatted
	mix compile --all-warnings --warnings-as-errors --force
	mix credo --strict
	mix sobelow --config
	mix dialyzer
	mix doctor
	mix test --trace
	@echo "✓ All paranoid checks passed!"
