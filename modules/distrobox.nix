# modules/distrobox.nix
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    distrobox
    podman
    xhost
  ];

  virtualisation.podman = {
    enable = true;
    dockerCompat = true;
  };

  # services.xserver.enable — already set in configuration.nix, removed here
  # users.users.nmurray.extraGroups — "podman" already set in configuration.nix, removed here
}
