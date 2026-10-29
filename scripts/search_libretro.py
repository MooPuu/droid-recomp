import urllib.request
import re

url = "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/"
req = urllib.request.Request(url, headers={"User-Agent": "Mozilla/5.0"})
try:
    with urllib.request.urlopen(req, timeout=10) as resp:
        html = resp.read().decode("utf-8", errors="ignore")
        matches = [m for m in re.findall(r'href="([^"]+)"', html) if "smackdown" in m.lower()]
        print("Matches in Libretro PS2:")
        for m in matches:
            print(" ", m)
except Exception as e:
    print("Error:", e)
