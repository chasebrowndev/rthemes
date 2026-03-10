# rthemes

Hyprland + Waybar theme ricing and swapping made easy.

Apply fully configured themes — including Hyprland config, Waybar style, and wallpaper — with a single command.

---

## Dependencies

- [hyprland](https://hyprland.org/)
- [waybar](https://github.com/Alexays/Waybar)
- [swww](https://github.com/LGFae/swww)

---

## Installation

#
# NOT AVAILABLE IN THE AUR YET, THE FOLLOWING IS PLACEHOLDER TEXT:
#

### AUR (recommended)
```bash
yay -S rthemes
# or
paru -S rthemes
```

### Manual
```bash
git clone https://github.com/YOUR_USERNAME/rthemes
cd rthemes
install -Dm755 themeset.sh /usr/bin/themeset
mkdir -p /usr/share/themeset
cp -r themes/* /usr/share/themeset/
```

---

## First-time setup

rthemes will automatically add the following line to your `~/.config/hypr/hyprland.conf` on first run:

```
source = ~/.config/hypr/theme.conf
```

This is the only change made to your Hyprland config. All your existing settings are preserved.

---

## Usage

```bash
# Apply a theme
themeset <theme-name>

# Apply a theme with verbose output
themeset -v <theme-name>

# List all available themes
themeset --list
```

---

## Included themes

| Theme | Description |
|---|---|
| `berserk` | Dark, gritty tones inspired by the manga |
| `cyberpunk` | Neon-lit night city aesthetic |
| `eldensote` | Earthy fantasy palette |
| `kaneki` | Clean monochrome with sharp accents |

---

## Adding custom themes

Create a folder under `~/.config/themes/<your-theme-name>/` with any of the following files:

| File | Purpose |
|---|---|
| `hypr.conf` | Hyprland configuration |
| `waybar.css` | Waybar stylesheet |
| `waybar.jsonc` | Waybar layout config |
| `wallpaper.jpg` (or `.png`, `.webp`) | Wallpaper image |

All files are optional — only present ones will be applied.

User themes in `~/.config/themes/` take priority over installed themes, so you can override any bundled theme by creating a folder with the same name.

---

## License

Free to use, modify, and distribute — must always remain free of charge. See [LICENSE](LICENSE.txt).

---

*Bug reports and suggestions welcome — chase.brown.dev@gmail.com*
