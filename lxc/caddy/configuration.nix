{ config, pkgs, lib, ... }: {

  systemd.network.networks."50-eth0" = lib.mkForce {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.101/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts."10.10.40.101:80" = {
      extraConfig = ''
        respond "Caddy is working on hive"
      '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [ jq ];
}
