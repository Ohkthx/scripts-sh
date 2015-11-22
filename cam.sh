#!/bin/bash
prefix32=/home/schism/.wine32
arch32=win32
dimensions=${1}
app_loc="${prefix32}/drive_c/Program Files/SwannView Link"
app="MyDvr.exe"

#if [[ ${dimensions} == "" ]];
# then
#	 dimensions="1920x1080"
# fi


DISPLAY=:0 wine explorer /desktop=DVR,${dimensions} ${app_loc}/${app} --opengl > /dev/null 2>&1 &
WINEPID=$!


wait ${WINEPID}
sleep 1; pkill explorer
sleep 1; pkill MyDvr.exe
echo "All cleaned up!"

