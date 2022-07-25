{ pkgs, ... }:
{
  programs = {
    adb = {
      enable = true;
    };
    light.enable = true;
    sway = {
      enable = true;
      extraPackages = with pkgs; [
        (pkgs.writeTextFile {
          destination = "/bin/configure-gtk";
          executable = true;
          name = "configure-gtk";
          text =
            let
              datadir = "${schema}/share/gsettings-schemas/${schema.name}";
              schema = pkgs.gsettings-desktop-schemas;
            in ''
              export XDG_DATA_DIRS=${datadir}:$XDG_DATA_DIRS
              gnome_schema=org.gnome.desktop.interface
              gsettings set $gnome_schema gtk-theme 'Dracula'
            '';
        })
        (pkgs.writeTextFile {
          destination = "/bin/dbus-sway-environment";
          executable = true;
          name = "dbus-sway-environment";
          text = ''
            dbus-update-activation-environment --systemd WAYLAND_DISPLAY XDG_CURRENT_DESKTOP=sway
            systemctl --user stop pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
            systemctl --user start pipewire pipewire-media-session xdg-desktop-portal xdg-desktop-portal-wlr
          '';
        })
        blueberry
        dracula-theme
        gammastep
        glib
        gnome3.adwaita-icon-theme
        grim
        mako
        mpv
        pulseaudio
        slurp
        swappy
        sway-launcher-desktop
        udiskie
        waybar
        wayland
        wl-clipboard
        wluma
        wtype
        xdg-utils
      ];
      wrapperFeatures.gtk = true;
    };
    wshowkeys = {
      enable = true;
    };
  };
}
