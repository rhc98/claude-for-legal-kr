#!/bin/sh
# Register the 국가법령정보 (korean-law) MCP with Claude Code.
# Usage: LAW_OC="<your OC key>" ./scripts/install-korean-law-mcp.sh
#
# A free OC 인증키 is required. Sign up at https://open.law.go.kr and the key
# arrives by email in ~1 minute.
set -eu

MCP_NAME="${KOREAN_LAW_MCP_NAME:-korean-law}"
MCP_BASE_URL="https://mcp.gomdori.app/law"

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found in PATH. Install Claude Code first: https://claude.com/claude-code" >&2
  exit 1
fi

# The OC key is mandatory. Accept it from LAW_OC, else prompt interactively.
if [ -z "${LAW_OC:-}" ]; then
  echo "국가법령정보 MCP requires a free OC 인증키 (open.law.go.kr, ~1 min to issue)."
  printf "Enter your LAW_OC key: "
  read -r LAW_OC
fi

if [ -z "${LAW_OC:-}" ]; then
  echo "ERROR: No OC key provided. Get one free at https://open.law.go.kr and set LAW_OC." >&2
  exit 1
fi

MCP_URL="${MCP_BASE_URL}?oc=${LAW_OC}"

# Idempotent: skip if already registered.
if claude mcp list 2>/dev/null | grep -q "^${MCP_NAME}:"; then
  echo "  korean-law MCP already registered as '${MCP_NAME}'. Skipping."
else
  echo "-> Registering 국가법령정보 (korean-law) MCP as '${MCP_NAME}'..."
  claude mcp add "$MCP_NAME" "$MCP_URL" --transport http
  echo "  Registered."
fi

# Smoke test: a simple law search.
echo "-> Running smoke test (search_law '민사소송법')..."
if claude mcp call "$MCP_NAME" search_law "민사소송법" >/tmp/korean-law-smoke.json 2>&1; then
  echo "  Smoke test passed. Sample saved to /tmp/korean-law-smoke.json"
else
  echo "  Smoke test failed. Output:" >&2
  cat /tmp/korean-law-smoke.json >&2
  echo "  Check that your LAW_OC key is valid (open.law.go.kr)." >&2
  exit 2
fi

cat <<'EOF'

국가법령정보 (korean-law) MCP is ready. Next steps:

  1. Install the privacy-legal plugin:
       claude plugin install privacy-legal@claude-for-legal-kr
  2. Run the cold-start interview:
       /privacy-legal:cold-start-interview

Auth: a free OC 인증키 (LAW_OC) is required — sign up at https://open.law.go.kr.
Rate limits follow the 법제처 국가법령정보 Open API policy. 429 responses are
handled by simple exponential backoff inside each skill.
EOF
