do_post_upgrade_actions()
{
     echo "No Post-Upgrade action defined"
}

generateConfig()
{
  
  generate_config_cmd="$generate_config $ACTION --resultFile result.properties"
 
  sh $generate_config_cmd
  cat $scripts_root/result.properties
  
  source $scripts_root/result.properties
  # Initialize CODESET_VERSION to codeset version available in prdeploy.jar
  CODESET_VERSION=$prdeploy_codeset_version
  
}

executeInner() 
{
        generateConfig
	source /opt/pega/kit/scripts/installer_post_upgrade.sh 2> /dev/null
	do_post_upgrade_actions
}
