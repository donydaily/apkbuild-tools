#!/usr/bin/env bash
set -e

PREFIX="${PREFIX:-/data/data/com.termux/files/usr}"

echo "[+] Mengunduh dan memasang apkbuild-termux ke $PREFIX/bin/..."
curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/apkbuild-termux -o "$PREFIX/bin/apkbuild"
chmod +x "$PREFIX/bin/apkbuild"

SHELL_FUNC_POSIX='
# apkbuild auto-cd function
apkbuild() {
    if [ "$1" = "init" ]; then
        '$PREFIX'/bin/apkbuild "$@"
        LATEST_DIR=$(ls -td -- */ 2>/dev/null | head -n 1)
        if [ -n "$LATEST_DIR" ]; then
            cd "$LATEST_DIR"
        fi
    else
        '$PREFIX'/bin/apkbuild "$@"
    fi
}'

SHELL_FUNC_FISH='
# apkbuild auto-cd function
function apkbuild
    if test "$argv[1]" = "init"
        '$PREFIX'/bin/apkbuild $argv
        set LATEST_DIR (ls -td -- */ 2>/dev/null | head -n 1)
        if test -n "$LATEST_DIR"
            cd "$LATEST_DIR"
        end
    else
        '$PREFIX'/bin/apkbuild $argv
    end
end'

add_to_config() {
    CONFIG_FILE="$1"
    FUNC_BODY="$2"
    
    mkdir -p "$(dirname "$CONFIG_FILE")"
    touch "$CONFIG_FILE"
    
    if ! grep -q "apkbuild auto-cd function" "$CONFIG_FILE"; then
        echo "[+] Menambahkan fungsi auto-cd apkbuild ke $CONFIG_FILE..."
        echo "$FUNC_BODY" >> "$CONFIG_FILE"
    else
        echo "[!] Fungsi apkbuild sudah terpasang di $CONFIG_FILE."
    fi
}

USER_SHELL=""
PARENT_PROC=$(ps -p $PPID -o comm= 2>/dev/null || true)
if [ -n "$PARENT_PROC" ]; then
    USER_SHELL=$(basename "$PARENT_PROC")
fi

if [ -z "$USER_SHELL" ] || [ "$USER_SHELL" = "sh" ]; then
    if [ -n "$SHELL" ]; then
        USER_SHELL=$(basename "$SHELL")
    fi
fi

echo "[+] Shell aktif terdeteksi: $USER_SHELL"

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

echo "[+] Instalasi Termux selesai!"
echo "[+] Buka kembali aplikasi Termux atau jalankan 'source ~/.${USER_SHELL}rc' untuk mulai menggunakan 'apkbuild'."
