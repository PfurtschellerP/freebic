#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sso himmelblau-selinux policycoreutils selinux-policy-devel checkpolicy m4 make

# Could be removed, once solved https://github.com/himmelblau-idm/himmelblau/issues/1503
SELINUX_SRC_DIR="/usr/share/selinux/packages/himmelblaud"
SELINUX_MAKEFILE="/usr/share/selinux/devel/Makefile"

echo "Compiling SELinux policy modules..."
cd "$SELINUX_SRC_DIR"
make -f "$SELINUX_MAKEFILE" himmelblaud.pp
make -f "$SELINUX_MAKEFILE" himmelblaud_additional.pp
echo "Installing SELinux policy modules..."
semodule -i himmelblaud.pp
semodule -i himmelblaud_additional.pp

# Clean up compiled files (keep source for potential recompilation)
rm -f himmelblaud.pp tmp/*.* 2>/dev/null || :
rm -f himmelblaud_additional.pp tmp/*.* 2>/dev/null || :
rmdir tmp 2>/dev/null || :

Relabel installed binaries
restorecon -Fv /usr/sbin/himmelblaud /usr/sbin/himmelblaud_tasks 2>/dev/null || :

# Relabel existing dirs (may not exist on fresh install)
[ -d /etc/himmelblau ]                && restorecon -RFv /etc/himmelblau || :
[ -d /run/himmelblaud ]               && restorecon -RFv /run/himmelblaud || :
[ -d /var/run/himmelblaud ]           && restorecon -RFv /var/run/himmelblaud || :
[ -d /var/cache/private/himmelblaud ] && restorecon -RFv /var/cache/private/himmelblaud || :
[ -d /var/cache/himmelblaud ]         && restorecon -RFv /var/cache/himmelblaud || :
[ -d /var/cache/nss-himmelblau ]      && restorecon -RFv /var/cache/nss-himmelblau || :
[ -d /var/lib/private/himmelblaud ]   && restorecon -RFv /var/lib/private/himmelblaud || :
[ -d /var/lib/himmelblaud ]           && restorecon -RFv /var/lib/himmelblaud || :


echo "Configuring PAM for Himmelblau"
aad-tool configure-pam

echo "Enable Himmelblau services"
systemctl enable himmelblaud himmelblaud-tasks himmelblau-hsm-pin-init

echo "Do any configuration that expects a live system"
systemctl enable first-boot.service
