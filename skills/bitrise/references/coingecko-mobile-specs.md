# CoinGecko Mobile Bitrise Specs

Last verified: February 9, 2026 (via Bitrise API)

## Apps

- Android app title: `coingecko-mobile-android`
- Android app slug: `36b04c9057195c56`
- iOS app title: `coingecko-mobile-ios`
- iOS app slug: `aa0ed863556c3617`

## Workflows

### Android (`36b04c9057195c56`)

- `internal-production`
- `automate-google-phased-rollout`
- `appstore-production`
- `internal-staging3`
- `internal-staging1`
- `internal-staging-mobile`
- `internal-price-store-debug`
- `rr-test-gh`
- `test-env-override`

### iOS (`aa0ed863556c3617`)

- `internal-production`
- `appstore-production`
- `internal-staging3`
- `internal-staging1`
- `internal-staging-mobile`
- `internal-price-store-debug`
- `internal-production-no-slack`
- `internal-production-no-slack-no-cache`
- `deploy-local-build`

## Shared Workflows Across Android and iOS

- `internal-production`
- `appstore-production`
- `internal-staging3`
- `internal-staging1`
- `internal-staging-mobile`
- `internal-price-store-debug`

## Build Decision Rule

- If the user does not explicitly specify a workflow ID, ask a clarification question before triggering any build.
- If the user asks to "build CoinGecko mobile" without platform, ask whether to build Android, iOS, or both.
- Do not guess workflow IDs when multiple valid options exist.

## Trigger Example

```bash
cat > /tmp/bitrise-build.json <<'JSON'
{
  "hook_info": { "type": "bitrise" },
  "build_params": {
    "branch": "your-branch",
    "workflow_id": "internal-production"
  }
}
JSON

scripts/bitrise_api.sh POST /apps/<app-slug>/builds --json @/tmp/bitrise-build.json
```
