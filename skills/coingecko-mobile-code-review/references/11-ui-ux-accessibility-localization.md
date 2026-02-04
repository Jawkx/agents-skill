# UI/UX, Accessibility, Localization Rubric

## Red flags (quick hits)
- Hardcoded user-facing strings instead of localization utilities
- One-off literal styling (colors/spacing) that ignores theme tokens

## UX fundamentals
- Loading/error/empty states exist and feel intentional.
- Interactions are responsive (no blocking spinners without reason).
- Copy is consistent and helpful.

## Accessibility (RN)
Must-check for user-facing UI:
- Touch targets are reasonable; add hitSlop when needed.
- Important icons/buttons have accessibility labels/roles when appropriate.
- Text respects dynamic type where relevant (maxFontSizeMultiplier patterns).

## Localization
- Avoid hardcoded user-facing strings.
- Use localization utilities per repo standard.
- Consider pluralization, formatting (dates/numbers), and truncation.

## Styling consistency
- Use CGStyled + theme tokens.
- Avoid random one-off spacing/color values unless justified.

## Platform considerations
- iOS/Android behavior differences:
  - back button handling
  - permissions
  - keyboard avoidance
  - safe areas
- Flag anything likely to break on one platform.
