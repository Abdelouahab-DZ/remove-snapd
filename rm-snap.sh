#!/usr/bin/env bash

# Exit immediately if a command exits with a non-zero status
set -e

echo "=== Disabling and stopping Snap services ==="
sudo systemctl stop snapd.service snapd.socket snapd.seeded.service
sudo systemctl disable snapd.service snapd.socket snapd.seeded.service

echo "=== Removing all installed Snaps (handling dependencies) ==="
# Loop to remove apps first, then runtimes/cores
while [ "$(snap list 2>/dev/null | wc -l)" -gt 0 ]; do
    for snap in $(snap list 2>/dev/null | awk '!/^Name|^refreshed/ {print $1}'); do
        sudo snap remove --purge "$snap" 2>/dev/null || true
    done
done

echo "=== Purging snapd from the system ==="
sudo apt purge -y snapd

echo "=== Cleaning up remaining leftovers ==="
sudo apt autoremove --purge -y
sudo rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd
rm -rf ~/snap

echo "=== Pinning APT to prevent Snap from reinstalling ==="
sudo apt-mark hold snapd 2>/dev/null || true

sudo tee /etc/apt/preferences.d/no-snap.pref << 'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

echo "=== Reloading system daemon ==="
sudo systemctl daemon-reload

echo "=== Process complete. Rebooting now... ==="
sudo reboot