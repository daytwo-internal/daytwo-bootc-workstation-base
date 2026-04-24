#!/usr/bin/env bash
set -euxo pipefail

dnf -y update

# The 'Workstation' environment group references 'base-graphical' which does not
# exist in RHEL 10 when GNOME COPR repos are enabled, and the selinux-policy-targeted
# from the COPR (43.x) conflicts with what the environment resolver tries to pin.
# Bluefin LTS solves this identically: install specific component groups, then
# GNOME packages individually so DNF pulls the COPR versions.
dnf group install -y --nobest \
    "Common NetworkManager submodules" \
    "Core" \
    "Fonts" \
    "Hardware Support" \
    "Standard" \
    "Workstation product core"

# GNOME 50 packages — DNF pulls these from the COPR enabled in 10-gnome-copr.sh
dnf -y install \
    gdm \
    gnome-bluetooth \
    gnome-color-manager \
    gnome-control-center \
    gnome-initial-setup \
    gnome-remote-desktop \
    gnome-session-wayland-session \
    gnome-settings-daemon \
    gnome-shell \
    gnome-user-docs \
    gvfs-fuse \
    gvfs-goa \
    gvfs-gphoto2 \
    gvfs-mtp \
    gvfs-smb \
    nautilus \
    orca \
    xdg-desktop-portal-gnome \
    xdg-user-dirs-gtk

# DevOps and system packages
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

# Lock remaining GNOME 50 packages against downgrade to RHEL 10 base versions.
# glib2 and fontconfig are already locked in 10-gnome-copr.sh (must happen
# before the group install to prevent gnome-shell startup crashes).
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
    xdg-desktop-portal \
    xdg-desktop-portal-gnome
