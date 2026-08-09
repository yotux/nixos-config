{ config, ... }: {

  imports = [ ../../modules/services/influxdb.nix
  	      ../../modules/services/telegraf.nix ];

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.40/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  myModules.influxdb.enable = true;
  myModules.telegraf.enable = true;
}
