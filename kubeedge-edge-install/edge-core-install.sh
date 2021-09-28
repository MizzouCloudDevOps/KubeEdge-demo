#!/bin/bash

# This script automates intallation of KubeEdge edge core node
# Developed by Songjie Wang at the University of Missouri
# March 03, 2021

# Note: This script needs to be run as root user

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

# install library prerequisites
echo -e "\n${GREEN}Installing required libraries.. ${NC}\n"
apt-get -y update || checkErr "System update"
apt-get -y upgrade || checkErr "System upgrade"
apt-get -y install wget net-tools gcc make vim openssh-server docker.io || checkErr "Library installation"
echo -e "\n${BLUE}Required libraries installed... \n"

echo -e "\n${GREEN} Checking Docker installation.. ${NC}\n"
docker --version || checkErr "Docker installation"
echo -e "\n${BLUE}Docker successfully installed... \n"

# install snap package manager
echo -e "\n${GREEN}Installing snap package manager...${NC}\n"
apt-get -y install snap
echo -e "\n${BLUE}Snap successfully installed... \n"

echo -e "\n${GREEN}Installing Kubernetes packages...${NC}\n"
snap install kubectl --classic || checkErr "Kubectl installation"
snap install kubeadm --classic || checkErr "Kubeadm installation"
# Dont install kubelet on EdgeNode
# apt-get -y install kubelet --classic || checkErr "Kubelet installation error..."

# check Kubernetes install
echo -e "\n${GREEN} Checking Kubernetes installation.. ${NC}\n"
kubectl version  
echo -e "\n${BLUE}Kubernetes successfully installed... \n"

# The following golang installation is only for edgeNode with amd64 architecture
echo -e "\n${GREEN} Installing Golang... ${NC}\n"
cd /root/
rm go1.16.linux-amd64.tar.gz
wget https://golang.org/dl/go1.16.linux-amd64.tar.gz || checkErr "Downloading Golang"
tar -C /usr/ -xzf /root/go1.16.linux-amd64.tar.gz || checkErr "Extracting Golang package"
echo -e "\n${BLUE}Golang successfully installed... \n"

# add environment variables
echo -e "\n{GREEN}Adding Go path environment variables into system...${NC}\n"
export PATH=$PATH:/snap/bin:/usr/go/bin
export GOPATH=/usr/go
export GOBIN=$GOPATH/bin
export PATH=$PATH:$GOBIN:$GOROOT/bin
export GO111MODULE=auto
echo "export PATH=\$PATH:/snap/bin:/usr/go/bin
export GOPATH=/usr/go
export GOBIN=\$GOPATH/bin
export PATH=\$PATH:\$GOBIN:\$GOROOT/bin
export GO111MODULE=auto" | tee -a /etc/bash.bashrc || checkErr "Adding path environment variables into system"
. /etc/bash.bashrc || checkErr "Loading environment variables..."
echo -e "\n${BLUE}Go path environment variables successfully loaded...${NC}\n"

# install Kubeedge v1.6.0
echo -e "\n${GREEN}Installing KubeEdge v1.6.0...${NC}\n"
rm -rf /etc/kubeedge
mkdir -p /etc/kubeedge/ || checkErr "Creating kubeedge directory"
cd /etc/kubeedge

The following Kubeedge version is only for CloudNode with AMD64 architecture
echo -e "\n${GREEN}Downloading KubeEdge v1.6.0...${NC}\n"
rm kubeedge-v1.6.0-linux-amd64.tar.gz
wget https://github.com/kubeedge/kubeedge/releases/download/v1.6.0/kubeedge-v1.6.0-linux-amd64.tar.gz || checkErr "Error downloading Kubeedge ..."
echo -e "\n${BLUE}Kubeedge successfully downloaded...${NC}\n"

echo -e "\n${GREEN}Downloading KubeEdge git repo...${NC}\n"
rm -rf $GOPATH/src/github.com/kubeedge/kubeedge
git clone https://github.com/kubeedge/kubeedge $GOPATH/src/github.com/kubeedge/kubeedge || checkErr "Downloading Kubeedge git repo"
echo -e "\n${BLUE}Kubeedge git repo successfully downloaded...${NC}\n"

# Since the Raspberry Pi has a difference architecture than the Cloud core node, we have to compile Keadm separately on this node
echo -e "\n${GREEN}Compiling Keadm...${NC}\n"
cd $GOPATH/src/github.com/kubeedge/kubeedge  || checkErr "Going into Kubeedge directory"
make all WHAT=keadm || checkErr "Error compiling Kubeedge ..."
cp ./_output/local/bin/keadm /usr/bin/ || checkErr "Copying keadm into /usr/bin/ "
echo -e "\n${BLUE}Keadm has been successfully compiled...${NC}\n"






