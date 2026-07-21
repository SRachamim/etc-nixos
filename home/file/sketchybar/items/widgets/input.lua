local colors = require("colors")
local settings = require("settings")

sbar.add("event", "input_change", "AppleSelectedInputSourcesChangedNotification")

local input = sbar.add("item", "widgets.input", {
  position = "right",
  icon = {
    string = "􀆪",
    font = { size = 16.0 },
    color = colors.white,
  },
  label = {
    string = "??",
    font = {
      family = settings.font.text,
      style = settings.font.style_map["Bold"],
      size = 12.0,
    },
    color = colors.white,
  },
  update_freq = 0,
})

sbar.add("bracket", "widgets.input.bracket", { input.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.input.padding", {
  position = "right",
  width = settings.group_paddings,
})

local name_map = {
  ["US"] = "EN",
  ["U.S."] = "EN",
  ["USInternational-PC"] = "EN",
  ["ABC"] = "EN",
  ["British"] = "EN",
  ["Hebrew"] = "HE",
  ["Hebrew-QWERTY"] = "HE",
  ["Arabic"] = "AR",
  ["French"] = "FR",
  ["German"] = "DE",
  ["Spanish"] = "ES",
  ["Russian"] = "RU",
  ["Italian"] = "IT",
}

local function update_input()
  sbar.exec(
    "defaults read ~/Library/Preferences/com.apple.HIToolbox.plist AppleSelectedInputSources | awk -F'= ' '/KeyboardLayout Name/{gsub(/[\";]/, \"\", $2); print $2; exit}'",
    function(result)
      local layout = result:match("^%s*(.-)%s*$") or ""
      local code = name_map[layout]
      if not code then
        code = layout:sub(1, 2):upper()
      end
      if code == "" then code = "??" end
      input:set({ label = { string = code } })
    end
  )
end

input:subscribe({ "input_change", "forced", "system_woke" }, update_input)

input:subscribe("mouse.clicked", function()
  sbar.exec('osascript -e \'tell application "System Events" to key code 49 using control down\'')
end)

update_input()
