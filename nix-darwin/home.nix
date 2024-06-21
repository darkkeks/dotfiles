{ config, pkgs, ... }:
let
  arc = pkgs.callPackage ./arc.nix {};
  jdk = pkgs.callPackage ./jdk.nix {};
  skotty = pkgs.callPackage ./skotty.nix {};
  homeDirectory = "/Users/darkkeks";
in
{
  home.username = "darkkeks";
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
    maven
    mdcat
    pv

    iterm2
    telegram-desktop

    docker
    colima

    nerdfonts
  ] ++ [
    (pkgs.python3.withPackages (ppkgs: [
        ppkgs.requests
        ppkgs.click

        (ppkgs.callPackage ./yandex-tracker-client.nix {})
    ]))
  ] ++ [
    arc
    skotty
  ];

  home.file = {
    jdk17 = {
      target = "Library/Java/JavaVirtualMachines/yandex-jdk-17";
      source = jdk.jdk17.home;
    };
  };

  # Home Manager can also manage your environment variables through
  # 'home.sessionVariables'. These will be explicitly sourced when using a
  # shell provided by Home Manager. If you don't want to manage your shell
  # through Home Manager then you have to manually source 'hm-session-vars.sh'
  # located at either
  #
  #  ~/.nix-profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  ~/.local/state/nix/profiles/profile/etc/profile.d/hm-session-vars.sh
  #
  # or
  #
  #  /etc/profiles/per-user/darkkeks/etc/profile.d/hm-session-vars.sh
  #
  home.sessionVariables = {
    # EDITOR = "emacs";
  };

  # Make font packages discoverable by MacOS.
  fonts.fontconfig.enable = true;

  programs.home-manager.enable = true;

  programs.java = {
    enable = true;
    package = jdk.jdk17;
  };
}
