#!/bin/bash

set -ouex pipefail

dnf clean all
rm -rf /var/cache/dnf/* /var/cache/yum/* /var/log/dnf.log /var/log/dnf* /var/log/yum.log /var/log/yum*
