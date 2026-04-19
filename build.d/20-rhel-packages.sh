#!/usr/bin/env bash
set -euxo pipefail

dnf -y update

dnf -y groupinstall Workstation

dnf -y install \
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
    zsh \
    zstd
