#!/bin/bash

# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# #       N O T E S
# # 
# # #  arch.conf/loader/entires cp
#   #  switch out "schism" from extras.sh
# # #  set new_user_home_path ?
# # #  add variables to configs to indicate if already performed.


C_OFF='\e[0m'			# Text Reset
C_1='\e[0;32m'			# Green
C_2='\e[0;31m'			# Red
ERR="${C_2}==>${C_OFF}  "	# Error message prefix.
INFO="${C_1}==>${C_OFF}  "	# Non-Error message prefix.

remote_pull="https://raw.githubusercontent.com/0x1p2/scripts-sh/master"
host_nm="0x1p2-laptop"		# Hostname of the new installation
new_user="schism"		# Username for the new installation
dir_boot="/dev/sda1"		# /boot
dir_root="/dev/sda2"		# /
dir_home="/dev/sda4"		# /home
dir_efi="/boot"			# EFI partition
dotfile_name="dotfiles"
dotfile_name_full="${dotfile_name}.tgz"

configs_multilib=0; configs_locale=0; configs_local=0;
a_b="${C_2}unset${C_OFF}"; a_v="${C_2}unset${C_OFF}";
a_a="${C_2}unset${C_OFF}"; a_x="${C_2}unset${C_OFF}"; 
a_e="${C_2}unset${C_OFF}"; u_m="${C_2}unset${C_OFF}"; 
s_e="${C_2}unset${C_OFF}"; y_i="${C_2}unset${C_OFF}";
p_r="${C_2}unset${C_OFF}"; d_f="${C_2}unset${C_OFF}";
i_c_1="${C_2}unset${C_OFF}"; i_c_2="${C_2}unset${C_OFF}"; 
i_c_3="${C_2}unset${C_OFF}"; i_c_4="${C_2}unset${C_OFF}"; 

if [[ -f ./extras.sh ]]; then
  source ./extras.sh
 else
  echo -e "\n ${ERR}File ${C_1}extras.sh${C_OFF} is not found. Retreiving..."
  wget ${remote_pull}/extras.sh > /dev/null 2>&1
  if [[ -f ./extras.sh ]]; then
   chmod +x extras.sh
   chown root:root extras.sh
   echo -e " ${INFO}Retreived ${C_2}extra.sh${C_OFF}."
  else
   echo -e " ${ERR}Something happened....?"
  fi
  exit 1
fi
_
for((;;)); do
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
configs_mod=$((configs_multilib+configs_locale+configs_local+configs_boot))
if [[ ${configs_mod} -eq 4 ]]; then configs_mod="${C_1}4${C_OFF}"; fi
clear ; echo ""
echo -en "${INFO}Choose the module you would like to install:\n 
 ${ERR}c)  [${C_2}${configs_mod}${C_OFF} / ${C_1}4${C_OFF}] Set ${C_1}configuration${C_OFF}.
 ${ERR}b)  [${a_b}] Install Basics
 ${ERR}v)  [${a_v}] Install Video
 ${ERR}a)  [${a_a}] Install Audio
 ${ERR}x)  [${a_x}] Install Xorg
 ${ERR}e)  [${a_e}] Install Extras
 ${ERR}u)  [${u_m}] User Creation/Management
 ${ERR}s)  [${s_e}] Enable services
 ${ERR}y)  [${y_i}] Install ${C_2}yaourt${C_OFF} script to ${C_1}${new_user}${C_OFF}
 ${ERR}d)  [${d_f}] Install dotfiles: ${C_1}${dotfile_full_name}${C_OFF}
 ${ERR}r)  [${p_r}] Eject CD (Prepare for reboot)
 \n ${ERR}ex) ${C_1}Exit${C_OFF} application.
\n${INFO} Choice [by-character]: "
read kbd_event
case ${kbd_event} in
	c )
		install_configs ;;
	b )
		apps_basic ;;
	v )
		apps_video ;;
	a ) 
		apps_audio ;;
	x )
		apps_xorg ;;
	e )
		apps_extra ;;
	u )
		user_management ;;
	s )
		services_enable ;;
	y )
		script_yaourt ;;
	d )
		dotfile_install ;;
	r )
		prep_reboot ;;
	ex )
		echo -e "\n ${ERR}Exiting!\n"
		exit 0 ;;
	* )
		echo -e "\n ${ERR}Invalid option: ${C_2}${kbd_event}${C_OFF}." ;;
esac
pause
# # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # #
## # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # # 
done
