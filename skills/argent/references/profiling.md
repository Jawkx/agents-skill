# Profiling

> Part of the unified `argent` skill. Return to [`../SKILL.md`](../SKILL.md) for task routing.

## React Native optimization

### Rules

- Do not apply shotgun optimizations. Measure first, define what "good enough" looks like (target metric + threshold), fix the top offender, re-measure honestly.
- **Quick scan** — `react-profiler-renders` for a live render count table. Identifies hot components instantly.
- **Deep measure** — load `profiling.md` reference. `react-profiler-start` → interact → `react-profiler-stop` → `react-profiler-analyze`.
- **Inspect** — `react-profiler-component-source` per finding. `react-profiler-fiber-tree` to trace component ancestry and render cost.
- **Verify correctness** - before fixing, recollect information from steps above and make a logical conclusion whether the approach is worth undertaking.
- **Fix** — apply one fix. Validate with `debugger-evaluate` before committing.
- **Re-measure** — report whether the target metric improved, regressed, or stayed flat. Check for regressions in other areas. If no net benefit or unacceptable tradeoffs, revert.
- **Profile for discovery, not only verification.** Use the profiler to find issues static analysis missed, not only to confirm fixes.
- **One fix per cycle for architectural changes.** Mechanical batch fixes (inline styles, index keys) can be grouped — re-profile once after the batch. When the measurement involves device interaction, record it as a flow (`ui-testing-and-flows.md` reference) before the first run so all subsequent cycles replay identical steps.
- **React Compiler**: if `react-profiler-analyze` reports `reactCompilerEnabled: true`, do NOT propose `useCallback`/`useMemo`/`React.memo` unless you confirmed compiler bail-out via `react-profiler-fiber-tree` (absent `useMemoCache`).
- **Sub-agents**: Phases 1–2 dispatch sub-agents — one per file for lint results, one per checklist item for semantic. Sub-agents CANNOT touch the device - all profiling and E2E verification must happen in the main agent.

### Pipeline

**Lint and semantic sweeps catch deterministic issues cheaply. Profiling finds runtime bottlenecks that static analysis misses. Do both.**

Copy this checklist into your TODO list:

```
Optimization Progress:
- [ ] Phase 1: Lint sweep (deterministic — catch mechanical issues without a running app)
- [ ] Phase 2: Semantic sweep (judgment — memoization, lists, animations, etc.)
- [ ] Phase 3: Baseline profile (find real bottlenecks, fix top offenders)
- [ ] Phase 4: Verify no regressions (crashes, errors, red screens)
```

#### Phase 1: Lint sweep

Run ESLint once at the project root with a comprehensive RN performance ruleset. Dispatch sub-agents to fix results — one per file.
See [optimization-lint-rules.md](optimization-lint-rules.md) for ruleset and procedure.

#### Phase 2: Semantic sweep

Review each area requiring judgment — memoization, list rendering, animations, async patterns, effect cleanup, state hygiene, context architecture. Dispatch one sub-agent per checklist item.
See [optimization-semantic-checklist.md](optimization-semantic-checklist.md) for full checklist.

#### Phase 3: Visual profiling

1. Load `profiling.md` reference, start dual profiling
2. Exercise key user flows (navigate screens the user specified, or all major flows)
3. Analyze with `react-profiler-analyze` + `native-profiler-analyze` + `profiler-combined-report`
4. Cross-reference profiling results with Phase 1–2 findings
5. Fix highest-impact issues. Re-profile after architectural changes; batch mechanical fixes. If a recorded flow breaks after a fix (e.g., UI layout changed), follow `ui-testing-and-flows.md` reference to repair the flow rather than silently discarding it.

#### Phase 4: Verify no regressions

Navigate every screen and UI flow within scope, confirm each renders without errors. If no scope was specified, verify the entire app — cover all reachable screens via `device-interaction.md`. Use `debugger-log-registry` to check for runtime errors and take screenshots to check for red/yellow error screens. Check for regressions introduced by fixes (e.g., fewer re-renders but higher CPU, or new jank in a different screen). Main agent only.

