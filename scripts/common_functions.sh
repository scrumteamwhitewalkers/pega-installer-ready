#!bin/bash


unzipKit(){
deleteFileAfterUnzip=false
#download if URI is provided
if [ "$KIT_URL" != "" ]; then
  deleteFileAfterUnzip=true
  buildname=$(basename $KIT_URL)
  if curl --output /dev/null --silent --head --fail $KIT_URL
  then
    echo "Downloading kit from url"
    curl -ksSL -o ${kit_root}/$buildname ${KIT_URL}
  else
    echo "Unable to download kit from url"
  fi
fi

#check the no of zip files
  no_of_zip_files=$(ls -lr ${kit_root}/*.zip 2> /dev/null| wc -l)
  if [ "$no_of_zip_files" == 0 ]
  then
	echo "The distribution kit is neither mounted nor downloaded through Kit url '"$KIT_URL"'. Please provide a valid distribution image"
	exit 1;
  elif [ "$no_of_zip_files" -gt 1 ]
  then
	echo "/opt/pega/kit folder should contain only one distribution image in zip format"
    exit 1     
  else
     unzip -o ${kit_root}/*.zip -d ${kit_root}
  fi

  #delete the file if URI is provided
  if $deleteFileAfterUnzip ; then
    echo "Deleting downloaded kit zip file."
    rm ${kit_root}/$buildname
  fi
}


# Build JDBC Driver jar path

constructJarPath(){

DRIVER_JAR_PATH=''

if [ "$JDBC_DRIVER_URI" != "" ]; then
  urls=$(echo $JDBC_DRIVER_URI | tr "," "\n")
  for url in $urls
    do
     echo "Downloading database driver: ${url}";
     jarfilename=$(basename $url)
     if curl --output /dev/null --silent --head --fail $url
     then
       curl -ksSL -o ${lib_root}/$jarfilename ${url}
     else
       echo "Could not download jar from ${url}"
       exit 1
     fi
    done
fi

# construct jar_path for the jars mounted in opt/pega/lib

for source_jar in ${lib_root}/*
do
    filename=$(basename "$source_jar")
    ext="${filename##*.}"
    if [ "$ext" = "jar" ]; then
       if [ -z $DRIVER_JAR_PATH ]; then
         DRIVER_JAR_PATH+="${lib_root}/${filename}"  
       else
         DRIVER_JAR_PATH+=":${lib_root}/${filename}"
       fi
    fi 
done

# This needs to be exported for dockerize to correctly replace JAR_PATH in template files
export DRIVER_JAR_PATH=$DRIVER_JAR_PATH
}

# Read Secrets
readSecrets() {
    if [ -e "$db_username_file" ]; then
        SECRET_DB_USERNAME=$(<${db_username_fil e})
    else
        SECRET_DB_USERNAME=${DB_USERNAME}
    fi

    if [ -e "$db_password_file" ]; then
        SECRET_DB_PASSWORD=$(<${db_password_file})
    else
        SECRET_DB_PASSWORD=${DB_PASSWORD}
    fi

    if { [ "$SECRET_DB_USERNAME" == "" ] || [ "$SECRET_DB_PASSWORD" == "" ] ;} && [ ! -e "$setupDatabase_properties" ]; then
        echo "DB_USERNAME and DB_PASSWORD must be specified.";
    exit 1
    fi
    # This needs to be exported for dockerize to correctly replace USERNAME, PASSWORD in template files
    export DB_USERNAME=$SECRET_DB_USERNAME
    export DB_PASSWORD=$SECRET_DB_PASSWORD
}

# Mount prlog4j2 provided
mount_log4j2() {
if [ -e "$prlog4j2" ]; then
    echo "Loading prlog4j2 from ${prlog4j2}...";
    cp "$prlog4j2" ${scripts_root}/config
else
    echo "No prlog4j2 was specified in ${prlog4j2}.  Using defaults."
fi
}

# Dockerize setupDatabase.properties from template
dockerizeSetupdatabase() {
  echo "Generating setupDatabase.properties from templates."
  /bin/dockerize -template ${config_root}/setupDatabase.properties.tmpl:${scripts_root}/setupDatabase.properties
}

# dockerize prconfig.xml from template
dockerizePrconfig() {
    echo "Generating prconfig.xml from templates."
    /bin/dockerize -template ${config_root}/prconfig.xml.tmpl:${scripts_root}/prconfig.xml
}

# dockerize prbootstrap.properties from template
dockerizePrbootstrap() {
    echo "Generating prbootstrap.properties from templates."
    /bin/dockerize -template ${config_root}/prbootstrap.properties.tmpl:${scripts_root}/prbootstrap.properties
}

# dockerize migrateSystem.properties from template
dockerizeMigrateSystemProperties() {
    echo "Generating migrateSystem.properties from templates."
    /bin/dockerize -template ${config_root}/migrateSystem.properties.tmpl:${scripts_root}/migrateSystem.properties
}

# Mount provided database conf files 
mount_dbconf() {
if [ -e "$mssql_conf" ] && [ "$DB_TYPE" == "mssql" ]; then
    echo "Loading mssql.conf from ${mssql_conf}...";
    cp "$mssql_conf" "${scripts_root}/config/mssql/mssql.conf"

elif [ -e "$postgres_conf" ] && [ "$DB_TYPE" == "postgres" ]; then
    echo "Loading postgres.conf from ${postgres_conf}...";
    cp "$postgres_conf" "${scripts_root}/config/postgres/postgres.conf"

elif [ -e "$oracledate_conf" ] && [ "$DB_TYPE" == "oracledate" ]; then
    echo "Loading oracledate.conf from ${oracledate_conf}...";
    cp "$oracledate_conf" "${scripts_root}/config/oracledate/oracledate.conf"

elif [ -e "$udb_conf" ] && [ "$DB_TYPE" == "udb" ]; then
    echo "Loading udb.conf from ${udb_conf}...";
    cp "$udb_conf" "${scripts_root}/config/udb/udb.conf"

elif [ -e "$db2zos_conf" ] && [ "$DB_TYPE" == "db2zos" ]; then
    echo "Loading db2zos.conf from ${db2zos_conf}...";
    cp "$db2zos_conf" "${scripts_root}/config/db2zos/db2zos.conf"
fi 
}



initializeSchemas() 
{
 if [ "$DATA_SCHEMA" == '' ]; then
    export DATA_SCHEMA=$RULES_SCHEMA
 fi
 if [ "$CUSTOMERDATA_SCHEMA" == '' ]; then
    export CUSTOMERDATA_SCHEMA=$DATA_SCHEMA
 fi
ACTUAL_RULES_SCHEMA=$RULES_SCHEMA;
ACTUAL_DATA_SCHEMA=$DATA_SCHEMA;
ACTUAL_CUSTOMERDATA_SCHEMA=$CUSTOMERDATA_SCHEMA;

}

isActionValid() {
 echo "Checking valid action"
 VALID_ACTIONS="install, upgrade, install-deploy, upgrade-deploy, pre-upgrade, post-upgrade"
 if [ -n "`echo $VALID_ACTIONS | xargs -d ","| xargs -n1| grep -e \"^$ACTION$\"`" ]; then
  echo "Action selected is '"$ACTION"'";
 else
  echo "Invalid action '"$ACTION"' passed.";
  echo "Valid actions are : " $VALID_ACTIONS;
  exit 1;
 fi
}
