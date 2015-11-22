#!/bin/bash 

# Created by: Schism
# Date created: 3 September, 2015
# Filename: brightness.sh
# Syntax: ./brightness.sh <number to set display>

# Changes:
#  Added:
#  3sep	- Added a check for 'root' user. Will prevent execution.
#  3sep	- Added color for error messages and non error messages.
#  3sep - Added ability to execute as non-root. Performs auto-sudo.
#  3sep - Added the ability to use the word "max" as a parameter.
#  3sep - Checks path for proper brightness settings. 
# 20sep - Change MIN_BRIGHTNESS from 1 to 10% of MAX_BRIGHTNESS.
#		MIN_BRIGHTNESS 1 will still result in black screen.
# 20sep - If value given below MIN_BRIGHTNESS, option to use MIN_BRIGHTNESS
#
# Removed: 
#  3sep	- pause() function. Not really needed before an exit.


# VARIABLES:
BRIGHTNESS_DIR=`ls /sys/class/backlight | head -n 1 | tail -n 1 | awk '{print $1}'`
BRIGHTNESS_MAX=`cat /sys/class/backlight/${BRIGHTNESS_DIR}/max_brightness`
BRIGHTNESS_MIN=`awk -v var1="${BRIGHTNESS_MAX}" -v var2="0.1" 'BEGIN {printf "%.2f", var1*var2; exit(0)}' | cut -d'.' -f1`
#BRIGHTNESS_MIN=1
BRIGHTNESS_FILE="/sys/class/backlight/${BRIGHTNESS_DIR}/brightness"

COLOR_OFF='\e[0m'       # Text Reset
RED='\e[0;31m'          # Red
GREEN='\e[0;32m'        # Green
ERR=" ${RED}==>${COLOR_OFF}  " 		# Error message prefix.
NERR="${GREEN}==>${COLOR_OFF}  "	# Non-Error message prefix.


# Check parameters, throw an error if fails and provide
#  proper syntax.
echo -e "\n${NERR}Executing as ${GREEN}${USER}${COLOR_OFF}!"

if [[ ! -f /sys/class/backlight/${BRIGHTNESS_DIR}/brightness ]];
 then
 	echo -e "${ERR}${BRIGHTNESS_DIR}/brightness does not exist!"
	echo -e "${NERR}Exiting..."
fi

# Check for root user:
if [[ ! ${EUID} -eq 0 ]];
 then
 	echo -e "\n${ERR}You must be root!"
	echo -en "${ERR}Execute as root? [y/n]: "
	read execute_root
	if [[ ${execute_root} == "y" || ${execute_root} == "yes" ]];
	 then
	 	echo " "
	 	sudo ${0} ${1}
	 	exit 0
	else
		echo -e "${NERR}Exiting..."
		exit 1
	fi
fi

if  [[ ${1} == "" ]];
 then
 	echo -e "\n${ERR}No parameters selected."
	echo -e " ${ERR} Syntax: ${0}  <number / max>"
	echo -e " ${ERR}MAX: ${BRIGHTNESS_MAX}\tMIN:${BRIGHTNESS_MIN}"
	echo -e "${NERR}Exiting..."
	exit 1
elif [[ ${1} == "max" ]];
 then
 	echo ${BRIGHTNESS_MAX} > ${BRIGHTNESS_FILE}
	echo -e "${NERR}Brightness changed to: ${BRIGHTNESS_MAX}."
	exit
elif [[ ! "${1}" =~ ^[0-9]+$ ]];
 then
 	echo -e "\n${ERR}You must provide a number or the word \"max\"!"
	echo -e " ${ERR}Syntax: ${0}  <number / max>"
	echo -e " ${ERR}MAX: ${BRIGHTNESS_MAX}\tMIN:${BRIGHTNESS_MIN}"
	echo -e "${NERR}Exiting...\n"
	exit 1
elif [[ ${1} -gt ${BRIGHTNESS_MAX} || ${1} -lt ${BRIGHTNESS_MIN} ]];
 then
 	echo -e "\n${ERR}Invalid Brightness: ${1}."
	echo -e " ${ERR}Range: ${BRIGHTNESS_MIN} - ${BRIGHTNESS_MAX}"
	echo -en "${NERR}Set to ${BRIGHTNESS_MIN} instead? [y/n]: "
	read choice
	if [[ ${choice,,} == "no" || ${choice,,} == "n" ]];
	 then
		echo -e "${NERR}Exiting...\n"
		exit 1
	else
		echo ${BRIGHTNESS_MIN} > ${BRIGHTNESS_FILE}
		echo -e "${NERR}Brightness changed to: ${BRIGHTNESS_MIN}."
		exit
	fi
else
	echo ${1} > ${BRIGHTNESS_FILE}
	echo -e "${NERR}Brightness changed to: ${1}."
	exit
fi

