#!/bin/bash
#
###########
# Dev by  : WodenTzeen
# Date    : Jan 2017
###########

# Auxilary function

function banner
{
	echo -e "============ Calcul SLA ===========\n=    Dev by Woden     ver 1.0     =\n===================================\n"
}

function menu
{
	echo -e "Sur quel produit voulez-vous appliquer la SLA ?\n	1. VPS\n	2. Serveur dédié\n	3. PCI\n	4. Quitter\n"
	echo -n "Réponse : " && read choice
}

function s_menusd
{
	echo -e "Sur quel type de SLA souhaitez-vous effectuer le calcul ?\n 	1. Network\n 	2. Intervention\n 	3. Menu précédent\n"
	echo -n "Réponse : " && read sd_choice
}

function s_menupci
{
	echo -e "Sur quel type de facturation l'instance est-elle configurée ?\n 	1. Mensuelle\n 	2. Horaire\n 	3. Menu précédent\n"
	echo -n "Réponse : " && read pci_choice
}

function check_sla
 {
 	# This function will check if the % of SLA is rigth
	echo -n "Actuellement, la SLA est fixé à $value%, est-ce correcte ? (y/N) :" && read yN

	while true ; do
		case $yN in
			0 )
				echo -n "Le pourcentage de SLA est-il correcte ? $value% (y/N) : " && read yN
				;;
			"y" | "Y" )
				echo "Merci de votre confirmation" && return 0
				;;
			"n" | "N" )
				while true ; do
					echo -n "Veuillez entrer le pourcentage de SLA : " && read value
					if [[ "$(echo $value | grep "^[ [:digit:] ]*$")" ]]; then
						echo "Nouveau pourcentage : $value%"
						return 0
					else
						echo "Mauvaise valeur, essayez encore."
					fi
				done
				
				return 0
				;;
			* )
				echo "Mauvais choix !"
				yN=0
				;;
		esac
	done
}

function check_time
{
	while true ; do
		if [[ $choice -eq 1 ]] || [[ $choice -eq 2 ]]; then 
			echo -n "Veuillez entrer le nombre d'heures d'indisponibilité : " && read temps
			if [[ "$(echo $temps | grep -E "^[1-9]{1,2}$")" ]]; then return 0
			else
				echo "Mauvaise valeur, essayez encore."
			fi
		elif [[ $choice -eq 3 ]]; then
			echo -n "Veuillez entrer le nombre de minutes d'indisponibilité : " && read temps
			if [[ "$(echo $temps | grep -E "^[1-9]{1,3}$")" ]]; then return 0
			else
				echo "Mauvaise valeur, essayez encore."
			fi
		fi
		#echo -n "Veuillez entrer le nombre d'heures d'indisponibilité : " && read temps
		
	done
}

function check_price
{
	while true ; do
		echo -n "Veuillez entrer prix de l'instance : " && read pci_price
		
		if [[ "$(echo $pci_price | grep -E "^[1-9]$")" ]]; then return 0
		else
			echo "Mauvaise valeur, essayez encore."
		fi
	done
}

function sla_vps
{
	clear
	# local variable declaration
	local pourcent && local calc && local result && local temps

	value=5

	echo "============ SLA VPS ==========="
	
	check_sla
	check_time

	if [[ $temps -gt 20 ]]; then
		echo 'Il faut ajouter un mois.'
	else
		# simple calcul
		pourcent=$(echo "$temps*$value" | bc -l)
		calc=$(echo "$pourcent/100" | bc -l)
		result=$(echo "30*$calc" | bc -l | cut -d '.' -f 1)
		echo "Il faut ajouter $result jours sur le serveur"
	fi
	if yes_no; then
		echo 'Okey ! ' | return 0
	else
		choice=0
	fi
	
}

