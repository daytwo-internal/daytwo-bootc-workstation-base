#!/usr/bin/env bash
set -euxo pipefail

# Add Flathub as the system-wide Flatpak remote.
curl --retry 3 -fsSLo /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo
