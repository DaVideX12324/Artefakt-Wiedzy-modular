import json, random, heapq, math, sys
import numpy as np
from PIL import Image, ImageDraw, ImageFont

W, H = 288, 216          # kafle 16 px -> 4608 x 3456 px
SEED = int(sys.argv[1]) if len(sys.argv) > 1 else 7
HOUSE_TARGET = int(sys.argv[2]) if len(sys.argv) > 2 else 110
rnd = random.Random(SEED)
nrng = np.random.default_rng(SEED)

(VOID, GRASS, PATH, PLAZA, WATER, CLIFF, STAIRS, HOUSE, DOOR, GATE, TREES, STATION, BRIDGE, SPECIAL, OBJ,
 LIBRARY, HIDEOUT, SHOP, WALL, TOWER) = range(20)
NAMES = {
    VOID: "poza mapą", GRASS: "trawa (grunt)", PATH: "ścieżka / droga", PLAZA: "bruk / rynek", WATER: "woda",
    CLIFF: "skarpa (krawędź zmiany wysokości)", STAIRS: "schody / rampa", HOUSE: "dom (obrys)", DOOR: "drzwi",
    GATE: "brama (zamknięta barierą)", TREES: "zieleń / do obsadzenia drzewami", STATION: "stacja rzemieślnicza",
    BRIDGE: "most", SPECIAL: "wejście specjalne (jaskinia / ścieki)", OBJ: "obiekt (fontanna)",
    LIBRARY: "biblioteka", HIDEOUT: "Hideout (nauczyciele)", SHOP: "sklep", WALL: "mur miejski", TOWER: "wieża murów",
}
COLORS = {
    VOID: (20, 20, 28), GRASS: (96, 150, 72), PATH: (205, 170, 112), PLAZA: (160, 160, 172), WATER: (48, 112, 214),
    CLIFF: (110, 78, 54), STAIRS: (240, 214, 70), HOUSE: (186, 76, 62), DOOR: (255, 255, 255),
    GATE: (255, 150, 40), TREES: (52, 110, 48), STATION: (150, 84, 190), BRIDGE: (176, 138, 74),
    SPECIAL: (255, 60, 240), OBJ: (60, 220, 210), LIBRARY: (70, 100, 200), HIDEOUT: (230, 120, 150), SHOP: (240, 180, 60),
    WALL: (78, 78, 90), TOWER: (40, 40, 52),
}

cat = np.full((H, W), VOID, dtype=np.int16)
hgt = np.zeros((H, W), dtype=np.int8)       # -1 niecka / rzeka, 0 dolina, 1..3 kolejne tarasy
yy_g, xx_g = np.mgrid[0:H, 0:W]
labels = []


def noise(scale, octaves=3, persistence=0.5):
    out = np.zeros((H, W), np.float32)
    amp, tot = 1.0, 0.0
    for o in range(octaves):
        s = max(2, int(scale / (2 ** o)))
        gh, gw = H // s + 3, W // s + 3
        g = nrng.random((gh, gw)).astype(np.float32)
        im = Image.fromarray(g).resize((gw * s, gh * s), Image.BICUBIC)
        out += np.array(im)[s:s + H, s:s + W] * amp
        tot += amp
        amp *= persistence
    out /= tot
    return (out - out.min()) / (out.max() - out.min())


def dil(m, r):
    out = m.copy()
    for _ in range(r):
        p = np.pad(out, 1)
        out = out | p[0:H, 1:W + 1] | p[2:H + 2, 1:W + 1] | p[1:H + 1, 0:W] | p[1:H + 1, 2:W + 2]
    return out


def components(mask):
    seen = np.zeros_like(mask, dtype=bool)
    comps = []
    for y in range(H):
        for x in range(W):
            if mask[y, x] and not seen[y, x]:
                stack, comp = [(x, y)], []
                seen[y, x] = True
                while stack:
                    cx, cy = stack.pop()
                    comp.append((cx, cy))
                    for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
                        nx, ny = cx + dx, cy + dy
                        if 0 <= nx < W and 0 <= ny < H and mask[ny, nx] and not seen[ny, nx]:
                            seen[ny, nx] = True
                            stack.append((nx, ny))
                comps.append(comp)
    return comps


def fix_adjacent():
    for _ in range(2):
        bad = (hgt >= 1) & dil(hgt == -1, 1)
        hgt[bad] = 0


