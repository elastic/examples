#!/bin/bash

if [ -z "${COFFEE_PRESS_HOSTS}" ]
then
    if [ -f ~/secrets.env ]
    then
	source ~/secrets.env
    fi
fi
BUTTONS_PER_CONTROLLER=4

entityId="$1"
sceneId="$2"
sceneData="$3"
quadId=${entityId#zwave.quad*}

creds="${COFFEE_PRESS_CREDENTIALS}"
hosts="${COFFEE_PRESS_HOSTS}"
endpoint="${COFFEE_PRESS_ENDPOINT}"

case $quadId in
    1|2)
	beverageSide=left
	;;
    3|4)
	beverageSide=right
	;;
    *)
	beverageSide="twilight zone"
	;;

esac

beverages=("Cappuccino" "Americano" "Mocha" "Macchiato" "Espresso" "Latte" "Coffee" "Other" )
beverageClass="Hot Beverages"

quadMod=$(( ($quadId - 1) % 2 ))
beverageIndex=$(( ($quadMod * $BUTTONS_PER_CONTROLLER) + $sceneId - 1 ))
beverage=${beverages[$beverageIndex]}

# ts=$(date "+%s")
ts=$(date -u "+%Y-%m-%dT%H:%M:%SZ")

read -r -d '' payload << EOF
{ 
    "sceneID": "$sceneId", 
    "sceneData": "$sceneData", 
    "entityID": "$entityId",  
    "quadId": $quadId,
    "quadMod": "$quadMod",
    "@timestamp": "$ts",  
    "beverageClass": "$beverageClass",  
    "beverage": "$beverage",  
    "beverageSide": "$beverageSide",  
    "beverageIndex": $beverageIndex,
    "quantity": 1
}
EOF

echo "payload: $payload" >> /tmp/quad.log
for host in $hosts
do
    output=$(curl -X POST \
		  --user "$creds" \
		  --silent \
		  --data "$payload" \
		  --header "Content-type: application/json" \
		  ${host}/${endpoint})
    if [ $? -ne 0 ]
    then
	echo $output >> /tmp/quad.log
    fi
done

