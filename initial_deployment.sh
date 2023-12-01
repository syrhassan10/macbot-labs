#!/bin/bash

# Update and Upgrade Ubuntu Packagess
echo "Updating and upgrading Ubuntu packages..."
sudo apt update && sudo apt -y upgrade

# Install Python3-pip
echo "Installing Python3-pip..."
sudo apt install -y python3-pip

# Install virtualenv and virtualenvwrapper
echo "Installing virtualenv and virtualenvwrapper..."
sudo -H pip3 install virtualenv virtualenvwrapper

# Install software-properties-common
echo "Installing software-properties-common..."
sudo apt-get install -y software-properties-common

# Add Deadsnakes PPA for Python 3.7
echo "Adding deadsnakes PPA for Python 3.7..."
sudo add-apt-repository -y ppa:deadsnakes/ppa
sudo apt update

# Install Python 3.7 and Dependencies
echo "Installing Python 3.7 and dependencies..."
sudo apt-get install -y python3.7 python3.7-venv python3.7-dev

echo "Setup complete!"
