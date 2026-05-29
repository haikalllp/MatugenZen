#!/usr/bin/env bash

# MatugenZen Install Script

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DEV_MODE=false

for arg in "$@"; do
    if [[ "$arg" == "--dev" ]]; then
        DEV_MODE=true
        break
    fi
done

find_zen_profile() {
    for dir in ~/.config/zen/*/; do
        if [[ -d "$dir/chrome/sine-mods" ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

PROFILE_DIR=$(find_zen_profile)

if [[ -z "$PROFILE_DIR" ]]; then
    echo "Error: Could not find a Zen profile with sine-mods directory"
    exit 1
fi

MOD_DIR="$PROFILE_DIR/chrome/sine-mods/matugen-zen"
echo "Installing to: $MOD_DIR"

mkdir -p "$MOD_DIR"

if [[ "$DEV_MODE" == true ]]; then
    ln -sf "$SCRIPT_DIR/theme.json" "$MOD_DIR/"
    ln -sf "$SCRIPT_DIR/theme-sync.uc.js" "$MOD_DIR/"
    ln -sf "$SCRIPT_DIR/preferences.json" "$MOD_DIR/"
    ln -sf "$SCRIPT_DIR/chrome.css" "$MOD_DIR/"
    mkdir -p "$MOD_DIR/assets"
    ln -sf "$SCRIPT_DIR/assets/zen-logo.svg" "$MOD_DIR/assets/"
    echo "Installed in DEV mode (symlinks)"
else
    cp "$SCRIPT_DIR/theme.json" "$MOD_DIR/"
    cp "$SCRIPT_DIR/theme-sync.uc.js" "$MOD_DIR/"
    cp "$SCRIPT_DIR/preferences.json" "$MOD_DIR/"
    cp "$SCRIPT_DIR/chrome.css" "$MOD_DIR/"
    cp "$SCRIPT_DIR/assets/zen-logo.svg" "$MOD_DIR/"
    echo "Installed (copied)"
fi

MODS_JSON="$PROFILE_DIR/chrome/sine-mods/mods.json"

if [[ -f "$MODS_JSON" ]]; then
    python3 << EOF
import json
with open('$MODS_JSON', 'r') as f:
    mods = json.load(f)
with open('$SCRIPT_DIR/theme.json', 'r') as f:
    new_mod = json.load(f)
mods['matugen-zen'] = new_mod
mods['matugen-zen']['origin'] = 'store'
with open('$MODS_JSON', 'w') as f:
    json.dump(mods, f, indent=2)
EOF
    echo "Updated existing mods.json"
else
    python3 << EOF
import json
with open('$SCRIPT_DIR/theme.json', 'r') as f:
    new_mod = json.load(f)
new_mod['origin'] = 'store'
mods = {'matugen-zen': new_mod}
with open('$MODS_JSON', 'w') as f:
    json.dump(mods, f, indent=2)
EOF
    echo "Created mods.json"
fi

TEMPLATE_DIR="$HOME/.config/matugen/templates"
mkdir -p "$TEMPLATE_DIR"
if [[ ! -f "$TEMPLATE_DIR/zen-browser.css" ]]; then
    cp "$SCRIPT_DIR/templates/zen-browser.css" "$TEMPLATE_DIR/"
    echo "Installed template to $TEMPLATE_DIR/zen-browser.css"
else
    echo "Template already exists at $TEMPLATE_DIR/zen-browser.css (skipped)"
fi

echo ""
echo "MatugenZen installed successfully!"
echo "Restart Zen Browser to activate the mod."
