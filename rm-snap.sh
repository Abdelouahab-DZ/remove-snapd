#!/usr/bin/env bash

set -Eeuo pipefail

REBOOT=false

usage() {
    cat <<'EOF'
Usage: sudo ./rm-snap.sh [--reboot]

Remove snapd and all installed snaps. The system is not rebooted unless
--reboot is explicitly supplied.
EOF
}

for arg in "$@"; do
    case "$arg" in
        --reboot) REBOOT=true ;;
        --help|-h) usage; exit 0 ;;
        *) echo "Unknown option: $arg" >&2; usage >&2; exit 2 ;;
    esac
done

if [[ $EUID -eq 0 ]]; then
    SUDO=()
else
    command -v sudo >/dev/null 2>&1 || {
        echo "Error: this script must run as root or have sudo installed." >&2
        exit 1
    }
    SUDO=(sudo)
fi

command -v apt-get >/dev/null 2>&1 || {
    echo "Error: apt-get is required. This script supports Debian-based systems." >&2
    exit 1
}

echo "=== Disabling and stopping Snap services ==="
"${SUDO[@]}" systemctl stop snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true
"${SUDO[@]}" systemctl disable snapd.service snapd.socket snapd.seeded.service 2>/dev/null || true

if command -v snap >/dev/null 2>&1; then
    echo "=== Removing all installed snaps ==="
    while mapfile -t snaps < <(snap list 2>/dev/null | awk 'NR > 1 && $1 != "" { print $1 }'); do
        ((${#snaps[@]} == 0)) && break
        removed=0
        for snap_name in "${snaps[@]}"; do
            if "${SUDO[@]}" snap remove --purge "$snap_name"; then
                ((removed += 1))
            fi
        done
        if ((removed == 0)); then
            echo "Error: unable to remove the remaining snaps." >&2
            exit 1
        fi
    done
fi

echo "=== Purging snapd from the system ==="
"${SUDO[@]}" apt-get purge -y snapd

echo "=== Cleaning up remaining leftovers ==="
"${SUDO[@]}" apt-get autoremove --purge -y
"${SUDO[@]}" rm -rf /snap /var/snap /var/lib/snapd /var/cache/snapd /usr/lib/snapd
rm -rf "$HOME/snap"

echo "=== Pinning APT to prevent Snap from reinstalling ==="
"${SUDO[@]}" tee /etc/apt/preferences.d/no-snap.pref >/dev/null <<'EOF'
Package: snapd
Pin: release a=*
Pin-Priority: -10
EOF

"${SUDO[@]}" systemctl daemon-reload

if [[ $REBOOT == true ]]; then
    echo "=== Process complete. Rebooting now... ==="
    "${SUDO[@]}" reboot
else
    echo "=== Process complete. Reboot when convenient to finish applying changes. ==="
fi
