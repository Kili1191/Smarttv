#!/usr/bin/env bash
# Zips channel/ and sideloads it to a Roku in developer mode.
# Usage: ROKU_IP=192.168.1.50 ROKU_PASS=yourpass ./scripts/deploy.sh
set -euo pipefail

: "${ROKU_IP:?Set ROKU_IP to your Roku's IP address}"
: "${ROKU_PASS:?Set ROKU_PASS to the dev password you chose}"

root="$(cd "$(dirname "$0")/.." && pwd)"
mkdir -p "$root/build"
rm -f "$root/build/channel.zip"

# Zip the contents of channel/, not the folder itself
(cd "$root/channel" && zip -qr "$root/build/channel.zip" .)

curl -sS --fail --digest -u "rokudev:$ROKU_PASS" \
    -F "mysubmit=Install" \
    -F "archive=@$root/build/channel.zip" \
    "http://$ROKU_IP/plugin_install" | grep -o '<font color="red">[^<]*' | sed 's/<font color="red">//' || true

echo "Deployed. Watch logs with: telnet $ROKU_IP 8085"
