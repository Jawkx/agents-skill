# State Management, Side Effects, Hooks

## Red flags (quick hits)
- Effects with incorrect dependency arrays
- Listeners/subscriptions/timers added in effects without cleanup

## Local vs global state
- Local UI state belongs in components/hooks.
- Shared/cross-screen state belongs in redux (or equivalent).
- Avoid duplicating the same state in multiple places.

## useEffect correctness
- Dependencies must be complete and correct.
- Cleanup required for:
  - listeners
  - timers
  - subscriptions
  - in-flight async work (where possible)

Avoid:
- effects that set state unconditionally based on props (derived state smell)
- disabling lint rules without strong justification

## Async patterns
- Do not make `useEffect` callback `async`; wrap it.
- Prefer cancellation patterns for fetches/subscriptions.

Example:
~~~ts
useEffect(() => {
  let cancelled = false;

  const run = async () => {
    try {
      const res = await fetchStuff();
      if (!cancelled) setData(res);
    } catch (e) {
      if (!cancelled) setError(e);
    }
  };

  run();
  return () => {
    cancelled = true;
  };
}, [fetchStuff]);
~~~

## Custom hooks
Extract a hook when:
- logic is reused across screens/components
- effects/state are large and obscure the UI
- it improves testing and separation of concerns

But avoid hooks that are just abstraction for abstraction's sake.
