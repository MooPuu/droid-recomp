import json
import urllib.request
import concurrent.futures

with open('catalog.json', 'r', encoding='utf-8') as f:
    cat = json.load(f)

apps = cat['apps']
print(f"Total apps: {len(apps)}")

# Check domains
domains = {}
for a in apps:
    c = a.get('cover', '')
    d = c.split('/')[2] if '://' in c else 'unknown'
    domains[d] = domains.get(d, 0) + 1
print("Cover domains breakdown:", domains)

# Collect all cover URLs
headers = {'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'}
def check_url(item):
    aid, name, url = item
    try:
        req = urllib.request.Request(url, headers=headers, method='HEAD')
        with urllib.request.urlopen(req, timeout=5) as r:
            return (aid, name, url, r.status)
    except:
        try:
            req = urllib.request.Request(url, headers=headers)
            with urllib.request.urlopen(req, timeout=5) as r:
                return (aid, name, url, r.status)
        except Exception as e:
            return (aid, name, url, str(e))

items = [(a['id'], a['name'], a['cover']) for a in apps]
print(f"Checking HTTP status for all {len(items)} cover URLs...")

with concurrent.futures.ThreadPoolExecutor(max_workers=20) as ex:
    results = list(ex.map(check_url, items))

failed = [x for x in results if x[3] != 200]
print(f"\nAudit complete: {len(results) - len(failed)} passed, {len(failed)} failed.")
if failed:
    for f in failed:
        print(f"FAILED: [{f[0]}] '{f[1]}' -> {f[2]} ({f[3]})")
else:
    print("SUCCESS: 100% of all 379 games return HTTP 200 OK!")
