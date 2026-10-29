# /review

Multi-perspective code review of recent changes. Produces a prioritized list of issues.

## Usage
```
/review [optional: specific file or feature scope]
```

## Steps

Review scope: $ARGUMENTS or the output of `git diff main...HEAD`

**Five review lenses (run as parallel sub-agents):**

1. **Correctness** — Does the code do what the PRD says? Are there missing cases?
2. **Security** — Injection risks, auth gaps, exposed secrets, unsafe data handling?
3. **Code quality** — Duplication, oversized functions, unclear naming?
4. **Performance** — N+1 queries, unnecessary re-renders, memory leak risks?
5. **Maintainability** — Will the next developer understand this code easily?

**Output:**
Write findings to `docs/todos/review-[YYYY-MM-DD].md`, grouped by priority:

```
P1 Critical  - Must fix before merge
P2 High      - Should fix in this PR
P3 Medium    - Schedule for next sprint
P4 Low       - Nice to have
```

Wait for the user to confirm which issues to address before making any changes.
