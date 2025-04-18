# NovelloShell

Quick and dirty substitute of Ravello.

## Objective

This tool provides quick and dirty substitute of Ravello for use with OpenStack infrastructure.
You can configure this tool to use any of your OpenStack deployment to have Ravello like features using it.

## Features

- Launch a new lab from blueprint
- Delete the lab environment blueprint
- Upload images to Novello/OSP environment
- Execute below functions on running labs:
  - Show status of running lab
  - Show console access details of the lab
  - Start the lab in stopped state
  - Stop the running lab
  - Delete the lab
  - Toggle boot sequence - supports boot from other image e.g. cd or dvd iso
    Name of the image to be used for alternate boot is tobe set in server properties as cdrom=imagename
  - Get access to openstack shell for a lab 
    - Restricted access for that specific lab
    - Allows users to run additional openstack commands on the stack specific to that lab environment only

  - Edit the stack template of the application(lab)
  - Update the lab environment with modified heat template
  - Save the running application(lab) as new blueprint
- Multi user support with access restriction to owner's labs
- Features like save as blueprint, delete blueprint, upload image, can be restricted to few users with admin rights

## How it works

![Alt text](novelloshell.png?raw=true "How NovelloShell works")


## How to configure

- Use novelloshell.sh script as shell for any user account.
*/etc/passwd* file entry should look like below:
```
ashishks:x:5010:5010::/home/ashishks:/mnt/novello/TESTING/novelloshell-v3.sh
```

- Configure .novelloshell.cfg file:
```
# Public network tobe used for the stack
PUBLICNETWORK=provider_net_cci_14
#PUBLICNETWORK=provider_net_shared_3

# RC file for admin access of stack
ADMINRC="/mnt/NovelloShell/psiprodrc"
#ADMINRC="/mnt/NovelloShell/psistagerc"

# Directory tobe used for storing configuration of running applications
APPSDIR="/mnt/NovelloShell/PROJECTS/APPS"

# Directory tobe used for storing configuration of blueprints
BPSDIR="/mnt/NovelloShell/PROJECTS/BPS"

STATSDIR="/mnt/NovelloShell/STATS"
LOGFILE="/mnt/NovelloShell/STATS/novelloshell.log"

# tag to be appended for the stack and images.
# This is to indetify the resources on the infrastructorure being shared by multiple teams.
TAG="pntae"

# URL containing FAQs about usage of novelloshell in the environment
# It is displayed on the first screen of the novelloshell 

FAQURL="https://url.corp.redhat.com/PNTAE-Training-lab-FAQs"
#MOTD="Labs older than 10 days will be deleted automatically.\nHappy learning!"
MOTD="/etc/motd.d/novelloshell"

DOMAIN="pntae-non-ldap.redhat.com"

MAXLABS=10

# Name of RHOS cluster for user's information.
# String "RHOS" is used of this name is not set.
#CLUSTERNAME="rhos-c"
CLUSTERNAME="rhos-d"

# File containing list of users for which admin rights are to be assigned.
# The admin rights involves the ability to delete existing blueprint,         
# edit running application, create new blueprint by saving the running application as blueprint, etc.
# Functionalities requireing admin rights are displayed in ALLCAPS.
ADMINUSERSFILE="/mnt/NovelloShell/novelloshell-admins"

# Images having this string in it's name will be skipped while creating new blueprint 
# and deleting the existing blueprints
# Make sure to include this string in the name of common images so as to avoid duplicate image creation and deletion.
# Common images can be stored only once and can be shared by different blueprints to save the space.
SKIPIMAGETAG="pntaecommon"

# Path of directory where image files are stored 
# This path is looked for upload of image in OpenStack 
IMAGEFILESPATH="/mnt/NovelloShell/PROJECTS/IMAGES"

# Path of directory where startup playbooks and scripts are stored
# This path is referred while creating clone of the a environment
STARTUPSCRIPTSPATH="/var/www/html/pntae-lab-setup-scripts"

# Web url of novelloshell host VM
# Required by STARTUPSCRIPTSPATH
# This url is configured in lab's heat template file to pull the lab startup scripts.
WEBURL="pntae-training.psi.redhat.com"

CLISUFFIX=""

# Behaviour of "ADMINACCESS" option is changed in v5
# Option ADMINACCESS is deprected and new option below is introduced here.
# This option is to be used with an OSP setup where NovelloShell does not have full admin rights.
# In such case, custom script should be made available to manage user and project creation.
# NovelloShell will use the custom script instead of using openstack commands for project and user creation.
# The custom script should take two arguments:
# 1) action: create or delete
# 2) lab name: this is the (same) name of the user and project to be created.
# Tasks to be performed by custom script:
#        openstack project create $lab > /dev/null 2>&1
#        openstack user create --password redhat --project $lab $lab > /dev/null 2>&1
#        openstack role add --project $lab --user $lab _member_ > /dev/null 2>&1
#        openstack role add --project $lab --user admin admin > /dev/null 2>&1
#        openstack quota set --cores -1 --instances -1 --ram -1 $lab > /dev/null 2>&1
# A shell script having admin access can be used to perform above tasks. The script can be armoured to hide the admin credentials.
# or this can also be performed by ansible tower job if the option is available.
# 
# If below variable is not set, it is considered that NovelloShell has admin rights with the ADMINRC file set above.

ADMINACCESS=no
ADMIN_USRROL_SCRIPT="/mnt/NovelloShell/psi-rhosp_manage-user-project.sh"
#ADMIN_STACK_SCRIPT="/mnt/NovelloShell/cat-tmp-novello.sh"
ADMIN_STACK_SCRIPT="/mnt/NovelloShell/psi-rhosp_stack-list.sh"
ADMIN_PUBLISH_IMAGE_SCRIPT="/mnt/NovelloShell/psi-rhosp_publish-image.sh"
PROJECTID=fda9407a7ab4465aa933783831ad5d40

LABNAMESTR=pntae_lab

#### Below config is referred for the tasks run outside of novelloshel script

# Number of days after which warning message about auto lab deletion  will be sent to the user.
STACKWARNDAYS=10

# Number of days after which lab environment will be automatically deleted.
STACKDELDAYS=14

# Number of days after which warning message for deletion of the image for image marked for deletion will be sent.
IMAGEWARNDAYS=25

# Number of days after which image marked for deletion will be automatically deleted.
IMAGEDELDAYS=30

# Path to the generic key injected in the lab environment. Ues private key path here.
KEYFILEPATH="/root/.ssh/pntae_training_key"

# Name of the labs mentioned in this file will not be deleted
PRESERVEDLABS="/mnt/NovelloShell/preservedlabs.txt"

# Path where backup of cluster images is stored (This is used by ospImageBkp project)
IMGBKPATH="/mnt/NovelloShell/PROJECTS/IMAGES"
```

