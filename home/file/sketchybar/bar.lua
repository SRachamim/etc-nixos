local colors = require("colors")

sbar.bar({
  topmost = "on",
  height = 40,
  color = colors.bar.bg,
  padding_right = 2,
  padding_left = 2,
  notch_display_height = 40,
  display = "all",
  sticky = true,
})
