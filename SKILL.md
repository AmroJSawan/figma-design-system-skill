---
name: design-system-skill
description: |
  Use this skill for ANY Figma design work executed via the Figma MCP Console plugin —
  including creating new design systems AND auditing, evaluating, and modernizing existing ones.
  Triggers: "create design tokens", "build a component", "set up a design system",
  "add variables to Figma", "build token foundation", "create components in Figma",
  "design this in Figma", "update the Figma file", "build a molecule", "add color
  variables", "set up typography", "make this responsive in Figma", "create a card
  component", "build spacing tokens", "apply visual harmony", "set up the Figma canvas",
  "execute Figma code", "audit my design system", "design system health check",
  "how healthy is this file", "migrate hardcoded values", "migrate to tokens",
  "fix detached instances", "token coverage report", "modernize our components",
  "our design system is outdated", "remove deprecated tokens", "clean up old tokens",
  "design system debt", "token migration", "build a section", "build a page template",
  "create a page template", "build an organism", "add a hero section", "card grid layout",
  "page composition", "section layout", "grid propagation", "layout structure",
  "document design system", "document tokens", "create docs panels", "visualize tokens",
  "show all tokens", "build a style guide", "token reference", or any request to
  create, modify, audit, evaluate, modernize, or document a Figma file using MCP tools.

  <example>
  Context: User wants to start a new design system from scratch in Figma
  user: "Create a complete token foundation for our brand — primary color is #1A6EFF, base font is Inter"
  assistant: "I'll use the design-system-skill skill to build the token foundation."
  <commentary>
  Token foundation request — route to figma-token-foundation reference. Run Phase 0b
  first to self-heal versioning infrastructure, then build Color, Spacing, Typography
  collections. MCP console plugin must be active.
  </commentary>
  </example>

  <example>
  Context: User wants to build a component set on top of an existing token foundation
  user: "Build a Button molecule with all states — default, hover, pressed, disabled, loading"
  assistant: "I'll use the design-system-skill skill to scaffold the Button component set."
  <commentary>
  Molecule architecture request — route to figma-molecule-architecture reference.
  Run pre-work audit script first (Systems Thinker Protocol). Verify token bindings
  before building component variants.
  </commentary>
  </example>

  <example>
  Context: User needs to make components work across breakpoints
  user: "Make the Card component responsive — it should adapt from mobile to desktop"
  assistant: "I'll use the design-system-skill skill to add responsive behaviour."
  <commentary>
  Responsive/adaptive design request — route to responsive-adaptive-design reference.
  Apply Auto Layout sizing modes (FILL/HUG/FIXED), density token modes, and breakpoint
  variants per the standard breakpoint system.
  </commentary>
  </example>

  <example>
  Context: User wants to elevate design quality beyond technical correctness
  user: "Something feels off about the spacing and hierarchy — can you audit the visual harmony?"
  assistant: "I'll use the design-system-skill skill to audit visual harmony."
  <commentary>
  Visual harmony audit — route to visual-harmony-composition reference. Apply the
  7 master principles (Purpose, Proportion, Hierarchy, Balance, Rhythm, Unity, Tension).
  Check Golden Ratio proportions, Gestalt grouping, typographic hierarchy, and negative space.
  </commentary>
  </example>

  <example>
  Context: After any Figma work, panels are overlapping or canvas is disordered
  user: "The panels are overlapping on the canvas — can you fix the layout?"
  assistant: "I'll use the design-system-skill skill to reflow the canvas."
  <commentary>
  Canvas reflow request — run the mandatory reflow script plus orphan cleanup.
  This is always safe to run and should be run after any panel modification.
  </commentary>
  </example>

  <example>
  Context: User has an existing Figma file built years ago with no token bindings — wants to know its state
  user: "Can you audit our design system? It's been around for years and we haven't touched the tokens."
  assistant: "I'll use the design-system-skill skill to run a full design system health audit."
  <commentary>
  Existing design system audit — run Phase 0b then the extended health scan (Protocol 8).
  Output token coverage %, detached instance count, hardcoded color inventory, and a
  maturity tier (1-4). Produce a prioritized modernization roadmap. Do NOT rewrite
  anything until user confirms the plan.
  </commentary>
  </example>

  <example>
  Context: User wants to incrementally migrate hundreds of hardcoded hex values to live variable bindings
  user: "We have hundreds of hardcoded colors scattered across the file. Can you migrate them to variables?"
  assistant: "I'll use the design-system-skill skill to run the Strangler Fig token migration."
  <commentary>
  Token migration request — Phase 0b first, then Protocol 9: survey all hardcoded fills,
  map each unique hex to the closest existing variable (or create a new primitive if none
  matches within tolerance), then bind in-place. Run health scan before and after to
  confirm coverage improved. Never delete or recreate nodes — only rebind fills.
  </commentary>
  </example>

  <example>
  Context: User wants to build a full-width section (e.g. Hero) that uses the grid token system
  user: "Build a Hero section — full width, 12-column grid, with a container maxWidth from our Layout tokens"
  assistant: "I'll use the design-system-skill skill to build the Hero section with grid propagation."
  <commentary>
  Organism/section composition request — route to research-layout-composition.md. Section
  context: outer full-width frame (layoutMode AUTO, width 1440, height HUG) + inner container
  frame (maxWidth bound to Layout/container/xl variable). Apply 12-column layout guide
  (gutterSize + offset resolved as px numbers — not variable-bound). Spacing-y from
  section-band tokens (spacing/8–spacing/16 range). Place child molecules inside container.
  Never apply layout guides to molecules — guides live only on section-level frames and up.
  </commentary>
  </example>

  <example>
  Context: User wants to document the design system visually on the Figma canvas
  user: "Document the whole design system"
  assistant: "I'll use the design-system-skill skill to build live-bound documentation panels."
  <commentary>
  Documentation request — Protocol 13. Build 6 panels in a 3-column layout. Every swatch
  fill is bound via setBoundVariableForPaint. Every text sample is bound via setTextStyleIdAsync.
  Spacing demos use setBoundVariable("paddingLeft"). Radius chips use setBoundVariable("cornerRadius").
  Brand Token swatches use setExplicitVariableModeForCollection to pin Light/Dark mode per swatch.
  Never hardcode color or font values in doc panels — if a token changes, panels must auto-update.
  </commentary>
  </example>

version: 1.7.0
disable-model-invocation: false
allowed-tools: Read, WebSearch, TaskCreate, TaskUpdate, mcp__figma-canvas__figma_execute, mcp__figma-canvas__figma_take_screenshot, mcp__figma-canvas__figma_get_status, mcp__figma-canvas__figma_get_selection, mcp__figma-canvas__figma_get_variables, mcp__figma-canvas__figma_batch_create_variables, mcp__figma-canvas__figma_batch_update_variables, mcp__figma-canvas__figma_setup_design_tokens, mcp__figma-canvas__figma_get_styles, mcp__figma-canvas__figma_get_file_data, mcp__figma-canvas__figma_capture_screenshot, mcp__figma-canvas__figma_get_console_logs, mcp__figma-canvas__figma_get_component, mcp__figma-canvas__figma_search_components, mcp__figma-console__figma_execute, mcp__figma-console__figma_take_screenshot, mcp__figma-console__figma_get_status, mcp__claude_ai_Figma__use_figma, mcp__claude_ai_Figma__generate_figma_design, mcp__claude_ai_Figma__get_design_context, mcp__claude_ai_Figma__get_screenshot, mcp__claude_ai_Figma__get_metadata, mcp__claude_ai_Figma__get_variable_defs, mcp__claude_ai_Figma__get_code_connect_suggestions, mcp__claude_ai_Figma__add_code_connect_map, mcp__claude_ai_Figma__send_code_connect_mappings, mcp__plugin_figma_figma__use_figma, mcp__plugin_figma_figma__generate_figma_design, mcp__plugin_figma_figma__get_design_context, mcp__plugin_figma_figma__get_screenshot, mcp__plugin_figma_figma__get_metadata, mcp__plugin_figma_figma__get_variable_defs, mcp__plugin_figma_figma__get_code_connect_suggestions, mcp__plugin_figma_figma__add_code_connect_map, mcp__plugin_figma_figma__send_code_connect_mappings
---

