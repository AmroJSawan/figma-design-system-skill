---
name: figma-mcp-init
description: MCP detection and adapter layer for design-system-skill. Run at the start of every session to detect available MCP tier and set operation routing strategy.
type: reference
---

# Figma MCP Init — Detection & Adapter Layer

Run this before every task. Sets `ACTIVE_TIER` for the session. All subsequent operations route through the dispatch table below.

---

## Phase 0a: MCP Probe Cascade

Attempt probes in order. First success wins — set `ACTIVE_TIER` and stop probing.

### Probe 1 — Canvas Bridge (preferred)

Call `mcp__figma-canvas__figma_get_status` (zero parameters, no side effects).

- Status: connected → **`ACTIVE_TIER = CANVAS_FULL`** — stop probing, proceed
- Error or disconnected → try Probe 2

### Probe 2 — Official Figma MCP

Call `mcp__figma__whoami` (zero parameters, no side effects, no fileKey needed).

- Success (returns user/email) → **`ACTIVE_TIER = OFFICIAL`** — stop probing, notify user (see below), proceed
- Error → try Probe 3

### Probe 3 — REST-only (no plugin)

Call `mcp__figma-canvas__figma_get_file_data` with the active file URL if known.

- Success → **`ACTIVE_TIER = REST_ONLY`** — stop probing, notify user, proceed (read-only)
- Error → **`ACTIVE_TIER = NONE`** → abort with setup instructions below

---

## Phase 0a: Tier Notification

Always tell the user which tier is active before proceeding.

**CANVAS_FULL** — no notice needed, proceed silently.

**OFFICIAL:**
> "Canvas Bridge plugin not active. Running via official Figma MCP (OFFICIAL tier).
> Reduced capabilities: no native audit scoring dashboard, bulk variable creation
> uses JS loop (~50× slower), WCAG contrast checks cannot resolve variable chains,
> no console log access.
> To restore full capabilities: open Figma Desktop → Plugins → Canvas Bridge."

**REST_ONLY:**
> "Running in read-only mode (REST_ONLY). No writes available. Can audit file
> structure, components, styles, and variables only.
> To enable writes: activate Canvas Bridge plugin."

**NONE:**
> "No Figma MCP is connected. Cannot proceed.
> Option 1 — Full capabilities: Open Figma Desktop → Plugins → Canvas Bridge
> Option 2 — Partial capabilities: Connect the official Figma MCP via Claude settings"

**Probe 3 returns 403 Token Expired:**
> "Figma access token is expired (REST_ONLY tier unavailable). To fix:
> Option 1 — Regenerate token in Figma → Settings → Personal Access Tokens, update FIGMA_ACCESS_TOKEN env var
> Option 2 — Activate Canvas Bridge plugin or connect official Figma MCP instead"

---

## Operation Dispatch Table

For every operation, look up `ACTIVE_TIER` and call the listed tool. Never call a CANVAS_FULL
tool when `ACTIVE_TIER = OFFICIAL` — use the JS equivalent instead.

### Health & Status

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Session health check | `figma_get_status` | `use_figma` minimal read | `figma_get_file_data` |
| Phase 0b full scan | `figma_execute` (phase0b script) | `use_figma` (phase0b-official script — see below) | REST partial (no health metrics) |
| Screenshot | `figma_take_screenshot` | `mcp__figma__get_screenshot` | — |
| Console logs | `figma_get_console_logs` | — (unavailable) | — |

### Token & Variable Operations

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Read variables | `figma_get_variables` | `use_figma` (getLocalVariablesAsync) | `figma_get_variables` (REST) |
| Create collection | `figma_create_variable_collection` | `use_figma` (createVariableCollection) | — |
| Batch create ≤100 vars | `figma_batch_create_variables` | `use_figma` (batch-create-vars script — see below) | — |
| Setup full token system | `figma_setup_design_tokens` | `use_figma` (setup-tokens script — see below) | — |
| Update variable | `figma_update_variable` | `use_figma` (setValueForMode) | — |
| Add mode | `figma_add_mode` | `use_figma` (collection.addMode) | — |

