#!/usr/bin/env bash
set -euxo pipefail

dnf -y install https://dl.fedoraproject.org/pub/epel/epel-release-latest-10.noarch.rpm

dnf -y install \
    bat \
    borgbackup \
    btop \
    fd-find \
    fzf \
    gh \
    htop \
    just \
    ncdu \
    rclone \
    restic \
    ripgrep \
    tldr
