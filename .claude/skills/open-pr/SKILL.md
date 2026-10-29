---
name: open-pr
description: Gate, commit, push, and open a pull request for the current branch, closing the GitHub issues it completes.
argument-hint: "[issue numbers] [extra PR context]"
disable-model-invocation: true
---

# Open PR

Ship the current branch as a pull request. Arguments: $ARGUMENTS

The default branch is the one `git symbolic-ref --short refs/remotes/origin/HEAD` names; with no remote, whichever of `main` or `master` exists. "The branch diff" below means `git diff <default>...HEAD` plus any uncommitted changes.

1. **Check the branch.** If on the default branch, stop and ask the user to create a branch named per `docs/git-workflow.md` (`git switch -c <name>` carries any local commits over).
2. **Quality gate.** Run the test, lint, and build commands from `CLAUDE.md`. If any fails, stop and follow the `debugging-and-error-recovery` skill; do not open the PR.
3. **Constraint guard.** If `CONSTRAINTS.md` exists, follow the `constraint-driven-development` skill to run the `guard` check defined in `.claude/commands/constraints.md` against the branch diff: lowered thresholds, skipped or deleted tests, new suppression comments, unfinished stubs, new exceptions. Stop on any finding. If `CONSTRAINTS.md` does not exist, skip this step and tell the user to run `/constraints` once to set up the project's quality bar.
4. **Evidence.** Follow the `prove-it-works` skill, reusing evidence already gathered this session for the same change, and keep its output for the PR body.
5. **Commit.** If the branch diff doesn't touch `docs/progress.md`, remind the user to update it (e.g. with `/handoff`), then carry on without waiting. If there are uncommitted changes, stage only the files this change touched (never `git add -A`) and commit with a Conventional Commits message per the `git-workflow-and-versioning` skill. If the tree is clean and the branch already has commits (e.g. from `/build`), skip the commit.
6. **Issues.** Collect the issues this PR closes, as the union of:
   - issue numbers given in the arguments, except the `Parent: #N` recorded at the top of `tasks/todo.md`: reference a parent with `Refs #N`, never close it;
   - the `#N` on every task line the branch diff changes from `- [ ]` to `- [x]` in `tasks/todo.md` (written there by `/to-tickets`). A Big-tier feature may ship over several PRs; each closes only the tasks it checked off.

   If that leaves nothing, use the number in the branch name (`feature/<N>-…`, `fix/<N>-…`). Only if there is still none, create one with `gh issue create` (title and a short "What / Why" body describing the change) and use its number.
7. **Push.** `git push -u origin HEAD`.
8. **Open the PR.** `gh pr create` with a Conventional Commits title summarizing the branch, and a body written with the `pr` skill's template: the Evidence section holds the step 4 output, and the body ends with one `closes #N` line per issue from step 6 (plus any `Refs #N`). Add any extra context from the arguments. Return the PR URL.
