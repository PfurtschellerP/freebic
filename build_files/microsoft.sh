#!/bin/bash

set -ouex pipefail

echo "Import Microsoft key and add repositories"
rpm --import https://packages.microsoft.com/keys/microsoft.asc
dnf config-manager addrepo --from-repofile=https://packages.microsoft.com/yumrepos/vscode.repo
dnf config-manager addrepo --from-repofile=https://packages.microsoft.com/yumrepos/edge.repo

echo "Installing Microsoft packages"
dnf makecache
dnf install -y code microsoft-edge-stable
