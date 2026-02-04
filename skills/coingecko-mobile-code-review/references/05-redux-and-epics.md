# Redux & Epics Rubric (Redux-Observable / RxJS)

## Typed hooks (team convention)
- Dispatch: use `useTypedDispatch()`
- Select: use `useStoreSelector()`

Flag:
- raw `useDispatch` / `useSelector` usage (unless explicitly allowed)
- selectors returning new objects each time (rerender risk)

## Redux architecture
- Keep reducers pure and predictable.
- Avoid storing derived state that can be computed from source-of-truth state.
- Prefer normalized state for collections.
- Encapsulate selection logic in selectors (and memoize when needed).

## Epics (RxJS) must-check
- Correct operator choice:
  - prefer `switchMap` for "latest wins"
  - prefer `concatMap` for ordered queues
  - prefer `exhaustMap` for "ignore while running"
- Always handle errors:
  - `catchError` and return a safe action stream
- Cancellation/cleanup:
  - use `takeUntil` on cancel actions where appropriate
  - avoid unbounded subscriptions
- Keep side effects isolated and testable.
- Be careful with concurrency and retries (avoid request storms).

Example error handling:
~~~ts
return action$.pipe(
  ofType(fetchUser.request),
  switchMap(({ payload }) =>
    from(api.fetchUser(payload.id)).pipe(
      map(fetchUser.success),
      catchError((e) => of(fetchUser.failure(toErrorPayload(e))))
    )
  )
);
~~~

## Tests
- New/changed reducers/selectors/epics should have tests.
- For epics: test success, failure, and cancellation paths.
