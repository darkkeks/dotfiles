#!/bin/bash

case "$1" in
    macos)
        ACTION="--delete bare --delete macos"
        ;;

    bare)
        ACTION="--delete bare"
        ;;

    *)
        echo "Usage: $0 [macos|bare]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION
