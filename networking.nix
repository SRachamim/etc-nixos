{ options, ... }:

{
  networking = {
    # Define your hostname.
    hostName = "nixos";

    interfaces.wlp0s20f3.useDHCP = true;

    # Enables wireless support via wpa_supplicant.
    networkmanager = {
      enable = true;
    };

    timeServers = options.networking.timeServers.default ++ [ "ntp.example.com" ];
  
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
  };
}