## How to use this tool

- Upload required images to your openstack environment
- Make sure to include the name of the blueprint in the name of the image uploaded to the stack.
- Create a directory with the name of the blueprint at the path denoted by BPSDIR configuration.
- Create stack_user.yaml file under the blueprint directory to launch the stack.
- Refer to the demo video for more details:
  - User acccess demo:
	https://youtu.be/x1O1CZ4wt98
  - Admin acccess demo:
	https://youtu.be/1vMT_Jr1rGQ

### User access

1. On the NovelloShell main screen, type new and press Enter to launch a new lab environment.

![Alt text](ns-user-1.png?raw=true "ns-user-1.png")


2. Once the next screen appears, type the name of the new lab environment to launch and press Enter. The name of the lab environment can be tab completed.

![Alt text](ns-user-2.png?raw=true "ns-user-2.png")

3. When prompted, press Enter to continue and return to the main screen.

4. On the NovelloShell main screen, type list and press Enter to display the list of running lab environments for the current user.

![Alt text](ns-user-3.png?raw=true "ns-user-3.png")

5. Select the name of the desired lab environment and press Enter.
Note: You can copy (Ctrl+Shift+C) and paste (Ctrl+Shift+V) the name of the desired lab stack. Tab complete does not work here.

6. Once you enter the lab environment, select the desired lab activity from the list.

![Alt text](ns-user-4.png?raw=true "ns-user-4.png")

7. Type status and press Enter to get the lab environment status and access details.
Note: Lab access details may differ from lab to lab.

![Alt text](ns-user-5.png?raw=true "ns-user-5.png")

### Admin access

Menu options mentioned in ALL CAPS are visible only to the admin uses.
Admin users can be configured in a file mentioned with `ADMINUSERSFILE` option in `novelloshell.cfg` For example: /mnt/NovelloShell/novelloshell-admins

- Admin access main screen

![Alt text](ns-admin-screen1.png?raw=true "ns-admin-screen1.png")

- BLUEPRINT options

![Alt text](ns-admin-blueprint.png?raw=true "ns-admin-blueprint.png")

- IMAGE options

![Alt text](ns-admin-image.png?raw=true "ns-admin-image.png")


## Expansion

Universes for different sub-teams can co-exist on the same backend infrastructure using NovelloShell frontend.

Consider the example for dedicated lab environment setups for three different teams, PNT, PFE and CEE.
Three light weight VMs to host novelloshell can be used to manage dedicated infrastructure for these teams on any shared openstack infrastructure. 

Respective sub-teams will have their own administrators or lab developer users managing the infrastructure for their team. 

The tool can also allow or restrict the associates from any team to login to any of the front-ed to access the lab environment offerings of that team if and when needed.

![Alt text](ns-multi-setup.png?raw=true "ns-multi-setup.png")
