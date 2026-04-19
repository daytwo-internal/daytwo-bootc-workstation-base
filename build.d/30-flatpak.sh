#!/usr/bin/env bash
set -euxo pipefail

# Add Flathub as the system-wide Flatpak remote.
curl --retry 3 -fsSLo /etc/flatpak/remotes.d/flathub.flatpakrepo \
    https://dl.flathub.org/repo/flathub.flatpakrepo

# Remove the RHEL Flatpak remote. On a bootc image, OS updates come via
# bootc upgrade — the rhel remote is unused and causes flatpak preinstall
# to fail trying to install RHEL-declared apps (e.g. Firefox) that we
# don't want managed through Flatpak.
rm -f /etc/flatpak/remotes.d/rhel.flatpakrepo
