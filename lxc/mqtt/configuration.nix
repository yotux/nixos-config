{ config, ... }: {

  imports = [ ../../modules/services/mqtt.nix ];

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.50/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  myModules.mqtt.enable = true;
}
