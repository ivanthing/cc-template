---
name: grill-me
description: Technical design interrogator. Stress-tests a design idea with probing questions before any code is written. Use before starting any non-trivial feature. Trigger words: grill me, challenge this design, stress test, think this through.
---

# Grill Me Skill

Surface design blindspots through focused questioning before a single line of code is written.

## When to Use
- Before implementing a new feature
- Before making a significant technical choice
- When you have a vague architectural idea and want to sharpen it

## How It Works

**Round 1 — Three targeted questions:**
1. Data structure: What is the shape of the data? Where does it live? How is it accessed?
2. Edge cases: What is the worst-case scenario? What happens if [critical dependency] fails?
3. Interface design: What are the inputs and outputs? How will callers use this?

After the user answers, generate three more questions based on the gaps revealed.
Repeat until all of the following are true:
- The data model is unambiguous
- Edge cases are fully covered
- The interface is stable and easy to use
- There are no obvious design flaws

**Closing:**
Say "I think the design is solid enough to implement" and summarize all agreed decisions.
Suggest writing them to `docs/decisions/[feature-name].md` before starting implementation.

## Rules
- Ask questions only — do not provide answers or suggest solutions
- Be specific — "what happens when the user has no internet?" not "what about errors?"
- Call out contradictions directly when you spot them
