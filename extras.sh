#!/bin/bash
# Misc functions

# Created by: Ryan Ball (0x1p2 || schism)
# Date Created: 18 September 2015

pause() 
{
 echo ""
 read -n 1 -p "Press any key to continue..." temp
 echo ""
}

install_configs()
{
 clear && echo ""
 echo "${host_nm}" > /etc/hostname
 echo -en "\n${INFO}[${i_c_1}] Would you like to enable ${C_1}multilib${C_OFF}: "
 read kbd_event
 if [[ ${kbd_event,,} == "yes" || ${kbd_event,,} == "y" ]]; then
	i_c_1="${C_1}configured${C_OFF}"
	configs_multilib=1
	sed -i 's:\#\[multilib\]:\[multilib\]:g' /etc/pacman.conf
	ln_n=`cat /etc/pacman.conf | grep -in "\[multilib\]" | cut -d':' -f1`
	ln_n=$((ln_n+1))
	sed -i "${ln_n}s:.*:Include = /etc/pacman.d/mirrorlist:" /etc/pacman.conf
	echo -e " ${ERR}Updating mirrors to support multilib..."
	pacman -Syy > /dev/null 2>&1
	echo -e " ${INFO}Update complete!"
 fi

 echo -en "\n${INFO}[${i_c_2}] Would you like to set ${C_1}locale-gen${C_OFF} and ${C_1}locale.conf${C_OFF}: "
 read kbd_event
 if [[ ${kbd_event,,} == "yes" || ${kbd_event,,} == "y" ]]; then
	i_c_2="${C_1}configured${C_OFF}"
	configs_locale=1
	echo "LANG=en_US.UTF-8" > /etc/locale.conf
	echo -en " ${INFO}Contents of ${C_1}/etc/locale.conf${C_OFF}: "
	cat /etc/locale.conf
	sed -i 's:\#en_US.UTF-8:en_US.UTF-8:' /etc/locale.gen
	locale-gen > /dev/null 2>&1
 fi

 echo -en "\n${INFO}[${i_c_3}] Would you like to set ${C_1}Central${C_OFF} timzeone: "
 read kbd_event
 if [[ ${kbd_event,,} == "yes" || ${kbd_event,,} == "y" ]]; then
	i_c_3="${C_1}configured${C_OFF}"
	configs_local=1
	ln -s /usr/share/zoneinfo/US/Central /etc/localtime
	echo -en " ${INFO}${C_2}Link${C_OFF} made: "
	ls -l /etc/localtime | awk '{print $9 $10 $11}'
 fi

 echo -en "\n${INFO}[${i_c_4}] Setup ${C_2}bootloader${C_OFF}? "
 read kbd_event
 if [[ ${kbd_event,,} == "yes" || ${kbd_event,,} == "y" ]]; then
	i_c_4=="${C_1}configured${C_OFF}"
	configs_boot=1
	bootctl --path ${dir_efi} install
	echo -e "timeout 3\ndefault arch" > ${dir_efi}/loader/loader.conf
	echo -e "title\t\tArch Linux" > ${dir_efi}/loader/entries/arch.conf
	echo -e "linux\t\t/vmlinuz-linux" >> ${dir_efi}/loader/entries/arch.conf
	echo -e "initrd\t\t/intel-ucode.img" >> ${dir_efi}/loader/entries/arch.conf
	echo -e "initrd\t\t/initramfs-linux.img" >> ${dir_efi}/loader/entries/arch.conf
	echo -e "options\t\troot=${dir_root} rw" >> ${dir_efi}/loader/entries/arch.conf
 fi

 echo -e "\n ${ERR}Enabling ${C_2}sudo${C_OFF} for group ${C_1}wheel${C_OFF}."
 sed -i 's:\# \%wheel ALL=(ALL) ALL:\%wheel ALL=(ALL) ALL:g' /etc/sudoers
 echo -e " ${INFO}${C_1}SUDO${C_OFF} enabled."
}


apps_basic()
{
 a_b="${C_1} set ${C_OFF}"
 pacman -S vim dosfstools tmux git scrot --noconfirm
 pacman -S iw wpa_supplicant dialog openssh networkmanager ntp nmap vulscan --noconfirm
 pacman -S lm_sensors acpi fuse intel-ucode --noconfirm
 pacman -S terminus-font ttf-droid ttf-liberation ttf-dejavu ttf-linux-libertine
 echo -e "\n ${ERR}Disabling root login via ssh."
 sed -i 's:\#PermitRootLogin prohibit-password:PermitRootLogin no:g' /etc/ssh/sshd_config
 echo -e " ${INFO}SSHing with ${C_2}root${C_OFF} is disabled."
}