def blur(a, r):
    k = np.ones(2 * r + 1) / (2 * r + 1)
    a = np.apply_along_axis(lambda v: np.convolve(np.pad(v, r, mode="edge"), k, mode="valid"), 0, a)
    a = np.apply_along_axis(lambda v: np.convolve(np.pad(v, r, mode="edge"), k, mode="valid"), 1, a)
    return a


# --- 1. obrys murów: nieregularny wielokąt (geometria) ------------------------------------------------------------
CX, CY = W / 2, H / 2
RX, RY = W / 2 - 14, H / 2 - 14
NV = 17
verts = []
fs = []
for i in range(NV):
    th = (i + rnd.uniform(-0.35, 0.35)) * 2 * math.pi / NV
    f = rnd.uniform(0.72, 1.0)
    if rnd.random() < 0.18:
        f = rnd.uniform(0.60, 0.72)    # załamanie do środka
    fs.append(f)
for i in range(NV):               # lekkie wygładzenie sąsiednich promieni, by uniknąć sztucznych kolców
    fs[i] = 0.6 * fs[i] + 0.2 * fs[i - 1] + 0.2 * fs[(i + 1) % NV]
for i in range(NV):
    th = (i + rnd.uniform(-0.3, 0.3)) * 2 * math.pi / NV
    x = CX + math.cos(th) * fs[i] * RX
    y = CY + math.sin(th) * fs[i] * RY
    verts.append((min(max(x, 14), W - 15), min(max(y, 14), H - 15)))
poly_img = Image.new("L", (W, H), 0)
ImageDraw.Draw(poly_img).polygon(verts, fill=255)
inside = np.array(poly_img) > 0
wall_img = Image.new("L", (W, H), 0)
wd_ = ImageDraw.Draw(wall_img)
for i in range(NV):
    wd_.line([verts[i], verts[(i + 1) % NV]], fill=255, width=3)
wallline = np.array(wall_img) > 0
inside_er = inside & ~dil(wallline, 3)


def ray_to_wall(dx, dy):
    t = 0.0
    n = math.hypot(dx, dy)
    dx, dy = dx / n, dy / n
    while t < 400:
        x, y = int(CX + dx * t), int(CY + dy * t)
        if not (0 <= x < W and 0 <= y < H) or not inside[y, x]:
            return CX + dx * (t - 1), CY + dy * (t - 1), dx, dy
        t += 0.5
    return CX, CY, dx, dy


GATES = {}
for nm, ang in (("n", -90), ("e", 5), ("s", 95), ("w", 185)):
    a = math.radians(ang + rnd.uniform(-14, 14))
    gx, gy, dx, dy = ray_to_wall(math.cos(a), math.sin(a))
    GATES[nm] = (int(gx), int(gy), dx, dy)

# --- 2. teren: tarasy w różnych kierunkach, także przez miasto -----------------------------------------------------
def bump(cx, cy, sx, sy):
    return np.exp(-(((xx_g - cx * W) / (sx * W)) ** 2 + ((yy_g - cy * H) / (sy * H)) ** 2))


def ridge(ax, ay, bx, by, sigma, amp):
    ax, ay, bx, by = ax * W, ay * H, bx * W, by * H
    px, py = xx_g - ax, yy_g - ay
    dx, dy = bx - ax, by - ay
    t = np.clip((px * dx + py * dy) / (dx * dx + dy * dy), 0, 1)
    d = np.hypot(px - t * dx, py - t * dy)
    return amp * np.exp(-(d / sigma) ** 2)


warp = noise(60, 3) - 0.5
z = np.zeros((H, W), np.float32)
# płaskowyże poza miastem
for cx, cy, sx, sy, amp in [(0.46, -0.02, 0.18, 0.12, 1.0), (1.02, 0.46, 0.12, 0.22, 1.0), (-0.02, 0.72, 0.10, 0.18, 0.95),
                            (0.66, 1.03, 0.17, 0.12, 1.0), (0.06, 0.04, 0.10, 0.10, 0.62), (0.93, 0.97, 0.09, 0.09, 0.55)]:
    z = np.maximum(z, amp * bump(cx, cy, sx, sy))
