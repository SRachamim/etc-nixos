{ ... }:

{
  home-manager.users.sahar.programs.ssh = {
    enable = true;
    matchBlocks = {
      "ssh.dev.azure.com" = {
        extraOptions = {
          "HostkeyAlgorithms"  = "+ssh-rsa";
          "PubkeyAcceptedAlgorithms" = "+ssh-rsa";
          "User" = "git";
        };
      };
    };
  };
}
