import json, sys, random, os, glob
import numpy as np
from PIL import Image, ImageDraw
sys.path.insert(0, '.')
import ldtk_rules as L

REPO = '/home/user/Artefakt-Wiedzy-modular'
ENV = REPO + '/assets/pixel_crawler/packs/free_pack_2.11/Pixel Crawler - Free Pack/Environment/'
REL = '../../../../../assets/pixel_crawler/packs/free_pack_2.11/Pixel Crawler - Free Pack/Environment/'
W = H = 80
rnd = random.Random(11)
Lr = np.load('layers.npy', allow_pickle=True).item()
objs = json.load(open('objs.json'))
ld = L.load(REPO + '/modules/quiz_rpg/scenes/maps/levels/town.ldtk')
rule_def = L.layer_def(ld, 'Podloga')

# --- maski z oryginału ---
road = Lr['Road'] != 4998
ground = Lr['Ground'] != 396
tall = Lr['Tall Grass'] != 8730
lev = np.clip(Lr['RockSlopes2'] - 22810, 0, 3)
auto = Lr['RockSlopes2_Auto'] != 0
man = Lr['Rock slopes manual'] != 0
cliffC = auto | man

# --- tilesety ---
sets = {}
g = 1
def add(name, rel, cols_img=True):
    global g
    im = Image.open(ENV + rel)
    cols, rows = im.width // 16, im.height // 16
    sets[name] = dict(first=g, cols=cols, rows=rows, rel=rel, w=im.width, h=im.height)
    g += cols * rows
add('Floors_Full', 'Tilesets/Floors_Full.png')
add('Wall_Tiles', 'Tilesets/Wall_Tiles.png')
add('Vegetation', 'Props/Static/Vegetation.png')
# kolekcja drzew
tree_files = sorted(f for f in glob.glob(ENV + 'Props/Static/Trees/Model_0*/Size_0?.png'))
trees_ts = {'first': g, 'items': []}
for i, f in enumerate(tree_files):
    im = Image.open(f)
    m = int(f.split('Model_')[1][:2]); s = int(f.split('Size_')[1][:2])
    trees_ts['items'].append(dict(id=i, rel=os.path.relpath(f, ENV), w=im.width, h=im.height, model=m, size=s))
g += len(tree_files)
print('drzewa:', [(t['model'], t['size'], t['w'], t['h']) for t in trees_ts['items']])

FF = sets['Floors_Full']['first']; WT = sets['Wall_Tiles']['first']; VG = sets['Vegetation']['first']

