#!/usr/bin/env bash
# ==============================================================================
# Script Pemasangan Antigravity Baru di NixOS
# ==============================================================================
set -e

echo "=========================================================="
echo "          Pemasangan Antigravity di Komputer Baru         "
echo "=========================================================="

mkdir -p "$HOME/.local/bin" "$HOME/.local/opt" "$HOME/.local/share/icons"

# 1. Pasang Antigravity CLI (agy) resmi dari Google
echo "==> Mengunduh dan memasang Antigravity CLI (agy)..."
curl -fsSL https://antigravity.google/cli/install.sh | bash

# 2. Periksa apakah ada installer Antigravity IDE / App di ~/Downloads
TAR_FILE=$(find "$HOME/Downloads" -maxdepth 2 \( -iname "*antigravity*.tar.gz" -o -iname "*Antigravity*.tar.gz" \) 2>/dev/null | head -n 1 || true)

if [ -n "$TAR_FILE" ] && [ -f "$TAR_FILE" ]; then
    echo "==> Menemukan file installer Antigravity Desktop: $TAR_FILE"
    echo "==> Mengekstrak ke ~/.local/opt/Antigravity-x64..."
    rm -rf "$HOME/.local/opt/Antigravity-x64"
    mkdir -p "$HOME/.local/opt/Antigravity-x64"
    tar -xzf "$TAR_FILE" -C "$HOME/.local/opt/Antigravity-x64" --strip-components=1 2>/dev/null || tar -xzf "$TAR_FILE" -C "$HOME/.local/opt/"
    
    # Normalisasi path
    if [ ! -f "$HOME/.local/opt/Antigravity-x64/antigravity" ]; then
        SUBDIR=$(find "$HOME/.local/opt" -maxdepth 2 -type f -name "antigravity" 2>/dev/null | head -n 1)
        if [ -n "$SUBDIR" ]; then
            PARENT=$(dirname "$SUBDIR")
            if [ "$PARENT" != "$HOME/.local/opt/Antigravity-x64" ]; then
                mv "$PARENT" "$HOME/.local/opt/Antigravity-x64"
            fi
        fi
    fi

    chmod +x "$HOME/.local/opt/Antigravity-x64/antigravity"
    ln -sf "$HOME/.local/opt/Antigravity-x64/antigravity" "$HOME/.local/bin/antigravity"
    echo "==> Antigravity Desktop IDE berhasil dipasang!"
else
    echo "----------------------------------------------------------"
    echo " Antigravity CLI ('agy') sudah berhasil dipasang."
    echo ""
    echo " Untuk Antigravity GUI / Desktop IDE:"
    echo " 1. Unduh 'Linux x64 (.tar.gz)' dari:"
    echo "    https://antigravity.google/download"
    echo " 2. Simpan di folder ~/Downloads"
    echo " 3. Jalankan kembali script ini:"
    echo "    ./scripts/install-antigravity.sh"
    echo "----------------------------------------------------------"
fi

echo "=========================================================="
echo " Selesai! Jalankan 'agy' di terminal untuk CLI,"
echo " atau 'antigravity' untuk membuka Desktop IDE."
echo "=========================================================="
