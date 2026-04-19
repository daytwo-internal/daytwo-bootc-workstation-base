#!/usr/bin/env bash
set -euxo pipefail

systemctl enable \
    bootc-fetch-apply-updates.timer \
    cockpit.socket \
    libvirtd.socket \
    zerotier-one.service

systemctl --global enable \
    flatpak-preinstall.service \
    flatpak-update.timer

systemctl set-default graphical.target
