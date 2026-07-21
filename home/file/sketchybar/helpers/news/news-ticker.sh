#!/usr/bin/env bash
# news-ticker.sh -- Fetch i24news Hebrew headlines and push to SketchyBar
# Usage:
#   news-ticker.sh refresh   -- fetch new headlines
#   news-ticker.sh next      -- advance to next headline
#   news-ticker.sh prev      -- go to previous headline
#   news-ticker.sh current   -- output current headline to SketchyBar

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.cache/sketchybar/news"
QUEUE_FILE="$CACHE_DIR/queue.tsv"
INDEX_FILE="$CACHE_DIR/index"
SKETCHYBAR="/opt/homebrew/bin/sketchybar"
PYTHON="/usr/bin/python3"
FETCHER="$SCRIPT_DIR/fetch_i24.py"

mkdir -p "$CACHE_DIR"
[ -f "$QUEUE_FILE" ] || touch "$QUEUE_FILE"
[ -f "$INDEX_FILE" ] || echo "0" > "$INDEX_FILE"

get_index() {
  cat "$INDEX_FILE" 2>/dev/null || echo "0"
}

set_index() {
  echo "$1" > "$INDEX_FILE"
}

queue_count() {
  wc -l < "$QUEUE_FILE" | tr -d ' '
}

push_current() {
  local idx
  idx=$(get_index)
  local count
  count=$(queue_count)

  if [ "$count" -eq 0 ]; then
    $SKETCHYBAR --trigger news_update title="" link="" source="" epoch=""
    return
  fi

  # Wrap around
  if [ "$idx" -ge "$count" ]; then
    idx=0
    set_index 0
  fi
  if [ "$idx" -lt 0 ]; then
    idx=$((count - 1))
    set_index "$idx"
  fi

  local line
  line=$(sed -n "$((idx + 1))p" "$QUEUE_FILE")
  local title link source epoch
  title=$(echo "$line" | cut -f1)
  link=$(echo "$line" | cut -f2)
  source=$(echo "$line" | cut -f3)
  epoch=$(echo "$line" | cut -f4)

  $SKETCHYBAR --trigger news_update title="$title" link="$link" source="$source" epoch="$epoch"
}

do_refresh() {
  local new_entries
  new_entries=$("$PYTHON" "$FETCHER" 2>/dev/null)
  [ -z "$new_entries" ] && return 1

  # Filter: keep only items from the last 60 minutes
  local now
  now=$(date +%s)
  local cutoff=$((now - 3600))
  local filtered=""

  while IFS= read -r entry; do
    local epoch
    epoch=$(echo "$entry" | cut -f4)
    if [ -n "$epoch" ] && [ "$epoch" -ge "$cutoff" ] 2>/dev/null; then
      filtered="${filtered}${entry}
"
    fi
  done <<< "$new_entries"

  if [ -z "$filtered" ]; then
    # No recent news; clear the display
    echo "" > "$QUEUE_FILE"
    set_index 0
    $SKETCHYBAR --trigger news_update title="" link="" source="" epoch=""
    return
  fi

  # Replace queue with filtered results (newest first)
  printf "%s" "$filtered" > "$QUEUE_FILE"

  # Point to the first (newest) item
  set_index 0
  push_current
}

do_next() {
  local idx
  idx=$(get_index)
  local count
  count=$(queue_count)
  [ "$count" -eq 0 ] && return
  idx=$(( (idx + 1) % count ))
  set_index "$idx"
  push_current
}

do_prev() {
  local idx
  idx=$(get_index)
  local count
  count=$(queue_count)
  [ "$count" -eq 0 ] && return
  idx=$(( (idx - 1 + count) % count ))
  set_index "$idx"
  push_current
}

case "${1:-current}" in
  refresh)  do_refresh ;;
  next)     do_next ;;
  prev)     do_prev ;;
  current)  push_current ;;
  *)        push_current ;;
esac
