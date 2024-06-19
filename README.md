# dotfiles

## Install

1. Install GNU stow
2. Clone repository
3. Run `./restow.sh` or `./restow.sh macos`

## Components
- `bare` &mdash; Common config files for macos/linux/wsl
- `macos` &mdash; Macos specific config files

## New macbook

1. Change hostname to `darkkeks-osx`.
1. Copy ssh-keys.
1. Install nix.


- System Preferences
  - Add russian keyboard layout (Russian PC variant)
  - Spelling &mdash; disable autocorrent
  - DateTime &mdash; Show date
  - Disable letter variants on key hold:
    `defaults write -g ApplePressAndHoldEnabled -bool false`
  - Disable font smoothing:
    `defaults -currentHost write -g AppleFontSmoothing -int 0`
  - Keyboard &mdash; adjust Key Repeat and Delay Until Repeat
  - Keyboard &mdash; disable apropos shortcut (`Search man Page Index in Terminal`)
- Install brew, Magnet, Telegram Desktop, JDK
- Apply stow configuration
- Install brew packages from Brewfile:
  `brew bundle install --file ~/Brewfile`
- Set brew bash as default shell (add to `/etc/shells`, then `chsh -s /usr/local/bin/bash`)
- Increase system open files limits: `sudo launchctl limit maxfiles 122880 245760`
- Export + Import IntelliJ settings
- Export + Import iTerm2 settings
- Login into docker
