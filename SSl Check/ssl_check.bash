#!/bin/bash
#######################
#
# Dev bye : W0d3n
# Date : March 2018
#
#######################
# == Auxilary function ==
# == Menu & banner section ==
function menu_help(){
	echo "Utilisation du script :"
	echo -e "\t-h, --help                : affiche ce message."
	echo -e "\t-v, --version             : affiche la version du script"
}
# == Auxilary main fuction section ==
# == Main function ==
if [ $# -eq 0 ]; then
	menu_help
fi

OPTS=$( getopt -o h v -l help,version )
if [ $? != 0 ]; then
	exit 1	
fi

eval set -- "$OPTS"

while true ; do
	case "$1" in
		-h --help)
			menu_help
			exit 0
			;;

		-v --version)
			echo "Version 1.0 Beta"
			;;

		--)
			shift
			break
			;;
	esac
done

exit 0