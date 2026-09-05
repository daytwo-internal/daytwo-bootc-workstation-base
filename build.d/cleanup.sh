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

# Clear /run, but skip anything podman/buildah keeps actively bind-mounted
# for this RUN step (/run/secrets, /run/.containerenv, ...) — removing those
# fails with "Device or resource busy".
find /run -mindepth 1 -maxdepth 1 -exec bash -c '
    for entry; do
        mountpoint -q "$entry" || rm -rf "$entry"
    done
' bash {} +

bootc container lint --skip sysusers --skip var-tmpfiles
