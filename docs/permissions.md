# Permission Model

> What `.claude/settings.json` does and does not protect against. The short version is in the README under "Why the default permission mode?".

## What the lists do

- **`allow`** pre-approves the commands the workflow needs: npm scripts, git branch/commit/push, and the `gh` issue and PR calls. In the default permission mode those steps run without prompts. Anything outside the list, such as ad-hoc verification with `curl` or `gh api`, still asks first when run directly.
- **`deny`** is a tripwire, not a boundary. Rules match command prefixes, so variants such as `git push origin main --force` slip past `Bash(git push --force:*)`.

## Why none of the modes is a sandbox

- **Default mode with this `allow` list:** the list auto-approves commands that can run code or upload files: `npm run`, `npx --no-install -c '<any shell>'`, `git fetch`/`git rebase` (flags such as `--upload-pack` and `--exec`), and `gh issue create` (`--body-file`). The `Read` deny rules do not stop a shell command from reading `.env` files.
- **`--permission-mode acceptEdits`:** edits are auto-approved, so an edited `package.json` script or lint config then runs through `npm run` or the format hook without a prompt.
- **`--dangerously-skip-permissions`:** approves everything, so the `deny` list is the only thing left in the way. Use it only inside a devcontainer or another sandbox, and only with branch protection on.

## What actually protects you

- **GitHub branch protection** on `main`: require PRs and reviews, block force pushes and deletion, disallow admin bypass.
- **A sandbox** for unattended runs and untrusted input (issues from outside contributors, fetched docs): `/sandbox`, a devcontainer, or a disposable VM with no production credentials.
- **Reviewing the diff** before it merges, including changes to `package.json` scripts, lint config and `.claude/`.
