#!/usr/bin/env bash
set -euxo pipefail

# GNOME 50 backport COPRs for EL10 (RHEL 10 / CentOS Stream 10 compatible)
# Must run before 20-rhel-packages.sh so DNF resolves GNOME 50 versions
# during Workstation group install rather than defaulting to the base GNOME.
# See: https://copr.fedorainfracloud.org/coprs/jreilly1821/
dnf -y install dnf-plugins-core
dnf -y copr enable jreilly1821/c10s-gnome-50-fresh
dnf -y copr enable jreilly1821/c10s-gnome-50

# MoreWaita: extended Adwaita icon theme matching GNOME 50 style
dnf -y copr enable trixieua/morewaita-icon-theme
