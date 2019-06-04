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

migrateCommand () {
  if [ "$2" != "" ]; then
    migrate="$migrate --$1 $2"
  else
    echo $1 "cannot be blank to perform migration"
  fi
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

	BULKMOVER_DIRECTORY="$scripts_root/upgrade/mover"
	MIGRATE_TEMP_DIRECTORY="$scripts_root/upgrade/migrate"
	BOOLEAN_TRUE="true"
	BOOLEAN_FALSE="false"
	# MIGRATE COMMANDS
	migrateCommand sourceDriverClass $JDBC_CLASS     
	migrateCommand sourceDriverJAR $DRIVER_JAR_PATH
	migrateCommand sourceDbType $DB_TYPE
	migrateCommand sourceDbURL $JDBC_URL
	migrateCommand sourceDbUser $SECRET_DB_USERNAME       
	migrateCommand sourceDbPassword $SECRET_DB_PASSWORD 
	migrateCommand sourceRulesSchema $RULES_SCHEMA
	migrateCommand sourceDataSchema $DATA_SCHEMA
	migrateCommand sourceCustomerDataSchema $CUSTOMERDATA_SCHEMA
	migrateCommand targetDriverClass $JDBC_CLASS
	migrateCommand targetDriverJAR $DRIVER_JAR_PATH
	migrateCommand targetDbType $DB_TYPE
	migrateCommand targetDbURL $JDBC_URL
	migrateCommand targetDbUser $SECRET_DB_USERNAME       
	migrateCommand targetDbPassword $SECRET_DB_PASSWORD
	migrateCommand dbLoadCommitRate $MIGRATION_DB_LOAD_COMMIT_RATE 
	migrateCommand bulkMoverDirectory $BULKMOVER_DIRECTORY 
	migrateCommand migrateTempDirectory $MIGRATE_TEMP_DIRECTORY
	migrateCommand bypassUdfGeneration $BYPASS_UDF_GENERATION

	# RULES_MIGRATION
	rules_migrate="$migrate --sourceRulesSchema $RULES_SCHEMA --targetRulesSchema $TARGET_RULES_SCHEMA --targetDataSchema $TARGET_RULES_SCHEMA --targetCustomerDataSchema $TARGET_RULES_SCHEMA --moveAdminTable $BOOLEAN_TRUE --cloneGenerateXML $BOOLEAN_TRUE --cloneCreateDDL $BOOLEAN_TRUE --cloneApplyDDL $BOOLEAN_TRUE --bulkMoverUnloadDB $BOOLEAN_TRUE --bulkMoverLoadDB $BOOLEAN_TRUE --generateRuleObjects $BOOLEAN_FALSE --applyRuleObjects $BOOLEAN_FALSE --createSchemaIfAbsent $BOOLEAN_TRUE"

	# RULES_UPGRADE
	rules_upgrade="$upgrade --rulesSchema $TARGET_RULES_SCHEMA --dataSchema $TARGET_RULES_SCHEMA --customerDataSchema $TARGET_RULES_SCHEMA"

	# GENERATE_SCHEMA_OBJECTS
	generate_schema_objects="$migrate --targetRulesSchema $TARGET_RULES_SCHEMA --targetDataSchema $DATA_SCHEMA --targetCustomerDataSchema $CUSTOMERDATA_SCHEMA --moveAdminTable $BOOLEAN_FALSE --cloneGenerateXML $BOOLEAN_FALSE --cloneCreateDDL $BOOLEAN_FALSE --cloneApplyDDL $BOOLEAN_FALSE --bulkMoverUnloadDB $BOOLEAN_FALSE --bulkMoverLoadDB $BOOLEAN_FALSE --generateRuleObjects $BOOLEAN_TRUE --applyRuleObjects $BOOLEAN_TRUE"

	# UPGRADE_DATA_ONLY
	data_upgrade="$upgrade --rulesSchema $TARGET_RULES_SCHEMA --dataSchema $DATA_SCHEMA --customerDataSchema $CUSTOMERDATA_SCHEMA --dataOnly"
	
	cd $scripts_root
	runRulesMigrate &&
	setBeforeRulesUpgrade &&
	runRulesUpgrade &&
	setBeforeGenerateSchemaObject &&
	sh $generate_schema_objects &&
	sh $data_upgrade
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
	 sh $rules_upgrade
	fi
shopt -u nocasematch
}

setBeforeRulesUpgrade() {
	export RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export DATA_SCHEMA=$TARGET_RULES_SCHEMA;
	export CUSTOMERDATA_SCHEMA=$TARGET_RULES_SCHEMA;
	dockerizePrconfig
	dockerizePrbootstrap
}

setBeforeGenerateSchemaObject() {
	export RULES_SCHEMA=$TARGET_RULES_SCHEMA;
	export DATA_SCHEMA=$ACTUAL_DATA_SCHEMA;
	export CUSTOMERDATA_SCHEMA=$ACTUAL_CUSTOMERDATA_SCHEMA;
	dockerizePrconfig
	dockerizePrbootstrap
}
