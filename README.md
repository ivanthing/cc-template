# Claude Code Vibe Coding Template

A production-ready Claude Code workflow template for teams.
Clone it, fill in the placeholders, and you're ready to build.

Synthesized from Anthropic's official best practices, Boris Cherny's (Claude Code creator) workflow, Kieran Klaassen's Compound Engineering philosophy, and battle-tested community patterns.

---

## What's inside

```
.
├── CLAUDE.md                          # Global rules — Claude reads this every session
├── docs/
│   ├── PRD.md                         # Product requirements document
│   ├── constraints.md                 # What NOT to do
│   ├── progress.md                    # Cross-session state handoff
│   ├── learnings.md                   # Error → rule log (Compound Engineering)
│   ├── architecture.md                # Architecture decision records
│   ├── git-workflow.md                # Team Git, CI/CD, and deploy guide
│   └── decisions/                     # Per-feature design decision records
├── src/
│   └── CLAUDE.md                      # Directory-level rules for src/
├── .claude/
│   ├── settings.json                  # Hooks (auto-format + test guard) + permissions
│   ├── agents/
│   │   ├── planner.md                 # PRD generation via product interview
│   │   ├── docs-explorer.md           # Live doc fetching via Context7 MCP
│   │   ├── test-runner.md             # PRD-driven test execution
│   │   ├── security-reviewer.md       # Pre-ship security audit
│   │   ├── refactor.md                # Fresh-session refactoring specialist
│   │   └── commit.md                  # Conventional Commits generator
│   ├── skills/
│   │   ├── grill-me/                  # Technical design interrogation
│   │   ├── prd-to-issues/             # PRD → vertical-slice GitHub Issues
│   │   ├── tdd/                       # Red → Green → Refactor cycle
│   │   ├── improve-arch/              # Architecture review and deepening
│   │   ├── tech-debt/                 # End-of-session cleanup
│   │   └── frontend/                  # UI design standards
│   └── commands/
│       ├── start-feature.md           # /start-feature
│       ├── grill.md                   # /grill
│       ├── review.md                  # /review
│       ├── handoff.md                 # /handoff
│       ├── ship.md                    # /ship
│       └── lfg.md                     # /lfg  (full automated loop)
└── .github/
    ├── workflows/
    │   ├── ci.yml                     # Lint + type check + test + build on every push
    │   ├── deploy-staging.yml         # Auto-deploy to staging on merge to main
    │   └── deploy-production.yml      # Manual-trigger production deploy with approval gate
    ├── ISSUE_TEMPLATE/
    │   ├── feature.md                 # Feature issue template
    │   └── bug.md                     # Bug report template
    ├── pull_request_template.md       # PR checklist and description structure
    └── claude-code-review.yml         # Claude GitHub App review configuration
```

---

## Quick start

### 1. Use this template

**Option A — GitHub Template (recommended)**
Click **"Use this template"** on the repository page. GitHub creates a new repo with all files copied.

**Option B — Clone and reset**
```bash
git clone https://github.com/[YOUR_USERNAME]/claude-code-template.git my-project
cd my-project
rm -rf .git && git init
```

### 2. Configure the placeholders

Open `CLAUDE.md` and fill in:
- `[YOUR_PROJECT_NAME]`
- Your actual tech stack
- Your actual dev/build/test/lint commands

Open `docs/constraints.md` and add any project-specific constraints.

### 3. Set up CI/CD

In `.github/workflows/`:
- `ci.yml` works out of the box — no changes needed
- `deploy-staging.yml` — uncomment your platform's deploy block (Vercel, Railway, Fly.io, etc.)
- `deploy-production.yml` — same, plus set up a GitHub Environment named `production` with required reviewers

Add your secrets in **GitHub → Settings → Secrets and variables → Actions**.

### 4. Enable the Claude GitHub App (optional but recommended)

Run this inside Claude Code after the repo is on GitHub:
```
/install-github-app
```
It will automatically review every PR for bugs and security issues.
Review behavior is configured in `.github/claude-code-review.yml`.

### 5. Start Claude Code

```bash
claude --dangerously-skip-permissions
```

Or add an alias to your shell config:
```bash
alias cc="claude --dangerously-skip-permissions"
```

### 6. Start your first feature

```
/start-feature [your first issue or feature description]
```

---

## How the workflow works

### The session loop

