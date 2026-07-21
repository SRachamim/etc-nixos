local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local media_control = "/opt/homebrew/bin/media-control"

sbar.add("event", "media_update")

local media_icon = sbar.add("item", "media.icon", {
  position = "left",
  icon = {
    string = icons.media.play_pause,
    color = colors.green,
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
  },
  label = { drawing = false },
  drawing = false,
  padding_right = 0,
  updates = true,
})

local media_label = sbar.add("item", "media.label", {
  position = "left",
  icon = { drawing = false },
  label = {
    string = "",
    max_chars = 30,
    color = colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 13.0,
    },
  },
  drawing = false,
  scroll_texts = true,
})

local media_bracket = sbar.add("bracket", "media.bracket", {
  media_icon.name,
  media_label.name,
}, {
  background = { color = colors.bg1 },
  popup = { align = "center" },
})

local popup_prev = sbar.add("item", "media.popup.prev", {
  position = "popup." .. media_bracket.name,
  icon = {
    string = icons.media.back,
    color = colors.white,
    font = { size = 18.0 },
    padding_left = 10,
    padding_right = 10,
  },
  label = { drawing = false },
  click_script = media_control .. " previous",
})

local popup_play = sbar.add("item", "media.popup.play", {
  position = "popup." .. media_bracket.name,
  icon = {
    string = icons.media.play_pause,
    color = colors.green,
    font = { size = 18.0 },
    padding_left = 10,
    padding_right = 10,
  },
  label = { drawing = false },
  click_script = media_control .. " toggle-play-pause",
})

local popup_next = sbar.add("item", "media.popup.next", {
  position = "popup." .. media_bracket.name,
  icon = {
    string = icons.media.forward,
    color = colors.white,
    font = { size = 18.0 },
    padding_left = 10,
    padding_right = 10,
  },
  label = { drawing = false },
  click_script = media_control .. " next",
})

local function media_collapse_popup()
  local drawing = media_bracket:query().popup.drawing == "on"
  if not drawing then return end
  media_bracket:set({ popup = { drawing = false } })
end

local function media_toggle_popup(env)
  if env.BUTTON == "right" then
    local should_draw = media_bracket:query().popup.drawing == "off"
    if should_draw then
      media_bracket:set({ popup = { drawing = true } })
    else
      media_collapse_popup()
    end
    return
  end
  sbar.exec(media_control .. " toggle-play-pause")
end

local function media_scroll(env)
  local delta = env.INFO.delta
  if delta > 0 then
    sbar.exec(media_control .. " next")
  elseif delta < 0 then
    sbar.exec(media_control .. " previous")
  end
end

media_icon:subscribe("media_update", function(env)
  local title = env.title or ""
  local artist = env.artist or ""
  local is_playing = env.playing == "true"

  local has_media = title ~= ""
  local media_text = ""
  if has_media then
    if artist ~= "" then
      media_text = artist .. " – " .. title
    else
      media_text = title
    end
  end

  local draw = has_media
  media_icon:set({
    drawing = draw,
    icon = {
      color = is_playing and colors.green or colors.grey,
    },
  })
  media_label:set({
    drawing = draw,
    label = { string = media_text },
  })
end)

media_icon:subscribe("mouse.clicked", media_toggle_popup)
media_icon:subscribe("mouse.scrolled", media_scroll)
media_label:subscribe("mouse.clicked", media_toggle_popup)
media_label:subscribe("mouse.scrolled", media_scroll)
media_label:subscribe("mouse.exited.global", media_collapse_popup)

sbar.exec("pkill -f media-stream.sh 2>/dev/null; $CONFIG_DIR/helpers/media-stream.sh &")
