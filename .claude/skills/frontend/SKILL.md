---
name: frontend
description: Frontend design and implementation standards. Avoids generic AI aesthetics. Produces well-structured, accessible UI. Trigger words: UI, design, component, page, frontend, make it look good.
---

# Frontend Skill

Produce UI that looks intentionally designed, not AI-generated.

## Avoiding Generic AI Aesthetics

Do not default to:
- `#3B82F6` (default Tailwind blue) as the primary color
- Pure white (`#FFFFFF`) backgrounds -- use a subtly tinted white
- 8px border radius on everything -- make a deliberate choice
- Gradient + shadow on every card

Good design is:
- Clear visual hierarchy (the eye knows where to go first)
- Generous whitespace
- Typographic rhythm (consistent line height and font size ratios)
- Restrained color (2-3 intentional colors + neutrals)

## Technical Standards (Next.js + Tailwind + shadcn/ui)

**Component hierarchy:**
- Prefer existing shadcn/ui components
- Extend from shadcn primitives when customization is needed
- Keep components under 200 lines -- split if larger

**Responsive design:**
- Mobile first: write base styles for mobile, use `md:` and `lg:` for larger screens
- Test breakpoints: 375px (phone), 768px (tablet), 1280px (desktop)

**Accessibility:**
- All interactive elements need `aria-label` or visible label text
- Color contrast must meet WCAG AA (4.5:1 for normal text)
- Everything must be keyboard-navigable

## Design Process

When given a UI requirement:
1. Ask about the intended style direction (minimal, modern, warm, professional?)
2. Reference similar products or design patterns as anchors
3. Offer 2-3 distinct style directions for the user to choose from
4. Implement the chosen direction using existing components where possible
