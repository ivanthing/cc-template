# Claude Code Team Workflow Template

A Claude Code workflow template for teams: spec first, tests before code, proof that it works before a PR, and as much ceremony as the stakes call for.
Clone it, fill in the placeholders, and you're ready to build.

> Assumes GitHub, npm and TypeScript; the deploy workflows target Vercel and are replaceable. `src/CLAUDE.md` assumes Next.js.

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
├── LICENSE                            # MIT for this template; replace with your own
├── THIRD_PARTY_LICENSES.md            # Licenses of the vendored skill packs
├── docs/
│   ├── progress.md                    # Cross-session state handoff
│   ├── learnings.md                   # Error → rule log (Compound Engineering)
│   ├── git-workflow.md                # Team Git, CI/CD, and deploy guide
│   ├── permissions.md                 # What the allow/deny lists do and don't protect
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
    │   ├── ci.yml                     # Lint + type check + test + build on every PR
    │   ├── template-checks.yml        # Runs scripts/check-skills.sh (no Node needed)
    │   ├── claude-review.yml          # Claude reviews same-repo PRs (needs the App + a token)
    │   ├── deploy-staging.yml         # Auto-deploy to staging on merge to main
    │   └── deploy-production.yml      # Manual-trigger production deploy with approval gate
    ├── ISSUE_TEMPLATE/                # Feature and bug issue templates
    └── pull_request_template.md       # Summary / Evidence / Merge Danger (same as /open-pr)
