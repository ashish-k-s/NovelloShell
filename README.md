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

image::novelloshell.png[width=100%]
.NovelloShell working


## How to configure

- Use novelloshell.sh script as shell for any user account.
*/etc/passwd* file entry should look like below:
```
ashishks:x:5010:5010::/home/ashishks:/mnt/novello/TESTING/novelloshell-v3.sh
```

- Configure .novelloshell.cfg file:
```
# Public network tobe used for the stack
PUBLICNETWORK=provider-network

# RC file for admin access of stack
ADMINRC="/mnt/novello/TESTING/overcloudrc"

# Directory tobe used for storing configuration of running applications
APPSDIR="/mnt/novello/TESTING/PROJECTS/APPS"

# Directory tobe used for storing configuration of blueprints
BPSDIR="/mnt/novello/TESTING/PROJECTS/BPS"

# tag to be appended for the stack and images.
# This is to indetify the resources on the infrastructorure being shared by multiple teams.
TAG="my-team"

# File containing list of users for which admin rights are to be assigned.
# The admin rights involves the ability to delete existing blueprint,         
# edit running application, create new blueprint by saving the running application as blueprint, etc.
# Functionalities requireing admin rights are displayed in ALLCAPS.
ADMINUSERSFILE="/mnt/novello/TESTING/novelloshell-admins"

# Images having this string in it's name will be skipped while creating new blueprint 
# and deleting the existing blueprints
# Make sure to include this string in the name of common images so as to avoid duplicate image creation and deletion.
# Common images can be stored only once and can be shared by different blueprints to save the space.
SKIPIMAGETAG="myteamcommon"

# Path of directory where image files are stored 
# This path is looked for upload of image in OpenStack 
IMAGEFILESPATH="/home/ashishks/novello/TESTING/PROJECTS/IMAGES"

# This option should usually be set to blank. It can be used when any clisiffix is tobe passsed to openstack command.
# like e.g. "--debug" or "--insecure" 
CLISUFFIX=""

# Behaviour of "ADMINACCESS=" option is changed in v5
# Option ADMINACCESS is deprected and this new option is introduced here.
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

#ADMINACCESSSCRIPT=/path/to/sample-script_manage-user-project.sh

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
