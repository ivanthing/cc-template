# /start-feature

Kick off a new feature with full context loaded. Run this at the beginning of every session.

## Usage
```
/start-feature [issue description or issue number]
```

## Steps

1. **Load context**
   - Read `docs/progress.md` to understand where things stand
   - Read `docs/learnings.md` to avoid repeating past mistakes
   - Read `docs/constraints.md` for current project constraints

2. **Verify git state**
   - Run `git status` to confirm the working directory is clean
   - Confirm you are on the correct feature branch (not main)
   - If on main, stop and ask the user to create a feature branch first

3. **Switch to Plan Mode (Shift+Tab)**
   - Analyze the feature to implement: $ARGUMENTS
   - Explore existing relevant code
   - Draft a detailed implementation plan

4. **Present the plan and wait**
   - List every file to be created or modified
   - Explain the approach and key decisions
   - Wait for the user to say "go ahead" or request changes

5. **Implement** (after confirmation)
   - Follow the plan
   - Update `docs/progress.md` after each meaningful milestone
