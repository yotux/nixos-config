{ config, pkgs, ... }: {

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.41/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  sops.secrets.grafana-secret-key = {
    sopsFile = ../../secrets/grafana/secret-key.yaml;
    owner = "grafana";
  };

  sops.secrets.influxdb-readonly-token = {
    key = "influxdb-token-env";
    sopsFile = ../../secrets/grafana/influxdb-token.yaml;
    owner = "grafana";
  };

  systemd.services.grafana.serviceConfig.EnvironmentFile = config.sops.secrets.influxdb-readonly-token.path;

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "grafana.naterslab.com";
        root_url = "https://grafana.naterslab.com";
      };
      security = {
        secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
      };
    };
    provision = {
      enable = true;
      datasources.settings.datasources = [
        {
          name = "InfluxDB - iotawatt";
          type = "influxdb";
          access = "proxy";
          url = "http://10.10.40.40:8086";
          jsonData = {
            version = "Flux";
            organization = "proxmox";
            defaultBucket = "iotawatt";
          };
          secureJsonData = {
            token = "$INFLUXDB_TOKEN";
          };
        }
      ];
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
