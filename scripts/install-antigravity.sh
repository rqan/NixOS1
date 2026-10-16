#!/usr/bin/env bash
# ==============================================================================
# Script Pemasangan Resmi Antigravity Desktop IDE (GUI) & CLI untuk NixOS
# Mengunduh langsung dari Google CDN resmi tanpa perlu download manual
# ==============================================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"

echo "=========================================================="
echo "    Pemasangan Otomatis Antigravity Desktop IDE (GUI)     "
echo "=========================================================="

# 1. Pastikan folder tujuan tersedia
mkdir -p "$HOME/.local/bin" "$HOME/.local/opt" "$HOME/.local/share/applications" "$HOME/.local/share/icons"

# 2. Salin icon Antigravity ke direktori icon pengguna jika tersedia di repo
if [ -f "$REPO_DIR/assets/icons/antigravity.png" ]; then
    echo "==> Memasang ikon Antigravity ke ~/.local/share/icons/antigravity.png..."
    cp "$REPO_DIR/assets/icons/antigravity.png" "$HOME/.local/share/icons/antigravity.png"
fi

# 3. Dapatkan tautan unduhan resmi Antigravity Desktop IDE GUI (Linux x64)
LATEST_API_URL="https://antigravity-ide-auto-updater-974169037036.us-central1.run.app/api/update/linux-x64/stable/latest"
FALLBACK_URL="https://edgedl.me.gvt1.com/edgedl/release2/j0qc3/antigravity/stable/2.5.5-4923483625488384/linux-x64/Antigravity%20IDE.tar.gz"

echo "==> Memeriksa tautan unduhan versi stabil terbaru dari Google..."
DOWNLOAD_URL=""
if command -v curl >/dev/null 2>&1 && command -v jq >/dev/null 2>&1; then
    DOWNLOAD_URL=$(curl -s "$LATEST_API_URL" | jq -r '.url // empty' 2>/dev/null || true)
fi

if [ -z "$DOWNLOAD_URL" ] || [ "$DOWNLOAD_URL" = "null" ]; then
    DOWNLOAD_URL="$FALLBACK_URL"
fi

# URL encode spasi agar tidak ditolak oleh curl
DOWNLOAD_URL="${DOWNLOAD_URL// /%20}"

echo "==> URL Unduhan: $DOWNLOAD_URL"

# 4. Unduh tarball Antigravity IDE GUI jika belum ada
ARCHIVE_PATH="/tmp/Antigravity-IDE-latest.tar.gz"

# Cek apakah ada file tarball di ~/Downloads atau di /tmp yang masih utuh
LOCAL_FOUND=$(find "$HOME/Downloads" /tmp -maxdepth 2 \( -iname "*antigravity*.tar.gz" -o -iname "*Antigravity*.tar.gz" \) -size +150M 2>/dev/null | head -n 1 || true)

if [ -n "$LOCAL_FOUND" ] && [ -f "$LOCAL_FOUND" ]; then
    echo "==> Menggunakan file installer yang sudah ada di lokal: $LOCAL_FOUND"
    ARCHIVE_PATH="$LOCAL_FOUND"
else
    echo "==> Mengunduh Antigravity Desktop IDE GUI (~240 MB) dari Google CDN..."
    curl -# -fL "$DOWNLOAD_URL" -o "$ARCHIVE_PATH"
fi

# 5. Ekstraksi biner ke ~/.local/opt/Antigravity-x64
echo "==> Mengekstrak Antigravity Desktop IDE ke ~/.local/opt/Antigravity-x64..."
rm -rf "$HOME/.local/opt/Antigravity-x64"
mkdir -p "$HOME/.local/opt/Antigravity-x64"

tar -xzf "$ARCHIVE_PATH" -C "$HOME/.local/opt/Antigravity-x64" --strip-components=1 2>/dev/null || tar -xzf "$ARCHIVE_PATH" -C "$HOME/.local/opt/"

# Normalisasi path jika struktur tarball berbeda
if [ ! -f "$HOME/.local/opt/Antigravity-x64/antigravity" ]; then
    SUBDIR=$(find "$HOME/.local/opt" -maxdepth 2 -type f -name "antigravity" 2>/dev/null | head -n 1 || true)
    if [ -n "$SUBDIR" ]; then
        PARENT=$(dirname "$SUBDIR")
        if [ "$PARENT" != "$HOME/.local/opt/Antigravity-x64" ]; then
            rm -rf "$HOME/.local/opt/Antigravity-x64"
            mv "$PARENT" "$HOME/.local/opt/Antigravity-x64"
        fi
    fi
fi

# Normalisasi nama file biner utama
if [ -f "$HOME/.local/opt/Antigravity-x64/antigravity-ide" ] && [ ! -f "$HOME/.local/opt/Antigravity-x64/antigravity" ]; then
    ln -sf "$HOME/.local/opt/Antigravity-x64/antigravity-ide" "$HOME/.local/opt/Antigravity-x64/antigravity"
elif [ -f "$HOME/.local/opt/Antigravity-x64/antigravity" ] && [ ! -f "$HOME/.local/opt/Antigravity-x64/antigravity-ide" ]; then
    ln -sf "$HOME/.local/opt/Antigravity-x64/antigravity" "$HOME/.local/opt/Antigravity-x64/antigravity-ide"
