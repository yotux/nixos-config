{ config, pkgs, lib, ... }: {

  services.caddy = {
    enable = true;
    globalConfig = ''
      auto_https off
    '';
    virtualHosts = {
      # Add reverse proxy hosts as services come online
      # "immich.naterslab.com".extraConfig = ''
      #   reverse_proxy 10.10.40.44:2283
      # '';
    };
  };

  networking.firewall.allowedTCPPorts = [ 80 443 ];

  environment.systemPackages = with pkgs; [ jq ];
}