### App-wide optimization

1. **Phase 1**: run lint centrally (one command), dispatch sub-agents to fix per-file in parallel
2. **Phase 2**: one sub-agent per checklist item for semantic sweep
3. **Phase 3**: main agent profiles top offending screens; fixes architectural issues top-down
4. **Phase 4**: main agent navigates all screens to verify nothing crashes

After the entire run, run lint again to verify no new issues were introduced with your changes.
This also helps ensure you haven't missed any issues which could've been fixed.

## React Native profiler

This skill is complementary to `profiling.md`, not a replacement for it.

### 2. Tool Overview

#### React Profiler (Hermes / React commits)

| Tool                              | Purpose                                                                                                                                                                                                                                                           |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `react-profiler-start`            | Start CPU sampling + inject React commit-capture hook. Optional: `sample_interval_us` (default 100).                                                                                                                                                              |
| `react-profiler-stop`             | Stop recording; stores cpuProfile + commitTree in session.                                                                                                                                                                                                        |
| `react-profiler-status`           | **Call if you were interrupted in the middle of the flow, never in another scenario** (debugger drop, Metro reload, pause, subagent handoff, any doubt). Returns `session_status: "active" \| "taken_over" \| "stopped" \| "no_react_runtime"`. Side-effect free. |
| `react-profiler-analyze`          | Run pipeline -> report with CPU-enriched hot commits, sorted by `totalRenderMs` DESC. Saves raw data to disk.                                                                                                                                                     |
| `react-profiler-component-source` | AST lookup: file, line, memoization status, 50 lines of source for a component.                                                                                                                                                                                   |
| `react-profiler-renders`          | Live fiber walk: render counts + durations per component (no profiling session required).                                                                                                                                                                         |
| `react-profiler-fiber-tree`       | Live fiber walk: full component hierarchy as JSON.                                                                                                                                                                                                                |

#### Drill-Down Query Tools (call after analyze)

| Tool                       | Purpose                                                                                      |
| -------------------------- | -------------------------------------------------------------------------------------------- |
| `profiler-cpu-query`       | Targeted CPU investigation: top functions, time-windowed CPU, call trees, per-component CPU. |
| `profiler-commit-query`    | Targeted commit investigation: by component, time range, commit index, or cascade tree.      |
| `profiler-stack-query`     | iOS Instruments drill-down: hang stacks, function callers, thread breakdown, leak details.   |
| `profiler-combined-report` | Cross-correlated report when both React Profiler and native profiler ran in parallel.        |
| `profiler-load`            | List and reload previous profiling sessions from disk for re-investigation with query tools. |

For native profiling (CPU hotspots, UI hangs, memory leaks), see the `profiling.md` reference.

---

### 3. Agent Behavior Guidelines

Follow these rules throughout the profiling workflow:

- Start `react-profiler-start` and `native-profiler-start` in parallel (two tool calls in one message). Both need `device_id`; use the same UDID for both so their data can be correlated later. This gives best coverage.
- If the user only wants native profiling, use the `profiling.md` reference workflow. Only skip `native-profiler-start` if the user has **already explicitly said** they don't want native profiling in this session

#### After analysis: ask about next steps

After presenting the analysis report, always ask the user what they want to do next. Present these options:

1. **Investigate further** — drill down into specific findings using query tools (CPU call trees, commit cascades, hang stacks, etc.) to identify root causes with confidence before making changes.
2. **Implement fixes** — apply changes based on the current findings, then re-profile to measure whether the metric changed (improved, regressed, or stayed flat).
3. **Done for now** — accept the report as-is.

Do NOT silently move on after the report. The report is the starting point, not the end — query tools exist specifically to let you dig deeper into anything the report flags.

#### During investigation: use query tools proactively

When drilling down, chain query tool calls based on what you find:

