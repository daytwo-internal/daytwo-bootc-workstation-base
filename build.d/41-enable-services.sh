#!/usr/bin/env bash
set -euxo pipefail

systemctl enable \
    cockpit.socket \
    libvirtd.socket \
    zerotier-one.service

systemctl set-default graphical.target
