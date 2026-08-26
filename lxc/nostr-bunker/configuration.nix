{ config, pkgs, ... }: {
  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.71/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };
  # service-specific config here
}
