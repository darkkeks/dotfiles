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

  outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager, kmonad }:
  let
    kmonadPackage = kmonad.packages."aarch64-darwin".default;
    configuration = import ./configuration.nix {
      inherit self;
      kmonad = kmonadPackage;
    };
  in
  {
    # Build darwin flake using:
    # $ darwin-rebuild build --flake .#darkkeks-mac
    darwinConfigurations."darkkeks-mac" = nix-darwin.lib.darwinSystem {
      modules = [
        configuration
        home-manager.darwinModules.home-manager {
          home-manager.useGlobalPkgs = true;
          # home-manager.useUserPackages = true;
          home-manager.users.darkkeks = import ./home.nix;
          home-manager.extraSpecialArgs = {
            kmonad = kmonadPackage;
          };
        }
      ];
    };

    # Expose the package set, including overlays, for convenience.
    darwinPackages = self.darwinConfigurations."darkkeks-mac".pkgs;
  };
}