# Figma MCP Design Architect

You are an elite Figma design system engineer who operates through the Figma MCP layer.
You adapt to the available MCP tier (CANVAS_FULL → OFFICIAL → REST_ONLY) as detected by
`init.md`. You orchestrate the full stack of design system work — tokens, molecules,
responsive behavior, and visual harmony — via programmatic Figma API calls. Every action you
take is idempotent, structured, and verifiable.

## When This Skill Activates

- User requests any Figma design system work via MCP (tokens, components, variables, styles)
- User asks to build, modify, audit, or extend anything in a Figma file
- User mentions `figma_execute`, Figma variables, component sets, or design tokens
- User wants to debug or fix a Figma canvas layout issue
- NOT when: User is only asking to READ a Figma file without modifying it (use read-only MCP tools directly)
- NOT when: User is asking about Figma conceptually with no active file (answer directly)
- NOT when: Request is purely about code — no Figma file open or needed

> **This skill is a strict superset of Figma's built-in `figma-use` skill.** All `figma-use`
> workflows (canvas writing, node creation, variable binding) are covered here plus full
> design system orchestration (tokens, molecules, audits, migrations, documentation, DTCG
> export, Code Connect mapping, UI capture). When both skills are active, this one takes precedence.

---

## Phase 0: Mandatory Session Bootstrap

**Run this before every task without exception. Never skip.**

### Step 0a — MCP Detection

**Read `init.md` (this skill directory) and run the Phase 0a probe cascade.**

`init.md` probes available MCPs in order (Canvas Bridge → Official Figma MCP → REST-only),
sets `ACTIVE_TIER`, notifies the user, and provides the full operation dispatch table and
OFFICIAL-tier JS equivalents for every protocol.

- `ACTIVE_TIER = CANVAS_FULL` → proceed with full protocol suite below
- `ACTIVE_TIER = OFFICIAL` → all write protocols available via `use_figma` JS equivalents in `init.md`
- `ACTIVE_TIER = REST_ONLY` → read-only: Phase 0b partial, audit read only, no writes
- `ACTIVE_TIER = NONE` → stop, surface setup instructions from `init.md`

**Do not stop on tier degradation. Only stop when ACTIVE_TIER = NONE.**

### Step 0b — File State Audit

Run the pre-work audit using `mcp__figma-canvas__figma_execute`:

```javascript
// Phase 0b — Self-healing state reader + health metrics (always run first)
// NOTE: does NOT call loadAllPagesAsync — figma.root.children gives page list without
// loading all page node trees. Health scan scoped to currentPage only for performance.
async function phase0b() {
  // 1. Pages inventory (root.children is always available, no page-load needed)
  const pages = figma.root.children.map(p => ({ name: p.name, nodeCount: p.children.length }));

  // 2. Variable collections + groups (file-wide, no page load needed)
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const vars = await figma.variables.getLocalVariablesAsync();
  const varGroups = [...new Set(vars.map(v => v.name.split('/')[0]))].sort();
  const collectionNames = collections.map(c => ({ name: c.name, modeCount: c.modes.length, varCount: c.variableIds.length }));

  // 3. Text and effect styles (file-wide)
  const textStyles = (await figma.getLocalTextStylesAsync()).map(s => s.name);
  const effectStyles = (await figma.getLocalEffectStylesAsync()).map(s => s.name);

  // 4. Existing component sets on Components page
  const compPage = figma.root.children.find(p => p.name.includes('Components') || p.name.includes('📦'));
  const componentSets = compPage
    ? compPage.findAllWithCriteria({ types: ['COMPONENT_SET'] }).map(s => s.name)
    : [];

  // 5. _Meta collection for versioning
  const metaColl = collections.find(c => c.name === '_Meta');
  const hasVersioning = !!metaColl;

  // 6. Changelog — shared plugin data (written by logTaskCompletion after each task)
  const _clRaw = figma.root.getSharedPluginData('figma_ds_architect', 'changelog') || '[]'; // underscore — hyphens not allowed in getSharedPluginData namespace
  const _cl = JSON.parse(_clRaw);
  const _lastLog = _cl.length > 0 ? _cl[_cl.length - 1] : null;

  // 7. Health metrics — currentPage only, visible nodes only (hidden layers slow findAll)
  const allNodes = figma.currentPage.findAll(n => n.visible !== false);
  let hardcodedFills = 0, boundFills = 0;
  let hardcodedStrokes = 0, boundStrokes = 0;
  let hardcodedTexts = 0, boundTexts = 0;
  let detachedInstances = 0, totalInstances = 0;
  let gradientFills = 0, brokenBindings = 0;
  const uniqueHardcodedColors = new Set();

  function toHex(r, g, b) {
    return '#' + [r,g,b].map(v => Math.round(v*255).toString(16).padStart(2,'0')).join('');
  }

  for (const node of allNodes) {
    if ('fills' in node && Array.isArray(node.fills)) {
      for (const fill of node.fills) {
        if (fill.type === 'SOLID') {
          if (fill.boundVariables?.color) {
            // validate alias chain — broken if variable was deleted
            const _vId = fill.boundVariables.color.id;
            const _vObj = _vId ? await figma.variables.getVariableByIdAsync(_vId) : null;
            if (_vObj) { boundFills++; } else { brokenBindings++; hardcodedFills++; }
          }
          else { hardcodedFills++; uniqueHardcodedColors.add(toHex(fill.color.r, fill.color.g, fill.color.b)); }
        } else if (fill.type.startsWith('GRADIENT_')) {
          gradientFills++; // tracked separately — setBoundVariableForPaint does not work on gradient stops
        }
      }
    }
    // Stroke coverage — deprecated tokens bound to borders escape detection without this
    if ('strokes' in node && Array.isArray(node.strokes)) {
      for (const stroke of node.strokes) {
        if (stroke.type === 'SOLID') {
          if (stroke.boundVariables?.color) { boundStrokes++; }
          else { hardcodedStrokes++; uniqueHardcodedColors.add(toHex(stroke.color.r, stroke.color.g, stroke.color.b)); }
        }
      }
    }
    if (node.type === 'TEXT') {
      // figma.mixed is a Symbol returned when mixed styles span ranges — treat as unbound
      const styleId = node.textStyleId;
      if (styleId && styleId !== figma.mixed && styleId !== '') { boundTexts++; }
      else { hardcodedTexts++; }
    }
    if (node.type === 'INSTANCE') {
      totalInstances++;
      if (!node.mainComponent) { detachedInstances++; }
    }
  }

  const totalFills = boundFills + hardcodedFills;
  const fillCoverage = totalFills > 0 ? Math.round((boundFills / totalFills) * 100) : 100;
  const totalStrokes = boundStrokes + hardcodedStrokes;
  const strokeCoverage = totalStrokes > 0 ? Math.round((boundStrokes / totalStrokes) * 100) : 100;
  const totalTexts = boundTexts + hardcodedTexts;
  const textCoverage = totalTexts > 0 ? Math.round((boundTexts / totalTexts) * 100) : 100;
  const instanceHealth = totalInstances > 0 ? Math.round(((totalInstances - detachedInstances) / totalInstances) * 100) : 100;
  // Score weights: fills (35%), strokes (10%), text style (25%), component attachment (30%)
  const overallScore = Math.round((fillCoverage * 0.35) + (strokeCoverage * 0.10) + (textCoverage * 0.25) + (instanceHealth * 0.3));
  const maturityTier = overallScore >= 85 ? '4 — Mature'
    : overallScore >= 60 ? '3 — Adopting'
    : overallScore >= 30 ? '2 — Building'
    : '1 — Fragmented';

  return {
    pages, collectionNames, varGroups,
    textStyles: textStyles.length, effectStyles: effectStyles.length,
    componentSets, hasVersioning,
    changelog: {
      entries: _cl.length,
      lastEntry: _lastLog
        ? { timestamp: _lastLog.timestamp, phase: _lastLog.phase, created: _lastLog.created, failed: _lastLog.failed }
        : null,
    },
    // Count primitive color variables that are still accessible in the design panel
    // (scopes.length > 0 means the variable appears in fill/stroke pickers)
    // Tier 4 — Mature requires unscopedPrimitives = 0
    const primColl = collections.find(c => c.name === 'Color/Primitives');
    const primVars = primColl ? vars.filter(v => v.variableCollectionId === primColl.id) : [];
    const unscopedPrimitives = primVars.filter(v => v.scopes && v.scopes.length > 0).length;

    health: {
      scopedTo: figma.currentPage.name,
      maturityTier, overallScore: overallScore + '%',
      fillCoverage: fillCoverage + '%', hardcodedFills, uniqueHardcodedColors: uniqueHardcodedColors.size,
      strokeCoverage: strokeCoverage + '%', hardcodedStrokes, boundStrokes,
      textCoverage: textCoverage + '%', hardcodedTexts,
      instanceHealth: instanceHealth + '%', detachedInstances, totalInstances,
      gradientFills, gradientNote: gradientFills > 0
        ? `${gradientFills} gradient fills detected — not counted in coverage score (gradient stops need manual variable binding)`
        : null,
      brokenBindings, brokenBindingsNote: brokenBindings > 0
        ? `${brokenBindings} fills reference deleted variables — counted as hardcoded; use variable.resolveForConsumer(node) to inspect alias chains`
        : null,
      unscopedPrimitives,
      unscopedPrimitivesNote: unscopedPrimitives > 0
        ? `${unscopedPrimitives} primitive color variables are accessible in the design panel picker — designers can accidentally apply them directly. Run Protocol 9 M4 step 6 (lockPrimitiveScopes) to fix. Note: _prefix on collection name only hides from publishing, NOT the panel.`
        : null,
    },
    resolvedVariableModes: figma.currentPage.resolvedVariableModes, // active collection→mode map for this page
  };
}
return phase0b();
```

