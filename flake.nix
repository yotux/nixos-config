{
  description = "My NixOS configuration";

  # -----------------------------------------------------------------
  # INPUTS – pin versions here.  `nixpkgs` and `nixos` are usually the
  # same revision; you can also add `home-manager`, `cachix`, etc.
  # -----------------------------------------------------------------
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
#    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";   # or a branch/tag
#    nixos.url   = "github:NixOS/nixpkgs/nixos-23.11";
    # Optional extras
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
#    # Optional cache helper
#    cachix = {
#      url = "github:cachix/cachix";
#      inputs.nixpkgs.follows = "nixpkgs";
#    };
  };

  # -----------------------------------------------------------------
  # OUTPUTS – expose what the flake provides.
  # -----------------------------------------------------------------
#  outputs = { self, nixpkgs, nixos, home-manager, cachix, ... }:
  outputs = { self, nixpkgs, home-manager, ... }:
    let
      # Helper to get a Nixpkgs set for a given system
      pkgsFor = system: import nixpkgs { inherit system; };
    in {
      # -------------------------------------------------------------
      # NixOS host configurations
      # -------------------------------------------------------------
      nixosConfigurations = {
        titan = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            ./hosts/titan/configuration.nix               # host‑specific
            ./modules/printer.nix
            ./modules/vpn.nix
	    ./modules/software.nix
	    ./modules/distrobox.nix
            # any other shared modules …
          ];
        };

#        server = nixos.lib.nixosSystem {
#          system = "x86_64-linux";
#          modules = [
#            ./hosts/server.nix
#            ./modules/networking.nix
#            ./modules/services/nginx.nix
#            ./modules/services/postgres.nix
#          ];
#        };
      };
    };
}
