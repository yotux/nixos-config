{ config, lib, pkgs, ... }:
{
  imports = [ ./hardware-configuration.nix ];

  # ─── Boot ───
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;
  boot.loader.systemd-boot.configurationLimit = 10; # keep /boot from filling up
  boot.kernel.sysctl."kernel.sysrq" = 1;
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # ─── File system (SSD + btrfs) ───
  # Options merge with the subvol entries from hardware-configuration.nix.
  # discard=async issues TRIM in the background as blocks are freed.
  fileSystems."/".options     = [ "noatime" "compress=zstd:1" "discard=async" ];
  fileSystems."/home".options = [ "noatime" "compress=zstd:1" "discard=async" ];
  fileSystems."/nix".options  = [ "noatime" "compress=zstd:1" "discard=async" ];
  fileSystems."/var/log".options = [ "noatime" "compress=zstd:1" "discard=async" ];
  # Weekly TRIM as a backstop in case async discard misses anything.
  services.fstrim.enable = true;

  # ─── Swap and hibernate ───
  # 13 GiB swapfile on its own btrfs subvolume (/swap inside the root subvolume).
  # RAM is 12 GiB, so the swapfile can hold a full hibernate image.
  swapDevices = [ { device = "/swap/swapfile"; } ];
  # The resume device is the btrfs root filesystem, not the swapfile itself.
  boot.resumeDevice = "/dev/disk/by-uuid/890312f8-f0d1-4b94-ad65-c9e433885beb";
  boot.kernelParams = [ "resume_offset=533760" ];
  
  time.hardwareClockInLocalTime = true;
 

  # Lid close: suspend, then hibernate after the delay so the battery can't drain.
  # On AC power, just suspend.
  services.logind.settings.Login = {
    HandleLidSwitch = "suspend-then-hibernate";
    HandleLidSwitchExternalPower = "suspend";
  };
  systemd.sleep.settings.Sleep.HibernateDelaySec = "30min";

  # Low battery: hibernate as a safety net under PowerDevil's settings.
  services.upower = {
    enable = true;
    percentageLow = 15;
    percentageCritical = 5;
    percentageAction = 3;
    criticalPowerAction = "Hibernate";
  };

  # ─── Networking ───
  networking.hostName = "rover"; # replace with the new machine's name
  networking.networkmanager.enable = true;
  services.resolved = {
    enable = true;
    settings.Resolve.FallbackDNS = [ "9.9.9.9" "1.1.1.1" ];
  };

  # ─── Locale and time ───
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

  # ─── Desktop: KDE Plasma 6 ───
  services.xserver.enable = true;
  services.displayManager.sddm.enable = true;
  services.desktopManager.plasma6.enable = true;
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # ─── Printing and scanning ───
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

  # ─── Nix ───
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 10d";
  };
  nix.optimise.automatic = true; # dedupes identical store files

  # ─── Containers ───
  # virtualisation.podman.enable = true;

  # ─── User ───
  users.users.nmurray = {
    isNormalUser = true;
    description = "Nathan Murray";
    shell = pkgs.zsh;
    extraGroups = [ "networkmanager" "wheel" "lp" "scanner" ];
    packages = with pkgs; [
      kdePackages.kate
      tree
      vorta
      borgbackup
    ];
  };

  # ─── Programs and services ───
  programs.zsh.enable = true;
  programs.git.enable = true;
  programs.firefox.enable = true;
  services.flatpak.enable = true;

  # Nitrokey udev rules; SSH handled by GPG agent.
  services.udev.packages = [ pkgs.nitrokey-udev-rules ];
  programs.ssh.startAgent = false;
  programs.gnupg.agent = {
    enable = true;
    enableSSHSupport = true;
  };

  # Keep this matching the release this install was made from.
  system.stateVersion = "26.05";
}

