#!/usr/bin/env bash
set -euxo pipefail

# GPG keys (repo files already present via COPY rootfs/)
rpm --import https://downloads.1password.com/linux/keys/1password.asc
rpm --import https://packages.microsoft.com/keys/microsoft.asc
rpm --import https://dl.google.com/linux/linux_signing_key.pub
rpm --import https://rpm.releases.hashicorp.com/gpg
rpm --import 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg'

# COPR repos — disabled immediately, enabled only at install time
dnf -y copr enable jchisholm204/Alacritty rhel-10-x86_64
dnf -y copr disable jchisholm204/Alacritty
dnf -y copr enable atim/starship
dnf -y copr disable atim/starship
dnf -y copr enable che/nerd-fonts rhel-10-x86_64
dnf -y copr disable che/nerd-fonts
dnf -y copr enable jdxcode/mise
dnf -y copr disable jdxcode/mise

# Multimedia repo — disabled, enabled only at install time in 25-multimedia.sh
dnf config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
dnf config-manager --set-disabled epel-multimedia
