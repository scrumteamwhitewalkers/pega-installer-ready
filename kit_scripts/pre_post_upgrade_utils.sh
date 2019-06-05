#!/bin/bash
prpcUtils="utils/prpcUtils.sh updateDASS"

prpcUtilsCommand(){
  if [ "$2" != "" ]; then
  prpcUtils="$prpcUtils --$1 $2"
  else
    echo $1 "cannot be blank to run prpcUtils"
  fi
}

construct_prpc_utils_command() {
  # Construct prpcUtils command
  prpcUtilsCommand driverClass $JDBC_CLASS
  prpcUtilsCommand driverJAR $DRIVER_JAR_PATH
  prpcUtilsCommand dbType $DB_TYPE
  prpcUtilsCommand dbURL $JDBC_URL
  prpcUtilsCommand dbUser $SECRET_DB_USERNAME
  prpcUtilsCommand dbPassword $SECRET_DB_PASSWORD
}

construct_dass_settings_json() {
  # construct dass settings json file
  upgrade_dass_settings_file="$scripts_root/upgrade_dass_settings.json"
  eval "echo \"$(sed 's/"/\\"/g' $scripts_root/upgrade_dass_settings.json.tmpl)\"" > $upgrade_dass_settings_file
  echo "Dass settings file:"
  cat $upgrade_dass_settings_file
}

set_dass_settings() {
  # call prpcutils to set the dass
  prpcUtils_set_upgrade_dass="$prpcUtils --dataSchema $DATA_SCHEMA --customerDataSchema $CUSTOMERDATA_SCHEMA --dassFilePath $upgrade_dass_settings_file"
  cd $scripts_root
  echo $prpcUtils_set_upgrade_dass
  sh $prpcUtils_set_upgrade_dass
}
