# /handoff

Save session state for the next session or a teammate picking up the work.
Run this before closing Claude Code.

## Usage
```
/handoff [optional: extra notes]
```

## Steps

1. **Summarize what was completed in this session**

2. **Update `docs/progress.md`**:
   - Mark completed tasks as done
   - Update "In Progress" and "Up Next"
   - Record the current branch name
   - Write a clear "Notes for Next Session" section:
     - Exactly what to do next (be specific)
     - Any current blockers
     - Gotchas or things to watch out for
     - $ARGUMENTS if extra notes were provided

3. **Remind the user to**:
   - Run `git add -A && git commit -m "chore: checkpoint"` if they haven't committed recently
   - Push the branch: `git push origin [branch-name]`

4. **Optional**: If the session produced key learnings, append them to `docs/learnings.md`
