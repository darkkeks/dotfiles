{
  config,
  pkgs,
  username,
  inputs,
  ...
}:
let
  jdk = pkgs.callPackage ./jdk.nix { };
  yourkit = pkgs.callPackage ./yourkit.nix { };

  homeDirectory = "/Users/${username}";

  # TODO(darkkeks): https://github.com/nix-community/home-manager/issues/2085 :(
  dotfilesPath = "./dotfiles";
  dotfilesSymlink = path: config.lib.file.mkOutOfStoreSymlink (homeDirectory + "/" + dotfilesPath + "/" + path);
in
{
  home.username = username;
  home.homeDirectory = homeDirectory;

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    coreutils
    gnugrep
    gnused
    gnutar
    openssl
    netcat-gnu
    htop
    neovim
    stow
    postgresql
    tree
    watch
    wget
    rsync
    ripgrep
    bat
    graphviz
    jq
    mdcat
    pv
    transmission_4
    vlc-bin
    pyright
    pyenv
    rustup
    clang
    cmake
    ncdu
    uv
    nh

    # Use maven with jdk8.
    (pkgs.maven.override { jdk_headless = jdk.jdk8; })

    keycastr
    google-chrome
    raycast

    docker
    colima

    nerd-fonts.jetbrains-mono

    nodejs
    bun

    (pkgs.python3.withPackages (ppkgs: [
      ppkgs.requests
      ppkgs.click
      ppkgs.yq

      (ppkgs.callPackage ./yandex-tracker-client.nix { })
    ]))

    yourkit
  ];

  home.sessionVariables = { };

  # Make font packages discoverable by MacOS.
  fonts.fontconfig.enable = true;

  # Install and configure configuration.
  programs.git = {
    enable = true;
    userName = "darkkeks";
    userEmail = "v.boben@yandex.ru";
  };

  # Install and configure tmux.
  programs.tmux = {
    enable = true;
    # Start enumerating windows with 1.
    baseIndex = 1;
    # Non-zero escape-time makes escape input delayed (for example in vim).
    escapeTime = 0;
    # Enable mouse support by default.
    mouse = true;
    # Increase history limit.
    historyLimit = 10000;
    extraConfig = ''
      # Highlight current window in red
      set-option -gw window-status-current-style bg=red
    '';
  };

  programs.spicetify = {
    enable = true;
    theme = inputs.spicetify.legacyPackages.${pkgs.stdenv.system}.themes.defaultDynamic;
  };

  # Configure bash.
  home.file.".bashrc".source = dotfilesSymlink "./bare/.bashrc";
  home.file.".profile".source = dotfilesSymlink "./bare/.profile";
  home.file.".bashrc_local".source = dotfilesSymlink "./macos/.bashrc_local";

  # Configure iTerm2.
  home.file.".config/iterm2/com.googlecode.iterm2.plist".source =
    dotfilesSymlink "./macos/.config/iterm2/com.googlecode.iterm2.plist";

  # Configure ssh.
  home.file.".ssh/config".source = dotfilesSymlink "./macos/.ssh/config";

  # Configure (neo)vim.
  home.file.".config/nvim/init.lua".source = dotfilesSymlink "./bare/.config/nvim/init.lua";
  home.file.".config/nvim/snippets".source = dotfilesSymlink "./bare/.config/nvim/snippets";

  # Configure JVMs.
  programs.java = {
    enable = true;
    package = jdk.jdk21;
  };

  home.file."Library/Java/JavaVirtualMachines/yandex-jdk-8".source = jdk.jdk8.home;
  home.file."Library/Java/JavaVirtualMachines/yandex-jdk-11".source = jdk.jdk11.home;
  home.file."Library/Java/JavaVirtualMachines/yandex-jdk-15".source = jdk.jdk15.home;
  home.file."Library/Java/JavaVirtualMachines/yandex-jdk-17".source = jdk.jdk17.home;
  home.file."Library/Java/JavaVirtualMachines/yandex-jdk-21".source = jdk.jdk21.home;

  # Configure maven.
  home.file.".m2/settings.xml".source = ./m2/settings.xml;
  home.file.".m2/settings-security.xml" = {
    source = config.lib.file.mkOutOfStoreSymlink /run/agenix/maven-settings-security;
  };

  # Forbid adding hooks to arcconfig.
  home.file.".arcconfig".source = config.lib.file.mkOutOfStoreSymlink /dev/null;
}
