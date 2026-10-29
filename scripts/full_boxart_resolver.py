import json
import urllib.request
import urllib.parse
import re
import time
import concurrent.futures

with open("scripts/libretro_indexes.json", "r", encoding="utf-8") as f:
    libretro_indexes = json.load(f)

with open("catalog.json", "r", encoding="utf-8") as f:
    catalog_data = json.load(f)

apps = catalog_data.get("apps", [])
print(f"Total apps in catalog: {len(apps)}")

headers = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36"
}

ORIGIN_TO_LIBRETRO = {
    "n64": ["Nintendo - Nintendo 64"],
    "gc": ["Nintendo - GameCube"],
    "wii": ["Nintendo - Wii"],
    "ps1": ["Sony - PlayStation"],
    "ps2": ["Sony - PlayStation 2"],
    "psp": ["Sony - PlayStation Portable"],
    "nds": ["Nintendo - Nintendo DS"],
    "gba": ["Nintendo - Game Boy Advance"],
    "gbc": ["Nintendo - Game Boy Color"],
    "snes": ["Nintendo - Super Nintendo Entertainment System"],
    "xbox": ["Microsoft - Xbox"],
    "x360": ["Microsoft - Xbox 360", "Microsoft - Xbox", "Sony - PlayStation 2"],
    "dc": ["Sega - Dreamcast"],
    "saturn": ["Sega - Saturn"],
    "pc_classic": [
        "Sony - PlayStation",
        "Sony - PlayStation 2",
        "Nintendo - Nintendo 64",
        "Nintendo - GameCube",
        "Nintendo - Game Boy Advance",
        "Nintendo - Game Boy Color",
        "Nintendo - Super Nintendo Entertainment System"
    ]
}

def clean_name(s):
    # remove parenthesized terms like (2013 Decompilation), (Android), etc.
    s = re.sub(r'\(.*?\)|\[.*?\]', '', s)
    s = s.replace("&amp;", "and").replace("&", "and")
    s = re.sub(r'[^a-zA-Z0-9\s]', ' ', s)
    return " ".join(s.lower().split())

def verify_url(url):
    if not url:
        return False
    try:
        req = urllib.request.Request(url, headers=headers, method="HEAD")
        with urllib.request.urlopen(req, timeout=6) as resp:
            return resp.status in (200, 206, 301, 302, 304)
    except urllib.error.HTTPError as e:
        if e.code in (403, 405):
            try:
                g_req = urllib.request.Request(url, headers={**headers, "Range": "bytes=0-1024"})
                with urllib.request.urlopen(g_req, timeout=6) as g_resp:
                    return g_resp.status in (200, 206, 301, 302)
            except Exception:
                return False
        return False
    except Exception:
        return False

def search_libretro(game_name, target_systems):
    cname = clean_name(game_name)
    tokens = [t for t in cname.split() if len(t) > 1 and t not in ("recomp", "recompiled", "port", "android", "remake", "the", "and")]
    if not tokens:
        return None

    for sys_name in target_systems:
        files = libretro_indexes.get(sys_name, [])
        best_file = None
        best_score = 0
        for f in files:
            f_clean = clean_name(f)
            f_tokens = set(f_clean.split())
            matched = sum(1 for t in tokens if t in f_tokens)
            score = matched
            if score > best_score:
                if "(usa" in f.lower():
                    best_score = score + 0.5
                    best_file = f
                else:
                    best_score = score
                    best_file = f

        # If matched most significant tokens
        required = max(1, int(len(tokens) * 0.6))
        if best_score >= required and best_file:
            encoded_sys = urllib.parse.quote(sys_name)
            encoded_file = urllib.parse.quote(best_file)
            candidate = f"https://thumbnails.libretro.com/{encoded_sys}/Named_Boxarts/{encoded_file}"
            if verify_url(candidate):
                return candidate
    return None

def search_steam(game_name):
    cname = clean_name(game_name)
    # clean out words that hinder search
    clean_search = re.sub(r'\b(recomp|recompiled|android|edition|port|remastered|classic|hd)\b', '', cname, flags=re.I).strip()
    url = f"https://store.steampowered.com/api/storesearch/?term={urllib.parse.quote(clean_search)}&l=english&cc=US"
    try:
        req = urllib.request.Request(url, headers=headers)
        with urllib.request.urlopen(req, timeout=5) as resp:
            data = json.load(resp)
            if data.get("items"):
                for it in data["items"][:3]:
                    app_id = it["id"]
                    cover_url = f"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900_2x.jpg"
                    if verify_url(cover_url):
                        header_url = f"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{app_id}/header.jpg"
                        return (cover_url, header_url)
                    # Try regular library_600x900.jpg
                    cover_url_1x = f"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{app_id}/library_600x900.jpg"
                    if verify_url(cover_url_1x):
                        header_url = f"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{app_id}/header.jpg"
                        return (cover_url_1x, header_url)
                    header_url = f"https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/{app_id}/header.jpg"
                    if verify_url(header_url):
                        return (header_url, header_url)
    except Exception:
        pass
    return None

