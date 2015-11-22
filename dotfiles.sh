#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 						    # # # # # # # # # # # # # # # # # # 
# Created by: Schism aka \x1p+2 aka Schy aka Royce  ## # # # # # # # # # # # # # # # # 
#   IRC Nick: \x1p2 || Schy                         # # # # # # # # # # # # # # # # # #
# Date Created: 8 September, 2015
# Name: dotfiles.sh
# Purpose:
#	Recursively backup selected files and directories
#	in the event of either a reload, corruption, FBI
#	CIA, NSA, or any other government agency breaking
#	down your door. (Kidding... no clear log function :P)
#
#	Option to send the files to a remote server for safe keeping.

# Revisions:
# 8SEP	v0.0 -	Initial start/creation @2112
# 9SEP 	v0.1 -  First compeletion (After splitting into function) @0108
# 9SEP	v0.2 - 	Allowed files/dirs to be explicted in subdirs.
#		  ie: .config/scripts/    Basicly preserves the parent dir.
# 10SEP v0.3 -  Fixed it capturing /home/${USER}/files*  Opening the TAR.GZ
#		  would lead the entire path because of the --parent on cp.

# # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # # #
#             N O T E S             # # # # # # # # # # # # # # # # # # # # # # # # # # 
# 1)  Add in parameters/switches for quick execution.
# 2)  Clean SCP log ;D (kidding, but maybe.)
# 3)  Unpack option; risky due to overwriting configuration files with old configs
# 4)  Add files/directories function. you will have to provide path off of ${HOME}
# 5)  Color the hostname/ip + username? Iunno just an option to mess with.

# # # # # # # # # # # # # # # # # # # 
#         V A R I A B L E S         #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
#   U S E R   M O D I F I A B L E   ## # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
TAR_BASE="dotfiles"	# Name of the tar file and base directory to be created.
# Insert Directories on new lines. Make sure there are ' & ' on first and last.
#   LOCATION of ACTION: ${HOME}. So adding "Documents" means: /home/${USER}/Documents
#   AND everything that is recursively below Documents.
SAVE_DIRECTORIES='Documents
media/pictures
.config/bspwm
.config/sxhkd
.config/scripts
.colors
.vim
.turses
.weechat'

SAVE_FILES='uuid
.uuid.bak
.vimrc
.compton.conf
.bashrc
.zshrc
.xinitrc
.Xresources
.Xdefaults
.Xauthority'
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # ## # # # # # # # # # # # # # # # # # # # # # # # 
C_OFF='\e[0m'	 	# Text Reset
#C_1='\e[0;32m'		# Green
C_1='\e[1;34m'		# Blue
C_2='\e[0;31m'		# Red
ERR="${C_2}==>${C_OFF}  "	# Error message prefix.
INFO="${C_1}==>${C_OFF}  "	# Non-Error message prefix.
TAR_BASE="dotfiles"		# Name of tar and temp dir; change if you want.	
TAR_NAME="${TAR_BASE}.tar.gz"	# Full tar name, uses above declaration
TAR_F="${TAR_NAME}"	# Full path to tar.
DIR_T="${TAR_BASE}"	# All files/directories will be cp'd here then tar'd.
fresh_start=1		# Used for startup in main.


# # # # # # # # # # # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # ## # # # # # # ### # # # # # # # # # # # # # # # #
# #       F U N C T I O N S       # #               # # # # # # # # # # # # # # # # #
# # # # # # # # # # # # # # # # # # #

pause()
{	
	# Creates a pause, useful for displaying information before 'clear'
	echo ""
	read -n 1 -p "Press any key to continue... " temp
	echo ""
}


