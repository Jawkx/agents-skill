# Ui Testing And Flows

> Part of the unified `argent` skill. Return to [`../SKILL.md`](../SKILL.md) for task routing.

## UI flow testing

### Platform-agnostic

The interaction tool names are identical on iOS and Android — `gesture-tap`, `gesture-swipe`, `describe`, `screenshot`, `launch-app`, etc. — and the tool-server auto-dispatches based on the `udid` you pass (UUID-shape → iOS, adb serial → Android).

**Before testing, resolve which device to test on.** Call `list-devices` and follow `<device_selection_rule>`: prefer a running device on any platform;

Once a platform is chosen, the per-platform setup skill takes over:

| Platform | Setup skill                     | Find devices with                                           |
| -------- | ------------------------------- | ----------------------------------------------------------- |
| iOS      | `device-interaction.md`    | `list-devices` → `boot-device` with `udid` if none booted   |
| Android  | `device-interaction.md` | `list-devices` → `boot-device` with `avdName` if none ready |

### 1. Workflow

All interactions go through argent MCP tools. Ensure the simulator/emulator is ready before starting.

For implementation tasks that modify visible UI, this workflow can also serve as a visual acceptance path.

1. **Baseline screenshot**: Call `screenshot` to see the current UI state. For visual regression comparison or UI change verification, capture the baseline at `scale: 1.0` with `includeImageInContext: false` and keep the returned `path` before editing whenever feasible.
2. **Find target**: Before tapping, use a discovery tool to get element coordinates:
   - **React Native apps**: use `debugger-component-tree` — it returns component names with (tap: x,y) coordinates. This is the preferred tool for RN apps on either platform. To use it, resolve the `react-native.md` reference for setup; on Android you must also run `adb -s <serial> reverse tcp:8081 tcp:8081` so Metro is reachable from the device.
   - **Standard app screens and in-app modals**: use `describe`. On iOS this returns the AX tree (falls back to native-devtools when AX is empty); on Android it returns the uiautomator tree in the same DescribeNode shape.
   - **Permission prompts / system modal overlays**: try `describe` first. Fall back to `screenshot` only if the overlay is not exposed reliably.
   - **Fallback**: use `screenshot` to estimate where the desired component is, then verify immediately after the action.
3. **Interact**: Perform the action (`gesture-tap`, `gesture-swipe`, `keyboard`, `button`, ...) — you receive a screenshot automatically.
4. **Verify**: Check the returned screenshot for expected results. If it shows a loading/transitional state, prefer blocking until it settles with `await-ui-element` (expected element `visible`, or a spinner `hidden`) over a guessed delay — but only with a selector you can trust (`text`/`identifier`/`role`) that the screen is known to have or that you saw in a prior `describe`; a guessed one just times out. Otherwise use a short fixed wait. Pick evidence by what's being asserted:
   - **Visual** (layout, spacing, color, typography, image/icon rendering, clipping, overflow, text rendering): prefer `screenshot-diff` against the baseline captured in step 1 — it surfaces pixel-visible changes the auto-screenshot might miss. Fall back to visual inspection of the auto-screenshot only when a stable baseline isn't available.
   - **Structural** (navigation state, element existence, accessibility labels/values, selection, hierarchy, route): verify with `describe`, `debugger-component-tree`, or `native-describe-screen`.
   - **Runtime / log / network** (console errors, API calls, persistence, timing): verify with `view-network-logs`, `debugger-log-registry`, `debugger-evaluate`, or targeted tests.
   - **Mixed**: collect evidence for each relevant class.
   - Report the combined verdict: expected behavior, observed behavior, evidence used, and any blocker for requested visual diffing.
5. **Repeat** for each step in the flow.

### 2. Template

```
Goal: Test [feature name]

Steps:
1. Classify expected result: visual / structural / runtime-log-network / mixed → choose evidence
2. [Navigate / tap / type to reach stable comparable starting point] → verify auto-screenshot
3. screenshot { scale: 1.0, includeImageInContext: false } → save baseline path when visual or mixed evidence needs diffing
4. [Perform the action to test] → verify auto-screenshot
5. Use screenshot-diff when requested or when comparable images add useful visual evidence
6. Report: pass / fail with combined visual, structural, runtime/log/network evidence as applicable
```

