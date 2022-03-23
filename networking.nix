{ options, ... }:

{
  networking = {
    # Define your hostname.
    hostName = "host";

    interfaces.wlp0s20f3.useDHCP = true;

    # Enables wireless support via wpa_supplicant.
    networkmanager = {
      connectionConfig = {
        "connection.stable-id" = "\${CONNECTION}/\${BOOT}";
      };
      enable = true;
      ethernet = {
        macAddress = "random";
      };
      wifi = {
        macAddress = "random";
        scanRandMacAddress = true;
      };
    };

    timeServers = options.networking.timeServers.default ++ [ "ntp.example.com" ];
  
    # The global useDHCP flag is deprecated, therefore explicitly set to false here.
    # Per-interface useDHCP will be mandatory in the future, so this generated config
    # replicates the default behaviour.
    useDHCP = false;
  };
}
