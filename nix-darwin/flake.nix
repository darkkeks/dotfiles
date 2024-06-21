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

    kmonad = {
      url = "git+https://github.com/kmonad/kmonad?submodules=1&dir=nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, ... }:
  let
    kmonad = inputs.kmonad.packages."aarch64-darwin".default;
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#darkkeks-mac
    darwinConfigurations."darkkeks-mac" = nix-darwin.lib.darwinSystem {
      specialArgs = {
        inherit self inputs;
      };
      modules = [
        ./configuration.nix

        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          home-manager.users.darkkeks = import ./home.nix;
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."darkkeks-mac".pkgs;
  };
}
