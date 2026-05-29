# MatugenZen

A Sine mod for Zen Browser that syncs Matugen's surface color to Zen Boosts, automatically theming all websites.

## Features

- Real-time sync with Matugen's generated theme files
- Automatically applies surface color to all websites via Zen Boosts
- Applies theme to browser chrome (background, sidebar, etc.)
- Configurable chrome theme path
- Minimal, lightweight implementation

## Installation

Run the install script:
```bash
bash install.sh
```

For development with symlinks:
```bash
bash install.sh --dev
```

This will automatically:
- Detect your Zen profile
- Copy or symlink the mod files
- Update `mods.json`
- Install the matugen template to `~/.config/matugen/templates/`

Then restart Zen Browser.

## Manual Installation

1. Create the mod directory:
```bash
mkdir -p ~/.config/zen/<profile>/chrome/sine-mods/matugen-zen
```

2. Copy the mod files:
```bash
cp *.json *.uc.js *.css ~/.config/zen/<profile>/chrome/sine-mods/matugen-zen/
```

3. Add to `mods.json` in `~/.config/zen/<profile>/chrome/sine-mods/`:
```bash
cd ~/.config/zen/<profile>/chrome/sine-mods
python3 -c "
import json
with open('mods.json', 'r') as f:
    mods = json.load(f)
with open('matugen-zen/theme.json', 'r') as f:
    new_mod = json.load(f)
mods['matugen-zen'] = new_mod
mods['matugen-zen']['origin'] = 'store'
with open('mods.json', 'w') as f:
    json.dump(mods, f, indent=2)
"
```

## Configuration

Edit preferences in Sine settings:
- **Theme File Path**: Path to the zen-browser.css theme file (default: `~/.cache/matugen/zen-browser.css`)
- **Color Intensity**: 0-200 (default: 150)
- **Color Brightness**: 0-100 (default: 15)
- **Color Strength**: 0-100, lower = stronger (default: 30)

## Theme File

The mod watches for changes in the chrome theme file and automatically applies the surface color to Zen Boosts for all websites.

## Template Setup

The install script will automatically copy the template to your matugen config. To do it manually:

```bash
mkdir -p ~/.config/matugen/templates
cp templates/zen-browser.css ~/.config/matugen/templates/
```

The template uses matugen's dot-notation syntax (`{{ colors.surface.default.hex }}`) that Matugen replaces with actual Material You colors.

## Requirements

- [Matugen](https://github.com/InioX/matugen) with theme generation configured
- Zen Browser with Sine mod system installed
- A `zen-browser.css` template in `~/.config/matugen/templates/`

## License

GPL-3.0
