---
name: open-pr
description: Gate, commit, push, and open a pull request for the current branch, closing its GitHub issues.
argument-hint: "[issue numbers] [extra PR context]"
disable-model-invocation: true
---

# Open PR

Ship the current branch as a pull request. Arguments: $ARGUMENTS

The default branch is `main` unless `git symbolic-ref refs/remotes/origin/HEAD` says otherwise. "The branch diff" below means `git diff <default>...HEAD` plus any uncommitted changes.

1. **Check the branch.** If on the default branch, stop and ask the user to create a branch named per `docs/git-workflow.md`.
2. **Quality gate.** Run the test, lint, and build commands from `CLAUDE.md`. If any fails, stop and follow the `debugging-and-error-recovery` skill; do not open the PR.
3. **Constraint guard.** If `CONSTRAINTS.md` exists, follow the `constraint-driven-development` skill to run the `guard` check defined in `.claude/commands/constraints.md` against the branch diff: lowered thresholds, skipped or deleted tests, new suppression comments, unfinished stubs, new exceptions. Stop on any finding. If `CONSTRAINTS.md` does not exist, skip this step and tell the user to run `/constraints` once to set up the project's quality bar.
4. **Evidence.** Follow the `prove-it-works` skill, reusing evidence already gathered this session for the same change, and keep its output for the PR body.
5. **Issues.** Collect the issues this PR closes:
   - issue numbers given in the arguments; otherwise
   - every `#N` recorded in `tasks/todo.md` for the tasks this branch delivered (written there by `/to-tickets`); otherwise
   - create one with `gh issue create` (title and a short "What / Why" body describing the change) and use its number.
6. **Commit.** First, if the branch diff doesn't touch `docs/progress.md`, remind the user to update it (e.g. with `/handoff`) and wait for them to update it or say to continue. Then, if there are uncommitted changes, stage only the files this change touched (never `git add -A`) and commit with a Conventional Commits message per the `git-workflow-and-versioning` skill. If the tree is clean and the branch already has commits (e.g. from `/build`), skip this step.
7. **Push.** `git push -u origin HEAD`.
8. **Open the PR.** `gh pr create` with a Conventional Commits title summarizing the branch, and a body written with the `pr` skill's template: the Evidence section holds the step 4 output, and the body ends with one `closes #N` line per issue from step 5. Add any extra context from the arguments. Return the PR URL.
