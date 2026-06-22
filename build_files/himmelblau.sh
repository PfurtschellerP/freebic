#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
rpm --import https://packages.himmelblau-idm.org/himmelblau.asc
dnf config-manager addrepo --from-repofile=https://packages.himmelblau-idm.org/stable/latest/rpm/fedora43/himmelblau.repo
# dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sso himmelblau-selinux

echo "Configuring PAM for Himmelblau"
aad-tool configure-pam

echo "Enable Himmelblau services"
systemctl enable himmelblaud himmelblaud-tasks
