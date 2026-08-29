{
  description = "My NixOS configuration";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs"; # keeps it on your pinned nixpkgs, avoids version drift
    };
    nix-caddy-withplugins = {
      url = "github:MichailiK/nix-caddy-withplugins";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };
  outputs = { self, nixpkgs, sops-nix, home-manager, nix-caddy-withplugins, ... }@inputs:
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
	  home-manager.nixosModules.home-manager
          ./hosts/titan/configuration.nix
          ./modules/borgmatic.nix
          ./modules/printer.nix
          ./modules/vpn.nix
          ./modules/software.nix
          ./modules/dev-tools.nix
          ./modules/iphone-sync.nix
          ./modules/browsers.nix
          ./modules/distrobox.nix
          ./modules/services/dnclient.nix
	  ./modules/services/vpn-proton.nix
	  {
	    home-manager.useGlobalPkgs = true;
      	    home-manager.useUserPackages = true;
      	    home-manager.users.nmurray = import ./home/nmurray/home.nix;
      	    home-manager.extraSpecialArgs = { inherit inputs; };
	  }
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
      lxc-grafana = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/grafana/configuration.nix
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
      lxc-ha-backup = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/ha-backup/configuration.nix
        ];
      };
      lxc-nostr-bunker = nixpkgs.lib.nixosSystem {
      	inherit system;
  	modules = [
    	  sops-nix.nixosModules.sops
    	  "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
    	  ./lxc/base/configuration.nix
    	  ./lxc/nostr-bunker/configuration.nix
	];
      };
    };
  };
}
