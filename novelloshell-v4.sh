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

CONFIGFILE=".novelloshell.cfg"

if [ ! -f "$CONFIGFILE" ]
then 
echo -e "ERROR: $CONFIGFILE does not exist"
exit 1
fi

PUBLICNETWORK=$(grep PUBLICNETWORK $CONFIGFILE)
ADMINRC=$(grep ADMINRC $CONFIGFILE)
APPSDIR=$(grep APPSDIR $CONFIGFILE)
BPSDIR=$(grep BPSDIR $CONFIGFILE)
TAG=$(grep TAG $CONFIGFILE)
ADMINUSERSFILE=$(grep ADMINUSERSFILE $CONFIGFILE)
IMAGEFILESPATH=$(grep IMAGEFILESPATH $CONFIGFILE | grep -v ^#)
eval $PUBLICNETWORK
eval $ADMINRC
eval $APPSDIR
eval $BPSDIR
eval $TAG
eval $ADMINUSERSFILE
eval $IMAGEFILESPATH

USERNAME=$(whoami)

# Set the ADMINUSER flag if the user has administrative rights
grep $USERNAME $ADMINUSERSFILE
if [ $? -eq 0 ]
then
ADMINUSER=1
else 
ADMINUSER=0
fi

cd $BPSDIR

bold=`tput bold`
normal=`tput sgr0`

function PrintMenuOptions1
{
	clear
	echo -e "\tNovelloShell - Shell based tool for Ravello like functionality on OpenStack cloud
\t=================================================================================\n
${bold}User:\t $USERNAME ${normal}\n
Lab environment options:
--------------------------
new - Launch a new lab from blueprint
list - List launched labs"

if [ $ADMINUSER -eq 1 ]
then
echo -e "DELETE - Delete the lab environment blueprint"
echo -e "IMAGE - Upload images to Novello cluster"
fi

echo -ne "exit - Exit from NovelloShell

Enter your choice: " 
}

function PrintMenuOptions2
{
	clear
	echo -e "\tNovelloShell - Shell based tool for Ravello like functionality on OpenStack cloud
\t=================================================================================\n
${bold}User:\t $USERNAME ${normal}
${bold}Lab environment:\t $lab ${normal}
\n
Lab environment activities:
--------------------------
status - Show status of a lab
console - Show console access details

start - Start a lab
stop - Stop a lab
delete - Delete a lab

shell - Shell for a lab
"

if [ $ADMINUSER -eq 1 ]
then
echo -e "SAVE - Save the application as blueprint
EDIT - Edit the stack template of application 
       (need to run "UPDATE" for the changes to take effect)
UPDATE - Update lab environment with current heat template
"
fi

echo -ne "back - Go back to previous menu
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
	'DELETE')
		if [ $ADMINUSER -eq 1 ]
		then
		LabBlueprintDELETE
		else 
		echo -e "Administrative rights required for this function\nHit enter to continue"
		read p
		DisplayScreen1
		fi
		;;
        'IMAGE')
                if [ $ADMINUSER -eq 1 ]
                then
                UploadIMAGE
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
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
	'UPDATE')
                if [ $ADMINUSER -eq 1 ]
                then
		LabUPDATE
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
		DisplayScreen2
                fi
		;;
	'shell')
		LabShell
		;;
	'SAVE')
                if [ $ADMINUSER -eq 1 ]
                then
		LabSAVE
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
		DisplayScreen2
                fi
		;;
	'EDIT')
                if [ $ADMINUSER -eq 1 ]
                then
		LabEDIT
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
		DisplayScreen2
                fi
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

function LabEDIT
{
	labdir="${APPSDIR}/${lab}"
	stackfile="${labdir}/stack_user.yaml"
	vi $stackfile
	echo -e "Make sure to UPDATE the stack for changes to take effect"
	PauseDisplayScreen2
}

