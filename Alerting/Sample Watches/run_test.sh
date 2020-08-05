if [ -z "$1" ]; then
echo "Specify watch name e.g. run_test.sh <foldername>"
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

protocol=http
if [ "$4" ] ; then
  protocol=$4
fi

num_tests=0
pass=0
fails=0
echo "--------------------------------------------------"
for test in `ls $1/tests/*.json`; do
echo "Running test $test"
python3 run_test.py --user $username --password $password --endpoint $endpoint --port $port --protocol $protocol --test_file $test
if [ $? -eq 0 ]; then
let pass=pass+1
else
let fails=fails+1
fi
let num_tests=num_tests+1
echo "--------------------------------------------------"
done;

echo "$num_tests tests run: $pass passed. $fails failed."
if [ $fails -eq 0 ]; then
exit 0
else
exit 1
fi