```
New session
    ↓
/start-feature [issue]            load context, check git, plan
    ↓
Plan Mode review                  you approve before any code is written
    ↓
Implementation                    hooks auto-run prettier + eslint + tsc on every save
    ↓
/review                           multi-perspective review, prioritized findings
    ↓
/ship                             quality gate → commit → push → open PR
    ↓
CI runs automatically             lint + typecheck + test + build
    ↓
Claude GitHub App reviews PR      bugs and security issues flagged automatically
    ↓
Team member approves              human review required to merge
    ↓
Merge to main
    ↓
Auto-deploy to staging            deploy-staging.yml fires on every merge
    ↓
Manual trigger → production       deploy-production.yml, requires team approval
```

### Compound Engineering

Every session feeds the next one. When Claude makes a mistake:

1. Fix the problem in this session
2. Document it in `docs/learnings.md`
3. Extract a rule and add it to `CLAUDE.md` or `docs/constraints.md`
4. Commit: `docs: add constraint for [what you learned]`

The whole team benefits immediately — Claude won't repeat that mistake.

---

## Command reference

| Command | What it does |
|---|---|
| `/start-feature [desc]` | Load context, verify git, plan and get approval before starting |
| `/grill [design]` | Technical interrogation — expose design blindspots before coding |
| `/review` | Multi-perspective code review, findings written to docs/todos/ |
| `/handoff` | Save session state to docs/progress.md before stopping |
| `/ship` | Quality gate → commit → push → open PR |
| `/lfg [desc]` | Full automated loop: plan → implement → test → review → ship |
| `/clear` | Reset context window — run before each new feature |
| `/compact` | Summarize and compress context when above 80% |
| `/context` | Inspect context usage — find what's consuming tokens |

---

## Git workflow summary

```
main               protected, always deployable, auto-deploys to staging on merge
feature/[N]-[desc] your working branch — lives 1–3 days, one issue per branch
```

**Branch naming**: `feature/42-google-oauth`, `fix/87-redirect-loop`, `chore/update-deps`

**Commit format**: `feat(auth): add Google OAuth login` — Conventional Commits, enforced by the commit agent

**Merge strategy**: Squash and Merge — keeps main history clean and readable

Full details in `docs/git-workflow.md`.

---

## Team onboarding

When a new developer joins:

1. Clone the repo
2. Copy `.env.example` → `.env.local` and fill in values
3. Read `CLAUDE.md`, `docs/constraints.md`, `docs/architecture.md`, and `docs/git-workflow.md`
4. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
5. Start from the project root: `claude --dangerously-skip-permissions`
6. Pick up an issue: `/start-feature [issue number or description]`

---

## Maturity path

**Week 1 — Foundations**
- [ ] Fill in `CLAUDE.md` placeholders for your project
- [ ] Add project-specific constraints to `docs/constraints.md`
- [ ] Get comfortable with Plan Mode (Shift+Tab twice)
- [ ] Use `/clear` before every new feature
- [ ] Ship your first PR with `/ship`

**Week 2 — Team workflow**
- [ ] Confirm CI is running on every PR (`ci.yml`)
- [ ] Configure and test staging deploy (`deploy-staging.yml`)
- [ ] Install the Claude GitHub App for automatic PR review
- [ ] Use `/start-feature` consistently as your session opener
- [ ] Start logging bugs to `docs/learnings.md`

**Week 3+ — Advanced**
- [ ] Use `prd-to-issues` skill to slice epics into vertical issues
- [ ] Configure Playwright MCP for automated UI verification
- [ ] Enable production deploy with approval gate (`deploy-production.yml`)
- [ ] Run `improve-arch` monthly for architecture reviews
- [ ] Try `/lfg` for the full one-command loop

---

## Design decisions

**Why `--dangerously-skip-permissions`?**
Prevents Claude from pausing to ask permission for safe, expected operations like running eslint or tsc. Truly dangerous commands are blocked in `.claude/settings.json`. Add anything you always want to allow to the `permissions.allow` list there.

**Why trunk-based development?**
Short-lived branches mean small, reviewable PRs. Each Claude session maps cleanly to one branch and one issue — context stays clean and reviews stay focused.

**Why Squash and Merge?**
Each merge to `main` produces one commit with a Conventional Commits message matching the PR title. The history stays readable and tooling like release-please can parse it automatically.

**Why write tests before implementation?**
Claude Code tends to write tests that match its own implementation. PRD-first tests reflect actual requirements, catch different bugs, and survive refactors better.

---

## References

- [Claude Code documentation](https://docs.anthropic.com/claude-code)
- [Claude Code official plugins](https://github.com/anthropics/claude-code-plugins)
- [Compound Engineering — Kieran Klaassen](https://every.to/superorganizers/compound-engineering)
- [Conventional Commits specification](https://www.conventionalcommits.org)
