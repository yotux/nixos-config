# /etc/nixos/configuration.nix
{ config, pkgs, ... }:

{
  #################################################################
  # 1️⃣ Packages we need
  #################################################################
  environment.systemPackages = with pkgs; [
    distrobox          # the DistroBox CLI
    podman             # OCI container runtime (root‑less, works great on NixOS)
    xhost         # tiny utility to grant X‑access to containers
    # optional: extra GUI utilities you might want inside the box
    # e.g., gnome3.gnome-terminal, firefox, gimp, libreoffice
  ];

  #################################################################
  # 2️⃣ Enable the container daemon (Podman)
  #################################################################
  virtualisation.podman = {
    enable = true;               # starts the podman socket
    # Enable root‑less networking (default). If you need host networking,
    # you can set `extraOptions = "--network=host";` per‑container later.
  };

  #################################################################
  # 3️⃣ Allow your user to talk to the podman socket
  #################################################################
  # users.users.E>.extraGroups = [ "podman" ];   # replace with your login name

  #################################################################
  # 4️⃣ (Optional) Enable Wayland socket exposure globally
  #    This makes /run/user/$UID/wayland-0 visible to containers.
  #################################################################
  # If you use Wayland (most modern GNOME/KDE sessions), add:
   services.xserver.enable = true;   # already true for most desktop configs
   environment.sessionVariables.WAYLAND_DISPLAY = "wayland-0";

  #################################################################
  # 5️⃣ Rebuild the system
  #################################################################
  # After saving the file:
  #   sudo nixos-rebuild switch
}
