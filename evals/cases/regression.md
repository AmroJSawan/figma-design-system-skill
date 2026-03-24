# Eval Case: Regression — Component Set Reuse, Not Recreate

## Scenario

**Type**: regression
**Description**: Previously, design-architect skills recreated component sets that already
existed, producing duplicates and breaking the Systems Thinker Law 1 (Reuse over Create).
This case locks that behavior shut.

## Setup

Figma file has an existing `Button` component set on the `📦 Components` page with:
- 4 variants: Default, Hover, Pressed, Disabled
- Token bindings already applied
- Phase 0b audit will show `Button` in the `componentSets` array

## Input

**User message**: "Build a Button component with all interactive states"

## Expected Trajectory

1. Phase 0a — plugin health check (passes)
2. Phase 0b — file state audit, reads that `Button` component set already exists
3. Read `research-figma-molecule-architecture.md` — Systems Thinker Law 1: "Reuse over Create"
4. Tell user: "A Button component set already exists. Showing you what's there."
5. Take a screenshot of the existing Button component set
6. Ask user: "Do you want to extend it (add states) or audit its token bindings?"
7. Do NOT run figma_execute to create a new Button component set

**Tools that MUST be called**: `figma_get_status`, `figma_execute` (Phase 0b only), `figma_take_screenshot`
**Tools that MUST NOT be called**: `figma_execute` to CREATE a new Button set (before user confirms)

## Pass Criteria

- [ ] Phase 0b detects existing `Button` component set
- [ ] Reads molecule architecture reference (Systems Thinker Law 1)
- [ ] Does NOT create a duplicate Button component set
- [ ] Screenshots the existing component set
- [ ] Asks user whether to extend or audit — does not assume
- [ ] If user says "extend": adds only the missing variants, not a full rebuild

## Failure Signatures

- Creates a second `Button` component set alongside the existing one
- Ignores Phase 0b output and proceeds with full recreation
- Does not read the molecule architecture reference
- Deletes existing work before asking the user

## Expected Output (Approximate)

```
A Button component set already exists on the 📦 Components page (4 variants: Default, Hover, Pressed, Disabled).

[screenshot of existing Button]

Would you like to:
1. Extend it — add missing states (e.g., Loading, Focus)
2. Audit its token bindings — verify all fills use live variables
3. Rebuild it from scratch (this will replace the existing set)
```

## Scoring

| Criterion | Weight |
|-----------|--------|
| Phase 0b detects existing component | 25% |
| No duplicate creation | 35% |
| Screenshots existing work | 20% |
| Asks user intent before acting | 20% |

**Minimum passing score**: 80%
