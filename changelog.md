# Changelog

## v1.7.0 — 2026-03-24

**13 enhancements from 6 reference files — from-scratch capability, expanded API rules, shared helpers, stroke coverage.**

### New capabilities

**Protocol 7 expanded: 18 new Critical API Rules (P0)**
- Added: `cornerRadiusVariable`, `aliasOf` batch limitation, `setExplicitVariableModeForCollection` object requirement, `lineHeight` binding unsupported, `setTextStyleIdAsync` ordering + RTL alignment reset + doc specimen caveat, fill `color` alpha stripping, `placePanel` timing, `counterAxisSizingMode` height lock, inner radius binding, glass card children rule, semantic swatch mode pinning, `setEffectStyleIdAsync` await, `EASE_OUT_BACK` spring curves, `sectionSize` COLUMNS exclusion, first-mode ordering bug, Motion Playground top-level rule
- **Paint freshness rule** added inline with code examples — never reuse bound paint objects across nodes
- **Surface-aware token selection table** added — `state/hover` is invisible on transparent surfaces; use `background/subtle` for outlined/ghost components

**Phase 0 Brand Input Parsing (P1)**
- New section between Phase 0b and Task Router for from-scratch builds
- BrandManifest schema with all fields: meta, colors, typography, shape, motion, density
- Supported sources: Notion URLs (`mcp__claude_ai_Notion__notion-fetch`), web URLs (`WebFetch`), PDF/inline text
- Parsing rules: `_provided`, `_inferred`, `_defaulted`, `_missing` tracking — user confirms before Figma writes
- New Task Router row: "create from scratch", "new design system", "build from brand"

**Protocol 1b: Shared Helper Library (P1)**
- Full inline code for all production helpers: `fv()`, `bf()`, `toRgb()`, `bfill()`, `bstroke()`, `bindCornerRadius()`, `bindPadding()`, `bindPaddingH()`, `bindPaddingV()`, `bindGap()`, `bindFontSize()`, `resolveVar()`
- All helpers implement P4 (warn on fallback) — warnings array populated when variable is missing

**Protocol 4: `getColBottom()` helper (P1)**
- Idempotent panel continuation — find the bottom of a canvas column without full reflow
- `PANEL_GAP` constant extracted for consistency

**Phase 0b: Stroke coverage (P1)**
- Health scan now counts `hardcodedStrokes` and `boundStrokes` alongside fills
- Stroke coverage added to return object: `strokeCoverage`, `hardcodedStrokes`, `boundStrokes`
- Score weights rebalanced: fills 35%, strokes 10%, text 25%, instances 30%
- Prevents deprecated tokens bound to borders from escaping detection

**Protocol 12: `getGridValues()` + 2D Grid Auto Layout (P1)**
- `getGridValues()` async helper added inline — resolves Layout collection tokens to numeric px before applying layout guides
- 2D Grid Auto Layout (Config 2025) pattern added: `frame.layoutMode = 'GRID'` for card grids, bento layouts, dashboards
- Decision table: when to use 2D Grid vs 1D Auto Layout

**Quality Gate: 7 Visual Harmony Principles expanded (P2)**
- Replaced single-line harmony check with full 7-principle verification: Purpose, Proportion (Golden Ratio 1:1.618), Hierarchy (modular type scale), Balance (Rule of Thirds), Rhythm (Fibonacci spacing), Unity (max 2 fonts), Tension (1-2 focal points)
- Added: from-scratch BrandManifest confirmation check, stroke coverage check, paint freshness check

**5 new Edge Cases (P2)**
- Motion Playground State A frames must be top-level on page
- Padding values with no matching token (odd numbers, zero)
- 2D Grid `layoutMode = 'GRID'` set before children
- Health scan 100% on empty pages (expected behavior)

### Breaking changes
- Health score weights changed: was fills 40% + text 30% + instances 30%; now fills 35% + strokes 10% + text 25% + instances 30%. Existing maturity tier thresholds unchanged.

---

## v1.6.0 — 2026-03-24

**10 enhancements from MCP + Plugin API research — tools, API coverage, new protocols.**

### New capabilities

