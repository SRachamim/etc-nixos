{ ... }:

{
  imports = [
    ./programs.nix.d/atuin.nix
    ./programs.nix.d/bat.nix
    ./programs.nix.d/direnv.nix
    ./programs.nix.d/fzf.nix
    ./programs.nix.d/git.nix
    ./programs.nix.d/kitty.nix
    ./programs.nix.d/lsd.nix
    ./programs.nix.d/neovim.nix
    ./programs.nix.d/rofi.nix
    ./programs.nix.d/ssh.nix
    ./programs.nix.d/starship.nix
    ./programs.nix.d/tmux.nix
    ./programs.nix.d/topgrade.nix
    ./programs.nix.d/xmobar.nix
    ./programs.nix.d/zsh.nix
  ];

  home-manager.users.sahar.programs = {
    home-manager = {
      enable = true;
    };
  };
}
