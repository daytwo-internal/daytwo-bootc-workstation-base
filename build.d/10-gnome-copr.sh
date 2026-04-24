#!/usr/bin/env bash
set -euxo pipefail

# versionlock plugin is needed before 20-rhel-packages.sh
dnf -y install 'dnf-command(versionlock)' dnf-plugins-core

# GNOME 50 COPR for EL10 — same repo Bluefin LTS uses (not -fresh, which is different)
# See: https://copr.fedorainfracloud.org/coprs/jreilly1821/c10s-gnome-50/
dnf copr enable -y "jreilly1821/c10s-gnome-50"

# libjxl 0.11 in this COPR has a different ABI than EPEL's 0.10, which breaks
# epel-multimedia's libavcodec (needs libjxl.so.0.10). Exclude it so EPEL wins.
GNOME50_REPO=$(find /etc/yum.repos.d/ -name "*jreilly1821*gnome-50*" | head -1)
echo "exclude=libjxl*" >> "${GNOME50_REPO}"

# These upgrades MUST happen before the GNOME group install:
# - selinux-policy: COPR 43.x required for GDM 50 userdb varlink socket;
#   EL10 base 42.x lacks the necessary policy rules.
# - gnutls: newer glib2 from COPR may pull in gnutls symbols not in base.
# - glib2: EL10 ships 2.80.x; GNOME 50 requires newer API symbols.
# - fontconfig: COPR pango 1.57+ links FcConfigSetDefaultSubstitute (added in
#   fontconfig 2.17.0); EL10 base ships 2.15.0 — causes symbol lookup error
#   at gnome-shell startup.
dnf -y install selinux-policy selinux-policy-targeted gnutls
dnf -y upgrade glib2 fontconfig

# Lock these two immediately — skew between glib2/fontconfig versions is the
# most common cause of gnome-shell startup crashes on EL10 + COPR.
dnf versionlock add glib2 fontconfig

# MoreWaita: extended Adwaita icon theme matching GNOME 50 style
dnf copr enable -y "trixieua/morewaita-icon-theme"
