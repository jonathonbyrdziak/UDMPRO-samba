#!/bin/sh

# Samba on-boot script for UDM Pro Max
# Ensures Samba is running and sharing /volume1/share

echo "Starting Samba on-boot script..."

# Check if /volume1 is mounted and writable
if [ ! -d /volume1 ]; then
    echo "Error: /volume1 not mounted"
    exit 1
fi

# Create shared directory if it doesn't exist
SHARE_DIR=/volume1/share
if [ ! -d "$SHARE_DIR" ]; then
    echo "Creating directory: $SHARE_DIR"
    mkdir -p "$SHARE_DIR"
    chmod 777 "$SHARE_DIR"
else
    echo "Directory exists: $SHARE_DIR"
fi

# Ensure Samba services are enabled and running
echo "Starting Samba services..."
systemctl enable smbd nmbd 2>/dev/null
systemctl restart smbd nmbd

# Check if services started successfully
if systemctl is-active --quiet smbd && systemctl is-active --quiet nmbd; then
    echo "Samba services are running"
    echo "Share available at: smb://$(hostname -I | awk '{print $1}')/Shared"
else
    echo "Error: Samba services failed to start"
    systemctl status smbd
    exit 1
fi