 #!/bin/bash

echo "Reverse SSH Setup Script"

# Prompt for user input
read -rp "Enter remote server username: " REMOTE_USER
read -rp "Enter the system name for reference: " KEY_NAME
read -rp "Enter remote server address (e.g., example.com): " REMOTE_HOST
read -rp "Enter remote SSH port (default 22): " REMOTE_PORT
REMOTE_PORT=${REMOTE_PORT:-22}  # Default to 22 if empty
read -rp "Enter local port on the remote server to access this machine (e.g., 2222): " LOCAL_PORT

SSH_KEY="$HOME/.ssh/id_rsa"
SERVICE_NAME="reverse-ssh"

# Check if SSH is installed
if ! command -v ssh &> /dev/null; then
    echo "Installing OpenSSH..."
    sudo apt-get update && sudo apt-get install -y openssh-server
fi

# Generate SSH key if not exists
if [ ! -f "$SSH_KEY" ]; then
    echo "Generating SSH key..."
    ssh-keygen -t rsa -b 4096 -f "$SSH_KEY" -N "" -C "$KEY_NAME"
fi 

# Display public key and prompt user to add it to the remote server
echo -e "\nAdd the following SSH public key to $REMOTE_USER@$REMOTE_HOST (~/.ssh/authorized_keys):"
cat "$SSH_KEY.pub"
echo -e "\nOnce added, press ENTER to continue..."
read -r

# Test SSH connection
echo "Testing SSH connection..."
if ! ssh -o StrictHostKeyChecking=no -i "$SSH_KEY" "$REMOTE_USER@$REMOTE_HOST" "echo 'Connection successful'"; then
    echo "SSH connection failed. Make sure the key is added to ~/.ssh/authorized_keys on the remote server."
    exit 1
fi

# Create systemd service file dynamically
echo "Creating systemd service..."
SERVICE_FILE="/etc/systemd/system/$SERVICE_NAME.service"

sudo bash -c "cat > $SERVICE_FILE" <<EOF
[Unit]
Description=Reverse SSH Tunnel
After=network.target

[Service]
User=$USER
ExecStart=/usr/bin/ssh -N -R $LOCAL_PORT:localhost:22 -i $SSH_KEY $REMOTE_USER@$REMOTE_HOST -p $REMOTE_PORT
Restart=on-failure
RestartSec=30s
StartLimitBurst=5
TimeoutStartSec=60s
StartLimitInterval=200

[Install]
WantedBy=multi-user.target
EOF

# Reload systemd, enable and start service
echo "Enabling and starting the reverse SSH service..."
sudo systemctl daemon-reload
sudo systemctl enable "$SERVICE_NAME"
sudo systemctl start "$SERVICE_NAME"

echo "Reverse SSH setup completed! It will persist across reboots."
echo "You can now connect to this machine from the remote server using:"
echo "ssh -p $LOCAL_PORT localhost"