### Audit & Lint Operations

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Design system audit (full) | `figma_audit_design_system` | `use_figma` (audit-basic script — see below) + degradation notice | `figma_get_design_system_summary` |
| Lint design (WCAG-aware) | `figma_lint_design` | `use_figma` (lint-basic script — see below) — no variable-chain contrast | — |
| Design system summary | `figma_get_design_system_summary` | `use_figma` (getLocalVariablesAsync summary) | `figma_get_design_system_kit` |
| Get styles | `figma_get_styles` | `use_figma` (getLocalTextStylesAsync + getLocalEffectStylesAsync) | `figma_get_styles` (REST) |
| **Protocol 8** — Maturity Assessment | `figma_audit_design_system` + `figma_execute` (full script in `figma-ds-modernization.md`) | `use_figma` (audit-basic script) — no 4-tier score | `figma_get_design_system_summary` (partial) |
| **Protocol 9** — Token Migration | `figma_execute` (Strangler Fig script in `figma-ds-modernization.md`) | `use_figma` (same script) | — |
| **Protocol 10** — Deprecation + Sunset | `figma_execute` (deprecation script in `figma-ds-modernization.md`) | `use_figma` (same script) | — |
| **Protocol 11** — Component Repair | `figma_execute` (repair script in `figma-ds-modernization.md`) | `use_figma` (same script) | — |

> Protocols 8–11 full scripts live in `figma-ds-modernization.md`. At OFFICIAL tier, all
> `figma_execute` calls in those scripts become `use_figma` calls with identical JS bodies.

### Component Operations

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Search components | `figma_search_components` | `mcp__figma__search_design_system` | `figma_search_components` (REST) |
| Get component (by nodeId) | `figma_get_component` | `mcp__figma__get_design_context` (with nodeId) | `figma_get_component` (REST) |
| Get component details (by key) | `figma_get_component_details` | `mcp__figma__get_design_context` | `figma_get_component_details` (REST) |
| Instantiate component | `figma_instantiate_component` | `use_figma` (importComponentByKeyAsync + createInstance) | — |
| Arrange component set | `figma_arrange_component_set` | `use_figma` (auto-layout arrange) | — |
| Get current selection | `figma_get_selection` | `use_figma` (figma.currentPage.selection) | — |

### Write / Canvas Operations

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Arbitrary canvas code | `figma_execute` | `use_figma` (same JS, different tool) | — |
| Set fills | `figma_set_fills` | `use_figma` (node.fills = [...]) | — |
| Set text | `figma_set_text` | `use_figma` (node.characters = ...) | — |
| Create child node | `figma_create_child` | `use_figma` (figma.createFrame etc.) | — |
| Resize node | `figma_resize_node` | `use_figma` (node.resize) | — |
| Move node | `figma_move_node` | `use_figma` (node.x = ..., node.y = ...) | — |
| Bind variable to fill | `figma_set_fills` with variableId | `use_figma` (setBoundVariableForPaint) | — |

### UI Capture (Protocol 16)

| Operation | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Capture live URL to Figma | `mcp__figma__generate_figma_design` (all tiers — this is an official MCP tool) | same | — |
| Tokenize captured fills | Protocol 9 via `figma_execute` | Protocol 9 via `use_figma` | — |

### Code Connect (same tools at all tiers)

| Operation | All Tiers |
|---|---|
| Get suggestions | `mcp__figma__get_code_connect_suggestions` |
| Add mapping | `mcp__figma__add_code_connect_map` |
| Publish | `mcp__figma__send_code_connect_mappings` |

---

## OFFICIAL Tier JS Equivalents

Paste these into `use_figma` calls when `ACTIVE_TIER = OFFICIAL`.
All extracted from figma-canvas-mcp source (`/Users/macpro/figma-canvas-mcp/dist/core/`).

### Phase 0b Health Scan (OFFICIAL)

