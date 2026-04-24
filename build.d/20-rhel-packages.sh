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

# Lock remaining GNOME 50 packages against downgrade to RHEL 10 base versions.
# glib2 and fontconfig are already locked in 10-gnome-copr.sh (must be done
# before the group install to prevent crashes at gnome-shell startup).
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
