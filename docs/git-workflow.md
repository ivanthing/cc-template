# Git Workflow & Team Collaboration Guide

> This document defines how the team uses Git, branches, PRs, CI/CD, and deploys.
> Claude Code agents follow these rules automatically via CLAUDE.md and the `/open-pr` skill.

---

## Branch Strategy

We follow a **trunk-based development** model with short-lived feature branches.

```
main          ──●──────────────────●──────── (protected, always deployable)
                 \                /
feature/login    ──●──●──●──●──●──           (your feature branch)
```

### Branch Naming Convention
```
feature/[issue-number]-[short-description]   # new features
fix/[issue-number]-[short-description]       # bug fixes
chore/[short-description]                    # non-functional changes
docs/[short-description]                     # documentation only
```

**Examples**:
```
feature/42-google-oauth
fix/87-login-redirect-loop
chore/update-dependencies
docs/api-authentication
```

### Rules
- `main` is **protected** — no direct pushes, ever
- Feature branches live for **1–3 days max** — keep PRs small and focused
- Every PR closes at least one GitHub Issue — a Big-tier feature may span several PRs, each closing the task issues it completed
- Delete the branch after the PR is merged

---

## Commit Convention

We use **Conventional Commits** (applied by the `git-workflow-and-versioning` skill via `/open-pr`).

### Format
```
<type>(<scope>): <short description>

[optional body — explain WHY, not what]

[optional footer — issue references, breaking changes]
```

### Types
| Type       | When to use                                      |
|------------|--------------------------------------------------|
| `feat`     | New feature visible to users                     |
| `fix`      | Bug fix                                          |
| `docs`     | Documentation changes only                       |
| `style`    | Formatting, no logic change                      |
| `refactor` | Code restructure, no behavior change             |
| `test`     | Adding or updating tests                         |
| `chore`    | Build process, dependency updates, config        |
| `ci`       | CI/CD pipeline changes                           |

### Examples
```
feat(auth): add Google OAuth login

Implements Google OAuth 2.0 using BetterAuth.
Users can now sign in with their Google account in addition to email/password.

closes #42

---

fix(dashboard): correct revenue calculation for refunded orders

The previous formula counted refunded transactions as revenue.
This fix excludes any transaction with status = 'refunded'.

closes #87
```

### Rules
- Title line: **72 characters max**, imperative mood ("add" not "added")
- Body: explain the **why**, not the what (the diff shows the what)
- Reference every Issue the change completes: `closes #[number]`, one line per issue
- Breaking changes: add `BREAKING CHANGE:` in the footer

---

## Pull Request Workflow

### Before Opening a PR
```bash
# 1. Make sure your branch is up to date
git fetch origin
git rebase origin/main

# 2. Run the full quality suite
npm run test
npm run lint
npm run build

# 3. Use /open-pr — it runs the quality gate, commits, pushes, and opens the PR
/open-pr
```

### PR Requirements (enforced via GitHub branch protection)
- [ ] All CI checks pass (lint, test, build)
- [ ] At least 1 team member approval
- [ ] Claude automated review completed (only if you kept `claude-review.yml`; see GitHub Actions Workflows)
- [ ] PR closes at least one GitHub Issue (`closes #XX`)
- [ ] Branch is up to date with main

### PR Title Format
Same as commit title: `feat(auth): add Google OAuth login`

### PR Description Template
See `.github/pull_request_template.md` — it's auto-populated when you open a PR, and matches the body `/open-pr` writes (Summary / Evidence / Merge Danger).

### Review Process
1. **Automated review** (Claude GitHub App, if you kept `claude-review.yml`) — runs on every same-repo PR; fork PRs skip it
   - Checks for bugs and security vulnerabilities
   - Does NOT comment on style (the prompt is in `.github/workflows/claude-review.yml`)
2. **Team review** — at least one approval required
   - Focus on: business logic, architecture decisions, edge cases
   - Not on: formatting (handled by prettier), style preferences
3. **Author merges** — the PR author clicks Merge after approval

### Merge Strategy
- Use **Squash and Merge** to keep main history clean
- The squash commit message = PR title (which follows Conventional Commits)
- Never use "Merge commit" — it pollutes the log

---

## CI/CD Pipeline

### Pipeline Overview

```
Push to any branch
        ↓
   [CI: Checks]
   lint + typecheck + test + build
        ↓
   PR opened → [Claude code review]
        ↓
   PR approved + merged to main
        ↓
   [CD: Deploy to Staging]  ← automatic
        ↓
   Manual approval (team lead)
        ↓
   [CD: Deploy to Production]  ← manual trigger
```

### GitHub Actions Workflows

