local settings = require("settings")

local icons = {
  sf_symbols = {
    plus = "􀅼",
    loading = "􀖇",
    apple = "􀣺",
    gear = "􀍟",
    cpu = "􀫥",
    clipboard = "􀉄",

    switch = {
      on = "􁏮",
      off = "􁏯",
    },
    volume = {
      _100 = "􀊩",
      _66 = "􀊧",
      _33 = "􀊥",
      _10 = "􀊡",
      _0 = "􀊣",
    },
    battery = {
      _100 = "􀛨",
      _75 = "􀺸",
      _50 = "􀺶",
      _25 = "􀛩",
      _0 = "􀛪",
      charging = "􀢋",
      warning = "􀇿",
    },
    wifi = {
      upload = "􀄨",
      download = "􀄩",
      connected = "􀙇",
      disconnected = "􀙈",
      router = "􁓤",
    },
    media = {
      back = "􀊊",
      forward = "􀊌",
      play_pause = "􀊈",
    },
    news = "􀤦",
  },

  nerdfont = {
    plus = "",
    loading = "",
    apple = "",
    gear = "",
    cpu = "",
    clipboard = "Missing Icon",

    switch = {
      on = "󱨥",
      off = "󱨦",
    },
    volume = {
      _100 = "",
      _66 = "",
      _33 = "",
      _10 = "",
      _0 = "",
    },
    battery = {
      _100 = "",
      _75 = "",
      _50 = "",
      _25 = "",
      _0 = "",
      charging = "",
      warning = "",
    },
    wifi = {
      upload = "",
      download = "",
      connected = "󰖩",
      disconnected = "󰖪",
      router = "Missing Icon",
    },
    media = {
      back = "",
      forward = "",
      play_pause = "",
    },
    news = "",
  },
}

if not (settings.icons == "NerdFont") then
  return icons.sf_symbols
else
  return icons.nerdfont
end
