local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local LOW_THRESHOLD = 20

local battery = sbar.add("item", "widgets.battery", {
  position = "right",
  icon = {
    font = {
      style = settings.font.style_map["Regular"],
      size = 19.0,
    },
  },
  label = { font = { family = settings.font.numbers } },
  update_freq = 180,
  popup = { align = "center" },
})

local popup_percent = sbar.add("item", {
  position = "popup." .. battery.name,
  icon = {
    string = "Charge:",
    width = 100,
    align = "left",
  },
  label = {
    string = "??%",
    width = 100,
    align = "right",
  },
})

local battery_bracket = sbar.add("bracket", "widgets.battery.bracket", { battery.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.battery.padding", {
  position = "right",
  width = settings.group_paddings,
})

battery:subscribe({ "routine", "power_source_change", "system_woke" }, function()
  sbar.exec("pmset -g batt", function(batt_info)
    local icon = "!"
    local label = "?"

    local found, _, charge = batt_info:find("(%d+)%%")
    if found then
      charge = tonumber(charge)
    end

    local charging = batt_info:find("AC Power")

    local _, _, remaining = batt_info:find("(%d+:%d+) remaining")
    if remaining then
      label = remaining .. "h"
    elseif charging then
      if found and charge >= 100 then
        label = "Full"
      else
        label = "Charging"
      end
    else
      label = "Calc..."
    end

    local color = colors.green
    local is_low = false

    if charging then
      icon = icons.battery.charging
    else
      if found and charge > 80 then
        icon = icons.battery._100
      elseif found and charge > 60 then
        icon = icons.battery._75
      elseif found and charge > 40 then
        icon = icons.battery._50
      elseif found and charge > LOW_THRESHOLD then
        icon = icons.battery._25
        color = colors.orange
      else
        icon = icons.battery.warning
        color = colors.black
        is_low = true
      end
    end

    battery:set({
      icon = { string = icon, color = color },
      label = { string = label },
    })

    battery_bracket:set({
      background = { color = is_low and colors.red or colors.bg1 },
    })

    if found then
      popup_percent:set({ label = charge .. "%" })
    end
  end)
end)

battery:subscribe("mouse.clicked", function()
  battery:set({ popup = { drawing = "toggle" } })
end)

battery:subscribe("mouse.exited.global", function()
  battery:set({ popup = { drawing = false } })
end)
