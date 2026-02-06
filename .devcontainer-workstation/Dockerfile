FROM ubuntu:24.04

RUN apt-get update && apt-get install -y --no-install-recommends \
    git curl ca-certificates openssh-client gnupg jq unzip \
    nodejs npm \
    poppler-utils mupdf-tools \
  && rm -rf /var/lib/apt/lists/*

RUN npm i -g @openai/codex


# TODO: Candidate packages discovered by agents
#
# When an agent installs a new package interactively using apt-get, it MUST also
# add a commented "candidate" line below so a human can decide whether to bake
# it into the image. Use the exact apt-get install line that was used.
#
# Examples:
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     tree ripgrep \
#   && rm -rf /var/lib/apt/lists/*
#
# Candidate lines (append below):


# Install GitHub CLI (gh)
RUN mkdir -p /etc/apt/keyrings && \
    curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg \
      | dd of=/etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg && \
    echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
      > /etc/apt/sources.list.d/github-cli.list && \
    apt-get update && apt-get install -y gh \
  && rm -rf /var/lib/apt/lists/*

COPY codex/config.toml /etc/codex/config.toml
COPY scripts/init-workstation.sh /usr/local/bin/init-workstation.sh
RUN chmod +x /usr/local/bin/init-workstation.sh

WORKDIR /workspace
