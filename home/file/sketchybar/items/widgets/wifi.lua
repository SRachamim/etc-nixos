local icons = require("icons")
local colors = require("colors")
local settings = require("settings")

local popup_width = 250

local wifi = sbar.add("item", "widgets.wifi", {
  position = "right",
  icon = {
    string = icons.wifi.disconnected,
    color = colors.grey,
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
  },
  label = { drawing = false },
  update_freq = 60,
})

local wifi_bracket = sbar.add("bracket", "widgets.wifi.bracket", { wifi.name }, {
  background = { color = colors.bg1 },
  popup = { align = "center", height = 30 },
})

local ssid_item = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = {
    string = icons.wifi.router,
    font = { style = settings.font.style_map["Bold"] },
    width = 30,
  },
  label = {
    string = "Not connected",
    font = { size = 14, style = settings.font.style_map["Bold"] },
    max_chars = 24,
    width = popup_width - 30,
  },
  background = {
    height = 2,
    color = colors.grey,
    y_offset = -15,
  },
})

local settings_item = sbar.add("item", {
  position = "popup." .. wifi_bracket.name,
  icon = { drawing = false },
  label = {
    string = "Wi-Fi Settings...",
    color = colors.blue,
    font = { size = 13 },
    width = popup_width,
    align = "center",
  },
  click_script = 'open "x-apple.systempreferences:com.apple.wifi-settings-extension"',
})

sbar.add("item", "widgets.wifi.padding", {
  position = "right",
  width = settings.group_paddings,
})

local function update_wifi()
  sbar.exec("ipconfig getifaddr en0", function(ip_addr)
    local connected = ip_addr ~= ""
    wifi:set({
      icon = {
        string = connected and icons.wifi.connected or icons.wifi.disconnected,
        color = connected and colors.green or colors.red,
      },
    })
  end)
end

wifi:subscribe({ "wifi_change", "system_woke", "routine" }, update_wifi)

wifi:subscribe("mouse.clicked", function()
  local should_draw = wifi_bracket:query().popup.drawing == "off"
  if should_draw then
    wifi_bracket:set({ popup = { drawing = true } })
    sbar.exec("ipconfig getsummary en0 | awk -F ' SSID : '  '/ SSID : / {print $2}'", function(result)
      local name = result:match("^%s*(.-)%s*$") or ""
      ssid_item:set({ label = name ~= "" and name or "Not connected" })
    end)
  else
    wifi_bracket:set({ popup = { drawing = false } })
  end
end)

wifi:subscribe("mouse.exited.global", function()
  wifi_bracket:set({ popup = { drawing = false } })
end)

update_wifi()
