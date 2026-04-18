#!/usr/bin/env bash
set -eo pipefail

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y --nodocs --setopt=install_weak_deps=False install \
    bat \
    borgbackup \
    btop \
    fd-find \
    fzf \
    gh \
    htop \
    just \
    ncdu \
    python3-neovim \
    rclone \
    restic \
    ripgrep \
    tldr
