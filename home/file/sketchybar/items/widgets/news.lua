local colors = require("colors")
local icons = require("icons")
local settings = require("settings")

local TICKER_SCRIPT = "$CONFIG_DIR/helpers/news/news-ticker.sh"

sbar.add("event", "news_update")

local current_link = ""

local function relative_time(epoch_str)
  if not epoch_str or epoch_str == "" then return "" end
  local epoch = tonumber(epoch_str)
  if not epoch then return "" end
  local diff = os.time() - epoch
  if diff < 60 then return "now"
  elseif diff < 3600 then return math.floor(diff / 60) .. "m"
  elseif diff < 86400 then return math.floor(diff / 3600) .. "h"
  else return math.floor(diff / 86400) .. "d"
  end
end

local news_icon = sbar.add("item", "widgets.news.icon", {
  position = "right",
  icon = {
    string = icons.news,
    color = colors.magenta,
    font = {
      style = settings.font.style_map["Regular"],
      size = 14.0,
    },
  },
  label = { drawing = false },
  padding_right = 0,
  updates = true,
})

local news_label = sbar.add("item", "widgets.news.label", {
  position = "right",
  icon = { drawing = false },
  label = {
    string = "...טוען חדשות",
    max_chars = 50,
    color = colors.white,
    font = {
      style = settings.font.style_map["Regular"],
      size = 13.0,
    },
    align = "right",
  },
  padding_left = 0,
  update_freq = 30,
  updates = true,
})

local news_bracket = sbar.add("bracket", "widgets.news.bracket", {
  news_icon.name,
  news_label.name,
}, {
  background = { color = colors.bg1 },
  popup = { align = "center", height = 30 },
})

sbar.add("item", "widgets.news.padding", {
  position = "right",
  width = settings.group_paddings,
})

-- Popup items for recent headlines (populated dynamically)
local popup_items = {}
for i = 1, 5 do
  popup_items[i] = sbar.add("item", "widgets.news.popup." .. i, {
    position = "popup." .. news_bracket.name,
    icon = {
      string = "•",
      color = colors.magenta,
      width = 20,
    },
    label = {
      string = "",
      max_chars = 50,
      color = colors.white,
      font = { size = 12.0 },
    },
    click_script = "open ''",
    drawing = false,
  })
end

-- Store recent headlines for popup
local recent_headlines = {}

news_icon:subscribe("news_update", function(env)
  local title = env.title or ""
  local link = env.link or ""
  local epoch = env.epoch or ""

  if title == "" then return end

  current_link = link

  local time_str = relative_time(epoch)
  local display_text = title
  if time_str ~= "" then
    display_text = time_str .. " · " .. title
  end

  news_label:set({ label = { string = display_text } })

  -- Track in recent list
  table.insert(recent_headlines, 1, { title = title, link = link, epoch = epoch })
  if #recent_headlines > 5 then
    table.remove(recent_headlines, 6)
  end

  -- Update popup items
  for i = 1, 5 do
    local h = recent_headlines[i]
    if h then
      local t = relative_time(h.epoch)
      local popup_label = ""
      if t ~= "" then popup_label = t .. " · " end
      popup_label = popup_label .. h.title
      popup_items[i]:set({
        drawing = true,
        label = { string = popup_label },
        click_script = "open '" .. h.link:gsub("'", "'\\''") .. "'",
      })
    else
      popup_items[i]:set({ drawing = false })
    end
  end
end)

-- Routine: refresh every 60s (every 2nd tick), rotate between refreshes
local tick_count = 0
news_label:subscribe("routine", function()
  tick_count = tick_count + 1
  if tick_count % 2 == 0 then
    sbar.exec(TICKER_SCRIPT .. " refresh")
  else
    sbar.exec(TICKER_SCRIPT .. " next")
  end
end)

-- Also refresh on forced/wake
news_icon:subscribe({ "forced", "system_woke" }, function()
  sbar.exec(TICKER_SCRIPT .. " refresh")
end)

-- Left-click: open article in browser
local function open_article()
  if current_link ~= "" then
    sbar.exec("open '" .. current_link:gsub("'", "'\\''") .. "'")
  end
end

-- Right-click: toggle popup
local function toggle_popup(env)
  if env.BUTTON == "right" then
    local drawing = news_bracket:query().popup.drawing == "on"
    news_bracket:set({ popup = { drawing = not drawing } })
    return
  end
  open_article()
end

-- Scroll: advance headlines
local function scroll_news(env)
  local delta = env.INFO and env.INFO.delta or 0
  if delta > 0 then
    sbar.exec(TICKER_SCRIPT .. " next")
  elseif delta < 0 then
    sbar.exec(TICKER_SCRIPT .. " prev")
  end
end

news_icon:subscribe("mouse.clicked", toggle_popup)
news_label:subscribe("mouse.clicked", toggle_popup)
news_icon:subscribe("mouse.scrolled", scroll_news)
news_label:subscribe("mouse.scrolled", scroll_news)
news_label:subscribe("mouse.exited.global", function()
  news_bracket:set({ popup = { drawing = false } })
end)

-- Initial fetch
sbar.exec(TICKER_SCRIPT .. " refresh")
