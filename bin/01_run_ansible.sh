#!/bin/bash

# Make sure the script works regardless of which directory it is called from
cd "${0%/*}/.."

printf "\n\n############### Installing Linux software requirements ###############\n"

sudo dnf install -y python39 curl python3-libselinux python39-devel

# Dirty hack to get selinux to work with Python
if [[ ! -L "/usr/lib/python3.9/site-packages/selinux" ]]; then
    sudo ln -s /usr/lib64/python3.6/site-packages/selinux /usr/lib/python3.9/site-packages/selinux
fi

printf "\n\n############### Installing Poetry ###############\n"
curl -sSL https://install.python-poetry.org | python3 -
PATH=$HOME/.local/bin:$PATH; export PATH

printf "\n\n############### Installing Ansible ###############\n"
poetry install

printf "\n\n############### Run Ansible ###############\n"
poetry run ansible-playbook --inventory ansible/inventory/hosts.yaml ansible/playbook.yaml --check
