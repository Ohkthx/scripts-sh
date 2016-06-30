#!/bin/bash

# Created by:	Ryan Ball
# Date created:	22 Nov 2015

# Purpose: 	Assist in the automation of implementing UO (Ultima Online) onto the linux 
# 		  platform. For a full installation, you will need to execute this script twice.
#		  + The first time will result in downloading both UO Steam and UO Classic Client.
#			It will then prompt you for the installation steps of the classic client
#			and lastly begin the patching process.
#		  + The second time will install UO Steam and fix the window management of ultima.
#			You will be prompted with special options to make execution and launching 
#			of Ultima much easier.
#			(Creates a launch application and a shortcut for the more manual launching.
# Notes:	This was a rushly created script. Overall it took about 2 hours (slighty more time for patching.
#		I attempted to add as much redundancy as possible to ensure that the files get installed
#		  correctly and it has no issues with dependencies. That is why you may see some repetitve actions.
#		I also built it around the ability to relaunch the script without doing a bunch of back work like
#		  redownloading or installing applications.

clear

UOC_CLIENT_EXE="UOClassicSetup.exe"	# Assigns the name of the client
#UOS_CLIENT_RAR="UOS_Latest.rar"		# Name of the .rar file for UO Steam
UOS_CLIENT_EXE="UOS_Latest.exe"		# Name of the UO Steam application (what is extracted from .rar)

UOC_CLIENT_URL="http://web.cdn.eamythic.com/us/uo/installers/20120309/UOClassicSetup_7_0_24_0.exe"	# URL to download from
UOS_CLIENT_URL="http://uos-update.github.io/UOS_Latest.exe"						# URL to download from
INSTALL_DIR="${PWD}/ultima_install"
W_PREFIX="${HOME}/.uo"

INS="[\x1B[1;36m**\x1B[0m]"	# Fancy prefix for a string display of a install: [**]
SUC="[\x1B[36m+\x1B[0m]"	# Fancy prefix for a string display of successful return: [+]
BAD="[\x1B[31m-\x1B[0m]"	# Fancy prefix for a string display of a failture return: [-]


function main
{
	check_progs					# Checks the required programs and makes sures that are installed... if not
							#   it will exit the application and notify what is needed.
	create_install_dir				# Creates the installation directory (This directory houses the download files.)
	if [[ ${execution_success} == "true" ]]; then	# If the directory was succesfully created...
		create_install_dir			# Navigates into the directory. This is a lame redundancy but is more handy
	fi						#   in the following functions. Just keeping it of a similar design.

	UOC_install					# Downloads and installs the Ultima Online Classic Client.
	if [[ ${execution_success} == "true" ]]; then	# If the download was successful (Double checks and makes sure file exist):
		UOC_install				# Launches the wizard for installing UO. Accept the defaults.
	fi						#   It will then launch UO to start patching. The script will exit here.

	UOS_install					# After a relaunch of the script... Downloads the UO Steam client.
	if [[ ${execution_success} == "true" ]]; then	# If the download was successfull (verifies existance):
		UOS_install				# Launches the wize for installing the client.
	fi

	WINE_fix					# Launches the winecfg menu to fix the window management of the Ultima Client.

	pause

	LINK_create					# Final options for creating aliases and shortcuts to launching UOS and UO.
}


function check_progs
{
	req_progs="wine wget"	# Programs that will be iterated through to verify they exist on the system.

	for program in ${req_progs}; do
		if [[ ! -f /usr/bin/${program} || ! -f /bin/${program} ]]; then	# Checks to verify you have the ability to download the executables (wget)
			echo " You need to the ${program} package to install this..."
			echo "  Exiting..."
			exit		# This executable is required... can not proceeded with downloading without it
		else
			echo -e " ${SUC} ${program} found."
		fi
	done
}


function create_install_dir
{
	execution_success="false"
	if [[ ! -d ultima_install/ ]]; then	
		echo -e " ${BAD} Directory: ultima_install/ does not exist... Creating."
		mkdir ultima_install		# Creates the directory.
		echo -e " ${SUC} Directory created."

		echo -e " ${BAD} Verifying directory creation was successful..."
		sleep 1
		execution_success="true"	# Sets the flag that will allow for rechecking directory existance and then changing.

	else
		echo -e "\n ${SUC} Directory: ultima_install/ exists... changing current directory."
		cd ultima_install/	# Changes to the directory.
		echo -e " ${SUC} Current Directory: ${PWD}"
	fi
}


