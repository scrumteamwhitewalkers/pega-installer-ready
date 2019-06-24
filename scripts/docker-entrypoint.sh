#!/bin/bash

#  Contains Commaon variables
source /scripts/variables.sh

#  Contains Common Funtion definitions
source /scripts/common_functions.sh

mount_files()
{

	# mount these files before mounting/dockerizing prconfig, prbootstrap, setupdatabase
	mount_log4j2
	mount_dbconf
}


dockerizeFiles()
{

	dockerizePrconfig
	dockerizePrbootstrap
	dockerizeSetupdatabase

}
execute()
{

	# Check action validation
	isActionValid


        if [ -z "$(ls -A /opt/pega/kit/scripts)" -a -z "$(ls -A /opt/pega/kit/archives)" -a -z "$(ls -A /opt/pega/kit/rules)" ]
        then	
	    # unzip distribution kit
	    unzipKit
	fi


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
	
	executeInner

}
execute

