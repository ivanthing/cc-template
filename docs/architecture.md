# Architecture Decision Records (ADR)

> Documents important architectural decisions and the reasoning behind them.
> Prevents future team members (and Claude) from re-debating settled decisions.

## Tech Choices

| Layer      | Choice              | Rationale                        |
|------------|---------------------|----------------------------------|
| Framework  | [e.g. Next.js 15]   | [Why this over alternatives]     |
| Database   | [e.g. PostgreSQL]   | [Why this over alternatives]     |
| Auth       | [e.g. BetterAuth]   | [Why this over alternatives]     |
| Deploy     | [e.g. Vercel]       | [Why this over alternatives]     |

## System Diagram

```
[Sketch your main modules and data flows here]

Client → Next.js App → API Routes → Database
                    ↓
                Auth Layer
```

## Decision Log

### ADR-001: [Decision title]
- **Date**: [YYYY-MM-DD]
- **Status**: [Accepted / Deprecated / Proposed]
- **Context**: [What situation prompted this decision?]
- **Decision**: [What was decided?]
- **Consequences**: [What are the trade-offs?]
