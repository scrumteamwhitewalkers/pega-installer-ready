do_pre_upgrade_actions()
{
 echo "No Pre-Upgrade action defined"
}

executeInner() 
{
	source /opt/pega/kit/scripts/installer_pre_upgrade.sh 2> /dev/null
	do_pre_upgrade_actions
}
