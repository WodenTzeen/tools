#!/bin/bash
#
###########
# Dev by  : W0d3n
# Date    : August 2017
###########
#
# This script is for made a automatic MegaRaid configuration whatever the kind of Raid level and number of disk

# == Auxilary function ==

# == Menu section ==
function banner_Main {
	echo -e "============ MegaRaid AutoConfig ===========\n=    Dev by Woden     ver 1.0     =\n============================================\n"
}

function banner_listDisk
{
	echo -e "============ MegaRaid AutoConfig ===========\n=    Dev by Woden     ver 1.0     =\n============================================\n============ Liste disque & raid ===========\n\n"
}

function banner_createRaid
{
	echo -e "============ MegaRaid AutoConfig ===========\n=    Dev by Woden     ver 1.0     =\n============================================\n============= Création de raid ============\n\n"
}

function banner_delRaid
{
	echo -e "============ MegaRaid AutoConfig ===========\n=    Dev by Woden     ver 1.0     =\n============================================\n============ Suppression de raid ===========\n\n"
}

function menu_Main
{
	echo -e "Que souhaitez-vous faire ?\n	1.Lister\n	2.Créer un raid\n	3.Supprimer un raid\n	4.Quitter\n"
	echo -n "Choix : " && read menu_MainChoice 
}


# == Auxilary primary function ==

function listDisk
{
	clear
	local listDisk_display && local listDisk_srvCount && local listDisk_cnt
	
	listDisk_cnt=1
	
	while true; do
		case $listDisk_cnt in
			1)
				while true; do
					local listDisk_srvCount && listDisk_srvCount=0
					while true; do
						banner_createRaid
						echo -e "	Veuillez indiquer l'ip du serveur sur lequel vous souhaitez effectuer l'action.\n"
						echo -n "Réponse : " && read srvName
						if [[ "echo $(srvName | grep "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}")" ]]; then break
						else
							echo "Mauvaise ip, recommencez" && pause
						fi
					done
					srvList[$listDisk_srvCount]=$(echo $srvName)
					echo -e "Voulez-vous ajouter un aure serveur ?\n"
					echo -n "Réponse : " && read ynAnswer
								
					if yes_no; then
						((listDisk_srvCount++)) | return 0
						else break
					fi
				done
				((listDisk_cnt++))
				;;
			2)
				clear
				banner_listDisk
				for i in (seq 0 $listDisk_srvCount); do
					echo -e "\n"
					echo ${srvList[i]} 
					echo "Voici les informations demandées :\n"
					ssh -y root@${srvList[i]}
					echo -e "$i\n############\n"
					MegaCli -PdList -aALL | egrep "Slot|Device ID";
					MegaCli -LDInfo -Lall -aALL | egrep "Virtual|RAID|Size";
				done
				;;
					
		esac
		pause
	done
}

