#!/bin/bash

set -ouex pipefail

echo "Installing Himmelblau packages and configuring PAM"
rpm --import https://packages.himmelblau-idm.org/himmelblau.asc
dnf config-manager addrepo --from-repofile=https://packages.himmelblau-idm.org/stable/latest/rpm/fedora43/himmelblau.repo
dnf makecache
dnf install -y selinux-policy-devel himmelblau pam-himmelblau nss-himmelblau himmelblau-sshd-config himmelblau-qr-greeter himmelblau-sso o365 himmelblau-selinux


install_himmelblau_selinux_module() {
	local selinux_src_dir=/ctx/selinux

	if [[ ! -d "$selinux_src_dir" ]]; then
		echo "SELinux source tree not found at $selinux_src_dir; skipping local module build"
		return 0
	fi

	if [[ ! -f /usr/share/selinux/devel/Makefile ]]; then
		echo "SELinux development Makefile not found; skipping local module build"
		return 0
	fi

	if ! command -v semodule >/dev/null 2>&1; then
		echo "semodule not available; skipping local module build"
		return 0
	fi

	echo "Building local himmelblaud SELinux module"
	make -f /usr/share/selinux/devel/Makefile -C "$selinux_src_dir" himmelblaud.pp

	echo "Installing local himmelblaud SELinux module"
	semodule -i "$selinux_src_dir/himmelblaud.pp"

	echo "Relabeling Himmelblau paths"
	restorecon -RFv \
		/usr/sbin/himmelblaud \
		/usr/sbin/himmelblaud_tasks \
		/etc/himmelblau \
		/run/himmelblaud \
		/var/run/himmelblaud \
		/var/cache/private/himmelblaud \
		/var/cache/himmelblaud \
		/var/cache/nss-himmelblau \
		/var/lib/private/himmelblaud \
		/var/lib/himmelblaud 2>/dev/null || true
}

install_himmelblau_selinux_module


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

dnf install -y gdm

# https://github.com/himmelblau-idm/himmelblau/issues/1042
echo "Switch from plasmalogin to gdm"
systemctl disable plasmalogin.service
systemctl enable gdm.service --force