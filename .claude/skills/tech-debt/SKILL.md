---
name: tech-debt
description: End-of-session technical debt cleanup. Finds and removes duplication introduced during the current session. Run before /ship. Trigger words: tech debt, clean up, end of session, tidy up, deduplicate.
---

# Tech Debt Skill

Clean up technical debt introduced during the current development session.
Run this before `/ship` to keep the codebase healthy over time.

## Workflow

1. **Scope the session** — run `git diff main...HEAD` to see what changed
2. **Find debt**:
   - Copy-pasted logic that could be a shared function
   - Functions over 50 lines that should be split
   - Magic numbers and strings that should be named constants
   - Stale TODO comments
   - Unused imports and variables
3. **Create shared utilities** — extract repeated logic to a shared location
4. **Update all references** — make sure everything still points to the right place
5. **Verify** — run the full test suite to confirm behavior is unchanged

## Report Format

List findings by impact, then wait for confirmation before changing anything:

```
High   - Will cause bugs or serious maintenance issues (fix now)
Medium - Code quality problem (fix in this session)
Low    - Minor improvement (log and move on)
```

## Session Wrap-Up

After cleanup is done:
1. Add any new learnings to `docs/learnings.md`
2. Update `docs/progress.md`
3. Suggest any new rules worth adding to `CLAUDE.md`
