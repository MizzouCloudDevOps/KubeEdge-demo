#!/bin/bash

# This script automates intallation of KubeEdge Cloud core node
# Developed by Songjie Wang at the University of Missouri
# March 03, 2021

# The script require one argument, the public IP addresses of Cloud node 
# Note: This script needs to be run as root user


#check to make sure argument is provided
if [ "$#" -ne 1 ]; then
    echo -e "\n${RED}Please provide the public IP of the Cloud node. Exiting...${NC}"
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

# $1: IP of Cloud node 
cloud_IP=$1

kubeedgeVersion=1.7.1

cd /root/
# install library prerequisites
echo -e "\n${GREEN}Installing required libraries.. ${NC}\n"
apt-get -y update || checkErr "System update error..."
apt-get -y upgrade || checkErr "System upgrade error..."
apt-get -y install wget net-tools gcc make vim openssh-server docker.io || checkErr "Library installation"
echo -e "\n${BLUE}Required libraries installed... \n"

echo -e "\n${GREEN} Checking Docker installation.. ${NC}\n"
docker --version || checkErr "Docker not installed correctly..."
echo -e "\n${BLUE}Docker successfully installed... \n"

# install snap package manager
echo -e "\n${GREEN}Installing snap package manager...${NC}\n"
apt-get -y install snap
apt-get -y install snapd 
echo -e "\n${BLUE}Snap successfully installed... \n"

echo -e "\n${GREEN}Installing Kubernetes packages...${NC}\n"
snap install kubectl --classic || checkErr "Kubectl installation"
snap install kubeadm --classic || checkErr "Kubeadm installation"
# Dont install kubelet on EdgeNode
snap install kubelet --classic || checkErr "Kubelet installation"
# check Kubernetes install
echo -e "\n${GREEN} Checking Kubernetes installation.. ${NC}\n"
kubectl version  
echo -e "\n${BLUE}Kubernetes successfully installed... \n"

# The following golang installation is only for CloudNode with AMD64 architecture
echo -e "\n${GREEN} Installing Golang... ${NC}\n"
cd /root/
rm go1.15.7.linux-amd64.tar.gz
wget https://golang.org/dl/go1.15.7.linux-amd64.tar.gz || checkErr "Downloading Golang"
tar -C /usr/ -xzf /root/go1.15.7.linux-amd64.tar.gz || checkErr "Extracting Golang package"
echo -e "\n${BLUE}Golang successfully installed... \n"

# add environment variables
echo -e "\n${GREEN}Adding Go path environment variables into system...${NC}\n"
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
/bin/bash -c '. /etc/bash.bashrc' || checkErr "Loading environment variables..."
echo -e "\n${BLUE}Go path environment variables successfully loaded...${NC}\n"

# install Kubeedge v1.6.0
echo -e "\n${GREEN}Installing KubeEdge v1.6.0...${NC}\n"
mkdir -p /etc/kubeedge/ || checkErr "Error: Not able to create kubeedge directory..."
cd /etc/kubeedge

# The following Kubeedge version is only for CloudNode with AMD64 architecture
# echo -e "\n${GREEN}Downloading KubeEdge v1.6.0...${NC}\n"
# wget https://github.com/kubeedge/kubeedge/releases/download/v1.6.0/kubeedge-v1.6.0-linux-amd64.tar.gz || checkErr "Error downloading Kubeedge ..."
# echo -e "\n${BLUE}Kubeedge successfully downloaded...${NC}\n"

echo -e "\n${GREEN}Downloading KubeEdge git repo...${NC}\n"
rm -rf /usr/go/src/github.com/kubeedge/kubeedge
git clone https://github.com/kubeedge/kubeedge $GOPATH/src/github.com/kubeedge/kubeedge || checkErr "Downloading Kubeedge git repo"
echo -e "\n${BLUE}Kubeedge git repo successfully downloaded...${NC}\n"

echo -e "\n${GREEN}Compiling Keadm...${NC}\n"
cd $GOPATH/src/github.com/kubeedge/kubeedge  || checkErr "Going into Kubeedge directory"
make all WHAT=keadm || checkErr "Error compiling Kubeedge ..."
cp ./_output/local/bin/keadm /usr/bin/ || checkErr "Copying keadm into /usr/bin/ "

# setup remote login to edge node
echo -e "\n${GREEN}Press enter when prompted to create ssh key pair...${NC}\n"
ssh-keygen 
echo -e "\n${BLUE}SSH key pair created...${NC}\n"

# Install Go Kind
echo -e "\n${GREEN}Installing Go Kind ...${NC}\n"
cd /root/ || checkErr "Is there a /root directory? I am not able to go to that directory..."
GO111MODULE="on" go get sigs.k8s.io/kind@v0.7.0 || checkErr "Getting Go kind"
kind version || checkErr "Error installing kind..."
echo -e "\n${BLUE}Go Kind successfully installed...${NC}\n"

# Download kindest
echo -e "\n${GREEN}Downloading kindest Docker image...${NC}\n"
docker pull kindest/node:v1.17.2 || checkErr "Downloading kindest Docker image"
echo -e "\n${BLUE}Finished downloading kindest Docker image...${NC}\n"

# Configure kindest
echo -e "\n${GREEN}  ...${NC}\n"
tee /root/kind.yaml <<-'EOF'
kind: Cluster
apiVersion: kind.x-k8s.io/v1alpha4
networking:
  apiServerAddress: "127.0.0.1"
  apiServerPort: 6443
nodes:
  - role: control-plane
    image: kindest/node:v1.17.2
    extraPortMappings:
     - containerPort: 5000
       hostPort: 5000

EOF
echo -e "\n${BLUE}Finished creating kind yaml file...${NC}\n"

# Create KubeEdge cluster using kind
echo -e "\n${GREEN}Creating KubeEdge cluster using kind...${NC}\n"
kind create cluster --config=/root/kind.yaml || checkErr "Creating Kubernetes cluster using Kind"
echo -e "\n${BLUE}Finished creating KubeEdge cluster using kind...${NC}\n"

# Check kubernetes nodes 
echo -e "\n${GREEN}Checking Kubernetes nodes...${NC}\n"
kubectl get nodes  || checkErr "Getting kubernetes nodes"
echo -e "\n${BLUE}Finished checking Kubernetes nodes...${NC}\n"

# Create Kubeedge Cloud node 
echo -e "\n${GREEN}Creating Kubeedge cloud node...${NC}\n"
keadm init --advertise-address="$cloud_IP" --kubeedge-version="$kubeedgeVersion"  --kube-config=/root/.kube/config || checkErr "Creating Kubeedge cloud node"
echo -e "\n${BLUE}Finished creating Kubeedge cloud node...${NC}\n"

# Create certificates and keys, and copy to edge node
echo -e "\n${GREEN}Creating certificates and keys, and copying to edge node...${NC}\n"
cd $GOPATH/src/github.com/kubeedge/kubeedge/build/tools || checkErr "Going to certgen.sh directory"
./certgen.sh genCertAndKey edge || checkErr "Generating certificates and keys"
echo -e "\n${BLUE}Finished creating certificates...${NC}\n"

echo -e "\n${GREEN}The KubeEdge Cloud core node has been prepared successfully... ${NC}\n"
echo -e "\n${GREEN}Now, you should go prepare the edge node... ${NC}\n"
echo -e "\n${GREEN}And once it is done, come back to the Cloud node and run the add-edge scripts... ${NC}\n"




