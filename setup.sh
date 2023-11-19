#!/bin/bash
set -e

sudo apt update
sudo apt upgrade -y
sudo apt install -y git ansible

# Set email address for the SSH key
email="diegoaldarondo@gmail.com" # Replace with your email address

git config --global user.email "$email"
git config --global user.name "Diego Aldarondo"

KNOWN_HOSTS_FILE="$HOME/.ssh/known_hosts"

# Check if GitHub is already in known_hosts
if grep -q "github.com" "$KNOWN_HOSTS_FILE"; then
    echo "GitHub is already in known_hosts."
else
    echo "Adding GitHub to known_hosts..."
    ssh-keyscan -t rsa github.com >> "$KNOWN_HOSTS_FILE"
fi

# Check for existing SSH keys
echo "Checking for existing SSH keys..."
if [ -f "$HOME/.ssh/id_ed25519" ] || [ -f "$HOME/.ssh/id_rsa" ]; then
    echo "An existing SSH key was found!"
else
    echo "No existing SSH keys found. Generating a new SSH key..."
    # Generate a new SSH key with the provided email
    ssh-keygen -t ed25519 -C "$email" -f "$HOME/.ssh/id_ed25519" -N ""
    
    # If the machine doesn't support the ed25519 algorithm, use RSA
    if [ $? -ne 0 ]; then
        echo "ed25519 is not supported, using RSA algorithm..."
        ssh-keygen -t rsa -b 4096 -C "$email" -f "$HOME/.ssh/id_rsa" -N ""
    fi

    # Start the ssh-agent in the background
    eval "$(ssh-agent -s)"
    
    # Add the SSH key to the ssh-agent
    ssh-add "$HOME/.ssh/id_ed25519" || ssh-add "$HOME/.ssh/id_rsa"
    
    echo "SSH key generation is complete. Please add the public key to GitHub."
    echo
fi
cat "$HOME/.ssh/id_ed25519.pub" || cat "$HOME/.ssh/id_rsa.pub"