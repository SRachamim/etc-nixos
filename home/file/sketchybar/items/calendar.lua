local settings = require("settings")
local colors = require("colors")

local cal = sbar.add("item", "widgets.calendar", {
  icon = {
    color = colors.white,
    padding_left = 8,
    font = {
      style = settings.font.style_map["Black"] or "Bold",
      size = 12.0,
    },
  },
  label = {
    color = colors.white,
    padding_right = 8,
    width = 49,
    align = "right",
    font = { family = settings.font.numbers },
  },
  position = "left",
  update_freq = 30,
  padding_left = 1,
  padding_right = 1,
  background = {
    color = colors.bg2,
    border_color = colors.black,
    border_width = 1,
  },
  click_script = "open -a 'Calendar'",
})

sbar.add("bracket", "widgets.calendar.bracket", { cal.name }, {
  background = {
    color = colors.transparent,
    height = 30,
    border_color = colors.grey,
  },
})

sbar.add("item", "widgets.calendar.padding", {
  position = "left",
  width = settings.group_paddings,
})

cal:subscribe({ "forced", "routine", "system_woke" }, function()
  cal:set({ icon = os.date("%a. %d %b."), label = os.date("%H:%M") })
end)
