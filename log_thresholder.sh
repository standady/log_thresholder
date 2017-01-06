#!/usr/bin/env bash

print_usage () {
   echo "Usage $0 <log_file> <stat_file> <needle> <-min|max> 5 [<-format> ]"
   echo "   log_file    path to file that will be searched"
   echo "   stat_file   Maintains where the last check was ran from"
   echo "   needle      String to search file for (uses grep so regex can be used)"
   echo "   min         Minimum number of times the needle is expected to be in the log"
   echo "   max         Maximum of times the needle is expected to be in the log"
   echo "   interval    Number of minutes                                                   "
   echo "   format      Format for dates in log  (use format code found in date man) Defaults to ISO-8601("%Y-%m-%dT%H:%M")"
}

compare_date () {
   if [[ $# -lt 2 ]]
   then
      exit 1
   fi

   t1=$(date --date="$1" +"%s")
   t2=$(date --date="$2" +"%s")
   ((td=$t2-t1))

   echo $td
}



if [[ $# -lt 7 ]]
then
   print_usage
   exit 1
fi

log_file=$1
stat_file=$2
needle=$3
shift 3

interval=0
min=0
max="-1"
format="%Y-%m-%dT%H:%M"
while : ; do
   case "$1" in
      -interval)
         interval=$2
         shift 2 ;;
      -min)
         min=$2
         shift 2 ;;
      -max)
         max=$2
         shift 2 ;;
      -format)
         format=$2
         shift 2 ;;

      *)
         break ;;
   esac
done

if [[ ! -r "$log_file" ]]
then
    echo "WARNING: Could not read from $log_file" >&2
    exit 1
fi

currentTime=$(date -Iminutes)

if [[ ! -f "$stat_file" ]]
then
  echo $(date --date="$currentTime - $interval minutes" -Iminutes) >$stat_file
fi

lastTime=$(cat $stat_file)
spanTime=$(date --date="$lastTime + $interval minutes" -Iminutes)

issue=0
while [[ $(compare_date $spanTime $currentTime) -gt 0 ]]; do

   lastDateStr=$(date --date="$lastTime" +"$format")
   endDateStr=$(date --date="$spanTime" +"$format")

   #get lines from file
   found=$(awk '$1>="'$lastDateStr'" && $1 <="'$endDateStr'"' $log_file | grep -o "$needle" | wc -l)

   if [[ $found -lt $min ]] || [[ $max -gt "-1" && $found > $max ]]
   then
      echo "PROBLEM: There were $found occurrences of \"$needle\" between $lastDateStr and $endDateStr. Expected at least $min and at most $max."
      issue+=1
   else
      echo "OK: $found occurrences of \"$needle\" between $lastDateStr and $endDateStr."
   fi

   lastTime=$spanTime
   spanTime=$(date --date="$lastTime + $interval minutes" -Iminutes)
done

echo $spanTime >$stat_file

exit $issue
