# wm-checkout -- start an Azure DevOps work item in its own workmux window.
#
# Runs /checkout-worktree-g headless (fetches the starting ref, creates
# <root>/<prefix>/<id>-<slug>, activates the work item), then opens the new
# worktree with `workmux open`. The new worktree is detected from git rather
# than from Claude's output, so wording changes in the skill do not break it.
#
# Strictness flags come from writeShellApplication; do not set them here.

die() {
  printf 'wm-checkout: %s\n' "$*" >&2
  exit 1
}

usage() {
  cat <<'USAGE'
wm-checkout -- create a worktree for a work item and open it in workmux

Usage:
  wm-checkout <work-item-id> [starting-ref]

Runs /checkout-worktree-g <id> [starting-ref] with `claude -p`, then
`workmux open <branch>` in the current tmux session. Run it from any
worktree of the repository, inside tmux.
USAGE
}

# Tools the skill needs, and nothing else: a denied tool fails the run
# instead of waiting on a prompt nobody can answer.
allowed_tools=(
  "Bash(git:*)"
  "Skill"
  "Read(~/.claude/skills/**)"
  # Each SKILL.md there is a home-manager symlink into /nix/store, and Claude
  # checks the resolved path, so the rule above alone is denied.
  "Read(//nix/store/**/SKILL.md)"
  "mcp__fundguard__get_work_item"
  "mcp__fundguard__update_work_item"
  "mcp__Azure_DevOps__wit_get_work_item"
  "mcp__Azure_DevOps__wit_update_work_item"
)

worktree_branches() {
  git worktree list --porcelain | grep '^branch ' | sed 's|^branch refs/heads/||' | sort
}

case "${1:-}" in
  -h | --help) usage; exit 0 ;;
  '') usage >&2; exit 1 ;;
esac

id=$1
ref=${2:-}
[[ $id =~ ^[0-9]+$ ]] || die "work item id must be numeric: $id"
[[ -n ${TMUX:-} ]] || die "run inside tmux: workmux opens the window in the current session"
git rev-parse --git-dir >/dev/null 2>&1 || die "run inside a worktree of the repository"

before=$(worktree_branches)

prompt="/checkout-worktree-g $id${ref:+ $ref}

Non-interactive run: skip the Evolve step."
claude -p "$prompt" --allowedTools "${allowed_tools[@]}" ||
  die "claude exited with an error"

after=$(worktree_branches)
new=$(comm -13 <(printf '%s\n' "$before") <(printf '%s\n' "$after"))

[[ -n $new ]] || die "no worktree was created; see Claude's output above"
[[ $(printf '%s\n' "$new" | wc -l) -eq 1 ]] || die "more than one new worktree: $new"

workmux open "$new"
