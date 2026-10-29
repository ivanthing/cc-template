# Constraints — What NOT to Do

> This file documents what to avoid. It complements CLAUDE.md's "what to do."
> Append new anti-patterns whenever you discover them.

## UI / Design
- Do not use default AI color palettes (blue/white, purple/white) unless required by brand
- Do not use emojis as functional UI elements
- Do not use inline style attributes — use Tailwind classes only
- Do not create UI components not defined in the PRD

## Code Standards
- Do not use `any` type in TypeScript — always be explicit
- Do not commit `console.log` debug statements
- Do not write single-file components over 200 lines — split them
- Do not use `// @ts-ignore` — fix the type error properly

## Architecture Boundaries
- Do not query the database directly from client components
- Do not hardcode API keys or secrets — use environment variables
- Do not build features outside the PRD scope without updating the PRD first
- Do not run large refactors without a git commit checkpoint first

## Agent Behavior
- Report problems before acting — do not self-initiate large refactors
- Never modify test files to make tests pass — fix the implementation instead
- Do not tackle more than 3 unrelated features in a single session
- Do not skip Plan Mode for complex features — always plan before coding

## Project-Specific Constraints (fill in for your project)
- [e.g. Do not modify /src/lib/auth — auth logic is stable]
- [e.g. Do not alter database schema files directly — write a migration instead]
