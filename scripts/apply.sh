#!/usr/bin/env bash
set -e

REPO_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
HOST="${1:-focarix}"

echo "==> Menerapkan konfigurasi NixOS untuk host: $HOST"
echo "==> Direktori flake: $REPO_DIR"

cd "$REPO_DIR"

# Stage untracked files agar terbaca oleh Flakes
git add -A

echo "==> Menjalankan nixos-rebuild switch..."
sudo nixos-rebuild switch --flake ".#$HOST"

echo "==> Selesai! Konfigurasi berhasil diterapkan."
