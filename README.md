# NixOS Dotfiles & Flake Configuration (99% UI/UX Parity)

Repositori konfigurasi NixOS modular dengan desktop environment Hyprland, shell Quickshell (Serpantinum), tema SDDM video wallpaper, Spicetify, dan terminal rice siap pakai (*plug-and-play*).

## Struktur Repositori

```
NixOS/
├── flake.nix                       # Multi-host Flake definition
├── hosts/
│   ├── laptop/                     # Profil khusus laptop (Intel VAAPI + ASUS battery limit)
│   └── generic/                    # Profil PC / komputer target baru
├── modules/
│   ├── core/                       # Bootloader, network, sound (Pipewire), users, zram
│   ├── desktop/                    # Hyprland (UWSM), SDDM patched, fonts, wayland portals
│   └── programs/                   # Spicetify, dev packages, flatpak, podman, nix-ld
├── home/
│   └── default.nix                 # Home Manager: GTK WhiteSur theme, dotfiles symlinks, assets
├── dotfiles/                       # Konfigurasi desktop terpusat
│   ├── hypr/                       # Hyprland Lua configs, keybinds, scripts, shaders
│   ├── serpantinum/                # Quickshell Serpantinum settings.json
│   ├── kitty/                      # Terminal kitty colors & config
│   ├── foot/                       # Terminal foot config
│   ├── cava/                       # Audio visualizer config
│   ├── btop/                       # System monitor theme & config
│   ├── fastfetch/                  # Fastfetch system info config
│   ├── starship.toml               # Shell prompt
│   ├── gtk-3.0/ & gtk-4.0/         # WhiteSur GTK styling
│   └── bin/                        # Helper scripts (start-serpantinum.sh, etc.)
├── assets/                         # Aset visual default
│   ├── wallpapers/                 # Wallpaper desktop & SDDM video greeter
│   └── profile/                    # Foto profil pengguna (The Fallen Angel.jpg)
└── scripts/
    ├── install.sh                  # Script instalasi & setup 1-klik untuk PC baru
    └── apply.sh                    # Helper untuk menerapkan perubahan (nixos-rebuild switch)
```

## Cara Menyalin & Menggunakan di Komputer Baru

### 1. Salin atau Clone Repositori ke Komputer Baru
Di komputer baru yang sudah terpasang NixOS standar:
```bash
git clone <URL_REPOSITORI> ~/GitHub/NixOS
cd ~/GitHub/NixOS
```
*(Atau salin seluruh folder ini via USB flashdisk/LAN ke `~/GitHub/NixOS`).*

### 2. Jalankan Script Instalasi Otomatis
```bash
./scripts/install.sh generic
```
Script di atas akan:
1. Mendeteksi hardware komputer baru dan membuat `hosts/generic/hardware-configuration.nix` secara otomatis.
2. Menyiapkan folder `/var/lib/sddm-wallpaper` dan menyalin video wallpaper login screen.
3. Menyiapkan foto profil dan wallpaper di `~/Pictures/`.
4. Membangun sistem dan menerapkan seluruh dotfiles via Home Manager.

Setelah proses selesai, restart komputer atau login ke sesi **Hyprland**. UI/UX Anda akan 99% sama persis dengan laptop sumber!

---

## Menerapkan Perubahan di Komputer Ini (Laptop)

Untuk menerapkan perubahan konfigurasi pada laptop saat ini:
```bash
./scripts/apply.sh laptop
# atau cukup:
./scripts/apply.sh
```
