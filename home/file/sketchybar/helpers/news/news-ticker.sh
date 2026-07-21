#!/usr/bin/env bash
# news-ticker.sh -- Fetch RSS headlines and push to SketchyBar
# Usage:
#   news-ticker.sh refresh   -- fetch new headlines from a random source
#   news-ticker.sh next      -- advance to next headline
#   news-ticker.sh prev      -- go to previous headline
#   news-ticker.sh current   -- output current headline to SketchyBar

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
CACHE_DIR="$HOME/.cache/sketchybar/news"
QUEUE_FILE="$CACHE_DIR/queue.tsv"
INDEX_FILE="$CACHE_DIR/index"
SKETCHYBAR="/opt/homebrew/bin/sketchybar"
PYTHON="/usr/bin/python3"
PARSER="$SCRIPT_DIR/parse_rss.py"

mkdir -p "$CACHE_DIR"
[ -f "$QUEUE_FILE" ] || touch "$QUEUE_FILE"
[ -f "$INDEX_FILE" ] || echo "0" > "$INDEX_FILE"

FEEDS=(
  "BBC News|https://feeds.bbci.co.uk/news/world/rss.xml"
  "Reuters|https://www.rss.app/feeds/tRdlDvSbMmjmkLCi.xml"
  "Al Jazeera|https://www.aljazeera.com/xml/rss/all.xml"
  "TechCrunch|https://techcrunch.com/feed/"
  "Ars Technica|https://feeds.arstechnica.com/arstechnica/index"
  "Hacker News|https://hnrss.org/frontpage"
  "Times of Israel|https://www.timesofisrael.com/feed/"
  "Ynet News|https://www.ynetnews.com/category/3082/rss"
)

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
    $SKETCHYBAR --trigger news_update title="" link="" source=""
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
  local title link source
  title=$(echo "$line" | cut -f1)
  link=$(echo "$line" | cut -f2)
  source=$(echo "$line" | cut -f3)

  $SKETCHYBAR --trigger news_update title="$title" link="$link" source="$source"
}

do_refresh() {
  local feed_count=${#FEEDS[@]}
  local rand_idx=$((RANDOM % feed_count))
  local feed_entry="${FEEDS[$rand_idx]}"
  local source_name="${feed_entry%%|*}"
  local feed_url="${feed_entry#*|}"

  local xml
  xml=$(curl -sL --max-time 10 "$feed_url" 2>/dev/null)
  [ -z "$xml" ] && return 1

  local new_entries
  new_entries=$(echo "$xml" | "$PYTHON" "$PARSER" "$source_name" 2>/dev/null)
  [ -z "$new_entries" ] && return 1

  # Dedup by link (field 2) against existing queue
  while IFS= read -r entry; do
    local link
    link=$(echo "$entry" | cut -f2)
    if ! grep -qF "$link" "$QUEUE_FILE" 2>/dev/null; then
      echo "$entry" >> "$QUEUE_FILE"
    fi
  done <<< "$new_entries"

  # Keep only the latest 100 entries
  local count
  count=$(queue_count)
  if [ "$count" -gt 100 ]; then
    local trim=$((count - 100))
    tail -n 100 "$QUEUE_FILE" > "$CACHE_DIR/queue_tmp.tsv"
    mv "$CACHE_DIR/queue_tmp.tsv" "$QUEUE_FILE"
    local idx
    idx=$(get_index)
    idx=$((idx - trim))
    [ "$idx" -lt 0 ] && idx=0
    set_index "$idx"
  fi

  push_current
}

do_next() {
  local idx
  idx=$(get_index)
  idx=$((idx + 1))
  set_index "$idx"
  push_current
}

do_prev() {
  local idx
  idx=$(get_index)
  idx=$((idx - 1))
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
