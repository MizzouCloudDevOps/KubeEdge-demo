#/bin/bash

set -e

sudo su 

echo ("Updating ssh login settings ... ")
sed -i "s/#PermitRootLogin prohibit-password/PermitRootLogin yes/g" /etc/ssh/sshd_config 

sed -i "s/PasswordAuthentication no/PasswordAuthentication yes/g" /etc/ssh/sshd_config

echo ("Restarting ssh daemon ... ")
systemctl restart sshd

# change password
echo ("please create your password for root user ... ")
passwd

echo ("System preparation done... ")
