#!/usr/bin/env bash
# Diagnostic script for Azure DevOps MCP — writes NDJSON to the debug session log.
set -euo pipefail

LOG="${DEBUG_ADO_MCP_LOG:-$HOME/.local/share/debug-ado-mcp.log}"
RUN_ID="${1:-diagnostic}"

log() {
  local hypothesis_id="$1" location="$2" message="$3" data="$4"
  printf '%s\n' "{\"runId\":\"$RUN_ID\",\"hypothesisId\":\"$hypothesis_id\",\"location\":\"$location\",\"message\":\"$message\",\"data\":$data,\"timestamp\":$(($(date +%s) * 1000))}" >> "$LOG"
}

# H1: Cursor MCP config file missing or incomplete
MCP_JSON="$HOME/.cursor/mcp.json"
MCP_EXISTS=false
MCP_SERVERS="[]"
if [ -f "$MCP_JSON" ]; then
  MCP_EXISTS=true
  MCP_SERVERS=$(python3 -c "import json; d=json.load(open('$MCP_JSON')); print(json.dumps(sorted(d.get('mcpServers',{}).keys())))" 2>/dev/null || echo '[]')
fi
EXPECTED='["Azure DevOps","Slack","fundguard"]'
REDUNDANT_REMOVED=$(python3 -c "import json; print(json.loads('$MCP_SERVERS')==json.loads('$EXPECTED'))" 2>/dev/null || echo false)
log "H1" "debug-ado-mcp.sh:mcp-json" "cursor mcp.json check" \
  "{\"exists\":$MCP_EXISTS,\"servers\":$MCP_SERVERS,\"expected\":$EXPECTED,\"no_redundant_servers\":$REDUNDANT_REMOVED}"

# H2: Nix wrapper still on disk (from Claude config)
WRAPPER=$(python3 -c "import json; d=json.load(open('$HOME/.claude.json')); print(d.get('mcpServers',{}).get('Azure DevOps',{}).get('command',''))" 2>/dev/null || echo "")
WRAPPER_OK=false
if [ -n "$WRAPPER" ] && [ -x "$WRAPPER" ]; then WRAPPER_OK=true; fi
log "H2" "debug-ado-mcp.sh:wrapper" "nix wrapper check" \
  "{\"wrapper\":\"$WRAPPER\",\"executable\":$WRAPPER_OK}"

# H3: plugin-azure-azure needs npx (different from ADO MCP)
log "H3" "debug-ado-mcp.sh:npx" "npx on PATH" \
  "{\"npx_in_path\":$(command -v npx >/dev/null && echo true || echo false)}"

# H4: ADO_PAT available after sourcing secrets
source "$HOME/.secrets" 2>/dev/null || true
log "H4" "debug-ado-mcp.sh:secrets" "ADO_PAT after source" \
  "{\"ado_pat_set\":$([ -n "${ADO_PAT:-}" ] && echo true || echo false)}"

# H5: wrapper starts and prints startup JSON
if [ "$WRAPPER_OK" = true ]; then
  STARTUP=$("$WRAPPER" 2>&1 & pid=$!; sleep 1; kill "$pid" 2>/dev/null; wait "$pid" 2>/dev/null || true)
  STARTED=false
  echo "$STARTUP" | grep -q "Starting Azure DevOps MCP Server" && STARTED=true
  log "H5" "debug-ado-mcp.sh:startup" "manual wrapper startup" \
    "{\"started\":$STARTED,\"first_line\":$(python3 -c "import json,sys; print(json.dumps(sys.stdin.read().splitlines()[0] if sys.stdin.read() else ''))" <<< "$STARTUP" 2>/dev/null || echo '""')}"
fi

echo "Diagnostics written to $LOG"
