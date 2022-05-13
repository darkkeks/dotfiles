#!/bin/bash

ACTION="--delete bare"

case "$1" in
    "")
        ;;

    macos)
        ACTION="$ACTION --delete macos"
        ;;

    *)
        echo "Usage: $0 [macos]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION
