#!/usr/bin/env bash
set -euxo pipefail

# versionlock plugin is needed before 20-rhel-packages.sh
dnf -y install 'dnf-command(versionlock)' dnf-plugins-core

# GNOME 49 COPR for EL10
# See: https://copr.fedorainfracloud.org/coprs/jreilly1821/c10s-gnome-49/
dnf copr enable -y "jreilly1821/c10s-gnome-49"

# gdk-pixbuf2 in this COPR has no built-in image format loaders (PNG, JPEG, SVG
# etc.) and ships no -modules subpackage. Exclude it so the base EL10 gdk-pixbuf2
# (2.42.x, with working built-in loaders) is kept — otherwise gnome-shell cannot
# decode most icon files. (Same workaround as Bluefin LTS.)
GNOME49_REPO=$(find /etc/yum.repos.d/ -name "*jreilly1821*gnome-49*" | head -1)
echo "exclude=gdk-pixbuf2*" >> "${GNOME49_REPO}"

# These upgrades MUST happen before the GNOME group install:
# - selinux-policy: COPR 43.x required for GDM 49 userdb varlink socket;
#   EL10 base 42.x lacks the necessary policy rules.
# - gnutls: newer glib2 from COPR may pull in gnutls symbols not in base.
# - glib2: EL10 ships 2.80.x; GNOME 49 requires newer API symbols.
# - fontconfig: COPR pango 1.57+ links FcConfigSetDefaultSubstitute (added in
#   fontconfig 2.17.0); EL10 base ships 2.15.0 — causes symbol lookup error
#   at gnome-shell startup.
# - gobject-introspection / gjs: glib2 2.84+ ships both libgirepository-1.0 and
#   libgirepository-2.0. If only one is upgraded both get loaded, double-registering
#   GIRepository and crashing gnome-shell at startup.
dnf -y install selinux-policy selinux-policy-targeted gnutls
dnf -y upgrade glib2 fontconfig gobject-introspection gjs

# Lock these immediately — version skew here is the leading cause of gnome-shell
# startup crashes on EL10 + COPR.
dnf versionlock add glib2 fontconfig

# MoreWaita: extended Adwaita icon theme
dnf copr enable -y "trixieua/morewaita-icon-theme"
