---
name: improve-arch
description: Architecture review and improvement. Finds opportunities to turn shallow modules into deep ones. Best used when onboarding an existing codebase or as a weekly architecture review. Trigger words: improve architecture, arch review, refactor structure, deep module, technical debt review.
---

# Improve Architecture Skill

Analyze the codebase and surface opportunities to simplify interfaces and deepen modules.
Especially useful when first onboarding an existing project.

## The Deep Module Principle
A good module has a **simple interface** and **complex implementation** (deep).
A bad module has a **complex interface** and **trivial implementation** (shallow).
This skill finds shallow modules and proposes ways to deepen them.

## Workflow

**Phase 1 — Exploration (read only, touch nothing)**
1. Scan the directory structure
2. Identify the main modules and their responsibilities
3. Map the dependency graph between modules

**Phase 2 — Find problems**
Identify:
- Shallow modules (complex to call, simple inside)
- Duplicated logic appearing in multiple places
- Messy dependencies (circular, cross-layer calls)
- Modules that force callers to know too much

**Phase 3 — Produce a candidate list**
List 3-5 "deepening candidates." For each:
- Current state (what makes it problematic)
- Ideal state (what a better interface looks like)
- Expected benefit (what duplication or complexity it eliminates)
- Risk and cost of the change

**Phase 4 — Let the team choose**
Present the list and let the user pick one.
Then generate 3 different interface design options for the chosen candidate.
Wait for a selection before writing any code.

## Rules
- Explore first, propose second, implement only after approval
- One improvement at a time — no big-bang refactors
- Every change must be covered by tests before and after
