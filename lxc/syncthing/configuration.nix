# lxc/syncthing/configuration.nix
# Syncthing for ~/file_tree. Data lives on the Proxmox mp0 volume at /srv/file_tree.
{ config, pkgs, ... }:
{
  networking.hostName = "syncthing";

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
    guiAddress = "0.0.0.0:8384";     # reachable on VLAN 40; set a GUI password immediately

    # Manage devices and folders in the GUI at first. With the defaults (true),
    # NixOS wipes anything added in the GUI whenever the service restarts.
    overrideDevices = false;
    overrideFolders = false;
  };

  networking.firewall.allowedTCPPorts = [ 8384 ];
}
