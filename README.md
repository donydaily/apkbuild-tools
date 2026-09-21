# 🤖 apkbuild

**apkbuild** adalah *tool* Command Line Interface (CLI) berbasis Bash untuk sistem operasi Linux. Tool ini dirancang untuk melakukan otomatisasi setup *environment*, inisialisasi struktur proyek Android modern, serta proses *build* APK (Debug & Release) secara praktis tanpa memerlukan Android Studio.

---

## 💡 Fitur Utama

- 🛠️ **Auto Setup Environment**: Otomatis mengunduh dan memasang SDKMAN!, OpenJDK 21, Android Command-line Tools, serta SDK Platform (API 33 – API 37).
- 📦 **Inisialisasi Proyek Dinamis**: Mengatur *Package Name*, *App Name*, dan direktori kode secara interaktif saat inisialisasi.
- 🎨 **Resource & App Icon Lengkap**: Menyediakan struktur berkas XML standar (`strings.xml`, `colors.xml`, `dimens.xml`, `attrs.xml`, `styles.xml`, `themes.xml`) serta *Adaptive App Icon* berbasis Vector XML.
- 🔑 **Auto Keystore Generation**: Membuat `debug.keystore` secara otomatis menggunakan `keytool` bawaan JDK.
- 🏷️ **Dynamic Version Name**: Menambahkan akhiran nama versi secara otomatis (`-debug` untuk varian Debug dan `-release` untuk varian Release).
- ⚡ **Siap Pakai**: Menggunakan konfigurasi *stack* modern (Gradle 8.10, AGP 8.7.0, Kotlin 2.0.20).

---

## 🛠️ Persyaratan Sistem

Tool ini dapat berjalan di berbagai distribusi Linux (Fedora, Arch Linux, Ubuntu/Debian) dengan ketergantungan paket dasar berikut:

- `curl`, `wget`, `unzip`, `git`
- `zip` / `tar`

---

## 🚀 Instalasi

**CURL**
   ```bash
   curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install.sh | bash
   ```
**WGET**
   ```bash
   wget -qO- https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install.sh | bash
   ```
