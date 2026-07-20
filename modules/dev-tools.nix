## dev-tools.nix — dev & build tooling
{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    gh
    git-crypt
    gnupg
    sops
    age
    jq
    flatpak-builder
  ];
}
