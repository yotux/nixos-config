{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.caddy;
in {
  options.myModules.caddy = {
    enable = mkEnableOption "Caddy reverse proxy";
    virtualHosts = mkOption {
      type = types.attrs;
      default = {};
      description = "Caddy virtual hosts configuration";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts = cfg.virtualHosts;
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    environment.systemPackages = with pkgs; [ jq ];
  };
}
