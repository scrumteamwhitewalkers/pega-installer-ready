#!/bin/bash

set -e

#  Contains Common variables
source /scripts/variables.sh

#  Contains Common funtion definitions
source /scripts/common_functions.sh

execute()
{
	unzipKit
	# intialize the jar path and secrets before mounting any config file
	constructJarPath
	readSecrets
	mount_files
	initializeSchemas
	dockerizeFiles

	if [ "$ACTION" == 'install' ] || [ "$ACTION" == 'install-deploy' ]; then
	  #------------------------INSTALL-------------------------------------
	  source /scripts/pega_install.sh
	elif [ "$ACTION" == 'upgrade' ] || [ "$ACTION" == 'upgrade-deploy' ]; then
	  #---------------------------UPGRADE----------------------------------
	  source /scripts/pega_upgrade.sh
	elif [ "$ACTION" == 'pre-upgrade' ] || [ "$ACTION" == 'post-upgrade' ]; then
	  source /scripts/pega_pre_post_upgrade.sh	
	else
	  echo "Invalid action " $ACTION " passed.";
	  exit 1;
	fi
	
	# Implementation for inner will be in one the included script based on $ACTION
	executeInner
}

# Execution begins here.
execute

