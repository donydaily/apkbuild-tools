#!/usr/bin/env bash
set -e

echo "[+] Mengunduh dan memasang apkbuild ke /usr/local/bin/..."
sudo curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/apkbuild -o /usr/local/bin/apkbuild
sudo chmod +x /usr/local/bin/apkbuild

# --- TEMPLATE FUNGSIONALITAS AUTO CD ---
SHELL_FUNC_POSIX='
# apkbuild auto-cd function
apkbuild() {
    if [ "$1" = "init" ]; then
        /usr/local/bin/apkbuild "$@"
        LATEST_DIR=$(ls -td -- */ 2>/dev/null | head -n 1)
        if [ -n "$LATEST_DIR" ]; then
            cd "$LATEST_DIR"
        fi
    else
        /usr/local/bin/apkbuild "$@"
    fi
}'

SHELL_FUNC_FISH='
# apkbuild auto-cd function
function apkbuild
    if test "$argv[1]" = "init"
        /usr/local/bin/apkbuild $argv
        set LATEST_DIR (ls -td -- */ 2>/dev/null | head -n 1)
        if test -n "$LATEST_DIR"
            cd "$LATEST_DIR"
        end
    else
        /usr/local/bin/apkbuild $argv
    end
end'

add_to_config() {
    CONFIG_FILE="$1"
    FUNC_BODY="$2"
    
    # Pastikan direktori tempat file config berada sudah ada
    mkdir -p "$(dirname "$CONFIG_FILE")"
    touch "$CONFIG_FILE"
    
    if ! grep -q "apkbuild auto-cd function" "$CONFIG_FILE"; then
        echo "[+] Menambahkan fungsi auto-cd apkbuild ke $CONFIG_FILE..."
        echo "$FUNC_BODY" >> "$CONFIG_FILE"
    else
        echo "[!] Fungsi apkbuild sudah terpasang di $CONFIG_FILE."
    fi
}

# --- DETEKSI SHELL YANG SEDANG AKTIF ---
USER_SHELL=""

# 1. Cek dari nama proses induk (PPID) jika dijalankan via pipe/curl
PARENT_PROC=$(ps -p $PPID -o comm= 2>/dev/null || true)
if [ -n "$PARENT_PROC" ]; then
    USER_SHELL=$(basename "$PARENT_PROC")
fi

# 2. Fallback menggunakan variabel $SHELL jika PPID mengembalikan bash/sh dasar
if [ -z "$USER_SHELL" ] || [ "$USER_SHELL" = "sh" ]; then
    if [ -n "$SHELL" ]; then
        USER_SHELL=$(basename "$SHELL")
    fi
fi

echo "[+] Shell aktif terdeteksi: $USER_SHELL"

# --- PROSES INJEKSI KONFIGURASI SESUAI SHELL ---
case "$USER_SHELL" in
    fish)
        add_to_config "$HOME/.config/fish/config.fish" "$SHELL_FUNC_FISH"
        ;;
    zsh)
        add_to_config "$HOME/.zshrc" "$SHELL_FUNC_POSIX"
        ;;
    bash)
        add_to_config "$HOME/.bashrc" "$SHELL_FUNC_POSIX"
        ;;
    *)
        echo "[!] Shell spesifik tidak dapat dipastikan. Memasang ke ~/.bashrc sebagai default..."
        add_to_config "$HOME/.bashrc" "$SHELL_FUNC_POSIX"
        ;;
esac

# Auto-reload untuk session Bash/Zsh/Fish yang sedang berjalan jika memungkinkan
case "$USER_SHELL" in
    fish)
        echo "[+] Menjalankan reload konfigurasi Fish..."
        fish -c "source ~/.config/fish/config.fish" 2>/dev/null || true
        ;;
    zsh)
        echo "[+] Menjalankan reload konfigurasi Zsh..."
        zsh -c "source ~/.zshrc" 2>/dev/null || true
        ;;
    bash)
        echo "[+] Menjalankan reload konfigurasi Bash..."
        bash -c "source ~/.bashrc" 2>/dev/null || true
        ;;
esac

echo "[+] Instalasi selesai!"
echo "[+] Silakan buka terminal baru atau restart session shell kamu untuk mengaktifkan 'apkbuild'."

