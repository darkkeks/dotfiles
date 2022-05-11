# source bashrc if running bash
if [ -n "$BASH_VERSION" ]; then
    if [ -f "$HOME/.bashrc" ]; then
        . "$HOME/.bashrc"
    fi
fi

# add private bin to PATH if exists
if [ -d "$HOME/bin" ]; then
    PATH="$HOME/bin:$PATH"
fi