startup() 
{
 # Local Variables
   # Zero out variables to be used in the for/if statements to come.
 files=(); missing=(); total=""; found=""; SUB_DIRS=""; SUB_FILES="";
 TOTAL_DIRS=""; TOTAL_FILES=""

 clear
 echo ""

 # Print some basic information
 echo -e "${INFO}Username: ${C_1}${USER}${C_OFF}"
 echo -e "${INFO}Home Directory: ${C_1}${HOME}${C_OFF}"
 echo -e "${INFO}Directory: ${C_1}${PWD}${C_OFF}"
 echo -e "${INFO}Tar File: ${C_2}${TAR_NAME}${C_OFF}"
 echo -e "${INFO}Save Location: ${C_2}${TAR_F}${C_OFF}"
 echo -e "${INFO}Checking for valid files in ${C_1}${HOME}${C_OFF}...\n"
 
 # Cycle thru each of the files and directories added to the variables above.
 #   and verify they exist.
 for item in ${SAVE_FILES} ${SAVE_DIRECTORIES};
 do
 	total=$((total+1))	# Adds a tally for a future output.
 	# Checks to verify the item is either a file or directory.
 	if [[ -f ${item} || -d ${item} ]];
 	then
 		echo -e " ${INFO}Found: ${item}${C_OFF}"
 		files+=("${item}")	# Adds that item to the final array.
 		found=$((found+1))	# Adds a tally for future output
 		# If it is a directory, check for the amount of sub-directories/files
 		if [[ -d ${item} ]];
 		then
 			SUB_FILES=`find ${item}/. -type f | wc -l`
 			SUB_DIRS=`find ${item}/. -type d | wc -l`
 			TOTAL_DIRS=$((${TOTAL_DIRS}+${SUB_DIRS}+1))
 			TOTAL_FILES=$((${TOTAL_FILES}+${SUB_FILES}))
 		# If it is a file, add to the file counter.
 		elif [[ -f ${item} ]];
 		then
 			TOTAL_FILES=$((TOTAL_FILES+1))
 		else
 			echo -e "${ERR} Unknown issue... "	# Unknown, but in here.
 			exit 1	# Exits just in case.
 		fi
 	else
 		echo -e "  ${ERR}Not Found: ${item}${C_OFF}"	# If it isn't found...
 		missing+=("${item}")				# add it to a list of "missing"
 	fi	
 done
 
 # Makes sure everything is OK, all files found.
 if [[ ${found} -eq ${total} ]]; 
 then
 	echo -e "\n${INFO}Found: ${found}/${total} items."
 elif [[ ${found} -lt ${total} ]];
 then
 	# If not all files were found, Tells you how many were and the missing one(s).
 	echo -e "\n  ${ERR}Found: ${found}/${total}\tMissing: ${C_2}${missing[@]}${C_OFF}"
 else
 	# Catch for unexpected error and to exit.
 	echo -e "\n  ${ERR} ERROR? ${found}/${total}"
 	exit 1
 fi
 
 # Print some worthless/basic information to amount of content being archived.
 #  this was gathered from the -d ${item}. 
 echo -e " ${INFO}Directories (+ sub-directories) discovered: ${C_1}${TOTAL_DIRS}${C_OFF}"
 echo -e " ${INFO}Files (+ sub-files) discovered: ${C_1}${TOTAL_FILES}${C_OFF}"
 
 for((;;)); do
  # Case statement that excepts all forms of yes/no
  echo -en "\n${INFO} Continue? [yes/no]: ${C_2}"
  read kbd_event
  case ${kbd_event} in
 	[yY] | [yY][Ee][Ss] )
		fresh_start=0
 		break
 		;;
 
 	[nN] | [nN][Oo] )
 		echo -e " ${ERR}Exiting..."
 		exit 1
 		;;
 	*) 
 		echo -e " ${ERR}Invalid input"
 		;;
  esac
 done
}


pkgr_tar()
{
 # Functions responsible for copying all files/directories and moving them
 #  to their temporary directory. Then packaging them
 clear
 echo ""
 # Checks if the directory (temp) does not exist. Else it creates it.
 if [[ ! -d ${DIR_T} ]]; then 
	mkdir ${DIR_T}
	echo -e "${INFO} Directory created: ${C_1}${DIR_T}${C_OFF}\n"
 else
	echo -e "${INFO} Directory exists: ${C_1}${DIR_T}${C_OFF}\n"

 fi

 # Iterates thru all of the discovered files/dirs found in startup() and copies them to temp_dir.
 for item in ${files[@]}; do
	 echo -en " ${ERR} [${C_2}COPYING${C_OFF}] ${C_1}${item}${C_OFF} into ${C_2}${DIR_T}${C_OFF}"
	 cp -R --parents ${item} ${DIR_T} > /dev/null 2>&1
	 echo -e "\r ${INFO} [${C_1}COPIED${C_OFF}] ${C_1}${item}${C_OFF} into ${C_2}${DIR_T}${C_OFF} " 
 done

 # Iterates thru all of the missing files and prints a message once again notifying missing contents
 for item in ${missing[@]}; do
	echo -e " ${ERR} [${C_2}SKIPPED${C_OFF}] ${C_1}${item}${C_OFF} - Not Found."
 done
 DISK_T=`du -sh ${DIR_T} | awk '{print $1}'`	# Grab the disk space used by the temp directory.
 echo -e "\n${INFO}Disk space taken by ${C_1}${DIR_T}${C_OFF}: ${C_2}${DISK_T}${C_OFF}."
 echo -en "${ERR} [${C_2}CREATING${C_OFF}] tar file: ${C_1}${TAR_F}${C_OFF}"
 tar czf ${TAR_F} ${DIR_T} > /dev/null 2>&1	# Tars the directory and nulls the erroneous output
 TAR_S=`du -sh ${TAR_F} | awk '{print $1}'`	# Grabs the disk space used by the tar file.
 echo -e "\r${INFO} [${C_1}COMPLETED${C_OFF}] Tar file: ${C_1}${TAR_F}${C_OFF}  Size: ${C_2}${TAR_S}${C_OFF}"
 pause
}


