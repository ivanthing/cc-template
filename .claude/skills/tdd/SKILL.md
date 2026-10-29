---
name: tdd
description: Test-driven development cycle. Write tests first, then implement, then refactor. Trigger words: TDD, write tests first, test-first, red green refactor.
---

# TDD Skill

Test-Driven Development: write the test (red), make it pass (green), then improve the code (refactor).

## Core Principle
**Tests are executable specifications, not implementation comments.**
They are written from the PRD acceptance criteria — not from looking at the code.

## The Cycle

**Red — Write a failing test**
1. Read the acceptance criteria in `docs/PRD.md`
2. Translate each criterion into a test case
3. Run the tests and confirm they fail (because nothing is implemented yet)
4. Tests must describe behavior, not implementation details

**Green — Make it pass with minimal code**
1. Write the least code needed to make the test pass
2. Do not over-engineer — just make it green
3. Run the tests and confirm they pass

**Refactor — Improve under test protection**
1. Clean up the code while the tests are green
2. Extract repeated logic, improve naming, remove duplication
3. Run the tests after every meaningful change to confirm nothing broke

## Test Layers

| Layer       | What to test                              | Tool                  |
|-------------|-------------------------------------------|-----------------------|
| Unit        | Pure functions, utilities, business logic | Jest / Vitest         |
| Integration | API routes, database interactions         | Jest + test DB        |
| E2E         | Full user flows                           | Playwright            |

## Hard Rules
- Never modify a test file to make it pass — fix the implementation
- Tests must cover all PRD acceptance criteria
- Edge cases and error paths need tests too, not just the happy path
