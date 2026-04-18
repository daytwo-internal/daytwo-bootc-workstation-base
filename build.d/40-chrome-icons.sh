#!/usr/bin/env bash
set -eo pipefail

for size in 16 24 32 48 64 128 256; do
    mkdir -p /usr/share/icons/hicolor/${size}x${size}/apps
    ln -sf /opt/google/chrome/product_logo_${size}.png \
           /usr/share/icons/hicolor/${size}x${size}/apps/google-chrome.png
done

gtk-update-icon-cache -f -t /usr/share/icons/hicolor/ 2>/dev/null || true
