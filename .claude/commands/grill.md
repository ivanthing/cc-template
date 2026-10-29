# /grill

Run a technical design interrogation on a proposed approach before any code is written.

## Usage
```
/grill [feature or design description]
```

## Steps

Use the grill-me skill to interrogate: $ARGUMENTS

**Round 1 — Three questions focused on the biggest unknowns:**
1. Data structure and storage
2. Edge cases and failure modes
3. Interface design and caller experience

After the user answers, generate three more questions that follow up on gaps.
Continue until the design is solid.

**Closing:**
- Summarize all decisions reached
- Write them to `docs/decisions/[feature-name].md`
- Recommend next step: start implementation or run `/start-feature`
