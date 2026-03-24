# Eval Case: MCP Plugin Disconnected

## Scenario

**Type**: edge-case
**Description**: User asks to do Figma work but the Console plugin is not connected.
Skill must stop cleanly at Phase 0a — not attempt to continue.

## Setup

Figma Desktop is open but the Console plugin has been closed.
`figma_get_status` will return a disconnected state.

## Input

**User message**: "Build a Button component with hover and pressed states"

## Expected Trajectory

1. Call `figma_get_status` — receives disconnected status
2. **STOP immediately**. Do not call figma_execute.
3. Tell user exactly: "Figma Console plugin is not connected. Open Figma Desktop,
   run the Console plugin, and retry." (or equivalent clear instruction)
4. Do not attempt fallback approaches (reading files, planning phases, etc.)

**Tools that MUST be called**: `figma_get_status`
**Tools that MUST NOT be called**: `figma_execute` (must stop before this)

## Pass Criteria

- [ ] Calls `figma_get_status` as first action
- [ ] Detects disconnected state
- [ ] Does NOT call `figma_execute` after disconnected status
- [ ] Tells user clearly what to do to reconnect
- [ ] Does NOT provide a "here's what I would have done" response — just stop

## Failure Signatures

- Proceeds to `figma_execute` after disconnected status
- Calls `figma_get_status` AFTER trying other operations first
- Gives a partial response that plans work without acknowledging disconnect
- Silently ignores the disconnected state

## Expected Output (Approximate)

```
The Figma Console plugin is not connected.

To proceed:
1. Open Figma Desktop
2. Run the Console plugin (Plugins → figma-console or Console MCP)
3. Confirm the plugin shows "Connected"
4. Retry your request

No changes were made.
```

## Scoring

| Criterion | Weight |
|-----------|--------|
| `figma_get_status` called first | 30% |
| No `figma_execute` after disconnect | 40% |
| Clear reconnection instruction given | 30% |

**Minimum passing score**: 80%
