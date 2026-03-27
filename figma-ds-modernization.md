# figma-ds-modernization — Existing Design System Protocols

**Version**: 1.2.0 | **Used by**: `figma-mcp-design-architect` v1.8.0+

Always read relevant sections before executing work. Load only the protocol(s) you need.

## Table of Contents

- [Protocol 8: Design System Maturity Assessment](#protocol-8-design-system-maturity-assessment)
- [Protocol 9: Token Migration — Strangler Fig](#protocol-9-token-migration--strangler-fig)
- [Protocol 10: Deprecation + Sunset](#protocol-10-deprecation--sunset)
- [Protocol 11: Component Health Repair](#protocol-11-component-health-repair)
- [Shared Helpers](#shared-helpers)
- [Integration Notes](#integration-notes)

---

## Protocol 8: Design System Maturity Assessment

**Trigger**: User asks to "audit", "health check", "assess", or "how mature is" an existing file.

**Invariant**: Phase 0b must have run first. The `health` object it returns is the input to this protocol.

### Step 1 — Read Phase 0b health output

The `health` object from Phase 0b contains:
- `maturityTier`, `overallScore` — pre-computed
- `fillCoverage`, `hardcodedFills`, `uniqueHardcodedColors`
- `textCoverage`, `hardcodedTexts`
- `instanceHealth`, `detachedInstances`, `totalInstances`
- `gradientFills`, `gradientNote` — gradient fills not counted in score; surface this

### Step 2 — Apply 4-tier maturity model

| Tier | Score | Characteristics |
|------|-------|----------------|
| 1 — Fragmented | < 30% | Hardcoded everywhere, no collections, no component system |
| 2 — Building | 30–59% | Some token collections, partial bindings, inconsistent naming |
| 3 — Adopting | 60–84% | Primitive + Semantic layers, >60% solid fill coverage, few detached instances |
| 4 — Mature | ≥ 85% | Full P→S→C layers, multi-mode, versioned, near-zero debt, `unscopedPrimitives = 0` |

**Note on score scope**: The score covers solid fills, text styles, and instance health on the
current page only. It does not measure: stroke coverage, spacing token adoption, effect style
coverage, or multi-mode completeness. State this limitation clearly in the report.

### Step 3 — Produce the modernization roadmap using the 6-R framework

| Strategy | When to apply |
|----------|--------------|
| **Retain** | Token collections and components already correctly bound — keep as-is |
| **Retire** | Orphaned/deprecated tokens with zero current bindings — safe to delete |
| **Rehost** | Hardcoded hex → variable binding without renaming (fastest ROI) — use Protocol 9 |
| **Replatform** | Rename tokens to P→S→C naming without changing values |
| **Refactor** | Redesign full token architecture (Primitive → Semantic → Component) |
| **Replace** | Rebuild a specific component set from scratch with fresh token bindings |

**If the file uses an unknown naming convention** (Material Design 3, IBM Carbon, Atlassian,
Spectrum, Polaris): use WebSearch to look up that system's token structure before mapping or
renaming. Do not guess.

### Step 4 — Output the health report

```
## Design System Health Report (current page: [pageName])

**Maturity Tier**: [N — Label] ([score]%)

| Dimension        | Score | Finding |
|-----------------|-------|---------|
| Solid fill coverage | XX% | N hardcoded fills (M unique colors) |
| Text style coverage | XX% | N text nodes not bound to styles |
| Component health    | XX% | N detached instances out of M total |

**Not measured**: stroke bindings, spacing tokens, effect styles, multi-mode coverage.

**Gradient fills**: [N detected — not counted in score. Gradient stops require manual
variable binding via a different mechanism than solid fills.]

**Modernization Roadmap** (prioritized by ROI):
1. [HIGH/MED/LOW] [6-R strategy] — [Protocol N] — [~N nodes affected]
2. ...

**Do not modify anything until you confirm this plan.**
What would you like to start with?
```

### Step 5 — Wait for user confirmation before any write operation.

### Step 6 — Persist health metrics + log the audit

After outputting the health report (and before waiting for user confirmation), run a
`figma_execute` block to persist metrics and record the audit in the changelog:

```javascript
// Copy logTaskCompletion and persistHealthToMeta from Shared Helpers above
// health = the health object from Phase 0b
const _report = { phase: 'Protocol 8 — Maturity Assessment', created: [], skipped: [], failed: [], warnings: [], blocked: null };
await persistHealthToMeta(health); // writes audit/* vars to _Meta collection
await logTaskCompletion(_report);  // writes to plugin data + AUDIT_TRAIL + last-modified
return _report;
```

---

## Protocol 9: Token Migration — Strangler Fig

**Trigger**: User wants to migrate hardcoded fills to live variable bindings.

**Principle**: Incremental — never cold-turkey. Process highest-frequency colors first.
Bind in-place. Never delete nodes, never recreate components.

---

### Phase M0 — Page Selection (skip if target page is already active)

Before surveying, identify which pages have hardcoded fills and which to skip. Run this
read-only scan across all pages:

```javascript
async function surveyAllPages() {
  function toHex(r,g,b) { return '#'+[r,g,b].map(v=>Math.round(v*255).toString(16).padStart(2,'0')).join(''); }
  const summary = [];
  for (const page of figma.root.children) {
    const nodes = page.findAll(n => n.visible !== false && 'fills' in n);
    const typeCounts = {};
    let hardcoded = 0;
    for (const n of nodes) {
      for (const f of (n.fills || [])) {
        if (f.type === 'SOLID' && !f.boundVariables?.color) {
          hardcoded++;
          typeCounts[n.type] = (typeCounts[n.type] || 0) + 1;
        }
      }
    }
    summary.push({ page: page.name, hardcodedFills: hardcoded, nodeTypes: typeCounts });
  }
  return summary;
}
return surveyAllPages();
```

Present the table to the user. Ask which page(s) to process. Navigate to target page before M1.

> **Skip pages used for token swatch display** (e.g. pages named '🎨 Tokens', 'Foundations',
> 'Color Palette'). Primitive fills inside display swatches are intentional — binding them
> to semantic tokens would break the documentation.

---

### Phase M1 — Survey (read-only)

```javascript
// Survey all hardcoded SOLID fills on the current page
// Returns frequency + node-type breakdown per hex — critical for M2 semantic mapping
async function surveyHardcodedFills() {
  const freq = {};
  const types = {}; // per hex: { FRAME: N, TEXT: N, COMPONENT_SET: N, ... }
  function toHex(r,g,b) { return '#'+[r,g,b].map(v=>Math.round(v*255).toString(16).padStart(2,'0')).join(''); }
  const allNodes = figma.currentPage.findAll(n => n.visible !== false);
  for (const node of allNodes) {
    if (!('fills' in node) || !Array.isArray(node.fills)) continue;
    for (const fill of node.fills) {
      if (fill.type === 'SOLID' && !fill.boundVariables?.color) {
        const hex = toHex(fill.color.r, fill.color.g, fill.color.b);
        freq[hex] = (freq[hex] || 0) + 1;
        if (!types[hex]) types[hex] = {};
        types[hex][node.type] = (types[hex][node.type] || 0) + 1;
      }
    }
  }
  return Object.entries(freq).sort((a,b) => b[1]-a[1])
    .map(([hex,count]) => ({ hex, count, nodeTypes: types[hex] }));
}
return surveyHardcodedFills();
```

The `nodeTypes` breakdown is essential for correct semantic mapping in M2:
- `TEXT` nodes → semantic text color token (`text/primary`, `text/tertiary`, etc.)
- `FRAME` nodes → semantic background or border token
- `COMPONENT_SET` / `COMPONENT` → structural fills — **will be skipped in M3** (see M3 note)

Present the sorted list to the user. Do NOT proceed to Phase M2 until user acknowledges.

---

### Phase M2 — Map (color matching with defined tolerance)

For each unique hex value:

1. Retrieve all existing color variables via `figma_get_variables`.
2. **Resolve alias chains first** — semantic tokens store `{ type: 'VARIABLE_ALIAS', id }` in
   `valuesByMode`, not an `{r,g,b}` value. Without resolution, the color-match helper silently
   skips all semantic tokens and only matches primitives. Use `resolveAlias()` (see Shared Helpers)
   to walk the chain to a concrete `{r,g,b,a}` value for every variable before comparing.
   **Prefer semantic token matches over primitive matches** when both are within tolerance —
   binding to a semantic token is the correct outcome; binding to a primitive is a stop-gap.
3. Run the color-match helper below to find the closest match within tolerance.
4. If match found: propose mapping `hex → existingVariable` (prefer semantic > primitive).
5. If no match: propose creating a new primitive `color/primitive/<name>`.
6. Present the full mapping table to the user for review before binding.

```javascript
// Color-match helper — compares in HSL space, tolerance = ±5 HSL-L units
// Color space: HSL (H: 0-360, S: 0-100, L: 0-100)
// Tolerance thresholds: |ΔL| ≤ 5, |ΔS| ≤ 10, |ΔH| ≤ 15 (or hue wraps within 345°)
function hexToRgb01(hex) {
  return {
    r: parseInt(hex.slice(1,3),16)/255,
    g: parseInt(hex.slice(3,5),16)/255,
    b: parseInt(hex.slice(5,7),16)/255,
  };
}
function rgbToHsl(r,g,b) {
  const max = Math.max(r,g,b), min = Math.min(r,g,b);
  const l = (max+min)/2;
  const s = max===min ? 0 : l<0.5 ? (max-min)/(max+min) : (max-min)/(2-max-min);
  let h = 0;
  if (max!==min) {
    if (max===r) h=((g-b)/(max-min)+(g<b?6:0))/6;
    else if (max===g) h=((b-r)/(max-min)+2)/6;
    else h=((r-g)/(max-min)+4)/6;
  }
  return { h: h*360, s: s*100, l: l*100 };
}
function colorsMatch(hex1, hex2) {
  const c1 = rgbToHsl(...Object.values(hexToRgb01(hex1)));
  const c2 = rgbToHsl(...Object.values(hexToRgb01(hex2)));
  const hdiff = Math.abs(c1.h - c2.h);
  return Math.abs(c1.l - c2.l) <= 5
    && Math.abs(c1.s - c2.s) <= 10
    && (hdiff <= 15 || hdiff >= 345);
}

// Usage: call for each (hardcodedHex, existingVariableHex) pair
// colorsMatch('#1A6EFF', '#1A70FF') → true (within tolerance)
// colorsMatch('#1A6EFF', '#FF0000') → false
```

---

### Phase M3 — Bind (write phase — requires Phase Wrapper)

**Batched pattern (preferred)** — process all hex→variable mappings in one call with per-mapping
try/catch. Fall back to one-per-call only for files with >10,000 nodes where timeouts occur.

```javascript
// Batched bind — replace MAPPINGS array with actual values from Phase M2
// Each entry: { hex: '#rrggbb', varId: 'VariableID:...' }
const MAPPINGS = [
  // { hex: '#a6a1b8', varId: 'VariableID:8:2160' },
  // { hex: '#000000', varId: 'VariableID:8:2245' },
  // ...
];

const _report = { phase: 'M3 — Batch Bind', created: [], skipped: [], failed: [], warnings: [], blocked: null };

// SKIP_TYPES: COMPONENT_SET and COMPONENT node fills are structural (variant container backgrounds).
// Binding base/white or base/black to these causes white/black boxes around component grids.
// These nodes are intentionally excluded. To include them, remove from SKIP_TYPES explicitly.
const SKIP_TYPES = new Set(['COMPONENT_SET', 'COMPONENT']);

function toHex(r,g,b) { return '#'+[r,g,b].map(v=>Math.round(v*255).toString(16).padStart(2,'0')).join(''); }
const allNodes = figma.currentPage.findAll(n => n.visible !== false);

for (const { hex: targetHex, varId } of MAPPINGS) {
  let variable;
  try {
    variable = await figma.variables.getVariableByIdAsync(varId);
    if (!variable) { _report.failed.push({ name: targetHex, reason: 'Variable ID not found: ' + varId }); continue; }
  } catch(e) { _report.failed.push({ name: targetHex, reason: e.message }); continue; }

  for (const node of allNodes) {
    if (SKIP_TYPES.has(node.type)) { continue; } // skip structural component frames
    if (!('fills' in node) || !Array.isArray(node.fills)) continue;
    try {
      let modified = false;
      const newFills = node.fills.map(fill => {
        if (fill.type !== 'SOLID' || fill.boundVariables?.color) return fill;
        if (toHex(fill.color.r, fill.color.g, fill.color.b) !== targetHex) return fill;
        modified = true;
        return figma.variables.setBoundVariableForPaint(fill, 'color', variable);
      });
      if (modified) { node.fills = newFills; _report.created.push(node.name + ' → ' + variable.name); }
    } catch(e) { _report.failed.push({ name: node.name, reason: e.message }); }
  }
}

return { total: _report.created.length, failed: _report.failed.length, details: _report };
```

**Rules**:
- Process highest-frequency hex first (maximum coverage per operation).
- Batch all mappings in one call — faster and produces one structured result.
- `COMPONENT_SET` and `COMPONENT` nodes are skipped by default — their fills are structural.
- If `total = 0`: stop. Verify you are on the correct page. Do not retry blind.
- If `failed` array is non-empty: surface failures before proceeding to M3.5.

---

### Phase M3.5 — Semantic Contextualization (run after M3 if any fills were bound to primitives)

The same primitive value can have different semantic intent depending on node type and context.
M3 binds to the closest color match — M3.5 upgrades primitive bindings to correct semantic tokens.

**When to run**: If M3 bound any fills to `Color/Primitives` variables (not semantic tokens).

**Step 1** — Audit newly bound primitives, grouped by `(primitive name, node type)`:

```javascript
async function auditPrimitiveBindings(primitiveCollectionName) {
  const colls = await figma.variables.getLocalVariableCollectionsAsync();
  const vars = await figma.variables.getLocalVariablesAsync();
  const primColl = colls.find(c => c.name === primitiveCollectionName);
  if (!primColl) return { error: 'Collection not found: ' + primitiveCollectionName };
  const primIds = new Set(vars.filter(v => v.variableCollectionId === primColl.id).map(v => v.id));

  const groups = {};
  const allNodes = figma.currentPage.findAll(n => n.visible !== false && 'fills' in n);
  for (const node of allNodes) {
    for (const fill of (node.fills || [])) {
      if (fill.type !== 'SOLID' || !fill.boundVariables?.color) continue;
      const varId = fill.boundVariables.color.id;
      if (!primIds.has(varId)) continue;
      const v = vars.find(x => x.id === varId);
      const key = (v?.name || varId) + '|' + node.type;
      if (!groups[key]) groups[key] = { primName: v?.name, nodeType: node.type, count: 0 };
      groups[key].count++;
    }
  }
  return Object.values(groups).sort((a,b) => b.count - a.count);
}
return auditPrimitiveBindings('Color/Primitives');
```

**Step 2** — Present disambiguation table to user. Example:

```
neutral/400 used as:
  54× TEXT  → suggest: text/tertiary (annotation labels) or text/disabled?
  3×  FRAME → suggest: border/strong (stroke-only frames)?
```

Ask user to confirm semantic mapping per `(primitive, nodeType)` row. Never auto-remap.

**Step 3** — Apply confirmed remaps:

```javascript
// Remap fills on nodes of a specific type from primitiveVarId → semanticVarId
async function remapByContext(primitiveVarId, nodeType, semanticVarId) {
  const semVar = await figma.variables.getVariableByIdAsync(semanticVarId);
  if (!semVar) return { error: 'Semantic variable not found: ' + semanticVarId };
  let fixed = 0;
  const SKIP_TYPES = new Set(['COMPONENT_SET', 'COMPONENT']);
  const allNodes = figma.currentPage.findAll(n => n.visible !== false && n.type === nodeType && 'fills' in n);
  for (const node of allNodes) {
    if (SKIP_TYPES.has(node.type)) continue;
    const newFills = node.fills.map(fill => {
      if (fill.type !== 'SOLID' || fill.boundVariables?.color?.id !== primitiveVarId) return fill;
      fixed++;
      return figma.variables.setBoundVariableForPaint(fill, 'color', semVar);
    });
    node.fills = newFills;
  }
  return { fixed, semantic: semVar.name, nodeType };
}
// Call once per confirmed (primitiveVarId, nodeType, semanticVarId) row
```

---

### Phase M4 — Verify

1. Re-run Phase 0b (or a fresh survey of hardcoded fills for the target page).
2. Compare `fillCoverage` before vs. after Phase M3.
3. Take a screenshot. Visually confirm the design is intact (colors should look unchanged).
4. Report coverage delta to user. Ask whether to continue to the next hex.
5. Log the completed migration — run a `figma_execute` block:

```javascript
// Copy logTaskCompletion from Shared Helpers
const _report = {
  phase: 'Protocol 9 — Token Migration (Strangler Fig)',
  created: [ /* bound node names from all M3 phases */ ],
  skipped: [], failed: [], warnings: [], blocked: null,
};
await logTaskCompletion(_report);
return _report;
```

6. **Enforce layer boundaries** — lock primitive variables from the design panel picker so
   designers cannot accidentally reapply them after migration. The `_` prefix on a collection
   name only hides from library publishing, NOT the local design panel. `scopes = []` is the
   correct mechanism (per [Plugin API docs](https://developers.figma.com/docs/plugins/api/properties/Variable-scopes/)):

```javascript
// Lock primitives: hide from all design panel pickers (fill, stroke, effect)
// Alias chains from semantic tokens still resolve correctly — only the UI picker is hidden
async function lockPrimitiveScopes(primitiveCollectionName) {
  const colls = await figma.variables.getLocalVariableCollectionsAsync();
  const vars  = await figma.variables.getLocalVariablesAsync();
  const primColl = colls.find(c => c.name === primitiveCollectionName);
  if (!primColl) return { skipped: 'Collection not found: ' + primitiveCollectionName };
  const primVars = vars.filter(v => v.variableCollectionId === primColl.id);
  let locked = 0, alreadyLocked = 0;
  for (const v of primVars) {
    if (v.scopes.length === 0) { alreadyLocked++; continue; }
    v.scopes = [];
    locked++;
  }
  return { locked, alreadyLocked, total: primVars.length };
}
return lockPrimitiveScopes('Color/Primitives'); // pass your actual collection name
```

---

## Protocol 10: Deprecation + Sunset

**Trigger**: User wants to clean up stale, unused, or explicitly deprecated tokens.

**Deprecation naming convention** (`_successor` annotation):
- Deprecated tokens must have their Figma variable `description` field set to:
  `_successor: color/semantic/brand-primary`
- Where the value after `_successor:` is the **full name** of the replacement variable.
- If no successor exists, the description should say `_successor: none — safe to delete`.
- Tokens without this annotation are NOT considered deprecated by Phase D1 — they are unknown.

---

### Phase D1 — Identify deprecated tokens

```javascript
async function findDeprecatedTokens() {
  const vars = await figma.variables.getLocalVariablesAsync();
  const deprecated = vars.filter(v =>
    v.name.startsWith('_deprecated/') ||
    v.name.includes('/deprecated/') ||
    v.name.startsWith('_old/') ||
    v.name.startsWith('_legacy/')
  );
  return deprecated.map(v => ({
    id: v.id, name: v.name, resolvedType: v.resolvedType,
    successor: (v.description || '').match(/_successor:\s*(.+)/)?.[1]?.trim() || null,
  }));
}
return findDeprecatedTokens();
```

Report the list to user. For each token, show: name, type, successor (if any).

---

### Phase D2 — Find nodes still bound to deprecated tokens (fills AND strokes)

```javascript
// Takes array of deprecated variable IDs, returns all nodes still bound to them
async function findBoundToDeprecated(deprecatedIds) {
  const idSet = new Set(deprecatedIds);
  const affected = [];
  const allNodes = figma.currentPage.findAll();
  for (const node of allNodes) {
    // Check fills
    if ('fills' in node && Array.isArray(node.fills)) {
      for (const fill of node.fills) {
        if (fill.boundVariables?.color && idSet.has(fill.boundVariables.color.id)) {
          affected.push({ nodeId: node.id, nodeName: node.name, binding: 'fill', variableId: fill.boundVariables.color.id });
        }
      }
    }
    // Check strokes (fills-only check would miss border color bindings)
    if ('strokes' in node && Array.isArray(node.strokes)) {
      for (const stroke of node.strokes) {
        if (stroke.boundVariables?.color && idSet.has(stroke.boundVariables.color.id)) {
          affected.push({ nodeId: node.id, nodeName: node.name, binding: 'stroke', variableId: stroke.boundVariables.color.id });
        }
      }
    }
  }
  return affected;
}

// Invoke — pass deprecated IDs from Phase D1
const deprecated = /* Phase D1 result */;
return await findBoundToDeprecated(deprecated.map(v => v.id));
```

If `affected.length > 0`: do NOT delete. Show user which nodes are still bound.
If `affected.length === 0`: the token is safe to delete (Phase D4).

---

### Phase D3 — Remap (only if `_successor` is defined and not "none")

For each deprecated token that has a valid successor:
1. Retrieve successor variable by name using `figma_get_variables`.
2. For each affected node in Phase D2: rebind its fill/stroke to the successor variable.
3. Re-run Phase D2 to confirm bindings are zero before proceeding to Phase D4.

---

### Phase D4 — Delete (only after Phase D2 confirms zero bindings)

```javascript
async function deleteDeprecatedVariable(variableId) {
  const v = await figma.variables.getVariableByIdAsync(variableId);
  if (!v) return { skipped: variableId, reason: 'not found — already deleted' };
  const name = v.name;
  v.remove();
  return { deleted: variableId, name };
}
// Call once per variable — never batch deletions before verifying each one.
return await deleteDeprecatedVariable('VARIABLE_ID');
```

**Hard rule**: Never delete a variable that still has active bindings (fills or strokes).
Always run Phase D2 immediately before Phase D4, even if D2 ran recently.

After all deletions are complete, log the task:

```javascript
// Copy logTaskCompletion from Shared Helpers
const _report = {
  phase: 'Protocol 10 — Deprecation + Sunset',
  created: [], skipped: [],
  failed: [], // populate with any deletion failures
  warnings: [ /* variable names that were skipped due to active bindings */ ],
  blocked: null,
};
await logTaskCompletion(_report);
return _report;
```

---

## Protocol 11: Component Health Repair

**Trigger**: Phase 0b `health.detachedInstances > 0`, or user asks to repair component health.

---

### Phase C1 — Inventory detached instances

```javascript
async function inventoryDetached() {
  const instances = figma.currentPage.findAllWithCriteria({ types: ['INSTANCE'] });
  const detached = instances.filter(i => !i.mainComponent);
  return detached.map(i => ({
    id: i.id, name: i.name,
    x: Math.round(i.x), y: Math.round(i.y),
    width: Math.round(i.width), height: Math.round(i.height),
  }));
}
return inventoryDetached();
```

Present the list to user. Do NOT auto-delete or auto-reattach. Ask user to choose an
action for each instance (or apply the same action to all).

---

### Phase C2 — Rogue override audit

```javascript
// Finds instances with hardcoded fills on their children (potential unintended overrides)
async function auditRogueOverrides() {
  const instances = figma.currentPage.findAllWithCriteria({ types: ['INSTANCE'] });
  const rogues = [];
  for (const inst of instances) {
    if (!inst.mainComponent) continue; // skip detached — handled in C1
    for (const child of inst.findAll()) {
      if ('fills' in child && Array.isArray(child.fills)) {
        const hardcoded = child.fills.filter(f => f.type === 'SOLID' && !f.boundVariables?.color);
        if (hardcoded.length > 0) {
          rogues.push({
            instanceId: inst.id, instanceName: inst.name,
            childName: child.name, hardcodedFills: hardcoded.length,
          });
        }
      }
    }
  }
  return rogues;
}
return auditRogueOverrides();
```

**Important**: A hardcoded fill on an instance child may be an **intentional override**
(designer's decision) or an **unintentional override** (legacy hardcoded value from main
component that was never tokenized). Always surface these to the user — never auto-reset.

---

### Phase C3 — Repair options (present to user, execute only chosen option)

| Option | Risk | Code |
|--------|------|------|
| Reset overrides | Loses all intentional customizations | `instance.resetOverrides()` |
| Bind fills to variables | Safe, preserves design intent | Run Protocol 9 on instance children |
| Delete and reinstantiate | Loses all overrides, but restores library link | See below |
| Leave as-is, document | No change | Add note to _Meta audit trail |

**Delete and reinstantiate — position-preserving implementation**:

```javascript
// Reinstantiate a detached instance at its original position
async function reinstantiateComponent(instanceId) {
  const _report = { phase: 'C3 — Reinstantiate', created: [], skipped: [], failed: [], warnings: [], blocked: null };
  const instance = figma.getNodeById(instanceId);
  if (!instance || instance.type !== 'INSTANCE') {
    _report.blocked = 'Instance not found: ' + instanceId; return _report;
  }
  const mainComponent = instance.mainComponent;
  if (!mainComponent) {
    _report.blocked = 'No main component — library may be missing or renamed'; return _report;
  }
  // Capture position and parent before removal
  const { x, y, parent } = instance;
  const parentId = parent?.id;
  instance.remove();
  // mainComponent.createInstance() is the correct API — NOT figma.createInstance()
  const newInst = mainComponent.createInstance();
  newInst.x = x;
  newInst.y = y;
  if (parentId) {
    const parentNode = figma.getNodeById(parentId);
    if (parentNode && 'appendChild' in parentNode) parentNode.appendChild(newInst);
  }
  _report.created.push(newInst.name);
  return { ..._report, newInstanceId: newInst.id, restoredPosition: { x, y } };
}
return await reinstantiateComponent('INSTANCE_ID');
```

**Rule**: Always screenshot before AND after any component health repair to verify the design
is visually intact. After all repairs are complete, log the task:

```javascript
// Copy logTaskCompletion from Shared Helpers
const _report = {
  phase: 'Protocol 11 — Component Health Repair',
  created: [ /* names of reinstantiated/repaired instances */ ],
  skipped: [], failed: [],
  warnings: [ /* instances left as-is by user choice */ ],
  blocked: null,
};
await logTaskCompletion(_report);
return _report;
```

---

## Protocol 17: Documentation Panel Consistency Audit

**Trigger**: After any panel creation, modification, or documentation work. Before declaring any
documentation task complete.

**Why this matters**: Figma's own "Documentation That Drives Adoption" post establishes that
documentation must evolve consistently with the system — style drift between panels erodes
designer trust and adoption. NN/g Design Systems 101 confirms that visual inconsistency in
documentation "undermines the goal of design systems at scale." Multiple dedicated Figma plugins
(ComponentQA, Design System Linter Pro, Design System Compliance Checker) exist specifically to
catch this pattern — confirming it is a recognized, recurring failure mode.

**Principle**: All `Panel ·` frames must share the same surface treatment. One panel is the
canonical reference; all others must match it exactly. The reference panel is the first token
documentation panel built (typically `Panel · Color Primitives` or equivalent).

### Canonical panel treatment

| Property | Required binding | Never use |
|----------|-----------------|-----------|
| Background fill | `Color/Semantic → background/subtle` via `setBoundVariableForPaint` | Hardcoded hex, `neutral/900` primitive, or unbound fill |
| Corner radius (all 4 corners) | `Radius → radius/lg` via `setBoundVariable` × 4 | Hardcoded `cornerRadius`, single unified radius |
| Category label (e.g. "FORM CONTROLS") | `Color/Semantic → accent/primary` fill | Hardcoded purple, any primitive |
| Panel title (e.g. "Button") | `Color/Semantic → text/primary` fill | Hardcoded white, any primitive |
| Description text | `Color/Semantic → text/tertiary` fill | Hardcoded gray, `neutral/400` primitive |
| Section label text | `Color/Semantic → text/secondary` fill | Hardcoded gray |
| Divider lines | `Color/Semantic → border/default` fill | Hardcoded white (`base/white`) |
| Accent bar decorator | `Color/Semantic → accent/primary` fill | Hardcoded purple |

---

### Phase P1 — Scan (read-only)

```javascript
// Scan all Panel · frames on the current page for fill and radius consistency
// Compares each panel against the first panel (reference) or a named panel
async function scanPanelConsistency(referenceName) {
  const vars = await figma.variables.getLocalVariablesAsync();
  const panels = figma.currentPage.children.filter(n =>
    n.name.startsWith('Panel ·') && n.type === 'FRAME'
  );
  if (panels.length === 0) return { error: 'No Panel · frames found on current page' };

  const ref = referenceName
    ? panels.find(p => p.name === referenceName) || panels[0]
    : panels[0];

  function inspect(panel) {
    const fill = (panel.fills || [])[0];
    const fillVarId  = fill?.boundVariables?.color?.id || null;
    const fillName   = fillVarId ? (vars.find(v => v.id === fillVarId)?.name || fillVarId) : null;
    const fillHex    = (!fillVarId && fill?.type === 'SOLID')
      ? '#' + [fill.color.r, fill.color.g, fill.color.b]
          .map(v => Math.round(v * 255).toString(16).padStart(2,'0')).join('')
      : null;
    const radVarId   = panel.boundVariables?.topLeftRadius?.id || null;
    const radName    = radVarId ? (vars.find(v => v.id === radVarId)?.name || radVarId) : null;
    const radHardcoded = !radVarId ? panel.cornerRadius : null;
    return { fillName, fillHex, radName, radHardcoded };
  }

  const refProps = inspect(ref);
  const results = panels.map(panel => {
    const props = inspect(panel);
    const issues = [];
    if (props.fillName !== refProps.fillName)
      issues.push(`fill token: "${props.fillName || props.fillHex || 'none'}" ≠ ref "${refProps.fillName}"`);
    if (props.radName !== refProps.radName)
      issues.push(`radius binding: "${props.radName || ('hardcoded ' + props.radHardcoded) || 'none'}" ≠ ref "${refProps.radName}"`);
    return { name: panel.name, id: panel.id, issues, consistent: issues.length === 0 };
  });

  const bad = results.filter(r => !r.consistent);
  return {
    reference: ref.name, referenceProps: refProps,
    total: panels.length,
    consistent: panels.length - bad.length,
    inconsistentPanels: bad,
    note: bad.length === 0 ? 'All panels consistent ✓' : `${bad.length} panel(s) diverge from reference`,
  };
}
return scanPanelConsistency(null); // or pass 'Panel · Color Primitives' as reference
```

Present the scan results. If `inconsistentPanels.length > 0`, proceed to Phase P2.
If `consistent === total`, no action needed — skip to screenshot verification.

---

### Phase P2 — Fix (write phase)

Copies the reference panel's fill and radius bindings to all inconsistent panels.
Does NOT touch interior content — only the panel frame itself.

```javascript
async function fixPanelConsistency(referenceName) {
  const vars = await figma.variables.getLocalVariablesAsync();
  const _report = { phase: 'P17 — Panel Consistency Fix', created: [], skipped: [], failed: [], warnings: [], blocked: null };

  const panels = figma.currentPage.children.filter(n =>
    n.name.startsWith('Panel ·') && n.type === 'FRAME'
  );
  if (panels.length === 0) { _report.blocked = 'No Panel · frames found'; return _report; }

  const ref = referenceName
    ? panels.find(p => p.name === referenceName) || panels[0]
    : panels[0];

  // Extract reference fill variable
  const refFill      = (ref.fills || [])[0];
  const refFillVarId = refFill?.boundVariables?.color?.id;
  const refFillVar   = refFillVarId ? vars.find(v => v.id === refFillVarId) : null;
  const refFallback  = refFill?.color || { r: 0.2, g: 0.19, b: 0.22 };

  // Extract reference radius variable
  const refRadVarId  = ref.boundVariables?.topLeftRadius?.id;
  const refRadVar    = refRadVarId ? vars.find(v => v.id === refRadVarId) : null;

  if (!refFillVar) _report.warnings.push('Reference panel has no bound fill — fill fix skipped');
  if (!refRadVar)  _report.warnings.push('Reference panel has no bound radius — radius fix skipped');

  for (const panel of panels) {
    if (panel.id === ref.id) { _report.skipped.push(panel.name + ' [reference panel]'); continue; }
    try {
      if (refFillVar) {
        panel.fills = [figma.variables.setBoundVariableForPaint(
          { type: 'SOLID', color: { r: refFallback.r, g: refFallback.g, b: refFallback.b }, opacity: 1 },
          'color', refFillVar
        )];
      }
      if (refRadVar) {
        for (const prop of ['topLeftRadius','topRightRadius','bottomLeftRadius','bottomRightRadius']) {
          try { panel.setBoundVariable(prop, refRadVar); }
          catch(e) { _report.warnings.push(`${panel.name} ${prop}: ${e.message}`); }
        }
      }
      _report.created.push(panel.name);
    } catch(e) { _report.failed.push({ name: panel.name, reason: e.message }); }
  }
  return _report;
}
return fixPanelConsistency(null);
```

After Phase P2: re-run Phase P1 to confirm `inconsistentPanels = []`, then screenshot.

---

### Phase P3 — Text Hierarchy Scan (optional, run when text token drift is suspected)

Scans top-level TEXT nodes directly inside each panel frame for unbound or primitive fills.
Does not descend into component instances — only direct panel children.

```javascript
async function scanPanelTextHierarchy() {
  const colls = await figma.variables.getLocalVariableCollectionsAsync();
  const vars  = await figma.variables.getLocalVariablesAsync();
  const semColl = colls.find(c => c.name === 'Color/Semantic');
  const primColl = colls.find(c => c.name === 'Color/Primitives');
  const semIds  = new Set(semColl ? vars.filter(v => v.variableCollectionId === semColl.id).map(v => v.id) : []);
  const primIds = new Set(primColl ? vars.filter(v => v.variableCollectionId === primColl.id).map(v => v.id) : []);

  const panels = figma.currentPage.children.filter(n => n.name.startsWith('Panel ·') && n.type === 'FRAME');
  const drift = [];

  for (const panel of panels) {
    const textNodes = panel.findAll(n => n.type === 'TEXT');
    for (const t of textNodes) {
      const fill = (t.fills || [])[0];
      if (!fill || fill.type !== 'SOLID') continue;
      const varId = fill.boundVariables?.color?.id;
      if (!varId) {
        drift.push({ panel: panel.name, node: t.name, chars: t.characters?.slice(0,30), issue: 'unbound fill' });
      } else if (primIds.has(varId)) {
        const v = vars.find(x => x.id === varId);
        drift.push({ panel: panel.name, node: t.name, chars: t.characters?.slice(0,30), issue: `primitive: ${v?.name}` });
      }
      // semIds = correct — no issue
    }
  }

  return {
    total: drift.length,
    note: drift.length === 0 ? 'All panel text nodes use semantic tokens ✓' : `${drift.length} text node(s) with primitive or unbound fills`,
    drift: drift.slice(0, 50),
  };
}
return scanPanelTextHierarchy();
```

For any drifted text nodes, remap using `remapByContext()` from Protocol 9 M3.5.

---

## Shared Helpers

These utilities are used across protocols. Copy into any `figma_execute` block as needed.

```javascript
// Hex conversion
function toHex(r,g,b) { return '#'+[r,g,b].map(v=>Math.round(v*255).toString(16).padStart(2,'0')).join(''); }

// Validate a variable ID is still live (returns null if deleted)
async function resolveVar(id) {
  try { return await figma.variables.getVariableByIdAsync(id); }
  catch { return null; }
}

// Validate a stale alias binding — flag as broken_binding if variable no longer exists
async function checkBinding(fill) {
  if (!fill.boundVariables?.color) return 'unbound';
  const v = await resolveVar(fill.boundVariables.color.id);
  return v ? 'valid' : 'broken_binding';
}

// Resolve a variable's alias chain to its concrete {r,g,b,a} value
// Semantic tokens store VARIABLE_ALIAS in valuesByMode — this walks the chain.
// allVars: array from getLocalVariablesAsync(). modeId: optional, uses first mode if omitted.
// Required for Protocol 9 M2 color-matching: semantic tokens are invisible without this.
// Per official docs: resolveForConsumer(node) also works when a consuming node is available.
async function resolveAlias(varObj, allVars, modeId) {
  if (!varObj) return null;
  const resolveMode = modeId || Object.keys(varObj.valuesByMode)[0];
  const val = varObj.valuesByMode[resolveMode];
  if (!val) return null;
  if (val.type === 'VARIABLE_ALIAS') {
    const target = allVars.find(v => v.id === val.id);
    if (!target) return null; // broken alias — variable was deleted
    return resolveAlias(target, allVars, null); // follow chain in target's default mode
  }
  return val; // concrete {r,g,b,a} or scalar
}
```

### `logTaskCompletion(report)` — three-layer completion logger

**Call at the end of the final write block of every task** (Protocol 1 addition).
Each layer is independently try/caught — a failure in one does not block the others.

```javascript
// Three-layer task completion logger
// Layer 1: shared plugin data  — machine-readable JSON history, survives file moves
// Layer 2: ⚙ AUDIT_TRAIL frame — human-visible appended text line on canvas
// Layer 3: _Meta/last-modified  — fast date stamp, surfaced in Phase 0b on next session
async function logTaskCompletion(report) {
  const NS = 'figma-ds-architect', KEY = 'changelog';

  // Layer 1 — shared plugin data (setSharedPluginData readable by any plugin with namespace)
  try {
    const log = JSON.parse(figma.root.getSharedPluginData(NS, KEY) || '[]');
    log.push({
      timestamp: new Date().toISOString(),
      phase:    report.phase   || '',
      created:  (report.created  || []).length,
      skipped:  (report.skipped  || []).length,
      failed:   (report.failed   || []).length,
      warnings: report.warnings  || [],
    });
    figma.root.setSharedPluginData(NS, KEY, JSON.stringify(log));
  } catch(e) { console.warn('logTaskCompletion L1:', e.message); }

  // Layer 2 — AUDIT_TRAIL frame (append one text line per task)
  try {
    const trail = figma.currentPage.findOne(n => n.name === '⚙ AUDIT_TRAIL' && n.type === 'FRAME');
    if (trail) {
      await figma.loadFontAsync({ family: 'Inter', style: 'Regular' });
      const line = figma.createText();
      line.fontName = { family: 'Inter', style: 'Regular' };
      line.fontSize = 11;
      const ts = new Date().toISOString().slice(0,16).replace('T',' ');
      const ph = (report.phase || 'unknown').slice(0,60);
      const c = (report.created||[]).length, f = (report.failed||[]).length;
      line.characters = `[${ts}] ${ph} | +${c} created | ${f} failed`;
      trail.appendChild(line);
    }
  } catch(e) { console.warn('logTaskCompletion L2:', e.message); }

  // Layer 3 — _Meta/last-modified variable (update date stamp if collection exists)
  try {
    const colls = await figma.variables.getLocalVariableCollectionsAsync();
    const metaColl = colls.find(c => c.name === '_Meta');
    if (metaColl) {
      const vars = await figma.variables.getLocalVariablesAsync();
      const lm = vars.find(v => v.variableCollectionId === metaColl.id && v.name === 'last-modified');
      if (lm) lm.setValueForMode(metaColl.defaultModeId, new Date().toISOString().slice(0,10));
    }
  } catch(e) { console.warn('logTaskCompletion L3:', e.message); }
}
```

### `persistHealthToMeta(health)` — Protocol 8 audit variable persistence

**Call after Protocol 8 health scan** to store computed metrics in `_Meta` as queryable variables.
Creates missing variables automatically (FLOAT for numbers, STRING for dates).

```javascript
// Persist health scan results to _Meta collection for fast future reads
// Variables created/updated: audit/fill-coverage, audit/overall-score,
//   audit/maturity-tier (1–4), audit/last-run (ISO date string)
async function persistHealthToMeta(health) {
  const colls = await figma.variables.getLocalVariableCollectionsAsync();
  const metaColl = colls.find(c => c.name === '_Meta');
  if (!metaColl) { console.warn('persistHealthToMeta: _Meta collection not found — skip'); return; }
  const vars = await figma.variables.getLocalVariablesAsync();
  const modeId = metaColl.defaultModeId;

  const updates = [
    { name: 'audit/fill-coverage',  type: 'FLOAT',  value: parseInt(health.fillCoverage)  || 0 },
    { name: 'audit/overall-score',  type: 'FLOAT',  value: parseInt(health.overallScore)  || 0 },
    { name: 'audit/maturity-tier',  type: 'FLOAT',  value: parseInt(health.maturityTier)  || 0 },
    { name: 'audit/last-run',       type: 'STRING', value: new Date().toISOString().slice(0,10) },
  ];

  for (const { name, type, value } of updates) {
    let v = vars.find(mv => mv.variableCollectionId === metaColl.id && mv.name === name);
    if (!v) v = figma.variables.createVariable(name, metaColl.id, type);
    v.setValueForMode(modeId, value);
  }
}
```

### Reading the changelog (query anytime)

```javascript
// Read full history from any figma_execute call
const raw = figma.root.getSharedPluginData('figma-ds-architect', 'changelog') || '[]';
const changelog = JSON.parse(raw);
// changelog[N] = { timestamp, phase, created, skipped, failed, warnings }
return { entries: changelog.length, last: changelog[changelog.length - 1] || null };
```

---

## Integration Notes

### Ordering with Universal Protocols (1–7)

These protocols do NOT replace Protocols 1–7. They run on top of them:
- Always apply Protocol 1 (Phase Wrapper) to any `figma_execute` write block.
- Always end write blocks with Protocol 3 (Structured Returns).
- Run Protocol 6 (Visual Validation Loop) after any bind or repair phase.
- Run Protocol 5 (Orphan Cleanup) only after token/component work is fully complete —
  NOT during migration, as intermediate audit nodes may be flagged as orphans.

### Correct execution order for a full modernization

1. Phase 0b health scan (always first)
2. Protocol 8: Maturity Assessment + roadmap (no writes)
3. User confirms roadmap
4. Protocol 9: Token Migration (Rehost — fastest ROI first)
5. Protocol 10: Deprecation Sunset (Retire — only after migration complete)
6. Protocol 11: Component Health Repair (only after token bindings stabilized)
7. Canvas Reflow + final screenshot

Never run Protocol 10 (deletion) before Protocol 9 (migration) — you may delete tokens
that are still needed for the migration mapping.
