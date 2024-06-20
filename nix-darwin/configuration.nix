{ self, kmonad, ... }:
{ lib, pkgs, ... }:
{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment.systemPackages = [
    pkgs.vim

    pkgs._1password-gui
    pkgs.spotify
  ];

  environment.shells = [
    pkgs.bashInteractive
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;
  # nix.package = pkgs.nix;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/bash.bashrc that loads the nix-darwin environment.
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = self.rev or self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  system.defaults = {
    NSGlobalDomain.ApplePressAndHoldEnabled = false;

    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config = {
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "1password"
        "spotify"
      ];
  };

  users.users = {
    darkkeks = {
      home = "/Users/darkkeks";

      # Manually running chsh -s is still required :(
      shell = "/run/current-system/sw/bin/bash";
    };
  };

  # Manage homebrew packages.
  homebrew = {
    enable = true;
    global = {
      # Do not autoupdate when running brew commands manually.
      autoUpdate = false;
    };
    brews = [
    ];
    casks = [
      "firefox"
      "intellij-idea-ce"
      "macfuse"
      "obs"
    ];
    masApps = {
      Magnet = 441258766;
    };
  };

  # Run kmonad in background.
  launchd.agents.kmonad = {
    serviceConfig = {
      Label = "kmonad";
      ProgramArguments = [
        "${kmonad}/bin/kmonad"
        (toString ./kmonad/caps-lock-arrows.kbd)
      ];
      StandardOutPath = "/var/log/kmonad.out.log";
      StandardErrorPath = "/var/log/kmonad.err.log";
      RunAtLoad = true;
      KeepAlive = true;
    };
  };
}
