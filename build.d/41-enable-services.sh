#!/usr/bin/env bash
set -euxo pipefail

systemctl enable \
    cockpit.socket \
    flatpak-preinstall.service \
    libvirtd.socket \
    zerotier-one.service

systemctl set-default graphical.target
