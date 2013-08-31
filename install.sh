#!/bin/bash

# Script to install utilities
# Author: Márk Sági-Kazár (sagikazarmark@gmail.com)
# This script install all or specific utilities
#
# Version: 1.0

DIR=$(cd `dirname $0` && pwd)
path="${path:-/usr/bin}"
BUILD=${BUILD:-0}

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

## Set path
setpath()
{
	[ -z "$1" ] || path="$1"

	if [ -d $path -a -w $path ]; then
		e "Path is set to $path"
	else
		ee "Please specify a valid and writable path"
	fi
}

# Checking root access
if [ $EUID -ne 0 ]; then
	e "You are not running this script as root!" 31
fi


while getopts p:b option; do
	case "${option}" in
		p )
			setpath ${OPTARG}
			;;
		b )
			BUILD=1
			;;
	esac
done

shift $((OPTIND-1))


if [[ -z "$scripts" && $BUILD -eq 0 ]]; then
	e "Installing all scripts"
	scripts=("$DIR/scripts"/*)
else
	IFS=' ' read -a scripts <<< "${scripts}"
fi


if [ $BUILD -eq 1 ]; then
	e "Compiling all scripts"
	BUILD="#!/bin/bash\n\n# Compiled script from several utilities.\n# Path: $path\n# Date: $(date +"%Y-%m-%d %H:%M:%S")\n"

	for script in "${scripts[@]}"; do
		script=`basename $script`
		if [[ -f "$DIR/scripts/$script" && -s "$DIR/scripts/$script" ]]; then
			e "\nCompiling $script"
			BUILD="$BUILD\n\n$script()\n{\n"

			while read line; do
				if [[ "$line" == \#* || "$line" == "" ]]; then
					continue
				fi

				line="${line//exit/return}"
				BUILD="$BUILD$line\n"
			done < "$DIR/scripts/$script"
			BUILD="$BUILD}"

			e "$script compiled" 32
		else
			e "\nScript $script not found or empty" 31
		fi
	done

	echo -e "$BUILD" > "$path/utilities.sh"

	if [ ! -x "$path/utilities.sh" ]; then
		e "\nAdding execute permission to $path/utilities.sh"
		chmod +x "$path/utilities.sh" || e "Cannot add execute permission to $path/utilities.sh" 31
	fi

	grep -R "[ -f $path/utilities.sh ] && source $path/utilities.sh" /etc/bash.bashrc &> /dev/null
	[ $? -eq 0 ] || echo -e "[ -f $path/utilities.sh ] && source $path/utilities.sh" >> /etc/bash.bashrc


	e "\nCompilation done." 32
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
			e "\nScript $script not found" 31
		fi
	done
	e "\nInstallation done." 32
fi
