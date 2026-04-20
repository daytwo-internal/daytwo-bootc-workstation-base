#!/usr/bin/env bash
set -euxo pipefail

# Third-party yum repos
dnf -y \
    --enablerepo=1password \
    --enablerepo=code \
    --enablerepo=google-chrome \
    --enablerepo=hashicorp \
    --enablerepo=zerotier \
    install \
        1password \
        code \
        google-chrome-stable \
        terraform \
        zerotier-one

# COPR packages
dnf -y \
    --enablerepo="copr:copr.fedorainfracloud.org:jchisholm204:Alacritty" \
    --enablerepo="copr:copr.fedorainfracloud.org:atim:starship" \
    --enablerepo="copr:copr.fedorainfracloud.org:che:nerd-fonts" \
    --enablerepo="copr:copr.fedorainfracloud.org:jdxcode:mise" \
    --enablerepo="copr:copr.fedorainfracloud.org:scottames:ghostty" \
    install \
        alacritty \
        ghostty \
        mise \
        nerd-fonts \
        starship
