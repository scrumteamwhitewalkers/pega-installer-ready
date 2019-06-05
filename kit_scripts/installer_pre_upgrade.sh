#!/bin/bash

source /opt/pega/kit/scripts/pre_post_upgrade_utils.sh

do_pre_upgrade_actions() {

  construct_prpc_utils_command
 
  echo "================ Running $ACTION ===================="

  echo "Installed pega code set version: $engine_codeset_version"

  isClusterUpgrading="true"
  isPatchUpgradeInProgress=$is_patch_upgrade
  prpcUtilsCommand rulesSchema $RULES_SCHEMA
  prpcUtilsCommand pegaCodesetVersion $engine_codeset_version

  construct_dass_settings_json

  set_dass_settings
}
