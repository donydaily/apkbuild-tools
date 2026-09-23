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

# -- INSTALL APKTOOL CLI -- #
sudo cat << 'EOF' > /usr/local/bin/apktoolc
#!/usr/bin/env bash

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

check_and_install_deps() {
    local missing_deps=()

    if ! command -v java &> /dev/null; then missing_deps+=("java"); fi
    if ! command -v apksigner &> /dev/null; then missing_deps+=("android-tools"); fi
    if ! command -v jq &> /dev/null; then missing_deps+=("jq"); fi

    if [ ${#missing_deps[@]} -ne 0 ]; then
        echo -e "${YELLOW}[!] Dependensi sistem belum lengkap: ${missing_deps[*]}${NC}"
        echo -e "${BLUE}[+] Menginstall dependensi via package manager...${NC}"

        if command -v dnf &> /dev/null; then
            sudo dnf install java-latest-openjdk android-tools jq curl -y
        elif command -v pacman &> /dev/null; then
            sudo pacman -S --noconfirm jdk-openjdk android-tools jq curl
        elif command -v apt &> /dev/null; then
            sudo apt update && sudo apt install default-jdk android-sdk-platform-tools jq curl -y
        fi
    fi

    if [ ! -f /usr/local/bin/apktool ]; then
        echo -e "${BLUE}[+] Mengunduh wrapper script apktool...${NC}"
        sudo curl -sLo /usr/local/bin/apktool https://raw.githubusercontent.com/iBotPeaches/Apktool/master/scripts/linux/apktool
        sudo chmod +x /usr/local/bin/apktool
    fi

    if [ ! -f /usr/local/bin/apktool.jar ]; then
        echo -e "${BLUE}[+] Mencari versi Apktool terbaru di GitHub...${NC}"
        LATEST_URL=$(curl -s https://api.github.com/repos/iBotPeaches/Apktool/releases/latest | jq -r '.assets[] | select(.name | endswith(".jar")) | .browser_download_url')

        if [ -n "$LATEST_URL" ] && [ "$LATEST_URL" != "null" ]; then
            echo -e "${BLUE}[+] Mengunduh Apktool terbaru dari: $LATEST_URL${NC}"
            sudo curl -sLo /usr/local/bin/apktool.jar "$LATEST_URL"
            echo -e "${GREEN}[+] Apktool versi terbaru berhasil terpasang!${NC}\n"
        else
            echo -e "${RED}[!] Gagal mengambil info versi terbaru dari GitHub, mengunduh fallback version...${NC}"
            sudo curl -sLo /usr/local/bin/apktool.jar https://bitbucket.org/iBotPeaches/apktool/downloads/apktool_2.10.0.jar
        fi
    fi
}

check_and_install_deps

case "$1" in
    d|decompile)
        target_apk="$2"

        if [ -z "$target_apk" ]; then
            mapfile -t apk_files < <(find . -maxdepth 1 -name "*.apk" -type f | sed 's|^\./||')

            if [ ${#apk_files[@]} -eq 0 ]; then
                echo -e "${RED}[!] Tidak ditemukan file .apk di direktori saat ini.${NC}"
                exit 1
            elif [ ${#apk_files[@]} -eq 1 ]; then
                target_apk="${apk_files[0]}"
                echo -e "${BLUE}[+] Menemukan 1 APK: ${target_apk}${NC}"
            else
                echo -e "${YELLOW}[?] Ditemukan beberapa file APK. Pilih salah satu:${NC}"
                PS3="Masukkan nomor pilihan: "
                select selected in "${apk_files[@]}"; do
                    if [ -n "$selected" ]; then
                        target_apk="$selected"
                        break
                    else
                        echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                    fi
                done
            fi
        fi

        out_dir="${3:-${target_apk%.apk}_src}"
        echo -e "${BLUE}[+] Decompiling ${target_apk} ke ${out_dir}...${NC}"
        apktool d "$target_apk" -o "$out_dir" -f
        echo -e "${GREEN}[+] Decompile selesai! Folder: ${out_dir}${NC}"
        ;;
        
    b|build|recompile)
        src_dir="$2"

        if [ -z "$src_dir" ]; then
            mapfile -t src_folders < <(find . -maxdepth 2 -name "apktool.yml" -exec dirname {} \; | sed 's|^\./||')

            if [ ${#src_folders[@]} -eq 0 ]; then
                echo -e "${RED}[!] Tidak ditemukan folder proyek apktool di direktori saat ini.${NC}"
                exit 1
            elif [ ${#src_folders[@]} -eq 1 ]; then
                src_dir="${src_folders[0]}"
                echo -e "${BLUE}[+] Menemukan 1 proyek Apktool: ${src_dir}${NC}"
            else
                echo -e "${YELLOW}[?] Ditemukan beberapa folder proyek Apktool. Pilih salah satu:${NC}"
                PS3="Masukkan nomor pilihan: "
                select selected in "${src_folders[@]}"; do
                    if [ -n "$selected" ]; then
                        src_dir="$selected"
                        break
                    else
                        echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                    fi
                done
            fi
        fi

        out_apk="${3:-${src_dir%/}_signed.apk}"
        temp_apk="${src_dir%/}_temp.apk"
        
        echo -e "${BLUE}[+] Recompiling folder ${src_dir}...${NC}"
        apktool b "$src_dir" -o "$temp_apk"
        
        if [ -f "$temp_apk" ]; then
            echo -e "${BLUE}[+] Optimasi & Sign APK...${NC}"
            mkdir -p ~/.android
            if [ ! -f ~/.android/debug.keystore ]; then
                keytool -genkey -v -keystore ~/.android/debug.keystore -storepass android \
                -alias androiddebugkey -keypass android -keyalg RSA -keysize 2048 \
                -validity 10000 -dname "CN=Android Debug,O=Android,C=US"
            fi
            
            if command -v zipalign &> /dev/null; then
                zipalign -v -p 4 "$temp_apk" "$out_apk"
                rm -f "$temp_apk"
            else
                mv "$temp_apk" "$out_apk"
            fi
            
            apksigner sign --ks ~/.android/debug.keystore --ks-pass pass:android "$out_apk"
            echo -e "${GREEN}[+] Recompile & Signing sukses! File: ${out_apk}${NC}"
        else
            echo -e "${RED}[!] Gagal membuat APK saat recompile.${NC}"
        fi
        ;;

    i|install)
        target_apk="$2"
        if [ -z "$target_apk" ]; then
            mapfile -t apk_files < <(find . -maxdepth 1 -name "*.apk" -type f | sed 's|^\./||')

            if [ ${#apk_files[@]} -eq 0 ]; then
                echo -e "${RED}[!] Tidak ditemukan file .apk di direktori saat ini.${NC}"
                exit 1
            elif [ ${#apk_files[@]} -eq 1 ]; then
                target_apk="${apk_files[0]}"
            else
                echo -e "${YELLOW}[?] Pilih APK yang ingin diinstall via ADB:${NC}"
                PS3="Masukkan nomor pilihan: "
                select selected in "${apk_files[@]}"; do
                    if [ -n "$selected" ]; then
                        target_apk="$selected"
                        break
                    else
                        echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                    fi
                done
            fi
        fi
        echo -e "${BLUE}[+] Memasang ${target_apk} ke perangkat ADB...${NC}"
        adb install -r "$target_apk"
        ;;

    ev|extract-vectors)
        target_apk="$2"
        if [ -z "$target_apk" ]; then
            mapfile -t apk_files < <(find . -maxdepth 1 -name "*.apk" -type f | sed 's|^\./||')

            if [ ${#apk_files[@]} -eq 0 ]; then
                echo -e "${RED}[!] Tidak ditemukan file .apk di direktori saat ini.${NC}"
                exit 1
            elif [ ${#apk_files[@]} -eq 1 ]; then
                target_apk="${apk_files[0]}"
            else
                echo -e "${YELLOW}[?] Pilih APK untuk diekstrak Vector XML-nya:${NC}"
                PS3="Masukkan nomor pilihan: "
                select selected in "${apk_files[@]}"; do
                    if [ -n "$selected" ]; then
                        target_apk="$selected"
                        break
                    else
                        echo -e "${RED}[!] Pilihan tidak valid.${NC}"
                    fi
                done
            fi
        fi

        out_folder="${3:-${target_apk%.apk}_vectors}"
        temp_dir=$(mktemp -d)

        echo -e "${BLUE}[+] Membongkar resource dari ${target_apk}...${NC}"
        apktool d "$target_apk" -o "$temp_dir" -f -s
        
        mkdir -p "$out_folder"
        echo -e "${BLUE}[+] Menyaring file Vector XML ke ${out_folder}...${NC}"
        
        find "$temp_dir/res" -type f -name "*.xml" | while read -r file; do
            if grep -q "<vector" "$file"; then
                cp "$file" "$out_folder/"
            fi
        done
        
        rm -rf "$temp_dir"
        echo -e "${GREEN}[+] Berhasil mengekstrak $(ls "$out_folder" | wc -l) Vector XML ke folder: ${out_folder}${NC}"
        ;;

    l|logs)
        echo -e "${BLUE}[+] Membuka ADB Logcat (Filter Exception/Crash)...${NC}"
        adb logcat *:E | grep --line-buffered -E "AndroidRuntime|FATAL|System.err|Exception"
        ;;

    if|install-framework)
        if [ -z "$2" ]; then
            echo -e "${RED}[!] Usage: apktool-helper if <framework-res.apk>${NC}"
            exit 1
        fi
        echo -e "${BLUE}[+] Memasang framework-res ke apktool...${NC}"
        apktool if "$2"
        ;;

    update)
        echo -e "${BLUE}[+] Memaksa pembaruan Apktool ke versi terbaru...${NC}"
        sudo rm -f /usr/local/bin/apktool.jar
        check_and_install_deps
        ;;
        
    *)
        echo "=== APKTool Helper (Interactive Menu) ==="
        echo " d  | decompile          : apktoolc d [app.apk]"
        echo " b  | build              : apktoolc b [folder_src]"
        echo " i  | install            : apktoolc i [app_signed.apk]"
        echo " ev | extract-vectors    : apktoolc ev [app.apk]"
        echo " l  | logs               : apktoolc l"
        echo " if | install-framework  : apktoolc if <framework-res.apk>"
        echo " update                  : apktoolc update"
        ;;
esac
EOF

# Beri izin eksekusi
sudo chmod +x /usr/local/bin/apktool-helper

echo "[+] Instalasi selesai!"
echo "[+] Silakan buka terminal baru atau restart session shell kamu untuk mengaktifkan 'apkbuild'."

