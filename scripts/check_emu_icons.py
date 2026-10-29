import json

with open("emulators.json", "r", encoding="utf-8") as f:
    d = json.load(f)

placeholders = []
for idx, e in enumerate(d["emulators"]):
    icon = e.get("icon", "")
    if "favicon.svg" in icon or not icon.strip():
        placeholders.append((idx + 1, e["id"], e["name"], icon))

print(f"Emulators with placeholder icons: {len(placeholders)}")
for p in placeholders:
    print(f"  #{p[0]} [{p[1]}] {p[2]}: {p[3]}")
