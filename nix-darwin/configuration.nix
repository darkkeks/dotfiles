{ pkgs, lib, inputs, username, ... }:
{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    spotify
    vscode
    agenix
    kmonad
  ];

  # Add shell to allowed shells (required by chsh).
  environment.shells = [
    pkgs.bashInteractive
  ];

  # Auto upgrade nix package and the daemon service.
  services.nix-daemon.enable = true;

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/bash.bashrc that loads nix environment.
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;
    
  # Some System Settings that can be configured automatically.
  system.defaults = {
    NSGlobalDomain.ApplePressAndHoldEnabled = false;

    NSGlobalDomain.InitialKeyRepeat = 15;
    NSGlobalDomain.KeyRepeat = 2;
  };

  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";

  nixpkgs.overlays = [
    # Add agenix package to pkgs.
    inputs.agenix.overlays.default
    # Add kmonad package to pkgs.
    inputs.kmonad.overlays.default
  ];

  # Configure kmonad.
  services.kmonad = {
    enable = true;
    config = ./kmonad/caps-lock-arrows.kbd;
  };

  age = {
    identityPaths = [ "/Users/darkkeks/.ssh/id_ed25519" ];
    secrets = {
      maven-settings-security.file = ./secrets/maven-settings-security.age;
      maven-settings-security.owner = username;
    };
  };

  nixpkgs.config = {
    # Whitelist packages with unfree licences.
    allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
      "spotify"
      "vscode"
    ];
  };

  users.users = {
    "${username}" = {
      home = "/Users/${username}";

      # Set user shell to the one managed by nix.
      # Manually running chsh -s is still required :(
      shell = pkgs.bashInteractive;
    };
  };

  # Manage homebrew packages.
  homebrew = {
    enable = true;
    global = {
      # Do not autoupdate when running brew commands manually.
      autoUpdate = false;
    };
    taps = [
      "darkkeks/xkbswitch"
    ];
    brews = [
      "darkkeks/xkbswitch/libxkbswitch"
      "darkkeks/xkbswitch/xkbswitch"
    ];
    casks = [
      "1password"
      "discord"
      "firefox"
      "google-chrome"
      "intellij-idea-ce"
      "keycastr"
      "logitech-g-hub"
      "macfuse"
      "notion"
      "obs"
      "pinta"
      "wireshark"
    ];
    masApps = {
      Magnet = 441258766;
    };
  };
}
