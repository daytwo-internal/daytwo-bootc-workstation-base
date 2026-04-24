#!/usr/bin/env bash
set -euxo pipefail

subscription-manager unregister || true
subscription-manager clean

# Compile dconf system database so extension settings take effect on first login
dconf update

dnf clean all
rm -rf \
    /var/cache/dnf \
    /var/cache/ldconfig/* \
    /var/log/*.log \
    /var/log/dnf* \
    /var/log/hawkey.log \
    /var/log/yum* \
    /tmp/* \
    /var/tmp/*

bootc container lint
