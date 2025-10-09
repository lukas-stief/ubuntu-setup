#!/bin/bash
# -e Exit immediately if a command exits with a non-zero status.
# -o pipefail the return value of a pipeline is the status of the last command to
set -eo pipefail

echo "Applying gnome settings..."
sh scripts/gnome-settings.sh
echo "Gnome settings applied."