function createRaid
{
	clear
	
	local createRaid_raidLevel && local createRaid_cnt && local createRaid_srvCount
	createRaid_cnt=1
	
	while true; do
		case $createRaid_cnt in
			1)
				while true; do
					local createRaid_srvCount=0
					while true; do
						banner_createRaid
						echo -e "	Veuillez indiquer l'ip du serveur sur lequel vous souhaitez effectuer l'action.\n"
						echo -n "Réponse : " && read srvName
						if [[ "echo $(srvName | grep "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}")" ]]; then break
						else
							echo "Mauvaise ip, recommencez" && pause
						fi
					done
					srvList[$createRaid_srvCount]=$(echo $srvName)
					echo -e "Voulez-vous ajouter un aure serveur ?\n"
					echo -n "Réponse : " && read ynAnswer
								
					if yes_no; then
						((createRaid_srvCount++)) | return 0
						else break
					fi
				done
				((createRaid_cnt++))
				;;
			2)
				clear
				banner_createRaid
				while true; do
					while true; do
						echo -e "	Veuillez indiquer le nombre de VD : "
						echo -n "Réponse : " && read nbrVD
						if [[ "echo $(createRaid_nbrVD | grep "^[0-9]")" ]]; then break
						else 
							echo "Mauvaise valeur, recommencez" && pause
						fi
					done
				done
				((createRaid_cnt++))
				;;
			3)
				clear
				banner_createRaid
				while true; do
					for i in `seq 0 $nbrVD`; do
						while true; do
							echo -e "	Quel niveau de raid souhaitez-vous pour le VD'$i' (choix : 0, 1, 3, 5, 6 , 10, 50, 60, 100) :\n"
							echo -n "Réponse :" && read raidLevel
							createRaid_raidLevel[i]=$(echo $raidLevel)
							if [[ "echo $(raidLevel | grep "^[0-6]{1,3}")" ]]; then break
							else 
								echo "Mauvaise valeur, recommencez." && pause
							fi
						done
					done
				done
				((createRaid_cnt++))
				;;
			4)
				clear
				banner_createRaid
				for i in `seq 0 $createRaid_srvCount`; do
					echo -e "\n Affichage des informations disque du ${srvList[i]} "
					echo "Voici les informations demandées :\n"
					ssh -y root@${srvList[i]}
					echo -e "\n############\n"
					MegaCli -PdList -aALL | egrep "Slot|Device ID";
					enclosur=$(MegaCli -PdList -aALL | grep "ID" | awk '{print $4}' | uniq)
					slot=$(MegaCli -PdList -aALL | grep "Slot" | awk '{print $3}'| uniq)
					nbSlot=$(echo $slot | wc -l)
					echo -e "\n############\n"
					echo -e ""
				done
				
				;;
			
		esac
	done
}

function delRaid
{
	clear
	local delRaid_cnt && local delRaid_display && local delRaid_srvCount
	
	delRaid_cnt=1
	
	while true; do
		case $delDisk_cnt in
			1)
				while true; do
					local delRaid_srvCount=0
					while true; do
						banner_createRaid
						echo -e "	Veuillez indiquer l'ip du serveur sur lequel vous souhaitez effectuer l'action.\n"
						echo -n "Réponse : " && read srvName
						if [[ "echo $(srvName | grep "^[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}.[0-9]{1,3}")" ]]; then break
						else
							echo "Mauvaise ip, recommencez" && pause
						fi
					done
					srvList[$delRaid_srvCount]=$(echo $srvName)
					echo -e "Voulez-vous ajouter un aure serveur ?\n"
					echo -n "Réponse : " && read ynAnswer
								
					if yes_no; then
						((delRaid_srvCount++)) | return 0
						else break
					fi
				done
				((delRaid_cnt++))
				;;
			2)
				clear
				banner_delRaid
				for i in (seq 0 $delRaid_srvCount); do
					echo -e "\n"
					echo ${srvList[i]} 
					echo "Voici les informations demandées :\n"
					ssh -y root@${srvList[i]}
					echo -e "$i\n############\n"
					MegaCli -CfgLDDel -L0 -a0
				done
				break
				;;
		esac
		pause
	done
}

function pause
# This function is the bash like "system pause"'s C function
{
	echo -n 'Appuyez sur une touche pour continuer…' && read a
}

function yes_no
#This function is for the yes-no question 
{
	while true ; do
		#echo -n 'Voulez-vous continuer ? (y/N) : '
		read ynAnswer
		if [ $reponse = "y" ] || [ $reponse = "Y" ]; then 
			echo 'Okey ! '
			pause
			return 0
		fi
		if [ $reponse = "n" ] || [ $reponse = "N" ]; then 
			echo 'Retour au menu précédent'
			pause
			clear
			return 1
		fi
	done
}

#Main function

clear
banner_Main
menu_Main

while true; do
	case $menu_MainChoice in
		0) 
			clear
			banner_Main
			menu_Main
			;;
		1)
			listDisk
			;;
		2)
			createRaid
			;;
		3)
			delRaid
			;;
		4)
			echo "Bye !"
			break
			;;
		*)
			echo "Mauvais choix, recommencez !"
			pause
			menu_MainChoice=0
			clear
			;;
	esac
done


