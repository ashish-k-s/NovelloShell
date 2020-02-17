# NovelloShell

Quick and dirty substitute of Ravello.

## Objective

This tool provides quick and dirty substitute of Ravello for use with OpenStack infrastructure.
You can configure this tool to use any of your OpenStack deployment to have Ravello like features using it.

## How to configure

- Use novelloshell.sh script as shell for any user account.
*/etc/passwd* file entry should look like below:
```
novello:x:5010:5010::/home/ashishks:/mnt/novello/TESTING/novelloshell-v3.sh
```

- Configure .novelloshell.cfg file:
```
# Public network to be used for the stack
PUBLICNETWORK=provider-network

# RC file for admin access of stack
ADMINRC="/mnt/novello/TESTING/overcloudrc"

# Directory tobe used for storing configuration of running applications
APPSDIR="/mnt/novello/TESTING/PROJECTS/APPS"

# Directory tobe used for storing configuration of blueprints
BPSDIR="/mnt/novello/TESTING/PROJECTS/BPS"

# tag to be appended for the stack and images
TAG="aks"

# File containing list of users for which admin rights are to be assigned.
# The admin rights involves the ability to delete existing blueprint,
# edit running application, create new blueprint by saving the running application as blueprint, etc.
# Functionalities requiring admin rights are displayed in ALLCAPS.

ADMINUSERSFILE="/mnt/novello/TESTING/novelloshell-admins"
```

## How to use this tool

- Upload required images to your openstack environment
- Make sure to include the name of the blueprint in the name of the image uploaded to the stack.
- Create a directory with the name of the blueprint at the path denoted by BPSDIR configuration.
- Create stack_user.yaml file under the blueprint directory to launch the stack.
- Refer to the demo video for more details.

