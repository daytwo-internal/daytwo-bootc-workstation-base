#!/usr/bin/env bash
set -eo pipefail

# GPG keys (repo files already present via COPY etc/yum.repos.d/)
rpm --import https://packages.microsoft.com/keys/microsoft.asc
rpm --import https://dl.google.com/linux/linux_signing_key.pub
rpm --import https://rpm.releases.hashicorp.com/gpg
rpm --import 'https://raw.githubusercontent.com/zerotier/ZeroTierOne/main/doc/contact%40zerotier.com.gpg'

# COPR repos
dnf -y copr enable agriffis/neovim-nightly
dnf -y copr enable jdxcode/mise
dnf -y copr enable atim/starship
dnf -y copr enable che/nerd-fonts

# Multimedia repo (disabled by default, used with --enablerepo in 06-multimedia.sh)
dnf config-manager --add-repo=https://negativo17.org/repos/epel-multimedia.repo
dnf config-manager --set-disabled epel-multimedia
