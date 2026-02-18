FROM mcr.microsoft.com/powershell:7.4-ubuntu-22.04

ARG DEBIAN_FRONTEND=noninteractive
ARG USERNAME=vscode
ARG USER_UID=1000
ARG USER_GID=1000

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
        neovim \
        git \
        curl \
        ripgrep \
        fd-find \
        python3 \
        python3-pip \
        nodejs \
        npm \
        xclip \
        ca-certificates \
        locales \
        sudo \
        less \
        unzip \
    && rm -rf /var/lib/apt/lists/*

RUN locale-gen en_US.UTF-8
ENV LANG=en_US.UTF-8
ENV LANGUAGE=en_US:en
ENV LC_ALL=en_US.UTF-8
ENV TERM=xterm-256color
ENV SOURCE_REPO_DIR=/repo-src
ENV TARGET_WORKSPACE_DIR=/workspaces/PowerShellVIM

# fd-find installs as fdfind on Ubuntu; expose fd for plugin/tool compatibility.
RUN ln -sf /usr/bin/fdfind /usr/local/bin/fd

RUN if ! getent group "${USER_GID}" >/dev/null; then groupadd --gid "${USER_GID}" "${USERNAME}"; fi \
    && if ! id -u "${USERNAME}" >/dev/null 2>&1; then useradd --uid "${USER_UID}" --gid "${USER_GID}" -m "${USERNAME}"; fi \
    && echo "${USERNAME} ALL=(root) NOPASSWD:ALL" > "/etc/sudoers.d/${USERNAME}" \
    && chmod 0440 "/etc/sudoers.d/${USERNAME}"

RUN mkdir -p /workspaces/PowerShellVIM /usr/local/share/powershell/Modules \
    && chown -R "${USERNAME}:${USERNAME}" /workspaces /usr/local/share/powershell/Modules

WORKDIR /workspaces/PowerShellVIM
USER ${USERNAME}

COPY --chown=${USERNAME}:${USERNAME} scripts/container-bootstrap.sh /usr/local/bin/container-bootstrap.sh
COPY --chown=${USERNAME}:${USERNAME} scripts/install-optional-kickstart.sh /usr/local/bin/install-optional-kickstart.sh
RUN chmod +x /usr/local/bin/container-bootstrap.sh /usr/local/bin/install-optional-kickstart.sh

CMD ["/bin/bash"]
