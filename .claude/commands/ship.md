# /ship

Complete the feature: run quality checks, commit, push, and open a PR.

## Usage
```
/ship [optional: extra PR context]
```

## Steps

1. **Quality gate** (all must pass before continuing)
   ```bash
   npm run test    # all tests must pass
   npm run lint    # zero lint errors
   npm run build   # build must succeed
   ```
   If anything fails, fix it before proceeding.

2. **Cleanup**
   - Run the tech-debt skill to remove obvious debt introduced this session
   - Remove any debug code or leftover `console.log` statements

3. **Update documentation**
   - Update `docs/progress.md`
   - Append any new learnings to `docs/learnings.md`
   - Run `/compact` to summarize the session; save the summary to `docs/progress.md`

4. **Commit** using the commit agent
   - Stage all changes: `git add -A`
   - Generate a Conventional Commit message
   - Show the message to the user, then execute the commit

5. **Push and open PR**
   - `git push origin [current-branch]`
   - Create a PR with:
     - Title: matches the commit message format
     - Body: auto-filled from `.github/pull_request_template.md`
     - Linked issue: `closes #[issue-number]`
     - $ARGUMENTS added to the description if provided
