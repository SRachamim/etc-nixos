{ ... }:

{
  hardware = {
    bluetooth.enable = true;
    nvidia.prime = {
      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };
    pulseaudio.enable = true;
  };

}
