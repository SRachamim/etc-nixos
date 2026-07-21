local colors = require("colors")
local icons = require("icons")
local settings = require("settings")
local app_icons = require("helpers.app_icons")

sbar.add("event", "aerospace_workspace_change")

local spaces = {}
local space_brackets = {}

for i = 1, 9, 1 do
  local ws_name = tostring(i)

  local space = sbar.add("item", "space." .. ws_name, {
    icon = {
      font = { family = settings.font.numbers },
      string = ws_name,
      padding_left = 15,
      padding_right = 8,
      color = colors.white,
      highlight_color = colors.magenta,
    },
    label = {
      padding_right = 20,
      color = colors.grey,
      highlight_color = colors.white,
      font = "sketchybar-app-font:Regular:16.0",
      y_offset = -1,
    },
    padding_right = 1,
    padding_left = 1,
    background = {
      color = colors.bg1,
      border_width = 1,
      height = 26,
      border_color = colors.black,
    },
    drawing = false,
    click_script = "aerospace workspace " .. ws_name,
  })

  spaces[i] = space

  local space_bracket = sbar.add("bracket", { space.name }, {
    background = {
      color = colors.transparent,
      border_color = colors.bg2,
      height = 28,
      border_width = 2,
    },
  })
  space_brackets[i] = space_bracket

  sbar.add("item", "space.padding." .. ws_name, {
    width = settings.group_paddings,
    drawing = false,
  })
end

local function update_spaces()
  sbar.exec("aerospace list-workspaces --focused", function(focused_result)
    local focused = focused_result:match("^%s*(.-)%s*$") or ""

    sbar.exec("aerospace list-windows --all --format '%{workspace}|%{app-name}'", function(win_result)
      local workspace_apps = {}
      for line in win_result:gmatch("[^\r\n]+") do
        local ws, app = line:match("^(.-)|(.*)")
        if ws and app then
          if not workspace_apps[ws] then workspace_apps[ws] = {} end
          table.insert(workspace_apps[ws], app)
        end
      end

      for i = 1, 9 do
        local ws_name = tostring(i)
        local apps = workspace_apps[ws_name]
        local has_windows = apps and #apps > 0
        local is_focused = ws_name == focused
        local should_draw = has_windows or is_focused

        local icon_line = ""
        if apps then
          local seen = {}
          for _, app in ipairs(apps) do
            if not seen[app] then
              seen[app] = true
              local lookup = app_icons[app]
              icon_line = icon_line .. ((lookup == nil) and app_icons["Default"] or lookup)
            end
          end
        end
        if icon_line == "" and is_focused then
          icon_line = " —"
        end

        sbar.animate("tanh", 10, function()
          spaces[i]:set({
            drawing = should_draw,
            icon = { highlight = is_focused },
            label = { string = icon_line, highlight = is_focused },
            background = {
              border_color = is_focused and colors.black or colors.bg2,
            },
          })
          space_brackets[i]:set({
            drawing = should_draw,
            background = {
              border_color = is_focused and colors.grey or colors.bg2,
            },
          })
        end)
        sbar.set("space.padding." .. ws_name, { drawing = should_draw })
      end
    end)
  end)
end

local space_observer = sbar.add("item", {
  drawing = false,
  updates = true,
})
space_observer:subscribe("aerospace_workspace_change", update_spaces)
space_observer:subscribe("front_app_switched", update_spaces)

update_spaces()
