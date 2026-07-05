{ config, pkgs, lib, ... }: {

  # Static IP for caddy - override base DHCP
  systemd.network.networks."50-eth0" = lib.mkForce {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.101/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  # Caddy reverse proxy
  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      # Add reverse proxy hosts as services come online
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [ jq ];
}