function sla_sd
{
	clear

	local pourcent && local calc && local result && local value && local temps
	echo "============ SLA SD ==========="
	s_menusd

	while true ; do
		case $sd_choice in
			0 )
				s_menusd
				;;
			1 )
				clear
				value=5
				echo "====== SLA sur incident réseau ======"
				check_sla
				check_time
				
				if [[ $temps -gt 20 ]]; then
				echo 'Il faut ajouter un mois.'
				else
				# simple calcul
				pourcent=$(echo "$temps*$value" | bc -l)
				calc=$(echo "$pourcent/100" | bc -l)
				result=$(echo "30*$calc" | bc -l | cut -d '.' -f 1)
				echo "Il faut ajouter $result jours sur le serveur"
				fi
				pause

				if yes_no; then
					echo 'Okey ! ' | return 0
				else
					echo 'Retour au menu précédent' && sd_choice=0
				fi

				;;
			2 )
				clear
				value=5
				echo "====== SLA sur durée d'intervention ======"
				check_sla
				check_time
								
				if [[ $temps -le 3 ]]; then echo "Toujours dans la GTI, pas de SLA"
				elif [[ $temps -ge 17 ]]; then echo "Il faut ajouter un mois."
				else 
					if [[ $temps -gt 3 ]] || [[ $temps -lt 17 ]]; then
					# simple calcul
					pourcent=$(echo "$temps*$value" | bc -l)
					calc=$(echo "$pourcent/100" | bc -l)
					result=$(echo "30*$calc" | bc -l | cut -d '.' -f 1)
					echo "Il faut ajouter $result jours sur le serveur"
					fi
				fi
				pause

				if yes_no; then
					echo 'Okey ! ' | return 0
				else
					echo 'Retour au menu précédent' && sd_choice=0
				fi
				;;
			3 )
				echo 'Retour au menu précédent'
				pause
				choice=0
				clear
				return 1
				;;
			* )
				echo 'Wrong choice ! Try again !'
				pause
				sd_choice=0
				clear
				;;
		esac
	done
}

function sla_pci
{
	clear

	local pourcent && local calc && local result && local value && local pci_price && local temps
	echo "============ SLA PCI ==========="
	s_menupci

	while true ; do
		case $pci_choice in
			0 )
				s_menupci
				;;
			1 )
				# monthly billing
				clear
				echo "============ SLA PCI Monthly ==========="
				value=0.5
				check_sla
				check_price
				
				check_time
				

				if [[ $temps -le 3 ]]; then echo "Pas d'application de SLA, on est dans le temps garantie."
				elif [[ $temps -ge 200 ]]; then echo "Il faut ajouter un $pci_price€."
				else
					if [[ $temps -gt 3 ]] || [[ $temps -lt 200 ]]; then
						pourcent=$(echo "$temps*$value" | bc -l)
						calc=$(echo "$pourcent/100" | bc -l)
						result=$(echo "$pci_price*$calc" | bc -l )

						#this is for a good display
						tmp=$(echo "$result" | cut -d . -f1)
						if [[ $tmp -ge 100 ]]; then result=$(echo "$result" | cut -c-6)
						elif [[ $tmp -ge 10 ]] || [[ $tmp -lt 100 ]]; then result=$(echo "$result" | cut -c-5)
						else result=$(echo "$result" | cut -c-4)
						fi

						echo "Il faut créer un voucher de $result d'euros sur le projet client"
					fi
				fi

				if yes_no; then
					echo 'Okey ! ' | return 0
				else
					pci_choice=0
				fi
				;;
			2 )
				# hourly billing
				clear
				value=0.5
				check_sla
				check_price
				check_time
				
				if [[ $temps -le 3 ]]; then echo "Pas d'application de SLA, on est dans le temps garantie."
				else
					if [[ $temps -gt 3 ]]; then
						pourcent=$(echo "$temps*$value" | bc -l)
						calc=$(echo "$pourcent/100" | bc -l)
						result=$(echo "$pci_price*$calc" | bc -l )

						#this is for a good display
						tmp=$(echo "$result" | cut -d . -f1)
						if [[ $tmp -ge 100 ]]; then result=$(echo "$result" | cut -c-6)
						elif [[ $tmp -ge 10 ]] || [[ $tmp -lt 100 ]]; then result=$(echo "$result" | cut -c-5)
						else result=$(echo "$result" | cut -c-4)
						fi

						echo "Il faut créer un voucher de $result d'euros sur le projet client"
					fi
				fi

				#pause

				if yes_no; then
					echo 'Okey ! ' | return 0
				else
					pci_choice=0
				fi
				;;
			3 )
				echo 'Retour au menu précédent'
				pause
				choice=0
				clear
				return 1
				;;
			* )	
				echo 'Wrong choice ! Try again !'
				pause
				pci_choice=0
				clear
				;;
		esac
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
	local reponse
	while true ; do
		echo -n 'Voulez-vous continuer ? (y/N) : '
		read reponse
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

# Main function

clear
banner
menu

while true ; do
	case $choice in
		0)
			menu
			;;
		1)
			sla_vps
			;;
		2)
			sla_sd
			;;
		3)
			sla_pci
			;;
		4)
			echo 'Thanks and see ya soon !'
			break;;
		*)
			echo 'Wrong choice ! Try again !'
			pause
			choice=0
			clear
			;;
	esac

done
