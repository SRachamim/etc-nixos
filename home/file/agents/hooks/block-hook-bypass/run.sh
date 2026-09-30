# Blocks git commit/push invocations that skip git hooks. Quoted text is
# ignored, so a commit message mentioning --no-verify passes.
cmd=$(jq -r '.tool_input.command // .command // .toolCall.args.CommandLine // .toolCall.args.command // empty')
[ -n "$cmd" ] || exit 0

unquoted=$(printf '%s' "$cmd" | sed -E "s/'[^']*'//g; s/\"([^\"\\\\]|\\\\.)*\"//g")

bypass='(^|[;&|(])[[:space:]]*git[^;&|]*[[:space:]](commit|push)[[:space:]]([^;&|]*[[:space:]])?--no-verify([[:space:]]|$)'
commit_n='(^|[;&|(])[[:space:]]*git[^;&|]*[[:space:]]commit[[:space:]]([^;&|]*[[:space:]])?-[a-zA-Z]*n[a-zA-Z]*([[:space:]]|$)'

if printf '%s\n' "$unquoted" | grep -qE "$bypass|$commit_n"; then
  echo "Blocked: this git command skips git hooks. Fix the failure the hook reports and commit or push normally." >&2
  exit 2
fi
