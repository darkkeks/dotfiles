#!/bin/bash

ACTION="--restow bare"

case "$1" in
    "")
        ;;

    macos)
        ACTION="$ACTION --restow macos"
        ;;

    *)
        echo "Usage: $0 [macos]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION

