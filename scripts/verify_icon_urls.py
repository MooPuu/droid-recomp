import urllib.request

test_urls = {
    "aethersx2": "https://raw.githubusercontent.com/Jaffacakelover/emulator-icons-svg/master/AetherSX2%20-%20icon.svg",
    "ppsspp-gold": "https://raw.githubusercontent.com/Jaffacakelover/emulator-icons-svg/master/PPSSPP%20Gold.svg",
    "my-boy-gba": "https://play-lh.googleusercontent.com/GmMy8HhuZPLeCep5Op5SOo7hn2S_n9520IZU0G6YStm4qIzzn7AlX1BD9S2jyQ8AOlOWX5hEuHHAM-VGaa8CrTo=s0-br30",
    "my-oldboy-gbc": "https://play-lh.googleusercontent.com/8MXDIivg1geazXua1Mds-9KxWv-LgVdYa5AChZpkr7MFMCZ9cOXm8Vopirmc_IXoXZI6UNBZj1cT9sXv5IlCi_k=s0-br30",
    "epsxe": "https://play-lh.googleusercontent.com/CkS6tKITvyy5WK8uAgALTDba-Czq7peFP-MG3iHNLkLaTdN5-To2JRRkqynKUIuGiu2giiMgOAEMzMuOiBjQ=s0-br30",
    "fpse": "https://play-lh.googleusercontent.com/H-XvVzN0BsfRXmxRZG2gkiEauZ_ofPqC-EzRoKQWV8sDng71NSQmmRyhbvCGw-VL53i8sY9bHY17kmC8slk4Y_4=s0-br30",
    "magic-dosbox": "https://play-lh.googleusercontent.com/pCh9A29wFlsEBtxLQ7f_Bor5eqc4-VFHrIzeKUZV_po_fghvBs3rWtdTW7OMC_ZL8RT0qBkSReaqIbXHEsl5=s0-br30",
    "mame4droid": "https://play-lh.googleusercontent.com/uCsgZ6hjdKMhzM3LlfaRO3z4TqN4h10fxX94F25XyFxjTC6JIAA8Xfq6eTVuDzBo-42dRIb_fsRtXw-C_RkOAQ=s0-br30",
    "beacon-launcher": "https://play-lh.googleusercontent.com/9k3xoQaMinZqR19EHHU5ZkrfikV9NQWvg8U8tWpiFFKbobUE_JkVc24frgqCfsbVaebJGjKwU0l3UfnmJBJdyfk=s0-br30",
    "pizza-boy-gba": "https://github.com/davide-beraldo.png",
    "kirikiroid2": "https://github.com/zeas2.png",
    "yuzu-android": "https://raw.githubusercontent.com/Jaffacakelover/emulator-icons-svg/master/Yuzu.svg",
    "snes9x-ex-plus": "https://raw.githubusercontent.com/Rakashazi/emu-ex-plus-alpha/master/pkg/android/res/mipmap-xxxhdpi/ic_launcher.png"
}

headers = {"User-Agent": "Mozilla/5.0"}

for k, url in test_urls.items():
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=8) as resp:
            print(f"[OK 200] {k} -> {len(resp.read())} bytes")
    except Exception as e:
        print(f"[FAIL] {k}: {e}")
