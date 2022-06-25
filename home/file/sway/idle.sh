swayidle \
	timeout 600 '~/.config/sway/lock.sh --grace 10 --fade-in 4' \
	timeout 800 'swaymsg "output * dpms off"' \
	resume 'swaymsg "output * dpms on"' \
	before-sleep '~/.config/sway/lock.sh'