def autotile(csv):
    tiles = L.eval_rules(rule_def, csv, W, H, 24, seed=rnd.randrange(1, 99999))
    grid = np.zeros((H, W), int)
    for t in tiles:
        grid[t['px'][1] // 16, t['px'][0] // 16] = t['t'] + FF
    return grid

GRASS, STONE, DIRT = 1, 2, 3
sand_g = autotile([GRASS] * (W * H))
ground_g = autotile([int(v) for v in np.where(ground, DIRT, 0).ravel()])
road_g = autotile([int(v) for v in np.where(road, STONE, 0).ravel()])

# --- skały: Wall_Tiles (blok brązowy, kolumny 0-5). Wybór kafla z sąsiedztwa maski cliffC ---
def rock_tile(mask, x, y, base_col=0):
    def m(xx, yy):
        return 0 <= xx < W and 0 <= yy < H and mask[yy, xx]
    n, s, w, e = m(x, y - 1), m(x, y + 1), m(x - 1, y), m(x + 1, y)
    if not w:
        col = 0
    elif not e:
        col = 5
    else:
        col = 1 + (x + y // 2) % 4
    if not n:
        row = 5
    elif not s:
        row = 8
    else:
        row = 6 + (y % 2)
    return WT + row * 25 + base_col + col

auto_g = np.zeros((H, W), int); man_g = np.zeros((H, W), int)
for y in range(H):
    for x in range(W):
        if auto[y, x]:
            auto_g[y, x] = rock_tile(cliffC, x, y)
        if man[y, x]:
            man_g[y, x] = rock_tile(cliffC, x, y)
# RockSlopes2 (marker poziomów) -> wierzch płaskowyżu: kolor bloku z Wall_Tiles wg poziomu (2 = szary, 3 = ciemny), środek bloku
rs_g = np.zeros((H, W), int)
for y in range(H):
    for x in range(W):
        if lev[y, x] >= 2 and not cliffC[y, x]:
            rs_g[y, x] = WT + (1 + (y % 4)) * 25 + 1 + (x % 4)   # środek wierzchu skał (blok brązowy, kolumny 1-4, wiersze 1-4)

# --- wysoka trawa: kępki z Vegetation ---
tufts = [(9, 1), (9, 2), (9, 3), (10, 0), (10, 1), (10, 2), (11, 0), (11, 1)]
tall_g = np.zeros((H, W), int)
for y in range(H):
    for x in range(W):
        if tall[y, x] and rnd.random() < 0.55:
            r, c = rnd.choice(tufts)
            tall_g[y, x] = VG + r * 25 + c

empty = np.zeros((H, W), int)
def layer(lid, name, grid):
    rows = ',\n'.join(','.join(str(int(v)) for v in grid[y]) for y in range(H))
    return f' <layer id="{lid}" name="{name}" width="{W}" height="{H}">\n  <data encoding="csv">\n{rows}\n</data>\n </layer>'

# --- obiekty ---
oid = 1
def tree_pick(o):
    model = o['lid'] % 3 + 1
    cand = [t for t in trees_ts['items'] if t['model'] == model]
    return min(cand, key=lambda t: abs(t['h'] - o['h']))


group1, group2 = [], []
def obj_xml(o, bucket):
    global oid
    if o['set'] == 'Trees_Desert':
        t = tree_pick(o)
        sc = max(o['h'], 24) / t['h']          # skala do wysokości oryginalnego obiektu (sprite'y paczki są znacznie większe)
        nw, nh = t['w'] * sc, t['h'] * sc
        bx = o['x0'] + o['w'] / 2 - nw / 2
        by = o['y0'] + o['h']
        bucket.append(f'  <object id="{oid}" name="Drzewo" type="Tree" gid="{trees_ts["first"] + t["id"]}" x="{bx:.1f}" y="{by:.1f}" width="{nw:.1f}" height="{nh:.1f}">\n'
                      f'   <properties>\n    <property name="model" type="int" value="{t["model"]}"/>\n    <property name="size" type="int" value="{t["size"] - 1}"/>\n   </properties>\n  </object>')
    else:
        kind = {'Buildings_Desert': 'Building', 'Rocks_Desert': 'Rock', 'Props_Desert': 'Prop'}.get(o['set'], 'Prop')
        name = {'Building': 'Budynek', 'Rock': 'Skala', 'Prop': 'Rekwizyt'}[kind]
        bucket.append(f'  <object id="{oid}" name="{name}" type="{kind}" x="{o["x0"]:.1f}" y="{o["y0"]:.1f}" width="{o["w"]:.1f}" height="{o["h"]:.1f}">\n'
                      f'   <properties>\n    <property name="original_tileset" value="{o["set"]}"/>\n    <property name="original_tile" type="int" value="{o["lid"]}"/>\n   </properties>\n  </object>')
    oid += 1
# oryginalne dwie grupy obiektów: Object Layer 2 (3 obiekty) i Object Layer 1 (reszta)
import xml.etree.ElementTree as ET
r = ET.parse('/root/.claude/uploads/0e17de7a-cba0-50f5-80ea-f4e05142e0b7/3d5545ce-Desert_Town.tmx').getroot()
import bisect
tsx = [(int(c.attrib['firstgid']), c.attrib['source'].split('/')[-1]) for c in r if c.tag == 'tileset']
fg = [a for a, _ in tsx]
def locate(gid):
    i = bisect.bisect_right(fg, gid) - 1
    return tsx[i][1].replace('.tsx', '').replace('Objects_', ''), gid - tsx[i][0]
for og in r.findall('objectgroup'):
    bucket = group2 if og.get('name') == 'Object Layer 2' else group1
    for o in og:
        gid = o.get('gid')
        if not gid:
            continue
        s, lid = locate(int(gid))
        w, h = float(o.get('width')), float(o.get('height'))
        obj_xml(dict(set=s, lid=lid, x0=float(o.get('x')), y0=float(o.get('y')) - h, w=w, h=h), bucket)

# --- zapis TMX w kolejności oryginalnych warstw ---
ts_xml = []
for name, s in sets.items():
    ts_xml.append(f' <tileset firstgid="{s["first"]}" name="{name}" tilewidth="16" tileheight="16" tilecount="{s["cols"]*s["rows"]}" columns="{s["cols"]}">\n'
                  f'  <image source="{REL}{s["rel"]}" width="{s["w"]}" height="{s["h"]}"/>\n </tileset>')
tx = [f' <tileset firstgid="{trees_ts["first"]}" name="Trees" tilewidth="{max(t["w"] for t in trees_ts["items"])}" tileheight="{max(t["h"] for t in trees_ts["items"])}" tilecount="{len(trees_ts["items"])}" columns="0">',
      '  <grid orientation="orthogonal" width="1" height="1"/>']
for t in trees_ts['items']:
    tx.append(f'  <tile id="{t["id"]}">\n   <image source="{REL}{t["rel"]}" width="{t["w"]}" height="{t["h"]}"/>\n  </tile>')
tx.append(' </tileset>')
ts_xml.append('\n'.join(tx))
body = [
    layer(1, 'Sand', sand_g), layer(2, 'Ground', ground_g), layer(3, 'Road', road_g), layer(4, 'Shadow', empty),
    layer(5, 'Wall', empty), layer(6, 'RockSlopes2', rs_g), layer(7, 'RockSlopes2_Auto', auto_g),
    layer(8, 'Rock slopes manual', man_g), layer(9, 'Fence back', empty),
    ' <objectgroup id="10" name="Object Layer 2">\n' + '\n'.join(group2) + '\n </objectgroup>',
    layer(11, 'Tall Grass', tall_g),
    ' <objectgroup id="12" name="Object Layer 1">\n' + '\n'.join(group1) + '\n </objectgroup>',
    layer(13, 'Fence Front', empty),
]
tmx = ('<?xml version="1.0" encoding="UTF-8"?>\n'
       f'<map version="1.10" tiledversion="1.10.1" orientation="orthogonal" renderorder="right-down" width="{W}" height="{H}" tilewidth="16" tileheight="16" infinite="0" nextlayerid="14" nextobjectid="{oid}">\n'
       + '\n'.join(ts_xml) + '\n' + '\n'.join(body) + '\n</map>\n')
open('tmx2/Desert_Town_Pixel_Crawler.tmx', 'w', encoding='utf-8').write(tmx)
print('TMX zapisany;', 'obiektów:', oid - 1, 'tilesety:', {k: v['first'] for k, v in sets.items()}, 'drzewa od', trees_ts['first'])

# --- podgląd: złożenie warstw z TMX (kafle + drzewa) ---
def atlas(name):
    return Image.open(ENV + sets[name]['rel']).convert('RGBA')
A = {n: atlas(n) for n in sets}
def draw_grid(img, grid):
    for y in range(H):
        for x in range(W):
            gid = int(grid[y, x])
            if not gid:
                continue
            for n, s in sets.items():
                if s['first'] <= gid < s['first'] + s['cols'] * s['rows']:
                    t = gid - s['first']
                    sx, sy = (t % s['cols']) * 16, (t // s['cols']) * 16
                    img.alpha_composite(A[n].crop((sx, sy, sx + 16, sy + 16)), (x * 16, y * 16))
                    break
img = Image.new('RGBA', (W * 16, H * 16), (105, 106, 121, 255))
for grid in (sand_g, ground_g, road_g, rs_g, auto_g, man_g, tall_g):
    draw_grid(img, grid)
d = ImageDraw.Draw(img, 'RGBA')
tree_img = {t['id']: Image.open(ENV + t['rel']).convert('RGBA') for t in trees_ts['items']}
import re
for line in group1 + group2:
    m = re.search(r'type="(\w+)" (?:gid="(\d+)" )?x="([-\d.]+)" y="([-\d.]+)" width="([-\d.]+)" height="([-\d.]+)"', line)
    typ, gid, x, y, w, h = m.group(1), m.group(2), float(m.group(3)), float(m.group(4)), float(m.group(5)), float(m.group(6))
    if typ == 'Tree':
        im = tree_img[int(gid) - trees_ts['first']]
        im2 = im.resize((max(1, int(w)), max(1, int(h))), Image.LANCZOS)
        img.alpha_composite(im2, (int(x), int(y - h))) if 0 <= x < W * 16 - w and 0 <= y - h < H * 16 - h else None
    elif typ == 'Building':
        d.rectangle([x, y, x + w, y + h], outline=(220, 40, 40, 255), fill=(220, 40, 40, 90), width=2)
    elif typ == 'Rock':
        d.ellipse([x, y, x + w, y + h], fill=(130, 130, 140, 200))
    else:
        d.rectangle([x, y, x + w, y + h], fill=(190, 90, 200, 200))
img.convert('RGB').save('podglad_tmx2.png')
