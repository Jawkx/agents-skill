# React Native

> Part of the unified `argent` skill. Return to [`../SKILL.md`](../SKILL.md) for task routing.

## React Native app workflow

### 1. Starting the React Native App

#### 1.1 Explore Configuration (MANDATORY — Do This First)

**Before running commands**, read the project's build and run configuration from the `argent-environment-inspector` subagent result.

Do NOT default to `npx react-native start` or `npx react-native run-ios` without first checking for custom scripts and workflows.

**Manual fallback** (if neither the agent nor the tool is available): read ALL `package.json` scripts — look for custom scripts like `start:local`, `start:dev`, `ios`, `build:ios`, flavors, etc. Custom scripts take priority over default commands. Also check `metro.config.js` for non-default port or watchFolders. For iOS builds, prefer opening `.xcworkspace` over `.xcodeproj` (CocoaPods generates the workspace).

**If the project structure is convoluted, ask the user before proceeding.**

**Remember the workflow:** Once you discover the project's build/run workflow, save it to project memory so you don't need to re-discover it each time.

**Checklist before start:**

- [ ] `node_modules` present (if not: `npm install` or `yarn`)
- [ ] For iOS: `ios/Podfile` exists; if `ios/Pods` missing or stale, run `cd ios && pod install && cd ..`
- [ ] No conflicting Metro on default port (see 1.2)

#### 1.2 Start Metro

1. Check whether metro is already running on port found in configuration and if it is - do not start another server. Refer to point 2.1.

1. **Use the project's custom start script if one exists** (e.g. `npm run start:local`, `yarn start:dev`). Fall back to default commands if no custom scripts are defined:

   ```bash
   npx react-native start
   ```

   Optional: `npx react-native start --reset-cache` if cache issues are suspected.

1. **Verify Metro is ready**: use the `debugger-status` tool to verify Metro is running and reachable.

1. **Projects with flavors or custom configs**: Use project-specific start script if present (e.g. `npm run start:local`), and start Metro **before** running the app.

#### 1.3 Run the App

In a **separate** terminal (Metro keeps running in the first):

**Use the project's custom build/run script if one exists** (e.g. `npm run ios`, `npm run android`, `yarn ios:debug`). Only fall back to the defaults below if no custom scripts are defined.

**Pass the target device explicitly** — derive it from `list-devices` (see `<device_selection_rule>`):

```bash
npx react-native run-ios --simulator="<name>"        # iOS (or --udid <UDID>)
npx react-native run-android --deviceId=<adb-serial> # Android
```

**Android only**: after install, run `adb -s <serial> reverse tcp:8081 tcp:8081` so the emulator/device can reach Metro on your host. Repeat if the device restarts or adb drops.

**Agent checklist:**

- [ ] Metro is already running and shows "ready"
- [ ] Command run from project root
- [ ] If the device isn't booted yet: use `boot-device` with the iOS `udid` or Android `avdName`. Refer to the `device-interaction.md` reference.
- [ ] Android: `adb -s <serial> reverse tcp:8081 tcp:8081` done.

---

### 2. Ensuring / Debugging Metro

#### 2.1 Check for Existing Metro

Before starting Metro, avoid "port already in use" errors. Default port to check is :8081, infer the port from documentation:

```bash
lsof -i :PORT
```

- **No output** → Port free; safe to start Metro.
- **Output with PID** → Another process is using the port.

Use the `debugger-status` tool to check whether the process on that port is actually a Metro server. If not Metro — ask the user whether you may kill the process.

To kill a Metro process, use the `stop-metro` tool (requires user confirmation).

#### 2.2 Confirm Correct Server Connection

- **App must point at the same host/port as the running Metro.** Default: same machine, port 8081.
- **iOS Simulator:** By default uses localhost; no extra config needed for same-machine Metro.

**Verify Metro is reachable:** use the `debugger-status` tool.

#### 2.3 Reload the App (Ensure New Bundle)

After code or config changes, the app must load the new bundle:

| Method      | How                                                                                               |
| ----------- | ------------------------------------------------------------------------------------------------- |
| Reload tool | Use the `debugger-reload-metro` tool                                                              |
| Restart app | Use the `restart-app` tool, or kill the app in simulator and run `npx react-native run-ios` again |

