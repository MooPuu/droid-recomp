import urllib.request
import re

package_ids = {
    "drastic-ds": "com.dsemu.drastic",
    "my-boy-gba": "com.fastemulator.gba",
    "my-oldboy-gbc": "com.fastemulator.gbc",
    "epsxe": "com.epsxe.ePSXe",
    "fpse": "com.emulator.fpse",
    "magic-dosbox": "bruenor.magicbox",
    "mame4droid": "com.seleuco.mame4droid",
    "beacon-launcher": "com.radikal.gamelauncher",
    "damon-ps2-pro": "com.damonplay.damonps2.pro"
}

headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"}

results = {}
for name, pkg in package_ids.items():
    url = f"https://play.google.com/store/apps/details?id={pkg}"
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=8) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
            # find og:image or play-lh image
            m = re.search(r'property="og:image"\s+content="([^"]+)"', html)
            if not m:
                m = re.search(r'content="([^"]+)"\s+property="og:image"', html)
            if m:
                results[name] = m.group(1)
                print(f"[FOUND] {name}: {m.group(1)}")
            else:
                print(f"[NOT FOUND] {name}")
    except Exception as e:
        print(f"[ERROR] {name}: {e}")

print(results)
