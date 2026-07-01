#!/bin/bash

set -ouex pipefail

echo "Add the tss group for the Himmelblau packages"
groupadd --system tss

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
