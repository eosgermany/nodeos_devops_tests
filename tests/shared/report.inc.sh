


testcase_report() {
  dt=$(date '+%d/%m/%Y %H:%M:%S');
  name=$1
  result=$2

  if [ "$result" -eq 0 ]; then
  	echo "$name.sh OK @"$dt >> results.log
  else
  	echo "$name.sh ERROR @"$dt >> results.log
  fi 	
}