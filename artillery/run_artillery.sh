#!/bin/bash

readonly ARGS="$@"
readonly TMP_DIR="/tmp"
readonly OUTPUT_DIRECTORY="/code/build"

runArtillery() {
    echo "Starting artillery..."
    cd "$TMP_DIR"
    echo $ARTILLERY_CONFIG
    artillery run $@
}

main() {
    runArtillery $@
}

main $ARGS
