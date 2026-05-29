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

detect_platform() {
    local os
    local arch

    case "$(uname -s)" in
        Linux*)  os="linux" ;;
        Darwin*) os="osx" ;;
        MINGW*|MSYS*|CYGWIN*) os="win" ;;
        *)       echo "Unsupported OS: $(uname -s)" >&2; exit 1 ;;
    esac

    case "$(uname -m)" in
        x86_64|amd64) arch="x64" ;;
        aarch64|arm64) arch="arm64" ;;
        *)              echo "Unsupported architecture: $(uname -m)" >&2; exit 1 ;;
    esac

    if [[ "$os" == "win" ]]; then
        echo "${os}-${arch}.exe"
    else
        echo "${os}-${arch}"
    fi
}

find_zen_profile() {
    for dir in ~/.config/zen/*/; do
        if [[ -d "$dir/chrome/sine-mods" ]] && [[ ! "$(basename "$dir")" =~ [Pp]rofile[\s-]+[Gg]roups ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

find_any_zen_profile() {
    for dir in ~/.config/zen/*/; do
        if [[ ! "$(basename "$dir")" =~ [Pp]rofile[\s-]+[Gg]roups ]]; then
            echo "$dir"
            return 0
        fi
    done
    return 1
}

install_sine() {
    local platform
    platform=$(detect_platform)
    local sine_binary="sine-${platform}"
    local temp_dir
    temp_dir=$(mktemp -d)

    echo "Installing Sine..."
    echo "Platform: $platform"
    echo "Downloading latest Sine..."

    if ! command -v curl &> /dev/null; then
        echo "Error: curl is required to download Sine"
        echo "Please install curl or download Sine manually from:"
        echo "https://github.com/CosmoCreeper/Sine/releases"
        exit 1
    fi

    if ! curl -fsSL "https://github.com/CosmoCreeper/Sine/releases/latest/download/${sine_binary}" -o "${temp_dir}/${sine_binary}"; then
        echo "Error: Failed to download Sine"
        exit 1
    fi

    chmod +x "${temp_dir}/${sine_binary}"

    echo "Running Sine installer..."
    if [[ -t 1 ]]; then
        "${temp_dir}/${sine_binary}"
    else
        "${temp_dir}/${sine_binary}" < /dev/tty
    fi

    rm -rf "$temp_dir"

    echo ""
    echo "Sine installed successfully!"
    echo "Please restart Zen Browser to initialize Sine, then re-run this script."
    exit 0
}

PROFILE_DIR=$(find_zen_profile) || true

if [[ -z "$PROFILE_DIR" ]]; then
    if find_any_zen_profile &> /dev/null; then
        echo "Zen Browser profiles found, but Sine is not installed."
        echo ""
        read -p "Do you want to install Sine automatically? [Y/n] " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]] || [[ -z $REPLY ]]; then
            install_sine

            PROFILE_DIR=$(find_zen_profile) || true

            if [[ -z "$PROFILE_DIR" ]]; then
                echo "Error: Could not find Zen profile after Sine installation"
                echo "Please restart Zen Browser at least once to initialize Sine"
                exit 1
            fi
        else
            echo "Installation cancelled."
            echo "Please install Sine manually from:"
            echo "https://github.com/CosmoCreeper/Sine/releases"
            exit 0
        fi
    else
        echo "Error: No Zen Browser profiles found at ~/.config/zen/"
        echo "Please install Zen Browser first."
        exit 1
    fi
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