#!/usr/bin/env bash
set -eo pipefail

systemctl enable \
    cockpit.socket \
    libvirtd.socket \
    zerotier-one.service

systemctl set-default graphical.target
