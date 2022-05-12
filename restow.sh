#!/bin/bash

case "$1" in
    macos)
        ACTION="--restow bare --restow macos"
        ;;

    bare)
        ACTION="--restow bare"
        ;;

    *)
        echo "Usage: $0 [macos|bare]"
        exit
esac

stow -v --target $HOME --no-folding $ACTION
