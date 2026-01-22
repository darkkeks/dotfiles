{
  description = "darkkeks@ nix configuration";

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

    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "agenix/systems";
    };

    yandex = {
      url = "path:/private/var/lib/arc/arcadia/junk/darkkeks/nix";
    };

    spicetify = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.systems.follows = "agenix/systems";
    };
  };

  outputs =
    inputs@{
      nix-darwin,
      nixpkgs,
      home-manager,
      agenix,
      mac-app-util,
      yandex,
      spicetify,
      ...
    }:
    let
      username = "darkkeks";
      # Build darwin flake using:
      # $ darwin-rebuild build --flake .
      configuration = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit inputs username; };
        modules = [
          ./nix-darwin/configuration.nix
          ./nix-darwin/kmonad.nix

          agenix.darwinModules.default
          mac-app-util.darwinModules.default

          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            # home-manager.useUserPackages = true;
            home-manager.users.${username} = import ./nix-darwin/home.nix;
            home-manager.extraSpecialArgs = { inherit inputs username; };
            home-manager.sharedModules = [
              mac-app-util.homeManagerModules.default
              yandex.homeManagerModules.default
              spicetify.homeManagerModules.spicetify
            ];
          }
        ];
      };
    in
    {
      formatter.aarch64-darwin = nixpkgs.legacyPackages.aarch64-darwin.nixfmt-rfc-style;

      darwinConfigurations."darkkeks-mac" = configuration;
      # Expose the package set, including overlays, for convenience.
      darwinPackages = configuration.pkgs;
    };
}