# grzbiety przecinające miasto po skosie
z = np.maximum(z, ridge(0.10, 0.66, 0.58, 0.24, 9, 0.80))      # NE-SW, na północ od rynku
z = np.maximum(z, ridge(0.60, 0.92, 0.92, 0.48, 8, 0.78))      # NW-SE przez wschodnią część miasta
z = np.maximum(z, ridge(0.28, 0.90, 0.14, 0.66, 7, 0.60))      # krótka grzęda SW
# wzgórza wewnątrz murów
z = np.maximum(z, 1.0 * bump(0.64, 0.34, 0.075, 0.105))        # wzgórze biblioteki
z = np.maximum(z, 0.62 * bump(0.77, 0.70, 0.06, 0.09))
z = np.maximum(z, 0.60 * bump(0.28, 0.80, 0.055, 0.075))
z = z + warp * 0.6 * (0.30 + z)
z = np.clip(z, 0, 1)
hgt[z >= 0.30] = 1
hgt[z >= 0.52] = 2
hgt[z >= 0.74] = 3

PX, PY = int(W * 0.46), int(H * 0.52)
n2 = noise(30, 2)
flat_c = np.hypot(xx_g - PX, yy_g - PY) + (n2 - 0.5) * 12
hgt[flat_c < 30] = 0
LX, LY = int(W * 0.64), int(H * 0.34)
flat_lib = np.hypot(xx_g - LX, (yy_g - LY) * 1.2) + (n2 - 0.5) * 8
hgt[flat_lib < 14] = 3

# jaskinia: wnęka przy murze po zachodniej stronie, w środku miasta
cave_cands = []
for ang in range(150, 231, 10):
    a = math.radians(ang)
    gx, gy, dx, dy = ray_to_wall(math.cos(a), math.sin(a))
    cx_, cy_ = int(gx - dx * 12), int(gy - dy * 12)
    cave_cands.append((int(hgt[cy_, cx_]), abs(ang - 190), cx_, cy_))
cave_cands.sort()
CAVE = (cave_cands[0][2], cave_cands[0][3])
cave_h = int(hgt[CAVE[1], CAVE[0]])
hgt[np.hypot(xx_g - CAVE[0], yy_g - CAVE[1]) < 9] = cave_h
for nm, (gx, gy, dx, dy) in GATES.items():
    hv = int(hgt[gy, gx])
    hgt[np.hypot(xx_g - gx, yy_g - gy) < 7] = hv
for v in (1, 2, 3):
    for comp in components(hgt == v):
        if len(comp) < 140:
            for x, y in comp:
                hgt[y, x] = max(0, v - 1)

rect_in = (xx_g >= 4) & (xx_g <= W - 5) & (yy_g >= 4) & (yy_g <= H - 5)
cat[rect_in] = GRASS

# --- 3. rzeka: najniższy pas doliny (DP) ---------------------------------------------------------------------------
zs = blur(z, 8)
band0, band1 = int(H * 0.50), int(H * 0.88)
base_y = H * 0.70
cost = zs[band0:band1, :].copy() + 0.9 * (np.abs(np.arange(band0, band1) - base_y)[:, None] / H)
Hb = band1 - band0
dp = np.full((Hb, W), 1e9, np.float32)
bk = np.zeros((Hb, W), np.int16)
dp[:, 0] = cost[:, 0]
for x in range(1, W):
    for y in range(Hb):
        best, by = 1e9, y
        for dy in (-1, 0, 1):
            yy = y + dy
            if 0 <= yy < Hb and dp[yy, x - 1] < best:
                best, by = dp[yy, x - 1], yy
        dp[y, x] = best + cost[y, x] + (0.02 if by != y else 0.0)
        bk[y, x] = by
ycur = int(np.argmin(dp[:, W - 1]))
ymin = np.zeros(W)
for x in range(W - 1, -1, -1):
    ymin[x] = band0 + ycur
    ycur = int(bk[ycur, x])
k = np.ones(41) / 41
yc = np.convolve(np.pad(ymin, 20, mode="edge"), k, mode="valid")
n1d = np.array(Image.fromarray(nrng.random((1, 14)).astype(np.float32)).resize((W, 1), Image.BICUBIC))[0]
yc = yc + (n1d - 0.5) * 14
wd = 4 + 2.5 * np.array(Image.fromarray(nrng.random((1, 8)).astype(np.float32)).resize((W, 1), Image.BICUBIC))[0]
river_bank = np.zeros((H, W), bool)
river_water = np.zeros((H, W), bool)
for x in range(W):
    for y in range(H):
        dd = abs(y - yc[x])
        if dd < wd[x] / 2 + 2.5:
            river_bank[y, x] = True
        if dd < wd[x] / 2:
            river_water[y, x] = True
river_bank &= rect_in
river_water &= rect_in
hgt[river_bank] = -1
fix_adjacent()
cat[river_water] = WATER

