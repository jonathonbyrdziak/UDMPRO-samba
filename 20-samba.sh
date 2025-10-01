#!/bin/sh

# variables
username="user"
password="password"
share_name="Shared"
container_name="samba"

# Function to log and check command success
check_command() {
    echo "Running: $1"
    eval "$1" 2>&1
    if [ $? -ne 0 ]; then
        echo "Error: Command failed - $1"
        exit 1
    fi
    echo "Success: $1"
}

# Prerequisite checks
echo "Checking prerequisites..."

# Check if Docker is installed and running
check_command "docker --version"
check_command "systemctl is-active docker"

# Check if /volume1 is mounted and writable
check_command "test -d /volume1 && touch /volume1/test_write && rm /volume1/test_write"

# creating shared directory if it doesn't exist
FILE=/volume1/share

if [ ! -d "$FILE" ]; then
    echo "Creating directory: $FILE"
    check_command "mkdir -p \"$FILE\""
    check_command "chmod 777 \"$FILE\""
else
    echo "Directory exists: $FILE"
fi

# Check if ports are free
for port in 139 445 137 138; do
    check_command "netstat -tuln | grep -q :$port && echo 'Port $port in use' && exit 1 || echo 'Port $port free'"
done

# starting the container
if [ "$(docker ps -a -q -f name=${container_name})" ]; then
    echo "Existing container found: Removing ${container_name}"
    check_command "docker rm -f ${container_name}"
else
    echo "No existing container: ${container_name}"
fi

# Pull image if not present
if ! docker images | grep -q dperson/samba; then
    echo "Pulling image: dperson/samba"
    check_command "docker pull dperson/samba"
else
    echo "Image exists: dperson/samba"
fi

# Run container
echo "Starting container: ${container_name}"
check_command "docker run --name ${container_name} -p 139:139 -p 445:445 -p 137:137/udp -p 138:138/udp -v \"$FILE:/share\" -d dperson/samba -n -u \"${username};${password}\" -s \"${share_name};/share;yes;no;no;all;none;none;Shared files\" -p -r -g \"fruit:model = MacPro7,1@ECOLOR=226,226,224\" -g \"fruit:resource = xattr\" -g \"fruit:metadata = stream\""