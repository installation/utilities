#!/bin/bash

# Script to install utilities
# Author: Márk Sági-Kazár (sagikazarmark@gmail.com)
# This script install all or specific utilities
#
# Version: 1.0

DIR=$(cd `dirname $0` && pwd)

# Echo colored text
e()
{
	local color="\033[${2:-34}m"
	echo -e "$color$1\033[0m"
}

# Checking root access
if [ $EUID -ne 0 ]; then
	e "You are not running this script as root!" 31
fi


while getopts p:b option; do
	case "${option}" in
		p )
			path=${OPTARG}
			;;
		b )
			build=1
			;;
	esac
done

path="${path:-/usr/bin}"
build=${build:-0}

if [ -d $path -a -w $path ]; then
	e "Path is set to $path"
else
	e "Please specify a valid and writable path" 31
	exit 1
fi


shift $((OPTIND-1))

if [ -z "$scripts" ]; then
	e "Installing all scripts"
	scripts=("$DIR/scripts"/*)
else
	IFS=' ' read -a scripts <<< "${scripts}"
fi

for script in "${scripts[@]}"; do
	script=`basename $script`
	if [ -f "$DIR/scripts/$script" ]; then
		e "\nInstalling $script"
		#cp -r "$DIR/scripts/$script" "$path" || e "Installing $script failed" 31

		if [ ! -x "$path/$script" ]; then
			e "Adding execute permission to $script"
			#chmod +x "$script" || e "Cannot add execute permission to $script" 31
		fi
		e "$script installed" 32
	fi
done