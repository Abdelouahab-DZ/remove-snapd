# Ubuntu Snap Remover Script 🛑

A robust bash script designed to completely purge Snap, snapd, and all associated snaps from an Ubuntu system, while setting up APT preferences to prevent it from ever accidentally reinstalling.

---

## ✨ Features

- **Service Disabling:** Gracefully stops and disables all background `snapd` systemd services.
- **Recursive Removal:** Loops through and purges all installed snap packages (handling complex dependencies and runtimes) before removing the daemon.
- **Deep Clean:** Cleans up leftover configuration files, caches, and system directories (`/snap`, `~/snap`, etc.).
- **APT Pinning:** Creates an APT preference rule and places a hold on `snapd` to block future package updates or unintended reinstalls.
- **Auto-Reboot:** Automatically reloads system daemons and reboots the system to finalize changes.

---

## ⚠️ Important Warning

This script **permanently removes all Snap packages** and the Snap store from your system. Make sure you have backed up any important data or application configurations stored within snap apps before running it.

---

## 📥 Installation & Setup
chmod +x rm-snap.sh
sudo ./rm-snap.sh