# Known direct high-res verified URLs for unique fan projects, indie games & Xbox 360 exclusives
MANUAL_BOXARTS = {
    "forza-horizon": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Forza%20Horizon%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Forza%20Horizon%20%28USA%29.png"
    },
    "forza-horizon-2": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Forza%20Horizon%202%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Forza%20Horizon%202%20%28USA%29.png"
    },
    "blue-dragon": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Blue%20Dragon%20%28USA%29%20%28Disc%201%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Blue%20Dragon%20%28USA%29%20%28Disc%201%29.png"
    },
    "lost-odyssey": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Lost%20Odyssey%20%28USA%29%20%28Disc%201%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Lost%20Odyssey%20%28USA%29%20%28Disc%201%29.png"
    },
    "gears-of-war-2": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Gears%20of%20War%202%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Gears%20of%20War%202%20%28USA%29.png"
    },
    "skate-3": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Skate%203%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox%20360/Named_Boxarts/Skate%203%20%28USA%29.png"
    },
    "wwe-smackdown-vs-raw-2011": {
        "cover": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/WWE%20SmackDown%20vs.%20Raw%202011%20%28USA%29%20%28En%2CFr%2CEs%29.png",
        "hero": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/WWE%20SmackDown%20vs.%20Raw%202011%20%28USA%29%20%28En%2CFr%2CEs%29.png"
    },
    "buckshot-roulette-mobile": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2835570/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2835570/header.jpg"
    },
    "balatro": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2379780/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2379780/header.jpg"
    },
    "ufo50-android": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1147860/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/1147860/header.jpg"
    },
    "sonic-dream-team": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2523270/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/2523270/header.jpg"
    },
    "the-legend-of-zelda-echoes-of-wisdom": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Switch/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Echoes%20of%20Wisdom%20%28World%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Switch/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Echoes%20of%20Wisdom%20%28World%29.png"
    },
    "another-metroid-2-remake-am2r": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Metroid%20II%20-%20Return%20of%20Samus%20%28World%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Metroid%20II%20-%20Return%20of%20Samus%20%28World%29.png"
    },
    "pokemon-gen-1-recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Pokemon%20-%20Red%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Pokemon%20-%20Red%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png"
    },
    "pokemon-gen-2-recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png"
    },
    "gen1recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Pokemon%20-%20Red%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy/Named_Boxarts/Pokemon%20-%20Red%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png"
    },
    "gen2recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29.png"
    },
    "pokemon-reloaded-en-android": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Pokemon%20-%20Emerald%20Version%20%28USA%2C%20Europe%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Pokemon%20-%20Emerald%20Version%20%28USA%2C%20Europe%29.png"
    },
    "pokemon-survivor-burst-android": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Pokemon%20-%20FireRed%20Version%20%28USA%2C%20Europe%29%20%28Rev%201%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Pokemon%20-%20FireRed%20Version%20%28USA%2C%20Europe%29%20%28Rev%201%29.png"
    },
    "showdown-ds-dual-screen": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20DS/Named_Boxarts/Pokemon%20-%20Platinum%20Version%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20DS/Named_Boxarts/Pokemon%20-%20Platinum%20Version%20%28USA%29.png"
    },
    "super-mario-bros-wonder-recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Switch/Named_Boxarts/Super%20Mario%20Bros.%20Wonder%20%28World%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Switch/Named_Boxarts/Super%20Mario%20Bros.%20Wonder%20%28World%29.png"
    },
    "botw-android": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Wii%20U/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Breath%20of%20the%20Wild%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Wii%20U/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Breath%20of%20the%20Wild%20%28USA%29.png"
    },
    "srb2-android": {
        "cover": "https://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Boxarts/Sonic%20The%20Hedgehog%20%28USA%2C%20Europe%29.png",
        "hero": "https://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Boxarts/Sonic%20The%20Hedgehog%20%28USA%2C%20Europe%29.png"
    },
    "ring-racers-android": {
        "cover": "https://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Boxarts/Sonic%20The%20Hedgehog%202%20%28World%29.png",
        "hero": "https://thumbnails.libretro.com/Sega%20-%20Mega%20Drive%20-%20Genesis/Named_Boxarts/Sonic%20The%20Hedgehog%202%20%28World%29.png"
    },
    "gta-4-mobile": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/header.jpg"
    },
    "gta-iv-liberty-recomp": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/header.jpg"
    },
    "grand-theft-auto-iv-liberty-recompiled": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/12210/header.jpg"
    },
    "cs16-client": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/10/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/10/header.jpg"
    },
    "tf15-client": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/20/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/20/header.jpg"
    },
    "space-cadet-pinball-android": {
        "cover": "https://raw.githubusercontent.com/k4zmu2a/SpaceCadetPinball/master/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png",
        "hero": "https://raw.githubusercontent.com/k4zmu2a/SpaceCadetPinball/master/android/app/src/main/res/mipmap-xxxhdpi/ic_launcher.png"
    }
}

