#!/bin/bash

# Update package list and install OpenSSH server
sudo apt-get update
sudo apt-get install -y openssh-server

# Disable password authentication and allow only key-based authentication
sudo sed -i 's/#PasswordAuthentication yes/PasswordAuthentication no/' /etc/ssh/sshd_config
sudo sed -i 's/UsePAM yes/UsePAM no/' /etc/ssh/sshd_config

# Set up a user for SSH login
sudo useradd -m -s /bin/bash vagrant
sudo echo 'vagrant:vagrant' | sudo chpasswd
sudo sed -i 's/PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
sudo systemctl restart ssh
