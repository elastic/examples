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

generateReport() {
    echo "Generating report..."
    artillery report $TMP_DIR/artillery_report_*.json
    echo "Archiving report in $OUTPUT_DIRECTORY..."
    cp $TMP_DIR/artillery_report_*.{html,json} "$OUTPUT_DIRECTORY"
}

main() {
    runArtillery $@
    generateReport
}

main $ARGS