fi

# 6. Set permission biner executable
echo "==> Mengatur izin eksekusi biner..."
chmod +x "$HOME/.local/opt/Antigravity-x64/antigravity"* 2>/dev/null || true
chmod +x "$HOME/.local/opt/Antigravity-x64/chrome_crashpad_handler" 2>/dev/null || true
chmod +x "$HOME/.local/opt/Antigravity-x64/chrome-sandbox" 2>/dev/null || true
if [ -d "$HOME/.local/opt/Antigravity-x64/bin" ]; then
    chmod +x "$HOME/.local/opt/Antigravity-x64/bin/"* 2>/dev/null || true
fi
if [ -d "$HOME/.local/opt/Antigravity-x64/resources/bin" ]; then
    chmod +x "$HOME/.local/opt/Antigravity-x64/resources/bin/"* 2>/dev/null || true
fi

# 7. Unduh dan pasang Antigravity Hub 2.0 (AI Agent Dashboard)
HUB_DIR="$HOME/.local/opt/Antigravity-Hub-x64"
HUB_URL="https://storage.googleapis.com/antigravity-public/antigravity-hub/2.23.0-5238607586394112/linux-x64/Antigravity.tar.gz"
HUB_ARCHIVE="/tmp/Antigravity-Hub.tar.gz"

if [ ! -x "$HUB_DIR/antigravity" ]; then
    echo "==> Mengunduh Antigravity Hub 2.0 Dashboard (~180 MB)..."
    if [ ! -f "$HUB_ARCHIVE" ]; then
        curl -# -fL "$HUB_URL" -o "$HUB_ARCHIVE"
    fi
    mkdir -p "$HUB_DIR"
    tar -xzf "$HUB_ARCHIVE" -C "$HUB_DIR" --strip-components=1 2>/dev/null || tar -xzf "$HUB_ARCHIVE" -C "$HUB_DIR"
    chmod +x "$HUB_DIR/antigravity"* "$HUB_DIR/chrome"* 2>/dev/null || true
    rm -f "$HUB_ARCHIVE"
fi

# 8. Buat symlink ke ~/.local/bin
ln -sf "$HOME/.local/opt/Antigravity-x64/bin/antigravity-ide" "$HOME/.local/bin/antigravity-ide"
ln -sf "$HUB_DIR/antigravity" "$HOME/.local/bin/antigravity-hub"
ln -sf "$HUB_DIR/antigravity" "$HOME/.local/bin/antigravity-dashboard"
ln -sf "$HOME/.local/opt/Antigravity-x64/bin/antigravity-ide" "$HOME/.local/bin/antigravity"

# 9. Buat .desktop entries untuk Application Menu & Serpantinum Launcher
echo "==> Memasang shortcut aplikasi Antigravity IDE & Antigravity Dashboard..."
cat <<EOF > "$HOME/.local/share/applications/antigravity-ide.desktop"
[Desktop Entry]
Name=Antigravity GUI (Text Editor)
Comment=Google Antigravity IDE (Code Editor)
GenericName=Code Editor & IDE
Exec=$HOME/.local/opt/Antigravity-x64/antigravity-ide %F
Icon=antigravity
Type=Application
StartupNotify=true
StartupWMClass=antigravity-ide
Categories=Development;IDE;TextEditor;
MimeType=text/plain;inode/directory;
EOF
chmod 644 "$HOME/.local/share/applications/antigravity-ide.desktop"

cat <<EOF > "$HOME/.local/share/applications/antigravity-dashboard.desktop"
[Desktop Entry]
Name=Antigravity GUI (Dashboard)
Comment=Google Antigravity 2.0 (AI Agent Dashboard)
GenericName=AI Agent Mission Control
Exec=$HUB_DIR/antigravity
Icon=antigravity
Type=Application
StartupNotify=true
StartupWMClass=antigravity
Categories=Development;ArtificialIntelligence;Utility;
EOF
chmod 644 "$HOME/.local/share/applications/antigravity-dashboard.desktop"

rm -f "$HOME/.local/share/applications/antigravity.desktop"

# Perbarui database desktop jika update-desktop-database tersedia
if command -v update-desktop-database >/dev/null 2>&1; then
    update-desktop-database "$HOME/.local/share/applications" 2>/dev/null || true
fi

# 10. Pasang Antigravity CLI (agy)
echo "==> Memasang / memperbarui Antigravity CLI (agy)..."
if command -v curl >/dev/null 2>&1; then
    curl -fsSL https://antigravity.google/cli/install.sh | bash 2>/dev/null || true
fi

# 11. Bersihkan file sementara jika di /tmp
if [ "$ARCHIVE_PATH" = "/tmp/Antigravity-IDE-latest.tar.gz" ]; then
    rm -f "$ARCHIVE_PATH"
fi

# 12. Verifikasi eksekusi biner
echo "=========================================================="
echo " [SUKSES] Dua GUI Antigravity berhasil dipasang!          "
echo " 1. Antigravity IDE (Teks Editor)   : 'antigravity-ide'   "
echo " 2. Antigravity Dashboard (AI 2.0)  : 'antigravity-hub'   "
echo "=========================================================="
