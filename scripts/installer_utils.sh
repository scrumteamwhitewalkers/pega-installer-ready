#!/bin/bash

do_upgrade_pre_post_actions() {

  source /opt/pega/kit/scripts/pre_post_upgrade_utils.sh

  dockerizePrpcUtilsProperties

  if [ "$ACTION" == 'pre-upgrade' ]; then
    do_pre_upgrade_actions
  elif [ "$ACTION" == 'post-upgrade' ]; then
    do_post_upgrade_actions
  else
    echo "Invalid action " $ACTION " passed.";
  fi
  
}

# dockerize prpcutils.properties from template
dockerizePrpcUtilsProperties() {
    echo "Generating prpcutils.properties from templates."
    /bin/dockerize -template ${config_root}/prpcUtils.properties.tmpl:${scripts_root}/utils/prpcUtils.properties
}