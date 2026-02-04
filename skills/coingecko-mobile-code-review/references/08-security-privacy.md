# Security & Privacy Rubric

## Secrets & sensitive data
Must-fix:
- Hardcoded API keys, secrets, tokens, private URLs.
- Logging tokens, emails, device identifiers, or other PII.

## Storage
- Tokens/sensitive data must use secure storage (per codebase standard).
- Avoid storing secrets in plain AsyncStorage unless explicitly approved.

## Network safety
- Ensure HTTPS is used.
- Handle network failures explicitly (timeouts, retries, offline).
- Do not leak sensitive headers in logs.

## Linking, deep links, WebView
- Validate and sanitize URLs before opening.
- Avoid open-redirect style vulnerabilities (do not blindly open external URLs).
- WebView: be careful with injected JS, untrusted origins, and navigation restrictions.

## Dependency hygiene (security angle)
- New dependencies should be justified:
  - size impact
  - maintenance health
  - license compatibility
  - known vulnerability risk (as feasible)

## Privacy UX
- Do not add new telemetry/logging without:
  - clear purpose
  - no PII
  - respecting user consent settings (if applicable)
