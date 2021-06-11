# Tasks performed by associated tower job:
# Execute command: openstack stack list
# Redirect command output in one file
# Accept all possible args for stack list command in the form of string
# Accept one more string as argument which can be used as filename to redirect output
# Copy the output file to remote host 
# This script will cat the file copied by tower job to get the output in exact same form 
# as the output provided by running command on console

TOWER_HOST=https://tower.engineering.redhat.com
TOWER_OAUTH_TOKEN=VoXDnTL6fMloFjYnAiXQYTesTXnEwO
TOWER_TOKEN=VoXDnTL6fMloFjYnAiXQYTesTXnEwO
JOBID=5942
if [[ $# -eq 0 ]]
then 
echo -e "insufficient arg"
exit 1
fi
file=$1
$(sudo -u toweruser rm /tmp/$file > /dev/null 2>&1)
shift
echo -e "Probing list of labs using tower job, this may take some time..."
if [[ $# -eq 0 ]]
then
	#echo -e "No args"
	#cmd="awx --conf.host $TOWER_HOST --conf.token $TOWER_TOKEN job_templates launch $JOBID  --monitor -f human"
	cmd="awx --conf.host $TOWER_HOST --conf.token $TOWER_TOKEN job_templates launch $JOBID  --extra_vars '{job_output_file: $file}'  --monitor -f human"
else
	arr=($@)
	for var in "$@"
	do
		if [[ $var == -* ]]
		then
			args="$args $var"
		else
			args="$args \"$var\""
		fi
	done

cmd="awx --conf.host $TOWER_HOST --conf.token $TOWER_TOKEN job_templates launch $JOBID  --extra_vars '{job_output_file: $file, stack_list_args: $args}'  --monitor -f human"
fi
eval $cmd > /dev/null 2>&1
#eval $cmd
cat /tmp/$file
