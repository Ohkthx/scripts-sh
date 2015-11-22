#!/bin/bash
#syntax: alive.sh <#_of_pings>
DEADCOUNT=0
LIVECOUNT=0
x=0
count="${1}"
if [[ ${1} == "" ]]; then count=0; fi
while [[ ${x} -le ${count} ]];
do
	#CHECKING="$CHECKING${i} "
	x=$((x+1))
	ping -c 1 -t 1 vps > /dev/null 2>&1;
	if [[ $? -eq 0 ]]; then
		LIVECOUNT=$((LIVECOUNT+1))
		echo "${LIVECOUNT}: Alive"
	elif [[ $? -gt 0 ]]; then
		DEADCOUNT=$((DEADCOUNT+1))
		echo "${DEADCOUNT}: Dead"
	fi
done
