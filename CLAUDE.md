# Project: [YOUR_PROJECT_NAME]

> Before you start: replace all [YOUR_*] placeholders and remove sections that don't apply.

## Core Principles (Boris Cherny's Three Laws)
- Make the simplest possible change — delete lines when you can
- Fix the root cause, never patch symptoms
- Only touch what's necessary — avoid side effects

## Tech Stack
- Frontend: [e.g. Next.js 15, TypeScript, Tailwind, shadcn/ui]
- Backend: [e.g. Node.js / Python FastAPI]
- Database: [e.g. PostgreSQL via Supabase]
- Auth: [e.g. BetterAuth / Clerk]
- Deploy: [e.g. Vercel]

## Key Commands
- Dev server: `[npm run dev]`
- Build: `[npm run build]`
- Test: `[npm run test]`
- Lint: `[npm run lint]`
- Type check: `[npx tsc --noEmit]`

## Reference Docs
- Product requirements: @docs/PRD.md
- Constraints: @docs/constraints.md
- Progress tracking: @docs/progress.md (update every session)
- Learnings log: @docs/learnings.md (compound over time)
- Architecture decisions: @docs/architecture.md
- Team git workflow: @docs/git-workflow.md

## Context Management Rules
- Before starting a new feature: run /clear to reset context
- When context exceeds 80%: run /compact to summarize
- Use /context to inspect what's consuming tokens (MCPs are the biggest culprit)
- Cross-session state lives in docs/progress.md — always read it first

## Explicit over Implicit
- Always name the agent or tool you want — don't expect Claude to guess
- Example: "Use the docs-explorer agent with Context7 MCP to read BetterAuth docs, then implement"
- Example: "Use the test-runner agent to validate against PRD acceptance criteria"

## Code Quality
- TypeScript strict mode: `strict: true`
- Hooks auto-run on every file write: prettier → eslint → tsc
- Tests are written from PRD requirements, not from implementation details
- Never modify test files to make tests pass — fix the implementation

## Git & Branching Rules
- Always work on a feature branch — never commit directly to main
- Commit before any large refactor as a checkpoint
- Follow Conventional Commits format (enforced by the commit agent)
- Every PR must reference its GitHub Issue
- See @docs/git-workflow.md for the full team branching strategy

## Compound Engineering Loop
Error encountered → log in docs/learnings.md → extract rule → update CLAUDE.md
This loop makes Claude Code progressively better on your codebase.