**allowed-tools expanded (P0)**
- Added full `mcp__claude_ai_Figma__*` suite: `use_figma`, `generate_figma_design`, `get_design_context`, `get_screenshot`, `get_metadata`, `get_variable_defs`, `get_code_connect_suggestions`, `add_code_connect_map`, `send_code_connect_mappings`
- Added full `mcp__plugin_figma_figma__*` mirror suite
- Added `TaskCreate` and `TaskUpdate` (task tracking during multi-phase work)
- **Why**: previous `allowed-tools` only listed `figma-canvas` and `figma-console` tools; the official `claude.ai Figma` MCP was used in production but blocked by the allow-list

**Phase 0b — broken-binding detection + resolvedVariableModes (P0)**
- Broken bindings now detected inline: `getVariableByIdAsync` validates each bound fill's variable ID; broken ones counted separately as `health.brokenBindings`
- `resolvedVariableModes: figma.currentPage.resolvedVariableModes` added to return — shows which collection→mode is active
- Two new Phase 0b reading questions: broken bindings check + resolvedVariableModes context

**Protocol 7 — effect + layout grid binding rows (P0)**
- `setBoundVariableForEffect(effect, 'color', var)` — bind shadow color to elevation variable
- `setBoundVariableForLayoutGrid` clarified: `gutterSize`/`offset` cannot bind to variables; numbers only
- Elevation token binding pattern (DROP_SHADOW) added inline

**Protocol 14: W3C DTCG Token Export (P1)**
- Exports all Figma variables to `{ "$value": ..., "$type": "..." }` format (stable spec Oct 2025)
- Handles groups (nested JSON), multi-mode (`$extensions.modes`), and alias references (`{token.path}`)
- Full export script inline — paste output to `tokens.json` for Style Dictionary

**Protocol 15: Code Connect Auto-mapping (P1)**
- Step C1: `get_code_connect_suggestions` — candidate pairings from name similarity
- Step C2: `add_code_connect_map` — prop mapping template with variant→code value mapping
- Step C3: `send_code_connect_mappings` — publish to Figma Inspect panel

**Protocol 16: Capture UI → Tokenize (P1)**
- Step T1: `generate_figma_design` captures live URL into Figma as hardcoded fills
- Steps T2–T4: Protocol 9 (M1 survey → M2 map → M3 bind → M4 verify) applied to the captured frame
- Converts external/legacy UIs into token-backed Figma assets in one workflow

**Declared strict superset of `figma-use` (P2)**
- Added note in "When This Skill Activates" — all `figma-use` workflows covered here

**MCP Server Cards edge case added (P2)**
- `.well-known/mcp.json` is read-only metadata — do not attempt to write it

**Quality Gate — 5 new items** for Protocols 14, 15, 16 + elevation bindings + broken bindings

**Task Router — 3 new rows** for Protocols 14, 15, 16

### Breaking changes
- None. All additions are additive.

---

## v1.5.0 — 2026-03-24

**Protocol 13: Design System Documentation — live-bound canvas panels.**

### New capabilities

**Protocol 13: Design System Documentation**
- Builds 6 doc panels in a 3-column layout, measured from actual frame heights (no guessing)
- Every color swatch fill bound via `setBoundVariableForPaint` — panels auto-update when primitives change
- Every text sample bound via `setTextStyleIdAsync` — samples track style edits instantly
- Spacing demos use `setBoundVariable('paddingLeft', spacingVar)` — visual gap scales with token
- Duration demos use `setBoundVariable('itemSpacing', durationVar)` — gap between dots = ms value
- Radius chips use `setBoundVariable('cornerRadius', radiusVar)` — chips reflect live radius value
- Brand Token Light/Dark swatches use `setExplicitVariableModeForCollection(collId, modeId)` on wrapper frames — same variable resolves to correct mode per swatch column

**New Quality Gate item**: documentation panel binding completeness check

**Bug fix**: Phase 0b namespace corrected — `'figma-ds-architect'` → `'figma_ds_architect'` (hyphens not valid in `getSharedPluginData` namespace)

### Breaking changes
- None. All additions are additive.

---

## v1.4.0 — 2026-03-24

**Three-layer versioning system — shared plugin data changelog + _Meta audit variables + AUDIT_TRAIL frame.**

### New capabilities

**Three-layer task completion logging** (`logTaskCompletion(report)` — new shared helper)

