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

  services.grafana = {
    enable = true;
    settings = {
      server = {
        http_addr = "0.0.0.0";
        http_port = 3000;
        domain = "grafana.naterslab.com";
      };
      security = {
        secret_key = "$__file{${config.sops.secrets.grafana-secret-key.path}}";
      };
    };
  };

  networking.firewall.allowedTCPPorts = [ 3000 ];
}