```javascript
async function phase0b_official() {
  const pages = figma.root.children.map(p => ({ name: p.name, nodeCount: p.children.length }));
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const vars = await figma.variables.getLocalVariablesAsync();
  const varGroups = [...new Set(vars.map(v => v.name.split('/')[0]))].sort();
  const collectionNames = collections.map(c => ({
    name: c.name, modeCount: c.modes.length, varCount: c.variableIds.length
  }));
  const textStyles = (await figma.getLocalTextStylesAsync()).map(s => s.name);
  const effectStyles = (await figma.getLocalEffectStylesAsync()).map(s => s.name);
  const compPage = figma.root.children.find(p =>
    p.name.includes('Components') || p.name.includes('\u{1F4E6}')
  );
  const componentSets = compPage
    ? compPage.findAllWithCriteria({ types: ['COMPONENT_SET'] }).map(s => s.name)
    : [];
  const metaColl = collections.find(c => c.name === '_Meta');
  return {
    tier: 'OFFICIAL',
    pages, collectionNames, varGroups,
    textStyles: textStyles.length,
    effectStyles: effectStyles.length,
    componentSets,
    hasVersioning: !!metaColl,
    health: null,
    note: 'OFFICIAL tier — weighted health metrics unavailable (Canvas Bridge required)'
  };
}
return phase0b_official();
```

### Batch Create Variables (OFFICIAL equivalent of `figma_batch_create_variables`)

> Note: This loops sequentially. Expect ~50× slower than the native batch tool on large sets.
> Warn user if creating >20 variables in OFFICIAL tier.

```javascript
// Replace COLLECTION_ID and VARIABLES_ARRAY before calling
const collectionId = "__COLLECTION_ID__";
const variables = __VARIABLES_ARRAY__;

const VALID_TYPES = ['COLOR', 'FLOAT', 'STRING', 'BOOLEAN'];

function hexToRgba(hex) {
  hex = hex.replace('#', '');
  if (hex.length === 3) hex = hex.split('').map(c => c + c).join('');
  if (!/^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$/.test(hex))
    throw new Error('Invalid hex color: #' + hex);
  return {
    r: parseInt(hex.substring(0, 2), 16) / 255,
    g: parseInt(hex.substring(2, 4), 16) / 255,
    b: parseInt(hex.substring(4, 6), 16) / 255,
    a: hex.length === 8 ? parseInt(hex.substring(6, 8), 16) / 255 : 1
  };
}

const collection = await figma.variables.getVariableCollectionByIdAsync(collectionId);
if (!collection) return { created: 0, failed: variables.length, error: 'Collection not found: ' + collectionId };

const results = [];
for (const v of variables) {
  try {
    if (!VALID_TYPES.includes(v.resolvedType))
      throw new Error('Invalid resolvedType: ' + v.resolvedType + '. Must be one of: ' + VALID_TYPES.join(', '));
    const variable = figma.variables.createVariable(v.name, collection, v.resolvedType);
    if (v.description) variable.description = v.description;
    if (v.valuesByMode) {
      for (const [modeId, value] of Object.entries(v.valuesByMode)) {
        const processed = v.resolvedType === 'COLOR' && typeof value === 'string'
          ? hexToRgba(value) : value;
        variable.setValueForMode(modeId, processed);
      }
    }
    results.push({ success: true, name: v.name, id: variable.id });
  } catch (err) {
    results.push({ success: false, name: v.name, error: String(err) });
  }
}
return {
  created: results.filter(r => r.success).length,
  failed: results.filter(r => !r.success).length,
  results
};
```

### Setup Design Tokens (OFFICIAL equivalent of `figma_setup_design_tokens`)

