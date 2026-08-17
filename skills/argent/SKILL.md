---
name: argent
description: Use Argent tools for iOS, Android, tvOS, Android TV, React Native, don't use it for web application. Covers device setup and interaction, UI testing, screenshots and visual diffs, reusable flows, Metro/CDP debugging, React and native profiling, performance optimization, and Argent Lens design variants. Use whenever a task involves Argent, a simulator/emulator/TV device, app UI automation or QA, React Native runtime debugging or profiling, screenshot comparison, flow recording, or Lens proposals.
---

# Argent

Use this file as the router. Read only the reference documents relevant to the task, but read each selected document completely before acting.

## Route the task

| Task | Read |
| --- | --- |
| Find/boot a device; tap, swipe, type, launch, inspect, or control mobile/Chromium/TV UI | [references/device-interaction.md](references/device-interaction.md) |
| Start/build a React Native app; connect Metro/CDP; inspect components, logs, network, or evaluate JS | [references/react-native.md](references/react-native.md) |
| Test a UI flow; compare screenshots; record, replay, or repair a reusable flow | [references/ui-testing-and-flows.md](references/ui-testing-and-flows.md) |
| Diagnose performance; profile React/native code; optimize re-renders, CPU, hangs, memory, jank, or startup | [references/profiling.md](references/profiling.md) |
| Build multiple real design variants and ask the human to choose in Argent Lens | [references/lens.md](references/lens.md) |

Read multiple references when the task crosses workflows. For example, React Native UI testing normally needs `device-interaction.md`, `react-native.md`, and `ui-testing-and-flows.md`; profiling also needs `profiling.md`.

## Universal rules

1. Start with `list-devices`; use its `platform`, `runtimeKind`, state, and id rather than guessing the target type.
2. IDs auto-dispatch: iOS/tvOS UUID, Android adb serial, Vega serial, or `chromium-cdp-<port>`. Tools generally call this argument `udid`; debugger/profiler tools generally call it `device_id`.
3. A target with `runtimeKind: "tv"` or `platform: "vega"` is focus-driven. Never use coordinate gestures; use `describe`, `tv-remote`, and `keyboard`.
4. On touch targets, discover controls with `describe` first. For React Native, use `debugger-component-tree` when the accessibility tree is insufficient. Use screenshots for visual state and as a final discovery fallback, not routine coordinate guessing.
5. Gesture coordinates are normalized `0.0–1.0`. `debugger-inspect-element` is the exception: it takes logical pixels.
6. Prefer `launch-app`, `restart-app`, and `open-url` over navigating from the home screen.
7. Gate transitions with `await-ui-element` when a reliable selector exists. Do not replace observable state with blind delays.
8. Android React Native requires `adb -s <serial> reverse tcp:8081 tcp:8081` (or the configured Metro port), repeated after a device/adb restart.
9. Measure performance before optimizing and re-measure the identical scenario after every fix. Record repeatable interaction paths as flows.
10. For visible changes, collect the evidence appropriate to the assertion: visual (`screenshot-diff`), structural (`describe`/component tree), and runtime (`logs`/network/evaluation/tests`).

## Supporting references

Open these only when directed by a workflow:

- [references/gesture-examples.md](references/gesture-examples.md) — custom, pinch, rotate, long-press, and drag gestures.
- [references/debugger-failure-scenarios.md](references/debugger-failure-scenarios.md) — Metro/CDP recovery.
- [references/debugger-source-maps.md](references/debugger-source-maps.md) — component-to-source resolution.
- [references/profiler-diagnostic-tools.md](references/profiler-diagnostic-tools.md) — standalone and post-analysis profiler queries.
- [references/optimization-lint-rules.md](references/optimization-lint-rules.md) — deterministic RN performance lint sweep.
- [references/optimization-semantic-checklist.md](references/optimization-semantic-checklist.md) — semantic RN performance review.
- [references/optimization-fix-reference.md](references/optimization-fix-reference.md) — common finding-to-fix mapping.
