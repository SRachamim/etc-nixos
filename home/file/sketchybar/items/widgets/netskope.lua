local colors = require("colors")
local settings = require("settings")

local NSDIAG = "/Library/Application Support/Netskope/STAgent/nsdiag"

local netskope = sbar.add("item", "widgets.netskope", {
  position = "right",
  icon = {
    string = "􀞚",
    font = {
      style = settings.font.style_map["Regular"],
      size = 16.0,
    },
    color = colors.grey,
  },
  label = { drawing = false },
  update_freq = 30,
  popup = { align = "center", height = 30 },
})

local popup_status = sbar.add("item", {
  position = "popup." .. netskope.name,
  icon = {
    string = "Status:",
    width = 80,
    align = "left",
  },
  label = {
    string = "Unknown",
    width = 170,
    align = "right",
  },
})

local popup_toggle = sbar.add("item", {
  position = "popup." .. netskope.name,
  icon = { drawing = false },
  label = {
    string = "Click to toggle",
    width = 250,
    align = "center",
    color = colors.blue,
  },
})

local netskope_bracket = sbar.add("bracket", "widgets.netskope.bracket", { netskope.name }, {
  background = { color = colors.bg1 },
})

sbar.add("item", "widgets.netskope.padding", {
  position = "right",
  width = settings.group_paddings,
})

local function update_status()
  sbar.exec('"' .. NSDIAG .. '" -n 2>&1', function(result)
    local connected = result:find("Connected") ~= nil
    netskope:set({
      icon = {
        string = connected and "􀞚" or "􀞜",
        color = connected and colors.green or colors.red,
      },
    })
    popup_status:set({
      label = { string = connected and "Connected" or "Disconnected" },
    })
    popup_toggle:set({
      label = { string = connected and "Click to disable" or "Click to enable" },
    })
  end)
end

local function set_transitioning(action_label)
  sbar.animate("elastic", 10, function()
    netskope:set({
      icon = { string = "􀖇", color = colors.orange },
    })
  end)
  popup_status:set({ label = { string = action_label } })
  popup_toggle:set({ label = { string = action_label, color = colors.orange } })
end

local function toggle_netskope(callback)
  sbar.exec('"' .. NSDIAG .. '" -n 2>&1', function(result)
    local connected = result:find("Connected") ~= nil
    set_transitioning(connected and "Disconnecting..." or "Connecting...")
    local cmd = connected and "disable" or "enable"
    sbar.exec('"' .. NSDIAG .. '" -t ' .. cmd .. ' 2>&1', function()
      sbar.delay(2, function()
        update_status()
        if callback then callback() end
      end)
    end)
  end)
end

netskope:subscribe({ "routine", "forced", "system_woke" }, update_status)

netskope:subscribe("mouse.clicked", function(env)
  if env.BUTTON == "right" then
    local should_draw = netskope:query().popup.drawing == "off"
    netskope:set({ popup = { drawing = should_draw } })
    if should_draw then update_status() end
    return
  end
  toggle_netskope()
end)

popup_toggle:subscribe("mouse.clicked", function()
  toggle_netskope(function()
    netskope:set({ popup = { drawing = false } })
  end)
end)

netskope:subscribe("mouse.exited.global", function()
  netskope:set({ popup = { drawing = false } })
end)

update_status()
