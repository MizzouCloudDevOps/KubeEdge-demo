#!/bin/bash

# Developed by Songjie Wang at the University of Missouri
# March 03, 2021

# This script copies certificate files to defined edge core node
# The script require one argument, the public IP addresses of edge node 
# Note: The edge node (in this case is a Raspberry Pi, requires port forwarding if it is connected to a home network)
# Note: This script needs to be run as root user
      # The command to login to root user is : sudo su
      # and the command to logout to your user is : exit

# This script takes one argument, the IP of the edge node to add to the cluster 

#check to make sure argument edgeNode IP provided
if [ "$#" -ne 1 ]; then
    echo -e "\n${RED}Please provide the public IP of the Edge node. Exiting...${NC}"
    exit
fi

#Color declarations
RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
LIGHTBLUE='\033[1;34m'
LIGHTGREEN='\033[1;32m'
NC='\033[0m' # No Color

function checkErr() {
    echo -e "${RED}$1 failed. Exiting.${NC}" >&2; exit;
}

#Check to see if the script is run as root/sudo. If not, warn the user and exit.
if [[ $EUID -ne 0 ]]; then
    echo -e "${RED}This script needs to be run as root. Please run this script again as root. Exiting.${NC}"
    exit
fi


# $1: IP of Edge node
edge_node_IP=$1

cd /root/

# setup remote login to edge node
echo -e "\n${GREEN}Copying ssh key to edge nodes ..., please enter your root password for edge node${NC}\n"
ssh-copy-id root@"$edge_node_IP" || checkErr "Copying ssh key to edge node 1"
echo -e "\n${BLUE}SSH key successfully copied to edge nodes...${NC}\n"

# Copy certificate files to edge node 
scp -r /etc/kubeedge/certs root@"$edge_node_IP":/etc/kubeedge/ || checkErr "Copying certificates to edge node"
scp -r /etc/kubeedge/ca root@"$edge_node_IP":/etc/kubeedge/ || checkErr "Copying ca to edge node"
echo -e "\n${BLUE}Finished copying certificates to edge node...${NC}\n\n\n"

echo -e "\n${GREEN}The KubeEdge Cloud core node has been prepared successfully... ${NC}\n"
echo -e "\n${GREEN}Now, you should go prepare the edge node... ${NC}\n"
echo -e "\n${GREEN}And once it is done, come back to the Cloud node and run the KubeEdge application installation scripts... ${NC}\n"




