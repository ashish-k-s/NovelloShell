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

function PrintMenuOptions
{
	clear
	echo -ne "\tNovelloShell - a quick and dirty substitute of ravshello for Novello
\t====================================================================\n
Lab environment activities:
--------------------------
1 - Launch a new lab
2 - Start a lab
3 - Stop a lab
4 - Delete a lab

5 - Show status of a lab
6 - Show console access details

7 - Update lab

s - Shell for a lab

x - Exit from NovelloShell

Enter your choice: " 
}

function MenuOptionActions
{
read choice
case "$choice" in
	1)
		LaunchLab
		;;
	2)
		StartLab
		;;
	3)
		StopLab
		;;
	4)
		DeleteLab
		;;
	5)
		StatusLab
		;;
	6)
		ShowConsole
		;;
	7)
		UpdateLab
		;;
	s)
		LabShell
		;;
	x)
		ExitNovelloShell
		;;
	*) 
		echo -e "Invalid option, hit Enter to try again."
		read p
		DisplayScreen1
		;;
esac
}

function PauseDisplayScreen1
{

	echo -e "Hit Enter to continue.."
	read p
	DisplayScreen1
}

function StopLab
{
        CheckListOfLabs
        SelectLab
        lab=$choice
        SetUserCredentialsFor $lab
        echo -e "Suspending  $lab"
	openstack stack suspend $lab
	echo -e "All the VMs of $lab will be suspended in some time"
	PauseDisplayScreen1
}

function StartLab
{
        CheckListOfLabs
        SelectLab
        lab=$choice
        SetUserCredentialsFor $lab
        echo -e "Starting  $lab"
	openstack stack resume $lab
	echo -e "All the VMs of $lab will be resumed in some time"
	PauseDisplayScreen1
}

function StatusLab
{
	CheckListOfLabs
	SelectLab
	lab=$choice
	SetUserCredentialsFor $lab
	echo -e "Probing status of $lab"
	openstack server list
	PauseDisplayScreen1
}

function UpdateLab
{
        CheckListOfLabs
        SelectLab
        lab=$choice
        SetUserCredentialsFor $lab
        echo -e "Updating lab environment $lab"
	labdir=${lab//$USERNAME-/}
	if [[ $(echo $labdir | rev | cut -d '-' -f 1 | rev) =~ ^n ]]
	then
		labdir=$(echo $labdir | rev | cut -d '-' -f 2- | rev)
	fi
        openstack stack update -t $labdir/stack_user.yaml $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=xxx
}

function ShowConsole
{
        CheckListOfLabs
        SelectLab
        lab=$choice
        SetUserCredentialsFor $lab
        echo -e "Probing console access details for $lab\n"
	for vm in `openstack server list -c Name -f value`
	do
		echo -ne "$vm \t"
		openstack console url show $vm -c url -f value
		echo -e "\n"
	done
	PauseDisplayScreen1
}

function ExitNovelloShell
{
	echo -e "Exiting NovelloShell"
	exit
}

function DisplayScreen1
{
	PrintMenuOptions
	MenuOptionActions
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
	runninglabs=$(openstack stack list | grep $lab | wc -l)
	if [ $runninglabs -gt 0 ]
	then
		no=$(( $runninglabs + 1 ))
		lab="$lab-n$no"
	fi
	openstack project create $lab
	openstack user create --password redhat --project $lab $lab
	openstack role add --project $lab --user $lab _member_
	openstack role add --project $lab --user admin admin
	openstack quota set --cores -1 --instances -1 --ram -1 $lab

	SetUserCredentialsFor $lab
	
	openstack stack create -t $1/stack_user.yaml $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=xxx
	return
}

function CheckListOfLabs
{
echo -e "Checking list of your labs.."
SetAdminCredentials
openstack stack list -c 'Stack Name' -c 'Stack Status' -c 'Creation Time' | grep $USERNAME
}

function SelectLab
{
	echo -e "================"
	echo -e "Select the name of lab environment"
	echo -e "Enter '<' to go back to previous menu or 'x' to exit"
	read -e choice
	if [ $choice == '<' ]
	then
		DisplayScreen1
	fi
	if [ $choice == 'x' ]
	then
		ExitNovelloShell
	fi
}

function LaunchLab
{
	clear
	echo -e "Launch a new lab environment"
	echo -e "============================"
	ls
	SelectLab
	if [ -d $choice ]
	then
		echo -e "Launching stack for $choice"
		LaunchLabStack $choice
		PauseDisplayScreen1
	fi
	echo -e "Ivalid option, hit Enter to try again"
	read p
	LaunchLab

}

function DeleteLab
{
CheckListOfLabs
SelectLab
lab=$choice
echo -e "Are you sure you want to delete the lab environment for $lab ? (YES|NO)"
read confirm
if [[ $confirm != 'YES' ]]
then
	echo -e "Not deleting the lab environment"
	PauseDisplayScreen1
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
CheckListOfLabs
SelectLab
lab=$choice
SetUserCredentialsFor $lab
openstack
DisplayScreen1
}

DisplayScreen1