#### 1. `ci.yml` — Runs on every push and PR
Checks: lint → type check → tests → build (skipped until `package-lock.json` exists)
See `.github/workflows/ci.yml`

#### 2. `template-checks.yml` — Runs on every push and PR
Runs `scripts/check-skills.sh` and lints the workflows with actionlint. Needs no Node.
See `.github/workflows/template-checks.yml`

#### 3. `claude-review.yml` — Runs on every same-repo PR
Claude reviews the PR for bugs and security issues. Needs the Claude GitHub App and the `ANTHROPIC_API_KEY` secret; delete it if you don't use it.
See `.github/workflows/claude-review.yml`

#### 4. `deploy-staging.yml` — Runs on merge to main
Deploys automatically to the staging environment.
See `.github/workflows/deploy-staging.yml`

#### 5. `deploy-production.yml` — Manual trigger only
Requires explicit team lead approval via GitHub Actions manual dispatch.
See `.github/workflows/deploy-production.yml`

### Environment Variables
| Variable         | Local (`.env.local`) | Staging        | Production     |
|------------------|----------------------|----------------|----------------|
| `DATABASE_URL`   | local postgres        | staging DB URL | prod DB URL    |
| `AUTH_SECRET`    | any local secret      | GitHub Secret  | GitHub Secret  |
| `NEXT_PUBLIC_*`  | `.env.local`          | GitHub Var     | GitHub Var     |

**Rules**:
- Never commit `.env*` files
- Production secrets live only in GitHub Secrets (Settings → Secrets)
- Use `NEXT_PUBLIC_` prefix only for values safe to expose to the browser

---

## Environments

| Environment | Branch  | Trigger    | URL                        | Purpose                    |
|-------------|---------|------------|----------------------------|----------------------------|
| Local       | any     | manual     | localhost:3000             | Individual development      |
| Staging     | main    | auto       | staging.[your-domain].com  | QA, team review, demos     |
| Production  | main    | manual     | [your-domain].com          | Live users                  |

### Staging Rules
- Staging always reflects the current state of `main`
- Use staging to demo features before production release
- Staging can be reset/wiped at any time — no persistent user data

### Production Rules
- Only deploy after team lead approval
- Always check staging first
- Keep a rollback plan: Vercel/platform allows instant rollback to previous deploy

---

## Team Collaboration with Claude Code

### One Developer Per Feature
Each team member works on their own feature branch. Claude Code is a per-developer tool — it reads and writes files in your local working directory.

**Conflict prevention**:
```bash
# Before starting work each day, sync with main
git fetch origin
git rebase origin/main

# If you're working on a large feature that overlaps with a teammate's,
# use git worktrees to isolate Claude Code sessions
git worktree add ../project-feature-b feature/b
cd ../project-feature-b
claude
```

### Shared Knowledge (Claude reads these)
These files are the team's shared brain that Claude Code loads at session start:

| File                    | Owner         | Update frequency      |
|-------------------------|---------------|-----------------------|
| `CLAUDE.md`             | Team lead     | Weekly or as needed   |
| `CONSTRAINTS.md`        | Team          | As new patterns emerge|
| `docs/decisions/`       | Tech lead     | Per major decision    |
| `docs/learnings.md`     | Everyone      | After every incident  |

### How to Update Team Rules
When you discover a pattern Claude keeps getting wrong:
1. Fix the current session manually
2. Open the relevant file (`CLAUDE.md` or `CONSTRAINTS.md`)
3. Add the rule in plain English
4. Commit with: `docs: add constraint for [what you learned]`
5. The whole team benefits immediately

### Onboarding a New Team Member
1. Clone the repo
2. Copy `.env.example` → `.env.local` and fill in values
3. Read `CLAUDE.md`, `CONSTRAINTS.md`, `docs/decisions/`, and this file
4. Install Claude Code: `npm install -g @anthropic-ai/claude-code`
5. Run: `claude` from the project root. The default permission mode is enough: the `allow` list in `.claude/settings.json` pre-approves the workflow's git, gh and npm steps; ad-hoc verification commands still ask. Use `--dangerously-skip-permissions` only inside a devcontainer or another sandbox (see README → Design decisions).
6. Start with: `/start-feature [your first issue]`

---

## Quick Reference

```bash
# Daily start
git fetch origin && git rebase origin/main

# Start a feature
git checkout -b feature/[issue-number]-[description]
claude
/start-feature [describe the feature]

# During development — Claude handles commits, but manual checkpoint:
git add <changed files> && git commit -m "chore: checkpoint before refactor"

# Finish a feature
/open-pr                       # gates, commits, pushes, creates PR

# After PR is merged — clean up
git checkout main
git pull origin main
git branch -d feature/[your-branch]
```
