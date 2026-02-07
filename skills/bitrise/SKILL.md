---
name: bitrise
description: Interface with the Bitrise REST API from the terminal. Use when a user asks to list apps, inspect builds, trigger or abort builds, query workflow runs, or call any endpoint under api.bitrise.io with a personal access token or workspace API token.
---

# Bitrise API

Use this skill to interact with Bitrise over HTTP from the local shell.

## Prerequisites

- Require a shell environment variable with a Bitrise token:

```bash
export BITRISE_ACCESS_TOKEN="<your-token>"
```

- Optionally override API host/version:

```bash
export BITRISE_API_BASE_URL="https://api.bitrise.io/v0.1"
```

- Never write tokens into `SKILL.md`, `references/`, scripts, or committed files.

## Primary Helper

Use the bundled script for authenticated calls:

```bash
scripts/bitrise_api.sh <METHOD> <PATH> [options]
```

Examples:

```bash
scripts/bitrise_api.sh GET /apps
scripts/bitrise_api.sh GET /me
scripts/bitrise_api.sh GET /apps/<app-slug>/builds --query "limit=20"
scripts/bitrise_api.sh POST /apps/<app-slug>/builds --json @payload.json
scripts/bitrise_api.sh POST /apps/<app-slug>/builds/<build-slug>/abort --json '{"abort_reason":"Stopped by API"}'
```

## Workflow

1. Confirm `BITRISE_ACCESS_TOKEN` exists before calling the API.
2. Discover the needed endpoint in Bitrise docs: `https://docs.bitrise.io/en/bitrise-ci/api/api-reference.html`.
3. Build the request body in a temporary JSON file for non-trivial payloads.
4. Call `scripts/bitrise_api.sh`.
5. If `jq` exists, pretty-print or filter JSON results.

## Troubleshooting

- `401` or `403`: verify token validity, scope/permissions, and workspace/app access.
- `404`: verify endpoint path and slug values.
- `422`: inspect payload schema in API reference and retry with corrected JSON.
- Rate-limit or transient errors: retry with backoff.

## References

- [API quick patterns](references/api-quick-patterns.md)
