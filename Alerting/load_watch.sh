if [ -z "$1" ] ; then
    echo "No watch name supplied e.g. ./load_watch.sh port_scan"
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

echo "Loading $1 scripts"

shopt -s nullglob
for script in $1/scripts/*.json
do
    filename=$(basename "$script")
    scriptname="${filename%.*}"
    echo $scriptname
    es_response=$(curl -s -X POST localhost:9200/_scripts/painless/$scriptname -u $username:$password -d @$script)
    if [ 0 -eq $? ] && [ $es_response = '{"acknowledged":true}' ]; then
        echo "Loading $scriptname script...OK"
    else
        echo "Loading $scriptname script...FAILED"
        exit 1
    fi
done

echo "Loading $1 watch "

curl -s -o /dev/null -X DELETE localhost:9200/_xpack/watcher/watch/$1 -u $username:$password
es_response=$(curl --w "%{http_code}" -s -o /dev/null -X PUT localhost:9200/_xpack/watcher/watch/$1 -u $username:$password -d @$1/watch.json)
if [ 0 -eq $? ] && [ $es_response = "201" ]; then
echo "Loading $2 watch...OK"
exit 0
else
echo "Loading $2 watch...FAILED"
exit 1
fi