#!/usr/bin/env bash
# ==============================================================================
# Script Pack Antigravity (Jalankan di Laptop ini)
# Mengemas Antigravity IDE & agy CLI menjadi file arsip portable
# ==============================================================================
set -e

OUTPUT_TAR="$HOME/antigravity-portable.tar.gz"

echo "==> Mengemas Antigravity ke: $OUTPUT_TAR"

tar -czf "$OUTPUT_TAR" \
    -C "$HOME" \
    .local/opt/Antigravity-x64 \
    .local/bin/agy \
    .local/bin/antigravity \
    .local/share/icons/antigravity.png \
    .local/share/applications/antigravity.desktop 2>/dev/null || true

echo "=========================================================="
echo " Berhasil dibuat: $OUTPUT_TAR"
echo " Ukuran file: $(du -sh "$OUTPUT_TAR" | cut -f1)"
echo ""
echo " Salin file 'antigravity-portable.tar.gz' ini ke komputer baru"
echo " (bisa via flashdisk, Local Network / SCP, atau Google Drive)."
echo "=========================================================="