**Agent checklist:**

- [ ] Only one Metro process (no duplicate on port)
- [ ] App was started after Metro was ready
- [ ] When needing to reload: refer to 2.3

---

### 3. Build / Install / Retry (React Native & iOS Native)

#### 3.1 When Build Fails (e.g. xcodebuild exit code 65)

**Order of operations (simplest first):**

1. Clean build folder, then retry the build command
2. Clear caches and reinstall dependencies: reset Metro cache, `watchman watch-del-all`, remove `node_modules` + lockfile, `npm install`, then `cd ios && rm -rf build Pods Podfile.lock && pod install --repo-update`
3. CocoaPods issues: `pod deintegrate` then `pod install --repo-update`
4. Open `ios/*.xcworkspace` in Xcode for detailed errors in the Report navigator

#### 3.2 When to Ask the User

**After 2-3 failed build or run attempts, STOP and ask the user for guidance.** The user may know about required env vars, Xcode version requirements, custom build configurations, monorepo-specific setup, or required external services.

If the project structure is convoluted and the correct build approach is not obvious, **ask the user early** rather than guessing.

#### 3.3 Saving Build Workflow for Later

Once you discover the correct build/run workflow for a project, **save it to project memory**. Capture: commands to start Metro, commands to build/run the app, and any required environment setup.

#### 3.4 When to Reinstall vs Refresh

| Situation                                             | Action                                                                                |
| ----------------------------------------------------- | ------------------------------------------------------------------------------------- |
| JS/React only changed                                 | Use `debugger-reload-metro` tool. No rebuild.                                         |
| Native code or `pod install` / project config changed | Rebuild: `npx react-native run-ios` (Metro can stay running).                         |
| `node_modules` or `package.json` changed              | `npm install`, then if native deps changed run `cd ios && pod install`. Then rebuild. |
| App needs reinstalling from .app path                 | Use `reinstall-app` tool with UDID, bundle ID, and .app path.                         |
| Persistent native build errors                        | Full clean + reinstall (step 2 above).                                                |

#### 3.5 Device Control

| Action                     | Tool / Command                                                         |
| -------------------------- | ---------------------------------------------------------------------- |
| List devices               | `list-devices` tool (iOS + Android)                                    |
| Boot an iOS simulator      | `boot-device` tool with `udid`                                         |
| Boot an Android emulator   | `boot-device` tool with `avdName`                                      |
| Launch an app              | `launch-app` tool (pass device id + bundle id / package name)          |
| Restart an app             | `restart-app` tool (pass device id + bundle id / package name)         |
| Open a URL / deep link     | `open-url` tool (pass device id + URL)                                 |
| Rotate device              | `rotate` tool                                                          |
| Stop simulator server      | `stop-simulator-server` tool (iOS UDID or Android serial — one device) |
| Stop all simulator servers | `stop-all-simulator-servers` tool (iOS + Android)                      |

For full simulator setup workflow, refer to the `device-interaction.md` reference.

---

### 4. Runtime Problems in the App

#### 4.1 Where to Look

| Problem type                      | Tool / Where to look                                                                                                                                                                                                                                              |
| --------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **JavaScript errors / logs**      | Use `debugger-log-registry` to get a summary and log file path, then `Grep`/`Read` to search.                                                                                                                                                                     |
| **React component hierarchy**     | Use `debugger-component-tree` tool for a text tree, or `debugger-inspect-element` at specific logical pixel coordinates (not normalized 0-1).                                                                                                                     |
| **Visual state of the app**       | Use `screenshot` tool to capture the current screen, but prefer `describe` or `debugger-component-tree` for actual navigation and target discovery. If a permission prompt or system-owned modal overlay is not exposed reliably, then fall back to `screenshot`. |
| **Evaluate JS in the app**        | Use `debugger-evaluate` tool to run JavaScript in the app's runtime.                                                                                                                                                                                              |
| **Native crashes / native stack** | `npx react-native log-ios` or iOS Simulator: Debug → Open System Log.                                                                                                                                                                                             |
| **Build/runtime config**          | `metro.config.js`, `babel.config.js`, `package.json` scripts, `ios/Podfile`.                                                                                                                                                                                      |

For comprehensive Metro debugging workflows (component inspection, console logs, JS evaluation), refer to the `react-native.md` reference.

