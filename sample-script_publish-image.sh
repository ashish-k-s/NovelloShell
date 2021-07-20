TOWER_HOST=https://tower.engineering.redhat.com
TOWER_OAUTH_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
TOWER_TOKEN=xxxxxxxxxxxxxxxxxxxxxxxxxx
JOBID=7056
if [ $# -lt 2 ] 
then 
	echo -e "Invalid number of arguments"
	exit 1
fi
PROJECT=$1
IMAGE=$2
echo -e "Running tower job to publish $IMAGE ..."
cmd="awx -k --conf.host $TOWER_HOST --conf.token $TOWER_TOKEN job_templates launch $JOBID  --extra_vars '{project_id: $PROJECT,  image_name: $IMAGE}'  --monitor -f human"
eval $cmd > /dev/null 2>&1
#eval $cmd

