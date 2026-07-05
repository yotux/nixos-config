{ config, pkgs, lib, ... }: {

  boot.isContainer = true;

  # Enable flakes from the start
  nix.settings.experimental-features = [ "nix-command" "flakes" ];

  # Networking - DHCP via systemd-networkd
  networking = {
    dhcpcd.enable = false;
    useDHCP = false;
    useHostResolvConf = false;
  };

  systemd.network = {
    enable = true;
    networks."50-eth0" = {
      matchConfig.Name = "eth0";
      networkConfig = {
        DHCP = "ipv4";
        IPv6AcceptRA = true;
      };
      linkConfig.RequiredForOnline = "routable";
    };
  };

  services.resolved.enable = true;

  # SSH - FIDO2 key only
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root.openssh.authorizedKeys.keys = [
    "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKq0ken4RRMwP6Vp/H6tQ3QaiDIId/JGatNg9rdjnweFAAAABHNzaDo= nitrokey-fido2"
  ];

  # Generate age key on first boot for sops-nix
  systemd.services.generate-sops-key = {
    description = "Generate age key for sops-nix";
    wantedBy = [ "multi-user.target" ];
    before = [ "sops-nix.service" ];
    serviceConfig.Type = "oneshot";
    script = ''
      if [ ! -f /var/lib/sops-nix/key.txt ]; then
        mkdir -p /var/lib/sops-nix
        ${pkgs.age}/bin/age-keygen -o /var/lib/sops-nix/key.txt
        chmod 600 /var/lib/sops-nix/key.txt
      fi
    '';
  };

  # Base packages - everything needed to self-manage
  environment.systemPackages = with pkgs; [
    # Nix management
    git

    # Secrets
    age
    sops

    # Backup
    borgbackup
    borgmatic

    # Network tools
    dig
    curl
    wget
    inetutils      # ping, traceroute, etc
    iproute2       # ip command
    nettools       # netstat, ifconfig
    tcpdump
    mtr
    nmap

    # System tools
    htop
    vim
    tmux
    rsync
    file
    tree
    jq
  ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";
}
