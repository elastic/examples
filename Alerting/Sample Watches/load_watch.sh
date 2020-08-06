if [ -z "$1" ] ; then
  echo "USAGE: load_watch.sh <watch_name> <optional_username> <optional_password> <optional_endpoint>:<optional_port> <optional_protocol>"
  echo "eg: ./load_watch.sh port_scan elastic changeme my_remote_cluster.mydomain:9200 https"
  echo -e
  echo "Defaults: elastic changeme localhost:9200 http"
  exit 1
fi

username=elastic
if [ "$2" ] ; then
  username=$2
fi

password=changeme
if [ "$3" ] ; then
  password=$3
fi

port=9200
endpoint=localhost
if [ "$4" ] ; then
  if ":" in $4; then
    endpoint=${4%":"*} # extractthe host value from the provided endpoint
    port=${4#*":"}  # extract the port value if provided in endpoint:port format
    if [ "$port" == "" ]; then
      # if port is blank, due to endpoint provided as localhost: or no port providedthen use default port
      port=9200
    fi
  else
    endpoint=$4
  fi
fi

if [ "$5" ] ; then
  protocol="$5://"
else
  protocol="http://"
fi

# test if provided watch name is correct/exists
if [ ! -d "$1" ]; then
  echo "Watch scripts dir $1 doesn't appear to exist in $PWD"
  exit 1
fi

echo "Loading $1 scripts"

shopt -s nullglob
for script in $1/scripts/*.json
do
    filename=$(basename "$script")
    scriptname="${filename%.*}"
    echo $scriptname
    es_response=$(curl -H "Content-Type: application/json" -s -X POST $protocol$endpoint:$port/_scripts/$scriptname -u $username:$password -d @$script)
    if [ 0 -eq $? ] && [ $es_response = '{"acknowledged":true}' ]; then
        echo "Loading $scriptname script...OK"
    else
        echo "Loading $scriptname script...FAILED"
        exit 1
    fi
done


echo "Removing existing $1 watch "
curl -H "Content-Type: application/json" -s -X DELETE $protocol$endpoint:$port/_xpack/watcher/watch/$1 -u $username:$password
echo "Loading $1 watch "
es_response=$(curl -H "Content-Type: application/json" --w "%{http_code}" -s -o /dev/null -X PUT $protocol$endpoint:$port/_xpack/watcher/watch/$1 -u $username:$password -d @$1/watch.json)
if [ 0 -eq $? ] && [ $es_response = "201" ]; then
  echo "Loading $1 watch...OK"
  exit 0
else
  echo "Loading $1 watch...FAILED with response code $es_response"
  exit 1
fi
