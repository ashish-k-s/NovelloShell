#!/bin/bash
# Copyright 2020, 2021 NovelloShell Author

# Licensed under the Apache License, Version 2.0 (the "License"); you may not
# use this file except in compliance with the License.  You may obtain a copy
# of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS, WITHOUT
# WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.  See the
# License for the specific language governing permissions and limitations under
# the License.

# Report Bugs: ashish.k.shah@gmail.com

PUBLICNETWORK=provider-network
ADMINRC="/export/novello/TESTING/do-not-use-this-rc"
WORKINGDIR="/export/novello/TESTING/PROJECTS"

USERNAME=$(whoami)
cd $WORKINGDIR

bold=`tput bold`
normal=`tput sgr0`

function PrintMenuOptions1
{
	clear
	echo -ne "\tNovelloShell - a quick and dirty substitute of ravshello for Novello
\t====================================================================\n
Lab environment options:
--------------------------
new - Launch a new lab
list - List launched labs
exit - Exit from NovelloShell

Enter your choice: " 
}

function PrintMenuOptions2
{
	clear
	echo -ne "\tNovelloShell - a quick and dirty substitute of ravshello for Novello
\t====================================================================\n
${bold}Using lab environment:\t $lab ${normal}
\n
Lab environment activities:
--------------------------
status - Show status of a lab
console - Show console access details

start - Start a lab
stop - Stop a lab
delete - Delete a lab

update - Update lab

shell - Shell for a lab

back - Go back to previous menu

exit - Exit from NovelloShell

Enter your choice: " 
}

function MenuOptionActions1
{
read choice
case "$choice" in
	'new')
		NewLab
		;;
	'list')
		ListLabs
		;;
	'exit')
		ExitNovelloShell
		;;
	*) 
		echo -e "Invalid option, hit Enter to try again."
		read p
		DisplayScreen1
		;;
esac
}

function MenuOptionActions2
{
read choice
case "$choice" in
	'start')
		StartLab
		;;
	'stop')
		StopLab
		;;
	'delete')
		DeleteLab
		;;
	'status')
		StatusLab
		;;
	'console')
		ShowConsole
		;;
	'update')
		UpdateLab
		;;
	'shell')
		LabShell
		;;
	'back')
		DisplayScreen1
		;;
	'exit')
		ExitNovelloShell
		;;
	*) 
		echo -e "Invalid option, hit Enter to try again."
		read p
		DisplayScreen2
		;;
esac
}

function PauseDisplayScreen1
{

	echo -e "Hit Enter to continue.."
	read p
	DisplayScreen1
}

function PauseDisplayScreen2
{

	echo -e "Hit Enter to continue.."
	read p
	DisplayScreen2
}

function StopLab
{
        SetUserCredentialsFor $lab
        echo -e "Suspending  $lab"
	openstack stack suspend $lab
	echo -e "All the VMs of $lab will be suspended in some time"
	PauseDisplayScreen2
}

function StartLab
{
        SetUserCredentialsFor $lab
        echo -e "Starting  $lab"
	openstack stack resume $lab
	echo -e "All the VMs of $lab will be resumed in some time"
	PauseDisplayScreen2
}

function StatusLab
{
	SetUserCredentialsFor $lab
	echo -e "Probing status of $lab"
	openstack server list
	PauseDisplayScreen2
}

