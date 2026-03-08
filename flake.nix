{
  description = "My NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    # home-manager = {
    #   url = "github:nix-community/home-manager";
    #   inputs.nixpkgs.follows = "nixpkgs";
    # };
  };

  outputs = { self, nixpkgs, ... }:
    {
      nixosConfigurations = {
        titan = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            { nixpkgs.config.allowUnfree = true; }
            ./hosts/titan/configuration.nix
            ./modules/printer.nix
            ./modules/vpn.nix
            ./modules/software.nix
            ./modules/distrobox.nix
          ];
        };
      };
    };
}
