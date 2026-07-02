#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sso himmelblau-selinux

echo "Configuring PAM for Himmelblau"
aad-tool configure-pam

echo "Enable Himmelblau services"
systemctl enable himmelblaud himmelblaud-tasks himmelblau-hsm-pin-init

echo "Selecting Himmelblau authselect profile"
authselect list
authselect select himmelblau

authselect enable-feature with-altfiles

sudo authselect apply-changes

# copied from the posttrans script in the himmelblau-selinux package
echo "Ensure selinux policy module is compiled and installed"
 
SELINUX_SRC_DIR="/usr/share/selinux/packages/himmelblaud"
SELINUX_MAKEFILE="/usr/share/selinux/devel/Makefile"
 
if command -v selinuxenabled >/dev/null 2>&1 && selinuxenabled; then
  # Check if SELinux development tools are available
  if [ ! -f "$SELINUX_MAKEFILE" ]; then
    echo "Warning: SELinux development Makefile not found at $SELINUX_MAKEFILE"
    echo "Please install selinux-policy-devel and re-run this script"
    exit 0
  fi
 
  # Compile the policy module from source
  if [ -d "$SELINUX_SRC_DIR" ]; then
    echo "Compiling SELinux policy module..."
    cd "$SELINUX_SRC_DIR"
    if make -f "$SELINUX_MAKEFILE" himmelblaud.pp; then
      echo "Installing SELinux policy module..."
      if semodule -i himmelblaud.pp; then
        # Clean up compiled files (keep source for potential recompilation)
        rm -f himmelblaud.pp tmp/*.* 2>/dev/null || :
        rmdir tmp 2>/dev/null || :
 
        # Relabel installed binaries
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
 
        echo "SELinux policy module installed successfully"
      else
        echo "Warning: Failed to install SELinux policy module"
				exit 1
      fi
    else
      echo "Warning: Failed to compile SELinux policy module"
			exit 1
    fi
  else
    echo "Warning: SELinux source directory not found at $SELINUX_SRC_DIR"
		exit 1
  fi
fi

