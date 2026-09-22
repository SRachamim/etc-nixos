# ctx -- per-thread context for the terminal development environment.
#
# A "thread" is a git worktree: one branch, one work item, one pull request, one
# Agent of Empires session. Work item and PR links are derived from the branch
# name and the origin remote rather than stored, so a new worktree needs no
# setup. Only links that cannot be derived -- a dashboard, a test run -- are
# pinned, and they live in the worktree's git directory so they die with it.
#
# Strictness flags come from writeShellApplication; do not set them here.

CTX_BROWSER="${CTX_BROWSER:-Google Chrome}"

die() {
  printf 'ctx: %s\n' "$*" >&2
  exit 1
}

warn() {
  printf 'ctx: %s\n' "$*" >&2
}

usage() {
  cat <<'USAGE'
ctx -- open the work item, pull request and pinned links for this worktree

Usage:
  ctx                    Open every link for this thread in one browser window
  ctx wi                 Open the work item
  ctx pr                 Open the pull request
  ctx ls                 List this thread's links
  ctx add <name> <url>   Pin a link to this thread
  ctx rm <name>          Unpin a link

Environment:
  CTX_BROWSER            Browser application name (default: Google Chrome)
USAGE
}

links_file() {
  printf '%s/ctx-links' "$(git rev-parse --git-dir)"
}

branch() {
  git symbolic-ref --quiet --short HEAD || die 'detached HEAD -- no thread branch'
}

# Populates ADO_ORG, ADO_PROJECT and ADO_REPO from the origin remote.
# Returns non-zero when origin is not an Azure DevOps remote.
parse_remote() {
  local url path
  url=$(git remote get-url origin 2>/dev/null) || return 1
  case "$url" in
    *ssh.dev.azure.com:v3/*)
      path=${url##*:v3/}
      ;;
    *dev.azure.com/*)
      path=${url#*dev.azure.com/}
      path=${path/\/_git\//\/}
      ;;
    *)
      return 1
      ;;
  esac
  path=${path%.git}
  IFS=/ read -r ADO_ORG ADO_PROJECT ADO_REPO <<<"$path"
  [ -n "${ADO_REPO:-}" ] || return 1
}

require_remote() {
  parse_remote || die 'origin is not an Azure DevOps remote'
}

# Work item id from the branch: feature/12345-slug, or a bare 12345-slug.
work_item_id() {
  local id
  id=$(branch | sed -n -e 's|^[^/]*/\([0-9][0-9]*\)-.*|\1|p' -e 's|^\([0-9][0-9]*\)-.*|\1|p' | head -1)
  [ -n "$id" ] || return 1
  printf '%s' "$id"
}

pull_request_id() {
  local id
  id=$(az repos pr list \
    --org "https://dev.azure.com/$ADO_ORG" \
    --project "$ADO_PROJECT" \
    --repository "$ADO_REPO" \
    --source-branch "$(branch)" \
    --status active \
    --query '[0].pullRequestId' \
    --output tsv 2>/dev/null) || return 1
  [ -n "$id" ] || return 1
  printf '%s' "$id"
}

work_item_url() {
  printf 'https://dev.azure.com/%s/%s/_workitems/edit/%s' "$ADO_ORG" "$ADO_PROJECT" "$1"
}

pull_request_url() {
  printf 'https://dev.azure.com/%s/%s/_git/%s/pullrequest/%s' "$ADO_ORG" "$ADO_PROJECT" "$ADO_REPO" "$1"
}

# Opens every URL as tabs of a single new window, which AeroSpace places in the
# workspace holding this terminal -- the thread keeps its pages together.
open_urls() {
  [ "$#" -gt 0 ] || die 'no links for this thread'
  if [ -x /usr/bin/open ]; then
    /usr/bin/open -na "$CTX_BROWSER" --args --new-window "$@"
  elif command -v xdg-open >/dev/null 2>&1; then
    local url
    for url in "$@"; do
      xdg-open "$url"
    done
  else
    printf '%s\n' "$@"
  fi
}

pinned_links() {
  local file
  file=$(links_file)
  [ -f "$file" ] && cat "$file"
}

pin_link() {
  unpin_link "$1"
  printf '%s\t%s\n' "$1" "$2" >>"$(links_file)"
}

unpin_link() {
  local file tmp
  file=$(links_file)
  [ -f "$file" ] || return 0
  tmp=$(mktemp)
  grep -v -- "^$1"$'\t' "$file" >"$tmp" || true
  mv "$tmp" "$file"
}

# Prints "name<TAB>url" for every link of this thread.
resolve_links() {
  local id
  if id=$(work_item_id); then
    printf 'work-item\t%s\n' "$(work_item_url "$id")"
  else
    warn "branch '$(branch)' carries no work item id"
  fi
  if id=$(pull_request_id); then
    printf 'pull-request\t%s\n' "$(pull_request_url "$id")"
  else
    warn "no active pull request for '$(branch)'"
  fi
  pinned_links
}

git rev-parse --git-dir >/dev/null 2>&1 || die 'not a git repository'

case "${1:-open}" in
  open)
    require_remote
    mapfile -t urls < <(resolve_links | cut -f2)
    open_urls "${urls[@]}"
    ;;
  wi)
    require_remote
    id=$(work_item_id) || die "branch '$(branch)' carries no work item id"
    open_urls "$(work_item_url "$id")"
    ;;
  pr)
    require_remote
    id=$(pull_request_id) || die "no active pull request for '$(branch)'"
    open_urls "$(pull_request_url "$id")"
    ;;
  ls)
    require_remote
    resolve_links | while IFS=$'\t' read -r name url; do
      printf '%-14s %s\n' "$name" "$url"
    done
    ;;
  add)
    [ "$#" -eq 3 ] || die 'usage: ctx add <name> <url>'
    pin_link "$2" "$3"
    ;;
  rm)
    [ "$#" -eq 2 ] || die 'usage: ctx rm <name>'
    unpin_link "$2"
    ;;
  -h | --help | help)
    usage
    ;;
  *)
    usage >&2
    exit 1
    ;;
esac
