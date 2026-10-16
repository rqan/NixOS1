#!/usr/bin/env bash
# ==============================================================================
# Script Instalasi & Penyiapan Total Komputer Baru / Laptop (NixOS Rice)
# Menyiapkan sistem 100% dari awal: Flake, Hyprland, Serpantinum,
# Antigravity IDE GUI, Brave, Microsoft Edge, dan seluruh aplikasi desktop.
# ==============================================================================
set -e

# PENCEGAHAN: Jangan jalankan script ini langsung dengan 'sudo'
if [ "$EUID" -eq 0 ]; then
    echo "=========================================================="
    echo " [ERROR] JANGAN jalankan script ini dengan 'sudo'!"
    echo " Jalankan sebagai pengguna biasa, contoh:"
    echo "   ./scripts/install.sh generic"
    echo ""
    echo " Script ini akan meminta password sudo secara otomatis"
    echo " hanya saat menjalankan nixos-rebuild dan setup SDDM."
    echo "=========================================================="
    exit 1
fi

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
TARGET_HOST="${1:-generic}"
CURRENT_USER="$(id -un)"

echo "=========================================================="
echo "    Penyiapan Sistem Total NixOS Rice (From Scratch)      "
echo "    Target Host Profile : $TARGET_HOST                    "
echo "    User Aktif          : $CURRENT_USER                   "
echo "=========================================================="

if [ "$CURRENT_USER" != "focarix" ]; then
    echo "----------------------------------------------------------"
    echo " [CATATAN PENTING USERNAME]"
    echo " Konfigurasi Flake & Home-Manager utama disetel untuk user: 'focarix'."
    echo " Sistem NixOS ini akan otomatis membuat user 'focarix' (password: 908)."
    echo " Pastikan saat di SDDM/Login Screen, Anda masuk sebagai 'focarix'!"
    echo "----------------------------------------------------------"
fi

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

# 2. PENCEGAHAN TABRAKAN: Cadangkan folder konfigurasi fisik lama agar Home-Manager tidak crash / collision
echo "==> Memeriksa dan mencadangkan folder konfigurasi fisik lama (mencegah Hyprland auto-config lock)..."
mkdir -p "$HOME/.config"
for d in hypr kitty foot cava btop fastfetch gtk-3.0 gtk-4.0 serpantinum; do
    if [ -d "$HOME/.config/$d" ] && [ ! -L "$HOME/.config/$d" ]; then
        echo "    -> Mengamankan folder fisik lama ~/.config/$d ke ~/.config/${d}.bak"
        rm -rf "$HOME/.config/${d}.bak"
        mv "$HOME/.config/$d" "$HOME/.config/${d}.bak"
    fi
done

if [ -f "$HOME/.config/starship.toml" ] && [ ! -L "$HOME/.config/starship.toml" ]; then
    mv "$HOME/.config/starship.toml" "$HOME/.config/starship.toml.bak"
fi

# 3. Bersihkan file lock Chromium/Electron (mencegah crash Brave, Edge, Code saat disalin antar komputer)
echo "==> Membersihkan file lock profil Chromium & Electron..."
rm -f "$HOME/.config/BraveSoftware/Brave-Browser/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/microsoft-edge/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/google-chrome/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/Code/Singleton"* 2>/dev/null || true
rm -f "$HOME/.config/Antigravity/Singleton"* 2>/dev/null || true

# 4. Siapkan direktori aset dan ikon
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

# 5. Siapkan wallpaper untuk SDDM Greeter (/var/lib/sddm-wallpaper)
echo "==> Menyiapkan direktori SDDM Wallpaper (/var/lib/sddm-wallpaper)..."
sudo mkdir -p /var/lib/sddm-wallpaper
sudo chown -R "$USER":users /var/lib/sddm-wallpaper 2>/dev/null || sudo chown -R 1000:100 /var/lib/sddm-wallpaper

if [ -f "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_wallpaper_type" /var/lib/sddm-wallpaper/wallpaper_type
fi
if [ -f "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" ]; then
    cp "$REPO_DIR/assets/wallpapers/sddm_current_wallpaper" /var/lib/sddm-wallpaper/current_wallpaper
fi

# 6. Siapkan dotfiles Serpantinum agar dapat ditulis oleh UI
mkdir -p "$HOME/.config/serpantinum"
if [ ! -f "$HOME/.config/serpantinum/settings.json" ]; then
    echo "==> Menginisialisasi settings.json Serpantinum..."
    cp "$REPO_DIR/dotfiles/serpantinum/settings.json" "$HOME/.config/serpantinum/settings.json"
    chmod 644 "$HOME/.config/serpantinum/settings.json"
fi

# 7. Stage seluruh file baru ke git agar Nix Flakes mengenalinya
echo "==> Memperbarui index git repository..."
git add -A

# 8. Rebuild sistem dengan Nix Flakes
echo "==> Membangun sistem NixOS dengan Flake host: $TARGET_HOST..."
sudo nixos-rebuild switch --flake ".#$TARGET_HOST"

# 9. Pasang / Perbarui Antigravity Desktop IDE GUI otomatis dari Google CDN
echo "==> Menjalankan pemasangan otomatis Antigravity Desktop IDE (GUI)..."
bash "$REPO_DIR/scripts/install-antigravity.sh"

# 10. Konfigurasi Flathub & Pasang Sober (Roblox) jika flatpak aktif
if command -v flatpak >/dev/null 2>&1; then
    echo "==> Mengonfigurasi Flathub dan Sober (Roblox)..."
    flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo || true
    flatpak install -y flathub org.vinegarhq.Sober || true
fi

# 11. Pengujian Mandiri (Self-Test)
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

# Verifikasi symlink konfigurasi Hyprland
if [ -L "$HOME/.config/hypr" ]; then
    echo "  [OK] Konfigurasi Hyprland: Terhubung ke Flake Dotfiles"
else
    echo "  [!] Konfigurasi Hyprland: Belum terhubung (masih folder fisik biasa)"
fi

echo "=========================================================="
echo "  Penyiapan Selesai! Sistem siap digunakan sepenuhnya.   "
echo "  - Antigravity GUI : SUPER + A atau klik ikon di menu   "
echo "  - Brave Browser   : SUPER + SHIFT + B                  "
echo "  - Terminal        : SUPER + T                          "
echo "  - File Manager    : SUPER + E                          "
echo "=========================================================="