### 3. Examples

#### Login flow

```
1. screenshot → see login screen
2. gesture-tap { x: 0.5, y: 0.4 }  → tap email field
3. keyboard { text: "user@example.com" }
4. gesture-tap { x: 0.5, y: 0.55 } → tap password field
5. keyboard { text: "password123" }
6. gesture-tap { x: 0.5, y: 0.7 }  → tap Login button
7. screenshot → verify home screen appeared
```

#### Scroll and navigation

```
1. screenshot → see list at top
2. gesture-swipe { fromY: 0.7, toY: 0.3 } → scroll down
3. gesture-tap item at visible position → verify auto-screenshot
4. screenshot → verify detail view opened
5. button { button: "back" }
6. screenshot → verify returned to list
```

#### Visual behavior check

```
1. Classify expected result as visual or mixed.
2. Navigate to the stable starting state.
3. screenshot { scale: 1.0, includeImageInContext: false } → save baseline path.
4. describe / debugger-component-tree → find the control and use its returned tap coordinates.
5. gesture-tap → perform the visual behavior under test.
6. screenshot-diff { baselinePath, captureCurrent: true, udid, outputDir } → inspect visible change or stability.
7. describe / debugger-component-tree → verify selected state, label, route, or attributes if relevant.
8. Report combined verdict from expected behavior, visual inspection, diff summary, and structural evidence.
```

#### Wait for a loading spinner

```
1. gesture-tap { x: 0.5, y: 0.7 } → trigger an action that fetches data
2. screenshot → loading spinner is showing
3. await-ui-element { condition: hidden, selector: { text: "Loading" } } → block until the fetch finishes and the spinner disappears
4. describe / screenshot → verify the fetched content rendered
```

---

### 4. Recovery Pattern

- If a screen is mid-transition or loading: block until it settles with `await-ui-element` (wait for the target element to be `visible`, or the spinner/placeholder to be `hidden`) instead of a blind fixed delay, then re-check. Fall back to a fixed wait + `screenshot` only when no element reliably marks the transition.
- If tap misses target: re-run discovery tool (`describe` / `debugger-component-tree`), retry once with new coordinates.
- If a permission dialog or modal is visible: re-run `describe` first. Stay in screenshot-driven navigation only when the overlay is not exposed reliably, then switch back to `describe` / `debugger-component-tree` as soon as it is dismissed.
- If tap fails twice at same coordinates: stop, re-discover, report if element not found.
- If a **saved flow** fails during `flow-execute` replay (as opposed to live test steps above): follow `ui-testing-and-flows.md` reference §10 for structured diagnosis and correction.

### Tips

- **Wait on the UI, don't poll.** When a step needs the screen to change first, gate it with `await-ui-element` (block until an element is `visible`/`hidden` or contains `text`) rather than repeated `screenshot` calls with fixed sleeps. See the `await-ui-element` section of `device-interaction.md`.
- **Use `gesture-custom` for long-press** context menus (800ms hold).
- **Report clearly**: state what you expected, what you saw, and the verdict.
- **Permission modals**: try `describe` first. Use `screenshot` only as fallback, tap one visible button at a time, and verify with the returned screenshot before continuing.
- **Record for replay**: If a tested flow is likely to be repeated, use the `ui-testing-and-flows.md` reference to record it as a `.yaml` script. This lets you replay the entire sequence later with a single `flow-execute` call instead of re-running each step manually.

### Related Skills

| Skill                              | When to use                                              |
| ---------------------------------- | -------------------------------------------------------- |
| `device-interaction.md`           | Tool usage for tapping, swiping, typing (iOS + Android)  |
| `ui-testing-and-flows.md`           | Visual regression and before/after screenshot comparison |
| `device-interaction.md`       | Booting and connecting an iOS simulator                  |
| `device-interaction.md`    | Booting and connecting an Android emulator               |
| `react-native.md` | Starting the app, Metro, build issues                    |
| `react-native.md`            | Breakpoints, console logs, JS evaluation                 |
| `ui-testing-and-flows.md`               | Record a test sequence as a replayable flow              |

