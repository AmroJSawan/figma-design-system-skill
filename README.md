# design-system-skill

A [Claude Code](https://claude.ai/code) skill that gives Claude full programmatic control over Figma — building design systems, auditing token health, migrating hardcoded values to variables, and repairing component debt — all via the Figma MCP plugin.

**Version**: 1.7.0 | **Tested with**: claude-sonnet-4-6

> **New (2026-03-24) — Figma Official Remote MCP with Write Support**
> Figma has released an official remote MCP server that supports **write operations** — create frames, set fills, bind variables, update text, and more — directly from Claude without needing the local Console plugin or the figma-canvas-mcp bridge.
> This is now the **preferred connection method** for all design write tasks. See [MCP Connection Options](#mcp-connection-options) below.

---

## What it does

When installed, Claude automatically activates this skill whenever you ask it to do Figma design system work. No slash commands, no manual setup — Claude detects the intent and runs the right workflow.

### Create new design systems
- Build a complete token foundation (Color Primitives → Semantics → Typography → Spacing → Motion)
- Scaffold component sets (molecules) with all interactive states
- Add responsive behavior across breakpoints with Auto Layout
- Apply visual harmony principles (Golden Ratio, Fibonacci spacing, Gestalt)

### Audit and modernize existing design systems
- **Health scan**: Token coverage %, detached instance count, hardcoded color inventory — in a single Phase 0b call
- **Maturity assessment**: Tier 1 (Fragmented) through Tier 4 (Mature) classification with a 6-R modernization roadmap
- **Token migration**: Strangler Fig pattern — survey hardcoded hex values by frequency, map to existing variables, bind in-place without touching nodes
- **Deprecation cleanup**: Find all `_deprecated/` tokens, check fills AND strokes for active bindings, remap to successors, then delete safely
- **Component repair**: Inventory detached instances, audit rogue overrides, present repair options before acting

### Safety-first design
Every workflow is gated by mandatory protocols that prevent data loss:
- Phase 0a (MCP health check) runs before anything touches Figma
- Phase 0b (file state audit) runs before any write operation
- Idempotency check on every creation — never duplicates existing work
- All writes return structured `{ phase, created, skipped, failed, warnings }` — no silent failures
- Visual validation loop after every change (screenshot → analyze → fix)
- Nothing is deleted or rebuilt without explicit user confirmation

---

## MCP Connection Options

As of **2026-03-24**, Figma provides an official remote MCP server with full **read and write** support. This supersedes the previous local Console plugin approach.

### Option A — Figma Official Remote MCP (recommended)

Figma's remote MCP connects directly to your Figma account over the network. No local plugin, no bridge server required.

**Capabilities unlocked:**
- Create, update, and delete nodes (frames, components, instances, text, shapes)
- Set fills, strokes, and corner radius — with variable bindings
- Write design tokens (variable collections, modes, values)
- Read file structure, styles, components, and variables
- All operations work on the currently open file in Figma Desktop or Web

**How to connect:**
1. In Claude Code settings (`~/.claude/settings.json`), add the Figma remote MCP under `mcpServers`
2. Authenticate with your Figma account when prompted
3. Open the target Figma file — the MCP operates on whichever file is active

> The remote MCP uses the same Figma Plugin API surface as the Console plugin but runs server-side. All write operations are subject to your Figma plan's API limits.

### Option B — figma-canvas MCP (local, legacy)

The local Console plugin + `figma-canvas-mcp` bridge remains fully supported for teams that require an air-gapped or offline setup. See [Installation](#installation) for setup steps.

**When to prefer Option B:**
- No internet access to Figma's remote MCP endpoint
- Need to run against a private Figma on-prem instance
- Debugging plugin API calls directly in the Figma console

### Which option is active?

The skill auto-detects the available MCP at Phase 0a. If the Figma remote MCP responds, it is used. If only `figma-canvas` is registered, the local plugin path is used. If neither is available, the skill halts with a clear error before touching anything.

---

## Standards & Compliance

Every workflow in this skill is grounded in industry standards. These are not optional guidelines — they are enforced at each relevant phase.

### Accessibility — WCAG 2.1 / 2.2

| Rule | Level | Where enforced |
|------|-------|----------------|
| Color contrast ≥ 4.5:1 (normal text) | AA | Token foundation — semantic color mapping |
| Color contrast ≥ 3:1 (large text / UI components) | AA | Component build — fill + stroke checks |
| Color contrast ≥ 7:1 (normal text) | AAA | Flagged as a recommendation in health reports |
| Focus indicators visible and ≥ 3:1 contrast | AA | Component state variants (focus state required) |
| Text resize to 200% without loss of content | AA | Responsive design — Auto Layout sizing modes |
| Non-text contrast ≥ 3:1 for interactive elements | AA | Molecule architecture — disabled / inactive states |

> Contrast ratios are calculated from resolved variable values (Light mode baseline). Dark mode is checked separately when a second mode collection exists.

### Token Architecture — W3C Design Tokens Community Group (DTCG)

The skill follows the [W3C DTCG token format](https://tr.designtokens.org/format/) for naming, layering, and referencing:

| Convention | Detail |
|------------|--------|
| **3-layer hierarchy** | Primitive → Semantic → Component (P→S→C) |
| **Token naming** | `{category}/{role}/{variant}` — e.g. `color/brand/primary`, `spacing/4`, `radius/md` |
| **Aliasing** | Semantic tokens reference primitives by variable alias, never by hardcoded value |
| **Type annotation** | Each token carries an explicit type: `color`, `dimension`, `number`, `string`, `boolean` |
| **Multi-mode support** | Light/Dark and Density modes use Figma variable collection modes — one value set per mode |
| **No orphan primitives** | Every primitive must be consumed by at least one semantic token (enforced in deprecation cleanup) |

### Typography — Type Scale Standards

| Standard | Applied rule |
|----------|-------------|
| **Modular scale** | Type sizes follow a ratio-based scale (Major Third 1.25× default, configurable) |
| **Minimum body text** | 16px / 1rem minimum for body copy (WCAG 1.4.4 resize compliance) |
| **Line height** | 1.4–1.6× for body text; 1.1–1.3× for headings |
| **Letter spacing** | 0 to +0.02em for body; tighter values only on display sizes ≥ 32px |
| **Font weight tokens** | Named by role (`font/weight/regular`, `font/weight/bold`) not by numeric value |

### Spacing — 4pt / 8pt Grid

All spacing tokens are multiples of 4px (base unit), with an 8px soft grid for layout-level spacing:

```
spacing/1  =  4px    spacing/6  = 24px
spacing/2  =  8px    spacing/8  = 32px
spacing/3  = 12px    spacing/10 = 40px
spacing/4  = 16px    spacing/12 = 48px
spacing/5  = 20px    spacing/16 = 64px
```

Odd multiples (spacing/3, spacing/5) are available but flagged in audits if used at section-band level — section spacing should use spacing/8 and above.

### Visual Design — Established Design Principles

| Principle | Standard applied |
|-----------|-----------------|
| **Proportion** | Golden Ratio (1:1.618) for panel sizing and hero section aspect ratios |
| **Spatial rhythm** | Fibonacci sequence (8, 13, 21, 34, 55px) as fallback spacing where tokens don't cover edge cases |
| **Gestalt grouping** | Proximity, similarity, continuity — checked in visual harmony audit |
| **Contrast hierarchy** | 3-level typographic hierarchy enforced (heading / body / caption) |
| **Negative space** | Minimum breathing room = spacing/4 (16px) inside any container |

### Component Quality — Atomic Design

Components follow the Atomic Design methodology (Brad Frost):

| Level | Definition | Build requirement |
|-------|-----------|-------------------|
| **Atom** | Indivisible UI unit (icon, label, badge) | Token-bound fills, no hardcoded values |
| **Molecule** | Composed of atoms (button, input field, chip) | All interactive states present (default / hover / focus / active / disabled / loading) |
| **Organism** | Section-level composition (card grid, nav bar) | Auto Layout, responsive sizing, grid-aligned |
| **Template / Page** | Full-screen layout | 12-column grid, container maxWidth from Layout tokens |

### Figma-Specific Best Practices

| Practice | Enforcement |
|----------|------------|
| All variable bindings use `setBoundVariable` / `setBoundVariableForPaint` — never hardcoded | Enforced in every figma_execute call |
| No `frame.resize()` on Auto Layout children — use `layoutSizingHorizontal` / `layoutSizingVertical` | Critical API Rules (Protocol 7) |
| `loadFontAsync` called before any text mutation | Critical API Rules (Protocol 7) |
| Layout guides (`layoutGrids`) use resolved px values — variable binding not supported by Figma | Documented in grid propagation protocol |
| Component properties typed explicitly (`BOOLEAN`, `TEXT`, `INSTANCE_SWAP`, `VARIANT`) | Molecule architecture protocol |

---

## Requirements

| Requirement | Notes |
|-------------|-------|
| [Claude Code](https://claude.ai/code) | Any plan |
| **Figma Official Remote MCP** *(recommended)* | Released 2026-03-24 — supports read + write, no local plugin needed |
| [Figma Desktop](https://www.figma.com/downloads/) | Required only for Option B (local Console plugin) |
| Figma Console MCP plugin | Option B only — see installation step 3 |
| figma-canvas MCP server | Option B only — bridges Claude ↔ Figma Console plugin |

### Reference files (included as dependencies)

This skill reads four domain-specific reference files at runtime. They must be present at:

```
~/.claude/skills/figma-token-foundation.md
~/.claude/skills/research-figma-molecule-architecture.md
~/.claude/skills/research-responsive-adaptive-design.md
~/.claude/skills/research-visual-harmony-composition.md
~/.claude/skills/figma-ds-modernization.md          ← bundled in this repo
~/.claude/skills/research-layout-composition.md     ← bundled in this repo
```

The first four are separate reference libraries (see [Dependencies](#dependencies)). `figma-ds-modernization.md` and `research-layout-composition.md` ship with this skill.

---

## Installation

### Step 1 — Clone this repository

```bash
git clone https://github.com/<your-username>/design-system-skill.git
```

Copy the skill directory into your Claude skills folder:

```bash
cp -r design-system-skill ~/.claude/skills/design-system-skill
cp figma-ds-modernization.md ~/.claude/skills/figma-ds-modernization.md
```

Verify the structure:

```
~/.claude/skills/
├── design-system-skill/
│   ├── SKILL.md
│   ├── README.md
│   ├── changelog.md
│   ├── evals/
│   │   ├── run-evals.sh
│   │   └── cases/
│   │       ├── basic.md
│   │       ├── edge-case.md
│   │       ├── regression.md
│   │       ├── audit-existing.md
│   │       └── migrate-hardcoded.md
│   └── versions/
│       ├── v1.0.0.md
│       ├── v1.1.0.md
│       └── v1.2.0.md
└── figma-ds-modernization.md
```

### Step 2 — Install the reference libraries

This skill routes to four reference files for deep domain knowledge. Install whichever apply to your work:

```bash
# All four — recommended for full capability
cp figma-token-foundation.md ~/.claude/skills/figma-token-foundation.md
cp research-figma-molecule-architecture.md ~/.claude/skills/research-figma-molecule-architecture.md
cp research-responsive-adaptive-design.md ~/.claude/skills/research-responsive-adaptive-design.md
cp research-visual-harmony-composition.md ~/.claude/skills/research-visual-harmony-composition.md
```

> The skill still works without them but will warn that deep knowledge is unavailable for the missing domain.

### Step 3 — Set up the Figma Console MCP plugin

The skill talks to Figma through a local MCP server that bridges Claude ↔ Figma Desktop.

**3a. Install the figma-canvas MCP server**

```bash
git clone https://github.com/sonnylazuardi/figma-canvas-mcp.git
cd figma-canvas-mcp
npm install
npm run build
```

**3b. Register it in Claude Code**

Add the server to `~/.claude/settings.json` (or `settings.local.json`):

```json
{
  "mcpServers": {
    "figma-canvas": {
      "command": "node",
      "args": ["/absolute/path/to/figma-canvas-mcp/dist/index.js"]
    }
  }
}
```

**3c. Install the Console plugin in Figma Desktop**

1. Open Figma Desktop
2. Go to **Plugins → Development → Import plugin from manifest**
3. Select the `manifest.json` from the `figma-canvas-mcp` plugin directory
4. Run the plugin: **Plugins → figma-console** (or the name in your manifest)
5. Confirm it shows a **Connected** status

### Step 4 — Verify everything is wired up

Run the eval suite to check that all reference files are in place:

```bash
bash ~/.claude/skills/design-system-skill/evals/run-evals.sh
```

Expected output:
```
design-system-skill Eval Suite
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Reference check:
  All 5 reference files present.

Cases:
  [basic] basic — 8 pass criteria
  [edge-case] edge-case — 5 pass criteria
  [regression] regression — 6 pass criteria
  [existing-system] audit-existing — 8 pass criteria
  [existing-system] migrate-hardcoded — 7 pass criteria

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Cases: 5
```

---

## Usage

Open a Figma file in Figma Desktop, make sure the Console plugin is running and showing **Connected**, then talk to Claude naturally.

### Build a new design system

```
Create a token foundation for our brand — primary color #2563EB, font is Inter
```

Claude will:
1. Check the MCP connection
2. Audit the file (what already exists)
3. Read the token foundation reference
4. Build Color Primitives → Semantics → Typography → Spacing in sequence
5. Reflow the canvas and screenshot each phase
6. Report what was created, skipped, or warned

### Audit an existing file

```
Our design system hasn't been touched in 3 years. Can you audit it?
```

Claude will:
1. Run the health scan (fill coverage, text style coverage, detached instances)
2. Classify maturity tier (1–4)
3. Output a health report table
4. Produce a prioritized modernization roadmap using the 6-R framework
5. Ask which item to start with — no modifications until you confirm

### Migrate hardcoded colors

```
We have hundreds of hardcoded colors. Can you migrate them to variables?
```

Claude will:
1. Survey all unique hardcoded hex values sorted by frequency
2. Map each hex to the closest existing variable (HSL tolerance matching) or propose creating a new primitive
3. Show you the full mapping table — wait for your confirmation
4. Bind fills in-place, highest-frequency first (Strangler Fig)
5. Re-run the health scan before/after to show coverage improvement

### Build from brand guidelines (from-scratch)

```
Create a complete design system from scratch — primary color #1A6EFF, font is Inter,
rounded corners, standard motion. Brand name is "Acme".
```

Claude will:
1. Parse a **BrandManifest** from your input — extracting colors, typography, shape, motion, and density preferences
2. Classify each field as `_provided`, `_inferred`, or `_defaulted` and show you the manifest for confirmation
3. Generate the full OKLCH color scale (50–950 shades) from your primary hex
4. Build all token collections in order: Color Primitives → Semantics → Typography → Spacing → Radius → Motion → Layout
5. Create text styles bound to the type scale
6. Build documentation panels showing every token live-bound to its variable
7. Report the final health score (should be ≥ 85% on a clean build)

You can also point Claude at a brand source instead of listing values inline:

```
Build a design system from our brand guidelines: https://notion.so/acme/brand-guidelines
```

Claude will fetch the Notion page, extract brand values, and build the same BrandManifest — asking you to confirm before writing anything to Figma.

### Fix detached components

```
Fix the detached instances on this page
```

Claude will:
1. Inventory all detached instances with name and canvas position
2. Audit rogue overrides on attached instances
3. Present you with repair options for each — never auto-deletes

---

## How it works

```
User message
    │
    ▼
Phase 0a — MCP health check (stop if disconnected)
    │
    ▼
Phase 0b — File state audit + health scan
    │        (pages, collections, component sets, fill/stroke/text coverage,
    │         broken bindings, detached instances, resolvedVariableModes)
    ▼
Phase 0 Brand Input — (from-scratch only) parse BrandManifest, confirm with user
    │
    ▼
Task Router — maps intent to reference file + protocol
    │
    ├── From scratch    → Phase 0 Brand Input → figma-token-foundation.md
    ├── Token work      → figma-token-foundation.md
    ├── Components      → research-figma-molecule-architecture.md
    ├── Responsive      → research-responsive-adaptive-design.md
    ├── Visual harmony  → research-visual-harmony-composition.md
    ├── Existing DS     → figma-ds-modernization.md (Protocols 8–11)
    ├── Composition     → research-layout-composition.md (Protocol 12)
    ├── Documentation   → Protocol 13 (inline)
    ├── DTCG export     → Protocol 14 (inline)
    ├── Code Connect    → Protocol 15 (inline)
    └── UI capture      → Protocol 16 (inline)
    │
    ▼
Universal Protocols (applied to every figma_execute call)
    1. Phase Wrapper + Shared Helpers — safeExec, fv(), bf(), bind*()
    2. Idempotency First   — check before creating
    3. Structured Returns  — { phase, created, skipped, failed, warnings }
    4. Canvas Reflow       — panels stay aligned (+ getColBottom for continuation)
    5. Orphan Cleanup      — partial failures don't leave stray nodes
    6. Visual Validation   — screenshot → analyze → fix (max 3 iterations)
    7. Critical API Rules  — 30+ Figma API gotchas enforced
    │
    ▼
Output report + next step suggestion
```

---

## Supported workflows

| Workflow | Trigger phrases |
|----------|----------------|
| **From-scratch build** | "create from scratch", "new design system", "build from brand guidelines" |
| Token foundation | "create design tokens", "build token foundation", "add variables" |
| Component building | "build a component", "create molecule", "add states" |
| Responsive design | "make responsive", "add breakpoints", "Auto Layout sizing" |
| Visual harmony | "audit visual harmony", "something feels off", "spacing audit" |
| Canvas cleanup | "panels overlapping", "reflow canvas", "orphan nodes" |
| **DS audit** | "audit my design system", "health check", "token coverage report" |
| **Token migration** | "migrate hardcoded colors", "migrate to tokens", "fix hardcoded" |
| **Deprecation** | "remove deprecated tokens", "clean up old tokens", "sunset" |
| **Component repair** | "fix detached instances", "reattach components" |
| **Grid propagation** | "build a section", "page template", "hero section", "card grid", "organism", "grid propagation" |
| **Documentation** | "document design system", "document tokens", "visualize tokens", "build a style guide" |
| **DTCG export** | "export tokens", "tokens.json", "Style Dictionary export", "DTCG format" |
| **Code Connect** | "code connect", "connect to code", "map Figma to code", "inspect panel code" |
| **UI capture → tokenize** | "capture this page", "import from URL", "tokenize this design" |

---

## File structure

```
design-system-skill/
├── SKILL.md                    # Main skill — Phases 0a/0b, Brand Input,
│                               # Task Router, Protocols 1–7, 12–16,
│                               # Shared Helpers, Quality Gate, Edge Cases
│
├── README.md                   # This file
├── changelog.md                # Version history with full diffs
│
├── evals/
│   ├── run-evals.sh            # Reference file checker + case lister
│   └── cases/
│       ├── basic.md            # Token foundation build
│       ├── edge-case.md        # MCP disconnected — must stop at Phase 0a
│       ├── regression.md       # Component set exists — must reuse, not recreate
│       ├── audit-existing.md   # Tier 1 file — health report without modifications
│       └── migrate-hardcoded.md # Strangler Fig migration — survey-confirm-bind-verify
│
└── versions/
    ├── v1.0.0.md               # Frozen snapshots for rollback
    ├── v1.1.0.md
    ├── v1.2.0.md
    ├── v1.3.0.md
    ├── v1.4.0.md
    └── v1.7.0.md               # v1.5.0–v1.6.0 were rapid iterations; v1.7.0 is the current frozen snapshot

# Companion reference file (ships with this repo):
figma-ds-modernization.md       # Protocols 8–11 (audit, migration, deprecation, repair)
                                # Includes colorsMatch() HSL helper, shared utilities,
                                # correct execution order for full modernization
```

---

## Dependencies

These reference files are loaded on demand by the Task Router. They are not bundled here — install them separately.

| File | Domain | Required for |
|------|--------|-------------|
| `figma-token-foundation.md` | Token architecture, Phase-by-phase workflow | Building new token foundations |
| `research-figma-molecule-architecture.md` | Component systems, Systems Thinker 3 Laws | Building/extending components |
| `research-responsive-adaptive-design.md` | Breakpoints, density modes, Auto Layout | Responsive design work |
| `research-visual-harmony-composition.md` | 7 master design principles, Golden Ratio | Visual quality audits |
| `figma-ds-modernization.md` | Protocols 8–11 — audit, migrate, deprecate, repair | **Bundled in this repo** |
| `research-layout-composition.md` | Protocol 12 — grid propagation, section/page composition | **Bundled in this repo** |

---

## Maturity tiers

The health scan in Phase 0b scores the current page across four dimensions:

| Dimension | Weight | Measures |
|-----------|--------|----------|
| Solid fill coverage | 35% | % of solid fills bound to Figma variables |
| Stroke coverage | 10% | % of solid strokes bound to Figma variables |
| Text style coverage | 25% | % of text nodes bound to text styles |
| Component health | 30% | % of instances attached to a main component |

| Tier | Score | Characteristics |
|------|-------|----------------|
| 1 — Fragmented | < 30% | Hardcoded everywhere, no variable collections |
| 2 — Building | 30–59% | Some token collections, partial bindings |
| 3 — Adopting | 60–84% | Primitive + Semantic layers, most fills bound |
| 4 — Mature | ≥ 85% | Full P→S→C token architecture, versioned, near-zero debt |

> Gradient fills, spacing tokens, and multi-mode coverage are not counted in the score. The report surfaces gradient count separately with a note. Broken bindings (fills referencing deleted variables) are detected and counted as hardcoded.

---

## Changelog

See [changelog.md](./changelog.md) for the full version history.

| Version | Date | Summary |
|---------|------|---------|
| v1.7.0 | 2026-03-24 | From-scratch capability: BrandManifest parsing, 18 new API rules, shared helper library (fv/bf/bfill/bstroke/bind*), stroke coverage in health scan, getGridValues + 2D Grid, 7 harmony principles in Quality Gate |
| v1.6.0 | 2026-03-24 | 10 enhancements: full claude.ai Figma MCP tools, broken-binding detection, setBoundVariableForEffect, Protocols 14–16 (DTCG export, Code Connect, UI capture), superset declaration |
| v1.5.0 | 2026-03-24 | Protocol 13: live-bound documentation panels, namespace fix, Quality Gate update |
| v1.4.0 | 2026-03-24 | Three-layer versioning: shared plugin data changelog, _Meta audit variables, AUDIT_TRAIL frame logging |
| v1.3.0 | 2026-03-24 | Grid propagation — Protocol 12, research-layout-composition.md, section/page/organism composition support |
| v1.2.0 | 2026-03-24 | 10 audit fixes: wrong API, JSON.stringify, figma.mixed, Phase D2, loadAllPagesAsync, hidden layers, gradients, strokes, Protocol 1 wrapper, position restore |
| v1.1.0 | 2026-03-24 | Added existing DS support — Protocols 8–11, WebSearch, health scan in Phase 0b |
| v1.0.0 | 2026-03-24 | Initial release — token foundation, molecules, responsive, visual harmony |

---

## Troubleshooting

**"Figma Console plugin is not connected"**
Open Figma Desktop → Plugins → run the Console plugin → confirm it shows Connected → retry.

**Health scan returns 0% fill coverage on a file that has variables**
Check that you are on the correct page. Phase 0b scans `figma.currentPage` only. Switch to the page with your design and retry.

**Token migration `bound: 0` for a hex that definitely exists**
The survey and bind steps ran on different pages. Verify `figma.currentPage.name` matches between Phase M1 and Phase M3.

**Phase D2 shows active bindings for a variable you want to delete**
Do not delete. Run Phase D3 remap first to point those nodes at the successor token, then re-run Phase D2 to confirm zero bindings before Phase D4.

**Reinstantiated component appeared at `{0, 0}`**
This was a bug in v1.1.0. Upgrade to v1.2.0 — position is now captured and restored.

**`figma.createInstance` throws "is not a function"**
This was a bug in v1.1.0. Upgrade to v1.2.0 — the API is now `mainComponent.createInstance()`.

**`maxWidth` binding has no visible effect on a container frame**
`maxWidth` only works on Auto Layout frames. The container frame must have `layoutMode` set to `"HORIZONTAL"` or `"VERTICAL"` before `setBoundVariable('maxWidth', var)` is called.

**Layout guide `gutterSize` throws when passed a variable reference**
`frame.layoutGrids[n].gutterSize` accepts numbers only — Figma variables cannot be bound to this field. Resolve the token's numeric pixel value and write it directly.

**Second node in a loop lost its fill variable binding (paint freshness)**
Never reuse a bound paint object across multiple nodes. `setBoundVariableForPaint` returns a paint tied to a single call — assigning that same paint to a second node may silently drop the binding. Call `setBoundVariableForPaint` fresh inside each loop iteration.

**Hover state overlay is invisible on a transparent/outlined component**
`state/hover` is typically a white overlay (`#FFFFFF` at low opacity) — invisible on transparent surfaces. Use `background/subtle` or another opaque semantic token for outlined/ghost components. See the surface-aware token selection table in Protocol 7.

**2D Grid (`layoutMode = 'GRID'`) children render in wrong order**
Figma 2D Grid fills cells left-to-right, top-to-bottom in DOM order. If children appear shuffled, check their append order — it must match the intended visual sequence. Re-appending in the correct order fixes the layout.

**Padding tokens not binding — `setBoundVariable('paddingTop', var)` has no effect**
Padding properties only exist on Auto Layout frames. Ensure `layoutMode` is `"HORIZONTAL"` or `"VERTICAL"` (not `"NONE"`) before calling `setBoundVariable` on any padding field.

**Health scan says 100% on an empty page**
An empty page has zero fills, zero text, zero instances — all coverage ratios default to 100% (0/0 = perfect). This is by design. Switch to a page with actual content before running the audit.

#Results:
<img width="1310" height="880" alt="Screenshot 2026-03-24 at 10 32 45 PM" src="https://github.com/user-attachments/assets/e5e5685b-1730-4ae2-a408-a6049554bf48" />
<img width="1175" height="804" alt="Screenshot 2026-03-24 at 10 32 52 PM" src="https://github.com/user-attachments/assets/4717efc8-3cad-449c-a11f-a9109e561a60" />
<img width="1081" height="826" alt="Screenshot 2026-03-24 at 10 33 00 PM" src="https://github.com/user-attachments/assets/8380e195-bb32-490b-acf1-855a2774a0a6" />
<img width="236" height="365" alt="Screenshot 2026-03-24 at 10 33 24 PM" src="https://github.com/user-attachments/assets/a70d9a27-0fb7-4bf0-970b-bee0bc1583e3" />
<img width="976" height="869" alt="Screenshot 2026-03-24 at 10 33 33 PM" src="https://github.com/user-attachments/assets/73d72014-6df8-4772-aa32-801f6cce099e" />
<img width="1214" height="902" alt="Screenshot 2026-03-24 at 10 33 40 PM" src="https://github.com/user-attachments/assets/bc74a3b9-327c-4afc-ae2d-f81dfedb9e8a" />
<img width="1226" height="898" alt="Screenshot 2026-03-24 at 10 33 46 PM" src="https://github.com/user-attachments/assets/4bc7c027-a547-49bf-b623-9428a66b5f97" />
<img width="1227" height="903" alt="Screenshot 2026-03-24 at 10 33 56 PM" src="https://github.com/user-attachments/assets/52180eb9-948f-4dda-9bec-4dafbb73ea4e" />
<img width="1233" height="910" alt="Screenshot 2026-03-24 at 10 34 02 PM" src="https://github.com/user-attachments/assets/a502aa17-516e-44f4-b840-f0a9a9e67982" />
<img width="747" height="893" alt="Screenshot 2026-03-24 at 10 34 25 PM" src="https://github.com/user-attachments/assets/b08b89f6-4c5f-46eb-a5f0-9823e7cbe1fb" />
<img width="805" height="597" alt="Screenshot 2026-03-24 at 10 34 32 PM" src="https://github.com/user-attachments/assets/e5e662f6-2e2f-4897-adea-6f3ccbd349a0" />
<img width="1259" height="464" alt="Screenshot 2026-03-24 at 10 34 56 PM" src="https://github.com/user-attachments/assets/4d524eef-bd0a-4a26-b14c-71e05a02b7b2" />
<img width="1262" height="631" alt="Screenshot 2026-03-24 at 10 35 01 PM" src="https://github.com/user-attachments/assets/4500ce19-7a77-41cf-9a33-94571b3e9ef7" />
<img width="728" height="211" alt="Screenshot 2026-03-24 at 10 35 24 PM" src="https://github.com/user-attachments/assets/2839252b-8ce2-4f2c-b32f-5d8c76438b2a" />
<img width="891" height="563" alt="Screenshot 2026-03-24 at 10 35 29 PM" src="https://github.com/user-attachments/assets/45ec66d3-1aff-4534-9ff8-d2a2ff7e4e7b" />

---

## License

MIT
