## software.nix
{ config, pkgs, ... }:

{

  environment.systemPackages = with pkgs; [
  # package name
  vlc
  nmap
  recoll
  neovim
  ghostty
  wget
  tealdeer
  xclip
  bat
  gh
  git-crypt
  gnupg
  pinentry-qt   # Use pinentry-qt on KDE for native GTK/Qt passphrase dialogs
  gparted
  writedisk
  ];
}