## Screenshot comparison

### 1. Role

Use `screenshot-diff` as supporting visual evidence for UI QA and visual regression checks. It highlights pixel-visible change or stability; it does not replace visual inspection, accessibility/component-tree state, frame/attribute checks, logs, network evidence, or app behavior.

Do not use screenshot diffing for tap-coordinate discovery. Use `describe`, `debugger-component-tree`, or `native-describe-screen` to find targets first.

### 2. When To Use

Use `screenshot-diff` when pixel comparison can answer the verification question:

- Required for explicit "UI regression test", "visual regression test", "screenshot diff", "compare screenshots", or "before/after visual comparison" requests, unless stable comparable screenshots cannot be produced.
- Good fit when the affected screen has stable before/after states and the expected result is pixel-visible: layout, position, size, spacing, color, typography, image/icon rendering, clipping, overflow, or text rendering.
- Good fit when the risk is unintended visual regression outside the exact element changed.
- Poor fit when the result is better verified structurally: state changes, navigation existence, accessibility tree contents, console/network behavior, or unit tests.
- Poor fit when dynamic content, unpausable animation, timestamps, ads, random data, or missing baseline/current screenshots would make the comparison noisy or meaningless.

### 3. Capture Rules

Use normal downscaled `screenshot` calls for UI context and state checks. Use full-resolution screenshots only when saving baseline/current PNG files for visual regression comparison. Suppress the image block so the full-size PNG is not loaded into context:

```json
{ "udid": "<UDID>", "scale": 1.0, "includeImageInContext": false }
```

Capture the stable baseline before the relevant interaction or before editing whenever feasible. Compare it to the post-change or post-interaction screen after the app reloads, rebuilds, or reaches the state under test.

### 4. Parameters

Provide `udid` and exactly one input for the baseline side and exactly one input for the current side:

- Common UI regression flow: saved baseline plus live current -> `baselinePath`, `captureCurrent: true`, `udid`, `outputDir`.
- Both screenshots already saved -> `baselinePath`, `currentPath`, `udid`, `outputDir`.
- Rare fixture flow: live baseline plus saved current -> `captureBaseline: true`, `currentPath`, `udid`, `outputDir`.
- Do not combine `captureBaseline: true` with `captureCurrent: true`, or provide both a path and live capture flag for the same side.

### 5. Deterministic Flow

1. Navigate to the known-good state.
2. Capture a baseline PNG with `screenshot` using `scale: 1.0` and `includeImageInContext: false`; keep the returned `path`.
3. Perform the interaction, apply the code change and navigate to the state under test.
4. Call `screenshot-diff` with the saved `baselinePath`, `captureCurrent: true`, `udid`, and `outputDir`.
5. Inspect the summary and artifact paths, then combine the diff with normal visual inspection and any structural/runtime evidence needed for the assertion.

```json
{
  "baselinePath": "/tmp/baseline.png",
  "captureCurrent": true,
  "udid": "<UDID>",
  "outputDir": "/tmp/argent-diff"
}
```

If both images are already saved, use file paths for both sides:

```json
{
  "baselinePath": "/tmp/baseline.png",
  "currentPath": "/tmp/current.png",
  "udid": "<UDID>",
  "outputDir": "/tmp/argent-diff"
}
```

## Reusable flow recording and replay

### 1. Overview

A flow is a recorded sequence of MCP tool calls saved to a `.yaml` file in the `.argent/flows/` directory. Each step is **executed live** as you add it, so you verify it works before it becomes part of the flow. Replay a finished flow with `flow-execute`.

### 2. Tools

