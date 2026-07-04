{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, sops-nix, ... }:
  let
    system = "x86_64-linux";
    pkgs = nixpkgs.legacyPackages.${system};
  in {

    # Existing NixOS hosts
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
        ];
      };

      # LXC base template
      lxc-base = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
        ];
      };

      # LXC docker template
      lxc-docker = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          sops-nix.nixosModules.sops
          "${nixpkgs}/nixos/modules/virtualisation/proxmox-lxc.nix"
          ./lxc/base/configuration.nix
          ./lxc/docker/configuration.nix
        ];
      };

    };

  };
}
