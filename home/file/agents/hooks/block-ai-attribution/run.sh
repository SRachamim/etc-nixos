# Blocks git commands that write a commit message carrying AI attribution.
# The whole command is scanned, quoted text included, because the trailer
# lives in the -m argument or the heredoc.
cmd=$(jq -r '.tool_input.command // .command // .toolCall.args.CommandLine // .toolCall.args.command // empty')
[ -n "$cmd" ] || exit 0

printf '%s\n' "$cmd" | grep -qE '(^|[;&|(]|[[:space:]])git([[:space:]][^;&|]*)?[[:space:]](commit|commit-tree|rebase|notes)([[:space:]]|$)' || exit 0

attribution='co-authored-by:[^[:cntrl:]]*(claude|anthropic|cursor|copilot|gpt|openai|gemini|codex)|generated with'
if printf '%s\n' "$cmd" | grep -qiE "$attribution"; then
  echo "Blocked: the commit message carries AI attribution. Remove the Co-Authored-By/Generated-with line and commit again." >&2
  exit 2
fi
