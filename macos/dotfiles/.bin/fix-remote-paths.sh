#!/bin/bash

path=$1

if [[ -z "$path" ]]; then
    echo "No path specified"
    exit 1
fi

echo "Fixing paths in $path"

grep -rl /home/darkkeks $path \
    | grep -E '\.(xml|java|iml)$' \
    | xargs perl -i -pe 's!/home/darkkeks/!/Users/darkkeks/!g'

echo "Done"