- A hot commit -> `profiler-commit-query` mode=`by_index` to see all components -> `profiler-cpu-query` mode=`component_cpu` for the slowest one -> `profiler-cpu-query` mode=`call_tree` for the hot function -> read the source file -> propose a fix.
- A memory leak -> `profiler-stack-query` mode=`leak_stacks` to identify the responsible module -> read the native source if actionable.
- A native hang -> `profiler-stack-query` mode=`hang_stacks` to get the native call chain -> correlate with React commit timing.

#### After fixes: always re-profile

When you apply a fix, always re-profile the same scenario afterward. Compare before/after metrics (commit durations, CPU time, render counts) and report honestly: did the target metric improve, stay flat, or regress? Did any _other_ metric get worse? If you need to reference the original data, use `profiler-load` to reload the pre-fix session. If the fix showed no improvement or introduced a regression, say so explicitly and reconsider the approach.

#### Use flows for reproducible profiling

When profiling requires a specific interaction sequence (scroll a list, navigate screens, trigger an animation), **record the interaction as a flow** using the `ui-testing-and-flows.md` reference before the first profiling run. Then replay the same flow for every subsequent run. This eliminates interaction variance as a confounder and makes before/after comparisons meaningful. Especially important when:

- You are about to re-profile after applying a fix (Step 8).
- The user asks you to compare multiple profiling sessions.
- The interaction path is more than 2-3 steps long.

---

### 4. Standard Profiling Workflow

**Complete all steps in order — do not break mid-flow.**

#### Step 1: Start profiling

Mind the react-native and ios-native profiler selection mentioned above when starting the session and start the tools. **Save `startedAtEpochMs` from the response** — you will need it for annotation offsets. Every subsequent profiler/query call in this session must use the same `device_id`. Before beginning, define lightweight success criteria with the user: which metric matters most (e.g., `totalRenderMs`, specific commit duration, render count for a component) and what threshold would be meaningful. This anchors later evaluation. On success:

- if user asked you to perform the profiling, determine how to profile yourself using tools described in `device-interaction.md` reference.
- if the user stated they wish to perform the interaction themselves — suggest what interaction to perform (e.g. "scroll the list", "switch tabs") and wait for their reply.
  If you received information about **existing profiling session** being owned by another agent:
- if session is marked as "stale", you may overtake it without prompting the user for allowance
- if session is NOT "stale" - before taking action and terminating the other session, **stop and ask user what you should do**, explaining the situation.

##### Annotate every interaction

After each `gesture-tap` or `gesture-swipe` call, record an annotation using the returned `timestampMs`. Compute `offsetMs = timestampMs - startedAtEpochMs`. Do this for _every_ interaction — including back-navigation swipes, not just the primary action. Pass all collected annotations to `react-profiler-analyze` in Step 3.

#### Step 2: Stop and collect

Call `react-profiler-stop` **and** `native-profiler-stop` in parallel. Only skip `native-profiler-stop` if you did not start it in Step 1. Note `duration_ms` and `fiber_renders_captured`.
If `fiber_renders_captured: 0`, warn the user — React commit data may be missing.

#### Step 3: Analyze

Call `react-profiler-analyze` with `port`, `device_id`, `project_root`, `platform`, and `rn_version`. The report includes metadata such as `reactCompilerEnabled`, `strictModeEnabled`, and `buildMode` — check these in the returned markdown report.

If you performed interactions using `gesture-tap`/`gesture-swipe`, pass `annotations` to mark when each action occurred. Each annotation's `offsetMs` must be computed as `tapTimestampMs - startedAtEpochMs`, where `tapTimestampMs` is the `timestampMs` returned by the gesture-tap/gesture-swipe tool and `startedAtEpochMs` was returned by `react-profiler-start`. Do **not** use `Date.now()` for this calculation — only server-side timestamps from the tool return values.

If dual profiling, also call `native-profiler-analyze`, then **you must** call `profiler-combined-report` for the cross-correlated view — do not skip this step when both profilers ran; the combined report surfaces correlations that individual reports miss.

