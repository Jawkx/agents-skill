# Output Structure & Tone

## Tone rules
- Be direct and specific. Do not include praise.
- Focus on outcomes and failure modes, not intent.
- Every issue must include a concrete change.
- Keep it short. Summary is a single line.

## Review output template (required)
Group all issues under the rubric they offend. Only include rubrics that have issues.

Start with a title, then a one-line summary that includes issue counts by severity and overall risk.

Required structure:
1) Title line
2) Summary line
3) Rubric sections with issues

Use this exact issue structure inside each rubric:
- **<Problem>**
- Trigger: <rule/keyword> (include rubric reference if the rule is explicitly listed in the rubric)
- Severity: Must fix | Should fix | Nit
- Solution: the concrete fix.

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

# PR-1234: Portfolio Screen Refactor
Summary: 2 issues (Must fix: 1, Should fix: 1, Nit: 0). Risk: med.

### React Native Performance
**Inline callbacks inside `renderItem` cause list rerenders**
Trigger: inline callbacks/objects in render (React Native Performance rubric)
Severity: Should fix
Solution: hoist `onPress` with `useCallback` and pass stable props to the row component.
