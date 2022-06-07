{ pkgs, ... }:
{
  programs = {
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
        bemenu
        dracula-theme
        glib
        gnome3.adwaita-icon-theme
        grim
        mako
        pulseaudio
        slurp
        swayidle
        swaylock-effects
        wayland
        wl-clipboard
      ];
      wrapperFeatures.gtk = true;
    };
  };
}
