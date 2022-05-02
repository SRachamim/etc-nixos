{ ... }:

{
  imports = [
    ./git.nix.d/delta.nix
  ];

  home-manager.users.user.programs.git = {
    aliases = {
      br = "branch";
      ci = "commit";
      co = "checkout";
      last = "log -1 HEAD";
      st = "status";
      unstage = "reset HEAD --";
    };

    enable = true;

    extraConfig = {
      core = {
        editor = "vim";
      };

      init = {
        defaultBranch = "master";
      };

      pull = {
        rebase = false;
      };

      user = {
        email = "srachamim@gmail.com";
        name = "Sahar Rachamim (Kishu)";
      };
    };
  };
}