# --- 4. mury, wieże, bramy ------------------------------------------------------------------------------------------
cat[wallline & rect_in & (cat != WATER)] = WALL        # nad rzeką mur ma przepust (woda płynie dalej)
for (vx, vy) in verts:
    x0, y0 = int(vx) - 2, int(vy) - 2
    cat[y0:y0 + 5, x0:x0 + 5] = TOWER
for nm, (gx, gy, dx, dy) in GATES.items():
    for y in range(gy - 5, gy + 6):
        for x in range(gx - 5, gx + 6):
            if 0 <= x < W and 0 <= y < H and math.hypot(x - gx, y - gy) <= 3.6 and cat[y, x] in (WALL, TOWER):
                cat[y, x] = GATE
    labels.append((gx - 10, gy - 5, "brama (bariera)"))

# --- 5. rynek i miejsca specjalne -------------------------------------------------------------------------------------
plaza = ((xx_g - PX) / 16.0) ** 2 + ((yy_g - PY) / 10.0) ** 2 < 1.0
plaza |= ((xx_g - (PX + 11)) / 9.0) ** 2 + ((yy_g - (PY + 6)) / 7.0) ** 2 < 1.0
plaza |= ((xx_g - (PX - 12)) / 8.0) ** 2 + ((yy_g - (PY - 4)) / 6.0) ** 2 < 1.0
plaza &= rect_in & (cat == GRASS) & (hgt == 0)
cat[plaza] = PLAZA
sunk = ((xx_g - PX) / 6.5) ** 2 + ((yy_g - PY) / 4.5) ** 2 < 1.0
hgt[sunk & plaza] = -1
cat[PY - 1:PY + 2, PX - 2:PX + 2] = OBJ
labels.append((PX - 12, PY - 14, "RYNEK (niecka -1)", (0, 0, 0)))

cat[CAVE[1] - 3:CAVE[1] + 3, CAVE[0] - 2:CAVE[0] + 2] = SPECIAL
labels.append((CAVE[0] - 4, CAVE[1] - 9, "JASKINIA / start"))

# dok ze ścieków: nad rzeką wewnątrz murów, na wschód od środka
DX = int(W * 0.66)
while DX > W * 0.4 and not inside_er[int(yc[DX] - wd[DX] / 2) - 12, DX]:
    DX -= 2
dock_y = int(yc[DX] - wd[DX] / 2)
hgt[dock_y - 9:dock_y + 1, DX - 8:DX + 8] = -1
cat[dock_y - 9:dock_y + 1, DX - 8:DX + 8] = PATH
cat[dock_y - 9:dock_y - 6, DX - 3:DX + 3] = SPECIAL
labels.append((DX - 7, dock_y - 14, "ŚCIEKI (dok)"))

lib_x0, lib_y0 = LX - 6, LY - 5
cat[lib_y0:lib_y0 + 9, lib_x0:lib_x0 + 12] = LIBRARY
cat[lib_y0 + 8, lib_x0 + 5:lib_x0 + 7] = DOOR
lib_door = (lib_x0 + 5, lib_y0 + 9)
labels.append((lib_x0 - 2, lib_y0 - 4, "BIBLIOTEKA (+3)"))
fix_adjacent()

# --- 6. ścieżki: A* + wygładzenie -------------------------------------------------------------------------------------------
extra = noise(10, 3) * 14.0
PATH_BASE = 0.45
NB = [(1, 0), (-1, 0), (0, 1), (0, -1), (1, 1), (1, -1), (-1, 1), (-1, -1)]
BLOCKED = (HOUSE, DOOR, LIBRARY, STATION, SPECIAL, OBJ, WALL, TOWER, HIDEOUT, SHOP)


def step_cost(u, v, goals=None):
    x, y = v
    if not (0 <= x < W and 0 <= y < H):
        return None
    c = cat[y, x]
    if goals is not None and v in goals:
        base = 0.6
    elif c == VOID:
        return None
    elif c == WATER:
        base = 1 + 30
    elif c in BLOCKED:
        return None
    elif c == GATE:
        base = 0.8
    elif c == PLAZA:
        base = 0.5
    elif c == PATH:
        base = PATH_BASE
    elif c == BRIDGE:
        base = 0.45
    else:
        base = 1 + extra[y, x]
    dh = abs(int(hgt[y, x]) - int(hgt[u[1], u[0]]))
    if dh:
        base += 22 * dh
    if abs(v[0] - u[0]) + abs(v[1] - u[1]) == 2:
        base *= 1.41
    return base


