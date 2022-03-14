#!/bin/bash

# This script acquires token for connecting edge core to Cloud core node and should be run on the Cloud core
# Developed by Songjie Wang at the University of Missouri
# March 03, 2021

# This script requires two arguments - public IP of the Cloud core, and the token obtained from Cloud cloud core earlier
# $1: IP of Cloud node
# $2: Token 

cloud_IP=$1
token=$2
edge_name=$3
kubeedgeVersion=1.7.2

#check to make sure argument edgeNode IP provided
if [ "$#" -ne 3 ]; then
    echo -e "\n${RED}Not enough arguments supplied, please provide the public IP of the Cloud node, and the token for joining the cluster, and the name of the edge node you want to use. Exiting...${NC}"
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


# start Keadm and connect to Cloud core node
keadm join --cloudcore-ipport="$cloud_IP:10000" --token="$token" --edgenode-name="$edge_name" --kubeedge-version="$kubeedgeVersion" || checkErr "Joining edge core to cluster"
