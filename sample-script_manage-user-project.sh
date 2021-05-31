### SAMPLE script to embed ansible tower job for project and user creation

TOWER_HOST=https://tower.eng.example.com
TOWER_OAUTH_TOKEN=xxxxxxxxxxxxxxx
TOWER_TOKEN=xxxxxxxxxxxxxxx
JOBID=5695
if [ $# -ne 2 ] 
then 
	echo -e "Invalid number of arguments"
	exit 1
fi
ACTION=$1
LAB=$2
cmd="awx --conf.host $TOWER_HOST --conf.token $TOWER_TOKEN job_templates launch $JOBID  --extra_vars '{action: $ACTION, project_name: $LAB, project_users: $LAB}'  --monitor -f human"
if [[ "$ACTION" == "create" ]]
then
echo -e "Creating project and user for $LAB this may take a minute..."
fi
if [[ "$ACTION" == "delete" ]]
then
echo -e "Deleting project and user for $LAB this may take a minute..."
fi
eval $cmd > /dev/null 2>&1
#eval $cmd

