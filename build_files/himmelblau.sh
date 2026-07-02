#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sso himmelblau-selinux policycoreutils selinux-policy-devel checkpolicy m4 make

echo "Configuring PAM for Himmelblau"
aad-tool configure-pam

echo "Enable Himmelblau services"
systemctl enable himmelblaud himmelblaud-tasks himmelblau-hsm-pin-init

echo "Selecting Himmelblau authselect profile"
authselect list
authselect select himmelblau

authselect enable-feature with-altfiles

sudo authselect apply-changes

echo "SELinux policy installation is deferred to first boot"
systemctl enable himmelblau-selinux-install.service

