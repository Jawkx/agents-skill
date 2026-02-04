# Code Quality & Standards (React Native + TypeScript)

## Red flags (quick hits)
- `any`, `as any`, or `@ts-ignore` without strong justification
- Inline styles with literal colors/spacing instead of theme tokens + `CGStyled`

## TypeScript-first (no loose typing)
- Flag **any** usage of:
  - `any` (prefer `unknown`, or a concrete union)
  - `// @ts-ignore` / `as any` (require justification)
  - Missing prop/state/types for public functions
- Prefer explicit types at module boundaries:
  - component props
  - custom hooks return values
  - service responses
  - redux actions/selectors
- Keep types local and discoverable:
  - Do not export huge "god" types unless truly shared.
  - Prefer narrowing early (guards) over casting late.

## Naming conventions
- Components: `PascalCase`
- Functions/variables: `camelCase`
- Constants: `SCREAMING_SNAKE_CASE`
- Redux migration files: `snake_case` filenames (team convention)

## Component/file structure (tried to follow unless there's a compelling reason not to)
Order for UI files:
1) imports
2) types
3) constants
4) component
5) helpers
6) styled components (CGStyled)
7) exports

## Syntax conventions (team rubric)
- Prefer functional components + hooks (avoid class components).
- Prefer arrow functions over function declarations for components and handlers.
- Prefer **named exports** over default exports.
- Use modern JS (ES2020+): optional chaining, nullish coalescing, `Array.prototype.at`, etc (as supported by project).

## Props interface/type naming
- Prop type must match component name with `Props` suffix.
  - `TodoList` => `TodoListProps`
- Keep props minimal; avoid "pass-through everything".

## Styling conventions
- Use `CGStyled` (team wrapper for styled-components).
- Prefer theme tokens over literals:
  - colors, spacing, typography, radii
- Avoid:
  - `StyleSheet.create` (unless a deliberate exception)
  - inline styles (especially with literals)
  - hardcoded colors/spacing
- For Text: prefer `maxFontSizeMultiplier` patterns when available.

Example:
~~~ts
const ErrorText = CGStyled.Text.attrs({
  maxFontSizeMultiplier: 1.2,
})`${({ theme }) => ({
  fontSize: theme.fontSizes.sm,
  lineHeight: theme.lineHeights.sm,
  color: theme.colors.inputBoxErrorBorder,
})}`;
~~~

## General hygiene checks
- Avoid dead code and commented-out blocks.
- Avoid duplication: extract when it clarifies, not when it obfuscates.
- Prefer readability over cleverness.
- Ensure imports are clean and consistent with repo rules.
