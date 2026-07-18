{ config, lib, pkgs, ... }: {
  virtualisation.docker.enable = true;

  users.users.nmurray.extraGroups = [ "docker" ];
}
