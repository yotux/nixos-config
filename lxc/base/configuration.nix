{ config, pkgs, lib, ... }: {

  boot.isContainer = true;

  # Override proxmox-lxc default
  networking.useDHCP = lib.mkForce true;

  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "prohibit-password";
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

  users.users.root = {
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDEq2kk1bjIupUHaypnRcVUaMNw+0/Vn9/9kF7zojTen openpgp:0x8C313364"
    ];
  };

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
