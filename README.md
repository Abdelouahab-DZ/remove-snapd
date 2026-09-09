# Ubuntu Snap Remover Script

A Bash script that removes Snap, snapd, and installed snaps from a Debian-based system, then adds an APT preference to prevent snapd from being installed accidentally.

---

## ✨ Features

- **Service disabling:** Stops and disables available `snapd` systemd services.
- **Complete removal:** Removes installed snaps before purging the daemon and its unused dependencies.
- **Cleanup:** Removes Snap data and cache directories.
- **APT pinning:** Creates an APT preference rule that blocks future snapd installations.
- **Safe default:** Does not reboot unless explicitly requested.

---

## ⚠️ Important Warning

This script **permanently removes all Snap packages** and the Snap store from your system. Make sure you have backed up any important data or application configurations stored within snap apps before running it.

---

## Installation and usage

```bash
git clone https://github.com/Abdelouahab-DZ/remove-snapd.git
cd remove-snapd
chmod +x rm-snap.sh
sudo ./rm-snap.sh
```

The script requires `apt-get`, `systemd`, and Bash. It must run as root or
with `sudo` available. To reboot automatically after completion, opt in:

```bash
sudo ./rm-snap.sh --reboot
```

## Warning

This permanently removes all Snap packages and their local data. Back up
important application data before running the script. Applications installed
only as snaps may need to be reinstalled from another source.
