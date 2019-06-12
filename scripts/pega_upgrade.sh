migrate="migrate.sh"
upgrade="upgrade.sh"

upgradeBanner()
{
echo " ____                    _   _                           _       "
echo "|  _ \ ___  __ _  __ _  | | | |_ __   __ _ _ __ __ _  __| | ___  "
echo "| |_) / _ \/ _  |/ _  | | | | |  _ \ / _  |  __/ _  |/ _  |/ _ \ "
echo "|  __/  __/ (_| | (_| | | |_| | |_) | (_| | | | (_| | (_| |  __/ "
echo "|_|   \___|\__  |\__ _|  \___/|  __/ \__  |_|  \__ _|\__ _|\___| "
echo "           |___/              |_|    |___/                       "
echo " ";
}

upgradeCommand() {
  if [ "$2" != "" ]; then
    upgrade="$upgrade --$1 $2"
  else
    echo $1 "cannot be blank to perform upgrade"
  fi
}

in_place() {
	cd $scripts_root
	sh $upgrade
}

out_of_place() {

	BOOLEAN_TRUE="true"
	BOOLEAN_FALSE="false"
	
	# RULES_MIGRATION
	rules_migrate="$migrate"

	cd $scripts_root
	dockerizeBeforeRulesMigrate &&
	runRulesMigrate &&
	dockerizeBeforeRulesUpgrade &&
	# RULES_UPGRADE
	runRulesUpgrade &&
	dockerizeBeforeGenerateSchemaObjects &&
	# GENERATE_SCHEMA_OBJECTS
	sh $migrate &&
	# UPGRADE DATA ONLY
	sh $upgrade
}

execute_upgrade() {
    upgradeBanner

    if [ "$ACTION" == 'upgrade' ] && [ "$UPGRADE_TYPE" == 'in-place' ]; then
    # IN_PLACE_UPGRADE	
	    in_place
    elif { [ "$ACTION" == 'upgrade' ] || [ "$ACTION" == 'upgrade-deploy' ] ;} && [ "$UPGRADE_TYPE" == 'out-of-place' ]; then
    # OUT_OF_PLACE_UPGRADE
	    out_of_place
    else
	 echo "Invalid action " $ACTION " or upgrade_type " $UPGRADE_TYPE " passed.";
     exit 1;
    fi
}

runRulesMigrate(){
shopt -s nocasematch
	if [ "$SKIP_RULES_MIGRATE" == 'true' ]; then
	 echo "Skipping Rules Migration since SKIP_RULES_MIGRATE is set to true"
	else
	 sh $rules_migrate
	fi
shopt -u nocasematch
}

runRulesUpgrade(){
shopt -s nocasematch
	if [ "$SKIP_RULES_UPGRADE" == 'true' ]; then
	 echo "Skipping Rules Upgrade since SKIP_RULES_UPGRADE is set to true"
	else
	 sh $upgrade
	fi
shopt -u nocasematch
}

dockerizeBeforeRulesUpgrade() {
	export RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export DATA_SCHEMA=$TARGET_RULES_SCHEMA;
	export CUSTOMERDATA_SCHEMA=$TARGET_RULES_SCHEMA;
	dockerizePrconfig
	dockerizePrbootstrap
	dockerizeSetupdatabase
}

dockerizeBeforeRulesMigrate() {
	export TARGET_RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export TARGET_DATA_SCHEMA=$TARGET_RULES_SCHEMA;
	export TARGET_CUSTOMERDATA_SCHEMA=$TARGET_RULES_SCHEMA;
	export MOVE_ADMIN_TABLE=$BOOLEAN_TRUE;
	export CLONE_GENERATE_XML=$BOOLEAN_TRUE;
	export CLONE_CREATE_DDL=$BOOLEAN_TRUE;
	export CLONE_APPLY_DDL=$BOOLEAN_TRUE;
	export BULKMOVER_UNLOAD_DB=$BOOLEAN_TRUE;
	export BULKMOVER_LOAD_DB=$BOOLEAN_TRUE;
	export RULES_OBJECTS_GENERATE=$BOOLEAN_FALSE;
	export RULES_OBJECTS_APPLY=$BOOLEAN_FALSE;
	dockerizeMigrateSystemProperties
}

setBeforeGenerateSchemaObject() {
	export RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export DATA_SCHEMA=$ACTUAL_DATA_SCHEMA;
	export CUSTOMERDATA_SCHEMA=$ACTUAL_CUSTOMERDATA_SCHEMA;
	dockerizePrconfig
	dockerizePrbootstrap
	dockerizeSetupdatabase
}

dockerizeBeforeGenerateSchemaObjects() {
	setBeforeGenerateSchemaObject
	export TARGET_RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export TARGET_DATA_SCHEMA=$DATA_SCHEMA;
	export TARGET_CUSTOMERDATA_SCHEMA=$CUSTOMERDATA_SCHEMA;
	export MOVE_ADMIN_TABLE=$BOOLEAN_FALSE;
	export CLONE_GENERATE_XML=$BOOLEAN_FALSE;
	export CLONE_CREATE_DDL=$BOOLEAN_FALSE;
	export CLONE_APPLY_DDL=$BOOLEAN_FALSE;
	export BULKMOVER_UNLOAD_DB=$BOOLEAN_FALSE;
	export BULKMOVER_LOAD_DB=$BOOLEAN_FALSE;
	export RULES_OBJECTS_GENERATE=$BOOLEAN_TRUE;
	export RULES_OBJECTS_APPLY=$BOOLEAN_TRUE;
	dockerizeMigrateSystemProperties
}
