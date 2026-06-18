#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
rpm --import https://packages.himmelblau-idm.org/himmelblau.asc
dnf config-manager addrepo --from-repofile=https://packages.himmelblau-idm.org/nightly/latest/rpm/fedora44/himmelblau.repo
dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sshd-config himmelblau-qr-greeter himmelblau-sso himmelblau-selinux

echo "Enable Himmelblau services"
sudo systemctl enable himmelblaud himmelblaud-tasks

echo "Configuring PAM for Himmelblau"
aad-tool configure-pam --really

echo "check if authselect profile is set to himmelblau already"
authselect current

# should be done by the aad-tool
# authselect create-profile himmelblau --base-on local
# authselect select himmelblau
echo "Set authselect profile to himmelblau"
authselect select himmelblau

# https://github.com/himmelblau-idm/himmelblau/issues/1042
# echo "Switch from plasmalogin to gdm"
# dnf install -y gdm
# systemctl disable plasmalogin.service
# systemctl enable gdm.service --force