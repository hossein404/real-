#!/bin/bash

# Exit on any error
set -e

# Function to check if a command exists
command_exists () {
    type "$1" &> /dev/null ;
}

# Update package list and install necessary packages
sudo apt-get update

# Check if Python is installed
if ! command_exists python3 ; then
    echo "Python3 is not installed. Installing Python3..."
    sudo apt-get install -y python3
fi

# Check if pip is installed
if ! command_exists pip3 ; then
    echo "pip3 is not installed. Installing pip3..."
    sudo apt-get install -y python3-pip
fi

# Check if virtualenv is installed
if ! command_exists virtualenv ; then
    echo "virtualenv is not installed. Installing virtualenv..."
    pip3 install virtualenv
fi

# Clone the GitHub repository
REPO_URL="https://github.com/mtashani/real-upload.gits"
CLONE_DIR="/opt/Real-Update"

if [ ! -d "$CLONE_DIR" ] ; then
    echo "Cloning the repository..."
    git clone "$REPO_URL" "$CLONE_DIR"
fi

cd "$CLONE_DIR"

# Create a virtual environment
if [ ! -d "env" ] ; then
    echo "Creating virtual environment..."
    virtualenv env
fi

# Activate the virtual environment
echo "Activating virtual environment..."
source env/bin/activate

# Install requirements
echo "Installing requirements..."
pip install -r requirements.txt

# Deactivate the virtual environment
echo "Deactivating virtual environment..."
deactivate

# Create systemd service file
SERVICE_FILE="/etc/systemd/system/realUpload.service"

echo "Creating systemd service file..."

sudo bash -c "cat > $SERVICE_FILE" <<EOL
[Unit]
Description=Run Python script at startup
After=network.target

[Service]
User=$USER
WorkingDirectory=$(pwd)
ExecStart=$(pwd)/env/bin/python $(pwd)/realUpload.py
Restart=always

[Install]
WantedBy=multi-user.target
EOL

# Reload systemd manager configuration
echo "Reloading systemd manager configuration..."
sudo systemctl daemon-reload

# Enable the service to start on boot
echo "Enabling the service to start on boot..."
sudo systemctl enable realUpload.service

# Start the service immediately
echo "Starting the service..."
sudo systemctl start realUpload.service

# Check the status of the service
sudo systemctl status realUpload.service
