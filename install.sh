#!/bin/bash

# Script to install utilities
# Author: Márk Sági-Kazár (sagikazarmark@gmail.com)
# This script install all or specific utilities
#
# Version: 1.0

while [ getopts p: option ]; do
	case "${option}" in
		p )
			echo ${OPTARG}
			;;
	esac
done
