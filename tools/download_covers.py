"""
Simple script to download book covers to `assets/covers/`.

Usage:
  - Create a CSV file `covers_to_download.csv` with header `id,url`.
  - Run: `python tools/download_covers.py`

The script will download each URL and save it as `assets/covers/book_{id}.{ext}`
and produce `assets/covers/mapping.json` with a map of id -> asset path.

Note: This script uses the standard library only.
"""
import csv
import json
import os
import sys
from urllib.request import urlopen, Request
from urllib.error import URLError, HTTPError

ROOT = os.path.dirname(os.path.dirname(__file__))
ASSET_DIR = os.path.join(ROOT, 'assets', 'covers')
CSV_PATH = os.path.join(ROOT, 'covers_to_download.csv')
MAPPING_PATH = os.path.join(ASSET_DIR, 'mapping.json')

os.makedirs(ASSET_DIR, exist_ok=True)

if not os.path.exists(CSV_PATH):
    print(f"Missing CSV: {CSV_PATH}")
    print("Create a file 'covers_to_download.csv' with header: id,url")
    sys.exit(1)

mapping = {}
with open(CSV_PATH, newline='', encoding='utf-8') as f:
    reader = csv.DictReader(f)
    for row in reader:
        book_id = row.get('id') or row.get('book_id')
        url = row.get('url')
        if not book_id or not url:
            print('Skipping invalid row:', row)
            continue
        try:
            req = Request(url, headers={'User-Agent': 'Mozilla/5.0'})
            with urlopen(req, timeout=20) as resp:
                info = resp.info()
                content_type = info.get_content_type()
                ext = 'jpg'
                if content_type == 'image/png':
                    ext = 'png'
                elif content_type == 'image/gif':
                    ext = 'gif'
                elif content_type == 'image/webp':
                    ext = 'webp'
                elif content_type == 'image/jpeg':
                    ext = 'jpg'
                else:
                    # fallback: try to infer from URL
                    lower = url.lower()
                    if lower.endswith('.png'):
                        ext = 'png'
                    elif lower.endswith('.webp'):
                        ext = 'webp'
                    elif lower.endswith('.gif'):
                        ext = 'gif'
                    elif lower.endswith('.jpg') or lower.endswith('.jpeg'):
                        ext = 'jpg'

                filename = f'book_{book_id}.{ext}'
                path = os.path.join(ASSET_DIR, filename)
                with open(path, 'wb') as out:
                    data = resp.read()
                    out.write(data)
                asset_path = os.path.join('assets', 'covers', filename).replace('\\', '/')
                mapping[str(book_id)] = asset_path
                print(f'Downloaded {book_id} -> {asset_path}')
        except (HTTPError, URLError) as e:
            print(f'Failed to download {url}: {e}')
        except Exception as e:
            print(f'Error for {url}: {e}')

with open(MAPPING_PATH, 'w', encoding='utf-8') as mf:
    json.dump(mapping, mf, indent=2, ensure_ascii=False)

print('\nMapping written to', MAPPING_PATH)
print('Update your book records to point `cover` or `cover_url` to the asset path (e.g. assets/covers/book_123.jpg)')