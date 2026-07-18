{ config, lib, pkgs, ... }: {
  imports = [
    ../base/configuration.nix
    ../../profiles/docker-host.nix
  ];

  networking.hostName = "frigate";

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.efi.efiSysMountPoint = "/boot/efi";
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # Recordings drive - disabled for now, SMART data showed 9040 pending
  # sectors + 784 reallocated sectors (2026-07-18 check) = failing disk.
  # Needs replacement before this gets re-enabled. Recordings currently
  # land on root NVMe instead, with tighter retention (motion-only,
  # no continuous mode) to keep that sustainable in the meantime.
  # fileSystems."/mnt/data" = {
  #   device = "/dev/disk/by-uuid/0c9f5ce8-71cf-43f8-9316-b523b31aaccd";
  #   fsType = "ext4";
  #   options = [ "defaults" "nofail" ];
  # };

  networking.interfaces.eno1.ipv4.addresses = [{
    address = "10.10.10.30";
    prefixLength = 24;
  }];
  networking.defaultGateway = "10.10.10.1";
  networking.nameservers = [ "10.10.10.1" "1.1.1.1" ];

  networking.interfaces.enp2s0.ipv4.addresses = [{
    address = "10.1.70.30";
    prefixLength = 24;
  }];

  networking.firewall.allowedTCPPorts = [ 22 80 443 5000 8554 8555 8971 ];

  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-vaapi-driver
      libva-vdpau-driver
      libvdpau-va-gl
      intel-compute-runtime
    ];
  };

  users.users.nmurray = {
    isNormalUser = true;
    extraGroups = [ "wheel" "render" "video" ];
    packages = with pkgs; [ tree ];
  };

  environment.systemPackages = with pkgs; [
    nano neovim smartmontools
  ];

  myModules.dnclient.enable = true;
  myModules.frigate.enable = true;

  system.stateVersion = "25.11";
}
