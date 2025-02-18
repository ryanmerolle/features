#!/usr/bin/env bash
# This code was generated using the devcontainer-feature cookiecutter.
# For more information: https://github.com/devcontainers-contrib/cookiecutter-devcontainers-feature
set -e
   

# pipx package parameters for MKDocs
INCLUDEMKDOCS="true"
MKDOCSVERSION=${VERSION:-"latest"}

    # pipx injection parameters for MKDocs env   
    INCLUDEPLUGINMKDOCSMATERIAL=${INCLUDEPLUGINMKDOCSMATERIAL:-"true"}
    PLUGINMKDOCSMATERIALVERSION=${PLUGINMKDOCSMATERIALVERSION:-"latest"}   
    INCLUDEPLUGINPYMDOWNEXTENSIONS=${INCLUDEPLUGINPYMDOWNEXTENSIONS:-"true"}
    PLUGINPYMDOWNEXTENSIONSVERSION=${PLUGINPYMDOWNEXTENSIONSVERSION:-"latest"}   
    INCLUDEPLUGINMKDOCSTRINGS=${INCLUDEPLUGINMKDOCSTRINGS:-"true"}
    PLUGINMKDOCSTRINGSVERSION=${PLUGINMKDOCSTRINGSVERSION:-"latest"}   
    INCLUDEPLUGINMKDOCSMONOREPOPLUGIN=${INCLUDEPLUGINMKDOCSMONOREPOPLUGIN:-"true"}
    PLUGINMKDOCSMONOREPOPLUGINVERSION=${PLUGINMKDOCSMONOREPOPLUGINVERSION:-"latest"}   
    INCLUDEPLUGINMKDOCSPDFEXPORTPLUGIN=${INCLUDEPLUGINMKDOCSPDFEXPORTPLUGIN:-"true"}
    PLUGINMKDOCSPDFEXPORTPLUGINVERSION=${PLUGINMKDOCSPDFEXPORTPLUGINVERSION:-"latest"}   
    INCLUDEPLUGINMKDOCSAWESOMEPAGESPLUGIN=${INCLUDEPLUGINMKDOCSAWESOMEPAGESPLUGIN:-"true"}
    PLUGINMKDOCSAWESOMEPAGESPLUGINVERSION=${PLUGINMKDOCSAWESOMEPAGESPLUGINVERSION:-"latest"}

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



 
# code bellow is mostly taken from the base python feature https://raw.githubusercontent.com/devcontainers/features/main/src/python/install.sh
updaterc() {
    echo "Updating /etc/bash.bashrc and /etc/zsh/zshrc..."
    if [[ "$(cat /etc/bash.bashrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/bash.bashrc
    fi
    if [ -f "/etc/zsh/zshrc" ] && [[ "$(cat /etc/zsh/zshrc)" != *"$1"* ]]; then
        echo -e "$1" >> /etc/zsh/zshrc
    fi
}
# settings these will allow us to clean leftovers later on
export PYTHONUSERBASE=/tmp/pip-tmp
export PIP_CACHE_DIR=/tmp/pip-tmp/cache
# install python if does not exists
if ! type pip3 > /dev/null 2>&1; then
    echo "Installing python3..."
    # If the python feature script had option to install pipx without the 
    # additional tools we would have used that, but since it doesnt 
    # we have to disable it with INSTALLTOOLS=false and install
    # pipx manually later on
    check_packages curl
    export VERSION="system" 
    export INSTALLTOOLS="false"
    curl -fsSL https://raw.githubusercontent.com/devcontainers/features/main/src/python/install.sh | $SHELL
fi
# install pipx if not exists
export PIPX_HOME=${PIPX_HOME:-"/usr/local/py-utils"}
export PIPX_BIN_DIR="${PIPX_HOME}/bin"

if ! type pipx > /dev/null 2>&1; then
    USERNAME=""
    POSSIBLE_USERS=("vscode" "node" "codespace" "$(awk -v val=1000 -F ":" '$3==val{print $1}' /etc/passwd)")
    for CURRENT_USER in "${POSSIBLE_USERS[@]}"; do
        if id -u ${CURRENT_USER} > /dev/null 2>&1; then
            USERNAME=${CURRENT_USER}
            break
        fi
    done
    if [ "${USERNAME}" = "" ]; then
        USERNAME=root
    fi

    PATH="${PATH}:${PIPX_BIN_DIR}"

    # Create pipx group, dir, and set sticky bit
    if ! cat /etc/group | grep -e "^pipx:" > /dev/null 2>&1; then
        groupadd -r pipx
    fi
    usermod -a -G pipx ${USERNAME}
    umask 0002
    mkdir -p ${PIPX_BIN_DIR}
    chown -R "${USERNAME}:pipx" ${PIPX_HOME}
    chmod -R g+r+w "${PIPX_HOME}" 
    find "${PIPX_HOME}" -type d -print0 | xargs -0 -n 1 chmod g+s

    pip3 install --disable-pip-version-check --no-cache-dir --user pipx 2>&1
    /tmp/pip-tmp/bin/pipx install --pip-args=--no-cache-dir pipx
    PIPX_COMMAND=/tmp/pip-tmp/bin/pipx
else
    PIPX_COMMAND=pipx
fi

#

if [ "$INCLUDEMKDOCS" = "true" ]; then
    if [ "$MKDOCSVERSION" =  "latest" ]; then
        util_command="mkdocs"
    else
        util_command="mkdocs==$MKDOCSVERSION"
    fi
    "${PIPX_COMMAND}" install --system-site-packages --force --pip-args '--no-cache-dir --force-reinstall' ${util_command}

    if [ "$INCLUDEPLUGINMKDOCSMATERIAL" =  "true" ]; then
        if [ "$PLUGINMKDOCSMATERIALVERSION" =  "latest" ]; then
            util_command="mkdocs-material"
        else
            util_command="mkdocs-material==$PLUGINMKDOCSMATERIALVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

    if [ "$INCLUDEPLUGINPYMDOWNEXTENSIONS" =  "true" ]; then
        if [ "$PLUGINPYMDOWNEXTENSIONSVERSION" =  "latest" ]; then
            util_command="pymdown-extensions"
        else
            util_command="pymdown-extensions==$PLUGINPYMDOWNEXTENSIONSVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

    if [ "$INCLUDEPLUGINMKDOCSTRINGS" =  "true" ]; then
        if [ "$PLUGINMKDOCSTRINGSVERSION" =  "latest" ]; then
            util_command="mkdocstrings[crystal,python]"
        else
            util_command="mkdocstrings[crystal,python]==$PLUGINMKDOCSTRINGSVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

    if [ "$INCLUDEPLUGINMKDOCSMONOREPOPLUGIN" =  "true" ]; then
        if [ "$PLUGINMKDOCSMONOREPOPLUGINVERSION" =  "latest" ]; then
            util_command="mkdocs-monorepo-plugin"
        else
            util_command="mkdocs-monorepo-plugin==$PLUGINMKDOCSMONOREPOPLUGINVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

    if [ "$INCLUDEPLUGINMKDOCSPDFEXPORTPLUGIN" =  "true" ]; then
        if [ "$PLUGINMKDOCSPDFEXPORTPLUGINVERSION" =  "latest" ]; then
            util_command="mkdocs-pdf-export-plugin"
        else
            util_command="mkdocs-pdf-export-plugin==$PLUGINMKDOCSPDFEXPORTPLUGINVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

    if [ "$INCLUDEPLUGINMKDOCSAWESOMEPAGESPLUGIN" =  "true" ]; then
        if [ "$PLUGINMKDOCSAWESOMEPAGESPLUGINVERSION" =  "latest" ]; then
            util_command="mkdocs-awesome-pages-plugin"
        else
            util_command="mkdocs-awesome-pages-plugin==$PLUGINMKDOCSAWESOMEPAGESPLUGINVERSION"
        fi
    pipx inject mkdocs ${util_command}
    fi

fi


updaterc "export PIPX_HOME=\"${PIPX_HOME}\""
updaterc "export PIPX_BIN_DIR=\"${PIPX_BIN_DIR}\""
updaterc "if [[ \"\${PATH}\" != *\"\${PIPX_BIN_DIR}\"* ]]; then export PATH=\"\${PATH}:\${PIPX_BIN_DIR}\"; fi"

# cleaning after pip
rm -rf /tmp/pip-tmp




# Clean up
rm -rf /var/lib/apt/lists/*

echo "Done!"