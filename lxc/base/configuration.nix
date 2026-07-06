{ config, pkgs, lib, ... }: {

  boot.isContainer = true;

  nix.settings.experimental-features = [ "nix-command" "flakes" ];

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

  users.users.nmurray = {
    isNormalUser = true;
    extraGroups = [ "wheel" ];
    hashedPassword = "$6$mjnmEVAWX6mjo0IX$qqixf1J439m1jyw5h0T32VvubQ9S42chEb6SE9W.AHA8mS3F2RWpS4sOs4n.VW0v9OdQH6GTx3OmV3dysMtV.1";
    openssh.authorizedKeys.keys = [
      "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAIKq0ken4RRMwP6Vp/H6tQ3QaiDIId/JGatNg9rdjnweFAAAABHNzaDo= nitrokey-fido2"
    ];
  };

  # Point sops-nix at the age key generated below
  sops.age.keyFile = "/var/lib/sops-nix/key.txt";

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

  environment.systemPackages = with pkgs; [
    git age sops borgbackup borgmatic
    dig curl wget inetutils iproute2 nettools tcpdump mtr nmap
    htop vim tmux rsync file tree jq
  ];

  time.timeZone = "America/Chicago";
  i18n.defaultLocale = "en_US.UTF-8";
  system.stateVersion = "26.05";
}
