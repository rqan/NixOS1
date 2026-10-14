#!/usr/bin/env bash
# ==============================================================================
# Script Unpack Antigravity (Jalankan di Komputer Baru)
# ==============================================================================
set -e

ARCHIVE_PATH="${1:-$HOME/antigravity-portable.tar.gz}"

if [ ! -f "$ARCHIVE_PATH" ]; then
    echo "!! File $ARCHIVE_PATH tidak ditemukan."
    echo "Penggunaan: ./scripts/unpack-antigravity.sh /path/ke/antigravity-portable.tar.gz"
    exit 1
fi

echo "==> Mengekstrak Antigravity dari: $ARCHIVE_PATH..."
mkdir -p "$HOME/.local/opt" "$HOME/.local/bin" "$HOME/.local/share/icons" "$HOME/.local/share/applications"

tar -xzf "$ARCHIVE_PATH" -C "$HOME"

chmod +x "$HOME/.local/opt/Antigravity-x64/antigravity" 2>/dev/null || true
chmod +x "$HOME/.local/bin/agy" 2>/dev/null || true
chmod +x "$HOME/.local/bin/antigravity" 2>/dev/null || true

echo "=========================================================="
echo " Antigravity berhasil dipasang di komputer ini!"
echo " Anda kini bisa menjalankannya via command: antigravity"
echo " atau klik ikon Antigravity di launcher aplikasi."
echo "=========================================================="
