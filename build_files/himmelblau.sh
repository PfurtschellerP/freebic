#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
rpm --import https://packages.himmelblau-idm.org/himmelblau.asc
dnf config-manager addrepo --from-repofile=https://packages.himmelblau-idm.org/nightly/latest/rpm/fedora44/himmelblau.repo
dnf makecache
dnf install -y himmelblau pam-himmelblau nss-himmelblau himmelblau-sshd-config himmelblau-qr-greeter himmelblau-sso himmelblau-selinux

echo "Configuring Authselect for Himmelblau"
authselect create-profile himmelblau --base-on local
authselect select himmelblau

echo "Modify nsswitch.conf to use himmelblau for passwd and group"
sed -i 's/^passwd:.*/& himmelblau/' /etc/authselect/custom/himmelblau/nsswitch.conf
sed -i 's/^group:.*/& himmelblau/' /etc/authselect/custom/himmelblau/nsswitch.conf

echo "Enable profiles for himmelblau"
authselect select custom/himmelblau

echo "Enable Himmelblau services"
sudo systemctl enable himmelblaud himmelblaud-tasks

echo "Configuring PAM for Himmelblau"
aad-tool configure-pam --really

# https://github.com/himmelblau-idm/himmelblau/issues/1042
echo "Switch from plasmalogin to lightdm"
dnf install -y lightdm

systemctl disable plasmalogin.service
systemctl disable plasma-setup.service

systemctl enable lightdm.service --force
