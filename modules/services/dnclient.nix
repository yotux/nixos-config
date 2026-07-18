{ config, lib, pkgs, ... }:
with lib;
let
  cfg = config.myModules.dnclient;

  dnclient = pkgs.stdenv.mkDerivation {
    pname = "dnclient";
    version = "0.9.5";

    src = pkgs.fetchurl {
      url = "https://dl.defined.net/764f2278/v0.9.5/linux/amd64/dnclient";
      hash = "sha256-PVBvut7iNtNPdSGf8C5HUplJZwT8nU2s/cf1XWEikvU=";
    };

    dontUnpack = true;

    installPhase = ''
      mkdir -p $out/bin
      cp $src $out/bin/dnclient
      chmod +x $out/bin/dnclient
    '';
  };
in {
  options.myModules.dnclient = {
    enable = mkEnableOption "Defined Networking dnclient (Nebula mesh)";
  };

  config = mkIf cfg.enable {
    systemd.services.dnclient = {
      description = "Defined Networking dnclient (Nebula mesh)";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      serviceConfig = {
        Type = "simple";
        ExecStart = "${dnclient}/bin/dnclient run";
        Restart = "always";
        RestartSec = "5s";
        StateDirectory = "defined";
      };
    };

    environment.systemPackages = [ dnclient ];
  };
}
