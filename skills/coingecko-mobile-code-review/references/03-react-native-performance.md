# React Native Performance Rubric

## Red flags (quick hits)
- Inline callbacks/objects created inside render, especially in list rows
- Missing or unstable keys in arrays/lists (no `key`, index keys for mutable data)

## Rendering & memoization
- Avoid inline functions/objects in render when passed to children.
- Consider `React.memo` for pure/presentational components.
- Use `useMemo` for expensive derived values (but do not cargo-cult it).
- Watch for unstable props causing child rerenders:
  - inline styles
  - inline callbacks
  - new arrays/objects created each render

## List performance (FlatList/SectionList)
Must-check:
- `keyExtractor` present and stable
- `renderItem` is stable (memoized or extracted component)
- Avoid heavy work inside `renderItem`
- Consider:
  - `getItemLayout` for fixed-height rows
  - `initialNumToRender`, `windowSize` tuning for long lists
  - `removeClippedSubviews` when appropriate (be careful with sticky headers)
- Do not overuse `extraData`; it forces rerenders.

## Images
- Avoid huge images without explicit sizing.
- Confirm sensible `resizeMode`.
- Use placeholders (`defaultSource`) if supported/needed.
- Avoid re-downloading / flicker: caching patterns as per codebase.

## Effects and async work
- Cancel/cleanup long-running work (subscriptions, timers, listeners).
- Avoid setState after unmount:
  - use AbortController where possible
  - unsubscribe in cleanup

## Common perf footguns
- Heavy `map/filter/sort` in render on big arrays
- Creating regex/date formatters on every render
- Unbounded re-renders due to global state selection:
  - selectors returning new objects each time
  - missing memoized selectors

## How to comment (high-signal)
For a perf issue, include:
- Where it happens (component + hot path)
- Why it matters (frequency, list size, navigation)
- A concrete fix (extract component, memoize, selector, list tuning)