def astar(start, goals, heur_to=None, limit=250000):
    goals = set(goals)
    pq = [(0.0, 0.0, start)]
    dist = {start: 0.0}
    prev = {}
    n = 0
    while pq:
        f, d, u = heapq.heappop(pq)
        if d > dist.get(u, 1e18):
            continue
        if u in goals:
            path = [u]
            while u in prev:
                u = prev[u]
                path.append(u)
            return path[::-1]
        n += 1
        if n > limit:
            return None
        for dx, dy in NB:
            v = (u[0] + dx, u[1] + dy)
            c = step_cost(u, v, goals)
            if c is None:
                continue
            nd = d + c
            if nd < dist.get(v, 1e18):
                dist[v] = nd
                prev[v] = u
                hh = 0.45 * math.hypot(v[0] - heur_to[0], v[1] - heur_to[1]) if heur_to is not None else 0.0
                heapq.heappush(pq, (nd + hh, nd, v))
    return None


def smooth(path, win=11, passes=3):
    a = np.array(path, float)
    if len(a) < 5:
        return a
    r = win // 2
    for _ in range(passes):
        pad = np.pad(a, ((r, r), (0, 0)), mode="edge")
        kk = np.ones(win) / win
        b = np.stack([np.convolve(pad[:, i], kk, mode="valid") for i in range(2)], axis=1)
        b[0], b[-1] = a[0], a[-1]
        a = b
    return a


def paint_disk(cx, cy, r):
    for dy in range(-int(r) - 1, int(r) + 2):
        for dx in range(-int(r) - 1, int(r) + 2):
            if dx * dx + dy * dy > r * r + 0.3:
                continue
            nx, ny = cx + dx, cy + dy
            if not (0 <= nx < W and 0 <= ny < H):
                continue
            c = cat[ny, nx]
            if c in (GRASS, TREES):
                cat[ny, nx] = PATH
            elif c == WATER and not wallline[ny, nx]:
                cat[ny, nx] = BRIDGE


def draw_smooth(path, r):
    a = smooth(path)
    for i in range(len(a) - 1):
        d = math.hypot(*(a[i + 1] - a[i]))
        steps = max(1, int(d * 2))
        for s in range(steps + 1):
            p = a[i] + (a[i + 1] - a[i]) * (s / steps)
            paint_disk(int(round(p[0])), int(round(p[1])), r)


def road(a, b, r):
    p = astar(a, {b}, heur_to=b)
    if p is None:
        print("brak ścieżki", a, b)
        return
    draw_smooth(p, r)


def passable(pt, need_inside=True):
    x, y = pt
    x = min(max(int(x), 6), W - 7)
    y = min(max(int(y), 6), H - 7)
    ok = (GRASS, PATH, PLAZA, TREES)
    if cat[y, x] in ok and (not need_inside or inside_er[y, x]):
        return (x, y)
    for r in range(1, 18):
        for dy in range(-r, r + 1):
            for dx in range(-r, r + 1):
                nx, ny = x + dx, y + dy
                if 0 <= nx < W and 0 <= ny < H and cat[ny, nx] in ok and (not need_inside or inside_er[ny, nx]):
                    return (nx, ny)
    return (x, y)


NODES = {
    "rynek": (PX, PY + 12),
    "hub_ne": (int(W * 0.60), int(H * 0.46)),
    "hub_sw": (int(W * 0.34), int(H * 0.62)),
    "hub_s": (int(W * 0.52), int(H * 0.70)),
    "hub_w": (int(W * 0.30), int(H * 0.46)),
    "hub_e": (int(W * 0.72), int(H * 0.56)),
    "biblioteka": lib_door,
    "jaskinia": (CAVE[0], CAVE[1] + 5),
    "dok": (DX, dock_y - 10),
}
for nm, (gx, gy, dx, dy) in GATES.items():
    NODES["brama_" + nm] = (int(gx - dx * 9), int(gy - dy * 9))
mids = []
for _ in range(600):
    x, y = rnd.randint(30, W - 30), rnd.randint(24, H - 24)
    if inside_er[y, x] and cat[y, x] == GRASS and hgt[y, x] >= 0 and all(math.hypot(x - mx, y - my) > 30 for mx, my in mids) \
            and all(math.hypot(x - nx, y - ny) > 22 for nx, ny in NODES.values()):
        mids.append((x, y))
    if len(mids) >= 10:
        break
