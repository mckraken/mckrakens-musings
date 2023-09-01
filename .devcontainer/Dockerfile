# See here for image contents: https://github.com/microsoft/vscode-dev-containers/tree/v0.224.3/containers/python-3/.devcontainer/base.Dockerfile

# [Choice] Python version (use -bullseye variants on local arm64/Apple Silicon): 3, 3.10, 3.9, 3.8, 3.7, 3.6, 3-bullseye, 3.10-bullseye, 3.9-bullseye, 3.8-bullseye, 3.7-bullseye, 3.6-bullseye, 3-buster, 3.10-buster, 3.9-buster, 3.8-buster, 3.7-buster, 3.6-buster
ARG VARIANT="3.11"
FROM mcr.microsoft.com/devcontainers/python:${VARIANT}

SHELL ["/bin/bash", "-c"]
# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi

RUN apt update && \
    apt -y dist-upgrade && \
    type -p curl >/dev/null || (apt install curl -y) && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install gh -y

# This user should be the same as "remoteUser" in the devcontainer.json file
ARG USERNAME="vscode"

USER ${USERNAME}
WORKDIR /home/${USERNAME}/

# Set up alias for devcontainer commands using the alternate Makefile
RUN echo 'alias make="make -f Makefile.container"' >> ~/.profile && \
    echo 'alias make="make -f Makefile.container"' >> ~/.bash_aliases && \
    curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash && \
    echo '. ~/.git-completion.bash' >> ~/.bashrc && \
    echo 'eval "$(gh completion -s bash)"' >> ~/.bashrc

# Install needed python packages
COPY --chown=${USERNAME} requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install --user -r /tmp/pip-tmp/requirements.txt
RUN rm -r /tmp/pip-tmp
