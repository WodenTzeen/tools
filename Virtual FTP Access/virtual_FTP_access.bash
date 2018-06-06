#!/bin/bash
#######################
#
# Dev bye : W0d3n
# Date : January 2018
#
#######################

# Packet needed :
# db6.0-util
# vsftpd

# == Auxilary function ==

# == Menu & banner section ==

function banner_Main {
	echo -e "============ Virtual FTP Access ===========\n=       Dev by Woden       ver 1.0        =\n==========================================\n"
}

function menu_Main {
	echo -e "What do you want to do ?\n	1.Proceed to the access creation\n	2.Quit\n"
	echo -n "Choix : " && read menu_MainChoice 
}

# == Auxilary main fuction section ==

function pause
# This function is the bash like "system pause"'s C function
{
	local a
	echo -n 'Press any key to continue…' && read a
}

function ftpCreation {

	clear
	local ftpCreation_cnt

	ftpCreation_cnt=1

	while true; do
		case $ftpCreation_cnt in
			1 )
				banner_Main
				echo -e "= Config file section =\nThis is the actual FTP users :"
				ls -l /etc/vsftpd/vsftpd_user_conf/ | awk '{print $9}'
				echo -ne "\nWich one do you whant to copy ? : " && read user
				echo -n "What is the name of your new user ? : " && read new_user
				echo "Creation of the config file…"
				echo -e "guest_username={user}\nlocal_root=/home/{new_user}\nvirtual_use_local_prives=YES\nwrite_enable=NO" > /etc/vsftpd/vsftpd_user_conf/{new_user}
				echo -e "Done…\nThis is the configuration for the user : $new_user"
				cat /etc/vsftpd/vsftpd_user_conf/$new_user
				pause
				((ftpCreation_cnt++))
				;;

			2)
				clear
				banner_Main
				echo "= Password section ="
				echo -n "Enter the password for this user : " && read passwd
				if [ -e /etc/vsftpd/login.txt ]; then
					echo "Login file already exist…create a backup…"
					cp /etc/vsftpd/login.txt /etc/vsftpd/login.txt.bak
					echo "Done…"
					pause
				fi
				echo -e "{new_user}\n{mdp}" > /etc/vsftpd/login.txt
				echo -n "Push login into db file…"
				db6.0_load -T -t hash -f /etc/vsftpd/login.txt /etc/vsftpd/login.db
				echo -e "Done…\nDeleting login file…"
				rm /etc/vsftpd/login.txt
				echo "Done…"
				pause
				((ftpCreation_cnt++))
				;;

			3)
				clear
				banner_Main
				echo -e "= Home folder section =\nCreating the home folder for $new_user…"
				if [ -e /home/$new_user ]; then
					echo "Home folder for this user already exist…\nNothing to do"
				else
					mkdir /home/$new_user
				fi

				echo "Do you want to bind this folder to an other one ? "
				echo "Reply (y/n): " && read yN
				if [ $yN == 'y' ] || [ $yN == 'Y']; then
					echo "To wich folder do you want to bind ? "
					echo "Reply : " && read src_path
					echo "Currently binding folder…"
					mount --bind $src_path /home/new_user
					echo -e "Done…\nSetting in fstab…"
					echo "Do you want to add a comment ? "
					echo -n "Reply (y/n): " && read yes_no
					if [ $yes_no == 'y' ] || [ $yes_no == 'Y' ] ; then
						echo -n "Comment : " && read comment
						echo -e "# $comment\n$source_path /home/$new_user none bind 0\t0" >> /etc/fstab
					elif [ $yes_no == 'n'] || [ $yes_no == 'N' ]; then
						echo "Alright, nothing to do…"
				fi
				else
					echo "Alright, nothing to do…"

				break
				;;

		esac
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
			ftpCreation
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