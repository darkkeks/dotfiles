# source bashrc if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi

    if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        . "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi
fi

# Managed by adv/frontend/scripts/install-internal-root-ca.sh
export NODE_EXTRA_CA_CERTS="$HOME/.ssl/certs/YandexInternalRootCA.pem"