function LabSAVE
{
	SetUserCredentialsFor $lab
        read -p "Enter new Project name: " NEWLAB
        while [[ -d "$NEWLAB" ]]
        do
                echo -e "Project with provided name already exists"
                read -p "Enter new Project name: " NEWLAB 
        done
	if [[ $NEWLAB == "" ]]
	then
		PauseDisplayScreen2
	fi
	#mkdir $NEWLAB

	echo -e "Stopping all the servers in this lab..."
	# TODO: Do not stop the server which is already in stopped state
	# TODO: Check if stopping the server is really needed
	for i in `openstack server list -c Name -f value`
	do
		openstack server stop $i
	done

	echo -ne "Waiting for all the server to stop. "
	while [ -n "$(openstack server list -c Name -c Status -f value | grep -v SHUTOFF)" ]
	do
		echo -n " . "
		#sleep 5
	done
	echo -e " "
	openstack server list -c Name -c Status -f value

	OLDLAB=$(openstack stack list -c 'Stack Name' -f value)
	OLDLAB=$(echo $OLDLAB | cut -d '-' -f 2- | rev | cut -d '_' -f 2- | rev)
	echo -e "Cloaning current status of $lab to $NEWLAB"

	cp -r $APPSDIR/$lab $BPSDIR/$NEWLAB
	newstackfile="${BPSDIR}/${NEWLAB}/stack_user.yaml"
	OLDIFS=$(echo $IFS)
	IFS=$'\n'
	for i in $(openstack server list -c Name -c Image -f value)
	do
		echo $i
		servername=$(echo $i | awk '{print $1}')
		curimgname=$(echo $i | awk '{print $2}')
		newimgname=$(echo "${curimgname/$OLDLAB/$NEWLAB}")
		echo -e "Processing $servername with image $curimgname"
	        
		##Avoid cloaning common images
	        if [[ $curimgname =~ "pntaecommon" ]]
        	then 
	                echo -e "Skipping image $image"
        	        continue
	        fi

		echo -e "Creating new image: $newimgname"
		openstack server image create --name $newimgname $servername > /dev/null 2>&1
		sed -i "s/$curimgname/$newimgname/g" $newstackfile
	done

	echo -e "Waiting for 2 minutes for images to be active..."
	sleep 120

	echo -e "Setting new images public..."

	SetAdminCredentials

	for image in $(grep 'image:' $newstackfile)
	do
		image=$(echo $image | awk -F ':' '{print $2}' | tr -d '[:space:]' | tr -d '"')

                ##Avoid common images
                if [[ $image =~ "pntaecommon" ]]
                then
                        echo -e "Skipping image $image"
                        continue
                fi

		echo -e "Setting $image as public image"
		openstack image set --property visibility=public $image 
	done

	SetUserCredentialsFor $lab

	PauseDisplayScreen2
}

