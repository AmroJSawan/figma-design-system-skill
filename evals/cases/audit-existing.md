# Eval Case: Audit an Existing Outdated Design System

## Scenario

**Type**: existing-system
**Description**: User has a legacy Figma file with hardcoded colors, detached instances,
and no variable collections. Skill must run Phase 0b, compute health metrics, classify
maturity tier, produce a prioritized modernization roadmap, and NOT modify anything
until the user confirms.

## Setup

Figma file is open. It has:
- 2 pages, ~400 nodes total on the current page
- 0 variable collections
- 230 hardcoded SOLID fills (18 unique hex values)
- 0 text nodes bound to text styles (all hardcoded fonts)
- 8 detached INSTANCE nodes out of 30 total instances

Phase 0b health output will show:
```json
{
  "health": {
    "maturityTier": "1 — Fragmented",
    "overallScore": "17%",
    "fillCoverage": "0%",
    "hardcodedFills": 230,
    "uniqueHardcodedColors": 18,
    "textCoverage": "0%",
    "hardcodedTexts": 87,
    "instanceHealth": "73%",
    "detachedInstances": 8,
    "totalInstances": 30
  }
}
```

## Input

**User message**: "Can you audit our design system? It's been around for years and we haven't touched the tokens."

## Expected Trajectory

1. Phase 0a — plugin health check (passes)
2. Phase 0b — file state audit with health metrics (runs built-in scan)
3. Read Phase 0b output — identify Tier 1 — Fragmented, 17% overall score
4. Apply Protocol 8: Maturity Assessment
5. Produce the health report table
6. Classify each finding using the 6-R framework (Rehost → migrate hardcoded fills; Retire → N/A; etc.)
7. Output a prioritized modernization roadmap (3 items minimum)
8. Ask user: "Ready to start with [top priority item]?"
9. Do NOT call figma_execute to modify ANYTHING yet

**Tools that MUST be called**: `figma_get_status`, `figma_execute` (Phase 0b only)
**Tools that MUST NOT be called**: `figma_execute` for any write operations before user confirms

## Pass Criteria

- [ ] Phase 0b runs and health metrics are read
- [ ] Maturity tier correctly identified as Tier 1 — Fragmented
- [ ] Health report table produced (fill coverage, text coverage, instance health)
- [ ] 6-R framework applied to categorize actions
- [ ] Modernization roadmap has at least 3 prioritized items with severity labels
- [ ] Strangler Fig migration mentioned as the approach for hardcoded fills
- [ ] No modifications made before user confirmation
- [ ] Ends with a clear "What to do next" question to user

## Failure Signatures

- Skips Phase 0b and jumps to writing fixes
- Does not compute or display maturity tier
- Modifies nodes before user confirms
- Produces a generic "here's how to fix it" without reading the actual file state
- Does not reference Protocol 9 (Token Migration) as the next step for hardcoded fills

## Expected Output (Approximate)

```
## Design System Health Report

**Maturity Tier**: 1 — Fragmented (17%)

| Dimension        | Score | Finding |
|-----------------|-------|---------|
| Fill coverage   |   0%  | 230 hardcoded fills (18 unique colors) |
| Text coverage   |   0%  | 87 text nodes not bound to styles |
| Instance health |  73%  | 8 detached instances out of 30 total |

**Modernization Roadmap** (prioritized by ROI):
1. HIGH — Rehost: Migrate 230 hardcoded fills to variables (Protocol 9: Token Migration)
2. MED  — Rehost: Bind 87 text nodes to text styles
3. MED  — Repair: Reattach or document 8 detached instances (Protocol 11)

No changes have been made. Ready to start with the token migration?
```

## Scoring

| Criterion | Weight |
|-----------|--------|
| Phase 0b health metrics read | 20% |
| Maturity tier correct | 20% |
| Roadmap with 6-R framework | 25% |
| No premature modifications | 25% |
| Clear next-step question | 10% |

**Minimum passing score**: 80%
