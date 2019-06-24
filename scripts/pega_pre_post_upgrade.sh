do_pre_upgrade_actions()
{
     echo "No Pre-Upgrade action defined"
}

do_post_upgrade_actions()
{
     echo "No Post-Upgrade action defined"
}

dockerizePrpcUtilsProperties()
{
    echo "Generating prpcutils.properties from templates."
    /bin/dockerize -template ${config_root}/prpcUtils.properties.tmpl:${scripts_root}/utils/prpcUtils.properties
}


generateConfig()
{ 
  generate_config_cmd="$generate_config $ACTION --resultFile result.properties"
      
  sh $generate_config_cmd
  
  cat $scripts_root/result.properties  
  source $scripts_root/result.properties
  
  # Initialize CODESET_VERSION and ENGINE_CODESET_VERSION
  export CODESET_VERSION=$prdeploy_codeset_version
  export ENGINE_CODESET_VERSION=$engine_codeset_version
  
   
  if [ "$ACTION" == 'post-upgrade' ]; then
      RULES_SCHEMA=$TARGET_RULES_SCHEMA 
  fi  
  
  dockerizePrpcUtilsProperties
}


executeInner() 
{
        generateConfig
	source /opt/pega/kit/scripts/pre_post_upgrade_utils.sh
	
	if [ "$ACTION" == 'pre-upgrade' ]; then
	    do_pre_upgrade_actions
        elif [ "$ACTION" == 'post-upgrade' ]; then
            do_post_upgrade_actions
        fi                        	    
}

