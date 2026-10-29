---
name: prd-to-issues
description: Breaks a PRD into GitHub Issues using vertical slicing. Each issue delivers end-to-end value. Trigger words: break into issues, create issues, slice the work, task breakdown, vertical slice.
---

# PRD to Issues Skill

Decompose `docs/PRD.md` into focused GitHub Issues using vertical slicing.

## Vertical Slice Principle
Every issue must:
- Cut through **all layers** (UI + API + database + tests) — not just one layer
- Be **independently shippable** — a user can see or feel the change
- **Surface unknown risks early** — do the risky slice first, not last

**Do not create horizontal slices** like "all database migrations" or "all UI components."

## Workflow

1. Read `docs/PRD.md` in full
2. Identify the 2-4 core user stories that define the product
3. For each story, create one GitHub Issue containing:
   - A clear action-oriented title (verb + noun)
   - Why this matters to the user
   - A concrete task checklist (database -> API -> frontend -> tests)
   - Acceptance criteria copied verbatim from the PRD
   - Blocking relationships to other issues
4. Propose an execution order sorted by risk and dependency

## Issue Template

```markdown
## User Value
[What does this deliver to the user?]

## Tasks
- [ ] Database: [schema / migration]
- [ ] API: [endpoint or server action]
- [ ] Frontend: [component / page]
- [ ] Tests: [unit / integration / E2E]

## Acceptance Criteria
- [ ] [Copied from PRD -- specific and testable]
- [ ] [Edge case]

## Dependencies
- Blocked by: #[issue number]
- Blocks: #[issue number]
```
