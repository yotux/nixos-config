# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running 'nixos-help').
{ config, pkgs, ... }:
{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # ─── Boot ───
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep /boot from filling up
  boot.kernel.sysctl."kernel.sysrq" = 1;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ─── File System ───
  fileSystems."/".options     = [ "noatime" "compress=zstd:1" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd:1" ];
  services.fstrim.enable = true;   # weekly TRIM via systemd timer

  # ─── Hibernate ───
  # Swap partition (same UUID as swapDevices in hardware-configuration.nix).
  # Do NOT enable randomEncryption on that swap device; it breaks resume.
  boot.resumeDevice = "/dev/disk/by-uuid/5d353b82-644b-4640-8f57-7caf7cce7f7f";

  # Lid close: suspend first, then hibernate after the delay so the battery
  # can never drain to zero while asleep. On AC power just suspend.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  # Low battery while running: hibernate. Plasma's PowerDevil (System Settings
  # -> Power Management) also has a critical-battery action; set it to
  # Hibernate there too. This is the safety net underneath it.
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # ─── Networking ───
  networking.hostName = "titan";
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.
  networking.networkmanager.enable = true;

  services.resolved = {
    enable = true;
    settings.Resolve = {
      FallbackDNS = [ "9.9.9.9" "1.1.1.1" ];
    };
  };

  # ─── sops secrets ───
  sops = {
    defaultSopsFile = ../../secrets/titan/borg.yaml;
    # titan has no SSH host key (workstation, no sshd) — use the dedicated age keyfile.
    # The key lives under /home (a separate btrfs subvolume that is not mounted
    # during early activation), so run secret installation as a systemd service
    # that starts after local filesystems are mounted.
    age.keyFile = "/home/nmurray/.config/sops/age/keys.txt";
    useSystemdActivation = true;
  };

  # ─── Nix ───
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 10d";
  };
  nix.optimise.automatic = true;   # dedupes identical store files

  # ─── Locale / time ───
  time.timeZone = "America/Chicago";

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

  # ─── Desktop ───
  services.xserver.enable = true;

  # KDE Plasma 6
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;

  # Keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ─── Printing / scanning ───
  services.printing.enable = true;
  hardware.sane.enable = true;

  # ─── Sound (PipeWire) ───
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  # ─── Containers ───
  # Enabling podman also creates the "podman" group used below.
  virtualisation.podman.enable = true;

  # ─── User ───
  # Don't forget to set a password with 'passwd'.
  users.users.nmurray = {
    isNormalUser = true;
    description = "Nathan Murray";
    shell = pkgs.zsh; # <--  Testing ZSH
    # "plugdev" removed: not defined on NixOS, and nitrokey-udev-rules
    # uses uaccess tagging instead of that group.
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" "podman" ];
    packages = with pkgs; [
      kdePackages.kate
      tree
      vorta
      borgbackup
      # NOTE: 'writedisk' removed — package does not exist in nixpkgs.
      # If you want a disk imaging tool, consider: usbimager or gnome-disk-utility
    ];
  };

  programs.zsh.enable = true; # <-- Testing 2nd entry

  # ─── Programs ───
  # Git — configured via programs.git (do not also add to systemPackages)
  programs.git.enable = true;

  programs.firefox.enable = true;

  # System-wide packages.
  # environment.systemPackages = with pkgs; [
  #   neovim
  # ];

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

  # ─── Firewall ───
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # networking.firewall.enable = false;

  # ─── Custom modules ───
  myModules.dnclient.enable = true;

  # Historical marker for stateful data defaults. Must match the release this
  # system was first installed from (26.11). Do NOT bump on upgrades.
  system.stateVersion = "26.11";
}
