#!/bin/bash

# This script acquires token for connecting edge core to Cloud core node and should be run on the Cloud core
# Developed by Songjie Wang at the University of Missouri
# March 03, 2021

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

echo -e "Acquiring your token to be used to join edge core to the KubeEdge cluster Cloud core: \n${GREEN}"
kubectl get secret -nkubeedge tokensecret -o=jsonpath='{.data.tokendata}' | base64 -d || checkErr "Getting token from the cloud core"
echo -e "\n\n${NC}Please take down the token, and pass it to edge-core-join.sh script on your edge node: \n"