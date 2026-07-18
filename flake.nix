{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-caddy-withplugins = {
      url = "github:MichailiK/nix-caddy-withplugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, sops-nix, nix-caddy-withplugins, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {
    nixosConfigurations = {
      titan = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          sops-nix.nixosModules.sops
          ./hosts/titan/configuration.nix
          ./modules/borgmatic.nix
          ./modules/printer.nix
          ./modules/vpn.nix
          ./modules/software.nix
          ./modules/distrobox.nix
          ./modules/firefox-librewolf.nix
          ./modules/services/dnclient.nix
        ];
      };
      lxc-base = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
        ];
      };
      lxc-docker = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/docker/configuration.nix
        ];
      };
      lxc-caddy = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.overlays = [ nix-caddy-withplugins.overlays.default ]; }
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/caddy/configuration.nix
        ];
      };
      lxc-mqtt = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/mqtt/configuration.nix
        ];
      };
      lxc-influxdb = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/influxdb/configuration.nix
        ];
      };
      lxc-immich = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/immich/configuration.nix
        ];
      };
      lxc-mygarage = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/docker/configuration.nix
          ./lxc/mygarage/configuration.nix
        ];
      };
      lxc-nextcloud = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/nextcloud/configuration.nix
        ];
      };
      frigate = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          { nixpkgs.config.allowUnfree = true; }
          sops-nix.nixosModules.sops
          ./hosts/frigate/hardware-configuration.nix
          ./hosts/frigate/configuration.nix
          ./modules/services/dnclient.nix
          ./modules/services/frigate.nix
        ];
      };
    };
  };
}
