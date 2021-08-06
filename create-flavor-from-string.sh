## SAMPLE USAGE: sh create-flavor-from-string.sh CPU_4_Memory_8192_Disk_50
vcpu=$(echo $1 | cut -d\_ -f 2)
mem=$(echo $1 | cut -d\_ -f 4)
disk=$(echo $1 | cut -d\_ -f 6)

flavor=$(echo $1)

openstack flavor create $flavor --vcpus $vcpu --ram $mem --disk $disk


