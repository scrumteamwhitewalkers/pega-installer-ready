#!/bin/bash

source /opt/pega/kit/scripts/pre_post_upgrade_utils.sh

do_post_upgrade_actions() {

  construct_prpc_utils_command
 
  echo "================ Running $ACTION ===================="

  echo "Installed pega code set version: $engine_codeset_version"

  isClusterUpgrading="false"
  isPatchUpgradeInProgress="false"
  prpcUtilsCommand rulesSchema $TARGET_RULES_SCHEMA

  construct_dass_settings_json

  set_dass_settings
}
