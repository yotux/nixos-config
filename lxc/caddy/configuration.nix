{ config, ... }: {

  imports = [ ../../modules/services/caddy.nix ];

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.101/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  myModules.caddy = {
    enable = true;
    virtualHosts."10.10.40.101:80".extraConfig = ''
      respond "Caddy is working on hive"
    '';
  };
}
