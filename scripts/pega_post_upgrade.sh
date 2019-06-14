do_post_upgrade_actions()
{
 echo "No Post-Upgrade action defined"
}

executeInner() 
{
	source /opt/pega/kit/scripts/installer_post_upgrade.sh 2> /dev/null
	do_post_upgrade_actions
}
