#!/usr/bin/env bash
set -euxo pipefail

# Third-party yum repos (code, google-chrome, hashicorp, zerotier)
dnf -y \
    --enablerepo=code \
    --enablerepo=google-chrome \
    --enablerepo=hashicorp \
    --enablerepo=zerotier \
    install \
        code \
        google-chrome-stable \
        terraform \
        zerotier-one

# COPR packages
dnf -y \
    --enablerepo="copr:copr.fedorainfracloud.org:atim:starship" \
    --enablerepo="copr:copr.fedorainfracloud.org:che:nerd-fonts" \
    --enablerepo="copr:copr.fedorainfracloud.org:jdxcode:mise" \
    install \
        mise \
        nerd-fonts \
        starship
