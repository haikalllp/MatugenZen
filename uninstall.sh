#!/usr/bin/env bash
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/install.sh"

REMOVE_SINE=false
for arg in "$@"; do
    if [[ "$arg" == "--sine" ]]; then
        REMOVE_SINE=true
        break
    fi
done

# ==========================================
# Uninstall MatugenZen mod
# ==========================================

uninstall_mod() {
    local PROFILE_DIR="$1"

    info "=== MatugenZen Mod Uninstallation ==="

    local MOD_DIR="$PROFILE_DIR/chrome/sine-mods/matugen-zen"

    if [[ ! -d "$MOD_DIR" ]]; then
        warn "Mod not found at $MOD_DIR"
        return 1
    fi

    info "Removing $MOD_DIR..."
    rm -rf "$MOD_DIR"
    ok "Mod directory removed"

    local MODS_JSON="$PROFILE_DIR/chrome/sine-mods/mods.json"
    if [[ -f "$MODS_JSON" ]]; then
        MODS_JSON="$MODS_JSON" python3 << 'PYEOF'
import json, os
path = os.environ['MODS_JSON']
with open(path) as f:
    mods = json.load(f)
if 'matugen-zen' in mods:
    del mods['matugen-zen']
    with open(path, 'w') as f:
        json.dump(mods, f, indent=2)
PYEOF
        ok "Removed 'matugen-zen' from mods.json"
    fi

    local tmpl="$HOME/.config/matugen/templates/zen-browser.css"
    if [[ -f "$tmpl" ]]; then
        rm -f "$tmpl"
        ok "Template removed"
    fi

    echo ""
    ok "MatugenZen mod uninstalled!"
}

# ==========================================
# Uninstall Sine (best-effort)
# ==========================================

uninstall_sine() {
    local BROWSER_INSTALL_DIR="$1"
    local PROFILE_DIR="$2"

    info "=== Sine Uninstallation (best-effort) ==="
    warn "This only removes known artifacts (engine/ + config.js)."
    warn "Files from profile.zip / locales.zip may remain."

    local chrome_dir="$PROFILE_DIR/chrome"
    if [[ -d "$chrome_dir/engine" ]]; then
        info "Removing $chrome_dir/engine..."
        rm -rf "$chrome_dir/engine"
        ok "Sine engine removed"
    else
        info "No engine directory found"
    fi

    if [[ -f "$BROWSER_INSTALL_DIR/config.js" ]]; then
        info "Removing $BROWSER_INSTALL_DIR/config.js..."
        if [[ ! -w "$BROWSER_INSTALL_DIR" ]]; then
            warn "Installation directory not writable — sudo will be used."
            sudo rm -f "$BROWSER_INSTALL_DIR/config.js"
        else
            rm -f "$BROWSER_INSTALL_DIR/config.js"
        fi
        ok "Bootloader config.js removed"
    else
        info "No config.js found in $BROWSER_INSTALL_DIR"
    fi

    echo ""
    ok "Sine best-effort removal complete!"
    echo "  Restart your browser, go to about:support,"
    echo "  click 'Clear Startup Cache', then restart again."
}

# ==========================================
# Main
# ==========================================

echo ""
echo "  MatugenZen Uninstaller"
echo "  ======================"
echo ""

choose_browser_profile

uninstall_mod "$CHOSEN_PROFILE_DIR" || true

if [[ "$REMOVE_SINE" == true ]]; then
    echo ""
    uninstall_sine "$CHOSEN_INSTALL_DIR" "$CHOSEN_PROFILE_DIR"
fi

echo ""
info "All done! Restart your browser."
