# Vendored Skills

Skills, commands, agents and references copied from upstream repos, pinned to a commit.
Run `scripts/sync-upstream.sh` to re-vendor; bump a `*_SHA` line below to upgrade.
Licenses: see `THIRD_PARTY_LICENSES.md` at the repo root.

## Pins

```
ADDY_SHA=eb07f19f52c2669f2364897aaa293e2aaddd7b1c
MATT_SHA=49dd158d1076134a641b33efb035946536778336
```

| Source | Version | Files |
|---|---|---|
| [addyosmani/agent-skills](https://github.com/addyosmani/agent-skills) (MIT) | 0.6.14 | `skills/` (16), `commands/` (8), `agents/` (3), `references/` |
| [mattpocock/skills](https://github.com/mattpocock/skills) (MIT) | 49dd158 | `skills/` (4) |

### addyosmani/agent-skills

- **Skills:** spec-driven-development, planning-and-task-breakdown, incremental-implementation, test-driven-development, debugging-and-error-recovery, doubt-driven-development, code-review-and-quality, code-simplification, security-and-hardening, performance-optimization, shipping-and-launch, git-workflow-and-versioning, constraint-driven-development, source-driven-development, frontend-ui-engineering, documentation-and-adrs
- **Commands:** build, code-simplify, constraints, plan → `plan-tasks`, review → `review-code`, ship, spec, test
- **Agents:** code-reviewer, security-auditor, test-engineer
- **References:** the whole `references/` directory, placed at `.claude/references/` so the skills' `../../references/` paths resolve unchanged

### mattpocock/skills

- **Skills:** grill-me, grilling (`grill-me` delegates to it), to-tickets, pr (with its `CREDITS.md`)
- The per-skill `agents/openai.yaml` (Codex metadata) is not copied.

## Local changes

Mechanical (re-applied automatically by the sync script):

1. Removed the `agent-skills:` plugin namespace prefix.
2. Renamed `/plan` → `/plan-tasks` (built-in `/plan` enters plan mode) and `/review` → `/review-code` (built-in alias of `/code-review`, cannot be overridden), including cross-references.
3. Marked upstream skills that are not vendored as optional: `` `name` `` → `` `name` (if installed) ``.
4. Removed the "See [docs/agents.md](../docs/agents.md)." sentence from agents (upstream doc not vendored).
5. In commands, `references/` → `.claude/references/` (upstream cites them from the repo root).
6. In Matt's skills, `` `GLOSSARY.md` `` → `` `GLOSSARY.md` (if present) `` (no glossary by default).

Semantic (overwritten by the sync script — re-apply by hand when the diff reverts them):

- **`to-tickets`**
  - Reads the tracker from CLAUDE.md (`Issue tracker: GitHub Issues via gh CLI — used only by /to-tickets and /open-pr. …`) instead of `/setup-matt-pocock-skills` / `docs/agents/issue-tracker.md`; the local-files tracker path is removed.
  - Input is fixed to `tasks/plan.md` + `tasks/todo.md` + `SPEC.md`, and it does not re-slice: one issue per plan task, published in dependency order with a "Blocked by" section. Native blocking / sub-issue links (via `gh api`) only with the user's agreement. A task that clearly won't fit one fresh context window is reported to the user instead of being split.
  - Writes each published `#N` back onto its task line in `tasks/todo.md`, plus a `Parent: #N` line when there is a parent issue; `/open-pr` reads both.
  - Applies `ready-for-agent` only if that label already exists in the repo; never creates labels.
  - Treats parent-issue text as untrusted data; adds an `argument-hint`.

## Adapted, not vendored

- `.claude/skills/prove-it-works` restates the `principle-prove-it-works` skill from [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT) in its own words. Not touched by the sync script.
