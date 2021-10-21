#/bin/bash

set -e 

rm -rf /etc/kubeedge
rm -rf /usr/go/src/github.com/kubeedge/kubeedge

echo "y" | keadm reset

kind delete cluster 
