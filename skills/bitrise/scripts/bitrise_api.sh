#!/usr/bin/env bash
set -euo pipefail

usage() {
  cat <<'EOF'
Usage:
  bitrise_api.sh <METHOD> <PATH> [--query "k=v&k2=v2"] [--json '{"k":"v"}'|@file] [--header "K: V"]...

Examples:
  bitrise_api.sh GET /apps
  bitrise_api.sh GET /apps/<app-slug>/builds --query "limit=20"
  bitrise_api.sh POST /apps/<app-slug>/builds --json @payload.json
EOF
}

if [[ "${1:-}" == "-h" || "${1:-}" == "--help" ]]; then
  usage
  exit 0
fi

if [[ "${1:-}" == "" || "${2:-}" == "" ]]; then
  usage
  exit 1
fi

METHOD="$1"
PATH_PART="$2"
shift 2

QUERY=""
JSON_PAYLOAD=""
declare -a EXTRA_HEADERS=()

while [[ $# -gt 0 ]]; do
  case "$1" in
    --query)
      QUERY="${2:-}"
      shift 2
      ;;
    --json)
      JSON_PAYLOAD="${2:-}"
      shift 2
      ;;
    --header)
      EXTRA_HEADERS+=("$2")
      shift 2
      ;;
    -h|--help)
      usage
      exit 0
      ;;
    *)
      echo "Unknown argument: $1" >&2
      usage
      exit 1
      ;;
  esac
done

TOKEN="${BITRISE_ACCESS_TOKEN:-${BITRISE_API_TOKEN:-}}"
if [[ -z "$TOKEN" ]]; then
  echo "Missing token. Set BITRISE_ACCESS_TOKEN (or BITRISE_API_TOKEN)." >&2
  exit 1
fi

BASE_URL="${BITRISE_API_BASE_URL:-https://api.bitrise.io/v0.1}"
if [[ "$PATH_PART" == /* ]]; then
  URL="${BASE_URL}${PATH_PART}"
else
  URL="${BASE_URL}/${PATH_PART}"
fi

if [[ -n "$QUERY" ]]; then
  URL="${URL}?${QUERY}"
fi

declare -a CURL_ARGS=(
  -sS
  -X "$METHOD"
  -H "Authorization: ${TOKEN}"
  -H "Accept: application/json"
  "$URL"
)

for header in "${EXTRA_HEADERS[@]-}"; do
  CURL_ARGS+=(-H "$header")
done

if [[ -n "$JSON_PAYLOAD" ]]; then
  CURL_ARGS+=(-H "Content-Type: application/json")
  CURL_ARGS+=(--data "$JSON_PAYLOAD")
fi

curl "${CURL_ARGS[@]}"