| Tool                     | Purpose                                                                    |
| ------------------------ | -------------------------------------------------------------------------- |
| `flow-start-recording`   | Start recording — takes a name and executionPrerequisite, creates the file |
| `flow-add-step`          | Execute a tool call live and record it if it succeeds                      |
| `flow-add-echo`          | Add a label/comment that prints during replay                              |
| `flow-finish-recording`  | Stop recording and get a summary                                           |
| `flow-read-prerequisite` | Read a flow's execution prerequisite without running it                    |
| `flow-execute`           | Replay a saved flow by name                                                |

### 3. Workflow

#### Recording

1. **Start**: Call `flow-start-recording` with a descriptive name, the absolute `project_root`, and an `executionPrerequisite` describing the required app state before running the flow (e.g. "App on home screen after a fresh reload"). `project_root` is stored for the session — you do **not** need to pass it again to subsequent tools.
2. **Build step-by-step**: For each action, call `flow-add-step` with the tool name and args. The tool runs immediately — check the result before moving on.
3. **Add labels**: Use `flow-add-echo` between steps to describe what each section does.
4. **Finish**: Call `flow-finish-recording` to stop recording. It returns the file path where the flow was saved and a summary of all steps. You can edit the `.yaml` file directly afterwards to remove, reorder, or tweak steps.

Every tool during recording returns the current flow file contents so you can track what has been recorded.

#### Replaying

Call `flow-execute` with the flow name. If the flow has an execution prerequisite:

1. The tool returns a **notice** with the prerequisite text instead of running. It asks you to verify the prerequisite is met and call `flow-execute` again with `prerequisiteAcknowledged: true`.
2. You can also call `flow-read-prerequisite` beforehand to inspect the prerequisite without triggering a run.
3. Once you pass `prerequisiteAcknowledged: true`, the flow runs all steps in order and returns every tool call result (including screenshots) merged into a single response.

If the flow has no prerequisite, it runs immediately without needing acknowledgment.

### 4. flow-add-step Usage

The `command` parameter is the MCP tool name. The `args` parameter is a **JSON string** (not an object):

```
command: "launch-app"
args: "{\"udid\": \"<UDID>\", \"bundleId\": \"com.apple.Preferences\"}"
```

```
command: "gesture-tap"
args: "{\"udid\": \"<UDID>\", \"x\": 0.5, \"y\": 0.35}"
```

```
command: "screenshot"
args: "{\"udid\": \"<UDID>\"}"
```

```
command: "await-ui-element"
args: "{\"udid\": \"<UDID>\", \"condition\": \"visible\", \"selector\": {\"text\": \"Continue\"}}"
```

Record an `await-ui-element` step to **gate** the next step on a screen transition — it blocks until the element is `visible`/`hidden` (or contains `text`), so the following step runs only once the screen has actually settled. If its condition is not met before the timeout, replay **stops at that step** (the steps after it assume the transition happened). Prefer this over a fixed `delayMs`. See the `await-ui-element` section of `device-interaction.md` for the full condition/selector reference.

For tools with no arguments, omit `args` entirely.

### 5. Important Rules

- **Every step runs live.** You will see the real tool result (including screenshots). Use this to verify the step worked before continuing.
- **Only successful steps are recorded.** If a tool call fails, nothing is written to the flow file — fix the issue and try again.
- **Pass `project_root` only to `flow-start-recording`.** It is stored for the session and automatically used by all subsequent flow tools. An error is returned if the path is not absolute.
- **You do NOT need to pass a flow name** to `flow-add-step`, `flow-add-echo`, or `flow-finish-recording`. The active flow is tracked automatically after `flow-start-recording`.
- **Start before adding.** Calling `flow-add-step`, `flow-add-echo`, or `flow-finish-recording` without an active recording returns an error: _"No active flow. Call flow-start-recording first."_
- **One flow at a time.** If you call `flow-start-recording` while already recording, the active flow switches to the new one. The response tells you which flow was abandoned and which is now active. The old flow's file remains on disk.
- **Mistakes can be edited out.** If a step was recorded by mistake, edit the `.yaml` file directly to remove or reorder entries.

### 6. Example Session

