if [ -z "$1" ] ; then
  echo "USAGE: load_watch.sh <watch_name> <optional_username> <optional_password> <optional_endpoint>:<optional_port>"
  echo "eg: ./load_watch.sh port_scan elastic changeme my_remote_cluster.mydomain:9200"
  echo -e
  echo "Defaults: elastic changeme localhost:9200"
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
    es_response=$(curl -s -X POST $endpoint:$port/_scripts/painless/$scriptname -u $username:$password -d @$script)
    if [ 0 -eq $? ] && [ $es_response = '{"acknowledged":true}' ]; then
        echo "Loading $scriptname script...OK"
    else
        echo "Loading $scriptname script...FAILED"
        exit 1
    fi
done

echo "Loading $1 watch "

curl -s -o /dev/null -X DELETE $endpoint:$port/_xpack/watcher/watch/$1 -u $username:$password
es_response=$(curl --w "%{http_code}" -s -o /dev/null -X PUT $endpoint:$port/_xpack/watcher/watch/$1 -u $username:$password -d @$1/watch.json)
if [ 0 -eq $? ] && [ $es_response = "201" ]; then
  echo "Loading $2 watch...OK"
  exit 0
else
  echo "Loading $2 watch...FAILED"
  exit 1
fi

