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

UOC_CLIENT_EXE="UOClassSetup.exe"
UOS_CLIENT_RAR="UOS_Latest.rar"
UOS_CLIENT_EXE="UOS_Latest.exe"

UOC_CLIENT_URL="http://web.cdn.eamythic.com/us/uo/installers/20120309/UOClassicSetup_7_0_24_0.exe"
UOS_CLIENT_URL="http://www.uoforever.com/files/UOS_Latest.rar"
INSTALL_DIR="${PWD}/ultima_install"
full_install="false"


function main
{
	create_install_dir
	if [[ ${execution_success} == "true" ]]; then
		create_install_dir
	fi

	UOC_install
	if [[ ${execution_success} == "true" ]]; then
		UOC_install
	fi

	UOS_install
	if [[ ${execution_success} == "true" ]]; then
		UOS_install
	fi

	WINE_fix

	LINK_create
}

function create_install_dir
{
	execution_success="false"
	if [[ ! -d ultima_install/ ]]; then
		echo "  [-] Directory: ultima_install/ does not exist... Creating."
		mkdir ultima_install			# Creates the directory.
		echo " [+] Directory created."
		full_install="true"			# Sets the flag "full_install" because install files do not exist.

		if [[ ! -f /usr/bin/wget ]]; then	# Checks to verify you have the ability to download the executables (wget)
			echo " You need to the wget package to install this..."
			echo "  Exiting..."
			exit		# This executable is required... can not proceeded with downloading without it
		fi			#   unless it is done manually....

		echo "  [-] Verifying directory creation was successful..."
		sleep 1
		execution_success="true"

	else
		echo -e "\n [+] Directory: ultima_install/ exists... changing current directory."
		cd ultima_install/	# Changes to the directory.
		echo " [+] Current Directory: ${PWD}"
	fi
}


function UOC_install 
{
	execution_success="false"
	if [[ ! -f ${UOC_CLIENT_EXE} ]]; then
		echo -e "\n  [-] File ${UOC_CLIENT_EXE} not found. Downloading."
		wget -O ${UOC_CLIENT_EXE} ${UOC_CLIENT_URL} > /dev/null 2>&1
		sleep 1
		if [[ -f ${UOC_CLIENT_EXE} ]]; then
			echo " [+] ${UOC_CLIENT_EXE} download complete. "
			execution_success="true"
		fi
	else
		if [[ ! -d "${HOME}/.wine32/drive_c/Program Files/Electronic Arts/Ultima Online Classic/" ]]; then
			echo -e "\n [++] Launching installation of: ${UOC_CLIENT_EXE}."
			WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine ${UOC_CLIENT_EXE} > /dev/null 2>&1
			echo " [+] Installation complete."
		fi

		if [[ ! -f "${HOME}/.wine32/drive_c/Program Files/Electronic Arts/Ultima Online Classic/soundLegacyMUL.uop" ]]; then
			echo -e "\n  [++] Patching the ${UOC_CLIENT_EXE} client."
			cd "${HOME}/.wine32/drive_c/Program Files/Electronic Arts/Ultima Online Classic/"
			echo "  Current Directory: ${PWD}"
			WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine UO.exe > /dev/null 2>&1
			echo -e "\n\n The patcher may take several seconds to launch. After the patch update is"
			echo -e "complete. Please restart the script to continue the install. It will no duplicate"
			echo -e "any of the previous installation. Thank you- (Approximately 30seconds)"
			for ((i = 30; i > -1; i--))
			do
				echo -en "\rTime: ${i}  "
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
	if [[ ! -f ${UOS_CLIENT_RAR} || ! -f ${UOS_CLIENT_EXE} ]]; then
		if [[ ! -f ${UOS_CLIENT_RAR} ]]; then
			echo -e "\n  [-] File: ${UOS_CLIENT_RAR} not found... Downloading."
			wget -O ${UOS_CLIENT_RAR} ${UOS_CLIENT_URL} > /dev/null 2>&1
			echo " [+] Download complete of: ${UOS_CLIENT_RAR}"
			sleep 1
		fi

		if [[ -f ${UOS_CLIENT_RAR} && ! -f ${UOS_CLIENT_EXE} ]]; then 
			echo "  [-] Unpacking ${UOS_CLIENT_RAR}."
			rar x ${UOS_CLIENT_RAR} > /dev/null 2>&1
			sleep 1
			if [[ -f ${UOS_CLIENT_EXE} ]]; then
				echo " [+] Unpackaging of ${UOS_CLIENT_RAR} => ${UOS_CLIENT_EXE} complete."
				execution_success="true"
			fi
		fi
	else
		# # # #  INSTALL
		if [[ ! -d "${HOME}/.wine32/drive_c/Program Files/UOS" ]]; then
			echo -e "\n [++] Installing ${UOS_CLIENT_EXE}."
			WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine ${UOS_CLIENT_EXE} > /dev/null 2>&1
		fi
	fi
}


function WINE_fix
{
	clear
	execution_success="false"
	echo -e "\n Modifying the winecfg to disable the window manager for controlling UO."
	echo "If this option is not performed. Your game will crash everytime when selecting"
	echo "a character and entering the game."
	echo -e "\n Options to DESELECT on the \"Graphics\" tab: "
	echo -e "\tAllow the window manager to decorate the windows."
	echo -e "\tAllow the window manager to control the windows."
	WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 winecfg > /dev/null 2>&1
}

function LINK_create
{
	clear
	echo -e "\n Do you wish to add the wine alias into your shell file?"
	echo "*(This will make typing \"wine\" a shortcut for: WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine"
	echo -n "  Option [y/N]: "
	read input
	if [[ ${input} == [yY] || ${input} == [yY][Ee][Ss] ]]; then
		check_alias
	fi

	echo -e "\n Do you want to make a shortcut to the game launch in ${HOME}?"
	echo  "This will allow for you to type in: \"./ultima.sh\" into the command prompt"
	echo  "to launch the game with UO Steam (in your home directory of course)"
	echo -n "  Option [y/N]: "
	read input
	if [[ ${input} == [yY] || ${input} == [yY][Ee][Ss] ]]; then
		check_shortcut	
	fi

	echo -e "\n\n Installation complete! If you want a chance to renable some of these options above, "
	echo "  Just restart this script. It shouldn't prompt for any installation unless files are mising."
	echo "  Thanks,"
	echo "     Ryan || 0x1p2 || Schism"
	exit
}

function check_alias
{
	shell=`echo ${SHELL} | awk -F"/" '{print $4}'`
	if_enabled=`cat ${HOME}/.${shell}rc | grep "alias wine"`
	if [[ ${if_enabled} != "" ]]; then
		echo "  [-] Alias exists already.."
	else
		echo "alias wine='WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine'" >> ${HOME}/.${shell}rc
		echo -e "\n\n  [+] Alias added. \n"
	fi
}

function check_shortcut
{
	UO_PATH="${HOME}/ultima.sh"
	if [[ ! -f ${UO_PATH} ]]; then
		echo "#!/bin/bash" > ${UO_PATH}
		echo "cd \"${HOME}/.wine32/drive_c/Program Files/UOS\"" >> ${UO_PATH} 
		echo "WINEPREFIX=${HOME}/.wine32 WINEARCH=win32 wine UOS.exe" >> ${UO_PATH}
		echo -e "\n${UO_PATH} has been created!"
		chmod +x ${UO_PATH}
		echo "EXECUTE AND LAUNCH UO BY: \"./ultima.sh\" in your home directory."
	else
		echo "${UO_PATH} already exists!"
	fi

}

main	# Execute main
