# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "titan";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Enable networking
  networking.networkmanager.enable = true;

  # Enable Nix flakes and new CLI
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Set your time zone.
  time.timeZone = "America/Chicago";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "en_US.UTF-8";
    LC_IDENTIFICATION = "en_US.UTF-8";
    LC_MEASUREMENT    = "en_US.UTF-8";
    LC_MONETARY       = "en_US.UTF-8";
    LC_NAME           = "en_US.UTF-8";
    LC_NUMERIC        = "en_US.UTF-8";
    LC_PAPER          = "en_US.UTF-8";
    LC_TELEPHONE      = "en_US.UTF-8";
    LC_TIME           = "en_US.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the KDE Plasma 6 Desktop Environment.
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with PipeWire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # Define a user account. Don't forget to set a password with 'passwd'.
  users.users.nmurray = {
    isNormalUser = true;
    description = "Nathan Murray";
    extraGroups = [ "networkmanager" "wheel" "lp" "podman" ];
    packages = with pkgs; [
      kdePackages.kate
      tree
      vorta
      # NOTE: 'writedisk' removed — package does not exist in nixpkgs.
      # If you want a disk imaging tool, consider: usbimager or gnome-disk-utility
    ];
  };

  # Git — configured via programs.git (do not also add to systemPackages)
  programs.git = {
    enable = true;
    config = {
      credential = {
        helper = "cache --timeout=3600";
      };
    };
  };

  # Install Firefox.
  programs.firefox.enable = true;

  # System-wide packages.
#  environment.systemPackages = with pkgs; [
#    neovim
#  ];

  # Flatpak support.
  services.flatpak.enable = true;

  # Nitrokey hardware security key udev rules.
  services.udev.packages = [ pkgs.nitrokey-udev-rules ];

  # SSH agent disabled in favour of GPG agent with SSH support.
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data (e.g. file locations, database versions)
  # were taken. It should match your original install release and should
  # NOT be bumped on upgrades — it is a historical marker, not a target.
  # See: man configuration.nix or https://nixos.org/nixos/options.html
  system.stateVersion = "24.11"; # <-- UPDATE if your install was on a different release
}

