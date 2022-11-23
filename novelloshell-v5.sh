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

CONFIGFILE="/etc/novelloshell.cfg"

if [ ! -f "$CONFIGFILE" ]
then 
echo -e "ERROR: $CONFIGFILE does not exist"
exit 1
fi

PUBLICNETWORK=$(grep PUBLICNETWORK $CONFIGFILE  | grep -v ^#)
ADMINRC=$(grep ADMINRC $CONFIGFILE  | grep -v ^#)
APPSDIR=$(grep APPSDIR $CONFIGFILE  | grep -v ^#)
BPSDIR=$(grep BPSDIR $CONFIGFILE  | grep -v ^#)
TAG=$(grep TAG $CONFIGFILE  | grep -v ^#)
FAQURL=$(grep FAQURL $CONFIGFILE  | grep -v ^#)
MOTD=$(grep MOTD $CONFIGFILE  | grep -v ^#)
ADMINUSERSFILE=$(grep ADMINUSERSFILE $CONFIGFILE  | grep -v ^#)
IMAGEFILESPATH=$(grep IMAGEFILESPATH $CONFIGFILE | grep -v ^#)
STARTUPSCRIPTSPATH=$(grep STARTUPSCRIPTSPATH $CONFIGFILE | grep -v ^#)
WEBURL=$(grep WEBURL $CONFIGFILE | grep -v ^#)
ADMINACCESS=$(grep ADMINACCESS= $CONFIGFILE  | grep -v ^#)
DOMAIN=$(grep DOMAIN= $CONFIGFILE  | grep -v ^#)
ADMIN_USRROL_SCRIPT=$(grep ADMIN_USRROL_SCRIPT= $CONFIGFILE  | grep -v ^#)
ADMIN_STACK_SCRIPT=$(grep ADMIN_STACK_SCRIPT= $CONFIGFILE  | grep -v ^#)
ADMIN_PUBLISH_IMAGE_SCRIPT=$(grep ADMIN_PUBLISH_IMAGE_SCRIPT= $CONFIGFILE  | grep -v ^#)
CLISUFFIX=$(grep CLISUFFIX= $CONFIGFILE  | grep -v ^#)
CLUSTERNAME=$(grep CLUSTERNAME= $CONFIGFILE  | grep -v ^#)
PROJECTID=$(grep PROJECTID= $CONFIGFILE  | grep -v ^#)
MAXLABS=$(grep MAXLABS= $CONFIGFILE  | grep -v ^#)
LOGFILE=$(grep LOGFILE= $CONFIGFILE  | grep -v ^#)
STATSDIR=$(grep STATSDIR= $CONFIGFILE  | grep -v ^#)
KEYFILEPATH=$(grep KEYFILEPATH= $CONFIGFILE  | grep -v ^#)


eval $PUBLICNETWORK
eval $ADMINRC
eval $APPSDIR
eval $BPSDIR
eval $TAG
eval $FAQURL
eval $MOTD
eval $ADMINUSERSFILE
eval $IMAGEFILESPATH
eval $STARTUPSCRIPTSPATH
eval $WEBURL
typeset -l ADMINACCESS
eval $ADMINACCESS
eval $DOMAIN
eval $PROJECTID
eval $CLUSTERNAME
eval $MAXLABS
eval $LOGFILE
eval $STATSDIR
eval $KEYFILEPATH

REPORTFILE="ns-usage-stats.csv"
CSVSEP=";"

if [ -z "$CLUSTERNAME" ]
then
CLUSTERNAME="RHOS"
fi

if [ $ADMINACCESS == "no" ]
then
accesstype="non-admin"
echo -e "NovelloShell is running without admin rights"
eval $ADMIN_USRROL_SCRIPT
eval $ADMIN_STACK_SCRIPT
eval $ADMIN_PUBLISH_IMAGE_SCRIPT

echo $ADMIN_USRROL_SCRIPT
echo $ADMIN_STACK_SCRIPT

if [[ -x "$ADMIN_USRROL_SCRIPT" ]]
then
echo -e "NovelloShell will be using $ADMIN_USRROL_SCRIPT for user and role creation"
else
echo -e "File $ADMIN_USRROL_SCRIPT configured to be used for user and role creation does not exist or it is not executable"
exit 1
fi

if [[ -x "$ADMIN_STACK_SCRIPT" ]]
then
echo -e "NovelloShell will be using $ADMIN_STACK_SCRIPT for listing of all stacks"
else
echo -e "File $ADMIN_STK_SCRIPT configured to be used for listing of all stacks does not exist or it is not executable"
exit 1
fi

if [[ -x "$ADMIN_PUBLISH_IMAGE_SCRIPT" ]]
then
echo -e "NovelloShell will be using $ADMIN_PUBLISH_IMAGE_SCRIPT for publishing images"
else
echo -e "File $ADMIN_PUBLISH_IMAGE_SCRIPT configured to be used for publishing image does not exist or it is not executable"
exit 1
fi

else
accesstype="admin"
echo -e "NovelloShell is running with admin rights"
fi

#read p

eval $CLISUFFIX

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
italic=`tput sgr3`

## This function may need to be tweaked based on the requirements of the ADMIN_STACK_SCRIPT being called.
## ekg USERNAME argument passed here may or may not be needed based on the ADMIN_STACK_SCRIPT implementation.
function exec_admin_stack_script
{
#echo -e $ADMIN_STACK_SCRIPT
#echo -e $@
eval $ADMIN_STACK_SCRIPT $USERNAME $@
}

function exec_admin_usrrol_script
{
#echo -e $ADMIN_USRROL_SCRIPT
#echo -e $@
eval $ADMIN_USRROL_SCRIPT $@
}

function exec_admin_publish_image_script
{
#echo -e $ADMIN_PUBLISH_IMAGE_SCRIPT
#echo -e $@
WriteLog "exec_admin_publish_image_script"
eval $ADMIN_PUBLISH_IMAGE_SCRIPT $@
}

function PrintMenuOptions1
{
	clear
	echo -e "\tNovelloShell - Shell based tool for Ravello like functionality on OpenStack cloud
\t=================================================================================\n
NovelloShell access on ${bold} $CLUSTERNAME : $accesstype ${normal}
FAQs : $FAQURL
${bold}$(cat $MOTD)${normal} \n
${bold}User:\t $USERNAME ${normal}\n
Lab environment options:
--------------------------
new - Launch a new lab from blueprint
list - List your launched labs
connect - Connect to the lab environment"
if [ $ADMINUSER -eq 0 ]
then
echo -e "info - Read the information about the lab environment template"
fi
if [ $ADMINUSER -eq 1 ]
then
echo -e "INFO - Read or edit the information about the lab environment template"
echo -e ""
echo -e "BECOME - Use NovelloShell as other user"
echo -e ""
echo -e "BLUEPRINT - Manage blueprints on Novello cluster"
echo -e "IMAGE - Manage images on Novello cluster"
echo -e ""
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

start - Start VMs in the lab
stop - Stop VMs in the lab
delete - Delete a lab

toggle - Toggle boot sequence for a VM

"

if [ $ADMINUSER -eq 1 ]
then
echo -e "SHELL - Open Stack shell for the lab

EDIT - Edit the stack template of application 
       (need to run "UPDATE" for the changes to take effect)
UPDATE - Update lab environment with current heat template

SAVE - Save the application as blueprint
PUBLISH - Publish images within this project
"
fi

echo -ne "back - Go back to previous menu
exit - Exit from NovelloShell

Enter your choice: " 
}

function PrintBlueprintOptions
{
        clear
        echo -e "\tNovelloShell - Shell based tool for Ravello like functionality on OpenStack cloud
\t=================================================================================\n
NovelloShell access on ${bold} $CLUSTERNAME : $accesstype ${normal}
${bold}User:\t $USERNAME ${normal}\n
Blueprint management options:
-----------------------------"
echo -ne "CLONE - Clone a new lab from existing lab environment template
EDIT - Edit lab environment blueprint
RENAME - Rename an existing lab environment
DELETE - Delete lab environment blueprint

STARTUP - Edit startup scripts for the lab

back - Go back to previous menu
exit - Exit from NovelloShell

Enter your choice: "

}

function PrintImageOptions
{
        clear
        echo -ne "\tNovelloShell - Shell based tool for Ravello like functionality on OpenStack cloud
\t=================================================================================\n
NovelloShell access on ${bold} $CLUSTERNAME : $accesstype ${normal}
${bold}User:\t $USERNAME ${normal}\n
Image management options:
------------------------"
echo -ne "\nUpload - Upload image(s) to Novello cluster
Delete - Delete image from Novello cluster (just mark for deletion, can be retrieved)
Purge - Purge the image marked for deletion (permanent delete, no recovery possible)
Retrieve - Retrieve deleted image from Novello cluster
Show - Show details of image

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
	'info')
		LabInfo
		;;
	'INFO')
		LabInfo
		;;
        'connect')
                LabBlueprintConnect
                ;;
        'BECOME')
                if [ $ADMINUSER -eq 1 ]
                then
                BecomeUser
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
                ;;
        'BLUEPRINT')
                if [ $ADMINUSER -eq 1 ]
                then
                DisplayBlueprintScreen
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
                ;;
        'IMAGE')
                if [ $ADMINUSER -eq 1 ]
                then
                DisplayImageScreen
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

function MenuBlueprintActions
{
read choice
case "$choice" in
        'BLUEPRINT')
                if [ $ADMINUSER -eq 1 ]
                then
                DisplayBlueprintScreen
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
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
        'CLONE')
                if [ $ADMINUSER -eq 1 ]
                then
                LabBlueprintCLONE
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
                ;;
        'RENAME')
                if [ $ADMINUSER -eq 1 ]
                then
                LabBlueprintRENAME
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
                ;;

        'EDIT')
                if [ $ADMINUSER -eq 1 ]
                then
                LabBlueprintEDIT
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
                fi
                ;;
        'STARTUP')
                if [ $ADMINUSER -eq 1 ]
                then
                LabBlueprintSTARTUP
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
                DisplayScreen1
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
                DisplayBlueprintScreen
                ;;
esac
}

function MenuOptionActions2
{
read choice
case "$choice" in
	'start')
		StartLabVMs
		;;
	'stop')
		StopLabVMs
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
       'toggle')
               ToggleBoot
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
	'SHELL')
                if [ $ADMINUSER -eq 1 ]
                then
		LabSHELL
                else
                echo -e "Administrative rights required for this function\nHit enter to continue"
                read p
		DisplayScreen2
                fi
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
        'PUBLISH')
                if [ $ADMINUSER -eq 1 ]
                then
                LabImagePUBLISH
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

function MenuImageActions
{
read choice
case "$choice" in
        'Upload')
                UploadIMAGE
                ;;
        'Delete')
                DeleteIMAGE
                ;;
        'Purge')
                PurgeIMAGE
                ;;
        'Retrieve')
                RetrieveIMAGE
                ;;
        'Show')
                ShowIMAGE
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
                DisplayImageScreen
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

function PauseDisplayImageScreen
{

        echo -e "Hit Enter to continue.."
        read p
        DisplayImageScreen
}

function PauseDisplayBlueprintScreen
{

        echo -e "Hit Enter to continue.."
        read p
        DisplayBlueprintScreen
}

function StopLabVMs
{
	WriteLog "StopLabVMs $lab"
        SetUserCredentialsFor $lab
        echo -e "List of VMs in $lab"
	openstack $CLISUFFIX server list -c 'Name' -f value -c 'Status' -f value
	echo -e "Select VMs to be stopped from above list (provide space seperated list)"
	read line
	arr=($line)
	echo -e "Stopping ${#arr[@]} VM(s): ${arr[@]}"      
	openstack $CLISUFFIX server stop ${arr[@]} > /dev/null 2>&1
	PauseDisplayScreen2
}

function StartLabVMs
{
        WriteLog "StartLabVMs $lab"
        SetUserCredentialsFor $lab
        echo -e "List of VMs in $lab"
        openstack $CLISUFFIX server list -c 'Name' -f value -c 'Status' -f value
        echo -e "Select VMs to be started from above list (provide space seperated list)"
        read line
        arr=($line)
        echo -e "Starting ${#arr[@]} VM(s): ${arr[@]}"
        openstack $CLISUFFIX server start ${arr[@]} > /dev/null 2>&1
        PauseDisplayScreen2
}

function StatusLab
{
	SetUserCredentialsFor $lab
	echo -e "Probing status of $lab"
	openstack $CLISUFFIX stack list
	echo -e "Probing for list of instances in $lab"
	openstack $CLISUFFIX server list -c Name -c Status -c Networks -c Image -c Flavor
	echo -e "Probing lab access details..."
        # Looking for 7 output values. Change the number if more output values are needed.
	for n in {1..7}
	do
		openstack $CLISUFFIX stack output show $lab output_$n -c output_value -f value 2> /dev/null
	done
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
	SetAdminCredentials

	SetUserCredentialsFor $lab
        read -p "Enter new Project name: " NEWLAB
        while [[ -d "$NEWLAB" ]]
        do
                echo -e "Project with provided name already exists"
                read -p "Enter new Project name: " NEWLAB 
        done
	if [[ $NEWLAB == "" ]]
	then
		PauseDisplayBlueprintScreen
	fi
	#mkdir $NEWLAB

        echo -ne "\nGetting list of available images . . . "
        ImageArrayAvail=($(openstack $CLISUFFIX image list -c Name -f value))
        echo -e "done"

	echo -e "Stopping all the servers in this lab..."
	# TODO: Do not stop the server which is already in stopped state
	# TODO: Check if stopping the server is really needed
	for i in `openstack $CLISUFFIX server list -c Name -f value`
	do
		openstack $CLISUFFIX server stop $i
	done

	echo -ne "Waiting for all the server to stop. "
	while [ -n "$(openstack $CLISUFFIX server list -c Name -c Status -f value | grep -v SHUTOFF)" ]
	do
		echo -n " . "
		#sleep 5
	done
	echo -e " "
	openstack $CLISUFFIX server list -c Name -c Status -f value

	OLDLAB=$(openstack $CLISUFFIX stack list -c 'Stack Name' -f value)
	OLDLAB=$(echo $OLDLAB | cut -d '-' -f 3- | rev | cut -d '_' -f 2- | rev)
	echo -e "Cloaning current status of $lab to $NEWLAB"

	cp -r $APPSDIR/$lab $BPSDIR/$NEWLAB
	newstackfile="${BPSDIR}/${NEWLAB}/stack_user.yaml"
	chmod -R a+w $BPSDIR/$NEWLAB
	OLDIFS=$(echo $IFS)
	IFS=$'\n'
	for i in $(openstack $CLISUFFIX server list -c Name -c Image -f value)
	do
		echo -e "\n$i"
		servername=$(echo $i | awk '{print $1}')
		curimgname=$(echo $i | awk '{print $2}')
		newimgname=$(echo "${NEWLAB}-${servername}")
		echo -e "Processing $servername running from image $curimgname"
	        
		##Provide option to avoid cloaning common images
	        if [[ $curimgname =~ "pntaecommon" ]]
        	then 
	                echo -e "\nPress Enter to skip saving common image $image \nType name of the new image if you wish save it."
	                echo -e "Copy/Paste the suggested name for new image $newimgname \nor type new name or press Enter to skip"
	                read new_image_name
			if [[ $new_image_name == '' ]]
			then
			echo -e "Skipping $image"
        	        continue
			fi
	        fi

		if [[ ! -z $new_image_name ]]
		then
		newimgname=$(echo $new_image_name)
		fi

		if [[ $newimgname != *"$TAG"* ]]; then
			newimgname=$newimgname-pntae
		fi


                if [[ " ${ImageArrayAvail[@]} " =~ " ${newimgname} " ]]
                then
                        echo -e "Image $newimgname already exists, skipping image . . . "
                        echo -e "Replacing $curimgname with $curimgname-MODIFYTHIS in $newstackfile"
                        sed -i "s/$curimgname/$curimgname-MODIFYTHIS/g" $newstackfile

                else
                        echo -ne "Image $newimgname does not exist, creating image . . . "
			echo -e "Creating new image $newimgname from $servername..." 

			openstack $CLISUFFIX server image create --name $newimgname $servername > /dev/null 2>&1
			echo -e "Replacing $curimgname with $newimgname in $newstackfile"

			cat -n $newstackfile > $newstackfile.num
			lineno=$(grep name $newstackfile.num | grep $servername | head -1 | awk '{print $1}')
			lineno=$(tail -n +$lineno $newstackfile.num | grep image  | grep -v '#' | head -1 | awk '{print $1}')
			cmd="sed -i \""${lineno}"s/"${curimgname}"/"${newimgname}"/\" "${newstackfile}
			eval $cmd

		fi
	done

	echo -e "\nWaiting for 2 minutes for images to be active..."
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

		echo -e "\nSetting $image as public image"
		if [ $ADMINACCESS == "no" ]
		then
			exec_admin_publish_image_script $PROJECTID $image
		else 
			openstack $CLISUFFIX image set --property visibility=public $image 
		fi
	done

        echo -e "Current status of $lab is frozen as blueprint with name $NEWLAB. "
        echo -e "Please launch $NEWLAB and verify that the state of all the VMs is as expected."
	echo -e "Do not delete this lab until you verify the new blueprint."

	SetUserCredentialsFor $lab

	PauseDisplayScreen2
}

function LabUPDATE
{
        SetUserCredentialsFor $lab
        echo -e "Updating lab environment $lab"
	labdir="${APPSDIR}/${lab}"
        openstack $CLISUFFIX stack update -t $labdir/stack_user.yaml $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=$USERNAME
	PauseDisplayScreen2
}

function LabImagePUBLISH
{

	echo -e "\nListing images available for publishing..."
        SetUserCredentialsFor $lab
	openstack $CLISUFFIX image list --shared -c Name -f value
	echo -e "please wait..."
	openstack $CLISUFFIX image list --private -c Name -f value
	read -p "Select (copy-paste) name of the image to be published (one at a time): " image
	if [ -z "$image" ]
	then
		echo -e "No image selected"
		PauseDisplayScreen2
	fi
	echo -e "\nSetting $image as public image..."
        if [ $ADMINACCESS == "no" ]
        then
                exec_admin_publish_image_script $PROJECTID $image
        else
                openstack $CLISUFFIX image set --property visibility=public $image
        fi
	PauseDisplayScreen2
}

function ShowConsole
{
        SetUserCredentialsFor $lab
        echo -e "Probing list of VMs in $lab . . ."
        openstack $CLISUFFIX server list -c 'Name' -f value -c 'Status' -f value
        echo -e "===^===^===^===^===^===^===^==="
        echo -e "Select VMs from above list for which you need console access details (provide space separated list)"
	echo -e "You may copy-paste name of the VM(s) from the above list"
	echo -e "or\nPress Enter to see console access details of all the VMs in this lab"
        read line
	if [[ ! -z "$line" ]]
	then
        	arr=($line)
	        echo -e "Probing console access links for selected VM(s)\n"      
		for vm in "${arr[@]}"
		do
                echo -ne "$vm \t"
		openstack $CLISUFFIX console url show $vm -c url -f value
                echo -e "\n"
		done
	else
        	echo -e "Probing console access details for $lab\n"
		for vm in `openstack $CLISUFFIX server list -c Name -f value`
		do
		echo -ne "$vm \t"
		openstack $CLISUFFIX console url show $vm -c url -f value
		echo -e "\n"
		done
	fi
	PauseDisplayScreen2
}

function ToggleBoot
{
	SetUserCredentialsFor $lab
	echo -e "Listing vms of this lab, please wait..."
	vms=($(openstack server list -c Name -f value))
	printf '%s\n' "${vms[@]}"
	read -p "Select the VM to toggle boot: " vmname
	if [[ " ${vms[@]} " =~ " ${vmname} " ]]
	then
		echo -ne "VM exists ... "
		eval `openstack server show $vmname -f shell | grep os_ext_sts`
		if [[ "$os_ext_sts_vm_state" == "rescued" && "$os_ext_sts_task_state" == "None" ]]
		then
			echo -e "Server $vmname is in rescue mode, putting it in unrescue mode..."
			openstack server unrescue $vmname
		elif [[ "$os_ext_sts_vm_state" == "active" && "$os_ext_sts_task_state" == "None" ]]
		then
			echo -ne "checking image ... "
			properties=`openstack server show $vmname -c properties -f value`
			eval $properties
			cdrom=$(echo $cdrom | sed 's/\,//')
			if [ -z "$cdrom" ]
			then
				echo -e "$vmname is not configured to use cdrom"
				PauseDisplayScreen2
			fi
			echo -ne "$cdrom ... "
			openstack image list | grep $cdrom > /dev/null 2>&1
			if [ $? -eq 0 ]
			then
				echo -e "exists"
				echo -e "Putting VM $vmname in rescue mode with image $cdrom"
				openstack server rescue --image $cdrom $vmname
			else
				echo -e "does not exist"
				PauseDisplayScreen2
			fi

			#echo -e "DETECT CDROM IMAGE AND USE IT FOR RESCUE"
		fi

		echo -e "PROBE FOR TOGGLE STATUS AND WHEN READY SHOW CONSOLE URL"



	else
		echo -e "VM does not exists"
	fi



	PauseDisplayScreen2

}

function ExitNovelloShell
{
	WriteLog "ExitNovelloShell"
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

function DisplayBlueprintScreen
{
        PrintBlueprintOptions
        MenuBlueprintActions
}


function DisplayImageScreen
{
        PrintImageOptions
        MenuImageActions
}

function SetUserCredentialsFor
{
	lab=$1
        export OS_USERNAME=$lab
        export OS_PASSWORD=redhat
        export OS_PROJECT_NAME=$lab

        ### FIXME: Required config option for domain settings below
        export OS_USER_DOMAIN_NAME=$DOMAIN
        export OS_PROJECT_DOMAIN_NAME=$DOMAIN
}

function SetAdminCredentials
{
source $ADMINRC
}

function LaunchLabStack
{

	CSVSTR=${USERNAME}
	CSVSTR=${CSVSTR}${CSVSEP}${1}

	uniqid=$(echo $RANDOM | md5sum | head -c 4)
	lab=$USERNAME-$TAG-$1-$uniqid
	SetAdminCredentials
        if [[ "$ADMINACCESS" != "no" ]]
	then
        runninglabs=$(openstack $CLISUFFIX stack list | grep $USERNAME | wc -l)
	else
        runninglabs=$(exec_admin_stack_script | grep $USERNAME | wc -l)
	fi

        if [ $runninglabs -lt $MAXLABS ]
        then
	mkdir -p "${APPSDIR}/${lab}"
	cpsrc="${BPSDIR}/${1}/stack_user.yaml"
	cpdst="${APPSDIR}/${lab}"
	cp $cpsrc $cpdst
	stackfile="${APPSDIR}/${lab}/stack_user.yaml"
	echo -e "Stack name:  $lab"

        if [[ "$ADMINACCESS" == "no" ]]
	then

	exec_admin_usrrol_script create $lab
	WriteLog "exec_admin_usrrol_script create $lab"
	else
        ## FIXME: Required config option for usage of --domain --user-domain and --project-domain options below
	openstack $CLISUFFIX project create $lab --domain $DOMAIN > /dev/null 2>&1
	openstack $CLISUFFIX user create --password redhat --project $lab $lab --domain $DOMAIN > /dev/null 2>&1
	openstack $CLISUFFIX role add --user-domain $DOMAIN --project-domain $DOMAIN --project $lab --user $lab _member_ > /dev/null 2>&1
	openstack $CLISUFFIX role add --user-domain $DOMAIN --project-domain $DOMAIN --project $lab --user admin admin > /dev/null 2>&1
        openstack $CLISUFFIX role add --user $lab --user-domain $DOMAIN --project $lab --project-domain $DOMAIN member  > /dev/null 2>&1
	openstack $CLISUFFIX quota set --cores -1 --instances -1 --ram -1 $lab > /dev/null 2>&1
        fi

	SetUserCredentialsFor $lab
	WriteLog "Creating stack for $lab"
        openstack $CLISUFFIX stack create -t $stackfile $lab --parameter project_name=$lab --parameter public_net_id=$PUBLICNETWORK --parameter project_guid=$USERNAME

	CSVSTR=${CSVSTR}${CSVSEP}${lab}
	CSVSTR=${CSVSTR}${CSVSEP}$(date +"%a %b %d %T %Y")
	echo -e $CSVSTR >> $STATSDIR/$REPORTFILE

	else
	echo -e "You can run maximum of $MAXLABS labs. Delete any of your running labs and try again."
	fi

	return
}

function ListLabs
{
echo -e "Checking list of your labs.."
SetAdminCredentials
if [[ "$ADMINACCESS" != 'no' ]]
then
openstack $CLISUFFIX stack list -c 'Stack Name' -c 'Stack Status' -c 'Creation Time' -f value | grep ^$USERNAME-
else
exec_admin_stack_script -c "'Stack Name'" -c "'Stack Status'" -c "'Creation Time'" -f value | grep ^$USERNAME-
fi

SelectLab
echo -e "checking presence of $lab"
SetUserCredentialsFor $lab
openstack $CLISUFFIX stack list -c 'Stack Name' | tr -d '|' | tr -d '[:blank:]' | grep ^$lab$
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
                DisplayImageScreen
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

if [[ $ImageName != *"$TAG"* ]]; then
        ImageName=$ImageName-$TAG
fi

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
	echo -ne "\nGetting list of available images . . . "
	ImageArrayAvail=($(openstack $CLISUFFIX image list -c Name -f value))
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
		        if [ $ADMINACCESS != "no" ]
		        then
				openstack $CLISUFFIX image create --disk-format $ImageType --container-format bare --public --file $ImageFile $ImageName
			else
			openstack $CLISUFFIX image create --disk-format $ImageType --container-format bare --file $ImageFile $ImageName
			fi
			WriteLog "UploadIMAGE $ImageFile"
			
	                echo -e "\nSetting $image as public image"
        	        if [ $ADMINACCESS == "no" ]
                	then
                        	exec_admin_publish_image_script $PROJECTID $ImageName
	                else
                	        openstack $CLISUFFIX image set --property visibility=public $ImageName
        	        fi

			echo -e "done"

		fi
	done
	PauseDisplayImageScreen
}

function DeleteIMAGE
{
SetAdminCredentials
read -p "Provide name of the image tobe deleted: " ImageName
if [[ "$ImageName" != *"$TAG"* ]]; then
	echo -e "Image belonging to $TAG can only be deleted"
	PauseDisplayImageScreen
fi
if [[ "$ImageName" == *"DELETE"* ]]; then
	echo -e "Image is already marked for deletion"
	PauseDisplayImageScreen
fi
echo -e "Below labs will be affected with deletion of this image. Make sure to correct these."
grep -Rl $ImageName $BPSDIR  | awk -F/ '{print $(NF-1)}' | sort | uniq
echo -e "Marking $ImageName for deletion"
ImageNameDel=$USERNAME-$ImageName-DELETE-$RANDOM
echo -ne "Setting $ImageName as $ImageNameDel for deletion..."
openstack $CLISUFFIX image set --name $ImageNameDel $ImageName
echo -e "done"
PauseDisplayImageScreen
}

function PurgeIMAGE
{
SetAdminCredentials
read -p "Provide name of the image tobe purged: " ImageName

if [[ "$ImageName" != *"$TAG"* ]]; then
        echo -e "Image belonging to $TAG can only be purged"
        PauseDisplayImageScreen
fi

if [[ "$ImageName" == *"DELETE"* ]]; then
        read -p "$ImageName will be deleted permanently and it can not be retrieved.\nAre you sure you want to proceed? (YES/[NO]): " decision
	if [[ $decision != "YES" ]]
	then
        	PauseDisplayImageScreen
	else
		echo -ne "Permanently deleting $ImageName..."
		openstack $CLISUFFIX image delete $ImageName
		echo -e "done"
	fi
        PauseDisplayImageScreen
fi
echo -e "Can not purge $ImageName. The image to be purged needs to be marked for deletion first."
echo -e "Please wait..."
openstack $CLISUFFIX image list -c Name -f value | grep $ImageName | grep DELETE
echo -e "You may wish to purge any of the above"
PauseDisplayImageScreen
}

function RetrieveIMAGE
{
SetAdminCredentials
read -p "Provide name of the image to be retrieved: " ImageName

if [[ "$ImageName" != *"DELETE"* ]] 
then
	echo -e "Can not retrieve $ImageName. Image marked for deletion can only be retrieved"
	echo -e "Please wait..."
	openstack $CLISUFFIX image list -c Name -f value | grep $ImageName | grep DELETE
	echo -e "You may wish to retrieve any of the above"
	PauseDisplayImageScreen
fi

echo -ne "\nGetting list of available images . . . "
ImageArrayAvail=($(openstack $CLISUFFIX image list -c Name -f value))
echo -e "done"

ImageNameRetrieve=$(echo $ImageName | cut -d- -f2- | rev | cut -d- -f3- | rev)

if [[ " ${ImageArrayAvail[@]} " =~ " ${ImageNameRetrieve} " ]]
then
        echo -e "$ImageName can not be retrieved as image with name $ImageNameRetrieve already exists"
	PauseDisplayImageScreen
else
	echo -ne "Setting $ImageName as $ImageNameRetrieve..."
	openstack $CLISUFFIX image set --name $ImageNameRetrieve $ImageName
	echo -e "done"
fi
PauseDisplayImageScreen
}

function ShowIMAGE
{
SetAdminCredentials
read -p "Provide name of the image whose details are to be displayed: " ImageName
openstack image show $ImageName | less
PauseDisplayImageScreen
}

function SelectLab
{
	echo -e "===^===^===^===^===^===^===^===^===^===^===^===^==="
	echo -e "Type the name of the lab you want to manage.\n(You may copy-paste namae of the lab from the above list)"
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

function LabBlueprintConnect
{
read -p "Provide name of the lab environment you wish to connect to: " lab
if [ $ADMINUSER -ne 1 ]
then
	labusername=$(echo $lab | awk -F '-' '{print $1}')
	if [[ "$USERNAME" != "$labusername" ]]
	then
		echo "You may connect to the labs belonging to you"
		PauseDisplayScreen1
	fi
fi
echo -e "checking presence of $lab"
SetAdminCredentials
SetUserCredentialsFor $lab
openstack $CLISUFFIX stack list -c 'Stack Name' | tr -d '|' | tr -d '[:blank:]' | grep ^$lab$
if [ $? -ne 0 ]
then
        echo -e "Invalid lab"
        PauseDisplayScreen1
fi
DisplayScreen2
}

function BecomeUser
{
read -p "Provide name of the user you wish to login as: " usr
sudo su - $usr 2> /dev/null
if [ $? -ne 0 ]
then
echo -e "Invalid user name"
else
echo -e "Exited from $usr's session"
fi
PauseDisplayScreen1
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
		if [[ $choice == *"template"*  ]]
		then
			echo -e "Template blueprints cannot be deleted. Contact NovelloShell administrator if you still wish to delete this"
			PauseDisplayBlueprintScreen
		fi
		echo -e "Are you sure you want to delete the lab environment blueprint $choice ? (YES|NO)"
		read confirm
		if [[ $confirm != 'YES' ]]
		then
		        echo -e "Not deleting the lab environment blueprint"
		        PauseDisplayBlueprintScreen
		fi

		echo -e "All associated images may be permanently deleted. Do you want to proceed? (YES|NO)"
		read confirm
		if [[ $confirm != 'YES' ]]
		then
		        echo -e "Not deleting the lab environment blueprint"
		        PauseDisplayBlueprintScreen
		fi
		
		echo -e "Deleting the lab environment blueprint: $choice"
		LabDataDELETE $choice
		PauseDisplayBlueprintScreen
	fi
	echo -e "Ivalid option, hit Enter to try again"
	read p
	LabBlueprintDELETE
}

function CloneTemplate
{
	if [[ $1 != *"template"* ]]
	then
	echo -e "Only template blueprints can be cloned"
	PauseDisplayBlueprintScreen
	fi
	echo -e "Creating new template from $1"
	echo -ne "Enter the name of the new blueprint: "
	read newbpname
        if [ -d $newbpname ]
        then
                echo -e "Blueprint $newbpname already exists!"
                echo -e "Consider editing existing blueprint or create clone with different name."
                PauseDisplayBlueprintScreen
        fi
	cp -r $1 $newbpname
	chmod -R a+rwx $newbpname
	if [ $? -eq 0 ]
	then
	sed -i "s|$1|$newbpname|g" $newbpname/stack_user.yaml
	if [ $? -eq 0 ]
	then
	chmod -R a+rw $newbpname/stack_user.yaml
        #read -p "Would you like to clone the startup scripts as well? ([Y]/n): " yn
        #if [[ "$yn" =~ ^(N|n|No|no|NO)$ ]]
        #then 
        #echo -e "Not cloning startup scripts for the lab template. You need to create those later"
        #WriteLog "Not cloning startup scripts for the lab template. You need to create those later"
        #else 
        echo -e "Cloning startup scripts for the lab template."
        WriteLog "Cloning startup scripts for the lab template."
        cp -r $STARTUPSCRIPTSPATH/$1 $STARTUPSCRIPTSPATH/$newbpname
        chmod -R a+rwx $STARTUPSCRIPTSPATH/$newbpname
        #fi
	echo -e "Successfully cloned $newbpname from $1!"
	WriteLog "Successfully cloned $newbpname from $1!"

	read -p "Provide IP address of lab development VM (optional - presss Enter to skip):" develIP
	if [[ -z "$develIP" ]]
	then
		echo -e "Skipping edit of webserver url"
                echo -e "$newbpname is still using production web server, consider editing the lab if required."
		PauseDisplayBlueprintScreen
	fi

	if [[ $develIP =~ ^[0-9]+\.[0-9]+\.[0-9]+\.[0-9]+$ ]]
	then
		echo -ne "Checking connectivity, please wait . . . "
		sudo ssh -o StrictHostKeyChecking=no -i $KEYFILEPATH cloud-user@$develIP echo success 2> /dev/null
		if [ $? -eq 0 ]
		then
			echo -ne "Configuring $newbpname to use $develIP . . . "
			sed -i "0,/$WEBURL/{s/$WEBURL/$develIP/}" $newbpname/stack_user.yaml
			if [ $? -eq 0 ]
			then
				echo -e "done"
				echo -ne "Creating required directories and file on $develIP . . . "
		                sudo ssh -o StrictHostKeyChecking=no -i $KEYFILEPATH cloud-user@$develIP sudo mkdir $STARTUPSCRIPTSPATH 2> /dev/null
		                sudo ssh -o StrictHostKeyChecking=no -i $KEYFILEPATH cloud-user@$develIP sudo chmod 777 $STARTUPSCRIPTSPATH 2> /dev/null
		                sudo scp -o StrictHostKeyChecking=no -r -i $KEYFILEPATH $STARTUPSCRIPTSPATH/$newbpname git@$develIP:$STARTUPSCRIPTSPATH 2> /dev/null
				echo -e "done"
			else
				echo -e "fail"
				echo -e "$newbpname is still using production web server, consider editing the lab if required."
			fi
		else
			echo -e "fail. Unable to connect to $develIP"
			echo -e "$newbpname is still using production web server, consider editing the lab if required."
		fi
	else
		echo -e "Invalid IP address, $newbpname is still using production web server, consider editing the lab if required."
	fi

	PauseDisplayBlueprintScreen
	fi
	fi
	echo -e "Something went wrong while cloning $newbpname from $1!"
	echo -e "Review $newbpname before using it"
	PauseDisplayBlueprintScreen
}

function LabBlueprintCLONE
{
	clear
        echo -e "Clone a new lab environment from existing template"
        echo -e "=================================================="
        cd $BPSDIR
        ls
        SelectLab
        if [ -d $choice ]
        then
                CloneTemplate $choice
		PauseDisplayBlueprintScreen
        fi
        echo -e "Ivalid option, hit Enter to try again"
        read p
        LabBlueprintCLONE

}


function RenameLab
{
if [[ $1 == *"template"* ]]
then
	echo -e "You can not rename the template blueprints"
	PauseDisplayBlueprintScreen
fi
echo -e "Renaming lab environment blueprint $1"
echo -ne "Enter the name of the new lab environment blueprint: "
read newbpname
if [ -d $newbpname ]
then
	echo -e "Blueprint $newbpname already exists!"
	echo -e "Consider editing existing lab blueprint or rename the lab with different name."
	PauseDisplayBlueprintScreen
fi
mv $1 $newbpname
chmod -R a+rwx $newbpname
if [ $? -eq 0 ]
then
	sed -i "s|$1|$newbpname|g" $newbpname/stack_user.yaml
	if [ $? -eq 0 ]
	then
		chmod -R a+rw $newbpname/stack_user.yaml
		if [ -d $STARTUPSCRIPTSPATH/$1 ]
		then
			echo -e "Renaming startup scripts directory for the lab template."
			WriteLog "Renaming startup scripts directory for the lab template."
			mv $STARTUPSCRIPTSPATH/$1 $STARTUPSCRIPTSPATH/$newbpname
			chmod -R a+rwx $STARTUPSCRIPTSPATH/$newbpname
		else
			echo -e "Startup scripts directory does not exist for the lab"
			WriteLog "Startup scripts directory does not exist for the lab"
		fi
	else
		echo -e "Error renaming name of the blueprint in the heat template, review the new blueprint before proceeding."
		WeiteLog "Error renaming name of the blueprint in the heat template, review the new blueprint before proceeding."
	fi
	echo -e "Successfully renamed $1 to $newbpname!"
	WriteLog "Successfully rendmaed $1 to $newbpname!"
	PauseDisplayBlueprintScreen
else
	echo -e "Something went wrong while renaming from $1 to $newbpname!"
	WriteLog "Something went wrong while renaming from $1 to $newbpname!"
	echo -e "Review $newbpname before using it"
fi
PauseDisplayBlueprintScreen
}

function LabBlueprintRENAME
{
        clear
        echo -e "Rename an existing lab environment to the new name"
        echo -e "=================================================="
        cd $BPSDIR
        ls
        SelectLab
        if [ -d $choice ]
        then
                RenameLab $choice
                PauseDisplayScreen1
        fi
        echo -e "Ivalid option, hit Enter to try again"
        read p
        LabBlueprintRENAME

}

function LabBlueprintSTARTUP
{
        clear
        echo -e "CAUTION: This may break the lab environment, make sure you know what you are doing\n"
        echo -e "Edit startup scripts for the lab environment"
        echo -e "============================================"
        cd $BPSDIR
        ls
        SelectLab
        if [ -d $choice ]
        then
                export VALIDDIR="$STARTUPSCRIPTSPATH/$choice"
		if [ -d $VALIDDIR ]
		then
			cd $VALIDDIR
		else
			read -p "Startup directory for $choice does not exist. Would you like to create it? (Y/[N]): " yn
        		if [[ "$yn" =~ ^(Y|y|Yes|yes|YES)$ ]]
		        then
				echo -e "Creating startup directory for $choice "
				mkdir $VALIDDIR
				cd $VALIDDIR
			else	
				echo -e "Not creating startup directory for $choice "
				PauseDisplayBlueprintScreen
			fi	
		fi
		export PS1="[NOVELLOSHELL \W]\$ "
		NOVELLO=yes bash
		PauseDisplayBlueprintScreen
        fi
        echo -e "Ivalid option, hit Enter to try again"
        read p
        LabBlueprintSTARTUP
}

function LabBlueprintEDIT
{
        clear
	echo -e "CAUTION: This may break the lab environment, make sure you know what you are doing\n"
        echo -e "Edit a lab environment blueprint"
        echo -e "================================"
        cd $BPSDIR
        ls
        SelectLab
        if [ -d $choice ]
        then
                vi $choice/stack_user.yaml
                DisplayBlueprintScreen
        fi
        echo -e "Ivalid option, hit Enter to try again"
        read p
        LabBlueprintEDIT
}

function LabDataDELETE
{
WriteLog "LabDataDELETE $choice"
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
		echo -e "Skipping image $image it is a template image"
		continue
	fi
	
        ##Avoid deleting images used by other blueprints
	grep -R --exclude-dir=$choice $image $BPSDIR > /dev/null 2>&1
	if [ $? -eq 0 ]
	then
		echo -e "Skipping image $image it is being used by other labs"
		continue
	fi

	echo -e "Marking $image for deletion"
	WriteLog "Marking $image for deletion"
	ImageNameDel=$USERNAME-$image-DELETE-$RANDOM
	echo -ne "Setting $image as $ImageNameDel for deletion..."
	openstack $CLISUFFIX image set --name $ImageNameDel $image
done
echo -e "Deleting heat template for $choice"
WriteLog "Deleting heat template for $choice"
cmd="rm -rf $BPSDIR/$choice"
eval $cmd
if [ $? -ne 0 ]
then
	echo -e "FAILED"
fi
echo -e "Deleting startup scripts for $choice"
WriteLog "Deleting startup scripts for $choice"
cmd="rm -rf $STARTUPSCRIPTSPATH/$choice"
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

function LabInfo
{
        clear
        echo -e "Select a lab environment template to know additional information"
        echo -e "================================================================"
        cd $BPSDIR
        ls
        SelectLab
        if [ -d $choice ]
        then
		if [ -f "$choice/README.md" ]
		then 
			if [ $ADMINUSER -eq 1 ]
			then
			vi $choice/README.md
			else
			less $choice/README.md
			fi
	                PauseDisplayScreen1

		else
                        if [ $ADMINUSER -eq 1 ]
                        then
	                	read -p "README file does not exist for $choice, would you like to create it? " yn
	                        if [[ "$yn" =~ ^(Y|y|Yes|yes|YES)$ ]]
				then
					vi $choice/README.md
				fi
			fi
	                echo -e "README file does not exist for $choice"
		fi
                PauseDisplayScreen1
        fi
        echo -e "Ivalid option, hit Enter to try again"
        read p
        LabInfo

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
WriteLog "Deleting $lab"
SetUserCredentialsFor $lab
openstack $CLISUFFIX stack delete $lab --wait --yes
if [ $? -eq 0 ]
then
	SetAdminCredentials
        if [ $ADMINACCESS != "no" ]
	then
	openstack $CLISUFFIX project delete $lab
	openstack $CLISUFFIX user delete $lab
	else
        exec_admin_usrrol_script delete $lab
	fi
	echo -e "\nSuccessfully deleted the lab environment"
	echo -ne "Deleating associated files..."
	rm -rf "${APPSDIR}/${lab}"
	echo -e "done\n"
else
	echo -e "\nFailed to delete the lab environment"
fi
PauseDisplayScreen1
}

function LabSHELL
{
SetUserCredentialsFor $lab
openstack $CLISUFFIX
DisplayScreen2
}

function WriteLog
{
alias date="date +\"%a %b %d %T\""
date=`date`
header="${date} ${USERNAME} "
echo -e $header$1 >> $LOGFILE
}

WriteLog "Logged in to NovelloShell"
DisplayScreen1
 
