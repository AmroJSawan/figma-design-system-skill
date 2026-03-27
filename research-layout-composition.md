# research-layout-composition — Grid Propagation & Compositional Hierarchy

**Version**: 1.0.0 | **Used by**: `figma-mcp-design-architect` v1.3.0+

This file answers one question: **when the design system foundation already defines a grid
and spacing scale, how do those tokens propagate upward through components, sections, and
full pages?** It covers the compositional hierarchy, context-aware token scoping, layout
guide application, the 2D Grid (Config 2025), and the audit for missing grid propagation.

Always read `research-responsive-adaptive-design.md` alongside this file — it holds the
canonical breakpoint table, Layout collection variable names, and responsive molecule rules.

---

## Table of Contents

1. [Compositional Hierarchy](#1-compositional-hierarchy)
2. [3-Context Token Scoping Rule](#2-3-context-token-scoping-rule)
3. [Grid Propagation Rule](#3-grid-propagation-rule)
4. [Layout Guides on Frames](#4-layout-guides-on-frames)
5. [2D Grid Auto Layout — Config 2025](#5-2d-grid-auto-layout--config-2025)
6. [Section Frame Pattern](#6-section-frame-pattern)
7. [Page Template Pattern](#7-page-template-pattern)
8. [Auto Layout Token Binding by Context](#8-auto-layout-token-binding-by-context)
9. [Composition Audit Scripts](#9-composition-audit-scripts)
10. [Context Decision Tree](#10-context-decision-tree)
11. [Critical API Rules for Layout](#11-critical-api-rules-for-layout)

---

## 1. Compositional Hierarchy

Five levels. Each level consumes the one below. Grid and spacing tokens are context-aware —
the same primitive value (e.g. 16px) means different things at different levels.

```
Level 5 — Page / Template
  Full viewport frame. Contains a stack of sections.
  Spacing context: page-level tokens (80-160px).
  Layout guide: full-width column grid (margin + gutter).
  Max-width container spans inside the page frame.

Level 4 — Section / Organism
  Full-width slice of a page (hero, features band, footer).
  Spacing context: section-level tokens (24-64px).
  Layout guide: 12-column column guide (same gutter as Layout collection).
  Container frame inside the section respects max-width.

Level 3 — Composition / Block
  Named content block inside a section (card row, stat group, nav links).
  Spacing context: section-level tokens for gaps, component-level for internal.
  Uses 2D Grid Auto Layout (Config 2025) OR nested Auto Layout.

Level 2 — Molecule / Component
  Functional UI unit (Button, Card, Input, Tag, Toggle).
  Spacing context: component-level tokens (4-16px for padding, 8-24px for gaps).
  Auto Layout internal. No layout guide.

Level 1 — Atom
  Single-property element (Icon, Label, Divider, Color Swatch).
  No Auto Layout spacing — size and fill only.
```

### Mapping to Figma frame types

| Level | Figma frame type | Contains | Naming pattern |
|-------|-----------------|----------|----------------|
| Page | Page (root) or top-level Frame | Section stacks | `Page · [Name]` |
| Section | Full-width Frame in page | Container + content | `Section · [Name]` |
| Composition/Block | Auto Layout frame in section | Component instances | `Block · [Name]` |
| Molecule | Component Set / Frame | Atoms + Auto Layout | `[ComponentName]` |
| Atom | Component / Vector / Text | Raw properties | `[AtomName]` |

### Important: breakpoint variants live at Section level, not Molecule

Molecules are internally responsive via Auto Layout sizing modes.
**Breakpoint variants (mobile/tablet/desktop layouts) belong on Section frames** — not
on individual molecules. A Section component can have `Breakpoint=Mobile/Desktop` variants
that rearrange the block layout, while the molecules inside adapt via FILL sizing.

---

## 2. 3-Context Token Scoping Rule

The foundation's `Spacing` collection defines one scale (4px increments). That same
scale is used at all three contexts — but different range bands apply per context.

### Band assignments (reference values; read actual names from Layout collection)

| Context | Token Band | Typical values | Applied to |
|---------|-----------|----------------|-----------|
| **Component** | `spacing/1` – `spacing/6` | 4px – 24px | Auto Layout padding, gaps inside molecules |
| **Section** | `spacing/6` – `spacing/16` | 24px – 64px | Gaps between blocks, section padding-y |
| **Page** | `spacing/16` – `spacing/32` | 64px – 128px+ | Gaps between sections, page padding-y |

### Lookup rule for new frames

Before setting any spacing value on a new frame, call:

```javascript
// Read Layout collection for the canonical spacing scale
const collections = await figma.variables.getLocalVariableCollectionsAsync();
const spacingColl = collections.find(c => c.name === 'Spacing');
const layoutColl  = collections.find(c => c.name === 'Layout');
if (!spacingColl) warn('Spacing collection not found — cannot apply context-aware tokens');
if (!layoutColl)  warn('Layout collection not found — cannot apply grid tokens');
```

Never guess token values. Always resolve from the collection.

---

## 3. Grid Propagation Rule

**The foundation already built the grid. Every frame above molecule level must use it.**

The Grid System panel (created by `figma-token-foundation`) contains the `Layout` collection
with these variables:

```
Layout collection variables:
  breakpoint/sm, breakpoint/md, breakpoint/lg, breakpoint/xl, breakpoint/2xl
  grid/columns        — default: 12
  grid/gutter         — per breakpoint (16, 24, 32px)
  grid/margin         — per breakpoint (16, 32, 80px)
  container/content   — max readable width (720px)
  container/xl        — max section width (1280px)
```

**Grid Propagation Rule**: Every Section frame and Page frame MUST have:
1. A layout guide (column grid) applied using the Layout collection values.
2. An inner Container frame with `maxWidth` = `container/xl` token value.
3. Auto Layout gap values bound to Spacing collection tokens at the appropriate band.

**Violation signal**: A Section frame wider than 640px with no `layoutGrids` is unfinished.

---

## 4. Layout Guides on Frames

> In May 2025, Figma renamed "layout grids" to "layout guides." The Plugin API property
> remains `layoutGrids` (synchronous — do NOT await).

### When to apply layout guides

| Frame type | Apply layout guide? | Pattern |
|-----------|--------------------|----|
| Page frame | Yes | COLUMNS, 12 col, margin + gutter from Layout collection |
| Section frame | Yes | COLUMNS, 12 col, same gutter |
| Container frame (inside section) | No | Constrained by maxWidth instead |
| Molecule / Block | No | Auto Layout handles internal spacing |

### Layout guide application — Plugin API

```javascript
// Apply a 12-column layout guide to a section or page frame
// gutterSize and offset must be resolved numeric values (variables can't bind directly)
function applyColumnGuide(frame, gutterPx, marginPx, columns = 12) {
  // NOTE: layoutGrids is synchronous — no await
  frame.layoutGrids = [
    {
      pattern: 'COLUMNS',
      alignment: 'STRETCH',
      count: columns,
      gutterSize: gutterPx,   // resolved value of grid/gutter token
      offset: marginPx,       // resolved value of grid/margin token
      visible: true,
      color: { r: 0.27, g: 0.27, b: 1, a: 0.06 }, // subtle blue guide
    }
  ];
}

// Read token values from Layout collection before calling
async function getGridValues(mode = 'Default') {
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const layout = collections.find(c => c.name === 'Layout');
  if (!layout) return { gutter: 32, margin: 80, columns: 12 }; // fallback

  const modeId = layout.modes.find(m => m.name === mode)?.modeId ?? layout.defaultModeId;
  const vars = await figma.variables.getLocalVariablesAsync();
  const gutterVar  = vars.find(v => v.variableCollectionId === layout.id && v.name === 'grid/gutter');
  const marginVar  = vars.find(v => v.variableCollectionId === layout.id && v.name === 'grid/margin');
  const colVar     = vars.find(v => v.variableCollectionId === layout.id && v.name === 'grid/columns');

  return {
    gutter:  gutterVar  ? gutterVar.valuesByMode[modeId]  : 32,
    margin:  marginVar  ? marginVar.valuesByMode[modeId]  : 80,
    columns: colVar     ? colVar.valuesByMode[modeId]     : 12,
  };
}
```

### Multi-breakpoint guide (section with mobile + desktop modes)

When building section components with multiple breakpoint variants, apply the correct guide
per variant based on which breakpoint mode is active:

```javascript
// Apply different column guides per breakpoint variant
const breakpointGuides = {
  Mobile:  { columns: 4,  gutter: 16, margin: 16 },
  Tablet:  { columns: 8,  gutter: 24, margin: 32 },
  Desktop: { columns: 12, gutter: 32, margin: 80 },
};
// Always resolve these from Layout collection rather than hardcoding
```

### Critical limitation — variables cannot bind directly to layoutGrids properties

`gutterSize` and `offset` in `layoutGrids` only accept numeric values. You cannot call
`setBoundVariable` on layout guide properties. Always resolve the token value at build time
and write the resolved number. If the user later changes the token value, re-run the guide
application to sync.

---

## 5. 2D Grid Auto Layout — Config 2025

Released May 2025. Similar to CSS Grid. Use for multi-column content blocks (card grids,
product shelves, bento layouts, image galleries, dashboards).

### When to use 2D Grid vs 1D Auto Layout

| Need | Use |
|------|-----|
| Cards in a wrapping multi-column grid | 2D Grid |
| Stacked form rows / page sections | 1D Vertical Auto Layout |
| Inline nav / button group | 1D Horizontal Auto Layout |
| Sidebar + main column layout | 2D Grid (2 columns, fr units) |
| Bento / masonry-style layout | 2D Grid |

### Plugin API for 2D Grid Auto Layout

```javascript
// Create a 2D Grid Auto Layout frame
function createGridFrame(parent, options = {}) {
  const {
    name = 'Block · Card Grid',
    columns = 3,
    columnGapVar,   // Figma Variable for column gap (from Spacing collection)
    rowGapVar,      // Figma Variable for row gap
    paddingVar,     // Figma Variable for frame padding
  } = options;

  const frame = figma.createFrame();
  frame.name = name;
  frame.layoutMode = 'GRID';          // 2D Grid — Config 2025
  frame.layoutSizingHorizontal = 'FILL';
  frame.layoutSizingVertical = 'HUG';

  // Append to parent BEFORE setting FILL sizing
  parent.appendChild(frame);

  // Bind gap tokens — itemSpacing binds column gap in Grid mode
  if (columnGapVar) frame.setBoundVariable('itemSpacing', columnGapVar);
  if (rowGapVar)    frame.setBoundVariable('counterAxisSpacing', rowGapVar);
  if (paddingVar) {
    frame.setBoundVariable('paddingTop', paddingVar);
    frame.setBoundVariable('paddingBottom', paddingVar);
    frame.setBoundVariable('paddingLeft', paddingVar);
    frame.setBoundVariable('paddingRight', paddingVar);
  }

  return frame;
}
```

### Column sizing in 2D Grid

```javascript
// After appending children, set column template
// Figma 2D Grid uses explicit column count — children auto-place
// For equal-width columns: set child layoutSizingHorizontal = FILL
// For fixed columns: set child layoutSizingHorizontal = FIXED with explicit width
```

### Token binding rules for 2D Grid

| Property | Variable collection | Typical token |
|----------|-------------------|--------------|
| Column gap (`itemSpacing`) | Spacing | `spacing/6` (24px) or `spacing/8` (32px) |
| Row gap (`counterAxisSpacing`) | Spacing | `spacing/6` (24px) |
| Frame padding | Spacing | Section-band token |

---

## 6. Section Frame Pattern

A Section frame is the standard organism container for a full-width page slice.

### Standard structure

```
Section · [Name]                     ← Full-width frame (FILL × HUG)
  Layout guide: 12 columns          ← Applied via layoutGrids
  Auto Layout: Vertical, align center
  Padding-y: section/band token     ← e.g. spacing/16 (64px)
  Padding-x: 0 (margin from layout guide)
  │
  └── Container                      ← Max-width frame (FIXED or FILL with maxWidth)
        maxWidth: container/xl       ← 1280px from Layout collection
        Auto Layout: Vertical or Grid
        Gap: section/band token
        │
        ├── [Headline Block]         ← Text atoms
        └── [Content Block]         ← Card grid / feature list / etc.
```

### Plugin API — build a section frame

```javascript
async function buildSection(page, name, options = {}) {
  const _report = { phase: 'Section · ' + name, created: [], failed: [], warnings: [], skipped: [] };

  // Read grid + spacing values from Layout collection
  const gridVals = await getGridValues(); // from Section 4

  // Resolve container/xl token value
  const collections = await figma.variables.getLocalVariableCollectionsAsync();
  const layoutColl = collections.find(c => c.name === 'Layout');
  const allVars = await figma.variables.getLocalVariablesAsync();
  const containerXlVar = allVars.find(v =>
    v.variableCollectionId === layoutColl?.id && v.name === 'container/xl'
  );
  const containerXl = containerXlVar
    ? containerXlVar.valuesByMode[layoutColl.defaultModeId]
    : 1280;

  // Resolve section padding token from Spacing collection
  const spacingColl = collections.find(c => c.name === 'Spacing');
  const sectionPadToken = options.paddingToken ?? 'spacing/16'; // 64px default
  const sectionPadVar = allVars.find(v =>
    v.variableCollectionId === spacingColl?.id && v.name === sectionPadToken
  );

  // 1. Outer section frame (full-width)
  const section = figma.createFrame();
  section.name = 'Section · ' + name;
  section.layoutMode = 'VERTICAL';
  section.layoutSizingHorizontal = 'FILL';
  section.layoutSizingVertical = 'HUG';
  section.primaryAxisAlignItems = 'CENTER';
  section.counterAxisAlignItems = 'CENTER';
  section.paddingLeft = 0;
  section.paddingRight = 0;
  page.appendChild(section);

  // Bind vertical padding to section-band spacing token
  if (sectionPadVar) {
    section.setBoundVariable('paddingTop', sectionPadVar);
    section.setBoundVariable('paddingBottom', sectionPadVar);
  } else {
    section.paddingTop = 64;
    section.paddingBottom = 64;
    _report.warnings.push(`Section padding token '${sectionPadToken}' not found — used 64px fallback`);
  }

  // Apply 12-column layout guide
  applyColumnGuide(section, gridVals.gutter, gridVals.margin); // from Section 4

  // 2. Inner container frame (max-width constrained)
  const container = figma.createFrame();
  container.name = 'Container';
  container.layoutMode = 'VERTICAL';
  container.layoutSizingHorizontal = 'FILL';
  container.layoutSizingVertical = 'HUG';
  container.maxWidth = containerXl;

  // Bind container maxWidth to Layout variable if possible
  if (containerXlVar) {
    container.setBoundVariable('maxWidth', containerXlVar);
  }

  section.appendChild(container);
  _report.created.push('Section · ' + name, 'Container');

  return { ..._report, sectionId: section.id, containerId: container.id };
}
```

---

## 7. Page Template Pattern

A page template is a vertical stack of Section frames inside a top-level page frame.
It acts as a composition scaffold — real pages are instances or copies with real content.

### Standard page template structure

```
Page · [Name]                         ← Top-level Figma frame or Page
  Width: 1440px (desktop) / 375px (mobile)
  Height: HUG (grows with content)
  Auto Layout: Vertical, 0 gap
  Background: color/semantic/surface-default
  Layout guide: 12 columns (desktop)
  │
  ├── Section · Navigation             ← Sticky header
  ├── Section · Hero                   ← Full-bleed hero
  ├── Section · [Feature-1]
  ├── Section · [Feature-2]
  ├── Section · CTA Band
  └── Section · Footer
```

### Section gap = page-level spacing token

The gap between sections on the page is set to a page-level spacing token
(e.g. `spacing/20` = 80px) OR sections have their own vertical padding that creates
the visual separation — in that case the page frame gap is 0.

**Rule**: Either bind the page frame `itemSpacing` to a page-level token and set section
padding to 0, OR set page frame gap to 0 and let each section carry its own padding.
Never both — that creates double-spacing.

### Plugin API — scaffold a page template

```javascript
async function scaffoldPageTemplate(pageName, sectionNames = []) {
  const _report = { phase: 'Page · ' + pageName, created: [], failed: [], warnings: [] };

  // Check if page already exists (idempotency)
  await figma.loadAllPagesAsync();
  const existing = figma.root.children.find(p => p.name === 'Page · ' + pageName);
  if (existing) {
    _report.skipped = ['Page · ' + pageName];
    return _report;
  }

  // Create new Figma page
  const newPage = figma.createPage();
  newPage.name = 'Page · ' + pageName;
  await figma.setCurrentPageAsync(newPage); // setCurrentPageAsync is async — always await

  // Create top-level page frame (1440px desktop default)
  const pageFrame = figma.createFrame();
  pageFrame.name = 'Template · ' + pageName;
  pageFrame.layoutMode = 'VERTICAL';
  pageFrame.itemSpacing = 0; // sections carry their own padding
  pageFrame.resize(1440, 100); // height will grow with HUG
  pageFrame.layoutSizingVertical = 'HUG';
  newPage.appendChild(pageFrame);

  // Apply page-level layout guide
  const gridVals = await getGridValues();
  applyColumnGuide(pageFrame, gridVals.gutter, gridVals.margin);

  // Scaffold each section shell
  for (const sName of sectionNames) {
    await buildSection(pageFrame, sName); // from Section 6
    _report.created.push('Section · ' + sName);
  }

  _report.created.unshift('Page · ' + pageName, 'Template · ' + pageName);
  return _report;
}
```

---

## 8. Auto Layout Token Binding by Context

Every Auto Layout frame created at section or page level must bind its padding and gap
properties to the correct context band from the Spacing collection.

### Binding reference

```javascript
// Helper — bind all four padding sides to the same variable
function bindPadding(frame, variable) {
  ['paddingTop','paddingBottom','paddingLeft','paddingRight'].forEach(prop =>
    frame.setBoundVariable(prop, variable)
  );
}

// Helper — bind asymmetric padding (vertical vs horizontal)
function bindPaddingYX(frame, yVar, xVar) {
  frame.setBoundVariable('paddingTop', yVar);
  frame.setBoundVariable('paddingBottom', yVar);
  frame.setBoundVariable('paddingLeft', xVar);
  frame.setBoundVariable('paddingRight', xVar);
}

// Helper — bind gap
function bindGap(frame, variable) {
  frame.setBoundVariable('itemSpacing', variable);
}
```

### Context binding table

| Frame type | Padding prop | Token band | Example token |
|-----------|-------------|-----------|--------------|
| Molecule / Button | paddingTop, paddingBottom | component | `spacing/2` (8px) |
| Molecule / Card | paddingLeft, paddingRight | component | `spacing/4` (16px) |
| Molecule → Molecule gap | itemSpacing | component | `spacing/3` (12px) |
| Block (card grid, stat row) | padding | section | `spacing/8` (32px) |
| Block → Block gap | itemSpacing | section | `spacing/6` (24px) |
| Section outer padding-y | paddingTop/Bottom | section | `spacing/16` (64px) |
| Section inner container gap | itemSpacing | section | `spacing/10` (40px) |
| Page section gap | itemSpacing | page | `spacing/20` (80px) |

---

## 9. Composition Audit Scripts

### Audit 1 — Detect section frames missing layout guides

```javascript
// Find frames that look like sections (wide, top-level) but have no layout guide
async function auditMissingLayoutGuides() {
  const wide = figma.currentPage.findAll(n =>
    n.type === 'FRAME' &&
    n.width >= 640 &&
    n.parent?.type === 'FRAME' // direct children of a page-level frame
  );
  const missing = wide.filter(f => !f.layoutGrids || f.layoutGrids.length === 0);
  return missing.map(f => ({
    id: f.id, name: f.name, width: Math.round(f.width),
    issue: 'Section-width frame missing layout guide',
  }));
}
return auditMissingLayoutGuides();
```

### Audit 2 — Detect Auto Layout frames with hardcoded spacing (not token-bound)

```javascript
// Find Auto Layout frames where padding/gap is a raw number, not a variable binding
async function auditUnboundSpacing() {
  const autoFrames = figma.currentPage.findAll(n =>
    n.type === 'FRAME' && n.layoutMode !== 'NONE' && n.visible !== false
  );
  const unbound = [];
  for (const f of autoFrames) {
    const props = ['paddingTop','paddingBottom','paddingLeft','paddingRight','itemSpacing'];
    const hardcoded = props.filter(p => {
      const val = f[p];
      const bound = f.boundVariables?.[p];
      return typeof val === 'number' && val > 0 && !bound;
    });
    if (hardcoded.length > 0) {
      unbound.push({ id: f.id, name: f.name, hardcodedProps: hardcoded });
    }
  }
  return unbound;
}
return auditUnboundSpacing();
```

### Audit 3 — Detect container frames without maxWidth

```javascript
// Find frames named 'Container' or 'container' that have no maxWidth constraint
async function auditMissingMaxWidth() {
  const containers = figma.currentPage.findAll(n =>
    n.type === 'FRAME' && /container/i.test(n.name)
  );
  return containers
    .filter(c => !c.maxWidth || c.maxWidth === 0)
    .map(c => ({ id: c.id, name: c.name, issue: 'Container frame missing maxWidth' }));
}
return auditMissingMaxWidth();
```

### Composite composition health report

Run all three audits in a single `figma_execute` block and return unified output:

```javascript
async function compositionHealthReport() {
  const [guideIssues, spacingIssues, maxWidthIssues] = await Promise.all([
    auditMissingLayoutGuides(),
    auditUnboundSpacing(),
    auditMissingMaxWidth(),
  ]);
  return {
    phase: 'Composition Audit',
    missingLayoutGuides: guideIssues.length,
    unboundSpacing: spacingIssues.length,
    missingMaxWidth: maxWidthIssues.length,
    details: { guideIssues, spacingIssues, maxWidthIssues },
  };
}
return compositionHealthReport();
```

---

## 10. Context Decision Tree

Use this tree when deciding what to build and which tokens/patterns to apply.

```
What are you building?
│
├── A single interactive element (button, input, toggle, tag)?
│     → Molecule. Apply component-band spacing tokens.
│         Internal padding: spacing/1 – spacing/4 (4–16px)
│         Internal gap: spacing/2 – spacing/6 (8–24px)
│         No layout guide. Auto Layout only.
│
├── A group of related molecules (form, search bar, button group)?
│     → Block / Composition. Apply section-low tokens.
│         Gap between molecules: spacing/4 – spacing/8 (16–32px)
│         Consider 2D Grid Auto Layout if multi-column.
│         No layout guide.
│
├── A full-width page slice (hero, feature band, CTA, footer)?
│     → Section / Organism.
│         Outer padding-y: spacing/12 – spacing/16 (48–64px)
│         Inner container maxWidth: container/xl from Layout collection
│         Inner gap between blocks: spacing/8 – spacing/10 (32–40px)
│         Apply 12-column layout guide using Layout collection gutter + margin.
│
├── A complete page or screen?
│     → Page Template.
│         Section-to-section gap: spacing/20+ (80px+) OR 0 if sections carry padding
│         Top-level frame width: 1440px (desktop) / 375px (mobile) / 768px (tablet)
│         Apply 12-column layout guide at the page frame.
│         Each Section uses the Section Frame Pattern.
│
└── A card grid / product shelf / image gallery?
      → Block with 2D Grid Auto Layout (Config 2025).
          Column gap: spacing/6 – spacing/8 (24–32px)
          Row gap: spacing/6 (24px)
          Children: FILL sizing for equal columns, FIXED for explicit widths
          Parent section applies the standard Section Frame Pattern around it.
```

---

## 11. Critical API Rules for Layout

These supplement Protocol 7 in `figma-mcp-design-architect` SKILL.md.

| Never do | Do instead |
|----------|-----------|
| `frame.layoutGrids = [...]` with `await` | `layoutGrids` is synchronous — no `await` |
| Hardcode `gutterSize` / `offset` numbers | Read from Layout collection and resolve first |
| Set `layoutSizingHorizontal = "FILL"` before `appendChild` | Append to parent first, then set FILL |
| Set `frame.layoutMode = "GRID"` before appending children | Append children first to avoid positioning errors |
| Use layout guide gutterSize for component spacing | Layout guide = visual reference only; Auto Layout tokens handle actual spacing |
| `frame.maxWidth = value` without setting `layoutMode` | `maxWidth` only works on Auto Layout frames |
| Bind `gutterSize` or `offset` to a variable | Not supported — resolve to number first |
| Set both page `itemSpacing` AND section padding-y | Choose one spacing strategy per file — double-spacing is a common bug |

### Variables you CAN bind on Auto Layout frames

```javascript
// These all support setBoundVariable():
frame.setBoundVariable('paddingTop',    spacingVar);
frame.setBoundVariable('paddingBottom', spacingVar);
frame.setBoundVariable('paddingLeft',   spacingVar);
frame.setBoundVariable('paddingRight',  spacingVar);
frame.setBoundVariable('itemSpacing',   spacingVar);   // 1D gap OR 2D column gap
frame.setBoundVariable('counterAxisSpacing', spacingVar); // 2D row gap only
frame.setBoundVariable('maxWidth',      containerVar); // Layout collection
frame.setBoundVariable('minWidth',      spacingVar);

// These do NOT support setBoundVariable():
// layoutGrids[n].gutterSize   → numeric only
// layoutGrids[n].offset       → numeric only
// layoutGrids[n].count        → numeric only
// frame.width / frame.height  → use resize() or FILL sizing instead
```
