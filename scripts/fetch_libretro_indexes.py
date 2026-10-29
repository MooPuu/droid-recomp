import urllib.request
import re
import json
import os

systems = [
    "Microsoft - Xbox 360",
    "Microsoft - Xbox",
    "Sony - PlayStation 2",
    "Sony - PlayStation",
    "Sony - PlayStation Portable",
    "Nintendo - GameCube",
    "Nintendo - Wii",
    "Nintendo - Nintendo 64",
    "Nintendo - Nintendo DS",
    "Nintendo - Game Boy Advance",
    "Nintendo - Game Boy Color",
    "Nintendo - Super Nintendo Entertainment System",
    "Sega - Dreamcast",
    "Sega - Saturn"
]

indexes = {}
headers = {"User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"}

for sys in systems:
    encoded_sys = urllib.parse.quote(sys)
    url = f"https://thumbnails.libretro.com/{encoded_sys}/Named_Boxarts/"
    print(f"Fetching index for {sys}...")
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=15) as resp:
            html = resp.read().decode("utf-8", errors="ignore")
            # find all .png links
            files = re.findall(r'href="([^"]+\.png)"', html)
            # unquote
            unquoted = [urllib.parse.unquote(f) for f in files if not f.startswith("?")]
            indexes[sys] = unquoted
            print(f"  Found {len(unquoted)} boxarts")
    except Exception as e:
        print(f"  Failed for {sys}: {e}")

with open("scripts/libretro_indexes.json", "w", encoding="utf-8") as f:
    json.dump(indexes, f, indent=2)

print("Saved all Libretro indexes to scripts/libretro_indexes.json")
