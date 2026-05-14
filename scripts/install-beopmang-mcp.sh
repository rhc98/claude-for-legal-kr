#!/usr/bin/env bash
# Register the Beopmang MCP with Claude Code.
# Usage: ./scripts/install-beopmang-mcp.sh
set -euo pipefail

MCP_NAME="${BEOPMANG_MCP_NAME:-beopmang}"
MCP_URL="https://api.beopmang.org/mcp"

if ! command -v claude >/dev/null 2>&1; then
  echo "ERROR: claude CLI not found in PATH. Install Claude Code first: https://claude.com/claude-code" >&2
  exit 1
fi

# Idempotent: skip if already registered.
if claude mcp list 2>/dev/null | grep -q "^${MCP_NAME}:"; then
  echo "  Beopmang MCP already registered as '${MCP_NAME}'. Skipping."
else
  echo "→ Registering Beopmang MCP as '${MCP_NAME}'..."
  claude mcp add "$MCP_NAME" "$MCP_URL" --transport http
  echo "  Registered."
fi

# Smoke test: a simple law search.
echo "→ Running smoke test (law search '개인정보보호법')..."
if claude mcp call "$MCP_NAME" law search "개인정보보호법" >/tmp/beopmang-smoke.json 2>&1; then
  echo "  Smoke test passed. Sample saved to /tmp/beopmang-smoke.json"
else
  echo "  Smoke test failed. Output:" >&2
  cat /tmp/beopmang-smoke.json >&2
  exit 2
fi

cat <<'EOF'

Beopmang MCP is ready. Next steps:

  1. Install the privacy-legal plugin:
       claude plugin install privacy-legal@claude-for-legal-kr
  2. Run the cold-start interview:
       /privacy-legal:cold-start-interview

Rate limit: 100 requests/minute (per-IP, unofficial). 429 responses are
handled by simple exponential backoff inside each skill.
EOF
