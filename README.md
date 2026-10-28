<div align="center">

# ⚡ DroidRecomp

### The Definitive Hub for Native Console & PC Recompilations on Android

[![GitHub Pages](https://img.shields.io/badge/Live%20Demo-GitHub%20Pages-34F2E8?style=for-the-badge&logo=github&logoColor=0B1220)](https://moopuu.github.io/droid-recomp/)
[![Platform](https://img.shields.io/badge/Platform-Android%208.0%2B-3DDC84?style=for-the-badge&logo=android&logoColor=white)](https://moopuu.github.io/droid-recomp/)
[![License](https://img.shields.io/badge/License-MIT-377BB6?style=for-the-badge)](LICENSE)
[![Catalog Size](https://img.shields.io/badge/Verified%20Recomps-370%2B%20Playable-34F2E8?style=for-the-badge)](catalog.json)
[![BYOR Legal](https://img.shields.io/badge/Zero%20ROMs-100%25%20Legal%20BYOR-52B788?style=for-the-badge)](#-legal-compliance--byor-architecture)
[![Themes](https://img.shields.io/badge/Themes-Midnight%20%7C%20Light%20%7C%20OLED-377BB6?style=for-the-badge)](https://moopuu.github.io/droid-recomp/)
[![Obtainium Ready](https://img.shields.io/badge/Sync-Obtainium%20Ready-F77F00?style=for-the-badge)](https://github.com/ImranR98/Obtainium)

<p align="center">
  <b>Play Nintendo 64, PlayStation, and PC classics running natively on ARM64 silicon — zero emulation overhead, uncapped frame rates, and native Android touch/controller controls.</b>
</p>

[**🌐 Launch Live Web App**](https://moopuu.github.io/droid-recomp/) • [**🎮 Browse 370+ Recomps**](https://moopuu.github.io/droid-recomp/#all) • [**📖 Setup Guide**](https://moopuu.github.io/droid-recomp/#how) • [**📥 Obtainium Pack**](https://moopuu.github.io/droid-recomp/#obtainium)

---

</div>

## 🌌 Overview

**DroidRecomp** is a high-performance web catalog and setup assistant inspired by the clean, cyberpunk aesthetic of [RecompLauncher](https://recomplauncher.com/). While traditional emulators translate machine instructions on the fly with massive performance hits, **static recompilations and decompilations** recompile original game machine code into native C/C++ or compile cleanly from reverse-engineered source code.

DroidRecomp indexes **371 verified, 100% playable native Android ports and static recompilations** (aggregated and deduplicated across OpenPortsGames, APKVision, DroidPorts, Pocket-Gaming, Codeberg, and GitHub) with comprehensive setup guides, hardware compatibility flags, triple-theme switching (Midnight Slate, Cyber Frost Light, and Pure AMOLED Black), and instant deep-linking into the **Obtainium** app manager for seamless updates.

---

## ✨ Key Features

<table>
  <tr>
    <td width="50%">
      <h3>📱 Adaptive Dual-Engine UI</h3>
      <ul>
        <li><b>Mobile Viewport:</b> Native thumb ergonomics, bottom sheet navigation, touch-optimized swipeable filter chips, and full PWA Add-to-Home-Screen capability.</li>
        <li><b>Desktop Viewport:</b> Expansive multi-column responsive grid, persistent system navigation, modal inspector, and keyboard shortcuts (press <code>/</code> to search).</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🎯 Hardware & Driver Filters</h3>
      <ul>
        <li><b>Touch Ready:</b> Filter ports equipped with on-screen virtual controls.</li>
        <li><b>Controller Ready:</b> Verified plug-and-play support for Bluetooth/USB gamepads (Odin, Retroid, Backbone, Xbox, DualSense).</li>
        <li><b>Turnip Recommended:</b> Identifies titles requiring or greatly benefiting from Mesa Turnip Adreno GPU drivers.</li>
      </ul>
    </td>
  </tr>
  <tr>
    <td width="50%">
      <h3>🔄 Obtainium Ecosystem Sync</h3>
      <ul>
        <li>One-tap <code>obtainium://app/...</code> links to import upstream GitHub releases directly into Obtainium.</li>
        <li>Instant <b>Obtainium JSON Sync Pack</b> exporter to batch-track your entire favorite library for background auto-updates.</li>
      </ul>
    </td>
    <td width="50%">
      <h3>🔐 Web Crypto ROM Verifier</h3>
      <ul>
        <li>In-browser, client-side SHA-1 cryptographic file checksum validator.</li>
        <li>Verifies whether your dumped retail ROM (e.g. <i>Zelda: Ocarina of Time</i>, <i>Majora's Mask</i>, <i>Mario 64</i>) matches the exact hash required by the recomp compiler.</li>
        <li><b>Zero upload:</b> ROM verification occurs 100% locally in your browser memory.</li>
      </ul>
    </td>
  </tr>
</table>

---

## 🕹️ Supported Systems & Verified Highlights

| Origin Platform | Architecture | Verified Playable Highlights | Input Support |
| :--- | :--- | :--- | :--- |
| **Nintendo 64** | Static Recomp & Decomp | *Zelda: Ocarina of Time* (Ship of Harkinian & Zelda64Recomp), *Majora's Mask* (2Ship2Harkinian), *Super Mario 64* (sm64ex), *Perfect Dark* | Touch & Gamepad |
| **PlayStation 1** | C Decomp / Native | *Silent Hill*, *Driver 2*, *Crash Team Racing* (OpenCTR) | Touch & Gamepad |
| **PlayStation 2** | OpenGOAL Source Port | *Jak and Daxter: The Precursor Legacy* (OpenGOAL Android) | Gamepad / Turnip |
| **Classic PC Engines** | Clean-room Engine Ports | *Grand Theft Auto III / Vice City / San Andreas* (re3/reVC/AML), *Fallout 1 & 2* (fo2exe), *Diablo 1* (DevilutionX), *The Elder Scrolls III: Morrowind* (OpenMW), *Heroes of Might and Magic III* (VCMI), *Return to Castle Wolfenstein* (RTCW-Touch), *Sonic Mania* (RSDKv5), *Deus Ex* | Touch, Mouse, Gamepad |
| **Handheld Classics** | Native C Ports | *Pokémon Emerald & FireRed* (pokeemerald native), *Sonic 1 & 2 & CD* (RSDKv3/v4), *AM2R* (Another Metroid 2 Remake) | Touch & Gamepad |

---

## 🚀 Live Web App & PWA Usage

The live web application is hosted on **GitHub Pages**:

```
https://moopuu.github.io/droid-recomp/
```

### Installing as a Mobile App (PWA)
1. Navigate to the link in Chrome on your Android device (or Retroid Pocket / AYN Odin).
2. Tap the three dots (⋮) in the browser header.
3. Select **Install app** or **Add to Home screen**.
4. DroidRecomp will launch full-screen with native app caching and zero browser borders.

---

## ⚖️ Legal Compliance & BYOR Architecture

> [!IMPORTANT]
> **DroidRecomp does NOT host, download, or distribute copyrighted ROMs, game assets, or proprietary commercial binaries.**

- **Clean-Room Engine Executables:** All indexed packages link directly to open-source developer repositories (GitHub, GitLab, Codeberg).
- **Bring-Your-Own-ROM (BYOR):** Recompilations extract and patch assets from retail game copies purchased and legally dumped by the user.
- **Data Privacy:** All local storage (favorites, UI mode settings, and hash computations) operates strictly on the client device.

---

## 🛠️ Repository Architecture

```text
├── .github/
│   └── workflows/
│       └── pages.yml      # Automated GitHub Pages CI/CD deployment
├── index.html             # Semantic responsive HTML structure
├── styles.css             # Neon cyan & dark midnight design system
├── app.js                 # Router, quad-filter engine & Obtainium link generator
├── catalog.js             # Zero-CORS browser-executable catalog database
├── catalog.json           # Raw JSON metadata specification
├── manifest.json          # Progressive Web App (PWA) manifest
├── favicon.svg            # Crisp vector SVG icon & app glyph
├── LICENSE                # MIT License
└── README.md              # Project documentation & reference
```

---

## 🤝 Contributing

We welcome additions of newly completed, fully playable Android recompilations and native source ports!

1. Fork this repository.
2. Edit `catalog.json` (and update `catalog.js`) adding your game entry following the schema:
   ```json
   {
     "id": "game-slug",
     "name": "Game Title",
     "originalSystem": "Nintendo 64",
     "recompType": "static_recompilation",
     "touchSupported": true,
     "controllerSupported": true,
     "turnipRecommended": false,
     "githubUrl": "https://github.com/author/repo",
     "dataPath": "Android/data/com.package/files/...",
     "notes": "Verified 60+ FPS on Snapdragon 865."
   }
   ```
3. Submit a Pull Request.

---

<div align="center">

Crafted with ⚡ for the handheld gaming and Android emulation community by [**Mahdi Kareem (@MooPuu)**](https://github.com/MooPuu).

</div>