```javascript
// Replace COLLECTION_NAME, MODE_NAMES, and TOKEN_DEFS before calling
// TOKEN_DEFS format: [{ name, resolvedType, description?, values: { ModeName: value } }]
// COLOR values: hex strings '#RRGGBB' | FLOAT values: numbers | STRING: strings
const collectionName = "__COLLECTION_NAME__";
const modeNames = __MODE_NAMES__;
const tokenDefs = __TOKEN_DEFS__;

const VALID_TYPES = ['COLOR', 'FLOAT', 'STRING', 'BOOLEAN'];

if (!Array.isArray(modeNames) || modeNames.length === 0)
  throw new Error('modeNames must be a non-empty array, e.g. ["Light", "Dark"]');

function hexToRgba(hex) {
  hex = hex.replace('#', '');
  if (hex.length === 3) hex = hex.split('').map(c => c + c).join('');
  if (!/^[0-9A-Fa-f]{6}$|^[0-9A-Fa-f]{8}$/.test(hex))
    throw new Error('Invalid hex color: #' + hex);
  return {
    r: parseInt(hex.substring(0, 2), 16) / 255,
    g: parseInt(hex.substring(2, 4), 16) / 255,
    b: parseInt(hex.substring(4, 6), 16) / 255,
    a: hex.length === 8 ? parseInt(hex.substring(6, 8), 16) / 255 : 1
  };
}

const collection = figma.variables.createVariableCollection(collectionName);
const modeMap = {};
const defaultModeId = collection.modes[0].modeId;
collection.renameMode(defaultModeId, modeNames[0]);
modeMap[modeNames[0]] = defaultModeId;
for (let i = 1; i < modeNames.length; i++) {
  modeMap[modeNames[i]] = collection.addMode(modeNames[i]);
}

const results = [];
for (const t of tokenDefs) {
  try {
    if (!VALID_TYPES.includes(t.resolvedType))
      throw new Error('Invalid resolvedType: ' + t.resolvedType + '. Must be one of: ' + VALID_TYPES.join(', '));
    const variable = figma.variables.createVariable(t.name, collection, t.resolvedType);
    if (t.description) variable.description = t.description;
    const modeWarnings = [];
    for (const [modeName, value] of Object.entries(t.values)) {
      const modeId = modeMap[modeName];
      if (!modeId) {
        // Warn but don't abort — token created but missing this mode's value
        modeWarnings.push('Unknown mode "' + modeName + '" for token "' + t.name + '" — value skipped');
        continue;
      }
      variable.setValueForMode(modeId,
        t.resolvedType === 'COLOR' && typeof value === 'string' ? hexToRgba(value) : value
      );
    }
    results.push({ success: true, name: t.name, id: variable.id, warnings: modeWarnings });
  } catch (err) {
    results.push({ success: false, name: t.name, error: String(err) });
  }
}
const warnings = results.flatMap(r => r.warnings || []);
return {
  collectionId: collection.id,
  collectionName,
  modes: modeMap,
  created: results.filter(r => r.success).length,
  failed: results.filter(r => !r.success).length,
  results,
  warnings  // surface all mode-mismatch warnings to the caller
};
```

### Basic Audit (OFFICIAL equivalent — no scoring dashboard)

> Degradation: Raw coverage counts only. No maturity tier, no weighted score,
> no WCAG contrast resolution, no variable-chain validation.
> Surface this notice to user alongside results.

```javascript
const nodes = figma.currentPage.findAll(n => 'fills' in n && Array.isArray(n.fills) && n.fills.length > 0);
let hardcodedFills = 0, boundFills = 0, gradientFills = 0;
const hardcodedColorSet = new Set();

for (const n of nodes) {
  if (!n.visible) continue;
  for (const fill of n.fills) {
    if (fill.type === 'SOLID') {
      if (fill.boundVariables?.color) {
        boundFills++;
      } else {
        hardcodedFills++;
        const { r, g, b } = fill.color;
        hardcodedColorSet.add(
          '#' + [r, g, b].map(v => Math.round(v * 255).toString(16).padStart(2, '0')).join('')
        );
      }
    } else if (fill.type?.startsWith('GRADIENT')) {
      gradientFills++; // counted separately — gradients can't be bound to variables in Figma
    }
  }
}

const textNodes = figma.currentPage.findAllWithCriteria({ types: ['TEXT'] });
let boundTexts = 0, hardcodedTexts = 0;
for (const n of textNodes) {
  if (!n.visible) continue;
  (n.textStyleId || n.boundVariables?.fontSize) ? boundTexts++ : hardcodedTexts++;
}

const fillCoverage = boundFills / Math.max(1, boundFills + hardcodedFills);
const textCoverage = boundTexts / Math.max(1, boundTexts + hardcodedTexts);

return {
  tier: 'OFFICIAL',
  degradationNotice: 'Simplified audit — no scoring dashboard, no maturity tier, no WCAG contrast chain resolution',
  pageScoped: figma.currentPage.name,
  fillCoverage: Math.round(fillCoverage * 100) + '%',
  hardcodedFills,
  boundFills,
  gradientFills,
  uniqueHardcodedColors: hardcodedColorSet.size,
  hardcodedColorInventory: [...hardcodedColorSet].slice(0, 30),
  textCoverage: Math.round(textCoverage * 100) + '%',
  hardcodedTexts,
  boundTexts
};
```

