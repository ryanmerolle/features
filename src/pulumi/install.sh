#!/usr/bin/env bash

PULUMI_VERSION="${VERSION:-"latest"}"
BASH_COMPLETION="${BASHCOMPLETION:-"true"}"

set -e

# Clean up 
rm -rf /var/lib/apt/lists/*

if [ "$(id -u)" -ne 0 ]; then
    echo -e 'Script must be run as root. Use sudo, su, or add "USER root" to your Dockerfile before running this script.'
    exit 1
fi

# Checks if packages are installed and installs them if not
check_packages() {
    if ! dpkg -s "$@" > /dev/null 2>&1; then
        if [ "$(find /var/lib/apt/lists/* | wc -l)" = "0" ]; then
            echo "Running apt-get update..."
            apt-get update -y
        fi
        apt-get -y install --no-install-recommends "$@"
    fi
}

# making sure curl is there, you never know
check_packages curl

# making sure shell configs are there, as pulumi installation script rely on 
# their existance in order to add its binary to the user's PATH
if [ ! -f "${HOME}/.bashrc" ] || [ ! -s "${HOME}/.bashrc" ] ; then
    cp  /etc/skel/.bashrc "${HOME}/.bashrc"
fi
if  [ ! -f "${HOME}/.profile" ] || [ ! -s "${HOME}/.profile" ] ; then
    cp  /etc/skel/.profile "${HOME}/.profile"
fi

# using "... | $SHELL" instead of the documented "... | sh" in order to support .bashrc/.zshrc as 
# pulumi installation script will rely on $SHELL variable (and has no support for SHELL=sh yet)
if [ "${VERSION}" == "latest" ]; then
	curl -fsSL https://get.pulumi.com | $SHELL
else
	curl -fsSL https://get.pulumi.com | $SHELL -s -- --version $VERSION
fi

# if pulumi script failed to insert to path, fallback to soft linking it in /usr/local/bin 
exec $SHELL
if ! [ -x "$(command -v pulumi)" ]; then
    ln -s $HOME/.pulumi/bin/pulumi /usr/local/bin/pulumi
fi

# finally we are adding bash completion. zsh support will be added soon
if [[ "${BASH_COMPLETION}" = "true" ]] ; then
    pulumi gen-completion bash > /etc/bash_completion.d/pulumi
fi

# Clean up 
rm -rf /var/lib/apt/lists/*

echo "Done!"