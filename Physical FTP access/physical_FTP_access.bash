#!/bin/bash
#######################
#
# Dev bye : W0d3n
# Date : March 2018
#
#######################

# Packet needed :
# 

# == Auxilary function ==

# == Menu & banner section ==

function banner_Main {
	echo -e "============ Physical FTP Access ===========\n=       Dev by Woden       ver 1.0        =\n==========================================\n"
}

function menu_Main {
	echo -e "What do you want to do ?\n	1.Proceed to the access creation\n	2.Quit\n"
	echo -n "Choice : " && read menu_MainChoice 
}

function menu_PhysicalFtp {

}

# == Auxilary main fuction section ==

function pause
# This function is the bash like "system pause"'s C function
{
	local a
	echo -n 'Press any key to continue…' && read a
}


function PhysicalFtp
{
	clear
	local PhysicalFtp_cnt

	PhysicalFtp=1

	while true ; do
		case PhysicalFtp_cnt in
			1 )
				while true ; do
					clear
					banner_Main
					echo -en "= User name section =\nEnter the name of the user : " && read user_name
					echo -e "Checking…"
					cat /etc/passwd | awk -F ":" '{print $1}' | grep $user_name
					OUT=$?
					if [[ $OUT -eq 0 ]]; then
						echo "User account already set, please enter an other one."
						break
					else
						echo -en "User currently unset, continue…\nAny comment ? :" && read comment
						echo -n "Do you whant to use a folder already created or not ? (y/N) :" && read yN
						if [[ $yN == y ]] || [[ $yN == Y ]]; then
							echo -n "Enter the folder path : " && read user_path
							if [ -e $user_path ]; then
								echo "Folder exist…Binding the user $user_name to $user_path."
								useradd -d $user_path -s /bin/false -c "$comment" $user_name
								echo -e "User $user_name have been created !\nNext step…"
							fi
						else 
							echo "Folder don't exist…creating default folder for this user…"
							useradd -m -s /bin/false -c "$comment" $user_name
							echo -e "User $user_name have been created !\nNext step…"
						fi
					fi
				done
				((PhysicalFtp_cnt++))
								
				;;
			2 )
				echo -en "\n= Password section =\nEnter the password for the user $user_name : " && read user_pswd
				echo "$user_name:$user_pswd" | chpasswd
				echo -e "Password for $user_name…done !\nNext step…"
				((PhysicalFtp_cnt++))
				;;
			3)
				echo -e "\n= Config SSHD section =\nCheck…"
				grep DenyUsers /etc/ssh/sshd_config | grep $user_name
				OUT=$?
				if [[ $OUT -eq 0 ]]; then
					echo -e "User already set !\nNext step…"
				else
					echo "Configuration for the user $user_name in DenyUsers…"
					# Currently checking to find how to do that
					echo "Configuration done !\nNext step…"
				fi
				((PhysicalFtp_cnt++))
				;;
			4)
				echo -en "\n= Htpasswd section =\nNginx or Apache installed ? (apache/nginx) : " && read web_server
				if [[ $web_server == apache ]]; then
					grep -r "RootDirectory"	/etc/apache2/site-enabled/* | grep $user_path
					OUT=$?
					if [[ $OUT -eq 0 ]]; then
						
					fi

				elif [[ $web_server == nginx ]]; then
					grep -r "RootDirectory" /etc/nginx/site-enabled/* | grep $user_path
					#statements
				fi
				
			*)
				
				;;
		esac

		clear
		menu_PhysicalFtp
	done
}

# == Main function ==

clear
banner_Main
menu_Main

while true; do
	case $menu_MainChoice in
		0 )
			clear
			banner_Main
			menu_Main
		1 )
			
			;;
		2 )
			echo 'See ya soon !'
			break
			;;
		*)
			echo 'Wrong choice ! Retry !'
			menu_MainChoice=0
			;;
	esac
done