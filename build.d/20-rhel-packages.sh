#!/usr/bin/env bash
set -eo pipefail

dnf -y --nodocs --setopt=install_weak_deps=False update

dnf -y --nodocs --setopt=install_weak_deps=False groupinstall Workstation

dnf -y --nodocs --setopt=install_weak_deps=False install \
    ansible-core \
    bootc \
    buildah \
    cockpit \
    cockpit-machines \
    cockpit-podman \
    cockpit-storaged \
    curl \
    dnf-plugins-core \
    edk2-ovmf \
    flatpak \
    git \
    git-lfs \
    gnome-extensions-app \
    gnome-shell-extension-dash-to-dock \
    iproute \
    jq \
    libvirt \
    libvirt-client \
    podman \
    qemu-kvm \
    rsync \
    skopeo \
    tmux \
    toolbox \
    tree \
    unzip \
    virt-install \
    virt-manager \
    vim-enhanced \
    wget \
    wl-clipboard \
    zsh \
    zstd
