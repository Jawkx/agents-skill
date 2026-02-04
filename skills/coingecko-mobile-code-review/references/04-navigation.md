# Navigation Rubric

## Type-safe navigation (team convention)
- Use `useTypedNavigation()` (not raw `useNavigation()`).
- Navigation calls must be type-safe:
  - avoid `as any` to bypass route param typing
  - ensure route params match navigator definitions

## Listener safety (memory leak prevention)
- Any `addListener` must be cleaned up:
  - return unsubscribe in `useEffect` cleanup
- `useFocusEffect` should return cleanup when registering listeners/subscriptions.

Example:
~~~ts
useEffect(() => {
  const unsubscribe = navigation.addListener('focus', onFocus);
  return unsubscribe;
}, [navigation, onFocus]);
~~~

## Screen options & headers
- Ensure options are set in the right place (navigator vs screen).
- Avoid recreating option objects on every render if it is expensive.
- Confirm back behavior and gestures match UX.

## Patterns to encourage
- Small navigation helpers/hooks when repeated across screens.
- Clear naming for routes.
- Avoid navigation logic leakage into deep child components unless intentional.
