{ ... }:

{
  home-manager.users.sahar.programs.zsh = {
    enable = true;
    enableAutosuggestions = true;
    enableSyntaxHighlighting = true;
    shellAliases = {
      condownfg = "nmcli con down sahar.rachamim@fundguard.com.fundguard.dev";
      constfg = "nmcli con | grep fundguard";
      conupfg = "nmcli con up sahar.rachamim@fundguard.com.fundguard.dev";
      conuppxl = "nmcli con up Pixel_2159";
      mux = "tmuxinator";
      pbcopy = "xclip -selection clipboard";
      pbpaste = "xclip -selection clipboard -o";
      s = "sonos";
      sa = "sonos _all_";
      sb = "sonos 'Bathroom'";
      sd = "sonos-discover";
      sl = "sonos 'Living Room'";
      ug = "nix-channel --update && nix-env --upgrade && topgrade";
    };
  };
}
