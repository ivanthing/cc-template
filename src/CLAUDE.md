# src/ Directory Rules

> Rules here override the root CLAUDE.md and apply only within src/.
> Example for a Next.js App Router project. Rewrite it for your stack, or delete this file.

## Directory Layout
```
src/
├── app/           # Next.js App Router -- pages and layouts
├── components/
│   ├── ui/        # Base components (shadcn/ui primitives)
│   └── [feature]/ # Feature-level components
├── lib/           # Utilities and third-party wrappers
├── hooks/         # Custom React hooks
├── types/         # TypeScript type definitions
└── server/        # Server-only code (database, auth) -- never import in client components
```

## Import Rules
- Use absolute imports: `@/components/ui/button`
- Never use relative imports across directories (`../../lib/...`)
- Code in `server/` must never be imported by client components

## Component Rules
- File names: PascalCase for components (`UserProfile.tsx`), kebab-case for utilities (`format-date.ts`)
- One primary export per component file
- All props must be explicitly typed -- no `any`
- Components over 200 lines must be split
