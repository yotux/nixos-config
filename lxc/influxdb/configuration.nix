{ config, ... }: {

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.40/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  services.influxdb2 = {
    enable = true;
  };

  networking.firewall.allowedTCPPorts = [ 8086 ];
}
