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
    /var/log/rhsm \
    /tmp/* \
    /var/tmp/* \
    /boot/symvers-*.xz

# /run/secrets is the active podman --secret mount point for this RUN step;
# removing it fails with "Device or resource busy", so clear everything else.
find /run -mindepth 1 -maxdepth 1 ! -name secrets -exec rm -rf {} +

bootc container lint --skip sysusers --skip var-tmpfiles
