{ config, pkgs, ... }: {
  imports = [ ../../modules/services/caddy.nix ../../modules/services/dnclient.nix ];
  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.10/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };
  myModules.dnclient.enable = true;
  myModules.caddy = {
    enable = true;
    virtualHosts = {
      "10.10.40.10:80".extraConfig = ''
        respond "Caddy is working on hive"
      '';
      "mygarage.naterslab.com".extraConfig = ''
        reverse_proxy 10.10.40.60:8686
        tls internal
      '';
      "cloud.naterslab.com".extraConfig = ''
        reverse_proxy 10.10.40.70:80
        tls internal
      '';
    };
  };
}
