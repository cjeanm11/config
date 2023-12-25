#!/bin/bash

IFS=$'\n\t'

os_setup() {
    echo "Detected OS: $(uname)"
    if [[ "$(uname)" == "Darwin" ]]; then
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        echo "Installing Ansible, curl, and git..."
        brew install ansible curl git lsof
        ansible-playbook ~/ansible/init.yml
    elif [[ "$(uname)" == "Linux" ]]; then
        sudo apt update && sudo apt install -y \
            software-properties-common curl git zsh sudo lsof build-essential \
            && sudo apt-add-repository -y ppa:ansible/ansible \
            && sudo apt install -y ansible
        ansible-playbook ~/ansible/init.yml
    else
        echo "Unsupported operating system. This script only runs on macOS or Linux."
        exit 1
    fi
}
