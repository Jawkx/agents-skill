---
name: react-effect-review
description: Use this skill when reviewing, debugging, or refactoring React components that use useEffect, derived state, prop-to-state syncing, form reset logic, subscriptions, or data fetching. Apply it when the user wants to simplify React state flow, remove unnecessary Effects, fix stale renders, reduce double renders, or decide whether an Effect should stay, move to an event handler, or be replaced with another pattern.
---

# React Effect Review

Review React components with a bias toward removing unnecessary `useEffect` usage.

## Goal

Help the user decide, for each Effect, whether to:

- remove it entirely
- replace it with render-time calculation
- replace it with `useMemo`
- move logic into an event handler
- reset state with a `key`
- lift state up / make the component controlled
- replace a manual subscription with `useSyncExternalStore`
- keep the Effect, but improve it

Do not remove an Effect just because it exists. Keep Effects that genuinely synchronize React with an external system.

## What counts as a real Effect

An Effect is justified when it synchronizes with something outside normal React rendering, such as:

- network-backed synchronization
- browser APIs or DOM integration
- timers, listeners, subscriptions
- third-party widgets
- analytics caused by display / visibility rather than a user action

If there is no external system involved, strongly suspect the Effect is unnecessary.

## Review process

1. Find every `useEffect` and note:
   - dependencies
   - state it writes
   - external systems it touches
   - whether it exists because of render-time data flow or a user event

2. Classify each Effect into one of these buckets:
   - derived data
   - expensive pure calculation
   - prop/state reset
   - event-specific logic
   - parent/child synchronization
   - external store subscription
   - fetch / async synchronization
   - legitimate external synchronization

3. For each Effect, produce:
   - verdict: `remove`, `rewrite`, or `keep`
   - reason in one or two sentences
   - preferred replacement pattern
   - any important caveat

4. Prefer the simplest correct pattern:
   - calculate during render
   - use `useMemo` only for expensive pure work
   - move action-specific logic into event handlers
   - use `key` to reset a subtree when switching identities
   - lift state up rather than syncing parent/child state via Effects
   - use `useSyncExternalStore` for subscriptions
   - keep fetch Effects only when they are actually synchronizing with external data, and add stale-response cleanup

## Rewrite rules

### 1) Derived state -> calculate during render

If an Effect sets state that can be derived from props or existing state, remove both the Effect and the redundant state.

Prefer:

```js
const fullName = firstName + ' ' + lastName;
````

Avoid:

```js
const [fullName, setFullName] = useState('');
useEffect(() => {
  setFullName(firstName + ' ' + lastName);
}, [firstName, lastName]);
```

### 2) Expensive pure calculation -> `useMemo`

If the logic is pure and expensive, keep it in render but memoize it.

Prefer:

```js
const visibleTodos = useMemo(
  () => getFilteredTodos(todos, filter),
  [todos, filter]
);
```

Do not add `useMemo` automatically unless there is a real performance reason.

### 3) Resetting all local state on identity change -> `key`

If a form or subtree should fully reset when the identity changes, split the component and pass a stable identity as `key` to the inner component.

Prefer this over an Effect that clears multiple fields after render.

### 4) Adjusting some state when props change

First ask whether the state can be removed entirely and recalculated from IDs or props.

If partial adjustment is truly needed, prefer render-time adjustment over an Effect that causes a stale render followed by another render.

### 5) User-action logic -> event handler

If logic should run because the user clicked, submitted, dragged, or otherwise acted, it belongs in the event handler, not in an Effect.

Common examples:

* POST on submit
* buy / checkout side effects
* notifications caused by a button click
* notifying a parent immediately after interaction

### 6) Parent/child synchronization

Avoid Effects whose job is to push child state upward or keep two React states in sync.

Prefer:

* lifting state up
* making the child controlled
* updating both pieces of state during the same event

### 7) External store subscription

If the component subscribes to mutable external data, prefer `useSyncExternalStore` over a custom subscription Effect when possible.

### 8) Fetching data

Fetching may remain in an Effect when the component must stay synchronized with external data for current props/state.

When keeping a fetch Effect:

* check for stale response / race conditions
* include cleanup or cancellation logic
* note when a framework-level data API would be preferable

Do not move fetch logic into an event handler unless the fetch is truly caused by a specific user action rather than view state.

## Output format

When reviewing code, respond in this structure:

### Effect audit

For each Effect:

* `Verdict:` keep / rewrite / remove
* `Why:`
* `Better pattern:`
* `Suggested change:`

### Refactored example

Provide either:

* a minimal patch, or
* a rewritten component

### Notes

Mention any of:

* behavior changes
* performance implications
* race condition risks
* whether the rewrite is opinionated vs clearly better

## Guardrails

* Do not claim an Effect is wrong if it syncs with a real external system.
* Do not force `useMemo` for cheap calculations.
* Do not recommend render-time state updates unless they are conditional and necessary.
* Prefer fewer state variables when the value can be derived.
* Prefer one-pass event-driven updates over multi-step Effect chains.
* When multiple solutions are valid, present the least surprising one first.
