#!/usr/bin/env bash
set -euxo pipefail

# Custom SELinux policy to fix GDM userdb socket on RHEL 10 + GNOME 49 COPR.
#
# gnome49-el10-compat ships policy rules designed for CentOS Stream 10; RHEL 10's
# base policy is slightly stricter in two places that block GDM login-screen RDP:
#
#   1. xdm_t denied write on .pwd.lock (passwd_file_t) — GDM locks the file
#      while consulting PAM during the remote-desktop login flow.
#   2. xdm_t denied create on .pwd.lock (etc_t) — same file, triggered when
#      the lock doesn't yet exist and GDM tries to create it.
#
# These denials are not in the compat package and are confirmed via:
#   ausearch -m AVC -ts today | grep gdm   (with permissive=0 lines)

cat > /tmp/gdm-userdb-fix.te << 'EOF'
module gdm-userdb-fix 1.0;

require {
    type xdm_t;
    type passwd_file_t;
    type etc_t;
    class file { write create };
}

# GDM writes/creates .pwd.lock while consulting PAM for remote-desktop logins
allow xdm_t passwd_file_t:file write;
allow xdm_t etc_t:file create;
EOF

checkmodule -M -m -o /tmp/gdm-userdb-fix.mod /tmp/gdm-userdb-fix.te
semodule_package -o /tmp/gdm-userdb-fix.pp -m /tmp/gdm-userdb-fix.mod
semodule -i /tmp/gdm-userdb-fix.pp

rm -f /tmp/gdm-userdb-fix.te /tmp/gdm-userdb-fix.mod /tmp/gdm-userdb-fix.pp
