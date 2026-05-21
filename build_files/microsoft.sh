#!/bin/bash

set -ouex pipefail

echo "Import Microsoft key and add repositories"
rpm --import https://packages.microsoft.com/keys/microsoft.asc

echo "Installing Microsoft packages"
dnf makecache
rm -rf /opt/microsoft
dnf install -y code microsoft-edge-stable
