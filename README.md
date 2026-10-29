# Claude Code Vibe Coding Template

A production-ready Claude Code workflow template for teams.
Clone it, fill in the placeholders, and you're ready to build.

Synthesized from Anthropic's official best practices, Boris Cherny's (Claude Code creator) workflow, Kieran Klaassen's Compound Engineering philosophy, and three curated skill packs:

- **[Addy Osmani's agent-skills](https://github.com/addyosmani/agent-skills)** — the development lifecycle: spec → plan → build → test → review → ship
- **[Matt Pocock's skills](https://github.com/mattpocock/skills)** — grilling a design before code, plan → GitHub issues, PR bodies
- **[pstack](https://github.com/cursor/plugins/tree/main/pstack)** — the "prove it works" verification principle

More skills don't make a smarter agent. Each one here has a specific caller, and how much of the process runs depends on the stakes of the change (see [Ceremony by stakes](#ceremony-by-stakes)).

---

## What's inside

```
.
├── CLAUDE.md                          # Global rules + the ceremony-by-stakes table
├── THIRD_PARTY_LICENSES.md            # Licenses of the vendored skill packs
├── docs/
│   ├── progress.md                    # Cross-session state handoff
│   ├── learnings.md                   # Error → rule log (Compound Engineering)
│   ├── git-workflow.md                # Team Git, CI/CD, and deploy guide
│   └── decisions/                     # Architecture decision records (ADRs)
├── scripts/
│   ├── sync-upstream.sh               # Re-vendor skills at the pinned upstream commits
│   └── check-skills.sh                # Integrity checks for .claude/ (run in CI)
├── src/
│   └── CLAUDE.md                      # Directory-level rules for src/
├── .claude/
│   ├── settings.json                  # Hooks (eslint + prettier on write) + permissions
│   ├── VENDORED.md                    # What was copied from where, pins, and local edits
│   ├── agents/                        # code-reviewer, security-auditor, test-engineer (Addy)
│   ├── commands/                      # /spec /plan-tasks /build /test /review-code /ship
│   │                                  # /code-simplify /constraints (Addy), /handoff
│   ├── references/                    # Checklists the Addy skills cite
│   └── skills/
│       ├── start-feature/             # /start-feature — classify stakes, route the work
│       ├── open-pr/                   # /open-pr — gate, commit, push, open PR
│       ├── prove-it-works/            # Verify on the real thing (from pstack)
│       ├── grill-me/ grilling/        # Design interrogation (Matt)
│       ├── to-tickets/ pr/            # Plan → GitHub issues, PR body template (Matt)
│       └── …                          # 16 lifecycle skills (Addy), see .claude/VENDORED.md
└── .github/
    ├── workflows/
    │   ├── ci.yml                     # Lint + type check + test + build on every push
    │   ├── template-checks.yml        # Runs scripts/check-skills.sh (no Node needed)
    │   ├── deploy-staging.yml         # Auto-deploy to staging on merge to main
    │   └── deploy-production.yml      # Manual-trigger production deploy with approval gate
    ├── ISSUE_TEMPLATE/                # Feature and bug issue templates
    ├── pull_request_template.md       # Summary / Evidence / Merge Danger (same as /open-pr)
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

### 5. Start Claude Code and initialize the project

```bash
claude --dangerously-skip-permissions
```

Then run these once per project:
```
/run-skill-generator     # generates a project-specific script to launch your app (used by prove-it-works)
/constraints             # writes CONSTRAINTS.md, the quality bar /open-pr guards
```

Install the [GitHub CLI](https://cli.github.com) (`gh`) — `/to-tickets` and `/open-pr` use it — and `jq`, which the format-on-save hook needs (without it the hook silently does nothing).

### 6. Start your first feature

```
/start-feature [your first issue or feature description]
```

---

## How the workflow works

### Ceremony by stakes

`/start-feature` first moves you off `main` onto a feature branch, then classifies the work. A small tweak is done on the spot (after you confirm the diff, if it came from an issue); everything else gets a command sequence and stops so you drive each step. The table lives in `CLAUDE.md`:

| Tier | When | Flow |
|---|---|---|
| Small tweak | ≤2 files, <50 lines, and no auth / payments / data access / config / env | Make the change → `prove-it-works` → `/open-pr` |
| Small feature | Clear requirement, one slice | `/grill-me` → `/test` → `/open-pr` |
| Big / fuzzy | Unclear requirement, or spans several modules | `/grill-me` → `/spec` → `/plan-tasks` → `/to-tickets` → `/build` (or `/build auto`) → `/review-code` → `/open-pr` |
| Production / security / irreversible | Auth, payments, data migrations, deploys, or anything `git revert` can't undo | The Big flow, plus `/doubt-driven-development` and the `security-and-hardening` skill; run `/ship` for a go/no-go before `/open-pr` |

In the Big tier, `/to-tickets` turns each task in `tasks/plan.md` into a GitHub issue and writes its `#N` back onto the task line in `tasks/todo.md`. A Big feature may ship over several PRs: each `/open-pr` closes the issues of the tasks that PR checked off, and only references the parent issue.

### After the PR

```
/open-pr                          quality gate → constraint guard → commit → push → PR
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
3. Extract a rule and add it to `CLAUDE.md` or `CONSTRAINTS.md`
4. Commit: `docs: add constraint for [what you learned]`

The whole team benefits immediately — Claude won't repeat that mistake.

---

## Command reference

| Command | What it does | From |
|---|---|---|
| `/start-feature [desc]` | Classify stakes, then do the tweak or print the command sequence | scaffold |
| `/grill-me` | Interview you round by round until the design has no open branches | Matt |
| `/spec` | Write `SPEC.md` before any code | Addy |
| `/plan-tasks` | Break the spec into small, verifiable tasks in `tasks/plan.md` | Addy |
| `/to-tickets` | Publish each plan task as a GitHub issue with blocking edges | Matt |
| `/build` / `/build auto` | Implement the next task (or every task after one approval), test-first | Addy |
| `/test` | TDD for features; prove-it pattern for bugs | Addy |
| `/review-code` | Five-axis review: correctness, readability, architecture, security, performance | Addy |
| `/code-simplify` | Reduce complexity without changing behavior | Addy |
| `/constraints` | Set the quality bar (`CONSTRAINTS.md`); `guard` checks a diff against it | Addy |
| `/ship` | Parallel review by three personas → go/no-go with a rollback plan | Addy |
| `/open-pr [issues]` | Gate, commit, push, and open a PR that closes its issues | scaffold |
| `/handoff` | Save session state to `docs/progress.md` before stopping | scaffold |

`/plan` and `/review` are Claude Code built-ins (plan mode and `/code-review`), which is why Addy's commands are renamed here. To pull newer upstream versions, bump the SHA in `.claude/VENDORED.md` and run `scripts/sync-upstream.sh`.

---

## Git workflow summary

```
main               protected, always deployable, auto-deploys to staging on merge
feature/[N]-[desc] your working branch — lives 1–3 days, its PR closes at least one issue
```

**Branch naming**: `feature/42-google-oauth`, `fix/87-redirect-loop`, `chore/update-deps`

**Commit format**: `feat(auth): add Google OAuth login` — Conventional Commits, applied by `/open-pr`

**Merge strategy**: Squash and Merge — keeps main history clean and readable

Full details in `docs/git-workflow.md`.

---

## Team onboarding

When a new developer joins:

1. Clone the repo
2. Copy `.env.example` → `.env.local` and fill in values
3. Read `CLAUDE.md`, `CONSTRAINTS.md`, `docs/decisions/`, and `docs/git-workflow.md`
4. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
5. Start from the project root: `claude --dangerously-skip-permissions`
6. Pick up an issue: `/start-feature [issue number or description]`

---

## Maturity path

**Week 1 — Foundations**
- [ ] Fill in `CLAUDE.md` placeholders for your project
- [ ] Run `/constraints` and `/run-skill-generator`
- [ ] Use `/start-feature` for every change and follow the tier it picks
- [ ] Use `/clear` before every new feature
- [ ] Ship your first PR with `/open-pr`

**Week 2 — Team workflow**
- [ ] Confirm CI is running on every PR (`ci.yml`)
- [ ] Configure and test staging deploy (`deploy-staging.yml`)
- [ ] Install the Claude GitHub App for automatic PR review
- [ ] Run a Big-tier feature end to end: `/spec` → `/plan-tasks` → `/to-tickets` → `/build`
- [ ] Start logging bugs to `docs/learnings.md`

**Week 3+ — Advanced**
- [ ] Try `/build auto` once a spec and plan exist
- [ ] Configure Playwright or Chrome DevTools MCP for UI verification
- [ ] Enable production deploy with approval gate (`deploy-production.yml`) and gate it with `/ship`
- [ ] Sync upstream skills with `scripts/sync-upstream.sh`

---

## Design decisions

**Why `--dangerously-skip-permissions`?**
Prevents Claude from pausing to ask permission for safe, expected operations like running eslint or tsc. In this mode the `deny` list in `.claude/settings.json` is a tripwire, not a boundary: it matches command prefixes, so variants such as `git push origin main --force` slip past it. The real protection has to live outside the agent:
- **GitHub branch protection** on `main`: require PRs and reviews, block force pushes and deletion, disallow admin bypass.
- **A sandbox** for unattended runs: `/sandbox`, a devcontainer, or a disposable VM.

If you don't have both, run with `--permission-mode acceptEdits` instead, so shell commands outside the `allow` list still ask first. That is not a sandbox either: edits are auto-approved, and an edited `package.json` script or lint config runs through `npm run` or the format hook without a prompt, while some allowed commands (`git rebase`, `git fetch`, `git diff`) take flags that run or write arbitrary things. Neither the `deny` list nor `acceptEdits` is a sandbox; for untrusted input (issues, fetched docs) use the default permission mode or `/sandbox`.

**Why ceremony by stakes?**
A one-line fix doesn't need a spec, and an auth change shouldn't ship without one. Matching process to risk keeps small changes fast and big ones safe.

**Why vendor skills instead of installing plugins?**
Only the skills with a caller in this workflow are copied, pinned to a commit, and kept consistent with each other (renamed commands, shared paths). Installing the full packs would add dozens of overlapping skills that compete to trigger. Don't also install these packs as plugins, or every skill appears twice.

**Why trunk-based development?**
Short-lived branches mean small, reviewable PRs. Each Claude session maps cleanly to one branch and one PR — context stays clean and reviews stay focused.

**Why Squash and Merge?**
Each merge to `main` produces one commit with a Conventional Commits message matching the PR title. The history stays readable and tooling like release-please can parse it automatically.

**Why write tests before implementation?**
Claude Code tends to write tests that match its own implementation. Spec-first tests reflect actual requirements, catch different bugs, and survive refactors better.

---

## References

- [Claude Code documentation](https://docs.anthropic.com/claude-code)
- [Addy Osmani — agent-skills](https://github.com/addyosmani/agent-skills)
- [Matt Pocock — skills](https://github.com/mattpocock/skills)
- [pstack](https://github.com/cursor/plugins/tree/main/pstack)
- [Compound Engineering — Kieran Klaassen](https://every.to/superorganizers/compound-engineering)
- [Conventional Commits specification](https://www.conventionalcommits.org)