The analyze report includes **CPU hotspots per commit** — showing exactly which JS functions ran during each slow React commit. Raw data is saved to disk automatically for later reload.

#### Step 4: Assess results

Analyze whether the results give you a proper image of what is wrong with the application - **do not assume improvement always exists**, verify results logically with reference to how react-native works. Make sure to give honest feedback and be ready to change the approach if needed.

#### Step 5: Present findings and ask about next steps

Present a concise summary of the key findings - present whether possibilities for improvement exist and how performing further actions could affect performance. Then follow the "After analysis" guideline — ask whether to investigate further, implement fixes (if available), or stop.

#### Step 6: Drill-down investigation (iterative)

Based on findings from the report, use query tools to investigate deeper:

- **Slow component?** -> `profiler-cpu-query` mode=`component_cpu` component_name=`AppNavigator` — shows what JS functions ran during that component's commits.
- **Want to see the call tree?** -> `profiler-cpu-query` mode=`call_tree` function_name=`expensiveFunction` — shows callers and callees.
- **What happened during a time window?** -> `profiler-commit-query` mode=`by_time_range` — lists all commits in a range.
- **Full commit detail?** -> `profiler-commit-query` mode=`by_index` commit_index=38 — all components, props changes, parent cascade.
- **Who triggered whom?** -> `profiler-commit-query` mode=`cascade_tree` — visual parent-child cascade.
- **iOS hang details?** -> `profiler-stack-query` mode=`hang_stacks` — native call stacks during a hang.

Repeat as needed until you identify the root cause function and file, referring to step 4 for honest evaluation. After each round of investigation, ask the user if they want to continue digging or move to fixing.

#### Step 7: Reload a previous session

If you profiled multiple scenarios and need to revisit earlier data:

1. Call `profiler-load` mode=`list` to see all saved sessions with timestamps (the list now also shows Runtime / Device / Metro bundle columns to help identify the right session).
2. Call `profiler-load` mode=`load_react` session_id=`<timestamp>` device_id=`<UDID>` to reload React data. `device_id` scopes the reload into the `port:device_id` cache slot.
3. Call `profiler-load` mode=`load_native` session_id=`<timestamp>` device_id=`<UDID>` to reload native profiler data.
4. Query tools now operate on the reloaded session data — **pass the same `device_id` you loaded with**, otherwise they will miss the cache.

This is useful for before/after comparisons: profile, fix, re-profile, then reload the original session to compare metrics side by side.

#### Step 8: Apply fix and re-profile

If fix is present, read the source code of the identified bottleneck using `react-profiler-component-source` or the Read tool. Apply the fix, then re-profile (Step 1 -> user interaction -> Step 2 -> Step 3 -> Step 4). Report whether the target metric improved, stayed flat, or regressed. Also check whether the fix introduced regressions in other metrics (e.g., render count dropped but CPU time increased, or a different component now re-renders more). If the fix showed no net benefit or unacceptable tradeoffs, revert and reconsider.

**Tip:** If the interaction sequence was recorded as a flow (see "Use flows for reproducible profiling" above), replay it with `flow-execute` instead of manually repeating the steps. This guarantees identical interaction conditions for the comparison. If the flow fails during replay (e.g., a UI fix changed the layout), follow `ui-testing-and-flows.md` reference §10 (Flow Self-Improvement) to diagnose and repair the flow before retrying the profiling cycle.

If the user stated that they do not wish for changes, present the profiling report and skip the fix but suggest it to the user.

**React Compiler rule:** If the analyze report indicates React Compiler is enabled, do NOT propose `useCallback`/`useMemo`/`React.memo` unless you confirmed compiler bail-out (check `react-profiler-fiber-tree` for absent `useMemoCache` on that component).

---

### 5. Important Caveats

