Script utilities
================

Script utilities to be used as system commands

## Usage

### Method one

Download specific scripts from the ````scripts```` directory to your path.

### Method two

* Clone this repository and run ````./install.sh [-p PATH] PARAMS````
* Clone this repository and run ````./build.sh [-p PATH] PARAMS````

Params can be:
* "*" or empty to include all scripts
* Scriptnames for specific scripts devided by spaces

Put ````source(PATH/utilities.sh)```` in your bash login script

````PATH```` is ````/usr/bin```` by default.