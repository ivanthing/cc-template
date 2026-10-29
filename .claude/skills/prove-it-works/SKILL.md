---
name: prove-it-works
description: Proves a change works by running the real thing and reading its real output before calling it done. Use before declaring any change complete, and to gather the Evidence section of a PR.
---

# Prove It Works

A change is done when you have watched it work, not when it compiles, the types check, or an agent says so.

Adapted from the `principle-prove-it-works` skill in [cursor/plugins/pstack](https://github.com/cursor/plugins/tree/main/pstack) (MIT).

## Process

1. **Run the real thing.** Start the app, call the endpoint, run the CLI, open the page: whatever exercises the changed behaviour end to end. Use the project's run script if one exists.
2. **Read the actual output.** The response body, the rendered value, the log line, the file on disk. Not a proxy for it: a passing build, a cached result, or a summary from a sub-agent is not evidence.
3. **Capture before and after.** What the behaviour was, what it is now. Screenshots for visual changes; command output or a test that fails before and passes after for everything else.
4. **Script it when you can.** A deterministic check that anyone can re-run beats a one-off observation. Keep its output visible.
5. **When a check fails, doubt the check first.** Confirm you are observing the right process, port, file and build before concluding the system is wrong.

## Output

Report the exact commands you ran and the output that proves the change, ready to paste into a PR's **Evidence** section.

End by reminding the user they can run `/verify` themselves for an independent check: it is user-triggered, so you cannot run it for them.
