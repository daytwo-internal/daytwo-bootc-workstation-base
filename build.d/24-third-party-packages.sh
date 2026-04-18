#!/usr/bin/env bash
set -eo pipefail

dnf -y --nodocs --setopt=install_weak_deps=False install \
    code \
    google-chrome-stable \
    mise \
    neovim \
    nerd-fonts \
    starship \
    terraform \
    zerotier-one