- **Dev mode inflation**: `buildMode: "dev"` renders are ~3x slower than production. Prioritize high `normalizedRenderCount` — it scales to prod.
- **Re-run after fixes**: Always re-profile after changes. Report honestly whether the metric improved, regressed, or stayed flat — do not assume improvement.
- **`excluded` is informational**: Components in `animatedSubtrees` and `recyclerChildren` re-render by design.
- **Strict Mode**: Double-invokes renders. The pipeline halves `normalizedRenderCount` automatically when detected.
- **Debugger connection**: If interrupted, started profiling also closes. Before attempting recovery, call `react-profiler-status` — it tells you whether the session is `active`, `taken_over`, `stopped`, or `no_react_runtime`, so you can decide whether to stop, restart, or reconnect first.
- **Confounders to watch for**:
  - Live API data may differ between runs (different payload sizes, content counts), which shifts render counts and durations independently of your fix. Note when data-dependent components show variance.
  - Profiler overhead inflates CPU measurements. If iOS Instruments shows `JSLexer`, `JSONEmitter`, or Hermes internals dominating the JS thread, that reflects profiler instrumentation cost — not app work. Discount those entries.
  - Runs are not perfectly reproducible. Small variations (under ~10-15%) in commit duration may be noise; only treat consistent, directional changes as signal.

For standalone diagnostic tools (live render stats, fiber tree, CPU summary), see `profiler-diagnostic-tools.md`.

## Native profiler

### 1. Tools

- `native-profiler-start` — start profiling on a booted device. iOS: xctrace recording for CPU, hangs, and leaks.
- `native-profiler-stop` — stop the profiler and export trace data to timestamped XML files.
- `native-profiler-analyze` — parse exported trace data and return a structured bottleneck payload.
- `profiler-stack-query` — drill into parsed data: hang stacks, function callers, thread breakdown, leak details.
- `profiler-load` — list and reload previous trace sessions from disk for re-investigation.

---

### 2. Platform Support

- **iOS**: Backend: Xcode Instruments via `xctrace` on a booted simulator or connected device. Requires Xcode command-line tools on PATH. Surfaces CPU hotspots, UI hangs, and memory leaks (instruments `Leaks` table).
- **Android**: Backend: Perfetto via `adb shell perfetto` + an in-process WASM trace-processor engine. Surfaces CPU hotspots and UI hangs, with per-hang jank reason codes, a main-thread state breakdown with `blocked_function` attribution, and a GC overlap annotation. Also reports an RSS-growth signal for memory pressure; treat it as a hint to confirm manually, not a confirmed leak. The target app must be debuggable or include `<profileable android:shell="true"/>` in its manifest for `perf_sample` callstacks to be captured.

---

### 3. Investigation Patterns

After `native-profiler-analyze` surfaces findings, use `profiler-stack-query` to drill into root causes:

- **Hang detected** → `profiler-stack-query` mode=`hang_stacks` for full native call chains → mode=`function_callers` for the suspected function → read native source.
- **CPU hotspot** → `profiler-stack-query` mode=`thread_breakdown` for per-thread distribution → mode=`function_callers` for the dominant function.
- **Memory leak** → `profiler-stack-query` mode=`leak_stacks` filtered by `object_type` for responsible frames and libraries.

After presenting findings, ask the user whether to investigate further, implement fixes, or stop. After applying fixes, always re-profile the same scenario and compare with `profiler-load`. Report honestly whether the target metric improved, regressed, or stayed flat. If the fix showed no net benefit or introduced regressions elsewhere, say so and reconsider.

**Tip:** For reproducible before/after comparisons, record the interaction sequence as a flow using the `ui-testing-and-flows.md` reference before the first profiling run. Replay with `flow-execute` on subsequent runs to eliminate interaction variance.

> **Note:** The `profiling.md` instructs to start native profiling automatically alongside React profiling. This skill's workflow and investigation patterns apply in both cases.

---

### 4. Workflow

**Complete all steps in order — do not break mid-flow.**

#### Step 0: Ensure the target app is running

The `native-profiler-start` tool **auto-detects** the running app on the device.
You do not need to derive `app_process` manually — just make sure the app is launched.

