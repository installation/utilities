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

## Exit error
ee()
{
	local exit_code="${2:-1}"
	local color="${3:-31}"

	e "$1" "$color"
	exit $exit_code
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
			BUILD=""
			;;
	esac
done

path="${path:-/usr/bin}"
build=${build:-0}

if [ -d $path -a -w $path ]; then
	e "Path is set to $path"
else
	ee "Please specify a valid and writable path"
fi


shift $((OPTIND-1))

if [ -z "$scripts" ]; then
	e "Installing all scripts"
	scripts=("$DIR/scripts"/*)
else
	IFS=' ' read -a scripts <<< "${scripts}"
fi


if [ $build -eq 1 ]; then
	BUILD="#!/bin/bash\n\n# Compiled script from several utilities.\n# Path: $path\n# Date: $(date +"%Y-%m-%d %H:%M:%S")\n"

	for script in "${scripts[@]}"; do
		script=`basename $script`
		if [[ -f "$DIR/scripts/$script" && -s "$DIR/scripts/$script" ]]; then
			e "\nCompiling $script"
			BUILD="$BUILD\n\n$script()\n{\n"

			while read line; do
				if [[ $line == \#* || $line == "" ]]; then
					continue
				fi

				line="${line//exit//return}"
				BUILD="$BUILD$line\n"
			done < "$DIR/scripts/$script"
			BUILD="$BUILD}"

			e "$script compiled" 32
		else
			ee "\nScript $script not found or empty" 2
		fi
	done

	echo -e "$BUILD" > "$path/utilities"
	echo -e "[ -f $path/utilities ] && source $path/utilities" >> /etc/bash.bashrc

	e "Compilation done." 32
else
	for script in "${scripts[@]}"; do
		script=`basename $script`
		if [[ -f "$DIR/scripts/$script" && -s "$DIR/scripts/$script" ]]; then
			e "\nInstalling $script"
			cp -r "$DIR/scripts/$script" "$path" || e "Installing $script failed" 31

			if [ ! -x "$path/$script" ]; then
				e "Adding execute permission to $script"
				chmod +x "$script" || e "Cannot add execute permission to $script" 31
			fi
			e "$script installed" 32
		else
			ee "\nScript $script not found" 2
		fi
	done
fi
