#!/usr/bin/env bash

MEDIA_CONTROL="/opt/homebrew/bin/media-control"
SKETCHYBAR="/opt/homebrew/bin/sketchybar"
JQ="/usr/bin/jq"

title=""
artist=""
playing="false"

cleanup() {
  $SKETCHYBAR --trigger media_update title="" artist="" playing="false" 2>/dev/null
  exit 0
}
trap cleanup EXIT INT TERM

$MEDIA_CONTROL stream | while IFS= read -r line; do
  parsed=$($JQ -r '[.payload.title // "", .payload.artist // "", (.payload.playing // false | tostring)] | @tsv' <<< "$line" 2>/dev/null)

  if [ -z "$parsed" ]; then
    continue
  fi

  new_title=$(echo "$parsed" | cut -f1)
  new_artist=$(echo "$parsed" | cut -f2)
  new_playing=$(echo "$parsed" | cut -f3)

  [ -n "$new_title" ] && title="$new_title"
  [ -n "$new_artist" ] && artist="$new_artist"
  [ "$new_playing" = "true" ] && playing="true"
  [ "$new_playing" = "false" ] && playing="false"

  if [ -z "$title" ] && [ -z "$artist" ]; then
    playing="false"
  fi

  $SKETCHYBAR --trigger media_update title="$title" artist="$artist" playing="$playing"
done