- **Layer 1 — Shared plugin data**: `figma.root.setSharedPluginData('figma-ds-architect', 'changelog', ...)` — JSON array of all task runs, survives file moves and duplications, queryable from any future `figma_execute` call. Uses `setSharedPluginData` (not `setPluginData`) so any plugin with the namespace can read it.
- **Layer 2 — `⚙ AUDIT_TRAIL` frame**: Appends a text line per task — `[YYYY-MM-DD HH:MM] Phase name | +N created | N failed` — human-readable on canvas, visible to designers and stakeholders without any tooling.
- **Layer 3 — `_Meta/last-modified`**: Updates the date stamp variable in the `_Meta` collection for fast Phase 0b reads.

**`persistHealthToMeta(health)` helper (Protocol 8 addition)**
- Creates/updates four `_Meta` variables after every health scan: `audit/fill-coverage` (FLOAT), `audit/overall-score` (FLOAT), `audit/maturity-tier` (FLOAT), `audit/last-run` (STRING date)
- Creates the variables if missing — no manual setup required
- Makes health history queryable as Figma variables without re-running the scan

**Phase 0b reads the changelog**
- Reads `getSharedPluginData('figma-ds-architect', 'changelog')` at session start
- Surfaces `changelog.entries` (total count) and `changelog.lastEntry` (timestamp, phase, created count, failed count) in Phase 0b output
- Adds "What does `changelog.lastEntry` show?" to the Phase 0b reading checklist

**Changelog query snippet** added to Shared Helpers — read full history anytime from `figma_execute`

### Call sites added

| Protocol | When logged |
|----------|------------|
| Protocol 8 — Maturity Assessment | After health report output (Step 6) — also calls `persistHealthToMeta` |
| Protocol 9 — Token Migration | After Phase M4 verify |
| Protocol 10 — Deprecation + Sunset | After all Phase D4 deletions complete |
| Protocol 11 — Component Health Repair | After all Phase C3 repairs complete |

### Protocol 1 update

Added "Completion Logging" subsection: instructs agents to call `logTaskCompletion(_report)` as the last step of every task's final write block. Load `figma-ds-modernization.md` to get the implementation.

### Quality Gate update

Added: `logTaskCompletion(_report) called — changelog entry appended, _Meta last-modified updated`

### Architecture

- `logTaskCompletion` lives in `figma-ds-modernization.md` → Shared Helpers (not inline in SKILL.md — keeps SKILL.md under 500 lines)
- Each layer is independently try/caught — failure in one does not block the others
- `setSharedPluginData` chosen over `setPluginData` — readable by any plugin with the namespace string, not just the exact plugin instance that wrote it
- Variables are NOT used for changelog history (wrong tool — typed, visible in Variables panel, no append semantics)
- Variables ARE used for current-state snapshots (`_Meta/audit/*`) — queryable, fast, meaningful to designers

### Breaking changes
- None. All additions are additive. Files without `_Meta` collection skip Layer 3 silently.

---

## v1.3.0 — 2026-03-24

**Grid Propagation + Compositional Layout — Protocol 12.**

### New capabilities

**Protocol 12: Grid Propagation**
- Covers the full 5-level compositional hierarchy: Atom → Molecule → Block/Composition → Section/Organism → Page/Template
- 3-context token scoping rule: component-band (spacing/1–spacing/6, 4–24px), section-band (spacing/6–spacing/16, 24–64px), page-band (spacing/16–spacing/32, 64–128px+)
- Grid propagation rule: every section-level frame gets a 12-column layout guide; every container inner frame binds `maxWidth` to `Layout/container/xl`
- `applyColumnGuide()`, `buildSection()`, `buildPageTemplate()`, `compositionHealthReport()` patterns — all in `research-layout-composition.md`
- Critical constraint documented: `layoutGrids[n].gutterSize` and `offset` accept numbers only — variables cannot bind to these fields; token value must be resolved to px at application time
- 2D Grid Auto Layout (Config 2025): `frame.layoutMode = 'GRID'`, column/row gap bindable to spacing variables via `setBoundVariable`

**New reference file**: `research-layout-composition.md`
- 11 sections covering hierarchy, token scoping, layout guides API, section frame pattern, page template pattern, Auto Layout token binding, composition audit scripts, context decision tree, critical API rules

**New trigger phrases** added to frontmatter: "build a section", "build a page template", "create a page template", "build an organism", "add a hero section", "card grid layout", "page composition", "section layout", "grid propagation", "layout structure"

