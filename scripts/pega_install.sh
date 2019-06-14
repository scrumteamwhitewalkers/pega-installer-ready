# This shell script files take cares of installing the pega platform
# Driver jar path , DB Username and DB password are passed as an arguments to install.sh command.
# Other installation parameters are picked up from setupDatabase.properties file.
install="install.sh"

installCommand ()
{
 if [ "$2" != "" ]; then
  install="$install --$1 $2"
 fi
}

executeInner() {
echo " ____                    ___           _        _ _           ";
echo "|  _ \ ___  __ _  __ _  |_ _|_ __  ___| |_ __ _| | | ___ _ __ ";
echo "| |_) / _ \/ _  |/ _  |  | ||  _ \/ __| __/ _  | | |/ _ \  __|";
echo "|  __/  __/ (_| | (_| |  | || | | \__ \ || (_| | | |  __/ |   ";
echo "|_|   \___|\__  |\__ _| |___|_| |_|___/\__\__ _|_|_|\___|_|   ";
echo "           |___/                                              ";
echo " "; 

# Mapping Docker environment variables to install.sh command line arguments

installCommand createSchemaIfAbsent true

cd $scripts_root
sh $install
}