list_contents()
{
 # List either the missing or the found pacakges in a neat order. (First time attempt at this.) 
 # Uses parameters to change output.
 if [[ ${1} == "missing" ]]; then
	cnt=0
	for item in ${missing[@]}; do
		if [[ ! $((${cnt} % 3)) -eq 0 ]]; then
			echo -en "${C_2}[ ${item}] ${C_OFF}\t"
		else
			echo -en "\n${C_2} [${item}] ${C_OFF}\t"
			cnt=0
		fi
		cnt=$((cnt+1))
	done
 elif [[ ${1} == "found" ]]; then
	cnt=0
	for item in ${files[@]}; do
		if [[ ! $((${cnt} % 3)) -eq 0 ]]; then
			echo -en "${C_1} [${item}] ${C_OFF}\t"
		else
			echo -en "\n${C_1} [${item}] ${C_OFF}\t"
			cnt=0
		fi
		cnt=$((cnt+1))
	done
 else
	echo -e "${ERR}An error occured?"
 fi
 echo ""
 pause
}


up_ld_scp()
{
 # Added feature that makes the upload steam-lined. Prompts for username/hostname.
 #  Starts scp which requests password and automatically throws it into the home
 #  directory of the requested username.
 if [[ -f ${TAR_F} ]]; then
	 clear
	 echo ""
	 echo -e "${INFO}${C_1}${TAR_F}${C_OFF} found.\n"
	 echo -en " ${INFO}Hostname/IP: ${C_2}"
	 read rcvr
	 echo -en " ${INFO}Username: ${C_1}"
	 read usrnm
	 echo -e " ${INFO}Establishing connection..."
	 echo -en "  ${ERR}"
	 scp -q ${TAR_F} ${usrnm}@${rcvr}:/home/${usrnm}/.
	 echo -e "${INFO} [${C_1}COMPLETED${C_OFF}] Transfer complete."
 else
	 echo -e "\n ${ERR}${C_2}${TAR_F}${C_OFF} Not found. Please create."
 fi
 pause
}


temp_dir_rm()
{
 if [[ -d ${DIR_T} ]]; then
  for((;;)); do
	# Case statement that excepts all forms of yes/no
	echo -en "\n${INFO}Remove ${C_2}${DIR_T}${C_OFF}? [yes/no]: ${C_1}"
	read kbd_event
	case ${kbd_event} in
		[yY] | [yY][Ee][Ss] )
			echo -en " ${ERR}"
			rm -rI ${DIR_T}
			echo -e "${INFO}Removed ${C_2}${DIR_T}${C_OFF}."
			echo -e "${INFO}Returning to the main page..."
			pause
                 	break
                 	;;

		[nN] | [nN][Oo] )
			echo -e "${INFO}Returning to the main page..."
			pause
			break
			;;
		*)
			echo -e " ${ERR}Invalid input"
			;;
	esac
  done
 else
	 echo -e "\n${ERR}${C_1}${DIR_T}${C_OFF} does not exist..."
	 pause

 fi  
}


main()
{
cd ${HOME}
for((;;)); do
 # If first time ran, it does the discovery of directories/files outlined in top variables.
 if [[ ${fresh_start} -eq 1 ]]; then
	 startup
 fi
 clear
 echo ""
 echo -e "${INFO}Loaded Directories: ${C_1}${TOTAL_DIRS}${C_OFF}"
 echo -e "${INFO}Loaded Files: ${C_1}${TOTAL_FILES}${C_OFF}"
 echo -e "${INFO}Current Directory: ${C_2}${PWD}${C_OFF}"
 if [[ -d ${DIR_T} ]]; then echo -e "\t${C_1}${DIR_T}${C_OFF} - exists."; fi
 if [[ -f ${TAR_F} ]]; then echo -e "\t${C_1}${TAR_F}${C_OFF} - exists."; fi
 echo -e "\n${INFO}Available options: "
 echo -en " ${ERR} 1)  (RE)Check for files/directories (${found}/${C_1}${total}${C_OFF})
 ${ERR} 2)  Package Files into TAR.GZ
 ${ERR} 3)  List ${C_2}\"missing\"${C_OFF} files/directories
 ${ERR} 4)  List ${C_1}\"found\"${C_OFF} files/directories
 ${ERR} 5)  Upload to server with ${C_1}'scp'${C_OFF}
 ${ERR} 6)  ${C_2}REMOVE${C_OFF} directory ${C_2}${DIR_T}${C_OFF}
 ${ERR} 7)  Exit
 \b${INFO}Option by number: ${C_1}"
   read option
   case ${option} in
	   1 )
		   startup	# Reruns the initial check (in the event to you moved file.)
		   ;;
	   2 )
		   pkgr_tar 	# Copies all files to a directory then tar.gz's it.
		   ;;
	   3 )
		   list_contents missing	# Shows missing packages.
		   ;;
	   4 )
		   list_contents found		# Shows found packages.
		   ;;
	   5 )
		   up_ld_scp	# Uploads [name].tar.gz created by pkgr_tar to a remote host.
		   ;;
	   6 )
		   temp_dir_rm
		   ;;
	   7 )
		   echo -e " ${ERR} Exiting. Thanks for using\n\t\t-Schism"
		   exit 1 ;;
	   * )
		   echo -e " ${ERR} Invalid option."
		   pause
		   ;;
   esac
done
}

main


