return {
  black = 0xff11111b,
  white = 0xffcdd6f4,
  red = 0xfff38ba8,
  green = 0xffa6e3a1,
  blue = 0xff89b4fa,
  yellow = 0xfff9e2af,
  orange = 0xfffab387,
  magenta = 0xffcba6f7,
  grey = 0xff6c7086,
  transparent = 0x00000000,

  bar = {
    bg = 0xff1e1e2e,
    border = 0xff1e1e2e,
  },
  popup = {
    bg = 0xe01e1e2e,
    border = 0xff6c7086,
  },
  bg1 = 0xff1e1e2e,
  bg2 = 0xff313244,

  with_alpha = function(color, alpha)
    if alpha > 1.0 or alpha < 0.0 then return color end
    return (color & 0x00ffffff) | (math.floor(alpha * 255.0) << 24)
  end,
}
