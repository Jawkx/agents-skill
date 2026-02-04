# Output Structure & Tone

## Tone rules
- Be direct and specific. Do not include praise.
- Focus on outcomes and failure modes, not intent.
- Every issue must include a concrete change.
- Keep it short. No summary section.

## Review output template (required)
Group all issues under the rubric they offend. Only include rubrics that have issues.

Use this exact issue structure:
- Problem: what is wrong and the impact/risk.
- Change: the concrete fix.

Recommended rubric headings:
- Standards & TypeScript
- React Native Performance
- Navigation
- Redux & Epics
- State, Effects & Hooks
- Error Handling & Validation
- Security & Privacy
- Testing & Quality
- Architecture & Maintainability
- UI/UX, Accessibility & Localization
- Other

### Example

#### React Native Performance
Problem: `renderItem` creates inline callbacks, which will thrash list item renders.
Change: hoist `onPress` with `useCallback` and pass stable props to the row component.
