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
