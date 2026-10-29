---
name: start-feature
description: Classify a piece of work by stakes and route it to the matching amount of ceremony.
argument-hint: "[issue number or description of the change]"
disable-model-invocation: true
---

# Start Feature

Match the ceremony to the stakes of: $ARGUMENTS

1. **Load context.** Read `docs/progress.md` and `docs/learnings.md`. If `$ARGUMENTS` is an issue number, read the issue with `gh issue view`.
2. **Classify.** Pick a tier from the **Ceremony by Stakes** table in `CLAUDE.md`. State the tier and the one-line reason (which criterion decided it). When the work sits between two tiers, pick the higher one.
3. **Route.**
   - **Small tweak:** make the change now, then follow the `prove-it-works` skill and report the evidence. Do not stop for approval.
   - **Any other tier:** print the tier's command sequence from the table, one command per line, filled in with this work's arguments. Then stop. Make no edits: the user runs each command.
