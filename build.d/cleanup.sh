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

# nonempty-run-tmp still fires on the empty /run/secrets directory itself:
# it can't be removed here (see above), and only disappears once the RUN
# step holding the --secret mount ends, by which point this script has
# already finished.
bootc container lint --skip sysusers --skip var-tmpfiles --skip nonempty-run-tmp
