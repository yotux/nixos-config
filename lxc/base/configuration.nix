{ config, pkgs, lib, ... }: {

  boot.isContainer = true;

  # Networking - DHCP by default
  # For static IP, comment out DHCP section and uncomment static section
  networking.useDHCP = lib.mkForce false;

  systemd.network.enable = true;
  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    networkConfig = {
      ## DHCP (default) - comment out for static IP
      DHCP = "yes";

      ## Static IP - uncomment and set values per container
      ## Address = "10.10.40.101/24";
      ## Gateway = "10.10.40.1";
      ## DNS = "10.10.40.1";
    };
  };

  # SSH - key only, no passwords ever
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  # Your FIDO2 SSH public key
  users.users.root = {
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKq0ken4RRMwP6Vp/H6tQ3QaiDIId/JGatNg9rdjnweFAAAABHNzaDo= nitrokey-fido2"
    ];
  };

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
        echo "Age key generated"
      fi
    '';
  };

  # Base packages every LXC gets
  environment.systemPackages = with pkgs; [
    borgbackup
    borgmatic
    age
    sops
    curl
    wget
    git
    htop
    vim
    tmux
    rsync
  ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";
}
