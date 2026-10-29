# /lfg (Let's F***ing Go)

One command to run the entire feature development cycle end-to-end.
Use this once you are comfortable with the individual steps.

## Usage
```
/lfg [feature description]
```

## Warning
This command runs many steps autonomously. Before using it, confirm:
- You are on the correct feature branch
- You have a PRD or enough context in the description
- You understand what Claude will do at each step

## Automated Sequence

1. **Load context** — read progress.md, learnings.md, constraints.md
2. **Deep planning** — more thorough than standard Plan Mode:
   searches docs, reads existing code patterns, looks up best practices
3. **Plan review** — presents the plan and waits for your approval **(this step is mandatory and never skipped)**
4. **Implement** — executes the approved plan
5. **Test** — runs the full test suite, fixes failures in the implementation
6. **UI validation** — if Playwright MCP is configured, validates user flows in the browser
7. **Code review** — multi-perspective review via the /review command
8. **Tech debt cleanup** — removes debt introduced during this session
9. **Ship** — commits, pushes, opens PR
10. **Update docs** — learnings.md and progress.md

## Notes
- Step 3 (plan review) always requires your confirmation — it will not proceed without it
- If anything unexpected happens, Claude stops and reports before continuing
- The full cycle typically takes 30-90 minutes depending on feature complexity
