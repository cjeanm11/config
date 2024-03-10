#!/bin/bash

IFS=$'\n\t'   

os_setup() {
    echo "Detected OS: $(uname)"

    if [[ "$(uname)" == "Darwin" ]]; then
        if ! command -v brew &>/dev/null; then
            echo "Homebrew is not installed. Installing Homebrew on macOS..."
            echo "This will run a script from the internet. Proceed? [y/N]"
            read -r confirmation
            if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
                echo "Installation aborted."
                exit 1
            fi
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        else
            echo "Homebrew is already installed."
        fi
        
        echo "Installing Ansible, curl, and git..."
        brew install ansible curl git lsof

    elif [[ "$(uname)" == "Linux" ]]; then
        echo "Updating package list and installing necessary packages on Linux..."
        echo "This will install packages using apt. Proceed? [y/N]"
        read -r confirmation
        if [[ "$confirmation" != "y" && "$confirmation" != "Y" ]]; then
            echo "Installation aborted."
            exit 1
        fi

        sudo apt update && sudo apt install -y \
            software-properties-common curl git zsh sudo lsof build-essential \
            && sudo apt-add-repository -y ppa:ansible/ansible \
            && sudo apt install -y ansible

    else
        echo "Unsupported operating system. This script only runs on macOS or Linux."
        exit 1
    fi
}