```
flow-start-recording  { name: "open-settings", project_root: "/Users/dev/MyApp", executionPrerequisite: "Simulator booted with app installed" }
flow-add-echo  { message: "Launch Settings app" }
flow-add-step  { command: "launch-app", args: "{\"udid\": \"ABC\", \"bundleId\": \"com.apple.Preferences\"}" }
flow-add-echo  { message: "Tap General" }
flow-add-step  { command: "gesture-tap", args: "{\"udid\": \"ABC\", \"x\": 0.5, \"y\": 0.35}" }
flow-add-echo  { message: "Tap About" }
flow-add-step  { command: "gesture-tap", args: "{\"udid\": \"ABC\", \"x\": 0.5, \"y\": 0.17}" }
flow-finish-recording  {}
```

### 7. Replay Example

```
flow-execute   { name: "open-settings", project_root: "/Users/dev/MyApp" }
→ Returns: notice with executionPrerequisite: "Simulator booted with app installed"
  "Verify the prerequisite is met and call flow-execute again with prerequisiteAcknowledged set to true."

flow-execute   { name: "open-settings", project_root: "/Users/dev/MyApp", prerequisiteAcknowledged: true }
→ Runs all steps, returns merged results with status and output for every step
```

### 8. Flow File Format

Flow files use YAML. The top-level is an object with `executionPrerequisite` (describes required state) and `steps` (array of actions):

- `- echo: <message>` — a label
- `- tool: <name>` with optional `args:` — a tool call. A tool step may also carry `delayMs: <ms>` to sleep that long before it runs. (`await-ui-element` is an ordinary tool step; see §4 and §10.5 for when to gate a transition with one.)

Example `.yaml` file:

```yaml
executionPrerequisite: Simulator booted with app installed
steps:
  - echo: Launch Settings app
  - tool: launch-app
    args:
      udid: ABC
      bundleId: com.apple.Preferences
  - echo: Wait for the Settings list to render
  - tool: await-ui-element
    args:
      udid: ABC
      condition: visible
      selector:
        text: General
  - echo: Tap General
  - tool: gesture-tap
    args:
      udid: ABC
      x: 0.5
      y: 0.35
  - echo: Tap About
  - tool: gesture-tap
    args:
      udid: ABC
      x: 0.5
      y: 0.17
```

### 9. When to Proactively Record a Flow

You do not need the user to ask for a flow. Record one proactively when you recognize any of these patterns:

- **About to re-profile**: You completed a profiling session and are about to apply a fix and re-profile. Record the interaction steps now so the re-profile replays them identically (see `profiling.md` and `profiling.md` references).
- **Repeating steps**: You have already performed a multi-step interaction sequence once and the task requires doing it again (comparison, retry, re-test).
- **Complex path discovered**: You worked through a non-trivial sequence of taps/swipes/navigation to reach a desired app state. Capture it before it is lost.
- **User says "again" / "one more time"**: Any request to redo what you just did is a signal to record first, then replay.

### 10. Flow Self-Improvement

Flows break. UI layouts change, coordinates drift, screens get added or removed. When `flow-execute` returns a failure, follow this procedure to diagnose and fix the flow instead of silently re-recording or giving up.

#### 10.1 Classify the Result

After every `flow-execute`, classify the outcome before proceeding:

| Outcome                | Signal                                                                | Action             |
| ---------------------- | --------------------------------------------------------------------- | ------------------ |
| **Success**            | All steps completed, final screenshot shows expected state            | Continue with task |
| **Hard error**         | A step has `ERROR` in the result — engine stopped there               | Enter §10.2        |
| **Silent misfire**     | All steps completed but final screenshot shows wrong screen           | Enter §10.2        |
| **Partial divergence** | Intermediate screenshot shows wrong state even though later steps ran | Enter §10.2        |

For silent misfires and partial divergence, echo annotations (§10.5) are your reference for what each screen _should_ look like.

#### 10.2 Diagnose

1. Note the failure step index and error message (if hard error).
2. Call `screenshot` to see where the app actually is now.
3. Call `describe` or `debugger-component-tree` to get the current element tree.
4. Compare current state to what the failed step expected. Classify the root cause:

