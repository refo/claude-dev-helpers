---
name: prd-to-issues
description: Break a PRD into independently-grabbable GitHub issues using tracer-bullet vertical slices. Use when user wants to convert a PRD to issues, create implementation tickets, or break down a PRD into work items.
---

# PRD to Issues

Break a PRD into independently-grabbable GitHub issues using vertical slices (tracer bullets).

## Process

**1. Locate the PRD**

Ask the user for the PRD GitHub issue number (or URL). If the PRD is not already in your context window, fetch it with `gh issue view <number>` (with comments).

**2. Explore the codebase (optional)**

If you have not already explored the codebase, do so to understand the current state of the code.

**3. Draft vertical slices**

Break the PRD into tracer bullet issues. Each issue is "a thin vertical slice that cuts through ALL integration layers end-to-end, NOT a horizontal slice of one layer."

Slices may be 'HITL' (human-in-the-loop) or 'AFK' (away-from-keyboard). HITL slices require human interaction, such as architectural decisions or design reviews. AFK slices can be implemented and merged without human interaction. Prefer AFK over HITL where possible.

**Vertical slice rules:**
- "Each slice delivers a narrow but COMPLETE path through every layer"
- A completed slice is demoable or verifiable independently
- Prefer many thin slices over few thick ones

**4. Quiz the user**

Present the proposed breakdown as a numbered list showing title, type, blockers, and user stories covered. Ask whether granularity is appropriate, dependencies are correct, and slice categorization is accurate.

**5. Create the GitHub issues**

For each approved slice, create issues using `gh issue create` in dependency order, using the provided template that includes parent PRD reference, description, acceptance criteria, blockers, and user stories addressed.

Do NOT close or modify the parent PRD issue.
