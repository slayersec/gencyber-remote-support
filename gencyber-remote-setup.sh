#!/bin/bash

# GenCyber Configuration Shell 0.2
# Author: Daniel Saylor
# git clone https://github.com/slayersec/GenCyber2021
# Usage: sudo ./gencyber-setup.sh

finduser=$(logname)
connectid=""
password=""

check_for_root () {
	if [ "$EUID" -ne 0 ]
	 then echo -e "\n\n Script must be run with sudo ./gencyber-setup.sh or as root \n"
	 exit
	fi
	}

check_distro() {
   	distro=$(cat /etc/os-release | grep -i -c "Raspbian GNU/Linux") # distro check
	if [ $distro -ne 2 ]
	 then echo -e "\n Sorry I only work on Raspbian GNU/Linux \n"; exit  # false
	fi
	}

install_tools() {
	apt update	
	apt -y install wireshark
	apt -y install gedit
	echo "Operation completed!"
	}

install_teamviewer() {
	echo -e "Stopping any teamviewerd service if it exists, ignore any error here "        
	systemctl disable teamviewerd 
        systemctl stop teamviewerd 
     	wget https://download.teamviewer.com/download/linux/teamviewer-host_armhf.deb -O /tmp/teamviewer-host_armhf.deb
	dpkg -i /tmp/teamviewer-host_armhf.deb 
	apt --fix-broken install
        systemctl enable teamviewerd
        systemctl start teamviewerd
	echo Setting random password...
	sleep 2
	eval /usr/bin/teamviewer passwd "$password"
	rm -f /tmp/teamviewer-host_armhf.deb
	}


generate_password() {
	#Generate a random string to use as a password.
	#This password is not a secure method of generation and is only meant for temporary use.
	#Do not share this password with anyone other then campus staff.
	chars=abcdefghijklmnopqrstuvwxyz123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ
	symbolsonly=!@$*
	password+=${symbolsonly:RANDOM%${#symbolsonly}:1}
	for i in {1..7} ; do
		password+=${chars:RANDOM%${#chars}:1}
	done
	password+=${symbolsonly:RANDOM%${#symbolsonly}:1}
	echo $password
	}

display_connect_info() {
	#Retrieves connection information for students
	connectid=$(cat /etc/teamviewer/global.conf | grep -i "ClientID" | cut -d " " -f4)
        echo -e "      Your Teamviewer ID: $connectid \nYour Teamviewer Password: $password"
	echo -e "      Your Teamviewer ID: $connectid \nYour Teamviewer Password: $password" > /home/$finduser/.stegolab_teamviewer
	chown $finduser:$finduser /home/$finduser/.stegolab_teamviewer
	}

configure_quick_help() {
	#quickly display connect information when "getHelp" is typed into console
	check_user_bashrc=$(cat /home/$finduser/.bashrc | grep -c gethelp)
	if [ $check_user_bashrc -ne 0 ] 	
	 then
	  echo "The command 'gethelp' can be entered at any time to retrieve connection information."
	 else
	  echo "alias gethelp='cat /home/$finduser/.stegolab_teamviewer'" >> /home/$finduser/.bashrc
	  chown $finduser:$finduser /home/$finduser/.bashrc
	  echo "You can use gethelp on the command line to display this information."
	fi	
	}
			



check_for_root
check_distro
install_tools
generate_password
install_teamviewer
display_connect_info
configure_quick_help

