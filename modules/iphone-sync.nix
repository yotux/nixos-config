## iphone-sync.nix — iPhone connectivity via libimobiledevice/usbmuxd
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    libimobiledevice
    usbmuxd
    ifuse
    libplist
    usbutils
  ];

  services.usbmuxd.enable = true;
}
