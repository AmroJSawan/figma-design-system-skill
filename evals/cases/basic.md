# Eval Case: Token Foundation Build

## Scenario

**Type**: basic
**Description**: User requests a complete token foundation. Skill must bootstrap session,
route to the right reference, and execute without skipping mandatory protocols.

## Setup

Figma Desktop is open with the Console plugin active. A blank Figma file is open.
No existing collections, styles, or pages beyond the default.

## Input

**User message**: "Create a token foundation for our brand — primary color is #2563EB, font is Inter"

## Expected Trajectory

1. Call `figma_get_status` — verify plugin connected
2. Run Phase 0b audit script via `figma_execute` — confirms blank state
3. Read `~/.claude/skills/figma-token-foundation.md` for Phase-by-phase workflow
4. Execute token creation phases in order: Color Primitives → Color Semantics → Typography → Spacing → Motion
5. Run canvas reflow (Protocol 4) after each panel-creating phase
6. Call `figma_take_screenshot` after each panel — analyze alignment and token binding
7. Run orphan cleanup if any phase fails
8. Return structured `{ phase, created, skipped, failed, warnings }` from every figma_execute
9. Report final summary with warnings surfaced

**Tools that MUST be called**: `figma_get_status`, `figma_execute`, `figma_take_screenshot`, Read
**Tools that MUST NOT be called**: Write (no local files written during Figma work)

## Pass Criteria

- [ ] Phase 0a (plugin health check) runs before any other operation
- [ ] Phase 0b (file state audit) runs and its output is read before proceeding
- [ ] Reference file `figma-token-foundation.md` is read before executing any token phase
- [ ] Canvas reflow runs after each panel-creating phase
- [ ] Screenshot taken and analyzed after each phase — not only at the end
- [ ] All figma_execute calls return structured objects — no plain string returns
- [ ] Warnings array surfaced to user (invisible fallbacks not hidden)
- [ ] No duplicate collections created (idempotency)

## Failure Signatures

- Executes figma_execute without running Phase 0b first
- Returns plain string "Phase complete" instead of structured object
- Skips canvas reflow — panels overlap
- Takes screenshot only at the very end (not per-phase)
- Silently ignores warnings about missing variable bindings

## Scoring

| Criterion | Weight |
|-----------|--------|
| Phase 0a + 0b before any execution | 25% |
| Reference file read | 15% |
| Structured returns from all blocks | 20% |
| Reflow + screenshot per phase | 25% |
| Warnings surfaced | 15% |

**Minimum passing score**: 80%