#### 4.2 JS Console Logs (Log Registry)

Logs are written to a flat log file on disk under `~/.argent/tmp/`. Use the **log-registry → grep** pattern instead of reading logs inline.

For the full workflow, flat entry format, and grep examples, see `react-native.md` reference §5.

#### 4.3 Do not try to use the DevMenu in React Native apps by default.

Use the argent tools instead.

---

### 5. Testing the App

Check the `argent-environment-inspector` result for test commands. For interactive UI testing with automatic screenshot verification, use the `ui-testing-and-flows.md` reference.

- **Unit tests**: Look for Jest in `package.json` (`"test": "jest"`, `jest` config). Run: `npm test` or `yarn test`.
- **E2E**: Look for Detox (`.detoxrc.js` or similar), or other E2E config. Dependencies: `detox`, `detox-cli`, and for iOS often `applesimutils`.
- **Visible UI changes**: Use `ui-testing-and-flows.md` for manual QA. For `screenshot-diff` rules and parameters, follow the `ui-testing-and-flows.md` reference. Use it when stable before/after screenshots add meaningful pixel-visible evidence.
- **UI flow testing**: For interactive UI testing with automatic screenshot verification, refer to the `ui-testing-and-flows.md` reference.

#### 5.2 Running Tests (Typical)

If the user's intent is ambiguous (run existing tests, write new tests, or find missing coverage), clarify before proceeding.

- **Jest**: `npm test` or `npx jest`.
- **Detox (example)**:
  - Build: `detox build --configuration ios.sim.release` (or debug).
  - Run: `detox test --configuration ios.sim.release`.
  - Ensure simulator is booted and not used by another process.

#### 5.3 Agent Testing Checklist

- [ ] Read `package.json` and test config (Jest, Detox, etc.).
- [ ] If E2E: confirm simulator/device and build config.
- [ ] If unclear: clarify whether to use existing workflows or write new tests.

---

### Quick Reference: Tools & Commands

| Goal                         | Tool / Command                                                                                                                           |
| ---------------------------- | ---------------------------------------------------------------------------------------------------------------------------------------- |
| Check port 8081              | `lsof -i :8081`                                                                                                                          |
| Kill Metro                   | `stop-metro` tool                                                                                                                        |
| Start Metro                  | `npx react-native start`                                                                                                                 |
| Start Metro (reset cache)    | `npx react-native start --reset-cache`                                                                                                   |
| Run iOS app                  | `npx react-native run-ios`                                                                                                               |
| Run Android app              | `npx react-native run-android`                                                                                                           |
| List devices                 | `list-devices` tool (iOS + Android)                                                                                                      |
| Boot a device                | `boot-device` tool (pass `udid` for iOS or `avdName` for Android)                                                                        |
| Take screenshot              | `screenshot` tool                                                                                                                        |
| Compare visible UI changes   | `screenshot-diff` tool; follow the `ui-testing-and-flows.md` reference for baseline/current capture choices                                   |
| Describe screen (a11y tree)  | `describe` tool for normal app screens and in-app modals; use `screenshot` only when permission/system overlays are not exposed reliably |
| Read JS console logs         | `debugger-log-registry` tool                                                                                                             |
| Reload JS bundle             | `debugger-reload-metro` tool                                                                                                             |
| Check Metro status           | `debugger-status` tool                                                                                                                   |
| Inspect React component tree | `debugger-component-tree` tool                                                                                                           |
| Run JS in app                | `debugger-evaluate` tool                                                                                                                 |
| iOS native logs              | `npx react-native log-ios`                                                                                                               |
| Android native logs          | `npx react-native log-android` or `adb -s <serial> logcat`                                                                               |
| Clean + reinstall (nuclear)  | See §3.1 step 3                                                                                                                          |

---

### Related Skills

| Skill                           | When to use                                                                                                                                              |
| ------------------------------- | -------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `device-interaction.md`    | Initial iOS simulator boot and connection setup                                                                                                          |
| `device-interaction.md` | Initial Android emulator boot and connection setup                                                                                                       |
| `device-interaction.md`        | Tapping, swiping, typing, hardware buttons, gestures on the simulator/emulator                                                                           |
| `react-native.md`         | JS-runtime CDP debugging (Metro on iOS / Android; the four ported tools also drive Chromium/CDP apps): component inspection, console logs, JS evaluation |
| `profiling.md`  | Profiling performance, finding re-render issues, CPU hotspots                                                                                            |
| `ui-testing-and-flows.md`           | Interactive UI testing with automatic screenshot verification after each action                                                                          |

