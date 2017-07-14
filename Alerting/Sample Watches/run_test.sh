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

num_tests=0
pass=0
fails=0
echo "--------------------------------------------------"
for test in `ls $1/tests/*.json`; do
echo "Running test $test"
python run_test.py --test_file $test --user $username --password $password
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