for i, m in enumerate(mids):
    NODES["m%d" % i] = m
KP = {k: passable(v) for k, v in NODES.items()}
names = list(KP)
inT = {"rynek"}
edges = []
while len(inT) < len(names):
    best = None
    for a in inT:
        for b in names:
            if b in inT:
                continue
            d = math.hypot(KP[a][0] - KP[b][0], KP[a][1] - KP[b][1])
            if best is None or d < best[0]:
                best = (d, a, b)
    inT.add(best[2])
    edges.append((best[1], best[2]))
have = {frozenset(e) for e in edges}
cand = sorted(((math.hypot(KP[a][0] - KP[b][0], KP[a][1] - KP[b][1]), a, b) for i, a in enumerate(names) for b in names[i + 1:]
               if frozenset((a, b)) not in have))
loops = [(a, b) for d, a, b in cand if d < 90][:13]
for a, b in edges:
    main = ("rynek" in (a, b)) or a.startswith("hub") or b.startswith("hub") or a.startswith("brama") or b.startswith("brama")
    road(KP[a], KP[b], 2.0 if main else 1.5)
PATH_BASE = 4.0
for a, b in loops:
    road(KP[a], KP[b], 1.5)
PATH_BASE = 0.45
# drogi za bramami: urywają się po kilkunastu kaflach (bariera)
for nm, (gx, gy, dx, dy) in GATES.items():
    ex, ey = int(gx + dx * 20), int(gy + dy * 20)
    out_pt = passable((ex, ey), need_inside=False)
    start = passable((int(gx + dx * 4), int(gy + dy * 4)), need_inside=False)
    road((gx, gy), out_pt, 1.5)

# --- 7. domy: tylko w obrębie murów, gęsto wzdłuż dróg -------------------------------------------------------------------
sizes = [(5, 6), (5, 6), (5, 6), (6, 7), (6, 7), (6, 7), (7, 8), (7, 8), (8, 9), (10, 9), (12, 10)]


def ok_house(x0, y0, w, h):
    if x0 < 10 or x0 + w > W - 10 or y0 < 10 or y0 + h + 3 > H - 10:
        return False
    L = int(hgt[y0, x0])
    if L < 0:
        return False
    for y in range(y0 - 1, y0 + h + 2):
        for x in range(x0 - 1, x0 + w + 1):
            if hgt[y, x] != L or not inside_er[y, x]:
                return False
            c = cat[y, x]
            inner = x0 <= x < x0 + w and y0 <= y < y0 + h
            if inner and c != GRASS:
                return False
            if (not inner) and c in (HOUSE, DOOR, LIBRARY, STATION, SPECIAL, OBJ, GATE, WATER, HIDEOUT, SHOP, WALL, TOWER):
                return False
    return True


ys_, xs_ = np.where(cat == PATH)
road_cells = [(x, y) for x, y in zip(xs_.tolist(), ys_.tolist()) if inside_er[y, x]]
wts = [0.25 + math.exp(-math.hypot(x - PX, y - PY) / 70.0) for x, y in road_cells]
houses = []
tries = 0
while len(houses) < HOUSE_TARGET and tries < 40000:
    tries += 1
    ax, ay = rnd.choices(road_cells, wts)[0]
    ang = rnd.uniform(0, 2 * math.pi)
    w, h = rnd.choice(sizes)
    for dist in range(4, 17):
        cx, cy = int(ax + math.cos(ang) * dist), int(ay + math.sin(ang) * dist)
        x0, y0 = cx - w // 2, cy - h // 2
        if x0 < 2 or y0 < 2 or x0 + w >= W or y0 + h >= H:
            break
        if ok_house(x0, y0, w, h):
            cat[y0:y0 + h, x0:x0 + w] = HOUSE
            dx = x0 + w // 2 - 1
            cat[y0 + h - 1, dx:dx + 2] = DOOR
            houses.append((x0, y0, w, h))
            break
print("domów:", len(houses))


def connect(start):
    ys2, xs2 = np.where(np.isin(cat, [PATH, PLAZA, BRIDGE, STAIRS]))
    goals = set(zip(xs2.tolist(), ys2.tolist()))
    p = astar(start, goals, limit=30000)
    if p:
        for x, y in p:
            for dx, dy in ((0, 0), (1, 0)):
                nx, ny = x + dx, y + dy
                if cat[ny, nx] in (GRASS, TREES):
                    cat[ny, nx] = PATH
    return p