Ask the user before running tests: confirm which test suite (unit, E2E, or both), whether to use existing CI commands, and whether they want you to run existing tests, write new ones, or explore test cases yourself.

## Metro and CDP debugger

### 1. Prerequisites

For **React Native (iOS / Android)**: requires **Metro dev server running** (default `localhost:8081`) and **a React Native app connected to Metro** (at least one CDP target). Verify via `debugger-status`.

For **Chromium (CDP)**: requires a Chromium/CDP app already available — an Electron app booted via `boot-device` with `electronAppPath`, or any Chromium browser exposing a CDP port (auto-discovered by `list-devices` on `9222` / `ARGENT_CHROMIUM_PORTS`). The debugger re-uses the page CDP session — `port` is ignored, `device_id` is the `chromium-cdp-<port>` value from `list-devices` / `boot-device`. Only `debugger-connect`, `debugger-status`, `debugger-evaluate`, `debugger-log-registry`, `view-network-logs`, and `view-network-request-details` work on Chromium (the latter two read the browser's native CDP Network recording for the active tab instead of the Metro-injected `fetch` interceptor); `debugger-component-tree`, `debugger-reload-metro`, `debugger-inspect-element`, and the `react-profiler-*` / `profiler-*` tools are RN-only and reject Chromium at the capability gate with `Tool 'X' is not supported on chromium app`.

#### Android: reverse port for Metro

Android emulators and physical devices do not resolve the host's `localhost` by default. Before the RN app can reach Metro, forward port 8081 (or whichever port Metro is on) from the device back to the host:

```bash
adb -s <serial> reverse tcp:8081 tcp:8081
```

`<serial>` is the Android `serial` from `list-devices`. Once reversed, the app on the device connects to Metro just like an iOS simulator does, and all `debugger-*` / `network-*` / `react-profiler-*` tools work unchanged. If the device restarts or adb drops, re-run the command. A failing Metro connection on Android almost always means `adb reverse` has not been done or has been lost.

### 2. Tool Overview

All tools accept `port` (default 8081) AND `device_id` (the iOS Simulator UDID or Android serial, a.k.a. `logicalDeviceId` — the CDP-reported id that matches the device). Always make sure you target the correct app on the correct device.

One Metro port can serve multiple connected devices (e.g. two simulators on `localhost:8081`, or an iOS simulator alongside an Android emulator with `adb reverse` set up). `device_id` pins every debugger/network/profiler call to a specific device so sessions do not collide.

#### Connect & diagnostics

| Tool               | Purpose                                                                                                                                                                                                                                                                                            |
| ------------------ | -------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `debugger-connect` | Connect to the JS runtime's CDP (Metro on iOS / Android; the page CDP session on Chromium). Returns port, projectRoot (empty on Chromium), deviceName, appName, `logicalDeviceId`, isNewDebugger, connected. The returned `logicalDeviceId` is the `device_id` for every subsequent debugger call. |
| `debugger-status`  | Like connect + loadedScripts, enabledDomains, sourceMapReady (no-op on Chromium). **Use to diagnose.**                                                                                                                                                                                             |

#### Reload & recovery

| Tool                    | Purpose                                                                                       |
| ----------------------- | --------------------------------------------------------------------------------------------- |
| `debugger-reload-metro` | Reload all connected apps (like pressing "r" in Metro terminal). Needs a CDP target.          |
| `restart-app`           | Terminate and relaunch the app by device id and bundleId. Use when app lost Metro connection. |

#### Inspection & console

| Tool                       | Purpose                                                                                                                                                                   |
| -------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `debugger-component-tree`  | Full React fiber tree (names, depth, bounding rects, tap coordinates).                                                                                                    |
| `debugger-inspect-element` | Inspect at (x, y) using **logical pixel coordinates** (not normalized 0-1): component hierarchy with source file:line and code fragment. See `debugger-source-maps.md`. |
| `debugger-log-registry`    | Get log summary (counts, clusters, file path). Then use `Grep`/`Read` on the flat log file for details.                                                                   |
| `debugger-evaluate`        | Run a JS expression in the app runtime.                                                                                                                                   |

---

### 3. Component Inspection

#### `debugger-component-tree` vs `debugger-inspect-element`

|          | `debugger-component-tree`                                              | `debugger-inspect-element`                                      |
| -------- | ---------------------------------------------------------------------- | --------------------------------------------------------------- |
| Best for | Layout overview; finding tap targets; user-defined component hierarchy | Identifying a visible element and tracing it to its source file |
| Use when | "What's on screen and where?"                                          | "What component is this and where is it defined?"               |

Both can point to source files, but `inspect-element` is purpose-built for source tracing. `component-tree` is for orientation and tap-target discovery.

#### `includeSkipped` guidance

Applies to both `debugger-component-tree` and `debugger-inspect-element`. Set to `true` only when debugging filter behavior — e.g., an expected component is missing from output, or you need to inspect a very specific branch of the tree (not just an overview).

> **Warning:** Output can be very large. Always combine with `maxNodes` (component-tree) or `maxItems` (inspect-element) and increase it incrementally (e.g., start at 50, then grow). Do not use `includeSkipped` without a limit on large apps.

---

### 4. Golden Rules

1. **`debugger-status` first when something fails** — it runs discovery, connection, and returns diagnostics.
2. **"No CDP targets" → get the app to connect to Metro** — use `restart-app` on the device, then retry `debugger-status`.
3. **Never assume one failure is permanent** — follow recovery steps before asking the user. For starting Metro and full failure recovery, see `react-native.md` and `debugger-failure-scenarios.md`.

---

### 5. Reading Console Logs (Log Registry)

Logs are written to a flat log file on disk. Use the **log-registry → grep** pattern instead of reading logs inline.

#### Workflow

1. **Call `debugger-log-registry`** — returns: `file` (log path), `totalEntries`, `byLevel`, `clusters` (top message groups with counts and source file info)
2. **Search the file** using `Grep` or `Read` with patterns from the response.

> **Large log files:** If `totalEntries` exceeds 10 000, delegate the grep exploration to an `Explore` subagent — pass it the file path, the entry format, and the patterns you need.

#### Flat log format

One entry per line — fields (whitespace-separated, `|` delimiter before message)

| Field         | Example                     | Notes                                               |
| ------------- | --------------------------- | --------------------------------------------------- |
| `[L:<id>]`    | `[L:42]`                    | Unique grep anchor                                  |
| `<timestamp>` | `2026-03-17T14:30:00.000Z`  | ISO 8601                                            |
| `<LEVEL>`     | `ERROR`, `WARN `, `LOG  `   | Uppercase, padded to 5 chars                        |
| `<source>`    | `src/api/user.ts:42` or `-` | Relative path from source map; `-` if unavailable   |
| `<message>`   | `Failed login attempt`      | Full message; embedded newlines replaced with space |

Source attribution (file + line) is also available in `clusters` returned by `debugger-log-registry`.

Log files and messages can be large - **Always scope your search**, treat the file like a database, not a document.

When reading from the log file:

- Never `Read` the log file directly. Use `grep` or shell commands with limits using the above file format tips.
- Default to `-m 50` unless you need more.
- Use `tail -N` recent entries.
- `clusters[].message` gives you the exact text which you may look for

> **If the file is too large** Delegate to an `Explore` subagent with the file path, the format spec above, and the specific patterns you need.

---

### Quick Reference

| Action                            | Tool                                                                |
| --------------------------------- | ------------------------------------------------------------------- |
| Diagnose / check connection       | `debugger-status`                                                   |
| Connect to CDP (Metro / Chromium) | `debugger-connect`                                                  |
| Reload JS (already connected)     | `debugger-reload-metro`                                             |
| Relaunch app on device            | `restart-app`                                                       |
| Inspect component at point        | `debugger-inspect-element`                                          |
| Full component tree               | `debugger-component-tree`                                           |
| Console log overview              | `debugger-log-registry` (summary + log file path for `Grep`/`Read`) |
| Evaluate JS                       | `debugger-evaluate`                                                 |
