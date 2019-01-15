dt=$(date '+%d/%m/%Y %H:%M:%S');

echo "$dt"

testcase_report() {
  name=$1
  result=$2

  if [ "$result" -eq 0 ]; then
  	echo "$name.sh OK @"$dt >> results.log
  else
  	echo "$name.sh ERROR @"$dt >> results.log
  fi 	
}