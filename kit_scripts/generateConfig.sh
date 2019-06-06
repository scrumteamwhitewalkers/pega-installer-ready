#!/bin/sh
# generateconfig sh script
#                          Copyright 2019  Pegasystems Inc.                           
#                                 All rights reserved.                                 
# This software has been provided pursuant to a License Agreement containing restrictions
# on its use. The software contains valuable trade secrets and proprietary information of
# Pegasystems Inc and is protected by federal copyright law.It may not be copied, modified,
# translated or distributed in any form or medium, disclosed to third parties or used in 
# any manner not provided for in  said License Agreement except with written
# authorization from Pegasystems Inc.


# Wrapper for the command line prpcUtils contained in prpcUtils.xml

usage() {

	echo "generateConfig.sh install | upgrade |install-deploy |upgrade-deploy |pre-upgrade |post-upgrade |help [options...]"
   	echo ""
	echo "Options:"
	echo "  --resultFile         The result file"
        exit 1
}

# shellcheck source=posixUtils.sh
. "$(dirname "$0")/posixUtils.sh"

CURRENT_SCRIPT=$(dirname "$0")

if [ -z "$JAVA_HOME" ] ; then
        echo "The JAVA_HOME environment variable must be defined."
        exit 1
fi

# get tool type (Install, Upgrade, etc.)
# tool type must coincide with an ant target in upgradeUtils.xml
TOOL_TYPE=""
case "$1"
in
        "install")              TOOL_TYPE="Install";;
        "install-deploy")       TOOL_TYPE="Install";;
        "upgrade")              TOOL_TYPE="Upgrade";;
        "upgrade-deploy")       TOOL_TYPE="Upgrade";;
        "pre-upgrade")          TOOL_TYPE="Pre-upgrade";;
        "post-upgrade")         TOOL_TYPE="Post-upgrade";;
        "--help")               usage;;
        *)                      echo "Unknown tool type $1"
                                usage;;
esac
shift


ANT_PROPS=""
while [ "$1" != "" ]
do
        case "$1"
        in
                "--resultFile") shift
                                 ANT_PROPS="$ANT_PROPS -Dresult.filepath=\"$(escape "$1")\"";;
                "--rulesSchema") shift
                                 ANT_PROPS="$ANT_PROPS -Drules.schema.name=\"$(escape "$1")\"";;
                "--help")        usage;;
                *)               echo "Unknown setting $1"
                                 usage;;
        esac
        shift
done

logfile=logs/CLI-GenerateConfig-log-$(date +'%h-%d-%Y-%H-%M-%S').log
mkdir -p logs
ANT_PROPS="$ANT_PROPS -Dprpc.util.action=$TOOL_TYPE"
# Run Ant, given the configuration we collected
run eval "\"$(dirname "$0")/bin/ant\"" "$ANT_PROPS" -f "\"$CURRENT_SCRIPT/upgradeUtils.xml\"" $TOOL_TYPE 2>&1 \| tee "$logfile"

if [ "$pipestatus_1" -ne 0 ] ; then
        echo "Ant Process returned a non 0 value"
        exit 1
	else
		exit 0
fi
