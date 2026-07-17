{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.caddy;
in {
  options.myModules.caddy = {
    enable = mkEnableOption "Caddy reverse proxy";
    package = mkOption {
      type = types.package;
      default = pkgs.caddy;
      description = "Caddy package to use";
    };
    virtualHosts = mkOption {
      type = types.attrs;
      default = {};
      description = "Caddy virtual hosts configuration";
    };
  };
  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = cfg.package;
      globalConfig = ''
        auto_https off
      '';
      virtualHosts = cfg.virtualHosts;
    };
    networking.firewall.allowedTCPPorts = [ 80 443 ];
    environment.systemPackages = with pkgs; [ jq ];
  };
}
