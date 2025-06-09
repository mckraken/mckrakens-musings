ARG VARIANT="3.13"
# FROM mcr.microsoft.com/devcontainers/python:${VARIANT} AS builder
# FROM python:${VARIANT}-alpine AS builder
FROM python:${VARIANT}-bookworm AS builder


SHELL ["/bin/bash", "-c"]
# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG NODE_VERSION="none"
RUN if [ "${NODE_VERSION}" != "none" ]; then su vscode -c "umask 0002 && . /usr/local/share/nvm/nvm.sh && nvm install ${NODE_VERSION} 2>&1"; fi
ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode
ARG PYTHON_VERSION="3.13"

RUN DEBIAN_FRONTEND=noninteractive && \
    apt update && \
    apt -y dist-upgrade && \
    apt -y install jq curl

# Install tenv for terraform/tofu mgmt
RUN TENV_VERSION=$(curl --silent https://api.github.com/repos/tofuutils/tenv/releases/latest | jq -r .tag_name) && \
    MACH_ARCH=$(dpkg --print-architecture) && \
    echo ${MACH_ARCH} && \
    curl -O -L "https://github.com/tofuutils/tenv/releases/download/${TENV_VERSION}/tenv_${TENV_VERSION}_${MACH_ARCH}.deb" && \
    dpkg -i "tenv_${TENV_VERSION}_${MACH_ARCH}.deb"

RUN adduser vscode
# This user should be the same as "remoteUser" in the devcontainer.json file
ARG USERNAME="vscode"

USER ${USERNAME}
WORKDIR /home/${USERNAME}/
ARG HOME="/home/${USERNAME}"

# Install tflint
RUN TFLINT_VERSION=$(curl --silent https://api.github.com/repos/terraform-linters/tflint/releases/latest | jq -r .tag_name) && \
    MACH_ARCH=$(dpkg --print-architecture) && \
    echo ${MACH_ARCH} && \
    curl -O -L "https://github.com/terraform-linters/tflint/releases/download/${TFLINT_VERSION}/tflint_linux_${MACH_ARCH}.zip" && \
    unzip tflint_linux_${MACH_ARCH}.zip && \
    mkdir -p ${HOME}/.local/bin && \
    mv tflint ${HOME}/.local/bin

# Install rust compliler for checkov
RUN curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- --default-toolchain stable -y
ENV PATH="${PATH}:${HOME}/.cargo/bin"

ENV PATH="${HOME}/.local/bin:$PATH"

# Install needed python packages
COPY --chown=${USERNAME} requirements.txt /tmp/pip-tmp/
RUN pip3 --disable-pip-version-check --no-cache-dir install --user -r /tmp/pip-tmp/requirements.txt
COPY --chown=${USERNAME} .pre-commit-config.yaml .
RUN git init && \
    pre-commit install-hooks && \
    rm -rf .git && \
    rm -rf /tmp/pip-tmp
COPY --chown=${USERNAME} .opentofu-version .terraform-version ./
RUN tenv tofu install && \
    tenv tf install

# FROM mcr.microsoft.com/devcontainers/python:${VARIANT} AS dev-container
# FROM python:${VARIANT}-alpine AS dev-container
FROM python:${VARIANT}-slim AS dev-container

SHELL ["/bin/bash", "-c"]
# [Choice] Node.js version: none, lts/*, 16, 14, 12, 10
ARG PYTHON_VERSION="3.13"

USER root
RUN DEBIAN_FRONTEND=noninteractive && \
    apt-get update && \
    apt-get -y dist-upgrade && \
    type -p curl >/dev/null || (apt install curl -y) && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" > /etc/apt/sources.list.d/github-cli.list > /dev/null && \
    apt update && \
    apt install git gh -y

COPY --from=builder /usr/bin/tenv /usr/bin/tofu /usr/bin/tf /usr/bin/terraform /usr/bin/terragrunt /usr/bin/

RUN adduser vscode
# This user should be the same as "remoteUser" in the devcontainer.json file
ARG USERNAME="vscode"
USER ${USERNAME}
WORKDIR /home/${USERNAME}/
ARG HOME="/home/${USERNAME}"

# Install packages from builder stage
COPY --from=builder --chown=${USERNAME} ${HOME}/.local ${HOME}/.local
COPY --from=builder --chown=${USERNAME} ${HOME}/.cache/pre-commit ${HOME}/.cache/pre-commit
COPY --from=builder --chown=${USERNAME} ${HOME}/.tenv ${HOME}/.tenv

# Set up alias for devcontainer commands using the alternate Makefile
RUN echo 'alias make="make -f Makefile.container"' >> ~/.profile && \
    echo 'alias make="make -f Makefile.container"' >> ~/.bash_aliases && \
    curl -s https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash && \
    echo '. ~/.git-completion.bash' >> ~/.bashrc && \
    echo 'eval "$(gh completion -s bash)"' >> ~/.bashrc && \
    echo 'PATH="$HOME/.local/bin:$PATH"' >> ~/.bashrc

ENV PATH="${HOME}/.local/bin:$PATH"