function LabUPDATE
{
        SetUserCredentialsFor $lab
        echo -e "Updating lab environment $lab"
	labdir="${APPSDIR}/${lab}"
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
	mkdir -p "${APPSDIR}/${lab}"
	cpsrc="${BPSDIR}/${1}/stack_user.yaml"
	cpdst="${APPSDIR}/${lab}"
	cp $cpsrc $cpdst
	stackfile="${APPSDIR}/${lab}/stack_user.yaml"
	echo -e "Stack name:  $lab"
	openstack project create $lab > /dev/null 2>&1
	openstack user create --password redhat --project $lab $lab > /dev/null 2>&1
	openstack role add --project $lab --user $lab _member_ > /dev/null 2>&1
	openstack role add --project $lab --user admin admin > /dev/null 2>&1
	openstack quota set --cores -1 --instances -1 --ram -1 $lab > /dev/null 2>&1

	SetUserCredentialsFor $lab
	
	openstack stack create -t $stackfile $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=xxx
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


function SelectImage
{
        echo -e "===^===^===^===^===^===^===^===^===^===^===^===^==="
        echo -e "Select the name of the images from above list"
        echo -e "Multiple images can be selected by seperating them with space"
        echo -e "Enter '<' to go back to previous menu or 'x' to exit"
        bind 'set mark-directories off' > /dev/null 2>&1
        choice=""
        count=0
        while [[ $choice = "" ]]
        do
                read -ea choice
                count=$(( count + 1))
                if [ $count -eq 5 ]
                then
                        choice='<'
                fi
        done
	ImageArrayReq=("${choice[@]}")
        if [[ $choice == '<' ]]
        then
                DisplayScreen1
        fi
        if [[ $choice == 'x' ]]
        then
                ExitNovelloShell
        fi
        return
}


function GetImageNameTypeFromFile
{
extn=$(echo $ImageFile | rev | cut -d '.' -f 1 | rev)
ImageName=$(echo $ImageFile | rev | cut -d '.' -f 2- | rev)
###echo -e "ImageName: $ImageName"
###echo -e "extn: $extn"
if [[ $extn == "img" || $extn == "raw" ]]
then
	ImageType="raw"
else 
	ImageType=$extn
fi
}

function UploadIMAGE
{
        clear
        echo -e "Upload the Image(s) in lab environment"
        echo -e "======================================"
	cd $IMAGEFILESPATH
        ls
        SelectImage
	SetAdminCredentials
	echo -ne "\nGettng list of available images . . . "
	ImageArrayAvail=($(openstack image list -c Name -f value))
	echo -e "done"
	###echo -e ${ImageArrayReq[@]}
	###echo -e ${ImageArrayReq[0]}
	for ImageFile in "${ImageArrayReq[@]}"
	do
		###echo $ImageFile
		###read p
		if [[ ! -f $ImageFile ]]
		then
			echo -e "$ImageFile does not exist, skipping..."
			continue
		fi
		GetImageNameTypeFromFile
		if [[ $ImageType != "raw" && $ImageType != "qcow2" && $ImageType != "iso" ]]
		then
			echo -e "Skipping $ImageFile of invalid image type: $ImageType"
			continue
		fi
		if [[ " ${ImageArrayAvail[@]} " =~ " ${ImageName} " ]]
		then
			echo -e "Image $ImageName already exists, skipping $ImageFile . . . "
		else 
			echo -ne "Image $ImageName does not exist, creating image . . . "
			openstack image create --disk-format $ImageType --container-format bare --public --file $ImageFile $ImageName
			echo -e "done"

		fi
	done
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

function LabBlueprintDELETE
{
	clear
	echo -e "Delete the lab environment blueprint"
	echo -e "===================================="
	cd $BPSDIR
	ls
	SelectLab
	if [ -d $choice ]
	then
		echo -e "Are you sure you want to delete the lab environment blueprint $choice ? (YES|NO)"
		read confirm
		if [[ $confirm != 'YES' ]]
		then
		        echo -e "Not deleting the lab environment blueprint"
		        PauseDisplayScreen1
		fi

		echo -e "All associated images will be permanently deleted. Do you want to proceed? (YES|NO)"
		read confirm
		if [[ $confirm != 'YES' ]]
		then
		        echo -e "Not deleting the lab environment blueprint"
		        PauseDisplayScreen1
		fi
		
		echo -e "Deleting the lab environment blueprint: $choice"
		LabDataDELETE $choice
		PauseDisplayScreen1
	fi
	echo -e "Ivalid option, hit Enter to try again"
	read p
	LabBlueprintDELETE
}

function LabDataDELETE
{
SetAdminCredentials
stackfile="$BPSDIR/$choice/stack_user.yaml"
OLDIFS=$(echo $IFS)
IFS=$'\n'
for image in $(grep 'image:' $stackfile)
do
        image=$(echo $image | awk -F ':' '{print $2}' | tr -d '[:space:]' | tr -d '"')
	##Avoid deleting common images
	if [[ $image =~ "pntaecommon" ]]
	then 
		echo -e "Skipping image $image"
		continue
	fi
        echo -e "Deleting image $image"
	
        openstack image delete $image
done
echo -e "Deleting heat template for $choice"
cmd="rm -rf $BPSDIR/$choice"
eval $cmd
if [ $? -ne 0 ]
then
	echo -e "FAILED"
fi
}

function NewLab
{
	clear
	echo -e "Launch a new lab environment"
	echo -e "============================"
	cd $BPSDIR
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
	echo -ne "Deleating associated files..."
	rm -rf "${APPSDIR}/${lab}"
	echo -e "done\n"
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
 
