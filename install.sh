#!/usr/bin/env bash
set -e

echo "[+] Mengunduh apkbuild..."
sudo curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/apkbuild -o /usr/local/bin/apkbuild
echo "[+] Memberikan izin eksekusi..."
sudo chmod +x /usr/local/bin/apkbuild
echo "[+] apkbuild berhasil terpasang di /usr/local/bin/apkbuild"
echo "[+] Jalankan 'apkbuild' untuk melihat petunjuk penggunaan."
