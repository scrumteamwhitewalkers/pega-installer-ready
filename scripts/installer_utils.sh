#!/bin/bash

do_upgrade_pre_post_actions() {

  if [ "$ACTION" == 'pre-upgrade' ]; then
    source /opt/pega/kit/scripts/installer_pre_upgrade.sh
    do_pre_upgrade_actions
  elif [ "$ACTION" == 'post-upgrade' ]; then
    source /opt/pega/kit/scripts/installer_post_upgrade.sh
    do_post_upgrade_actions
  else
    echo "Invalid action " $ACTION " passed.";
  fi
  
}
