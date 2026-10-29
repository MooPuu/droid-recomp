<div align="center">

<img src="./DroidRecomp%20Logo.svg" width="160" alt="DroidRecomp Logo" />

# ⚡ DroidRecomp

### The Definitive Hub for Native Console & PC Recompilations & Emulators on Android

[![GitHub Pages](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-34F2E8?style=for-the-badge&logo=github&logoColor=0B1220)](https://moopuu.github.io/droid-recomp/)
[![Download APK](https://img.shields.io/badge/Download-Android%20APK%20(v1.0.0)-34F2E8?style=for-the-badge&logo=android&logoColor=0B1220)](https://github.com/MooPuu/droid-recomp/releases/download/v1.0.0/DroidRecomp-v1.0.0-release.apk)
[![Platform](https://img.shields.io/badge/Platform-Android%208.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://moopuu.github.io/droid-recomp/)
[![License](https://img.shields.io/badge/License-MIT-377BB6?style=for-the-badge)](LICENSE)
[![Catalog Size](https://img.shields.io/badge/Verified%20Recomps-345%2B%20Playable-34F2E8?style=for-the-badge)](catalog.json)
[![Emulators Hub](https://img.shields.io/badge/Emulators-50%20Verified%20Suites-34F2E8?style=for-the-badge)](emulators.json)
[![BYOR Legal](https://img.shields.io/badge/Zero%20ROMs-100%25%20Legal%20BYOR-52B788?style=for-the-badge)](#-legal-compliance--byor-architecture)
[![Themes](https://img.shields.io/badge/Themes-Midnight%20%7C%20Light%20%7C%20OLED-377BB6?style=for-the-badge)](https://moopuu.github.io/droid-recomp/)
[![Obtainium Ready](https://img.shields.io/badge/Sync-Obtainium%20Ready-F77F00?style=for-the-badge)](https://github.com/ImranR98/Obtainium)

<p align="center">
  <b>Play Nintendo 64, PlayStation, and PC classics running natively on ARM64 silicon — zero emulation overhead, uncapped frame rates, and native Android touch/controller controls.</b>
</p>

[**🌐 Launch Live Web App**](https://moopuu.github.io/droid-recomp/) • [**📲 Download APK (v1.0.0)**](https://github.com/MooPuu/droid-recomp/releases/download/v1.0.0/DroidRecomp-v1.0.0-release.apk) • [**🎮 Browse Recomps**](https://moopuu.github.io/droid-recomp/#all) • [**⚡ Emulators Hub**](https://moopuu.github.io/droid-recomp/#emulators) • [**🛠️ Submit Port**](https://moopuu.github.io/droid-recomp/#submit) • [**📥 Obtainium Pack**](https://moopuu.github.io/droid-recomp/#obtainium)

---

</div>

## 🌌 Overview

**DroidRecomp** is a high-performance web catalog, launcher, and native Android application inspired by the clean, cyberpunk aesthetic of [RecompLauncher](https://recomplauncher.com/). While traditional emulators translate machine instructions on the fly with massive performance hits, **static recompilations and decompilations** recompile original game machine code into native C/C++ or compile cleanly from reverse-engineered source code.

DroidRecomp indexes **345 verified native Android ports and static recompilations** and **50 top Android emulators (Free & Paid) + Turnip drivers** with comprehensive setup guides, hardware compatibility flags, triple-theme switching (Midnight Slate, Cyber Frost Light, and Pure AMOLED Black), an integrated 1-tap game launcher, and instant deep-linking into the **Obtainium** app manager for seamless background updates.

---

## ✨ Key Features

<table>
  <tr>
    <td width="50%">
      <h3>📱 Adaptive Dual-Engine UI (Web & Flutter)</h3>
      <ul>
        <li><b>Mobile Bottom Navigation:</b> 5-button touch navigation (Discover, Browse, Emulators, Library, Guide).</li>
        <li><b>Native Flutter Android App:</b> Full native Android app with APK package detection and direct intent launching.</li>
        <li><b>Triple Theme Engine:</b> Midnight Dark Slate, Cyber-Frost Light, and Pure AMOLED OLED Black.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🎮 Library & 1-Tap Game Launcher</h3>
      <ul>
        <li><b>1-Tap Native Launching:</b> Launch any installed recomp or port directly with a single tap.</li>
        <li><b>Custom Sideloaded Games:</b> Add any unlisted game or APK with package name and custom box art.</li>
        <li><b>Phone App Auto-Detection:</b> Pick directly from installed apps on your device to add to your shelf.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>⚡ Android Emulators Hub</h3>
      <ul>
        <li>21 curated console & PC emulators (NetherSX2, Sudachi, Dolphin, PPSSPP, Lime3DS, DuckStation, Vita3K, Winlator, Mobox, melonDS, Flycast, ScummVM, etc.).</li>
        <li>Direct APK download links, Obtainium deep links, and GitHub source links.</li>
        <li>Mesa Turnip Qualcomm Adreno GPU driver package companion.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🛠️ 1-Click Submission Portal</h3>
      <ul>
        <li>Interactive community submission wizard with live real-time card preview.</li>
        <li><b>1-Click GitHub Issue Generator:</b> Pre-populates a verified issue template with validated JSON.</li>
        <li>Instant clipboard export and local library testing.</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🕹️ Supported Systems & Verified Highlights

| Origin Platform | Architecture | Verified Playable Highlights | Input Support |
| :--- | :--- | :--- | :--- |
| **Nintendo 64** | Static Recomp & Decomp | *Zelda: Ocarina of Time* (Shipwright & Zelda64Recomp), *Majora's Mask* (2Ship2Harkinian), *Super Mario 64* (sm64ex), *Perfect Dark*, *Banjo-Kazooie* | Touch & Gamepad |
| **PlayStation 1** | C Decomp / Native | *Silent Hill*, *Driver 2*, *Crash Team Racing* (OpenCTR) | Touch & Gamepad |
| **PlayStation 2** | OpenGOAL Source Port | *Jak and Daxter: The Precursor Legacy* (OpenGOAL Android) | Gamepad / Turnip |
| **Classic PC Engines** | Clean-room Engine Ports | *Grand Theft Auto III / Vice City / San Andreas* (re3/reVC/AML), *Fallout 1 & 2* (fo2exe), *Diablo 1* (DevilutionX), *The Elder Scrolls III: Morrowind* (OpenMW), *Heroes of Might and Magic III* (VCMI), *Return to Castle Wolfenstein* (RTCW-Touch), *Sonic Mania* (RSDKv5), *Deus Ex*, *Balatro*, *Hollow Knight* | Touch, Mouse, Gamepad |
| **Handheld Classics** | Native C Ports | *Pokémon Emerald & FireRed* (pokeemerald native), *Sonic 1 & 2 & CD* (RSDKv3/v4), *AM2R* (Another Metroid 2 Remake) | Touch & Gamepad |

---

## 🚀 Native Flutter Android App Build Instructions

The complete native Flutter Android application source code is provided in `droid_recomp_app/`.

### Prerequisites
* Flutter SDK (3.24+)
* Android SDK & Java 17+ (JDK / Android Studio JBR)

### Compiling Release APK
Run the build script:
```powershell
powershell.exe -ExecutionPolicy Bypass -File "scripts/build_release_apk.ps1"
```
Or build manually via Flutter:
```bash
cd droid_recomp_app
flutter pub get
flutter build apk --release
```
The compiled, tree-shaken APK will be output to `build/app/outputs/flutter-apk/app-release.apk`.

---

## ⚖️ Legal Compliance & BYOR Architecture

> [!IMPORTANT]
> **DroidRecomp does NOT host, download, or distribute copyrighted ROMs, game assets, or proprietary commercial binaries.**

- **Clean-Room Engine Executables:** All indexed packages link directly to open-source developer repositories (GitHub, GitLab, Codeberg).
- **Bring-Your-Own-ROM (BYOR):** Recompilations extract and patch assets from retail game copies purchased and legally dumped by the user.
- **Client-Side Privacy:** All local storage (favorites, custom games, installed packages, and hash calculations) operates strictly on the user's client device.

---

## 🛠️ Repository Architecture

```text
├── .github/
│   └── workflows/
│       └── pages.yml              # Automated GitHub Pages CI/CD deployment
├── droid_recomp_app/              # Native Flutter & Android application codebase
│   ├── android/                   # Native Android wrapper & MethodChannel launcher
│   ├── assets/                    # Bundled catalog.json & emulators.json
│   ├── lib/
│   │   └── main.dart              # Flutter application code (5-tab navigation, themes, launcher)
│   ├── test/                      # Flutter widget tests
│   └── pubspec.yaml               # Flutter package configuration
├── scripts/
│   └── build_release_apk.ps1      # 1-click script to build release APK
├── index.html                     # Semantic responsive web application
├── styles.css                     # Neon cyan & dark midnight design system
├── app.js                         # Web router, launcher intent handler & submission wizard
├── catalog.js / catalog.json      # 345 verified Android recompilations & source ports
├── emulators.js / emulators.json  # 21 verified Android emulators & Turnip drivers
├── manifest.json                  # Progressive Web App (PWA) manifest
├── favicon.svg                    # Brand vector SVG favicon
├── DroidRecomp Logo.svg           # High-resolution vector brand logo
├── LICENSE                        # MIT License
└── README.md                      # Project documentation
```

---

<div align="center">

Crafted with ⚡ for the handheld gaming and Android emulation community by [**Mahdi Kareem (@MooPuu)**](https://github.com/MooPuu).

</div>