### Basic Lint (OFFICIAL equivalent — no variable-chain contrast)

> Degradation: Detects hardcoded values and detached instances only.
> Does NOT resolve variable alias chains for WCAG contrast calculation.

```javascript
const findings = [];
const nodes = figma.currentPage.findAll(() => true);

for (const n of nodes) {
  if (!n.visible) continue;

  // Hardcoded color check
  if ('fills' in n && Array.isArray(n.fills)) {
    for (const fill of n.fills) {
      if (fill.type === 'SOLID' && !fill.boundVariables?.color) {
        const { r, g, b } = fill.color;
        const hex = '#' + [r, g, b].map(v => Math.round(v * 255).toString(16).padStart(2, '0')).join('');
        findings.push({ nodeId: n.id, nodeName: n.name, severity: 'warning', rule: 'hardcoded-fill', message: `Hardcoded fill: ${hex}` });
      }
    }
  }

  // Detached instance check
  if (n.type === 'INSTANCE' && n.mainComponent === null) {
    findings.push({ nodeId: n.id, nodeName: n.name, severity: 'error', rule: 'detached-instance', message: 'Instance detached from main component' });
  }

  // Touch target check (interactive frames)
  if (n.type === 'FRAME' && n.reactions?.length > 0) {
    const { width, height } = n;
    if (width < 44 || height < 44) {
      findings.push({ nodeId: n.id, nodeName: n.name, severity: 'warning', rule: 'touch-target', message: `Touch target too small: ${Math.round(width)}×${Math.round(height)}px (min 44×44)` });
    }
  }
}

const summary = {
  totalFindings: findings.length,
  errorCount: findings.filter(f => f.severity === 'error').length,
  warningCount: findings.filter(f => f.severity === 'warning').length
};

return {
  tier: 'OFFICIAL',
  degradationNotice: 'Basic lint only — no WCAG contrast resolution (Canvas Bridge required for variable-chain contrast checks)',
  findings: findings.slice(0, 100),
  summary
};
```

---

## Tier Capability Matrix

| Capability | CANVAS_FULL | OFFICIAL | REST_ONLY |
|---|---|---|---|
| Protocols 1–7, 12–16 | ✓ full | ✓ adapted | Read-only subset |
| Protocols 8–11 (audit/migration) | ✓ full (via `figma-ds-modernization.md`) | ✓ adapted (JS equivalents) | Audit read only |
| Native audit dashboard | ✓ | — | — |
| WCAG contrast (variable-aware) | ✓ | — | — |
| Batch variable creation (fast) | ✓ 1 call | ~ JS loop | — |
| Token browser UI | ✓ | — | — |
| Console log access | ✓ | — | — |
| All write operations | ✓ | ✓ via `use_figma` | — |
| Token setup | ✓ | ✓ via JS equivalent | — |
| Component instantiation | ✓ | ✓ via JS equivalent | — |
| Read file / components / styles | ✓ | ✓ | ✓ |
| Code Connect | ✓ | ✓ | ✓ |

---

## Mid-Session Tier Degradation

If Canvas Bridge disconnects during a session:

1. Re-run Phase 0a probe cascade
2. Update `ACTIVE_TIER`
3. Notify user: "Canvas Bridge disconnected — downgraded to OFFICIAL tier"
4. Continue with adapted toolset
5. Only stop if `ACTIVE_TIER = NONE`

**Do not stop on tier degradation. Only stop on NONE.**
