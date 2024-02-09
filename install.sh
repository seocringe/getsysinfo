#!/bin/bash

# Ensure the script is run as root
if [ "$(id -u)" -ne 0 ]; then
  echo "Please run as root"
  exit 1
fi

# Define the installation directory
INSTALL_DIR="/usr/local/bin"

# Copy scripts to the installation directory
cp src/getsysinfo.zsh "$INSTALL_DIR/getsysinfo"
cp src/update_getsysinfo.zsh "$INSTALL_DIR/update_getsysinfo"

# Set executable permissions
chmod +x "$INSTALL_DIR/getsysinfo"
chmod +x "$INSTALL_DIR/update_getsysinfo"

echo "getsysinfo and update_getsysinfo have been installed successfully."
