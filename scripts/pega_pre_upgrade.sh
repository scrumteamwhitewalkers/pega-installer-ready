do_pre_upgrade_actions()
{
     echo "No Pre-Upgrade action defined"
}

generateConfig() {
  
  generate_config_cmd="$generate_config $ACTION --resultFile result.properties"

  if [ "$ACTION" == 'pre-upgrade' ]; then
	generate_config_cmd="$generate_config_cmd --rulesSchema $RULES_SCHEMA"  
  fi

  sh $generate_config_cmd
  cat $scripts_root/result.properties
  
  source $scripts_root/result.properties
  # Initialize CODESET_VERSION to codeset version available in prdeploy.jar
  CODESET_VERSION=$prdeploy_codeset_version
}

executeInner() 
{
        generateConfig
	source /opt/pega/kit/scripts/installer_pre_upgrade.sh 2> /dev/null
	do_pre_upgrade_actions
}
