---
name: open-pr
description: Gate, commit, push, and open a pull request for the current change, linked to its GitHub issue.
argument-hint: "[issue number] [extra PR context]"
disable-model-invocation: true
---

# Open PR

Ship the current change as a pull request. Arguments: $ARGUMENTS

1. **Check the branch.** If on `main`, stop and ask the user to create a branch named per `docs/git-workflow.md`.
2. **Quality gate.** Run the test, lint, and build commands from `CLAUDE.md`. If any fails, stop and follow the `debugging-and-error-recovery` skill; do not open the PR.
3. **Constraint guard.** If `CONSTRAINTS.md` exists, follow the `constraint-driven-development` skill to run the `guard` check defined in `.claude/commands/constraints.md` against the diff: lowered thresholds, skipped or deleted tests, new suppression comments, unfinished stubs, new exceptions. Stop on any finding. If `CONSTRAINTS.md` does not exist, skip this step and tell the user to run `/constraints` once to set up the project's quality bar.
4. **Evidence.** Follow the `prove-it-works` skill and keep its output for the PR body.
5. **Issue.** Use the issue number from the arguments. If none was given, create one with `gh issue create` (title and a short "What / Why" body describing the change) and use its number.
6. **Commit.** Stage only the files this change touched, never `git add -A`. Write a Conventional Commits message per the `git-workflow-and-versioning` skill, ending with `closes #<issue>`.
7. **Push.** `git push -u origin HEAD`.
8. **Open the PR.** `gh pr create` with the commit's title, and a body written with the `pr` skill's template: the Evidence section holds the step 4 output, and the body ends with `closes #<issue>`. Add any extra context from the arguments. Return the PR URL.
