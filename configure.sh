#!/bin/bash
if [ "$#" -eq 0 ] || ([ "$1" != "local.yml" ] && [ "$1" != "fauna.yml" ]); then
    echo "Usage: ./configure.sh <local.yml|dev.yml> [options]"
    exit 1
fi

git pull origin main
ansible-playbook $@ --ask-become-pass --ask-vault-pass
