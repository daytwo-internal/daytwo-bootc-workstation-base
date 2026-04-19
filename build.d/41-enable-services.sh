#!/usr/bin/env bash
set -euxo pipefail

systemctl enable \
    bootc-fetch-apply-updates.timer \
    cockpit.socket \
    flatpak-preinstall.service \
    flatpak-update.timer \
    libvirtd.socket \
    zerotier-one.service

systemctl set-default graphical.target