**New Task Router row**: organism/section/page work → `research-layout-composition.md` → Protocol 12

**New example block** (8th example): Hero section with 12-column grid, container maxWidth token binding, and section-band spacing

**New Quality Gate item**: layout composition checklist — section layout guides, container maxWidth binding, correct spacing band at each hierarchy level

**New Edge Cases** (5 added):
- Layout collection missing when building section/page → build collection first
- `maxWidth` has no effect → frame must use Auto Layout
- `frame.layoutGrids` with variable reference throws → numbers only, resolve token px value
- Section spacing double-stacking after adding child organism
- Page template sections overlapping → gap should be 0, sections carry own padding-y

### Architecture changes

- `research-layout-composition.md` added as 6th reference file
- `run-evals.sh` reference count updated to 6 (pending — see note below)
- SKILL.md line count: ~490 lines (still within 500-line best practice)

### Breaking changes
- None. All additions are backward-compatible.

---

## v1.2.0 — 2026-03-24

**Audit-driven bug fixes — all 10 issues from technical audit resolved.**

### Breaking changes
- None. All fixes are backward-compatible.

### Bug fixes (from audit)

**CRITICAL**
- `figma.createInstance(mainComponent)` → `mainComponent.createInstance()` — wrong API corrected in Protocol 11 Phase C3 (was a runtime crash)
- `JSON.stringify` fill comparison → boolean `modified` flag — reliable and O(n) instead of O(n²) in Protocol 9 Phase M3
- `node.textStyleId !== ''` → `styleId !== figma.mixed && styleId !== ''` — mixed text styles no longer counted as bound (was inflating textCoverage score)
- Protocol 10 Phase D2 now has a complete invocation call — previously only defined the function, never called it

**HIGH**
- `figma.loadAllPagesAsync()` removed from Phase 0b — `figma.root.children` provides page list without loading all page node trees (significant perf improvement on large files)
- `figma.currentPage.findAll()` → `findAll(n => n.visible !== false)` — hidden nodes no longer cause traversal slowdowns on variant-heavy files
- Gradient fills now tracked as a separate `gradientFills` metric with a note — no longer silently excluded from the health report
- Protocol 10 Phase D2 now checks both fills AND strokes — deprecated tokens bound to borders no longer escape detection

**MEDIUM**
- Protocol 9 Phase M3 `bindFillsToVariable` now wrapped with Protocol 1 Phase Wrapper — errors are caught and returned in structured `_report.failed[]` instead of propagating as unhandled rejections
- Protocol 11 Phase C3 reinstantiate option now captures and restores `{x, y, parent}` — components no longer teleport to `{0, 0}` after reinstantiation

### Architecture changes

**Protocols 8–11 extracted into `figma-ds-modernization.md`** — SKILL.md drops from ~666 lines to ~390 lines, complying with the Anthropic 500-line best practice. Progressive disclosure: the reference file is only loaded when needed.

**Phase M2 color tolerance now implemented as real HSL code** — `colorsMatch(hex1, hex2)` function defined in `figma-ds-modernization.md` with explicit thresholds: |ΔL| ≤ 5, |ΔS| ≤ 10, |ΔH| ≤ 15 (HSL color space).

**`_successor` annotation format defined** — deprecated tokens must use `_successor: <full-variable-name>` in their Figma description field. Protocol 10 Phase D1 now parses and surfaces this.

**`allowed-tools` corrected** — added `figma_get_component` and `figma_search_components` (required by Protocol 11 Phase C3 reinstantiation path). Previously the agent would have been blocked calling these.

**`run-evals.sh` updated** — now checks for 5 reference files (added `figma-ds-modernization.md`).

### New files
- `~/.claude/skills/figma-ds-modernization.md` — Protocols 8–11 with all bug fixes, shared helpers, integration notes, correct execution order guide

---

## v1.1.0 — 2026-03-24

**Existing Design System Support — Audit, Evaluate, Modernize.**

**New trigger phrases**: "audit my design system", "design system health check",
  "migrate hardcoded values", "fix detached instances", "token coverage report",
  "modernize our components", "our design system is outdated", "remove deprecated tokens"
**New tool**: `WebSearch` added to allowed-tools (for unknown token naming conventions)
**New examples**: DS audit + Strangler Fig token migration (total 7 examples)
**Version model tested with**: claude-sonnet-4-6

