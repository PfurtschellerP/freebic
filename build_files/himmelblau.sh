#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
rpm --import https://packages.himmelblau-idm.org/himmelblau.asc
dnf config-manager addrepo --from-repofile=https://packages.himmelblau-idm.org/nightly/latest/rpm/fedora44/himmelblau.repo
# dnf makecache
# dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sshd-config himmelblau-qr-greeter himmelblau-sso himmelblau-selinux

echo "Enable Himmelblau services"
# sudo systemctl enable himmelblaud himmelblaud-tasks

echo "Configuring PAM for Himmelblau"
# aad-tool configure-pam