for (x, y, w, h) in houses:
    connect((x + w // 2 - 1, y + h))
connect(lib_door)


def pick(side):
    cand = [hh for hh in houses if hh[2] >= 7 and 10 < math.hypot(hh[0] - PX, hh[1] - PY) < 50 and (hh[0] - PX) * side > 0 and cat[hh[1], hh[0]] == HOUSE]
    cand.sort(key=lambda hh: math.hypot(hh[0] - PX, hh[1] - PY))
    return cand[0] if cand else None


for side, c, nm in ((-1, HIDEOUT, "HIDEOUT"), (1, SHOP, "SKLEP")):
    hh = pick(side)
    if hh:
        x, y, w, h = hh
        for yy in range(y, y + h):
            for xx in range(x, x + w):
                if cat[yy, xx] == HOUSE:
                    cat[yy, xx] = c
        labels.append((x, y - 3, nm, (0, 0, 0)))

# --- 8. stacje rzemieślnicze przy rzece (wewnątrz murów) -------------------------------------------------------------------
near_water = dil(river_water, 34) & ~dil(river_water, 4) & inside_er
stations = []
for nm in ["alchemia", "tartak", "kuźnia", "kuchnia", "warsztat"]:
    for _ in range(20000):
        x, y = rnd.randint(14, W - 20), rnd.randint(14, H - 20)
        if not near_water[y, x]:
            continue
        L = int(hgt[y, x])
        ok = L == 0
        for yy in range(y - 1, y + 7):
            for xx in range(x - 1, x + 7):
                if not ok:
                    break
                if not (0 <= yy < H and 0 <= xx < W) or hgt[yy, xx] != L or cat[yy, xx] not in (GRASS, PATH) or not inside_er[yy, xx]:
                    ok = False
        if ok and all(math.hypot(x - sx, y - sy) > 22 for sx, sy, _ in stations):
            cat[y:y + 6, x:x + 6] = STATION
            stations.append((x, y, nm))
            connect((x + 2, y + 6))
            labels.append((x - 2, y - 3, nm))
            break

# --- 9. schody na krawędziach tarasów, skarpy ----------------------------------------------------------------------------------
rim = np.zeros((H, W), bool)
for y in range(1, H - 1):
    for x in range(1, W - 1):
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            if hgt[y + dy, x + dx] < hgt[y, x]:
                rim[y, x] = True
                break
road_like = np.isin(cat, [PATH, BRIDGE])
stairs_mask = dil(rim & road_like, 1) & road_like & (cat != BRIDGE)
cat[stairs_mask] = STAIRS
for sx, sy in ((PX, PY - 5), (PX, PY + 5), (PX - 7, PY), (PX + 7, PY)):
    for dy in range(-1, 2):
        for dx in range(-1, 2):
            if cat[sy + dy, sx + dx] == PLAZA:
                cat[sy + dy, sx + dx] = STAIRS
SKIP = {VOID, WATER, STAIRS, BRIDGE, HOUSE, DOOR, LIBRARY, STATION, SPECIAL, GATE, OBJ, HIDEOUT, SHOP, PATH, WALL, TOWER}
cliff = rim & ~np.isin(cat, list(SKIP))
cat[cliff] = CLIFF

# --- 10. drzewa: w mieście skąpo, poza murami gęsty las -------------------------------------------------------------------------
fn = noise(11, 3)
keep_clear = dil(np.isin(cat, [PATH, PLAZA, STAIRS, BRIDGE, HOUSE, DOOR, LIBRARY, STATION, HIDEOUT, SHOP, SPECIAL, GATE, OBJ, CLIFF, WALL, TOWER]), 3)
for y in range(H):
    for x in range(W):
        if cat[y, x] != GRASS or keep_clear[y, x]:
            continue
        d = min(x, y, W - 1 - x, H - 1 - y)
        if inside[y, x]:
            if fn[y, x] > 0.74:
                cat[y, x] = TREES
        else:
            if fn[y, x] > 0.50 or (d < 14 and rnd.random() < 0.9 - 0.06 * (d - 4)):
                cat[y, x] = TREES

# --- render -------------------------------------------------------------------------------------------------------------------------
def tint(c, h):
    if h > 0:
        f = 1 + 0.12 * h
        return tuple(min(255, int(v * f + 10 * h)) for v in c)
    if h < 0:
        return tuple(int(v * 0.72) for v in c)
    return c


img = Image.new("RGB", (W, H))
px = img.load()
hmap = Image.new("L", (W, H))
hp = hmap.load()
sketch = Image.new("L", (W, H))
sp = sketch.load()
FLAT = (VOID, DOOR, SPECIAL, STAIRS, BRIDGE, GATE, WALL, TOWER)
for y in range(H):
    for x in range(W):
        c = int(cat[y, x])
        px[x, y] = COLORS[c] if c in FLAT else tint(COLORS[c], int(hgt[y, x]))
        hv = int(hgt[y, x])
        hp[x, y] = 0 if c == VOID else (30, 70, 120, 175, 235)[hv + 1]
        base = (15, 45, 85, 140, 215)[hv + 1]
        if c in (PATH, STAIRS, PLAZA, BRIDGE):
            base = 225
        elif c in (HOUSE, HIDEOUT, SHOP, LIBRARY, STATION, DOOR):
            base = 95
        elif c in (WALL, TOWER, GATE):
            base = 150
        elif c == WATER:
            base = 5
        elif c == VOID:
            base = 0
        sp[x, y] = base
img.save("miasto_maska_1px.png")
hmap.save("miasto_wysokosc_1px.png")
sketch.resize((W * 3, H * 3), Image.NEAREST).save("miasto_szkic_gray_x3.png")

S = 5
big = img.resize((W * S, H * S), Image.NEAREST)
d = ImageDraw.Draw(big)
for gx in range(0, W + 1, 16):
    d.line([(gx * S, 0), (gx * S, H * S)], fill=(0, 0, 0), width=1)
for gy in range(0, H + 1, 16):
    d.line([(0, gy * S), (W * S, gy * S)], fill=(0, 0, 0), width=1)
try:
    font = ImageFont.truetype("/usr/share/fonts/truetype/dejavu/DejaVuSans-Bold.ttf", 13)
except Exception:
    font = ImageFont.load_default()
for lb in labels:
    x, y, t = lb[0], lb[1], lb[2]
    col = lb[3] if len(lb) > 3 else (255, 255, 255)
    d.text((x * S + 1, y * S + 1), t, fill=(0, 0, 0) if col != (0, 0, 0) else (255, 255, 255), font=font)
    d.text((x * S, y * S), t, fill=col, font=font)

used = sorted({int(v) for v in np.unique(cat)})
LEG_H = 130
canvas = Image.new("RGB", (W * S, H * S + LEG_H), (30, 30, 36))
canvas.paste(big, (0, 0))
d = ImageDraw.Draw(canvas)
cols = 4
cw = (W * S) // cols
for i, kk in enumerate(used):
    cx = (i % cols) * cw + 12
    cy = H * S + 10 + (i // cols) * 20
    d.rectangle([cx, cy, cx + 14, cy + 14], fill=COLORS[kk], outline=(255, 255, 255))
    d.text((cx + 22, cy), NAMES[kk], fill=(235, 235, 235), font=font)
d.text((12, H * S + LEG_H - 22), "jaśniejszy odcień = wyższy taras (0 dolina, +1..+3), ciemniejszy = obniżenie (-1), siatka co 16 kafli (1 kafel = 16 px)", fill=(200, 200, 200), font=font)
canvas.save("miasto_podglad_x5.png")

with open("legenda.json", "w", encoding="utf-8") as f:
    json.dump({
        "seed": SEED, "parametry": {"NV": NV, "promien_zwykly": [0.72, 1.0], "zalamanie": {"szansa": 0.18, "promien": [0.60, 0.72]}, "wygladzenie": [0.6, 0.2, 0.2], "domy_cel": HOUSE_TARGET}, "rozmiar_kafli": [W, H], "kafel_px": 16, "rozmiar_px": [W * 16, H * 16],
        "wysokosc": {"-1": "obniżenie (rzeka, niecka)", "0": "dolina", "1": "taras 1", "2": "taras 2", "3": "płaskowyż"},
        "mury": [[round(x, 1), round(y, 1)] for x, y in verts],
        "kategorie": {str(kk): {"nazwa": NAMES[kk], "kolor": "#%02x%02x%02x" % COLORS[kk]} for kk in used},
    }, f, ensure_ascii=False, indent=1)
np.savetxt("kategorie.csv", cat, fmt="%d", delimiter=",")
np.savetxt("wysokosc.csv", hgt, fmt="%d", delimiter=",")
print({NAMES[kk]: int((cat == kk).sum()) for kk in used})