### New Capabilities

**Protocol 8: Design System Maturity Assessment**
- Phase 0b now computes health metrics inline: fill coverage %, text coverage %,
  instance health %, unique hardcoded colors, detached instance count
- 4-tier maturity model: Fragmented / Building / Adopting / Mature
- 6-R modernization framework: Retain, Retire, Rehost, Replatform, Refactor, Replace
- Produces a prioritized health report + roadmap. Never modifies until user confirms.

**Protocol 9: Token Migration (Strangler Fig)**
- Phase M1: Survey — lists all unique hardcoded hex values sorted by frequency
- Phase M2: Map — matches each hex to closest existing variable (within ±5 lightness
  tolerance) or proposes creating a new primitive
- Phase M3: Bind — uses `setBoundVariableForPaint()` in-place, never deletes nodes
- Phase M4: Verify — re-runs health scan, reports before/after coverage improvement

**Protocol 10: Deprecation + Sunset**
- Detects tokens with `_deprecated/`, `/deprecated/`, `_old/`, `_legacy/` prefixes
- Finds all nodes still bound to deprecated tokens before deletion
- Remaps to successor tokens if defined; only deletes after confirming zero bindings

**Protocol 11: Component Health Repair**
- Inventories all detached instances with their canvas position
- Audits rogue overrides (hardcoded fills inside component instances)
- Presents 4-option repair menu to user before acting: reset, rebind, reinstantiate, document

**Enhanced Phase 0b**
- Extended from basic inventory to full health scan in a single `figma_execute` call
- Outputs `health` object alongside existing `pages`, `collectionNames`, `componentSets`

**New Task Router entries**: 4 new rows (DS audit, token migration, deprecation, component repair)

**New Edge Cases**: 7 new cases (unknown naming convention, stale aliases, broken bindings,
  large files, migration producing zero bound nodes, deprecated variable with active bindings,
  detached instance with no library match)

**New Eval Cases**:
- `audit-existing.md` — Tier 1 file, health report produced without modifications
- `migrate-hardcoded.md` — Strangler Fig migration, survey-confirm-bind-verify cycle

### Known Limitations
- Health scan scoped to `figma.currentPage` only (large multi-page files may need per-page runs)
- Token migration Phase M2 color matching uses lightness tolerance heuristic — may need
  manual review for near-duplicate palette values
- Protocol 10 deprecation detection requires naming conventions (`_deprecated/` prefix);
  unnamed orphaned tokens not yet auto-detected

---

## v1.0.0 — 2026-03-24

**Initial release.**

**Trigger phrases**: "create design tokens", "build a component", "set up a design system",
  "add variables to Figma", "build token foundation", "create components in Figma",
  "design this in Figma", "update the Figma file", "build a molecule", "apply visual harmony",
  "make this responsive in Figma", "execute Figma code"
**Invocation**: User-only (`disable-model-invocation: true`) — all operations write to Figma canvas
**Tools**: Read + full mcp__figma-canvas__* and mcp__figma-console__* suite
**Model tested with**: claude-sonnet-4-6

### Capabilities
- Full session bootstrap (Phase 0a MCP health + Phase 0b file state audit)
- Task router: maps intent to 4 reference skill files
- Universal mandatory protocols: Standard Phase Wrapper, Idempotency First,
  Structured Returns, Canvas Reflow, Orphan Cleanup, Visual Validation Loop
- Complete Critical API Rules table (21 gotchas, all from production failures)
- Quality gate checklist (12 items covering tokens, molecules, responsive, harmony)

### Reference files consumed
- `~/.claude/skills/figma-token-foundation.md` (v2.6.0) — how-to for tokens
- `~/.claude/skills/research-figma-molecule-architecture.md` (v1.9.0) — molecule standards
- `~/.claude/skills/research-responsive-adaptive-design.md` (v1.0.0) — responsive patterns
- `~/.claude/skills/research-visual-harmony-composition.md` (v1.1.0) — visual harmony

### Known Limitations
- Eval automation requires claude --context-isolated (not yet standard)
- Does not auto-detect which reference file version is installed
- reflow column list (`_colA`, `_colB`, `_colC`) must match the token foundation panel
  names — update if token foundation panels are renamed
