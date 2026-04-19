#!/usr/bin/env bash
set -euxo pipefail

# Add Flathub as the system-wide Flatpak remote (disabled by default for users,
# but available for flatpak-preinstall.service to install declared apps).
curl --retry 3 -fsSLo /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo
