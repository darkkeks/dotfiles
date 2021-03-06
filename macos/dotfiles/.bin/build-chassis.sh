#!/bin/bash

set -e

OUTPUT_PATH=~/IdeaProjects/chassis

if ! ROOT=$(arc root); then
    echo "You should be in arcadia root!"
    exit
fi

function build {
    cd "$ROOT"

    echo "Dumping dependency graph..."
    ya dump dir-graph direct/apps/chassis/ > /tmp/graph.json

    MODULES="$(jq '. | keys | .[]' /tmp/graph.json -r | grep '^direct' | awk 'BEGIN { ORS=" " }; { print "-C " $1 }')"

    echo "Running ya ide idea..."
    ya ide idea --ignore-recurses --yt-store --group-modules tree --omit-test-data --iml-in-project-root --local -r $OUTPUT_PATH $MODULES

    echo "Done!"
}

build
