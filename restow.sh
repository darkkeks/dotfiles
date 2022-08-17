#!/bin/bash

ACTION="--restow bare"

case "$1" in
    "")
        ;;

    macos)
        ACTION="$ACTION --restow macos"
        ;;

    gpg)
        ACTION="$ACTION --restow gpg"
        ;;

    *)
        echo "Usage: $0 [macos]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION

