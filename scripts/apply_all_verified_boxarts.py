import json

REPLACEMENTS = {
    "diablo-1-devilutionx": {
        "cover": "https://images.launchbox-app.com//01cc2e7f-36e9-4cba-a564-03b1c04770d2.jpg",
        "hero": "https://images.launchbox-app.com//01cc2e7f-36e9-4cba-a564-03b1c04770d2.jpg"
    },
    "devilutionx": {
        "cover": "https://images.launchbox-app.com//01cc2e7f-36e9-4cba-a564-03b1c04770d2.jpg",
        "hero": "https://images.launchbox-app.com//01cc2e7f-36e9-4cba-a564-03b1c04770d2.jpg"
    },
    "morrowind-ds-openmw-ds": {
        "cover": "https://images.launchbox-app.com//ba642fcf-9647-42c5-811e-3fcd4597fbe9.jpg",
        "hero": "https://images.launchbox-app.com//ba642fcf-9647-42c5-811e-3fcd4597fbe9.jpg"
    },
    "simpsons-hit-and-run": {
        "cover": "https://images.launchbox-app.com//fb6c7676-31e5-44c6-932d-4c93a3e140c9.jpg",
        "hero": "https://images.launchbox-app.com//fb6c7676-31e5-44c6-932d-4c93a3e140c9.jpg"
    },
    "god-of-war-iii-remastered": {
        "cover": "https://images.launchbox-app.com//7ffddf98-a398-4bf1-98fc-bad1d833c70d.png",
        "hero": "https://images.launchbox-app.com//7ffddf98-a398-4bf1-98fc-bad1d833c70d.png"
    },
    "sonic-unleashed-recomp": {
        "cover": "https://images.launchbox-app.com//035ab994-abe7-4487-860a-48d34ee48ebf.png",
        "hero": "https://images.launchbox-app.com//035ab994-abe7-4487-860a-48d34ee48ebf.png"
    },
    "sonic-3-amp-knuckles": {
        "cover": "https://images.launchbox-app.com//e5f676ff-711c-4cff-8542-3f2e960eb095.png",
        "hero": "https://images.launchbox-app.com//e5f676ff-711c-4cff-8542-3f2e960eb095.png"
    },
    "sonic-1-amp-sonic-2-2013-decompilation": {
        "cover": "https://images.launchbox-app.com//a2296bc8-5745-4cd0-bd59-5f97a8e7eeb6.png",
        "hero": "https://images.launchbox-app.com//a2296bc8-5745-4cd0-bd59-5f97a8e7eeb6.png"
    },
    "sonic-r": {
        "cover": "https://images.launchbox-app.com//d7bb25ed-f9cd-43e1-95f2-e0e93c651069.png",
        "hero": "https://images.launchbox-app.com//d7bb25ed-f9cd-43e1-95f2-e0e93c651069.png"
    },
    "sonic-robo-blast-2-amp-srb2kart": {
        "cover": "https://images.launchbox-app.com//a74a770b-0763-453b-a30f-73546e095f26.jpg",
        "hero": "https://images.launchbox-app.com//a74a770b-0763-453b-a30f-73546e095f26.jpg"
    },
    "srb2-android": {
        "cover": "https://images.launchbox-app.com//a74a770b-0763-453b-a30f-73546e095f26.jpg",
        "hero": "https://images.launchbox-app.com//a74a770b-0763-453b-a30f-73546e095f26.jpg"
    },
    "wipeout": {
        "cover": "https://images.launchbox-app.com//c8026f8f-c080-47ed-a8d7-b248a8a19231.jpg",
        "hero": "https://images.launchbox-app.com//c8026f8f-c080-47ed-a8d7-b248a8a19231.jpg"
    },
    "pok-mon-let-39-s-go-eevee": {
        "cover": "https://images.launchbox-app.com//a9e597ac-d081-4ab5-a66c-1e12c9a3bd02.jpg",
        "hero": "https://images.launchbox-app.com//a9e597ac-d081-4ab5-a66c-1e12c9a3bd02.jpg"
    },
    "virtua-tennis-3": {
        "cover": "https://images.launchbox-app.com//19b99366-d8b7-47da-8727-7ecd53e1ef46.jpg",
        "hero": "https://images.launchbox-app.com//19b99366-d8b7-47da-8727-7ecd53e1ef46.jpg"
    },
    "hacx-classic-core-engines": {
        "cover": "https://images.launchbox-app.com//1a0d1cb4-0947-4249-8954-90e34db51e1c.png",
        "hero": "https://images.launchbox-app.com//1a0d1cb4-0947-4249-8954-90e34db51e1c.png"
    },
    "mkvdcu-android": {
        "cover": "https://images.launchbox-app.com//85eabb35-df87-46aa-abd5-e5c4fa4f0a1d.jpg",
        "hero": "https://images.launchbox-app.com//85eabb35-df87-46aa-abd5-e5c4fa4f0a1d.jpg"
    },
    "touhou-6-android": {
        "cover": "https://images.launchbox-app.com//1d256a98-15af-4195-8d4a-6f56c8a9278d.jpg",
        "hero": "https://images.launchbox-app.com//1d256a98-15af-4195-8d4a-6f56c8a9278d.jpg"
    },
    "open-enroth": {
        "cover": "https://images.launchbox-app.com//381cc0e5-78c0-4175-a091-a5740473eb4e.jpg",
        "hero": "https://images.launchbox-app.com//381cc0e5-78c0-4175-a091-a5740473eb4e.jpg"
    },
    "doukutsu-rs": {
        "cover": "https://images.launchbox-app.com//1bb2f334-4422-484a-8684-7cbe0e19ea9a.jpg",
        "hero": "https://images.launchbox-app.com//1bb2f334-4422-484a-8684-7cbe0e19ea9a.jpg"
    },
    "freedom-planet-2-port": {
        "cover": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/595500/library_600x900_2x.jpg",
        "hero": "https://shared.fastly.steamstatic.com/store_item_assets/steam/apps/595500/header.jpg"
    },
    "dragon-ball-raging-blast-2": {
        "cover": "https://images.launchbox-app.com//ce27cf1e-aaa3-4f20-814d-5918a42faf3a.jpg",
        "hero": "https://images.launchbox-app.com//ce27cf1e-aaa3-4f20-814d-5918a42faf3a.jpg"
    },
    "midnight-club-los-angeles": {
        "cover": "https://images.launchbox-app.com//3dfb7dc7-5738-4d9c-ba51-368104cab6b3.png",
        "hero": "https://images.launchbox-app.com//3dfb7dc7-5738-4d9c-ba51-368104cab6b3.png"
    },
    "dantes-inferno-android": {
        "cover": "https://images.launchbox-app.com//133d6a99-4700-4073-be72-834ba1c81f6c.jpg",
        "hero": "https://images.launchbox-app.com//133d6a99-4700-4073-be72-834ba1c81f6c.jpg"
    },
    "dbz-burst-limit-android": {
        "cover": "https://images.launchbox-app.com//b491e6ed-ba90-4106-a07f-3e9ff3325424.png",
        "hero": "https://images.launchbox-app.com//b491e6ed-ba90-4106-a07f-3e9ff3325424.png"
    },
    "dishsoap": {
        "cover": "https://images.launchbox-app.com//1454c216-3896-492d-988b-fa4de3653963.jpg",
        "hero": "https://images.launchbox-app.com//1454c216-3896-492d-988b-fa4de3653963.jpg"
    },
    "chavo-kart-android": {
        "cover": "https://images.launchbox-app.com//2c746401-bc0e-4d88-97b3-352eb283b73d.png",
        "hero": "https://images.launchbox-app.com//2c746401-bc0e-4d88-97b3-352eb283b73d.png"
    },
    "eternal-sonata-reprise": {
        "cover": "https://images.launchbox-app.com//da34a840-79da-48ee-b601-9a038ad93f46.png",
        "hero": "https://images.launchbox-app.com//da34a840-79da-48ee-b601-9a038ad93f46.png"
    },
    "infinite-blade-2-android": {
        "cover": "https://images.launchbox-app.com//a13bbcf6-5c0d-4c00-adae-8821cc7992db.png",
        "hero": "https://images.launchbox-app.com//a13bbcf6-5c0d-4c00-adae-8821cc7992db.png"
    },
    "isle-portable": {
        "cover": "https://images.launchbox-app.com//e9e6e188-28b4-4f19-b54d-62c3d0b32534.png",
        "hero": "https://images.launchbox-app.com//e9e6e188-28b4-4f19-b54d-62c3d0b32534.png"
    },
    "knytt-stories-android": {
        "cover": "https://images.launchbox-app.com//74fd4f04-21d7-44ea-bcec-561b1758087e.jpg",
        "hero": "https://images.launchbox-app.com//74fd4f04-21d7-44ea-bcec-561b1758087e.jpg"
    },
    "looking-glass": {
        "cover": "https://images.launchbox-app.com//8a48f99d-a4a8-4904-a818-bee713e07a56.jpg",
        "hero": "https://images.launchbox-app.com//8a48f99d-a4a8-4904-a818-bee713e07a56.jpg"
    },
    "mbhaxe": {
        "cover": "https://images.launchbox-app.com//568cc2b7-1f44-464a-96da-d3810d6a459c.jpg",
        "hero": "https://images.launchbox-app.com//568cc2b7-1f44-464a-96da-d3810d6a459c.jpg"
    },
    "micropolis-android": {
        "cover": "https://images.launchbox-app.com//084c3f94-a14a-4c90-aff5-5b265883af47.jpg",
        "hero": "https://images.launchbox-app.com//084c3f94-a14a-4c90-aff5-5b265883af47.jpg"
    },
    "jessicanataliagta-androidrecomp": {
        "cover": "https://images.launchbox-app.com//733c770f-7733-440e-b7b1-efedcbe0ed6d.jpg",
        "hero": "https://images.launchbox-app.com//733c770f-7733-440e-b7b1-efedcbe0ed6d.jpg"
    },
    "naruto-rise-of-a-ninja-recomp": {
        "cover": "https://images.launchbox-app.com//269e47bf-b466-460d-abf6-3d816e754501.png",
        "hero": "https://images.launchbox-app.com//269e47bf-b466-460d-abf6-3d816e754501.png"
    },
    "naruto-the-broken-bond-recomp": {
        "cover": "https://images.launchbox-app.com//7cfc268d-0cd2-46d4-be39-8018e3f92b57.jpg",
        "hero": "https://images.launchbox-app.com//7cfc268d-0cd2-46d4-be39-8018e3f92b57.jpg"
    },
    "naughty-bear-restuff-android-port": {
        "cover": "https://images.launchbox-app.com//bb9d6c6d-e7a8-4460-99ff-b3fea90f4fc4.png",
        "hero": "https://images.launchbox-app.com//bb9d6c6d-e7a8-4460-99ff-b3fea90f4fc4.png"
    },
    "open-wheels": {
        "cover": "https://images.launchbox-app.com//58ad823e-4876-45b6-a958-9c14ccaa1103.png",
        "hero": "https://images.launchbox-app.com//58ad823e-4876-45b6-a958-9c14ccaa1103.png"
    },
    "openarena-classic-core-engines": {
        "cover": "https://images.launchbox-app.com//6e140745-37d5-42e7-a965-67dd11aa1ab2.jpg",
        "hero": "https://images.launchbox-app.com//6e140745-37d5-42e7-a965-67dd11aa1ab2.jpg"
    },
    "renut-android": {
        "cover": "https://images.launchbox-app.com//8818404b-9b2f-497f-aadf-b6a50d7e2b48.jpg",
        "hero": "https://images.launchbox-app.com//8818404b-9b2f-497f-aadf-b6a50d7e2b48.jpg"
    },
    "road-rash-native": {
        "cover": "https://images.launchbox-app.com//280b0576-3262-46bc-b23c-613addb2f572.png",
        "hero": "https://images.launchbox-app.com//280b0576-3262-46bc-b23c-613addb2f572.png"
    },
    "rsdkv3-decompilation": {
        "cover": "https://images.launchbox-app.com//f2d39ea2-1681-44ad-b06c-d33dae1df7b9.jpg",
        "hero": "https://images.launchbox-app.com//f2d39ea2-1681-44ad-b06c-d33dae1df7b9.jpg"
    },
    "warcraft-orcs-and-humans-android": {
        "cover": "https://images.launchbox-app.com//0ea9a652-3ee8-4ad5-91e0-46ab7c0cb3ec.png",
        "hero": "https://images.launchbox-app.com//0ea9a652-3ee8-4ad5-91e0-46ab7c0cb3ec.png"
    },
    "tyrian-2000-android": {
        "cover": "https://images.launchbox-app.com//4b161739-cccd-4a61-9424-a756231cd8f4.png",
        "hero": "https://images.launchbox-app.com//4b161739-cccd-4a61-9424-a756231cd8f4.png"
    },
    "ultima-5-android": {
        "cover": "https://images.launchbox-app.com//4e340396-3f08-4de6-b0d6-cbdadcb72dea.png",
        "hero": "https://images.launchbox-app.com//4e340396-3f08-4de6-b0d6-cbdadcb72dea.png"
    },
    "white-album-2-android": {
        "cover": "https://images.launchbox-app.com//b7043d82-f92b-436c-b536-75bf74140687.jpg",
        "hero": "https://images.launchbox-app.com//b7043d82-f92b-436c-b536-75bf74140687.jpg"
    },
    "rayman-mini": {
        "cover": "https://images.launchbox-app.com//97d2b59e-005f-4c4c-93c2-89055e2d94cf.jpg",
        "hero": "https://images.launchbox-app.com//97d2b59e-005f-4c4c-93c2-89055e2d94cf.jpg"
    },
    "final-fantasy-tactics-advance": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Final%20Fantasy%20Tactics%20Advance%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Final%20Fantasy%20Tactics%20Advance%20%28USA%29.png",
        "origin": "gba"
    },
    "fire-emblem-the-sacred-stones": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Fire%20Emblem%20-%20The%20Sacred%20Stones%20%28USA%2C%20Australia%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Advance/Named_Boxarts/Fire%20Emblem%20-%20The%20Sacred%20Stones%20%28USA%2C%20Australia%29.png",
        "origin": "gba"
    },
    "tetris-attack": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/Named_Boxarts/Tetris%20Attack%20%28USA%29%20%28En%2CJa%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Super%20Nintendo%20Entertainment%20System/Named_Boxarts/Tetris%20Attack%20%28USA%29%20%28En%2CJa%29.png",
        "origin": "snes"
    },
    "the-legend-of-zelda-ocarina-of-time-3d": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%2064/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Ocarina%20of%20Time%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%2064/Named_Boxarts/Legend%20of%20Zelda%2C%20The%20-%20Ocarina%20of%20Time%20%28USA%29.png",
        "origin": "n64"
    },
    "rampage-total-destruction": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20GameCube/Named_Boxarts/Rampage%20-%20Total%20Destruction%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20GameCube/Named_Boxarts/Rampage%20-%20Total%20Destruction%20%28USA%29.png",
        "origin": "gc"
    },
    "dead-or-alive-xtreme-beach-volleyball-android": {
        "cover": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox/Named_Boxarts/Dead%20or%20Alive%20Xtreme%20Beach%20Volleyball%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Microsoft%20-%20Xbox/Named_Boxarts/Dead%20or%20Alive%20Xtreme%20Beach%20Volleyball%20%28USA%29.png",
        "origin": "xbox"
    },
    "gen2recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29%20%28GB%20Compatible%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Pokemon%20-%20Gold%20Version%20%28USA%2C%20Europe%29%20%28SGB%20Enhanced%29%20%28GB%20Compatible%29.png",
        "origin": "gbc"
    },
    "hunters-recomp-dual-screen": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20DS/Named_Boxarts/Metroid%20Prime%20-%20Hunters%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20DS/Named_Boxarts/Metroid%20Prime%20-%20Hunters%20%28USA%29.png",
        "origin": "nds"
    },
    "wario-land-3-recomp": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Wario%20Land%203%20%28World%29%20%28En%2CJa%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Game%20Boy%20Color/Named_Boxarts/Wario%20Land%203%20%28World%29%20%28En%2CJa%29.png",
        "origin": "gbc"
    },
    "dora64-3": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%2064/Named_Boxarts/Doraemon%203%20-%20Nobita%20no%20Machi%20SOS%21%20%28Japan%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%2064/Named_Boxarts/Doraemon%203%20-%20Nobita%20no%20Machi%20SOS%21%20%28Japan%29.png",
        "origin": "n64"
    },
    "woodyre": {
        "cover": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/Woody%20Woodpecker%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/Woody%20Woodpecker%20%28USA%29.png",
        "origin": "ps2"
    },
    "sega-rally-port0r": {
        "cover": "https://thumbnails.libretro.com/Sega%20-%20Saturn/Named_Boxarts/Sega%20Rally%20Championship%20%28Europe%29.png",
        "hero": "https://thumbnails.libretro.com/Sega%20-%20Saturn/Named_Boxarts/Sega%20Rally%20Championship%20%28Europe%29.png",
        "origin": "pc_classic"
    },
    "unreal-tournament-android": {
        "cover": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/Unreal%20Tournament%20%28USA%29.png",
        "hero": "https://thumbnails.libretro.com/Sony%20-%20PlayStation%202/Named_Boxarts/Unreal%20Tournament%20%28USA%29.png",
        "origin": "pc_classic"
    },
    "warcraft-2-android": {
        "cover": "https://thumbnails.libretro.com/Sony%20-%20PlayStation/Named_Boxarts/WarCraft%20II%20-%20The%20Dark%20Saga%20%28USA%29%20%28En%2CFr%2CDe%2CEs%2CIt%29.png",
        "hero": "https://thumbnails.libretro.com/Sony%20-%20PlayStation/Named_Boxarts/WarCraft%20II%20-%20The%20Dark%20Saga%20%28USA%29%20%28En%2CFr%2CDe%2CEs%2CIt%29.png",
        "origin": "pc_classic"
    },
    "super-mario-bros-remastered-android": {
        "cover": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Entertainment%20System/Named_Boxarts/Super%20Mario%20Bros.%20%28World%29.png",
        "hero": "https://thumbnails.libretro.com/Nintendo%20-%20Nintendo%20Entertainment%20System/Named_Boxarts/Super%20Mario%20Bros.%20%28World%29.png",
        "origin": "snes"
    },
    "brogue-android": {
        "cover": "https://images.launchbox-app.com//924d44d0-e2cd-466c-8c7e-1cbac1f74eb0.png",
        "hero": "https://images.launchbox-app.com//924d44d0-e2cd-466c-8c7e-1cbac1f74eb0.png"
    },
    "unnethack-android": {
        "cover": "https://images.launchbox-app.com//40ca9e60-bc33-4171-8729-3d95eff0dd9d.png",
        "hero": "https://images.launchbox-app.com//40ca9e60-bc33-4171-8729-3d95eff0dd9d.png"
    },
    "therapy-with-dr-albert-krueger-android": {
        "cover": "https://images.launchbox-app.com//6d6317a4-25eb-473c-91af-ccd541a3483e.png",
        "hero": "https://images.launchbox-app.com//6d6317a4-25eb-473c-91af-ccd541a3483e.png"
    },
    "xash3d-fwgs": {
        "cover": "https://cdn.cloudflare.steamstatic.com/steam/apps/70/library_600x900.jpg",
        "hero": "https://cdn.cloudflare.steamstatic.com/steam/apps/70/header.jpg"
    },
    "stellargames-bakagain": {
        "cover": "https://images.launchbox-app.com//58891481-d796-4d23-ad25-0536765100d3.png",
        "hero": "https://images.launchbox-app.com//58891481-d796-4d23-ad25-0536765100d3.png"
    },
    "pokemon-reloaded-en-android": {
        "cover": "https://images.launchbox-app.com//b125445c-c303-489a-9411-803f0c83e4bf.png",
        "hero": "https://images.launchbox-app.com//b125445c-c303-489a-9411-803f0c83e4bf.png"
    },
    "pokerogue-app": {
        "cover": "https://images.launchbox-app.com//77dbdf0d-6e28-44f1-9de7-2ef8301c8082.png",
        "hero": "https://images.launchbox-app.com//77dbdf0d-6e28-44f1-9de7-2ef8301c8082.png"
    },
    "elfen-lied-fighting-android": {
        "cover": "https://images.launchbox-app.com//920d440c-8059-4ab3-ae0b-4986752b5759.jpg",
        "hero": "https://images.launchbox-app.com//920d440c-8059-4ab3-ae0b-4986752b5759.jpg"
    }
}

# 1. Update catalog.json
with open('catalog.json', 'r', encoding='utf-8') as f:
    cat = json.load(f)

updated_count = 0
for app in cat['apps']:
    aid = app.get('id')
    if aid in REPLACEMENTS:
        r = REPLACEMENTS[aid]
        app['cover'] = r['cover']
        app['hero'] = r['hero']
        if 'origin' in r:
            app['origin'] = r['origin']
        updated_count += 1

print(f"Updated {updated_count} apps in catalog.json")

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

print("Synchronized catalog.json, catalog.js, and droid_recomp_app/assets/catalog.json successfully!")
