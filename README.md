# 🤖 apkbuild

**apkbuild** adalah *tool* Command Line Interface (CLI) berbasis Bash untuk sistem operasi Linux. Tool ini dirancang untuk melakukan otomatisasi setup *environment*, inisialisasi struktur proyek Android modern, serta proses *build* APK (Debug & Release) secara praktis tanpa memerlukan Android Studio.

---

## 🛠️ Tech Stack & Versi Utama

| Komponen | Versi / Spesifikasi |
| :--- | :--- |
| **Android Gradle Plugin (AGP)** | `8.7.0` |
| **Kotlin** | `2.0.20` |
| **Gradle Wrapper** | `8.10` |
| **Java (JDK)** | `21 LTS` (Temurin `21.0.4-tem`) |
| **Compile / Target SDK** | `35` (Android 15) |
| **Minimum SDK** | `33` (Android 13) |
| **Android Build-Tools** | `34.0.0` |

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

Tool ini dapat berjalan di berbagai distribusi **Linux** (Fedora, Arch Linux, Ubuntu/Debian) atau **Termux** (Android) dengan ketergantungan paket dasar berikut:

- `curl`, `wget`, `unzip`, `git`
- `zip` / `tar`

---

## 🚀 Instalasi

**CURL**
   ```bash
   curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install.sh | bash
   curl -sSL https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install-termux.sh | bash
   ```
**WGET**
   ```bash
   wget -qO- https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install.sh | bash
   wget -qO- https://raw.githubusercontent.com/donydaily/apkbuild-tools/main/install-termux.sh | bash
   ```
