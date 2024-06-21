# dotfiles

## Install

1. Install GNU stow
2. Clone repository
3. Run `./restow.sh` or `./restow.sh macos`

## Components
- `bare` &mdash; Common config files for macos/linux/wsl
- `macos` &mdash; Macos specific config files

## New macbook
1. Change hostname to `darkkeks-mac`.
1. Copy ssh-keys.
1. Install brew.
1. Install nix.
1. Run darwin-rebuild switch.
1. Apply stow configuration.
1. Set iTerm2 preferences directory to `macos/.config/iterm2`.
1. System Preferences:
  - Add russian keyboard layout (Russian PC variant)
  - Change shortcuts:
    - Switching spaces
    - Changing input source
    - Spotlight
1. Install kmonad dext.
1. Set bash as default shell (`chsh -s /run/current-system/sw/bin/bash`).
1. Log in IntelliJ IDEA.
1. Log in docker
