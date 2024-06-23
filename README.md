# dotfiles

## Install

### stow

1. Install stow.
1. Run `./restow.sh` or `./restow.sh macos`.

### nix-darwin

1. Change hostname to `darkkeks-mac`.
1. Copy ssh-keys.
1. Install nix.
1. Install brew.
1. Run `darwin-rebuild switch --flake dotfiles/nix-darwin`.

## Components
- `bare` &mdash; Common config files for macos/linux/wsl.
- `macos` &mdash; Macos specific config files.
- `nix-darwin` &mdash; Flake with configuration for nix-darwin with home-manager.

## New macbook
1. Apply nix-darwin and stow configurations.
1. Set iTerm2 preferences directory to `macos/.config/iterm2`.
1. System Preferences:
   - Add russian keyboard layout (Russian PC variant).
   - Change shortcuts: switching spaces, changing input source, spotlight.
1. Install kmonad dext (see instructions in kmonad repository).
1. Set bash as default shell (`chsh -s /run/current-system/sw/bin/bash`).
1. Login: IntelliJ IDEA, docker, vscode, 1password, etc.
