# Claude Commands

This directory contains custom slash commands for Claude Code to streamline common development workflows in Elixir/Phoenix projects.

## What Are Slash Commands?

Slash commands are shortcuts that expand into full prompts when executed. They help automate repetitive tasks and ensure consistent workflows across the team.

## Available Commands

### Setup & Development Commands

#### `/prime`
**Purpose**: Initialize project context at the beginning of a new Claude Code session.

**Usage**:
```
/prime
```

**What it does**:
- Lists all files in the repository (`git ls-files`)
- Reads `CLAUDE.md` to understand project conventions
- Summarizes understanding of the codebase

**When to use**: At the start of each new Claude Code session to help Claude understand the project structure and conventions.

---

#### `/start`
**Purpose**: Start the development server.

**Usage**:
```
/start
```

**What it does**:
- Executes `mix phx.server` or your configured start command
- Starts the application in development mode

**When to use**: When you want to quickly start the local development server.

---

### Planning Commands

#### `/plan-feature [feature description]`
**Purpose**: Create a detailed plan for implementing a new feature.

**Usage**:
```
/plan-feature Add user authentication with OAuth
```

**What it does**:
- Researches the codebase to understand existing patterns
- Creates a feature plan in `specs/features/*.md`
- Includes implementation steps, testing strategy, and acceptance criteria

**When to use**: Before implementing any new feature.

---

#### `/plan-bug [bug description]`
**Purpose**: Create a detailed plan for fixing a bug.

**Usage**:
```
/plan-bug Users can't submit forms on mobile
```

**What it does**:
- Researches the codebase to understand the bug
- Creates a bug fix plan in `specs/bugs/*.md`
- Includes root cause analysis and validation steps

**When to use**: Before fixing any bug.

---

#### `/plan-chore [chore description]`
**Purpose**: Create a plan for maintenance or refactoring tasks.

**Usage**:
```
/plan-chore Update deprecated dependencies
```

**What it does**:
- Creates a chore plan in `specs/chores/*.md`
- Lists step-by-step tasks and validation commands

**When to use**: Before tackling maintenance or refactoring.

---

### Implementation Commands

#### `/implement-plan [path to plan]`
**Purpose**: Execute a plan created by planning commands.

**Usage**:
```
/implement-plan specs/features/user-auth-feature.md
```

**What it does**:
- Reads the plan file
- Implements each step in order
- Executes validation commands
- Reports results with `git diff --stat`

**When to use**: After creating and reviewing a plan.

---

## Typical Workflow

### For New Features:
1. `/prime` - Initialize context (if new session)
2. `/plan-feature [description]` - Create plan
3. Review the plan in `specs/features/`
4. `/implement-plan specs/features/[name].md` - Execute
5. Review and test

### For Bug Fixes:
1. `/prime` - Initialize context
2. `/plan-bug [description]` - Create fix plan
3. Review the plan in `specs/bugs/`
4. `/implement-plan specs/bugs/[name].md` - Execute
5. Verify the fix

### For Maintenance:
1. `/prime` - Initialize context
2. `/plan-chore [description]` - Create plan
3. Review the plan in `specs/chores/`
4. `/implement-plan specs/chores/[name].md` - Execute
5. Validate no regressions

## Tips

- **Always start with `/prime`** at the beginning of a session
- **Review plans before implementing** - edit if needed
- **Plans are documentation** - keep them in version control
- **Validation is built-in** - ensures quality

## Customization

These commands can be customized for your project:
- Edit the markdown files to adjust prompts
- Add project-specific commands
- Modify the plan formats to match your needs
