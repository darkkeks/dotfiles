{
  pkgs,
  lib,
  inputs,
  username,
  ...
}:
{
  # List packages installed in system profile.
  environment.systemPackages = with pkgs; [
    agenix
    kmonad
  ];

  # Add shell to allowed shells (required by chsh).
  environment.shells = [
    pkgs.bashInteractive
  ];

  # Necessary for using flakes on this system.
  nix.settings.experimental-features = "nix-command flakes";

  # Create /etc/bash.bashrc that loads nix environment.
  programs.bash.enable = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Used for backwards compatibility, please read the changelog before changing.
  # $ darwin-rebuild changelog
  system.stateVersion = 4;

  # User that system settings are applied to.
  system.primaryUser = username;

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

  # Enable touch-id for sudo.
  security.pam.services.sudo_local = {
    enable = true;
    touchIdAuth = true;
  };

  security.pki.certificateFiles = [
    ./../certs/YandexInternalCA.pem
  ];

  age = {
    identityPaths = [ "/Users/darkkeks/.ssh/id_ed25519" ];
    secrets = {
      maven-settings-security.file = ./secrets/maven-settings-security.age;
      maven-settings-security.owner = username;
    };
  };

  nixpkgs.config = {
    # Whitelist packages with unfree licences.
    allowUnfreePredicate =
      pkg:
      builtins.elem (lib.getName pkg) [
        "claude-code"
        "google-chrome"
        "raycast"
        "spotify"
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
      "pg83/tap"
    ];
    brews = [
      "darkkeks/xkbswitch/libxkbswitch"
      "darkkeks/xkbswitch/xkbswitch"
      "mas"
      "pg83/tap/shitty"
      "pkgconf"
      "skopeo"
    ];
    casks = [
      "1password"
      "android-commandlinetools"
      "android-studio"
      "claude"
      "cutter"
      "db-browser-for-sqlite"
      "discord"
      "firefox"
      "garmin-express"
      "insta360-studio"
      "intellij-idea"
      "intellij-idea-ce"
      "iterm2"
      "keymapp"
      "macfuse"
      "macrorecorder"
      "mitmproxy"
      "notion"
      "nvidia-geforce-now"
      "obs"
      "pinta"
      "proxyman"
      "spotify"
      "steam"
      "t3-code"
      "telegram-desktop"
      "virtualbox"
      "visual-studio-code"
      # Renamed from plain "wireshark", which brew still lists because the old
      # Caskroom entry with the ChmodBPF installers was left behind.
      "wireshark-app"
      "yandex-disk"
      "zwift"
    ];
    masApps = {
      GarageBand = 682658836;
      Keynote = 409183694;
      Magnet = 441258766;
      Numbers = 409203825;
      Pages = 409201541;
      Tailscale = 1475387142;
      "Windows App" = 1295203466;
      Xcode = 497799835;
      iMovie = 408981434;
    };

    # These are installed by hand from a .dmg even though a cask exists. Listing
    # them here would break activation, since brew refuses to install a cask over
    # an app it does not own. Hand them over first, then move them up:
    #
    #   brew install --cask --adopt coq-platform dolphin logitech-g-hub \
    #       minecraft modrinth tunnelblick zoom
    #
    # No cask at all, so these stay manual: IDA Free, TeamViewer QS,
    # boringNotch, friture, VoceVista Video.
  };
}
