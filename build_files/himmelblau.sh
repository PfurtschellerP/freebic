#!/bin/bash

set -ouex pipefail

echo "Install tpm2-tss as the tss group is a requirement for the himmelblau systemd service"
dnf install tpm2-tss

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