function UOC_install 
{
	execution_success="false"
	if [[ ! -f ${UOC_CLIENT_EXE} ]]; then
		echo -e "\n  ${BAD} File ${UOC_CLIENT_EXE} not found. Downloading."
		wget -O ${UOC_CLIENT_EXE} ${UOC_CLIENT_URL} > /dev/null 2>&1		# Downloads the UO Classic Client.
		sleep 1
		if [[ -f ${UOC_CLIENT_EXE} ]]; then
			echo -e " ${SUC} ${UOC_CLIENT_EXE} download complete. "
			execution_success="true"					# Set flag for it to install (download success)
		fi
	else
		if [[ ! -d "${W_PREFIX}/drive_c/Program Files/Electronic Arts/Ultima Online Classic/" ]]; then
			echo -e "\n ${INS} Launching installation of: ${UOC_CLIENT_EXE}."
			WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine ${UOC_CLIENT_EXE} > /dev/null 2>&1	# Launch the UO Install.
			echo -e " ${SUC} Installation complete."
		fi

		if [[ ! -f "${W_PREFIX}/drive_c/Program Files/Electronic Arts/Ultima Online Classic/soundLegacyMUL.uop" ]]; then
			echo -e "\n ${INS} Patching the ${UOC_CLIENT_EXE} client."
			cd "${W_PREFIX}/drive_c/Program Files/Electronic Arts/Ultima Online Classic/"
			echo "  Current Directory: ${PWD}"
			WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine UO.exe > /dev/null 2>&1	# Launch the Patcher
			echo -e "\n\n The patcher may take several seconds to launch. After the patch update is"
			echo -e "complete. Please restart the script to continue the install. It will not duplicate"
			echo -e "any of the previous installation. Thank you- (Approximately 30seconds)"
			for ((i = 30; i > -1; i--))
			do
				echo -en "\rTime: ${i}  "	# Count down of 30 seconds... so users don't think it is broken.
				sleep 1
			done
			
			echo
			exit
		fi

	fi
}


function UOS_install
{
	execution_success="false"
	if [[ ! -f ${UOS_CLIENT_EXE} ]]; then
		if [[ ! -f ${UOS_CLIENT_EXE} ]]; then
			echo -e "\n  ${BAD} File: ${UOS_CLIENT_EXE} not found... Downloading."
			wget ${UOS_CLIENT_URL} > /dev/null 2>&1		# Downloads the UO Steam client.
			echo -e " ${SUC} Download complete of: ${UOS_CLIENT_EXE}"
			sleep 1
			execution_success="true"	# Flag for installation.
		fi
	else
		if [[ ! -d "${W_PREFIX}/drive_c/Program Files/UOS" ]]; then
			echo -e "\n ${INS} Installing ${UOS_CLIENT_EXE}."
			WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine ${UOS_CLIENT_EXE} > /dev/null 2>&1	# Launches UOS installation process.
		fi
	fi
}


function WINE_fix
{
	execution_success="false"
	echo -e "\n Modifying the winecfg to disable the window manager for controlling UO."
	echo "If this option is not performed. Your game will crash everytime when selecting"
	echo "a character and entering the game."
	echo -e "\n Options to DESELECT on the \"Graphics\" tab: "
	echo -e "\tAllow the window manager to decorate the windows."
#	echo -e "\tAllow the window manager to control the windows."
	WINEPREFIX=${W_PREFIX} WINEARCH=win32 winecfg > /dev/null 2>&1	# Launches the winecfg to disable window management.
}


function LINK_create
{
	echo -e "\n Do you wish to add the wine alias into your shell file?"
	echo "*(This will make typing \"wine\" a shortcut for: WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine"
	echo -n "  Option [y/N]: "
	read input
	if [[ ${input} == [yY] || ${input} == [yY][Ee][Ss] ]]; then
		check_alias	# If accepted... Check existance, if not- create alias in users default shell.
	fi

	echo -e "\n Do you want to make a shortcut to the game launch in ${HOME}?"
	echo  "This will allow for you to type in: \"./ultima.sh\" into the command prompt"
	echo  "to launch the game with UO Steam (in your home directory of course)"
	echo -n "  Option [y/N]: "
	read input
	if [[ ${input} == [yY] || ${input} == [yY][Ee][Ss] ]]; then
		check_shortcut	# If accepted... Check existance, if not- create the short for launching UO.
	fi

	echo -e "\n\n Installation complete! If you want a chance to reenable some of these options above, "
	echo "  Just restart this script. It shouldn't prompt for any installation unless files are missing."
	echo "  Thanks,"
	echo "     Ryan || 0x1p2 || Schism"
	exit
}


function check_alias
{
	shell=`echo ${SHELL} | awk -F"/" '{print $4}'`			# Parses /usr/bin/SHELL for shell name
	if_enabled=`cat ${HOME}/.${shell}rc | grep "alias wine"`	# Checks for alias inside shells configuration file.
	if [[ ${if_enabled} != "" ]]; then
		echo -e "\n ${BAD} Alias exists already.."		# Already exists. MEH.
	else
		echo "alias wine='WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine'" >> ${HOME}/.${shell}rc	# Appends alias to config file
		echo -e "\n\n ${SUC} Alias added. \n"
	fi
}


function check_shortcut
{
	UO_PATH="${HOME}/ultima.sh"								# FILE: ./ultima.sh
	if [[ ! -f ${UO_PATH} ]]; then	
		echo "#!/bin/bash" > ${UO_PATH}							# #!/bin/bash
		echo "cd \"${W_PREFIX}/drive_c/Program Files/UOS\"" >> ${UO_PATH} 		# cd "${W_PREFIX}/drive_c/Program Files/UOS"
		echo "WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine UOS.exe" >> ${UO_PATH}		# WINEPREFIX=${W_PREFIX} WINEARCH=win32 wine UOS.exe > /dev/null 2>&1
		echo -e "\n${UO_PATH} has been created!"					#     resulted in poor performance by wine -------------^
		chmod +x ${UO_PATH}								# Marks the new file executable.
		echo "EXECUTE AND LAUNCH UO BY: \"./ultima.sh\" in your home directory."
	else
		echo -e " ${BAD} ${UO_PATH} already exists!"
	fi

}

function pause
{
	echo ""
	read -n 1 -p "Press any key to continue..." temp
	echo ""
}

main	# Execute main
