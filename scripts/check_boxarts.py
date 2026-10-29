import json
import urllib.request
import urllib.error
import concurrent.futures
import time

with open("catalog.json", "r", encoding="utf-8") as f:
    data = json.load(f)

apps = data.get("apps", [])
print(f"Total apps in catalog: {len(apps)}")

missing_or_none = []
for idx, g in enumerate(apps):
    b = g.get("boxart")
    if not b or b == "None" or not str(b).strip():
        missing_or_none.append((idx + 1, g.get("id"), g.get("name")))

print(f"Apps with None or empty boxart: {len(missing_or_none)}")
for m in missing_or_none:
    print(f"#{m[0]} [{m[1]}]: {m[2]}")