1. If the app is already running on the device, skip to Step 1 (do not pass `app_process`).
2. If the app is not running, use `launch-app` with the correct bundle ID first.
3. Only pass `app_process` explicitly if the tool reports multiple running user apps and you need to disambiguate.

> **Note**: If multiple build flavors are installed (dev, staging, prod), the tool will detect whichever one is currently running. If both are running, it will ask you to specify.

#### Step 1: Start recording

Call `native-profiler-start` with `device_id` (iOS UDID or Android serial). The tool auto-detects the running app and saves the trace to `/tmp/argent-profiler-cwd/` with a timestamped filename.
Let the user interact with the app or drive interaction via simulator tools (see `device-interaction.md` reference).

#### Step 2: Stop and export

Call `native-profiler-stop` with `device_id`. iOS sends SIGINT to xctrace, waits for trace packaging, and exports CPU, hangs, and leaks data to XML — check `exportDiagnostics` for any export warnings. Android sends SIGTERM to the on-device perfetto daemon, polls `/proc/<pid>` until it exits, then `adb pull`s the `.pftrace` to the host.

#### Step 3: Analyze

Call `native-profiler-analyze` with `device_id`. Returns a markdown report with bottlenecks categorized as CPU hotspots, UI hangs, or memory leaks, sorted by severity.

#### Step 4: Present findings and ask about next steps

Present a concise summary of the key findings. Then follow the "After analysis" guideline — ask whether to investigate further with query tools, implement fixes, or stop.

#### Step 5: Drill-down investigation

Use `profiler-stack-query` to investigate specific findings. See §3 Investigation Patterns for chaining guidance.

#### Step 6: Reload previous sessions

To revisit a previous trace:

1. Call `profiler-load` mode=`list` to see available sessions.
2. Call `profiler-load` mode=`load_native` session_id=`<timestamp>` device_id=`<UDID>` to re-parse the XML files.
3. Use `profiler-stack-query` to investigate the reloaded data.

---

### 5. Understanding Results

Bottlenecks are categorized by severity:

- **RED**: CPU functions taking >15% of total time, all UI hangs, and **attributed** memory leaks (those with a resolved responsible frame). These require immediate attention.
- **YELLOW**: CPU functions taking 3-15% of total time, and **unattributed** memory leaks (`<Call stack limit reached>`, no library — see the memory-leaks caveat below). Worth investigating but may be acceptable.

Each bottleneck type indicates a different class of problem:

- **CPU hotspots**: Native functions consuming excessive CPU time. Look for tight loops, expensive computations, or redundant work.
- **UI hangs**: Main thread blocked long enough to cause visible jank or unresponsiveness. Often caused by synchronous I/O, heavy layout passes, or lock contention.
- **Memory leaks**: Objects allocated but never freed. Common causes include retain cycles, unclosed resources, or forgotten observers. Argent records via `xctrace --attach`, which has no malloc-stack history, so on the simulator most leaks come back **unattributed** (`<Call stack limit reached>`, no library) and are dominated by benign system allocations — these are reported as a low-confidence YELLOW summary, not confirmed RED leaks. For attributed stacks, capture with malloc stack logging enabled at launch.

---

### 6. Important Caveats

- **Simulator vs device**: Simulator profiling reflects host Mac performance, not real device hardware. Use device profiling for accurate CPU timings and memory behavior.
- **xctrace availability (iOS)**: Requires Xcode command-line tools installed. Verify with `xcrun xctrace version`.
- **Profiler overhead**: xctrace instrumentation adds CPU load. If `JSLexer`, `JSONEmitter`, or Hermes runtime internals dominate the JS thread in CPU hotspot results, those reflect profiler overhead — not app work. Discount those entries when evaluating findings.
- **Run-to-run variance**: Small fluctuations in CPU percentages between runs are normal. Treat only consistent directional changes (across 2+ runs or >15% delta) as actionable signal.
- **Live data variability**: If the app fetches live API data, different responses between runs change rendering workload independently of code changes. Note when data-dependent screens show variance.
