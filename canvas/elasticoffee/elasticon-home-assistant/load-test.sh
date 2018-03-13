#!/bin/bash

maxDelay=${1:-60}

function random
{
    local from=$1
    local to=$2

    echo $(( ((RANDOM<<15)|RANDOM) % ($to - $from + 1) + $from))
}

while [ 1 ]
do
    quad=$(random 1 4)
    button=$(random 1 4)
    delay=$(random 2 $maxDelay)

    echo "coffeePressHandler.sh  "zwave.quad${quad}" "$button" 0 delay=$delay"
    ./coffeePressHandler.sh  "zwave.quad${quad}" "$button" 0
    sleep $delay
done
