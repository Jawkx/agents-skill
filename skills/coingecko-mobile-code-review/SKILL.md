---
name: coingecko-mobile-code-review
description: Senior-level code review workflow for CoinGecko Mobile (React Native + TypeScript). Uses progressive disclosure to load only relevant rubrics (performance, navigation, redux/epics, security, testing, UX) and produces structured, constructive, actionable feedback.
metadata:
  owner: mobile-team
  version: "1.0"
---

# CoinGecko Mobile Code Review

This skill is intentionally *thin*. Follow progressive disclosure: load only the rubrics needed for the specific change.

## Always load (baseline)
Read these before writing review feedback:
- [references/00-review-process.md](references/00-review-process.md)
- [references/01-output-and-tone.md](references/01-output-and-tone.md)
- [references/02-standards-and-typescript.md](references/02-standards-and-typescript.md)

## Load additional rubrics only when triggered

### React Native performance
- Load: [references/03-react-native-performance.md](references/03-react-native-performance.md)
- Trigger: any `*.tsx` change, list rendering (FlatList/SectionList), images, animations, expensive computations, or repeated re-renders.

### Navigation
- Load: [references/04-navigation.md](references/04-navigation.md)
- Trigger: changes to navigators/routes/screen options/deep links OR any added/changed navigation actions (`navigate`, `push`, `replace`, `reset`, `goBack`) OR navigation listeners/focus logic.
- Skip: if the PR touches screens/components but does not change navigation actions, route params, or navigator configuration.

### Redux & Epics
- Load: [references/05-redux-and-epics.md](references/05-redux-and-epics.md)
- Trigger: reducers/actions/selectors/store wiring OR `*/epics/*` OR RxJS operator usage in app logic OR any `dispatch` / `useStoreSelector` changes.

### State, side-effects, hooks
- Load: [references/06-state-effects-hooks.md](references/06-state-effects-hooks.md)
- Trigger: complex local state, `useEffect` heavy logic, async side-effects, new custom hooks, cleanup/cancellation risks.

### Error handling & validation
- Load: [references/07-error-handling-validation.md](references/07-error-handling-validation.md)
- Trigger: async/network/file IO, parsing, user inputs/forms, user-generated content, loading/error/empty state UX.

### Security & privacy
- Load: [references/08-security-privacy.md](references/08-security-privacy.md)
- Trigger: auth, tokens, secure storage, deep links, WebView, payments, logging, PII, new deps, networking changes.

### Testing & quality gates
- Load: [references/09-testing-and-quality.md](references/09-testing-and-quality.md)
- Trigger: new/changed reducers, epics, utils, services, or bug fixes; anything on a critical path.

### Architecture & maintainability
- Load: [references/10-architecture-maintainability.md](references/10-architecture-maintainability.md)
- Trigger: large components, new abstractions, cross-module coupling, dependency injection, folder structure changes.

### UI/UX, accessibility, localization
- Load: [references/11-ui-ux-accessibility-localization.md](references/11-ui-ux-accessibility-localization.md)
- Trigger: any user-facing UI or copy changes.

## Operating principles
- Prioritize correctness, safety, and maintainability over style nits.
- Propose concrete fixes (small patches) when feasible.
- Group issues by the rubric they offend.
- For each issue, state the **problem** and the **change**.

When writing feedback, follow the structure in:
- [references/01-output-and-tone.md](references/01-output-and-tone.md)
