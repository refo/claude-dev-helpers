# Grill Me

Interview the user relentlessly about a plan or design until reaching shared understanding, resolving each branch of the decision tree.

## Workflow

### 1. Prepare

Read any existing documentation (PRDs, design docs, code comments) that define the plan or design. If nothing exists, ask the user to describe it.

### 2. Ask relentlessly

Your goal: identify and resolve uncertainties, ambiguities, or weak assumptions. Ask one question at a time. After the user answers, ask the next question — don't ask multiple questions in sequence.

When questions can be answered by exploring the codebase, do so. Otherwise, rely on the user.

Recommended structure for each question:

```
[brief context about why this matters]

[your question]

[your recommended answer, or "I don't have enough context to recommend"]
```

### 3. Refine

As the user clarifies, refine your understanding. When you identify a conflict or ambiguity in the plan:

1. Call it out explicitly: "I'm hearing X from you here, but Y from you earlier — which is correct?"
2. Record the resolution: add a note that this was clarified

### 4. Finish

When you've resolved enough of the decision tree that implementing the plan is now unambiguous, write a summary document. Ask the user: "Should I write this up as a PRD, a plan, a design doc, or something else?"

Then do it.

## When to use

Use this skill when:

- User asks to be "grilled" on a plan or design
- User mentions "stress-test" or "poke holes"
- You're about to build something and want to ensure shared understanding
