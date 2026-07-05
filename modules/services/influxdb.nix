{ config, lib, pkgs, ... }:
with lib;
let cfg = config.myModules.influxdb;
in {
  options.myModules.influxdb = {
    enable = mkEnableOption "InfluxDB 2.x time series database";
  };

  config = mkIf cfg.enable {
    services.influxdb2.enable = true;

    sops.secrets.influxdb_token = {
      sopsFile = ../../secrets/influxdb/api-token.yaml;
    };

    environment.systemPackages = [ pkgs.influxdb2-cli ];

    networking.firewall.allowedTCPPorts = [ 8086 ];
  };
}
