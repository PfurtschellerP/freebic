#! /bin/bash

set -ouex pipefail

echo "Enable Himmelblau authselect profile"
authselect list
authselect select himmelblau with-altfiles --force
authselect apply-changes