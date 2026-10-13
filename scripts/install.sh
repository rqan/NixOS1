#!/usr/bin/env bash
# ==============================================================================
# Script Instalasi & Penyiapan PC Baru (NixOS + Hyprland + Serpantinum)
# Menjamin 99% UI/UX persis sama dengan laptop sumber
# ==============================================================================
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOST="${1:-generic}"

echo "=========================================================="
echo "  Penyiapan Konfigurasi Komputer Baru (NixOS Rice Setup)  "
echo "  Target Host Profile: $TARGET_HOST"
echo "=========================================================="

cd "$REPO_DIR"

# 1. Pastikan hardware-configuration.nix sesuai dengan komputer target jika host generic
if [ "$TARGET_HOST" = "generic" ]; then
    echo "==> Mendeteksi konfigurasi perangkat keras komputer target..."
    if command -v nixos-generate-config >/dev/null 2>&1; then
        echo "==> Membuat hosts/generic/hardware-configuration.nix dari hardware saat ini..."
        nixos-generate-config --show-hardware-config > "$REPO_DIR/hosts/generic/hardware-configuration.nix"
    elif [ -f /etc/nixos/hardware-configuration.nix ]; then
        echo "==> Menyalin /etc/nixos/hardware-configuration.nix ke hosts/generic/..."
        cp /etc/nixos/hardware-configuration.nix "$REPO_DIR/hosts/generic/hardware-configuration.nix"
    else
        echo "!! PERINGATAN: nixos-generate-config tidak ditemukan. Pastikan hosts/generic/hardware-configuration.nix sudah diisi."
    fi
fi

# 2. Siapkan aset profil dan wallpaper pengguna
echo "==> Menyiapkan folder aset (~/Pictures/Wallpapers dan Profile Pictures)..."
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Profile Pictures"

if [ -f "$REPO_DIR/assets/profile/the_fallen_angel.jpg" ]; then
    cp "$REPO_DIR/assets/profile/the_fallen_angel.jpg" "$HOME/Pictures/Profile Pictures/The Fallen Angel.jpg"
fi

if [ -f "$REPO_DIR/assets/wallpapers/default_desktop.jpg" ]; then
    cp "$REPO_DIR/assets/wallpapers/default_desktop.jpg" "$HOME/Pictures/Wallpapers/default_desktop.jpg"
fi

# 3. Siapkan wallpaper untuk SDDM Greeter (/var/lib/sddm-wallpaper)
echo "==> Menyiapkan direktori SDDM Wallpaper (/var/lib/sddm-wallpaper)..."
sudo mkdir -p /var/lib/sddm-wallpaper
sudo chown -R "$USER":users /var/lib/sddm-wallpaper 2>/dev/null || sudo chown -R 1000:100 /var/lib/sddm-wallpaper

if [ -f "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" /var/lib/sddm-wallpaper/wallpaper_type
fi
if [ -f "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" /var/lib/sddm-wallpaper/current_wallpaper
fi

# 4. Siapkan dotfiles Serpantinum agar dapat ditulis oleh UI
mkdir -p "$HOME/.config/serpantinum"
if [ ! -f "$HOME/.config/serpantinum/settings.json" ]; then
    echo "==> Menginisialisasi settings.json Serpantinum..."
    cp "$REPO_DIR/dotfiles/serpantinum/settings.json" "$HOME/.config/serpantinum/settings.json"
    chmod 644 "$HOME/.config/serpantinum/settings.json"
fi

# 5. Stage semua file ke git agar Nix Flakes mengenali file baru
git add -A

# 6. Jalankan nixos-rebuild switch
echo "==> Membangun sistem NixOS dengan Flake..."
sudo nixos-rebuild switch --flake ".#$TARGET_HOST"

echo "=========================================================="
echo "  Instalasi Selesai! Sistem siap digunakan.               "
echo "  UI/UX telah diselaraskan dengan laptop sumber.          "
echo "=========================================================="
