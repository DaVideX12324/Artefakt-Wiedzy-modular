"""Maska prototypu: przed | po przejściach czyszczących. Kolory: void/ściana, podłoga, chodnik, kwas, koryto,
kładka, portale; zmiany przejść: czerwony = ściana -> podłoga, niebieski = podłoga -> ściana."""
import json, sys
from PIL import Image, ImageDraw

src = json.load(open(sys.argv[1]))
post = json.load(open(sys.argv[2]))
out = sys.argv[3]
S = int(sys.argv[4]) if len(sys.argv) > 4 else 6
W, H = src['w'], src['h']
water = {tuple(p) for p in src['water']}
dry = {tuple(p) for p in src['dry']}
lanes = {tuple(p) for p in src['lanes']}
bridge = {tuple(c) for b in src['bridges'] for c in b['cells']}
service = {tuple(p) for p in src.get('service', [])}
gate = {tuple(c) for g in src.get('gates', []) for c in g}
hallc = {tuple(p) for p in src.get('halls', [])}
C = {'void': (14, 16, 20), 'wall': (40, 34, 30), 'floor': (122, 92, 64), 'lane': (150, 118, 84),
     'acid': (120, 170, 40), 'dry': (60, 74, 76), 'bridge': (200, 160, 90), 'service': (96, 120, 150), 'gate': (255, 140, 0)}


def is_wall(g, x, y):
    return not (0 <= x < W and 0 <= y < H) or g[y][x] == '#'


def draw(g, base=None):
    im = Image.new('RGB', (W * S, H * S), C['void'])
    d = ImageDraw.Draw(im)
    for y in range(H):
        for x in range(W):
            p = (x, y)
            if g[y][x] == '#':
                # ściana przy podłodze (pas do 5 kratek) ciemnobrązowa, dalej void
                near = any(not is_wall(g, x + dx, y + dy) for dx in range(-2, 3) for dy in range(-5, 3))
                col = C['wall'] if near else C['void']
            elif p in gate:
                col = C['gate']
            elif p in service:
                col = C['service']
            elif p in bridge:
                col = C['bridge']
            elif p in water:
                col = C['dry'] if p in dry else C['acid']
            elif p in lanes:
                col = C['lane']
            elif p in hallc:
                col = (214, 178, 58)
            else:
                col = C['floor']
            if base is not None and base[y][x] != g[y][x]:
                col = (220, 40, 40) if g[y][x] == '.' else (60, 110, 230)
            d.rectangle([x * S, y * S, x * S + S - 1, y * S + S - 1], fill=col)
    for k, col in (('entrance', (255, 255, 255)), ('exit', (255, 60, 200))):
        x, y = src['portals'][k]
        d.ellipse([x * S - 2 * S, y * S - 2 * S, x * S + 2 * S, y * S + 2 * S], outline=col, width=max(2, S // 2))
    for (x, y) in src.get('levers', []):
        d.rectangle([x * S - S, y * S - S, x * S + 2 * S, y * S + 2 * S], fill=(255, 230, 0), outline=(0, 0, 0))
    for gx in range(0, W, 25):   # siatka okien 25x25 (skala makiety)
        d.line([gx * S, 0, gx * S, H * S], fill=(70, 70, 90))
    for gy in range(0, H, 25):
        d.line([0, gy * S, W * S, gy * S], fill=(70, 70, 90))
    return im


a = draw(src['grid'])
b = draw(post['grid'], base=src['grid'])
pad = 12
im = Image.new('RGB', (a.width * 2 + pad, a.height), (40, 40, 40))
im.paste(a, (0, 0)); im.paste(b, (a.width + pad, 0))
im.save(out)
changed = sum(1 for y in range(H) for x in range(W) if src['grid'][y][x] != post['grid'][y][x])
print('zapisano', out, 'zmienione kratki', changed, 'czas', post['ms'], 'ms', post['stats'])
