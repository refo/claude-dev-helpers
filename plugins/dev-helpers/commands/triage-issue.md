# Triage Issue

Systematically investigate a bug, design a fix, and create a GitHub issue with TDD approach.

## Workflow

### 1. Problem Capture

Ask the user: "What's the problem you're seeing?" Capture their description with minimal follow-up questions. Go with their initial report — interview comes next.

### 2. Exploration & Diagnosis

Use the Agent tool to deeply investigate the codebase:
- Where does the bug manifest? (which file, component, API endpoint)
- What is the involved code path?
- What is the root cause?
- Are there related patterns elsewhere?

Examine source files, tests, git history, error handling, and similar working code.

### 3. Fix Approach

Determine:
- The minimal change needed
- Which modules are affected
- What behaviors need verification
- Is this a regression? Missing feature? Design flaw?

### 4. TDD Fix Design

Create ordered RED-GREEN cycles. Each cycle is one vertical slice:
- RED: Write a test for one observable behavior
- GREEN: Minimal code to pass
- Repeat until the issue is fixed

Rules:
- Tests verify behavior through public interfaces, not implementation details
- One test at a time
- Each test should survive internal refactors

### 5. GitHub Issue Creation

Generate the issue automatically using `gh issue create` without requesting user review first.

Use this template:

```
# <Issue Title>

## Problem

<Description of the bug from the user's perspective>

## Root Cause

<What's happening in the code>

## Solution

A TDD fix with ordered RED-GREEN cycles.

### Cycle 1: <Title>

**Test**: <Description of what the test verifies>

**Implementation**: <Minimal code needed to pass>

### Cycle 2: <Title>

... (repeat for each cycle)

## Verification

- [ ] All tests pass
- [ ] Behavior is fixed
```
