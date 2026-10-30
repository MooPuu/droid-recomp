import json
import sys

sys.stdout.reconfigure(encoding='utf-8')

# Import canonical verified covers from fix_all_boxarts_definitively
from fix_all_boxarts_definitively import VERIFIED_COVERS as REPLACEMENTS

def apply():
    with open('catalog.json', 'r', encoding='utf-8') as f:
        cat = json.load(f)

    count = 0
    for app in cat['apps']:
        aid = app['id']
        if aid in REPLACEMENTS:
            app['cover'] = REPLACEMENTS[aid]['cover']
            app['hero'] = REPLACEMENTS[aid]['hero']
            count += 1

    with open('catalog.json', 'w', encoding='utf-8') as f:
        json.dump(cat, f, indent=2, ensure_ascii=False)

    with open('catalog.js', 'w', encoding='utf-8') as f:
        f.write('// DroidRecomp Master Verified Catalog\n')
        f.write('window.DROID_CATALOG = ')
        json.dump(cat, f, indent=2, ensure_ascii=False)
        f.write(';\n')

    with open('droid_recomp_app/assets/catalog.json', 'w', encoding='utf-8') as f:
        json.dump(cat, f, indent=2, ensure_ascii=False)

    print(f"Updated {count} apps across catalogs successfully!")

if __name__ == '__main__':
    apply()
