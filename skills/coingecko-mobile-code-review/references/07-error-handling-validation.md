# Error Handling & Validation Rubric

## Red flags (quick hits)
- Async calls without `try/catch` (or equivalent error handling)
- Errors that are swallowed or only logged with no user-visible state when one is expected

## Async operations
- Ensure `try/catch` exists for:
  - network calls
  - parsing (JSON/date/number)
  - storage IO
- Errors should map to:
  - a user-facing state/message where appropriate
  - logging/reporting where appropriate (without leaking PII)

## UI states
- Loading states: avoid blank screens
- Empty states: be explicit and helpful
- Error states: provide retry path when meaningful

## Validation
- Validate user inputs (forms, search, deep link params).
- Sanitize user-generated content before rendering where applicable.
- Ensure "happy path only" code is hardened with edge cases:
  - null/undefined
  - empty arrays
  - offline / timeout
  - partial data

## Error boundaries
- Use error boundaries for:
  - risky UI trees
  - third-party components prone to throw
  - critical screens where crash would be painful

## What to flag
- silent failures
- swallowed errors
- "console.log the error and continue" with no UX response (when user expects one)
