# Bitrise API Quick Patterns

Use these as request templates with `scripts/bitrise_api.sh`.

## Base URL and Auth

- Base URL: `https://api.bitrise.io/v0.1`
- Header: `Authorization: <token>`

## Check caller identity and token

```bash
scripts/bitrise_api.sh GET /me
```

## List apps

```bash
scripts/bitrise_api.sh GET /apps
```

## List builds for an app

```bash
scripts/bitrise_api.sh GET /apps/<app-slug>/builds --query "limit=20"
```

## Trigger a build

```bash
cat > /tmp/bitrise-build.json <<'JSON'
{
  "hook_info": { "type": "bitrise" },
  "build_params": {
    "branch": "main",
    "workflow_id": "primary"
  }
}
JSON

scripts/bitrise_api.sh POST /apps/<app-slug>/builds --json @/tmp/bitrise-build.json
```

## Abort a running build

```bash
scripts/bitrise_api.sh POST /apps/<app-slug>/builds/<build-slug>/abort --json '{"abort_reason":"Stopped by API"}'
```

## Notes

- Keep payloads in files for complex requests to reduce quoting errors.
- Use `jq` to parse responses:

```bash
scripts/bitrise_api.sh GET /apps | jq '.data[] | {slug, title}'
```

- See full API docs:
  - Overview: https://docs.bitrise.io/en/bitrise-ci/api/api-overview.html
  - Reference: https://docs.bitrise.io/en/bitrise-ci/api/api-reference.html
