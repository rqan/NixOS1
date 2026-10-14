#!/usr/bin/env bash
# ==============================================================================
# Script Instalasi & Penyiapan Total Komputer Baru / Laptop (NixOS Rice)
# Menyiapkan sistem 100% dari awal: Flake, Hyprland, Serpantinum,
# Antigravity IDE GUI, Brave, Microsoft Edge, dan seluruh aplikasi desktop.
# ==============================================================================
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOST="${1:-generic}"

echo "=========================================================="
echo "    Penyiapan Sistem Total NixOS Rice (From Scratch)      "
echo "    Target Host Profile: $TARGET_HOST                     "
echo "=========================================================="

cd "$REPO_DIR"

# 1. Pastikan hardware-configuration.nix sesuai dengan komputer target jika host generic
if [ "$TARGET_HOST" = "generic" ]; then
    echo "==> Mendeteksi konfigurasi perangkat keras komputer target..."
    if command -v nixos-generate-config >/dev/null 2>&1; then
        echo "==> Menghasilkan hosts/generic/hardware-configuration.nix secara otomatis..."
        nixos-generate-config --show-hardware-config > "$REPO_DIR/hosts/generic/hardware-configuration.nix"
    elif [ -f /etc/nixos/hardware-configuration.nix ]; then
        echo "==> Menyalin /etc/nixos/hardware-configuration.nix ke hosts/generic/..."
        cp /etc/nixos/hardware-configuration.nix "$REPO_DIR/hosts/generic/hardware-configuration.nix"
    else
        echo "!! PERINGATAN: Pastikan hosts/generic/hardware-configuration.nix sudah memuat partisi disk yang benar."
    fi
fi

# 2. Bersihkan file lock Chromium/Electron (mencegah crash Brave, Edge, Code saat disalin antar komputer)
echo "==> Membersihkan file lock profil Chromium & Electron..."
rm -f "$HOME/.config/BraveSoftware/Brave-Browser/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/microsoft-edge/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/google-chrome/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/Code/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/Antigravity/Singleton"* 2>/dev/null || true

# 3. Siapkan direktori aset dan ikon
echo "==> Menyiapkan folder aset (~/Pictures dan ~/.local/share/icons)..."
mkdir -p "$HOME/Pictures/Wallpapers" "$HOME/Pictures/Profile Pictures" "$HOME/.local/share/icons"

if [ -f "$REPO_DIR/assets/profile/the_fallen_angel.jpg" ]; then
    cp "$REPO_DIR/assets/profile/the_fallen_angel.jpg" "$HOME/Pictures/Profile Pictures/The Fallen Angel.jpg"
fi

if [ -f "$REPO_DIR/assets/wallpapers/default_desktop.jpg" ]; then
    cp "$REPO_DIR/assets/wallpapers/default_desktop.jpg" "$HOME/Pictures/Wallpapers/default_desktop.jpg"
fi

if [ -f "$REPO_DIR/assets/icons/antigravity.png" ]; then
    cp "$REPO_DIR/assets/icons/antigravity.png" "$HOME/.local/share/icons/antigravity.png"
fi

# 4. Siapkan wallpaper untuk SDDM Greeter (/var/lib/sddm-wallpaper)
echo "==> Menyiapkan direktori SDDM Wallpaper (/var/lib/sddm-wallpaper)..."
sudo mkdir -p /var/lib/sddm-wallpaper
sudo chown -R "$USER":users /var/lib/sddm-wallpaper 2>/dev/null || sudo chown -R 1000:100 /var/lib/sddm-wallpaper

if [ -f "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" /var/lib/sddm-wallpaper/wallpaper_type
fi
if [ -f "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" /var/lib/sddm-wallpaper/current_wallpaper
fi

# 5. Siapkan dotfiles Serpantinum agar dapat ditulis oleh UI
mkdir -p "$HOME/.config/serpantinum"
if [ ! -f "$HOME/.config/serpantinum/settings.json" ]; then
    echo "==> Menginisialisasi settings.json Serpantinum..."
    cp "$REPO_DIR/dotfiles/serpantinum/settings.json" "$HOME/.config/serpantinum/settings.json"
    chmod 644 "$HOME/.config/serpantinum/settings.json"
fi

# 6. Stage seluruh file baru ke git agar Nix Flakes mengenalinya
echo "==> Memperbarui index git repository..."
git add -A

# 7. Rebuild sistem dengan Nix Flakes
echo "==> Membangun sistem NixOS dengan Flake host: $TARGET_HOST..."
sudo nixos-rebuild switch --flake ".#$TARGET_HOST"

# 8. Pasang / Perbarui Antigravity Desktop IDE GUI otomatis dari Google CDN
echo "==> Menjalankan pemasangan otomatis Antigravity Desktop IDE (GUI)..."
bash "$REPO_DIR/scripts/install-antigravity.sh"

# 9. Konfigurasi Flathub & Pasang Sober (Roblox) jika flatpak aktif
if command -v flatpak >/dev/null 2>&1; then
    echo "==> Mengonfigurasi Flathub dan Sober (Roblox)..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak install -y flathub org.vinegarhq.Sober || true
fi

# 10. Pengujian Mandiri (Self-Test)
echo ""
echo "=========================================================="
echo "          PENGUJIAN MANDIRI SISTEM & APLIKASI             "
echo "=========================================================="

test_app() {
    local name="$1"
    local cmd="$2"
    if eval "$cmd" >/dev/null 2>&1; then
        echo "  [OK] $name: Berfungsi Normal"
    else
        echo "  [!] $name: Perlu diperiksa"
    fi
}

test_app "Antigravity Desktop IDE" "antigravity --version"
test_app "Brave Browser" "brave --version"
test_app "Microsoft Edge" "microsoft-edge --version"
test_app "VS Code" "code --version"
test_app "Kitty Terminal" "kitty --version"

echo "=========================================================="
echo "  Penyiapan Selesai! Sistem siap digunakan sepenuhnya.   "
echo "  - Antigravity GUI : SUPER + A atau klik ikon di menu   "
echo "  - Brave Browser   : SUPER + SHIFT + B                  "
echo "  - Terminal        : SUPER + T                          "
echo "  - File Manager    : SUPER + E                          "
echo "=========================================================="
