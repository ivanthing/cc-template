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
- Issue tracker: GitHub Issues via gh CLI — used only by /to-tickets and /open-pr. Task list target is always tasks/todo.md.

## Key Commands
- Dev server: `[npm run dev]`
- Build: `[npm run build]`
- Test: `[npm run test]`
- Lint: `[npm run lint]`
- Type check: `[npx tsc --noEmit]`

## Ceremony by Stakes
Start every piece of work with `/start-feature [issue or description]`. It picks a tier from this table; higher stakes get more ceremony. When work sits between two tiers, use the higher one.

| Tier | When | Flow |
|---|---|---|
| Small tweak | ≤2 files, <50 lines, and no auth / payments / data access / config / env | Make the change → `prove-it-works` → `/open-pr` |
| Small feature | Clear requirement, one slice | `/grill-me` → `/test` → `/open-pr` |
| Big / fuzzy | Unclear requirement, or spans several modules | `/grill-me` → `/spec` → `/plan-tasks` → `/to-tickets` → `/build` (or `/build auto`) → `/review-code` → `/open-pr` |
| Production / security / irreversible | Auth, payments, data migrations, deploys, or anything `git revert` can't undo | The Big flow, plus `/doubt-driven-development` and the `security-and-hardening` skill; run `/ship` for a go/no-go before `/open-pr` |

Enter `spec-driven-development`, `planning-and-task-breakdown`, `doubt-driven-development`, `shipping-and-launch` and `constraint-driven-development` only through their command, this table, or when a command's text tells you to (e.g. `/build auto` steps 3 and 6). Do not trigger them because a task description looks like a match.

## Project Docs
- Progress tracking: @docs/progress.md (read first, update every session with `/handoff`)
- Learnings log: `docs/learnings.md` (compound over time)
- Spec, plan, task list and quality bar: `SPEC.md`, `tasks/plan.md`, `tasks/todo.md`, `CONSTRAINTS.md` (created by `/spec`, `/plan-tasks`, `/constraints`; `/to-tickets` adds each task's `#N` to `tasks/todo.md`)
- Architecture decisions: `docs/decisions/` (ADRs via the `documentation-and-adrs` skill)
- Team git workflow: `docs/git-workflow.md`
- Vendored skills: `.claude/VENDORED.md` — change vendored files only through `scripts/sync-upstream.sh` and the edits recorded there

## Code Quality
- TypeScript strict mode: `strict: true`
- Hooks auto-run on every file write outside `.claude/`: eslint → prettier
- No `any`, no `// @ts-ignore`, no committed `console.log` debug statements
- Never weaken a test or a threshold to make a change pass — fix the implementation (`/open-pr` checks the diff against `CONSTRAINTS.md`)

## Git & Branching Rules
- Always work on a feature branch — never commit directly to main
- Commit before any large refactor as a checkpoint
- Follow Conventional Commits format (applied by `/open-pr`)
- Every PR closes at least one GitHub Issue (a Big-tier PR closes all of its task issues)
- See `docs/git-workflow.md` for the full team branching strategy

## Compound Engineering Loop
Error encountered → log in docs/learnings.md → extract rule → update CLAUDE.md
This loop makes Claude Code progressively better on your codebase.
