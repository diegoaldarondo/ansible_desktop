#!/bin/bash

git pull origin main
ansible-playbook local.yml --ask-become-pass