print("Resolving boxarts for all games...")
resolved_count = 0
already_ok_count = 0
failed_games = []

for idx, app in enumerate(apps):
    app_id = app.get("id")
    name = app.get("name")
    curr_cover = app.get("cover")
    origin = app.get("origin", "pc_classic")

    # If it's in manual overrides, use that
    if app_id in MANUAL_BOXARTS:
        app["cover"] = MANUAL_BOXARTS[app_id]["cover"]
        app["hero"] = MANUAL_BOXARTS[app_id]["hero"]
        resolved_count += 1
        continue

    # If current cover is already working and NOT from wikimedia, keep it
    if curr_cover and "wikimedia.org" not in curr_cover and verify_url(curr_cover):
        already_ok_count += 1
        continue

    # Otherwise, we need to resolve it!
    found = False

    # 1. Try Steam first for PC and modern games
    steam_res = search_steam(name)
    if steam_res:
        app["cover"] = steam_res[0]
        app["hero"] = steam_res[1]
        resolved_count += 1
        found = True
        print(f"[{idx+1}/{len(apps)}] STEAM: {name} -> {steam_res[0][:60]}")
        continue

    # 2. Try Libretro matching
    systems = ORIGIN_TO_LIBRETRO.get(origin, ["Sony - PlayStation 2", "Microsoft - Xbox", "Nintendo - Nintendo 64"])
    libretro_res = search_libretro(name, systems)
    if libretro_res:
        app["cover"] = libretro_res
        app["hero"] = libretro_res
        resolved_count += 1
        found = True
        print(f"[{idx+1}/{len(apps)}] LIBRETRO: {name} -> {libretro_res[:60]}")
        continue

    # 3. If still not found, try searching Libretro across all consoles
    all_systems = list(libretro_indexes.keys())
    broad_libretro = search_libretro(name, all_systems)
    if broad_libretro:
        app["cover"] = broad_libretro
        app["hero"] = broad_libretro
        resolved_count += 1
        found = True
        print(f"[{idx+1}/{len(apps)}] BROAD LIBRETRO: {name} -> {broad_libretro[:60]}")
        continue

    failed_games.append((idx + 1, app_id, name, origin))
    print(f"[{idx+1}/{len(apps)}] FAILED TO RESOLVE: {name} ({origin})")

print(f"\nResolution summary:")
print(f"Already OK: {already_ok_count}")
print(f"Newly Resolved: {resolved_count}")
print(f"Failed to resolve: {len(failed_games)}")

# Save updated catalog
with open("catalog.json", "w", encoding="utf-8") as f:
    json.dump(catalog_data, f, indent=2, ensure_ascii=False)

with open("catalog.js", "w", encoding="utf-8") as f:
    f.write("window.DROIDRECOMP_CATALOG = " + json.dumps(catalog_data, indent=2, ensure_ascii=False) + ";\n")

with open("droid_recomp_app/assets/catalog.json", "w", encoding="utf-8") as f:
    json.dump(catalog_data, f, indent=2, ensure_ascii=False)

with open("scripts/unresolved_games.json", "w", encoding="utf-8") as f:
    json.dump([{"idx": g[0], "id": g[1], "name": g[2], "origin": g[3]} for g in failed_games], f, indent=2)

print("Saved catalog.json, catalog.js, and droid_recomp_app/assets/catalog.json!")