```

---

## Quick start

### 1. Use this template

**Option A — GitHub Template (recommended)**
Click **"Use this template"** on the repository page. GitHub creates a new repo with all files copied.

**Option B — Clone and reset**
```bash
git clone https://github.com/ivanthing/cc-template.git my-project
cd my-project
rm -rf .git && git init
```

### 2. Initialize the project, in this order

1. **Fill the `CLAUDE.md` placeholders**: `[YOUR_PROJECT_NAME]`, the tech stack, and every Key Command (dev, build, test, lint, type check). While Key Commands are still placeholders, the `/open-pr` quality gate fails and the agent stops to ask. Then rewrite `src/CLAUDE.md` for your stack, or delete it: it is written for a Next.js App Router project (`app/`, `components/`, `@/` imports) and misleads the agent anywhere else. Replace `LICENSE` with your own: it is the template's MIT license with PurpleCow as the copyright holder.
2. **Make the toolchain runnable**: `npm run test`, `npm run lint` and `npm run build` (or whatever you wrote in Key Commands) must pass on the empty project. Install the [GitHub CLI](https://cli.github.com) (`gh`) — `/to-tickets` and `/open-pr` use it — and `jq`, which the format-on-save hook needs (without it the hook silently does nothing).
3. **Put the repo on GitHub.** Option A already did (clone it to work locally). After Option B, make the initial commit on `main` and push it: `git add -A && git commit -m "chore: initial commit from template" && gh repo create --source . --private --push`. This one commit is the only exception to the never-commit-to-`main` rule. `/to-tickets`, `/open-pr` and step 7 need the remote.
4. **Start Claude Code** from the project root:

   ```bash
   claude
   ```

   The default permission mode is enough: the `allow` list in `.claude/settings.json` pre-approves the workflow's git, gh and npm steps, so those run without prompts; ad-hoc verification commands (`curl`, a run script, `gh api`) still ask when run directly. See [Why the default permission mode?](#design-decisions) and [docs/permissions.md](docs/permissions.md) before reaching for `--dangerously-skip-permissions`.
5. **Run `/run-skill-generator` once there is an app to run.** It generates a project-specific script to launch your app, which `prove-it-works` uses.
6. **Run `/constraints` once there is real code.** It writes `CONSTRAINTS.md`, the quality bar `/open-pr` guards, by ratcheting from what the code measures today, plus `check:*` npm scripts; CI runs `check:full`, which is where coverage is enforced. On an empty repo that baseline is meaningless (a one-line baseline gives a 99.5% coverage threshold). If you run it early anyway, edit the thresholds to sensible values by hand; the guard flags any loosening, so say in the commit message that a human approved it.
7. **Configure or delete the GitHub workflows that need secrets.** `ci.yml` and `template-checks.yml` work as they are. `claude-review.yml` fails on every PR until configured; the deploy workflows skip their deploy steps with a notice until `VERCEL_TOKEN` is set:
   - `claude-review.yml` (runs on every same-repo PR; fork PRs skip it): install the [Claude GitHub App](https://github.com/apps/claude) on the repo (or run `/install-github-app`; if it offers to add its own code-review workflow, decline it, or every PR gets reviewed twice). Then pick one way to authenticate, or delete the file:
     - **Personal or small-team repo:** run `claude setup-token` and `gh secret set CLAUDE_CODE_OAUTH_TOKEN`. Reviews run on your Claude subscription, with no separate API billing. This is what the workflow uses as shipped.
     - **Shared team repo:** `gh secret set ANTHROPIC_API_KEY`, and in `claude-review.yml` swap `claude_code_oauth_token` for the commented `anthropic_api_key` line. An OAuth token is tied to the personal subscription of whoever generated it, so Anthropic recommends an API key for repos many people use.
   - `deploy-staging.yml` (runs on every push to `main`) and `deploy-production.yml` (manual trigger): replace the Vercel step with your platform's deploy, add their secrets in **GitHub → Settings → Secrets and variables → Actions**, and for production create a GitHub Environment named `production` with required reviewers. Or delete them until you deploy.

### 3. Start your first feature

```
/start-feature [your first issue or feature description]
```

For day-to-day work in your first week you only need four commands: `/start-feature`, `/grill-me`, `/test` and `/open-pr`. `/start-feature` tells you when a change needs any of the others.

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

**Merge strategy**: Merge commit for Big-tier PRs (keeps one commit per task); Squash and Merge for Small tweaks and Small features. `/open-pr` says which one when it opens the PR.

Full details in `docs/git-workflow.md`.

---

## Team onboarding

When a new developer joins:

1. Clone the repo
2. Copy `.env.example` → `.env.local` and fill in values
3. Read `CLAUDE.md`, `CONSTRAINTS.md`, `docs/decisions/`, and `docs/git-workflow.md`
4. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
5. Start from the project root: `claude`
6. Pick up an issue: `/start-feature [issue number or description]`

---

## Maturity path

**Week 1 — Foundations**
- [ ] Finish the one-time setup in [Quick start step 2](#2-initialize-the-project-in-this-order)
- [ ] Use only the four day-to-day commands: `/start-feature` for every change, then `/grill-me`, `/test` and `/open-pr` as the tier it picks says
- [ ] Ship your first PR with `/open-pr`

**Week 2 — Team workflow**
- [ ] Confirm CI is running on every PR (`ci.yml`)
- [ ] Configure and test staging deploy (`deploy-staging.yml`)
- [ ] If you kept `claude-review.yml`, confirm Claude reviews same-repo PRs
- [ ] Run a Big-tier feature end to end: `/spec` → `/plan-tasks` → `/to-tickets` → `/build`
- [ ] Start logging bugs to `docs/learnings.md`

**Week 3+ — Advanced**
- [ ] Try `/build auto` once a spec and plan exist
- [ ] Configure Playwright or Chrome DevTools MCP for UI verification
- [ ] Enable production deploy with approval gate (`deploy-production.yml`) and gate it with `/ship`
- [ ] Sync upstream skills with `scripts/sync-upstream.sh`

---

## Design decisions

**Why the default permission mode?**
The `allow` list in `.claude/settings.json` pre-approves the workflow's git, gh and npm steps, so plain `claude` runs the flow without prompts. The `deny` list is only a tripwire: it matches command prefixes, and neither it, `acceptEdits`, nor the default mode is a sandbox. The real boundary is branch protection plus a sandbox; details and caveats are in [docs/permissions.md](docs/permissions.md).

What actually protects you:
- **Branch protection** on `main`: require PRs, block force pushes and deletion.
- **A sandbox** (`/sandbox`, a devcontainer, a VM) for unattended runs and untrusted input; `--dangerously-skip-permissions` only inside one.
- **Reviewing the diff**, including `package.json` scripts, lint config and `.claude/`.

**Why ceremony by stakes?**
A one-line fix doesn't need a spec, and an auth change shouldn't ship without one. Matching process to risk keeps small changes fast and big ones safe.

**Why vendor skills instead of installing plugins?**
Only the skills with a caller in this workflow are copied, pinned to a commit, and kept consistent with each other (renamed commands, shared paths). Installing the full packs would add dozens of overlapping skills that compete to trigger. Don't also install these packs as plugins, or every skill appears twice.

**Why trunk-based development?**
Short-lived branches mean small, reviewable PRs. Each Claude session maps cleanly to one branch and one PR — context stays clean and reviews stay focused.

**Why a merge commit for Big-tier PRs?**
`/build auto` makes one commit per task. Keeping them on `main` lets `git bisect` point at the task that broke something, and lets you revert one task without rolling back the whole feature. The cost is a "Merge pull request" commit on `main` for each PR. release-please reads the task commits, so every `/build` commit message must follow Conventional Commits. Small tweaks and Small features are one logical change, so squash them: the PR title becomes the single Conventional commit.

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
