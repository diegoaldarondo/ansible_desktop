# Ansible Desktop Setup 

## Overview

This repository contains scripts and Ansible playbooks for setting up and configuring a desktop environment, specifically tailored for Debian 12 (Bookworm). It utilizes Ansible, an automation tool, to systematically install and configure various applications and settings on a local machine.

## Repository Structure

- `configure.sh`: A bash script to configure your environment by running the Ansible playbook.
- `setup.sh`: A script for installing Ansible and Git, configuring SSH keys, and setting up GitHub credentials.
- Ansible playbook files: Includes tasks for installing and configuring multiple applications and tools.

## Prerequisites

- Debian 12 (Bookworm) or a compatible Linux distribution.
- Git
- Ansible
- Sudo permissions on the local machine.

## Installation and Setup

1. **Ensure Sudo Permissions:**
   - Before running the `setup.sh` script, confirm that your user account has sudo permissions. 
   - To add sudo permissions, log in as root with `su` and run `usermod -aG sudo <username>`.

2. **Initial Setup with `setup.sh`:**
   - Execute the `setup.sh` script to install Ansible and Git.
   - The script also generates an SSH key, adds it to the ssh-agent, configures Git with your GitHub credentials, and adds github.com to your list of known hosts.
   - Add your public SSH key to your GitHub account to enable SSH authentication. For more information, see [Connecting to GitHub with SSH](https://docs.github.com/en/github/authenticating-to-github/connecting-to-github-with-ssh).

3. **Configuring the Environment:**
   - Run `bash configure.sh` to execute the Ansible playbook.
   - This will set up the specified applications and configurations on your local machine as defined in the playbook.

## Features

The Ansible playbook includes tasks for:

- Creating a `.local/bin` directory for user-specific binaries.
- Installing packages, flatpaks, and various tools like fzf, lazygit, ripgrep, and more.
- Setting up Miniconda, Visual Studio Code, and other development tools.
- Configuring GNOME settings, Apptainer, AnyDesk, VirtualBox, and managing dotfiles.

## Customization

Customize the playbook by editing the variables in the playbook file. Change the `user` variable to your username or modify paths and versions of tools as necessary.

## Updating Configuration

To update the Ansible configuration:

- Run `bash configure.sh`.


*Note: Basic understanding of Ansible and bash scripting is recommended for using and modifying this repository.*

