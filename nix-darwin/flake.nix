{
  description = "darkkeks@ macos configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    agenix = {
      url = "github:ryantm/agenix";
      inputs.darwin.follows = "nix-darwin";
      inputs.home-manager.follows = "home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ nix-darwin, nixpkgs, home-manager, agenix, ... }:
  let
    username = "darkkeks";
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .
    configuration = nix-darwin.lib.darwinSystem {
      specialArgs = { inherit inputs username; };
      modules = [
        ./configuration.nix
        ./kmonad.nix

        agenix.darwinModules.default

        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          home-manager.users.${username} = import ./home.nix;
          home-manager.extraSpecialArgs = { inherit inputs username; };
        }
      ];
    };
  in
  {
    darwinConfigurations."darkkeks-mac" = configuration;
    # Expose the package set, including overlays, for convenience.
    darwinPackages = configuration.pkgs;
  };
}
