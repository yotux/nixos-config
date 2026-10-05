# lxc/syncthing/configuration.nix
# Syncthing for ~/file_tree. Data lives on the Proxmox mp0 volume at /srv/file_tree.
# Daily borgmatic backup of the synced folders to BorgBase (secrets via sops-nix).
{ config, pkgs, lib, ... }:
{

  systemd.network.networks."50-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      Address = "10.10.40.22/24";
      Gateway = "10.10.40.1";
      DNS = "10.10.40.1";
    };
    linkConfig.RequiredForOnline = "routable";
  };

  services.syncthing = {
    enable = true;
    # Default user/group "syncthing" (NixOS gives it a fixed uid).
    openDefaultPorts = true;         # 22000 tcp/udp (sync), 21027 udp (discovery)
    guiAddress = "0.0.0.0:8384";     # reachable on VLAN 40

    # Manage devices and folders in the GUI at first. With the defaults (true),
    # NixOS wipes anything added in the GUI whenever the service restarts.
    overrideDevices = false;
    overrideFolders = false;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];

  # --- Secrets (decrypted at activation by sops-nix using /var/lib/sops-nix/key.txt) ---
  sops.secrets."borgbase-ssh-key" = {
    sopsFile = ../../secrets/syncthing/borgbase-ssh-key.yaml;
    mode = "0400";
  };
  sops.secrets."borg-passphrase" = {
    sopsFile = ../../secrets/syncthing/borg-passphrase.yaml;
    mode = "0400";
  };

  # --- Backup: daily borgmatic run to the BorgBase repo ---
  services.borgmatic = {
    enable = true;   # installs a systemd service + daily timer
    settings = {
      source_directories = [
        "/srv/file_tree/file_tree"
        "/srv/file_tree/ente-auth"
      ];
      exclude_patterns = [ "*/.stfolder" ];

      repositories = [
        {
          path = "ssh://p1qfatct@p1qfatct.repo.borgbase.com/./repo";
          label = "borgbase-syncthing";
        }
      ];

      encryption_passcommand = "${pkgs.coreutils}/bin/cat ${config.sops.secrets."borg-passphrase".path}";
      ssh_command = "ssh -i ${config.sops.secrets."borgbase-ssh-key".path} -o StrictHostKeyChecking=accept-new";

      keep_daily = 7;
      keep_weekly = 4;
      keep_monthly = 6;

      checks = [
        { name = "repository"; frequency = "2 weeks"; }
      ];
    };
  };
}
