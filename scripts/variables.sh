#!bin/bash


pega_root="/opt/pega"
kit_root="${pega_root}/kit"
scripts_root="${kit_root}/scripts"
lib_root="${pega_root}/lib"
config_root="${pega_root}/config"
secret_root="${pega_root}/secrets"


db_username_file="${secret_root}/DB_USERNAME"
db_password_file="${secret_root}/DB_PASSWORD"

setupDatabase_properties="${config_root}/setupDatabase.properties"
prconfig="${config_root}/prconfig.xml"
prlog4j2="${config_root}/prlog4j2.xml"
prbootstrap="${config_root}/prbootstrap.properties"

postgres_conf="${config_root}/postgres.conf"
mssql_conf="${config_root}/mssql.conf"
oracledate_conf="${config_root}/oracledate.conf"
db2zos_conf="${config_root}/db2zos.conf"
udb_conf="${config_root}/udb.conf"

generate_config="${scripts_root}/generateConfig.sh"

install="install.sh"
migrate="migrate.sh"
upgrade="upgrade.sh"


