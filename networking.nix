{ options, ... }:
{
  networking = {
    hostName = "SaharRachamim";
    interfaces.wlp0s20f3.useDHCP = true;
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
    useDHCP = false;
  };
}
