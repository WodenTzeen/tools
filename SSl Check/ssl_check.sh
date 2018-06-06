#!/bin/bash
#
#######################
#
# Dev bye : W0d3n
# Date : March 2018
#
#######################
#
# == Auxilary function ==
# == Menu & banner section ==
function menu_help
{
	echo "Utilisation du script :"
	echo -e "\t-s, --site					: site pour le check SSL"
	echo -e "\t-h, --help 					: affiche ce message."
	echo -e "\t-v, --version 				: affiche la version du script"
}
# == Auxilary main fuction section ==
function ssl_check
{
	openssl s_client -showcerts -connect "$SITE":443 >> "$SITE"_$(date +%Y%m%d).txt
	echo "== SSL Check du domaine $SITE au $(date +%Y-%m-%d) ==" >> SSL_score_$SITE_$(date +%Y%m%d).txt
	proto_support
	key_exchange
	cypher_strength
	ssl_score=$((($proto_value+$key_score+$cypher_scrore)/3))
	ssl_note
	echo "La note du certificat SSL est : $ssl_value" >> SSL_score_$(date +%Y%m%d).txt
	echo -e "La note du protocol est : $prot_score\nLe protocol utilisé est : $proto" >> SSL_score_$(date +%Y%m%d).txt
	echo -e "La note de la clef est : $key_score\nLa clef public est codé en : $key_value bits" >> SSL_score_$(date +%Y%m%d).txt
	echo -e "La note du cypher est : $cypher_score\nLe cypher utilisé est : $cypher" >> SSL_score_$(date +%Y%m%d).txt
}

function proto_support
{
	proto=$(grep "Protocol" $2_$(date +%Y%m%d).txt)
	#proto_wc=$(echo $proto | awk '{print}' | wc -c)
	#if [[ $proto -gt 3 ]]; then
	#	proto_value_tmp=0
	#	for i in `seq 3 $proto_wc`;
	#	do
	#		proto_tab[i]=$(echo $proto | awk '{print $i}')
	#		case $proto[i] in
	#			SSLv2.0 )
	#				proto_value=0;
	#				;;
	#			SSLv3.0 )
	#				proto_value=80;
	#				;;
	#			TLSv1.0 )
	#				proto_value=90;
	#				;;
	#			TLSv1.1 )
	#				proto_value=95;
	#				;;
	#			TLSv2.0 )
	#				proto_value=100;
	#				;;
	#		esac
#
	#		proto_value_tmp=$("$proto_value+$proto_value_tmp" | bc -l)
	#	done
	#else
		proto=$(echo $proto | awk '{print $3}')
		proto_value
	#fi
}

function proto_value
{
	case $proto in
		SSLv2.0 )
			proto_score=0;
			;;
		SSLv3.0 )
			proto_score=80;
			;;
		TLSv1.0 )
			proto_score=90;
			;;
		TLSv1.1 )
			proto_score=95;
			;;
		TLSv2.0 )
			proto_score=100;
			;;
	esac
}

function key_exchange
{
	wc_count=$(grep "public key" $2_$(date +%Y%m%d).txt | grep -Eo "[0-9]" | wc -l)
	key_value=$(grep "public key" $2_$(date +%Y%m%d).txt | grep -Eo "[0-9]{$wc_count}")
	OUT=$?
	if [[ $key_value -gt 512 ]]; then
		key_score=20
	elif [[ $key_value -gt 512 ]] || [[ $key_value -lt 1024 ]]; then
		key_score=40
	elif [[ $key_value -gt 1024 ]] || [[ $key_value -lt 2048 ]]; then
		key_score=80
	elif [[ $key_value -gt 2048 ]] || [[ $key_value -lt 4096 ]]; then
		key_score=90
	elif [[ $key_value -ge 4096 ]]; then
		key_score=100
	elif [[ $OUT -eq 0 ]]; then
		key_score=0
	fi
}

function cypher_strength
{
	cypher=$(grep "Cipher" $2_$(date +%Y%m%d).txt | tail -1 | awk '{print $3}')
	cypher_value=$(echo $cypher | awk -F "-" '{print $5}' | grep -Eo "[0-9]{3}")
	if [[ $cypher_value -eq "0" ]]; then
		cypher_scrore=0
	elif [[ $cypher_value -gt 0 ]] || [[ $cypher_value -lt 128 ]]; then
		cypher_scrore=20
	elif [[ $cypher_value -gt 128 ]] || [[ $cypher_value -lt 256 ]]; then
		cypher_scrore=80
	elif [[ $cypher_value -ge 256 ]]; then
		cypher_scrore=100
	fi
}

function ssl_note
{
	if [[ $ssl_score -gt 20 ]]; then
		ssl_value="F"
	elif [[ $ssl_score -ge 20 ]] || [[ $ssl_score -lt 35 ]]; then
		ssl_value="E"
	elif [[ $ssl_score -ge 35 ]] || [[ $ssl_score -lt 50 ]]; then
		ssl_value="D"
	elif [[ $ssl_score -ge 50 ]] || [[ $ssl_score -lt 65 ]]; then
		ssl_value="C"
	elif [[ $ssl_score -ge 65 ]] || [[ $ssl_score -lt 80 ]]; then
		ssl_value="B"
	elif [[ $ssl_score -ge 80 ]] || [[ $ssl_score -lt 90 ]]; then
		ssl_value="A"
	elif [[ $ssl_score -ge 90 ]]; then
		ssl_value="A+"
	fi	
}
# == Main function ==
if [[ $# -eq 0 ]]; then
	menu_help
fi

OPTS=$(getopt -o hvs -l help,version,site -n 'parse-options' -- "$@")
if [[ $? != 0 ]]; then
	echo "Voici les commandes autorisées."
	menu_help
	exit 1	
fi

eval set -- "$OPTS"

while true ; do
	case "$1" in
		"-h" | "--help" )
			menu_help;
			shift
			;;

		"-v" | "--version" )
			echo "Version 1.0 Beta"
			shift
			;;

		"-s" | "--site")
			SITE=$2
			ssl_check;
			exit 0
			;;

		"--" )
			shift;
			break
			;;

		*)
			break
			;;
	esac
done

exit 0