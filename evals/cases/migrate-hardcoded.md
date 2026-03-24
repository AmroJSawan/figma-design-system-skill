# Eval Case: Token Migration — Strangler Fig Pattern

## Scenario

**Type**: existing-system
**Description**: User wants to migrate 230 hardcoded fills to live variable bindings.
Skill must use Protocol 9 (Strangler Fig): survey → map → confirm → bind → verify.
Must NOT bind blindly — must show mapping to user first. Must NOT delete nodes.

## Setup

Figma file has:
- 230 hardcoded SOLID fills (18 unique hex values)
- 1 variable collection: `Primitives` with 12 existing color variables
- Top 3 hardcoded colors by frequency:
  - `#1A6EFF` — 89 uses (matches existing `color/primitive/blue-500`)
  - `#F5F5F5` — 62 uses (no match in library)
  - `#1A1A1A` — 41 uses (matches existing `color/primitive/neutral-900`)

## Input

**User message**: "Okay let's start — migrate the hardcoded colors to variables."

## Expected Trajectory

1. Phase 0a — plugin health check (passes, assumed from prior audit)
2. Phase 0b — confirm collection state (Primitives collection present)
3. Protocol 9 Phase M1 — run survey script, confirm top 18 colors by frequency
4. Protocol 9 Phase M2 — map each hex to closest existing variable OR propose new primitive
   - `#1A6EFF` → `color/primitive/blue-500` (existing, use it)
   - `#F5F5F5` → no match → propose creating `color/primitive/neutral-50`
   - `#1A1A1A` → `color/primitive/neutral-900` (existing, use it)
5. Present mapping table to user. Ask for confirmation before binding.
6. User confirms → Phase M3: bind fills hex by hex, starting with highest-frequency
7. Phase M4: re-run health scan, confirm fill coverage improved
8. Take screenshot, compare before/after coverage numbers

**Tools that MUST be called**: `figma_get_status`, `figma_execute` (survey + bind + re-scan), `figma_take_screenshot`
**Tools that MUST NOT be called**: Any delete operations on nodes

## Pass Criteria

- [ ] Phase M1 survey runs and lists all 18 unique colors with frequencies
- [ ] Phase M2 mapping table shown to user before any writes
- [ ] Unmatched colors (`#F5F5F5`) handled: new primitive proposed, not silently skipped
- [ ] Phase M3 binds fills using `figma.variables.setBoundVariableForPaint()`
- [ ] Processing order: highest frequency first (Strangler Fig)
- [ ] Phase M4 re-runs health scan and reports fill coverage improvement
- [ ] Screenshot taken after migration
- [ ] No nodes deleted or recreated — only fills rebound

## Failure Signatures

- Binds fills without showing mapping to user first
- Silently skips unmatched colors instead of proposing new primitives
- Processes colors in arbitrary order instead of frequency-descending
- Does not re-run health scan to verify improvement
- Uses hardcoded variable IDs from a previous session (stale IDs)
- Deletes or recreates any nodes

## Expected Output (Approximate)

```
Phase M1 — Survey complete: 18 unique hardcoded colors, 230 total fills

Top colors:
| Hex     | Count | Closest Variable              | Action |
|---------|-------|-------------------------------|--------|
| #1A6EFF |    89 | color/primitive/blue-500      | Rehost |
| #F5F5F5 |    62 | (none — within ±5 tolerance)  | Create color/primitive/neutral-50 |
| #1A1A1A |    41 | color/primitive/neutral-900   | Rehost |
...

Shall I proceed with this mapping? (I'll create the 3 new primitives first, then bind.)

[After confirmation]

Phase M3 — Migration complete:
- Bound 89 fills → color/primitive/blue-500
- Bound 62 fills → color/primitive/neutral-50 (new)
- Bound 41 fills → color/primitive/neutral-900
...

Phase M4 — Health re-scan:
Fill coverage: 0% → 74% (170 of 230 fills now bound)
Remaining: 60 fills across 15 less-frequent colors — continue?
```

## Scoring

| Criterion | Weight |
|-----------|--------|
| Survey runs and lists colors correctly | 20% |
| Mapping shown before binding | 25% |
| Unmatched colors handled (new primitive proposed) | 20% |
| Health scan re-run after migration | 20% |
| No node deletions | 15% |

**Minimum passing score**: 80%
