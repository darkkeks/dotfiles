#!/bin/bash

ACTION="--delete bare"

case "$1" in
    "")
        ;;

    macos)
        ACTION="$ACTION --delete macos"
        ;;

    gpg)
        ACTION="$ACTION --delete gpg"
        ;;


    *)
        echo "Usage: $0 [macos|gpg]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION
