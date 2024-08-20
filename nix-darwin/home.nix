{ config, pkgs, inputs, username, ... }:
let
  arc = pkgs.callPackage ./arc.nix {};
  jdk = pkgs.callPackage ./jdk.nix {};
  skotty = pkgs.callPackage ./skotty.nix {};
  yourkit = pkgs.callPackage ./yourkit.nix {};
in
{
  home.username = username;
  home.homeDirectory = "/Users/${username}";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "23.11";

  home.packages = with pkgs; [
    curl
    coreutils
    gnugrep
    gnused
    gnutar
    openssl
    netcat-gnu
    htop
    neovim
    stow
    percona-server
    postgresql
    tree
    watch
    wget
    rsync
    ripgrep
    bat
    git
    graphviz
    jq
    mdcat
    pv
    transmission
    vlc-bin

    # Use maven with jdk8.
    (pkgs.maven.override { jdk_headless = jdk.jdk8; })

    iterm2
    telegram-desktop

    docker
    colima

    nerdfonts
  ] ++ [
    (pkgs.python3.withPackages (ppkgs: [
        ppkgs.requests
        ppkgs.click
        ppkgs.yq

        (ppkgs.callPackage ./yandex-tracker-client.nix {})
    ]))
  ] ++ [
    arc
    skotty
    yourkit
  ];

  home.sessionVariables = {
  };

  # Make font packages discoverable by MacOS.
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  # Configure JVMs.
  programs.java = {
    enable = true;
    package = jdk.jdk17;
  };
  home.file.jdk8 = {
    target = "Library/Java/JavaVirtualMachines/yandex-jdk-8";
    source = jdk.jdk8.home;
  };
  home.file.jdk11 = {
    target = "Library/Java/JavaVirtualMachines/yandex-jdk-11";
    source = jdk.jdk11.home;
  };
  home.file.jdk15 = {
    target = "Library/Java/JavaVirtualMachines/yandex-jdk-15";
    source = jdk.jdk15.home;
  };
  home.file.jdk17 = {
    target = "Library/Java/JavaVirtualMachines/yandex-jdk-17";
    source = jdk.jdk17.home;
  };

  # Configure maven.
  home.file.".m2/settings.xml".source = ./m2/settings.xml;
  home.file.".m2/settings-security.xml" = {
    source = config.lib.file.mkOutOfStoreSymlink /run/agenix/maven-settings-security;
  };
}