| Root cause       | Symptoms                                                        |
| ---------------- | --------------------------------------------------------------- |
| Coordinate drift | Tap succeeded but hit wrong element; elements shifted positions |
| Missing element  | Target element not present in element tree                      |
| Wrong screen     | Screenshot shows entirely different page than expected          |
| Timing           | Element exists in tree but tap missed; loading spinner visible  |
| State mismatch   | First step fails — executionPrerequisite was not actually met   |

5. State the diagnosis in one sentence before attempting any correction.

#### 10.3 Correct

Choose the lightest strategy that fits:

**Strategy 1 — Edit the YAML** (coordinate drift, parameter changes).
Read `.argent/flows/<flow-name>.yaml`, update the broken step's `x`/`y`, `bundleId`, `text`, or other args. Re-run `flow-execute` to verify.

**Strategy 2 — Manual recovery + continue** (timing/transient issues, one-off replay).
Manually execute the failed step with corrected coordinates from §10.2 discovery, then manually execute remaining steps. Does not fix the YAML — use only when re-recording is not worth it.

**Strategy 3 — Re-record from failure point** (structural changes, new intermediate screens).
Navigate the app to the state just before the failure point. Call `flow-start-recording` with the same flow name (overwrites). Re-add the working prefix steps via `flow-add-step`, then continue recording new steps from the divergence point. Call `flow-finish-recording`.

**Strategy 4 — Full re-record** (major changes, unclear diagnosis, or 3+ broken steps).
Reset the app to prerequisite state (`restart-app` + `launch-app`). Record from scratch with the same flow name.

**Decision heuristic:**

- 1 step broken, parameter-only change → Strategy 1
- 1 step broken, transient issue, not worth persisting → Strategy 2
- 2–3 steps broken or flow structure partially changed → Strategy 3
- 3+ steps broken, or unclear root cause → Strategy 4
- Flow used for profiling comparison (must be identical) → Strategy 4

#### 10.4 Verify and Bound Retries

After applying a correction, re-run `flow-execute` to verify.

- If it succeeds → done. Report what changed (e.g. "Fixed step 4: updated tap coordinates from 0.5,0.35 to 0.5,0.42").
- If it fails at a **different** step → return to §10.2 for a second attempt.
- If this is already the second correction attempt → **stop**. Report the diagnosis to the user and recommend a full re-record or manual investigation.

**Hard cap: 2 correction cycles.** Do not enter an unbounded fix loop.

#### 10.5 Making Flows Resilient

Apply these when recording new flows to reduce future breakage:

- **Echo expected state, not just actions.** Write `"On Settings > General screen, about to tap About"` not `"Tap About"`. During diagnosis these tell you what the screen _should_ look like.
- **Gate transitions with `await-ui-element`, not fixed delays.** After a tap that triggers a navigation, record an `await-ui-element` step that waits for the next screen's element to be `visible` (or a spinner to be `hidden`) before the following step. This removes the **Timing** failure mode in §10.2 (the element is in the tree but the tap fired before the screen settled) and is more reliable than `delayMs` or an extra `screenshot`. An unmet wait stops replay at that step, so a mistimed step can never run blind.
- **Add screenshot steps after critical navigation.** Insert `screenshot` steps after screen transitions. These produce images in the flow result you can inspect during diagnosis.
- **Write specific executionPrerequisites.** `"App on home tab, user logged in, simulator UDID is <X>"` — not `"App running"`. Verify with `screenshot` + `describe` before acknowledging.
- **Prefer launch-app / open-url over navigation chains.** Deep links are more resilient to layout changes than tap sequences.
- **Echo accessibility labels for coordinate taps.** When recording a tap, add an echo with the target's label or testID: `"Tapping 'Submit' button (testID: submit-btn) at 0.5, 0.82"`. During repair, use `describe` to find the element by label and update coordinates. Only use `screenshot` for permission or system overlays when `describe` cannot expose the target reliably.
