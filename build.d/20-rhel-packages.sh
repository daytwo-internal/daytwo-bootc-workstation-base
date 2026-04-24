#!/usr/bin/env bash
set -euxo pipefail

dnf -y update

# Install Workstation group. GNOME 50 COPR repos (enabled in 10-gnome-copr.sh) take priority
# so DNF resolves GNOME 50 packages instead of the base GNOME version from RHEL 10 repos.
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
    iproute \
    jq \
    libvirt \
    libvirt-client \
    morewaita-icon-theme \
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

# SELinux policy, PAM, and userdb socket fixes required for GNOME 50 on EL10
dnf -y install gnome50-el10-compat

# Lock GNOME 50 packages to prevent dnf upgrade from downgrading back to
# the RHEL 10 base GNOME version if RHEL repos later ship matching version numbers.
dnf versionlock add \
    gnome-shell \
    gdm \
    mutter \
    gnome-session-wayland-session \
    gnome-settings-daemon \
    gnome-control-center \
    gsettings-desktop-schemas \
    gtk4 \
    libadwaita \
    pango \
    fontconfig \
    glib2 \
    xdg-desktop-portal \
    xdg-desktop-portal-gnome