function UpdateLab
{
        SetUserCredentialsFor $lab
        echo -e "Updating lab environment $lab"
	labdir=${lab//$USERNAME-/}
	labdir=$(echo $labdir | rev | cut -d '_' -f 2- | rev)
        openstack stack update -t $labdir/stack_user.yaml $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=xxx
	PauseDisplayScreen2
}

function ShowConsole
{
        SetUserCredentialsFor $lab
        echo -e "Probing console access details for $lab\n"
	for vm in `openstack server list -c Name -f value`
	do
		echo -ne "$vm \t"
		openstack console url show $vm -c url -f value
		echo -e "\n"
	done
	PauseDisplayScreen2
}

function ExitNovelloShell
{
	echo -e "Exiting NovelloShell"
	exit
}

function DisplayScreen1
{
	PrintMenuOptions1
	MenuOptionActions1
}

function DisplayScreen2
{
	PrintMenuOptions2
	MenuOptionActions2
}

function SetUserCredentialsFor
{
	lab=$1
        export OS_USERNAME=$lab
        export OS_PASSWORD=redhat
        export OS_PROJECT_NAME=$lab
}

function SetAdminCredentials
{
source $ADMINRC
}

function LaunchLabStack
{
	lab=$USERNAME-$1
	SetAdminCredentials
	appendno=0
	count=1
        runninglabs=$(openstack stack list | grep $lab | wc -l)
        if [ $runninglabs -gt 0 ]
        then
		runninglabnos=$(openstack stack list -c 'Stack Name' | grep $lab | tr -d '|' | tr -d '[:blank:]' | rev | cut -d '_' -f 1)
		while [ $appendno -eq 0 ]
		do
			if [[ $runninglabnos == *$count* ]]
			then
				count=$(( count + 1 ))
			else 
				appendno=$count
			fi
		done
	else
		appendno=$count
	fi
	
	lab="${lab}_${appendno}"
	echo -e "Stack name:  $lab"
	openstack project create $lab > /dev/null 2>&1
	openstack user create --password redhat --project $lab $lab > /dev/null 2>&1
	openstack role add --project $lab --user $lab _member_ > /dev/null 2>&1
	openstack role add --project $lab --user admin admin > /dev/null 2>&1
	openstack quota set --cores -1 --instances -1 --ram -1 $lab > /dev/null 2>&1

	SetUserCredentialsFor $lab
	
	openstack stack create -t $1/stack_user.yaml $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=xxx
	return
}

function ListLabs
{
echo -e "Checking list of your labs.."
SetAdminCredentials
openstack stack list -c 'Stack Name' -c 'Stack Status' -c 'Creation Time' | grep $USERNAME
SelectLab
echo -e "checking presence of $lab"
openstack stack list -c 'Stack Name' | tr -d '|' | tr -d '[:blank:]' | grep ^$lab$
if [ $? -ne 0 ]
then
	echo -e "Invalid lab"
	PauseDisplayScreen1
fi
DisplayScreen2
}

function SelectLab
{
	echo -e "===^===^===^===^===^===^===^===^===^===^===^===^==="
	echo -e "Select the name of lab environment from above list"
	echo -e "Enter '<' to go back to previous menu or 'x' to exit"
	bind 'set mark-directories off' > /dev/null 2>&1
	choice=""
	count=0
	while [[ $choice = "" ]]
	do
		read -e choice
		count=$(( count + 1))
		if [ $count -eq 5 ]
		then
			choice='<'
		fi
	done
	lab=$choice
	if [ $choice == '<' ]
	then
		DisplayScreen1
	fi
	if [ $choice == 'x' ]
	then
		ExitNovelloShell
	fi
	return
}

function NewLab
{
	clear
	echo -e "Launch a new lab environment"
	echo -e "============================"
	ls
	SelectLab
	if [ -d $choice ]
	then
		echo -e "Launching lab environment for $choice"
		LaunchLabStack $choice
		PauseDisplayScreen1
	fi
	echo -e "Ivalid option, hit Enter to try again"
	read p
	NewLab

}

function DeleteLab
{
echo -e "Are you sure you want to delete the lab environment for $lab ? (YES|NO)"
read confirm
if [[ $confirm != 'YES' ]]
then
	echo -e "Not deleting the lab environment"
	PauseDisplayScreen2
fi

echo -e "Deleting $lab"
SetUserCredentialsFor $lab
openstack stack delete $lab --wait --yes
if [ $? -eq 0 ]
then
	SetAdminCredentials
	openstack project delete $lab
	openstack user delete $lab
	echo -e "\nSuccessfully deleted the lab environment"
else
	echo -e "\nFailed to delete the lab environment"
fi
PauseDisplayScreen1
}

function LabShell
{
SetUserCredentialsFor $lab
openstack
DisplayScreen2
}

DisplayScreen1
 
