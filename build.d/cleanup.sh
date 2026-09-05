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

# Clear /run, but never descend into /run/secrets (each file inside it is
# individually bind-mounted by podman --secret for this RUN step) or
# /run/.containerenv (bind-mounted by the container runtime itself) —
# removing either fails with "Device or resource busy".
find /run -mindepth 1 -maxdepth 1 ! -name secrets ! -name .containerenv -exec rm -rf {} +

bootc container lint --skip sysusers --skip var-tmpfiles
