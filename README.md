# MatugenZen

A Sine mod for mainly for Zen Browser and other firefox based browser that syncs Matugen's surface color to Zen Boosts, automatically theming all websites.

## Features

- Real-time sync with Matugen's generated theme files
- Automatically applies surface color to all websites via Zen Boosts
- Applies theme to browser chrome (background, sidebar, etc.)
- Configurable chrome theme path
- Minimal, lightweight implementation

## Installation

Run the install script:
```bash
# Run the install script
./install.sh
```
```
# Choose browser and profile
# Example
:: Detecting installed browsers...
Available browsers:
  1) Zen Browser (/opt/zen-browser-bin)  (default)
  2) Firefox (/usr/lib/firefox)
  0) Manual entry

Select browser [1]: 1

:: Finding profiles in /home/user/.config/zen...
Available profiles:
  1) Default Profile  (default)
  2) Default (release)

Select profile [1]: 2
```

This will automatically:
- Install sine mods and set it up
- Detect your Zen profile
- Copy the mod files
- Update `mods.json`
- Install the matugen template to `~/.config/matugen/templates/`

### Template Setup

The install script will automatically copy the template to your matugen templates, but you have to set them in `config.toml` manually:

```bash
[templates.zen]
input_path = '~/.config/matugen/templates/zen-browser.css'
output_path = '~/.cache/matugen/zen-browser.css'
```

## Configuration

Edit preferences in Sine settings:
- **Theme File Path**: Path to the zen-browser.css theme file (default: `~/.cache/matugen/zen-browser.css`)
- **Color Intensity**: 0-200 (default: 155)
- **Color Brightness**: 0-100 (default: 60)
- **Color Contrast**: 0-100, lower = stronger (default: 80)

## Theme File

The mod watches for changes in the chrome theme file and automatically applies the surface color to Zen Boosts for all websites.

## Requirements

- [Matugen](https://github.com/InioX/matugen) with theme generation configured
- Zen Browser with Sine mod system installed
- A `zen-browser.css` template in `~/.config/matugen/templates/`

## License

GPL-3.0
