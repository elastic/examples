if [ -z "$1" ]; then
  echo "Specify watch name e.g. run_test.sh <foldername>"
  exit 1
fi

username=elastic
if [ "$2" ] ; then
  username="$2"
fi

password=changeme
if [ "$3" ] ; then
  password="$3"
fi

port=9200
endpoint=localhost
if [ "$4" ] ; then
  if ":" in "$4"; then
    endpoint=${4%":"*} # extract the host value from the provided endpoint
    port=${4#*":"}  # extract the port value if provided in endpoint:port format
    if [ "$port" == "" ]; then
      # if port is blank, due to endpoint provided as localhost: or no port provided then use default port
      port=9200
    fi
  else
    endpoint=$4
  fi
fi

protocol=http
if [ "$5" ] ; then
  protocol=$5
fi

num_tests=0
pass=0
fails=0
echo "--------------------------------------------------"
# shellcheck disable=SC2231
for test in $1/tests/*.json; do
  echo "Running test $test"

  if python3 run_test.py --user "$username" --password "$password" --endpoint "$endpoint" --port "$port" --protocol "$protocol" --test_file "$test"; then
    pass=$(( pass+1 ))
  else
    fails=$(( fails+1 ))
  fi
  num_tests=$(( num_tests+1 ))
  echo "--------------------------------------------------"
done

echo "$num_tests tests run: $pass passed. $fails failed."
if [ $fails -eq 0 ]; then
  exit 0
else
  exit 1
fi
