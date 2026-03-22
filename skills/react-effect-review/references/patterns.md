# React Effect Review Patterns

Read this file when you need concrete rewrite guidance for a React `useEffect` review.

## Common smells

### Redundant derived state

Smell:
- Effect writes state derived only from props or existing state

Usual fix:
- remove the state variable
- compute directly during render

### Effect used as an event bus

Smell:
- Effect runs after `isSubmitted`, `jsonToSubmit`, `isInCart`, `shouldNotify`, etc. changes
- actual cause is a click or submit event

Usual fix:
- move the action into the event handler

### Reset-on-prop-change Effect

Smell:
- Effect clears local state when entity identity changes

Usual fix:
- split component
- pass `key={entityId}` to the inner form/subtree

### Selection reset / partial state adjustment

Smell:
- Effect nulls or patches a subset of local state whenever props change

Usual fix order:
1. remove the state entirely if it can be derived
2. store IDs, not denormalized objects
3. if truly necessary, adjust during render instead of post-render Effect

### Parent notification Effect

Smell:
- child uses Effect to call `onChange` / `onFetched` / `setParentState`

Usual fix:
- update parent and child during the same event
- or lift state up and make the child controlled

### Manual external subscription Effect

Smell:
- local state mirrors browser or library store with manual add/remove listeners

Usual fix:
- `useSyncExternalStore`

### Fetch Effect without cleanup

Smell:
- `fetch(...).then(setState)` in an Effect with no stale-response guard

Usual fix:
- ignore stale responses or cancel request
- mention framework data APIs when relevant

## Decision shortcuts

Ask in order:

1. Can this value be calculated during render?
2. Is this just an expensive pure calculation?
3. Is this logic caused by a user action?
4. Is this trying to reset identity-specific state?
5. Is this syncing two React states that should be unified?
6. Is this a real external synchronization?
7. If it stays, does it need cleanup?

## Review language to use

Prefer:
- "This Effect is unnecessary because ..."
- "This value is derivable from existing state ..."
- "This action is event-specific and should happen in the handler ..."
- "This subtree should reset by identity, so use a `key` ..."
- "This subscription is a better fit for `useSyncExternalStore` ..."
- "This fetch Effect is legitimate, but it needs stale-response cleanup ..."
