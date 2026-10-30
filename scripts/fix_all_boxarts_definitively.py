import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

VERIFIED_COVERS = {
    "diablo-1-devilutionx": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Diablo%20(USA)%20(En%2CFr%2CDe%2CSv).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Diablo%20(USA)%20(En%2CFr%2CDe%2CSv).png"
    },
    "devilutionx": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Diablo%20(USA)%20(En%2CFr%2CDe%2CSv).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Diablo%20(USA)%20(En%2CFr%2CDe%2CSv).png"
    },
    "morrowind-ds-openmw-ds": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/22320/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/22320/library_600x900.jpg"
    },
    "simpsons-hit-and-run": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Simpsons%2C%20The%20-%20Hit%20_%20Run%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Simpsons%2C%20The%20-%20Hit%20_%20Run%20(USA).png"
    },
    "the-simpsons-hit-and-run-android": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Simpsons%2C%20The%20-%20Hit%20_%20Run%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Simpsons%2C%20The%20-%20Hit%20_%20Run%20(USA).png"
    },
    "pokemon-gen-2-recomp": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/master/Named_Boxarts/Pokemon%20-%20Gold%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced)%20(GB%20Compatible).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/master/Named_Boxarts/Pokemon%20-%20Gold%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced)%20(GB%20Compatible).png"
    },
    "gen2recomp": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/master/Named_Boxarts/Pokemon%20-%20Gold%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced)%20(GB%20Compatible).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Color/master/Named_Boxarts/Pokemon%20-%20Gold%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced)%20(GB%20Compatible).png"
    },
    "pokemon-gen-1-recomp": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy/master/Named_Boxarts/Pokemon%20-%20Red%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy/master/Named_Boxarts/Pokemon%20-%20Red%20Version%20(USA%2C%20Europe)%20(SGB%20Enhanced).png"
    },
    "rayman-mini": {
        "cover": "https://apkvision.org/wp-content/uploads/2026/10/rayman_mini_icon.webp",
        "hero": "https://apkvision.org/wp-content/uploads/2026/10/rayman_mini_icon.webp"
    },
    "rayman-origins-recomp": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Wii/master/Named_Boxarts/Rayman%20Origins%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Wii/master/Named_Boxarts/Rayman%20Origins%20(USA).png"
    },
    "sonic-unleashed-recomp": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Sonic%20Unleashed%20(USA)%20(En%2CJa%2CFr%2CDe%2CEs%2CIt).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_2/master/Named_Boxarts/Sonic%20Unleashed%20(USA)%20(En%2CJa%2CFr%2CDe%2CEs%2CIt).png"
    },
    "golden-sun": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Advance/master/Named_Boxarts/Golden%20Sun%20(USA%2C%20Europe).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Game_Boy_Advance/master/Named_Boxarts/Golden%20Sun%20(USA%2C%20Europe).png"
    },
    "virtua-tennis-3": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_Portable/master/Named_Boxarts/Virtua%20Tennis%203%20(USA)%20(En%2CJa%2CFr%2CDe%2CEs%2CIt)%20(v1.02).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_Portable/master/Named_Boxarts/Virtua%20Tennis%203%20(USA)%20(En%2CJa%2CFr%2CDe%2CEs%2CIt)%20(v1.02).png"
    },
    "dantes-inferno-android": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_Portable/master/Named_Boxarts/Dante%27s%20Inferno%20(USA)%20(v1.01).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation_Portable/master/Named_Boxarts/Dante%27s%20Inferno%20(USA)%20(v1.01).png"
    },
    "daytona-usa-3ds-pc-android": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Dreamcast/master/Named_Boxarts/Daytona%20USA%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sega_-_Dreamcast/master/Named_Boxarts/Daytona%20USA%20(USA).png"
    },
    "wipeout": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Wipeout%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Wipeout%20(USA).png"
    },
    "road-rash-native": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Road%20Rash%20(USA).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/Road%20Rash%20(USA).png"
    },
    "doom-3-bfg-edition-classic-core-engines": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/208200/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/208200/library_600x900.jpg"
    },
    "doukutsu-rs": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/200900/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/200900/library_600x900.jpg"
    },
    "rsdkv3-decompilation": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/200940/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/200940/library_600x900.jpg"
    },
    "devil-may-cry-4-port": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/45700/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/45700/library_600x900.jpg"
    },
    "madness-project-nexus-port": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/488860/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/488860/library_600x900.jpg"
    },
    "heretic-classic-core-engines": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/2390/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/2390/library_600x900.jpg"
    },
    "looking-glass": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/19680/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/19680/library_600x900.jpg"
    },
    "botw-android": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Wii_U/master/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Breath%20of%20the%20Wild%20(USA)%20(En%2CFr%2CEs).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Nintendo_-_Wii_U/master/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Breath%20of%20the%20Wild%20(USA)%20(En%2CFr%2CEs).png"
    },
    "warcraft-2-android": {
        "cover": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/WarCraft%20II%20-%20The%20Dark%20Saga%20(USA)%20(En%2CFr%2CDe%2CEs%2CIt).png",
        "hero": "https://raw.githubusercontent.com/libretro-thumbnails/Sony_-_PlayStation/master/Named_Boxarts/WarCraft%20II%20-%20The%20Dark%20Saga%20(USA)%20(En%2CFr%2CDe%2CEs%2CIt).png"
    },
    "pokerogue-app": {
        "cover": "https://avatars.githubusercontent.com/u/164962081?v=4",
        "hero": "https://avatars.githubusercontent.com/u/164962081?v=4"
    }
}

# 1. Update catalog.json
with open('catalog.json', 'r', encoding='utf-8') as f:
    cat = json.load(f)

count = 0
for app in cat['apps']:
    aid = app['id']
    if aid in VERIFIED_COVERS:
        app['cover'] = VERIFIED_COVERS[aid]['cover']
        app['hero'] = VERIFIED_COVERS[aid]['hero']
        count += 1

with open('catalog.json', 'w', encoding='utf-8') as f:
    json.dump(cat, f, indent=2, ensure_ascii=False)

# 2. Update catalog.js
with open('catalog.js', 'w', encoding='utf-8') as f:
    f.write('// DroidRecomp Master Verified Catalog\n')
    f.write('window.DROID_CATALOG = ')
    json.dump(cat, f, indent=2, ensure_ascii=False)
    f.write(';\n')

# 3. Update droid_recomp_app/assets/catalog.json
with open('droid_recomp_app/assets/catalog.json', 'w', encoding='utf-8') as f:
    json.dump(cat, f, indent=2, ensure_ascii=False)

print(f"Successfully updated {count} apps across catalog.json, catalog.js, and droid_recomp_app/assets/catalog.json!")
