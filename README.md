# Reverse SSH Tunnel Setup Script

## Overview
This script automates the setup of a **persistent Reverse SSH Tunnel** using `systemd`, allowing remote access to a local machine via SSH. It ensures that the connection remains active across reboots, providing a reliable way to access a machine behind a firewall or NAT.

## Features
- **Automates Reverse SSH Tunnel setup**
- **Generates SSH keys if needed**
- **Creates a persistent systemd service**
- **Auto-reconnects on failure**
- **Works with any Linux system using systemd**

## How It Works
This script:
1. Prompts the user for SSH details (remote user, host, ports).
2. Checks for and installs OpenSSH.
3. Generates an SSH key (if missing) and displays the public key for manual addition to the remote server.
4. Tests the SSH connection.
5. Creates a systemd service to maintain the reverse SSH tunnel.
6. Enables and starts the systemd service to keep the tunnel active.

## Prerequisites
- A **remote server** with SSH access.
- The local machine should have `systemd` and `bash` installed.
- **SSH key-based authentication** should be enabled on the remote server.

## Installation & Usage
1. **Download the script**:
   ```sh
   curl -O https://raw.githubusercontent.com/SaraanshSharma/Reverse-SSH-Script/refs/heads/main/reverse_ssh.sh
   chmod +x reverse-ssh.sh
   ```
2. **Run the script**:
   ```sh
   ./reverse-ssh.sh
   ```
3. **Follow the prompts** to enter the required SSH details.
4. **Copy the displayed public key** to the remote server’s `~/.ssh/authorized_keys`.
5. **Verify the setup**:
   ```sh
   systemctl status reverse-ssh
   ```
6. **Access the machine from the remote server**:
   ```sh
   ssh -p <LOCAL_PORT> localhost
   ```

## Systemd Service Details
The script creates a service file at `/etc/systemd/system/reverse-ssh.service` with the following key features:
- **Auto-restart** on failure
- **Waits for the network** before starting
- **Runs persistently in the background**

### Managing the Service
- **Check status**:
  ```sh
  systemctl status reverse-ssh
  ```
- **Restart manually**:
  ```sh
  systemctl restart reverse-ssh
  ```
- **Disable the service**:
  ```sh
  systemctl disable reverse-ssh
  ```
- **Remove the service**:
  ```sh
  sudo rm /etc/systemd/system/reverse-ssh.service
  sudo systemctl daemon-reload
  ```

## Security Considerations
- Use **strong SSH keys** and restrict access.
- Limit the remote server’s ability to connect using `AllowUsers` in `sshd_config`.
- Use **firewall rules** to restrict access to the SSH port.
- Consider using `fail2ban` to prevent brute-force attacks.

## Troubleshooting
- **If SSH connection fails:**
  - Ensure the **public key is added** to the remote server.
  - Check if the **remote server allows incoming SSH connections**.
  - Verify that the correct **ports are open**.

- **If the systemd service does not start:**
  - Run `journalctl -xe -u reverse-ssh` to check logs.
  - Ensure `ssh` is installed and available.
  - Check `ExecStart` in the service file for typos.

## License
This script is released under the MIT License. Feel free to modify and distribute.

## Author
[Saraansh Sharma]

## Contributions
Contributions are welcome! Please open an issue or submit a pull request on GitHub.