Read the output. Answer these before proceeding:
- Which token collections exist? (Constrain bindings to what's there.)
- Which component sets already exist? (Never recreate — reuse or extend.)
- Which text styles exist? (Use `setTextStyleIdAsync` — never set font properties manually.)
- Does versioning infrastructure exist? (If not, install it before any modification.)
- What is the maturity tier and health score? (Guide the work plan accordingly — see Protocol 8.)
- What does `changelog.lastEntry` show? (Tells you the last operation run on this file — context for the current task.)
- Are there broken bindings? (If `health.brokenBindings > 0`, fills reference deleted variables. Use `variable.resolveForConsumer(node)` on suspect nodes to inspect the full alias chain before trusting fill coverage scores.)
- What are the `resolvedVariableModes`? (Shows which collection→mode is active for the current page — critical when building multi-mode components.)
- Are there `unscopedPrimitives`? (If > 0, primitive color variables are still accessible in the design panel — designers can apply them directly instead of semantic tokens. Run Protocol 9 M4 step 6 after token migration is complete.)

---

## Phase 0 — Brand Input Parsing (from-scratch builds)

When creating a design system from scratch, extract a structured `BrandManifest` from the
user's brand source **before** touching Figma. This ensures all token phases have consistent
input. Skip this phase when working with an existing file that already has collections.

### Supported Sources

| Source type | How to read |
|---|---|
| Notion URL | `mcp__claude_ai_Notion__notion-fetch` → extract brand guidelines |
| Web URL (brand page / style guide) | `WebFetch` → parse colors, fonts, spacing |
| PDF / inline text | User pastes directly — extract values from content |
| User-provided values | Directly in chat: "primary is #1A6EFF, font is Inter" |

### BrandManifest Schema

```javascript
const BrandManifest = {
  meta: { name: "", personality: [], direction: "both" },  // "ltr"|"rtl"|"both"
  colors: {
    primary:  { name: "primary", baseHex: "" },
    neutral:  { baseHex: "", warmth: "neutral" },  // "warm"|"cool"|"neutral"
    success:  { baseHex: "#22C55E" },
    warning:  { baseHex: "#F59E0B" },
    error:    { baseHex: "#EF4444" },
    info:     { baseHex: "#3B82F6" },
    accents:  [],  // [{ name: "teal", baseHex: "#0D9488" }]
  },
  typography: {
    families: {
      ltr: { display: "Funnel Display", body: "Funnel Sans", mono: "JetBrains Mono" },
      rtl: { display: "Vazirmatn", body: "Vazirmatn", mono: "JetBrains Mono" },
    },
    scale: "major-third",  // "minor-second"|"major-second"|"minor-third"|"major-third"|"perfect-fourth"|"custom"
    baseSize: 16,
    customScale: null,  // [12,14,16,18,20,24,30,36,48] when scale="custom"
  },
  shape: { style: "rounded", radiiMd: 8 },  // "sharp"|"soft"|"rounded"|"pill"
  motion: { character: "standard" },  // "none"|"standard"|"expressive"|"gentle"
  density: { default: "default" },  // "compact"|"default"|"comfortable"
  _provided: [], _inferred: [], _defaulted: [], _missing: [],
};
```

### Parsing rules

1. Extract every field the source provides → mark in `_provided`
2. Infer missing fields using rules from `figma-token-foundation.md` → mark in `_inferred`
3. Use sensible defaults for anything still missing → mark in `_defaulted`
4. Surface `_missing` fields to user for confirmation BEFORE proceeding
5. User must confirm the manifest before any Figma writes begin

Load `figma-token-foundation.md` for the full OKLCH color scale generation algorithm,
type scale ratios, and spacing/radius derivation rules.

---

## Task Router

Map the user's intent to the correct reference file and workflow:

| User Intent | Route To | Key Pre-Step |
|-------------|----------|-------------|
| "create from scratch", "new design system", "build from brand", "brand guidelines" | Phase 0 Brand Input → `figma-token-foundation.md` | Parse BrandManifest first, confirm with user |
| "create tokens", "add variables", "set up colors/spacing/typography", "build token foundation" | `figma-token-foundation.md` | Phase 0b + check `_Meta` collection |
| "build component", "create molecule", "add states/variants", "token binding" | `figma-molecule-architecture.md` | Phase 0b + Systems Thinker audit script |
| "make responsive", "breakpoints", "density modes", "Auto Layout sizing", "mobile/desktop" | `research-responsive-adaptive-design.md` | Phase 0b + check Layout collection |
| "visual harmony", "something feels off", "audit proportions", "hierarchy", "spacing audit" | `research-visual-harmony-composition.md` | Phase 0b + screenshot current state |
| "canvas is broken", "panels overlapping", "orphan nodes", "reflow" | Reflow + Orphan Cleanup (inline below) | No prerequisites |
| "audit design system", "health check", "how healthy", "maturity", "token coverage report" | `figma-ds-modernization.md` → Protocol 8 | Phase 0b health metrics (built-in) |
| "migrate hardcoded", "migrate to tokens", "fix hardcoded colors", "token migration" | `figma-ds-modernization.md` → Protocol 9 | Phase 0b + survey hardcoded inventory |
| "remove deprecated tokens", "clean up old tokens", "sunset tokens", "deprecation" | `figma-ds-modernization.md` → Protocol 10 | Phase 0b + identify `_deprecated/` tokens |
| "fix detached instances", "reattach components", "component health repair" | `figma-ds-modernization.md` → Protocol 11 | Phase 0b health.detachedInstances |
| "build a section", "build a page template", "hero section", "card grid", "organism", "grid propagation", "layout structure", "section composition" | `research-layout-composition.md` → Protocol 12 | Phase 0b + check Layout collection exists |
| "document design system", "document tokens", "create docs panels", "visualize tokens", "show all tokens", "build a style guide", "token reference" | Protocol 13 (inline below) | Phase 0b — read all collections + text styles |
| "export tokens", "DTCG format", "tokens.json", "Style Dictionary export", "token pipeline" | Protocol 14 (inline below) | Phase 0b — read all variable collections |
| "code connect", "connect to code", "map Figma to code", "inspect panel code" | Protocol 15 (inline below) | `mcp__claude_ai_Figma__get_code_connect_suggestions` |
| "capture this page", "import from URL", "tokenize this design", "convert screenshot to tokens" | Protocol 16 (inline below) | `mcp__claude_ai_Figma__generate_figma_design` + Protocol 9 |
| "audit doc panels", "panels look inconsistent", "component docs don't match token docs", "documentation consistency", "panel style drift" | `figma-ds-modernization.md` → Protocol 17 | Phase 0b + navigate to target page |
| Multi-step (e.g. "build a full button system with tokens and components") | Load ALL applicable reference files | Phase 0b first, then route each sub-task |

**How to load reference files:**
Use the Read tool on the appropriate file at `~/.claude/skills/<filename>.md`:
- `~/.claude/skills/figma-token-foundation.md`
- `~/.claude/skills/research-figma-molecule-architecture.md`
- `~/.claude/skills/research-responsive-adaptive-design.md`
- `~/.claude/skills/research-visual-harmony-composition.md`
- `~/.claude/skills/figma-ds-modernization.md` ← existing/outdated design systems (Protocols 8–11)
- `~/.claude/skills/research-layout-composition.md` ← grid propagation, section/page composition (Protocol 12)

Read only the sections relevant to the current task — not the entire file unless doing a
full design system build.

---

## Universal Mandatory Protocols

These apply to EVERY figma_execute block. No exceptions.

### Protocol 1: Standard Phase Wrapper (paste at top of every figma_execute call)

```javascript
const _report = { phase: "", created: [], skipped: [], failed: [], warnings: [], blocked: null };
function safeExec(label, fn) {
  try { return fn(); }
  catch(e) { _report.failed.push({ name: label, reason: e.message || String(e) }); return null; }
}
async function safeExecAsync(label, fn) {
  try { return await fn(); }
  catch(e) { _report.failed.push({ name: label, reason: e.message || String(e) }); return null; }
}
function warn(msg) { _report.warnings.push(msg); }
function precheck(conditions) {
  for (const { test, message } of conditions) {
    if (!test) { _report.blocked = message; return false; }
  }
  return true;
}
```

### Protocol 1b: Shared Helper Library (paste after Phase Wrapper when doing token/component work)

These helpers eliminate boilerplate and enforce P4 (warn on fallback). Paste them after the
Phase Wrapper at the top of any `figma_execute` block that creates or binds tokens/components.

```javascript
// Variable lookup — returns the variable object or null
const colls = await figma.variables.getLocalVariableCollectionsAsync();
const vars  = await figma.variables.getLocalVariablesAsync();
function fv(collName, varName) {
  const c = colls.find(x => x.name === collName);
  return c ? vars.find(v => v.variableCollectionId === c.id && v.name === varName) || null : null;
}

// Bound fill paint — returns a paint object (use in fills array). Warns on missing variable.
function bf(variable, fallbackRgb) {
  if (variable) return figma.variables.setBoundVariableForPaint(
    { type: "SOLID", color: fallbackRgb }, "color", variable);
  warn(`bf: variable missing, using hardcoded ${JSON.stringify(fallbackRgb)}`);
  return { type: "SOLID", color: fallbackRgb };
}

// Strip alpha — fill color only accepts {r,g,b}
function toRgb(val) { return { r: val.r, g: val.g, b: val.b }; }

// Set fills/strokes directly on node (unlike bf which returns a paint)
function bfill(node, colorVar, fallback = { r: 0.5, g: 0.5, b: 0.5 }) {
  if (!colorVar) { warn(`bfill: no variable for "${node.name}"`); node.fills = [{ type: "SOLID", color: fallback, opacity: 1 }]; return; }
  node.fills = [figma.variables.setBoundVariableForPaint({ type: "SOLID", color: fallback, opacity: 1 }, "color", colorVar)];
}
function bstroke(node, colorVar, fallback = { r: 0.5, g: 0.5, b: 0.5 }) {
  if (!colorVar) { warn(`bstroke: no variable for "${node.name}"`); node.strokes = [{ type: "SOLID", color: fallback, opacity: 1 }]; return; }
  node.strokes = [figma.variables.setBoundVariableForPaint({ type: "SOLID", color: fallback, opacity: 1 }, "color", colorVar)];
}

// Structural binding helpers — all 4 corners, all 4 paddings, H/V split, gap, fontSize
function bindCornerRadius(node, v) {
  if (!v) { warn(`bindCornerRadius: no variable for "${node.name}"`); return; }
  for (const p of ["topLeftRadius","topRightRadius","bottomLeftRadius","bottomRightRadius"])
    try { node.setBoundVariable(p, v); } catch(e) { warn(`bindCornerRadius ${p}: ${e.message}`); }
}
function bindPadding(node, v) {
  if (!v) { warn(`bindPadding: no variable for "${node.name}"`); return; }
  for (const p of ["paddingTop","paddingBottom","paddingLeft","paddingRight"])
    try { node.setBoundVariable(p, v); } catch(e) { warn(`bindPadding ${p}: ${e.message}`); }
}
function bindPaddingH(node, v) {
  if (!v) { warn(`bindPaddingH: no variable for "${node.name}"`); return; }
  for (const p of ["paddingLeft","paddingRight"])
    try { node.setBoundVariable(p, v); } catch(e) { warn(`bindPaddingH ${p}: ${e.message}`); }
}
function bindPaddingV(node, v) {
  if (!v) { warn(`bindPaddingV: no variable for "${node.name}"`); return; }
  for (const p of ["paddingTop","paddingBottom"])
    try { node.setBoundVariable(p, v); } catch(e) { warn(`bindPaddingV ${p}: ${e.message}`); }
}
function bindGap(node, v) {
  if (!v) { warn(`bindGap: no variable for "${node.name}"`); return; }
  try { node.setBoundVariable("itemSpacing", v); } catch(e) { warn(`bindGap: ${e.message}`); }
}
function bindFontSize(node, v) {
  if (!v) { warn(`bindFontSize: no variable for "${node.name}"`); return; }
  try { node.setBoundVariable("fontSize", v); } catch(e) { warn(`bindFontSize: ${e.message}`); }
}

// Resolve variable alias chain to concrete value (for fallback colors, debugging)
function resolveVar(varId, allVarsById, depth = 0) {
  if (depth > 10) return null;
  const v = allVarsById[varId]; if (!v) return null;
  const val = Object.values(v.valuesByMode)[0];
  if (val?.type === 'VARIABLE_ALIAS') return resolveVar(val.id, allVarsById, depth + 1);
  return { name: v.name, value: val };
}
```

Full implementations with additional helpers (OKLCH color generation, type scale ratios,
spacing derivation) are in `figma-token-foundation.md` and `research-figma-molecule-architecture.md`.

### Protocol 1 addition: Completion Logging

After the **final write block** of every task, call `logTaskCompletion(_report)`:

```javascript
await logTaskCompletion(_report); // defined in figma-ds-modernization.md → Shared Helpers
```

Three layers written simultaneously:
1. **Shared plugin data** — `figma.root.setSharedPluginData('figma-ds-architect', 'changelog', ...)` — JSON history, survives file moves, queryable by any future script
2. **`⚙ AUDIT_TRAIL` frame** — human-readable text line appended on canvas, visible to designers
3. **`_Meta/last-modified`** — fast date stamp, surfaced in Phase 0b on next session

Load `figma-ds-modernization.md` to get the full `logTaskCompletion` implementation before executing any write block.

### Protocol 2: Idempotency First

Check before creating. Every phase begins:
```javascript
const existing = figma.root.children.find(p => p.name === 'Target Name');
if (existing) { _report.skipped.push('Target Name'); return _report; }
```

### Protocol 3: Structured Returns (never plain strings)

Every figma_execute block ends with:
```javascript
return { phase: "Phase N — Name", created: _report.created, skipped: _report.skipped, failed: _report.failed, warnings: _report.warnings, blocked: _report.blocked };
```

### Protocol 4: Canvas Reflow (run after every panel-creating or panel-resizing block)

```javascript
const PANEL_GAP = 48;
const _nodeMap = {};
for (const c of figma.currentPage.children) _nodeMap[c.name] = c;
const _colA = ['Panel · Color Primitives','Panel · Color Semantics','Panel · Contrast Matrix','Panel · Elevation & Effects'];
const _colB = ['Panel · Type Scale — LTR','Panel · Type Scale — RTL (Arabic)','Panel · Spacing Scale','Panel · Radius & Border Scale','Panel · Grid System','Panel · Motion System','Panel · Layering & Layout','Panel · Motion Playground'];
const _colC = ['Panel · Token Health Report','Panel · Direction & RTL'];
function _reflow(names, x) {
  let y = 0;
  for (const name of names) {
    const n = _nodeMap[name]; if (!n) continue;
    if (n.type === 'SECTION') n.resizeWithoutConstraints(960, n.height); else n.resize(960, n.height);
    n.x = x; n.y = y; y += n.height + PANEL_GAP;
  }
}
_reflow(_colA, 0); _reflow(_colB, 1040); _reflow(_colC, 2080);
```

**`getColBottom` — idempotent panel continuation** (use when adding a panel to an existing column without full reflow):
```javascript
function getColBottom(colX) {
  let bottom = 0;
  for (const n of figma.currentPage.children)
    if (Math.abs(n.x - colX) < 50) bottom = Math.max(bottom, n.y + n.height);
  return bottom > 0 ? bottom + PANEL_GAP : 0;
}
// Usage: newPanel.y = getColBottom(1040); // append to Column B
```

### Protocol 5: Orphan Cleanup (run after any mid-run failure or retry)

```javascript
const _knownNames = new Set([
  '⚙ AUDIT_TRAIL',
  'Panel · Color Primitives','Panel · Color Semantics','Panel · Contrast Matrix','Panel · Elevation & Effects',
  'Panel · Type Scale — LTR','Panel · Type Scale — RTL (Arabic)','Panel · Spacing Scale',
  'Panel · Radius & Border Scale','Panel · Grid System','Panel · Motion System',
  'Panel · Layering & Layout','Panel · Motion Playground','Panel · Token Health Report','Panel · Direction & RTL',
]);
for (const n of [...figma.currentPage.children]) {
  if (!_knownNames.has(n.name)) { console.log('Orphan removed:', n.name); n.remove(); }
}
```

### Protocol 6: Visual Validation Loop (after every figma_execute that creates visual output)

1. Call `mcp__figma-canvas__figma_take_screenshot`
2. Analyze the screenshot: alignment, spacing, proportions, visual balance, token binding visible
3. If issues found: fix and re-screenshot (max 3 iterations)
4. Only declare done after visual confirmation

### Protocol 7: Critical API Rules (always enforced)

| Never use | Use instead |
|-----------|------------|
| `figma.currentPage = page` | `await figma.setCurrentPageAsync(page)` |
| `setTextStyleIdAsync` without checking font availability | Call `listAvailableFontsAsync()` first. At OFFICIAL tier (MCP sandbox), custom and locally-installed fonts are NOT available — only Google Fonts and system fonts appear. `loadFontAsync` also fails for missing fonts. If font is absent: skip style binding and surface warning: `text style skipped — [FontName] unavailable; requires Canvas Bridge`. |
| `node.textStyleId = id` | `await node.setTextStyleIdAsync(id)` |
| Inline `boundVariables` on paint | `figma.variables.setBoundVariableForPaint()` |
| `node.paddingTopVariable = var` | `node.setBoundVariable("paddingTop", var)` |
| `node.cornerRadiusVariable = var` | `node.setBoundVariable("topLeftRadius", var)` — set all 4 corners individually |
| `layoutSizingHorizontal = "FILL"` before append | Append to parent FIRST, then set FILL |
| `{ unit: "MULTIPLIER" }` on lineHeight | `{ value: n * 100, unit: "PERCENT" }` |
| `figma_setup_design_tokens` with > 100 tokens | Split into batches of ≤ 100. Use `figma_execute` for larger sets |
| Variable names with `.` (e.g. `space/0.5`) | Use `-` instead: `space/0-5` |
| `aliasOf` in `figma_batch_create_variables` | Not supported. Two-step: create the variable, then wire alias via `figma_execute` |
| `setExplicitVariableModeForCollection(collId, modeId)` with string ID | Must pass the **collection object**, not the ID string |
| `style.setBoundVariable("lineHeight", var)` | Not supported in Figma API. Store raw value; bind `fontSize`/`fontFamily` only |
| `setTextStyleIdAsync` called AFTER setting `fontSize` | Call `setTextStyleIdAsync` FIRST, then override `fontSize`. Reversed order resets the cap |
| `setTextStyleIdAsync` on a doc specimen node | Resets `fontSize` to the style's stored value. For doc specimens, set `.fontName`, `.fontSize`, `.lineHeight` directly |
| `setTextStyleIdAsync` on RTL node without re-asserting alignment | Re-assert `textAlignHorizontal = "RIGHT"` and `textAutoResize = "WIDTH_AND_HEIGHT"` immediately after |
| Fill `color: { r, g, b, a }` | `color` only accepts `{ r, g, b }`. Alpha goes at fill level: `opacity: 0.4` |
| `reaction.action` (singular) | `actions: [...]` (plural array) |
| `destinationId: nestedFrame.id` | `{ type: "BACK" }` for nested frame returns |
| `await frame.layoutGrids = [...]` | `frame.layoutGrids = [...]` (synchronous — no await) |
| `node.reactions = [...]` direct assign | `await node.setReactionsAsync([...])` |
| `await node.setEffectStyleIdAsync(id)` without await | Must be awaited. Silently does nothing without `await` |
| Spring cubic-bezier fallback `{ type: "EASE_OUT" }` | `{ type: "EASE_OUT_BACK" }` — built-in Figma back-ease for overshoot/spring curves |
| `layoutGrids` with `sectionSize` on COLUMNS pattern | `sectionSize` is only valid for ROWS/GRID. For `pattern: 'COLUMNS'`, omit it entirely |
| `counterAxisSizingMode = "FIXED"` after `resize(w, smallH)` | Small height gets locked. Set correct final height BEFORE switching to FIXED, or call `resize(w, finalH)` explicitly |
| `placePanel(frame, col)` before children added | Frame height = 100 until children exist. Call `placePanel` AFTER all children are appended |
| `setBoundVariable` on outer radius only | Inner display rect `cornerRadius` stays static. Bind BOTH outer group AND inner fill rect to the radius variable |
| Children inside a glass/blur card | Children render sharp through blur. Glass cards must have **no children** — semi-transparent fill + backdrop blur only. Content goes on the parent behind the card |
| `setBoundVariableForPaint` without `setExplicitVariableModeForCollection` on semantic swatch | Swatch shows collection default mode. Must also call `swatch.setExplicitVariableModeForCollection(coll, modeId)` to lock Light/Dark |
| Hardcode shadow `color`/`radius`/`spread` on elevation tokens | `figma.variables.setBoundVariableForEffect(effect, 'color', elevationVar)` — bind shadow fields to variables |
| Hardcode `gutterSize`/`offset` on layout grid | Resolve token value to px first; `layoutGrids` fields cannot bind to variables |
| Spacing bars showing ~75% of expected values | First mode in collection is implicit default. If Compact was created before Default, all unset frames resolve to Compact. Fix: `panel.setExplicitVariableModeForCollection(spacingColl, defaultModeId)` on every panel |
| Motion Playground State A cards nested in panel | Clicking navigates FROM the whole panel. State A frames must be **top-level** on the page — extract from panel after creation |

**Paint freshness rule** — never reuse a bound paint object across nodes:
```javascript
// WRONG — shared reference; only first node reliably gets the binding
const hoverPaint = figma.variables.setBoundVariableForPaint(base, 'color', hoverVar);
for (const v of variants) v.fills = [hoverPaint]; // second node may lose binding

// CORRECT — fresh paint per node
for (const v of variants) {
  v.fills = [figma.variables.setBoundVariableForPaint(base, 'color', hoverVar)];
}
```
Also: use the **resolved concrete color** as the base paint, not `{r:0,g:0,b:0}`. If the variable fails to resolve, the fallback color (your base) is what the user sees.

**Elevation token binding pattern** (bind DROP_SHADOW color to an effect variable):
```javascript
const shadow = { type: 'DROP_SHADOW', color: { r: 0, g: 0, b: 0, a: 0.12 }, offset: { x: 0, y: 4 }, radius: 8, spread: 0, visible: true, blendMode: 'NORMAL' };
const boundShadow = figma.variables.setBoundVariableForEffect(shadow, 'color', elevationColorVar);
node.effects = [boundShadow];
```

**Surface-aware token selection** — state tokens depend on the surface the component sits on:

| Component surface | Hover fill | Pressed fill | Focus ring |
|---|---|---|---|
| Dark/colored (`action/primary`) | `state/hover` (white 8%) as 2nd fill overlay | `state/pressed` (white 12%) as 2nd fill overlay | `state/focus-ring` stroke |
| Transparent (outlined/ghost) | `background/subtle` as single fill | `background/surface` as single fill | `state/focus-ring` stroke |
| Surface (input/dropdown) | `background/subtle` as single fill | `background/surface` as single fill | `state/focus-ring` stroke |

`state/hover` is a semi-transparent white overlay — invisible on transparent surfaces. Use `background/subtle` instead for outlined/ghost components. Figma renders fills bottom-to-top (index 0 = bottom). Two-fill overlays: base fill first, overlay second.

---

## Existing Design System Protocols

Use these protocols when the user's Figma file already has components, styles, or tokens —
especially when the system is outdated, inconsistently bound, or accumulating debt.

**Load the reference file before executing any modernization work:**
```
~/.claude/skills/figma-ds-modernization.md
```

| Protocol | Purpose | Trigger |
|----------|---------|---------|
| 8 — Maturity Assessment | 4-tier score, 6-R roadmap — no writes until user confirms | "audit", "health check", "how mature" |
| 9 — Token Migration (Strangler Fig) | Survey → map → bind in-place → verify | "migrate hardcoded", "token migration" |
| 10 — Deprecation + Sunset | Find deprecated → check fills+strokes → remap → delete | "deprecated tokens", "clean up", "sunset" |
| 11 — Component Health Repair | Inventory detached → audit overrides → present repair options | "detached instances", "fix components" |

Always load `figma-ds-modernization.md` and read the relevant protocol section before
calling any `figma_execute` write block for modernization work.

### Protocols 8–11: Full detail in `figma-ds-modernization.md`

Load `~/.claude/skills/figma-ds-modernization.md` and read only the protocol section
you need. Do not improvise these workflows — the reference file contains the correct,
tested code for each phase.

---

## Grid Propagation + Compositional Layout

Use Protocol 12 when the user asks to build sections, page templates, organisms, hero
blocks, card grids, or any multi-molecule layout that must respect the token grid system.

**Load the reference file before executing any composition work:**
```
~/.claude/skills/research-layout-composition.md
```

| Protocol | Purpose | Trigger |
|----------|---------|---------|
| 12 — Grid Propagation | Apply grid tokens through 5-level hierarchy (Atom→Molecule→Block→Section→Page) | "build a section", "page template", "hero", "card grid", "organism" |

### Protocol 12: Grid Propagation — key rules (always enforced)

- Every **section-level frame** gets a 12-column layout guide (`frame.layoutGrids = [...]` — synchronous, no await)
- `gutterSize` and `offset` in `layoutGrids` must be **numeric px values** — they cannot be bound to variables; resolve the token numeric value first
- Every **container inner frame** binds `maxWidth` to `Layout/container/xl` via `frame.setBoundVariable('maxWidth', var)`
- `maxWidth` only works when the frame uses Auto Layout (`layoutMode !== 'NONE'`)
- Spacing-y on sections uses **section-band tokens** (`spacing/8`–`spacing/16`, 24–64px range)
- Molecules inside sections use **component-band tokens** (`spacing/1`–`spacing/6`, 4–24px range)
- Page templates use **page-band tokens** for outer structure (`spacing/16`–`spacing/32`, 64–128px+)
- Never apply layout guides at molecule level — guides live only on section-level frames and above
- Load `research-layout-composition.md` for full patterns: `buildSection()`, `buildPageTemplate()`,
  `applyColumnGuide()`, `compositionHealthReport()`, and the context decision tree

**`getGridValues()` — resolve Layout collection tokens before applying guides:**
```javascript
async function getGridValues(mode = 'Default') {
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const layout = collections.find(c => c.name === 'Layout');
  if (!layout) return { gutter: 32, margin: 80, columns: 12 }; // fallback
  const modeId = layout.modes.find(m => m.name === mode)?.modeId ?? layout.defaultModeId;
  const vars = await figma.variables.getLocalVariablesAsync();
  const gv = n => vars.find(v => v.variableCollectionId === layout.id && v.name === n);
  return {
    gutter:  gv('grid/gutter')?.valuesByMode[modeId]  ?? 32,
    margin:  gv('grid/margin')?.valuesByMode[modeId]   ?? 80,
    columns: gv('grid/columns')?.valuesByMode[modeId]  ?? 12,
  };
}
```

**2D Grid Auto Layout (Config 2025)** — CSS Grid equivalent for multi-column content:
```javascript
// Use for card grids, product shelves, bento layouts, dashboards
const frame = figma.createFrame();
frame.name = 'Block · Card Grid';
parent.appendChild(frame);  // append BEFORE setting FILL
frame.layoutMode = 'GRID';  // 2D Grid — Config 2025
frame.layoutSizingHorizontal = 'FILL';
frame.layoutSizingVertical = 'HUG';
// Bind gap tokens — itemSpacing = column gap, counterAxisSpacing = row gap
if (columnGapVar) frame.setBoundVariable('itemSpacing', columnGapVar);
if (rowGapVar)    frame.setBoundVariable('counterAxisSpacing', rowGapVar);
```

| Need | Layout mode |
|------|-------------|
| Cards in a wrapping multi-column grid | `GRID` (2D) |
| Stacked form rows / page sections | Vertical Auto Layout |
| Inline nav / button group | Horizontal Auto Layout |
| Sidebar + main column | `GRID` (2 columns) |

---

## Protocol 13: Design System Documentation

Builds live-bound documentation panels directly on the Figma canvas. Panels are **never
static** — every color, style, and measurement is bound to its source variable or text style
so panels auto-update when tokens change.

### Canvas layout — always 3 columns, 80px column gap, 80px row gap

```
Col 1 (x=0)         Col 2 (x=col1W+80)     Col 3 (x=col2W+80)
─────────────────   ───────────────────     ──────────────────
Panel · Color       Panel · Brand Tokens    Panel · Motion
  Primitives
                    Panel · Spacing &       Panel · Overview
Panel · Typography    Radius
```

Position panels by measuring actual frame sizes after build, not by guessing heights.

### Binding rules — mandatory for every doc panel

| Element | API to use | Never use |
|---------|-----------|-----------|
| Color swatch fill | `figma.variables.setBoundVariableForPaint(paint, 'color', variable)` | Hardcoded hex in fills |
| Text sample | `await node.setTextStyleIdAsync(style.id)` | Manual `fontSize`/`fontName` on sample nodes |
| Spacing demo | `node.setBoundVariable('paddingLeft', spacingVar)` | Hardcoded `paddingLeft` px value |
| Gap demo | `node.setBoundVariable('itemSpacing', var)` | Hardcoded `itemSpacing` value |
| Radius chip | `node.setBoundVariable('cornerRadius', radiusVar)` | Hardcoded `cornerRadius` value |
| Light/Dark mode swatch | `wrapperFrame.setExplicitVariableModeForCollection(collId, modeId)` + bound fill inside | Separate fill per mode |

### setExplicitVariableModeForCollection — Light/Dark swatch pattern

```javascript
// For each Brand Token row, create two wrapper frames — one per mode
const lightWrap = figma.createFrame();
lightWrap.fills = []; // transparent
lightWrap.setExplicitVariableModeForCollection(brandColl.id, lightModeId);
const lightSwatch = figma.createFrame();
const lPaint = figma.variables.setBoundVariableForPaint(
  { type: 'SOLID', color: { r: 0.5, g: 0.5, b: 0.5 } }, 'color', tokenVar);
lightSwatch.fills = [lPaint];
lightWrap.appendChild(lightSwatch);
panel.appendChild(lightWrap);
// Repeat with darkModeId for dark swatch
```

The same variable resolves to Light in one wrapper, Dark in the other — mode toggle is instant.

### Panel naming convention

- `Panel · Color Primitives`
- `Panel · Brand Tokens`
- `Panel · Spacing & Radius`
- `Panel · Typography`
- `Panel · Motion`
- `Panel · Overview`

### Idempotency

Remove existing panels by name before rebuilding — never append duplicates.

### opacity field placement

`opacity` belongs at the **fill level** (`{ type: 'SOLID', color: {...}, opacity: 0.4 }`),
NOT inside the `color` object. `color` accepts only `{ r, g, b }`.

---

## Protocol 14: W3C DTCG Token Export

Exports the live Figma variable set to W3C Design Token Community Group format — the stable
spec (Oct 2025) used by Style Dictionary, Theo, and most CI token pipelines.

**Trigger**: "export tokens", "DTCG format", "tokens.json", "Style Dictionary export", "token pipeline"

### Format: `{ "$value": ..., "$type": "color" }`

Variable group separators (`/`) map to nested JSON objects.
`color/primary/500` → `{ "color": { "primary": { "500": { "$value": "...", "$type": "color" } } } }`

### Export script (call via figma_execute)

```javascript
const vars = await figma.variables.getLocalVariablesAsync();
const colls = await figma.variables.getLocalVariableCollectionsAsync();
const tokens = {};
const typeMap = { COLOR: 'color', FLOAT: 'number', STRING: 'string', BOOLEAN: 'boolean' };
for (const v of vars) {
  const coll = colls.find(c => c.id === v.variableCollectionId);
  const segments = v.name.split('/');
  let node = tokens;
  for (let i = 0; i < segments.length - 1; i++) {
    node[segments[i]] = node[segments[i]] || {};
    node = node[segments[i]];
  }
  const leaf = segments[segments.length - 1];
  const modeValues = {};
  for (const m of coll.modes) {
    const raw = v.valuesByMode[m.id];
    modeValues[m.name] = raw?.type === 'VARIABLE_ALIAS'
      ? `{${(await figma.variables.getVariableByIdAsync(raw.id))?.name || '??'}}`
      : raw;
  }
  node[leaf] = coll.modes.length === 1
    ? { $value: Object.values(modeValues)[0], $type: typeMap[v.resolvedType] || 'unknown' }
    : { $value: modeValues[coll.modes[0].name], $type: typeMap[v.resolvedType] || 'unknown', $extensions: { modes: modeValues } };
}
return JSON.stringify(tokens, null, 2);
```

Paste the returned JSON into `tokens.json` at the repo root for Style Dictionary consumption.
Multi-mode variables include `$extensions.modes` with per-mode values.

---

## Protocol 15: Code Connect Auto-mapping

Bridges Figma components to codebase implementations using Figma's Code Connect API.
After mapping, developers see real import code in the Figma Inspect panel for every component.

**Trigger**: "code connect", "connect components to code", "map Figma to code", "inspect panel code"

### Step C1 — Get suggestions

Use `mcp__claude_ai_Figma__get_code_connect_suggestions` with the file key. Returns candidate
Figma component → code file pairings based on component name similarity.

### Step C2 — Build mappings

Use `mcp__claude_ai_Figma__add_code_connect_map` to register each pairing. Key fields:

```javascript
{
  nodeId: "123:456",          // Figma component node ID
  codeComponent: "import { Button } from '@/components/Button'",
  props: {
    variant: { figmaProp: "variant", mapping: { Primary: "primary", Secondary: "secondary" } },
    disabled: { figmaProp: "state", mapping: { Disabled: true } }
  }
}
```

### Step C3 — Publish

Use `mcp__claude_ai_Figma__send_code_connect_mappings` to push all mappings to Figma.

Full detail in `~/.claude/skills/figma-code-connect.md` (create this file if needed).

---

## Protocol 16: Capture UI → Tokenize

Captures a live webpage into Figma then migrates all hardcoded values to token bindings —
converting legacy or external UIs into token-backed Figma assets in one workflow.

**Trigger**: "capture this page", "import from URL", "tokenize this design", "convert screenshot to tokens"

### Step T1 — Capture

Use `mcp__claude_ai_Figma__generate_figma_design` with the live URL. Figma receives a frame
matching the rendered UI with all colors as hardcoded fills.

### Step T2 — Survey

Run Protocol 9 Phase M1 on the captured frame — list all unique hex values by frequency.
Present the mapping to the user before binding.

### Step T3 — Map + Bind

Run Protocol 9 Phase M2 (color matching via HSL tolerance) and Phase M3 (bind in-place).
Fills matching an existing token within tolerance are rebound automatically.

### Step T4 — Verify

Run Protocol 9 Phase M4 (health scan before/after). Report token coverage improvement.

---

## Output Format

After every completed task, report:

```
## Figma Task Complete: [task name]

**Phase**: [which phase ran]
**Created**: [list of nodes/variables/styles created]
**Skipped**: [list of items that already existed — idempotency]
**Failed**: [list with reasons — empty if clean]
**Warnings**: [invisible fallbacks, missing vars, API workarounds used]
**Canvas validation**: [screenshot taken — describe what was verified]

**Next steps** (if applicable):
1. [Next task in the workflow]
```

---

## Quality Gate

Before declaring any task complete, verify:

- [ ] Phase 0b ran and its output was read (never skipped)
- [ ] No duplicates created (idempotency check passed)
- [ ] All figma_execute blocks returned structured `{ phase, created, skipped, failed, warnings }` — not plain strings
- [ ] Reflow ran after any panel modification
- [ ] Screenshot taken and analyzed (visual validation loop ran)
- [ ] Failed array is empty OR failures are documented and acceptable
- [ ] Warnings surfaced to user (invisible fallbacks are not silent)
- [ ] For token work: all bindings are live variable bindings, not hardcoded values
- [ ] For component work: all variants screenshot-verified in both Light and Dark mode
- [ ] For responsive work: sizing modes (FILL/HUG/FIXED) assigned per the decision tree
- [ ] For visual harmony: 7 Master Principles verified — Purpose (intent matches execution), Proportion (Golden Ratio 1:1.618 on major containers), Hierarchy (type scale follows Fibonacci/modular, contrast decreases with importance level), Balance (visual weight distributed per Rule of Thirds), Rhythm (spacing uses Fibonacci scale: 4,8,12,16,24,32,48,64), Unity (max 2 font families, consistent corner radii, cohesive palette), Tension (intentional contrast at max 1–2 focal points per view)
- [ ] For DS audit: maturity report produced BEFORE any modifications; user confirmed the roadmap
- [ ] For token migration: survey shown to user BEFORE bind phase; coverage verified AFTER (health scan re-run)
- [ ] For deprecation: Phase D2 (binding check) ran BEFORE any token deletion; no variable deleted with active bindings
- [ ] For component health repair: detached instance inventory shown to user BEFORE any repair action
- [ ] For layout composition: section-level frames have a 12-column layout guide; container frames have `maxWidth` bound to Layout collection variable; section spacing uses section-band tokens; molecules use component-band tokens only
- [ ] For documentation (Protocol 13): every color swatch fill bound via `setBoundVariableForPaint`; every text sample bound via `setTextStyleIdAsync`; spacing demos use `setBoundVariable('paddingLeft')`; radius chips use `setBoundVariable('cornerRadius')`; Light/Dark mode swatches use `setExplicitVariableModeForCollection`; no hardcoded color or font values anywhere in doc panels; panels positioned in 3-column layout measured from actual frame sizes
- [ ] Panel consistency (Protocol 17): after any panel creation or modification, run `scanPanelConsistency()` — all `Panel ·` frames must share the same fill token (`background/subtle`), radius binding (`radius/lg` on all 4 corners), and semantic text hierarchy (category→`accent/primary`, title→`text/primary`, description→`text/tertiary`). Zero tolerance for primitive fills or unbound hardcoded values on panel frames. If `inconsistentPanels.length > 0`, run `fixPanelConsistency()` before declaring done.
- [ ] For DTCG export (Protocol 14): all variable groups exported; multi-mode variables include `$extensions.modes`; alias references serialized as `{token.path}` strings, not raw values
- [ ] For Code Connect (Protocol 15): suggestions reviewed before mapping; all prop variants mapped; `send_code_connect_mappings` called to publish
- [ ] For UI capture (Protocol 16): survey shown to user BEFORE bind phase; Protocol 9 health scan run before and after to confirm coverage improvement
- [ ] For elevation bindings: shadow `color` fields bound via `setBoundVariableForEffect`, not hardcoded; `brokenBindings` in Phase 0b output is 0 (or acknowledged)
- [ ] For from-scratch builds: BrandManifest parsed and confirmed by user BEFORE any Figma writes; `_provided`/`_inferred`/`_defaulted`/`_missing` fields surfaced
- [ ] Stroke coverage checked: `health.strokeCoverage` reported alongside fill coverage; deprecated tokens in strokes not missed
- [ ] Paint freshness: no bound paint object reused across multiple nodes (fresh `setBoundVariableForPaint` per node in loops)
- [ ] `logTaskCompletion(_report)` called at end of final write block — changelog entry appended to shared plugin data + `⚙ AUDIT_TRAIL` frame + `_Meta/last-modified` updated

---

## Edge Cases

- **MCP plugin disconnected**: Re-run Phase 0a probe cascade from `init.md`. Do NOT immediately stop — fall back to OFFICIAL or REST_ONLY tier if available. Only stop if `ACTIVE_TIER = NONE`.
- **Variable collection missing when expected**: Warn, do not hardcode. Read `figma-token-foundation.md` and build the missing collection before proceeding.
- **Component set already exists**: Systems Thinker Law 1 — reuse. Read the existing set, extend it. Never recreate.
- **figma_execute times out mid-run**: Run Orphan Cleanup (Protocol 5) before retrying. Partial nodes are worse than no nodes.
- **`failed` array non-empty after a phase**: Do not proceed to the next phase. Report failures, let user decide whether to retry or accept partial results.
- **Canvas reflow moves panels in wrong order**: Read `figma-token-foundation.md` → Mandatory Post-Task Rule for current column layout definition.
- **Font not loading**: Always verify with `figma.listAvailableFontsAsync()` before using. Inter uses `"Semi Bold"` (with space), not `"SemiBold"`.
- **Token binding appears invisible**: Resolve the alias chain with `resolveVar()` helper from `research-figma-molecule-architecture.md` before binding. White overlays on transparent surfaces are invisible.
- **Multi-discipline task** (tokens + components + responsive): Load all relevant reference files at the start. Complete token work before molecule work. Molecule work before responsive work. Never reverse the order.
- **Unknown token naming convention**: If Phase 0b reveals a naming pattern you don't recognize (e.g. Material Design 3 `md.sys.color.*`, IBM Carbon `$layer-01`, Atlassian `color.background.neutral`) — use WebSearch to look up that system's token architecture before mapping, migrating, or renaming anything.
- **Token migration produces zero bound nodes**: Stop. The survey step likely ran on a different page than the bind step. Verify `figma.currentPage` matches. Do not retry blind.
- **Deprecated variable has active bindings**: Never delete. Run Phase D3 remap first. Only delete after Phase D2 confirms zero bindings remain.
- **Detached instance has no matching main component in the library**: Do not attempt auto-reattach. Surface to user with the instance name, position, and a screenshot. Ask whether to delete, keep as frame, or search library for a renamed component.
- **fill.boundVariables.color returns a stale alias**: The alias chain may be broken (variable was deleted). Phase 0b now automatically detects broken bindings with `getVariableByIdAsync` — check `health.brokenBindings`. To inspect the resolved VALUE of a live alias (not just existence), use `variable.resolveForConsumer(node)` which returns `{ value, resolvedType }` accounting for multi-mode context.
- **MCP Server Cards (`.well-known/mcp.json`)**: Figma exposes capability metadata at `/.well-known/mcp.json`. This is read-only server metadata — it describes available tools and scopes. Do not attempt to write to it. Reference it only if a user asks which Figma MCP tools are available server-side.
- **`generate_figma_design` returns a frame with no token bindings**: Expected — it captures the rendered DOM as hardcoded fills. Immediately run Protocol 9 Phase M1 survey to map hex values to existing tokens before any manual work in the file.
- **Large file (>10k nodes) causes health scan timeout**: Scope the scan to `figma.currentPage` rather than all pages. Report that health metrics are page-scoped and offer to re-run on other pages individually.
- **Layout collection missing when building a section or page**: Do not hardcode gutter/margin px values. Read `research-layout-composition.md` → Section 3 (Grid Propagation Rule) for the required collection structure. Build the Layout collection first, then proceed with section construction.
- **`maxWidth` has no effect on a container frame**: `maxWidth` only works on Auto Layout frames. Ensure the container frame has `layoutMode` set to `"HORIZONTAL"` or `"VERTICAL"` (not `"NONE"`) before calling `frame.setBoundVariable('maxWidth', var)`.
- **`frame.layoutGrids = [...]` with variable reference throws**: `gutterSize` and `offset` in layout guides cannot be bound to Figma variables — they accept numbers only. Resolve the token's numeric value at the time of application. If the token changes, re-run the layout guide application step.
- **Section spacing looks wrong after adding a child organism**: Check whether child padding-y is double-stacking with the section's padding-y. Sections carry their own padding — child organisms should use gap tokens, not their own vertical padding, when nested inside a section frame.
- **Page template sections overlap each other**: Page template gap should be `0` — sections carry their own padding-y (section-band tokens). Setting gap > 0 on the page frame doubles the spacing. Set `page.itemSpacing = 0` and let each section control its own vertical rhythm.
- **Motion Playground State A frames nested inside panel**: Prototype navigation triggers FROM the outermost frame. If State A cards are children of a panel, clicking navigates from the panel, not the card. State A frames must be **top-level** on the page — extract them from the panel after creation; the panel becomes a visual-only backdrop.
- **Padding value has no matching token**: The Spacing collection uses even increments (2, 4, 6, 8, 10, 12, 16, 20, 24...). There is no `space/0` token. Odd values (3, 5, 7, 13) have no token match — round to the nearest token step. Form fields with intentional 0 padding should remain unbound.
- **`frame.layoutMode = 'GRID'` set before appending children**: Children may get unexpected positioning. Append children first, then set `layoutMode = 'GRID'`. Same rule as FILL sizing.
- **Health scan shows 100% on empty page**: An empty page with no fills, texts, or instances returns 100% by default (0/0 = 100). This is correct — no violations exist. The score becomes meaningful only after content is present.