apps_video()
{
 a_v="${C_1} set ${C_OFF}"
 pacman -S bumblebee mesa xf86-video-intel lib32-mesa-libgl --noconfirm
 pacman -S nvidia lib32-nvidia-utils primus lib32-primus --noconfirm
}


apps_audio()
{
 a_a="${C_1} set ${C_OFF}"
 pacman -S alsa-firmware alsa-lib alsa-plugins alsa-tools alsa-utils alsaplayer --noconfirm
 pacman -S pulseaudio-alsa lib32-alsa-lib pulseaudio pavucontrol lib32-pulseaudio --noconfirm
}


apps_xorg()
{
 a_x="${C_1} set ${C_OFF}"
 pacman -S synaptics xorg xorg-xclock xterm xorg-server-utils xorg-apps xorg-xinit --noconfirm
}


apps_extra()
{
 a_e="${C_1} set ${C_OFF}"
 pacman -S vlc firefox hplip ncmpc mpc mpd --noconfirm
 pacman -S cups bspwm sxhkd conky weechat gmrun eog --noconfirm
}


user_management()
{
 u_m="${C_1} set ${C_OFF}"
 if [[ ! -d /home/${new_user} ]]; then
  echo -e " ${INFO}New ${C_2}root${C_OFF} password..."
  passwd
  useradd -m -s /bin/bash -g users ${new_user}
  echo -e " ${INFO}New ${C_2}${new_user}${C_OFF} password..."
  passwd ${new_user}
  gpasswd -a ${new_user} video
  gpasswd -a ${new_user} audio
  gpasswd -a ${new_user} bumblebee
  gpasswd -a ${new_user} wheel
  gpasswd -a mpd users
  gpasswd -a mpd audio
 fi
}


services_enable()
{
 s_e="${C_1} set ${C_OFF}"
 systemctl enable NetworkManager
 systemctl enable org.cups.cupsd.service
 systemctl enable sshd
 systemctl enable bumblebeed
}

script_yaourt()
{
 y_i="${C_1} set ${C_OFF}"
 echo -e "#!/bin/bash
 mkdir build
 cd build
 sudo pacman -S yajl    # this is a dependency for package-query
 
 wget ${remote_pull}/package-query-1.6.2.tar.gz
 tar xvzf package-query-1.6.2.tar.gz
 cd package-query-1.6.2
 makepkg -si
 cd ..
 
 wget ${remote_pull}/yaourt-1.6.tar.gz
 tar xvzf yaourt-1.6.tar.gz
 cd yaourt-1.6
 makepkg -si
 cd .. 
 yaourt -Sa google-chrome-dev turses hsetroot compton cdw --noconfirm
 yaourt -Sa steam skype rxvt-unicode-256xresources spotify --noconfirm" > /home/${new_user}/script.sh
 chmod +x /home/${new_user}/script.sh
 chown ${new_user}:users /home/${new_user}/script.sh
}

dotfile_install()
{
 d_f="${C_1} set ${C_OFF}"
 clear && echo ""
 echo -en "\n${INFO}Do you wish to pull ${C_1}dotfiles.tgz${C_OFF}: "
 read kbd_event
 if [[ ${kbd_event,,} == "yes" || ${kbd_event,,} == "y" ]]; then
  echo -en "\n ${INFO}Hostname/IP: ${C_2}"
  read rcvr
  echo -en " ${INFO}Username: ${C_1}"
  read usrnm
  echo -e "${INFO}Establishing connection..."
  echo -en "  ${ERR}"
  cd /home/${new_user}
  scp -q ${usrnm}@${rcvr}:/home/${usrnm}/${dotfile_name_full} .
  echo -e " ${INFO}Pull complete..."
  if [[ -f ${dotfile_name_full} ]]; then
   echo -e " ${ERR}Extracting files..."
   tar xzf ${dotfile_name_full} > /dev/null 2>&1
   echo -e " ${ERR}Correcting permissions..."
   chown ${new_user} ${dotfile_name} -R
   echo -e " ${ERR}Moving files to ${C_1}${new_user}${C_OFF}'s home..."
   mv ${dotfile_name}/* .
   mv ${dotfile_name}/.* .
   echo -e " ${ERR}Cleaning up directory..."
   rmdir ${dotfile_name}
   echo -e " ${INFO}Complete!"
  else
   echo -e " ${ERR}Something when wrong... ${C_2}${dotfile_name_full}${C_OFF} not found."
  fi
 fi
}


prep_reboot()
{
 p_r="${C_1} set ${C_OFF}"
 eject
}

